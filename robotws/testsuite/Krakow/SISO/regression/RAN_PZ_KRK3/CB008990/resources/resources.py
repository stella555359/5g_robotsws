import logging
import time
import re
import random
from datetime import datetime
from functools import wraps
from inspect import getcallargs
from moler.device import DeviceFactory
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.bts.devices.du.du_operations import login_logout
from taf.rfrl.bts.devices.du.alarm_verification import GnbAlarmVerification
from taf.rfrl.bts.connections import device_aliases
from taf.rfrl.bts.devices.ru.ru_operations import GenericRuOperations
from taf.rfrl.bts.devices.du.logs_collecting.basic_logs import GnbLog
from taf.rfrl.bts.devices.du.cell_operations import GenericCellOperations
from taf.rfrl.bts.helpers.dist_name import get_id_from_dist_name

rfsw_log_list = ['startup', 'runtime', 'UnitOAM_SOAP', 'bbox3', 'ant_discovery',
                 'pm_1_syslog', 'pm_2_syslog', 'pm_startup_DEFAULT', 'pm_UnitOAM_SOAP_Log',
                 'pm_ant_discovery_log', 'pm_fault_history_log', 'fault_history', 'version', 'clock_service']

rfsw_log_list_aphg = ['ptp_log_0000', 'rocal_state']

prrh_logs_gen1 = {'EID_': 1, 'RFSW_tx_gain_trace_': 6, 'Squatch_Dump_Ant_': 1, 'cal_': 1}

prrh_logs_gen2 = {'EID_': 1, 'RFSW_tx_gain_trace_': 4, 'Squatch_Dump_Ant_': 1, 'rfsw_asi5g-tx-cal-cache': 1,
                  'rfsw_asir-rx-cal-cache': 1}

bts_alarms = ['Service account root access is enabled', 'Ethernet port security is disabled', 'SSH enabled',
              'R&D Service Port enabled', 'LMP access via port 443', 'NgGnbInitPartialReset']

fault_1907_recovery = [{
    'number': '7101',
    'faultId': '1907',
    'faultName': 'Radio autonomous reset as recovery action',
    'severity': 'Warning'
}]

fault_1907 = [{
    'number': '7116',
    'faultId': '1907',
    'faultName': 'FR module reset requested',
    'severity': 'Critical'
}]

fault_recovery1 = [{
    'number': '7115',
    'faultId': '4592',
    'faultName': 'BTS Reset Cause',
    'severity': 'Warning'
}]

fault_1904_recovery1 = [{
    'number': '7101',
    'faultId': '1904',
    'faultName': 'Radio autonomous reset as recovery action',
    'severity': 'Warning'
}]

fault_1904_recovery2 = {
    'number': '7101',
    'faultId': '1904',
    'faultName': 'Baseband card autonomous reset as recovery action',
    'severity': 'Warning'
}

fault_1904_recovery3 = {
    'number': '7101',
    'faultId': '1904',
    'faultName': 'Baseband card power autonomous reset as recovery action',
    'severity': 'Warning'
}

fault_1904 = [{
    'number': '7116',
    'faultId': '1904',
    'faultName': 'RF BB bus synchronization error',
    'severity': 'Critical'
}]

fault_7312 = {
    'number': '7115',
    'faultId': '7312',
    'faultName': 'NgGnbInitFullReset',
    'severity': 'Warning'
}


def _get_bts_id_arg_name(passed_args):
    if 'gnb_id' in passed_args:
        return 'gnb_id'
    elif 'enb_id' in passed_args:
        return 'enb_id'
    elif 'bts_id' in passed_args:
        return 'bts_id'
    else:
        raise ValueError("One of parameter [gnb_id, enb_id, bts_id] is required")


def alarm_watcher(web_fun):
    """
    Starts alarm watcher with proper alarms depending on which test is beeing executed.
    """

    @wraps(web_fun)
    def wrapper(self, *args, **kwargs):
        passed_args = getcallargs(web_fun, self, *args, **kwargs)
        if "ru_fault_name" in passed_args and "sleep_time" not in passed_args:
            if passed_args["ru_fault_name"] == "EFaultId_BBBus_SyncError":
                if int(passed_args["iteration_number"]) < 3:
                    self.alarms.allow_alarm(bts_id=passed_args["bts_id"],
                                            du_id=passed_args["du_id"], alarm=fault_1904_recovery1)
                elif 3 <= int(passed_args["iteration_number"]) < 5:
                    self.alarms.allow_alarm(bts_id=passed_args["bts_id"],
                                            du_id=passed_args["du_id"], alarm=[fault_1904_recovery2, fault_7312])
                elif int(passed_args["iteration_number"]) == 5:
                    self.alarms.allow_alarm(bts_id=passed_args["bts_id"],
                                            du_id=passed_args["du_id"], alarm=[fault_1904_recovery3, fault_7312])
                elif int(passed_args["iteration_number"]) > 5:
                    self.alarms.allow_alarm(bts_id=passed_args["bts_id"],
                                            du_id=passed_args["du_id"], alarm=fault_1904)
            elif passed_args["ru_fault_name"] == "EFaultId_FrDfeNoTxDataAl":
                if int(passed_args["iteration_number"]) < 3:
                    self.alarms.allow_alarm(bts_id=passed_args["bts_id"],
                                            du_id=passed_args["du_id"], alarm=fault_1907_recovery)
                else:
                    self.alarms.allow_alarm(bts_id=passed_args["bts_id"],
                                            du_id=passed_args["du_id"], alarm=fault_1907)
        try:
            web_fun(**passed_args)
        except Exception:
            self.alarms.stop_watching_alarms(bts_id=passed_args["bts_id"],
                                             du_id=passed_args["du_id"])
            raise
    return wrapper


class WrongFilteringTime(Exception):
    pass


class FaultNotTriggered(Exception):
    pass


class FaultTriggered(Exception):
    pass


class FaultWrongSeverity(Exception):
    pass


class UnexpectedFaultRU(Exception):
    pass


class RuFaults(GenericRuOperations):
    bts_type = 'GNB'
    cells = GenericCellOperations()
    alarms = GnbAlarmVerification()
    ru = None

    def __init__(self):
        super().__init__(bts_type=RuFaults.bts_type)

    @login_logout
    def _get_ru_id_from_bts(self, bts_id=0, du_id=0, ru_id=0):
        """
        Get RU id from bts
        :param bts_id: BTS id - related to Test Line configuration. Default: 0
        :param du_id:  DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]. Default:0
        :param ru_id: ID of radio unit related to Test Line configuration file. Default: 0
        :return radio_id_bts: Get RU id from bts
        """
        sn = self._get_ru_serial_number(bts_id=bts_id, du_id=du_id, radio_id=ru_id)
        rus_info = self._get_all_rus_info(bts_id=bts_id, du_id=du_id)
        for radio in rus_info:
            if sn == radio.get("serialNumber"):
                radio_id_bts = get_id_from_dist_name(dist_name=radio['id']['configuration'])
                return radio_id_bts

    @load_moler_configuration_from_tl()
    def login_to_ru(self, bts_type="GNB", bts_id=0, du_id=0, ru_id=0):
        """
        Logs in to given RU.
        :param bts_type: GNB or ENB
        :param bts_id: BTS id - related to Test Line configuration. Default: 0
        :param du_id:  DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]. Default: 0
        :param ru_id:  ID of radio unit related to Test Line configuration file. Default: 0
        :return ru: moler object of RU
        """
        ru = DeviceFactory.get_device(device_aliases.ssh_bts_du_ru.format(bts_type,
                                                                          bts_id, du_id, ru_id),
                                      establish_connection=False)
        ru.goto_state(state="RU")
        return ru

    def trigger_or_cancel_fault_1904(self, interface, trigger=True):
        """
        Triggers or cancels fault 1904
        :param interface: interface name which connects DFE with Beamer.
        :param trigger:  True to trigger fault, False to cancel it. Default: True
        :return trigger_timestamp: Date time formats, pointing out when fault has been started.
        """
        if not isinstance(trigger, bool):
            raise ValueError("Please use proper value True to trigger the fault, False to clear it")
        if trigger:
            up_down = "down"
        elif not trigger:
            up_down = "up"
        self.ru.goto_state(state="RU")
        up_down_int = self.ru.get_cmd(cmd_name="sudo",
                                      cmd_params={
                                          "sudo_params": "{}".format("ifconfig {} {}".format(interface, up_down)),
                                      })
        up_down_int()
        trigger_timestamp = self._get_time_on_ru()
        return trigger_timestamp

    def check_if_fault_is_active(self, ru_fault, severity="critical"):
        """
        Checks if RU reported given fault in  /run/fault_history_log_temp.txt file.
        :param ru_fault: Ru fault name which should be raised on RU.
        :param severity:  Severity of fault. Default: critical
        :return trigger_timestamp: Date time format, pointing out when fault has been spoted by RU.
        """
        cat = self.ru.get_cmd(cmd_name="cat", cmd_params={"path": "{}".format("/run/fault_history_log_temp.txt | "
                                                                              "awk '/Active "
                                                                              "faults:/,/InActive faults:/' "),
                                                          })
        cat_output = cat()
        all_faults = list(filter(lambda x: re.search('<(.*)>.*', x), cat_output['LINES']))
        if len(all_faults) > 1:
            raise UnexpectedFaultRU("Unexpected fault raised {}".format(all_faults))
        elif len(all_faults) == 0:
            raise FaultNotTriggered("Fault {} has not been triggered".format(ru_fault))
        elif ru_fault not in all_faults[0]:
            raise UnexpectedFaultRU("Fault {} has not been triggered, different fault raised instead {}"
                                    .format(ru_fault, all_faults[0]))
        elif severity not in all_faults[0]:
            raise FaultWrongSeverity("Fault {} had wrong severity".format(ru_fault))
        error_timestamp = re.search(r"<(.*)\.", all_faults[0]).group(1)
        error_timestamp = datetime.strptime(error_timestamp, "%Y-%m-%dT%H:%M:%S")
        error_timestamp = time.mktime(error_timestamp.timetuple())
        return error_timestamp

    def check_if_fault_appeared_on_ru_after_filtering_time(self, ru_fault, filtering_time, trigger_timestamp,
                                                           severity="critical", step=2, timeout=50):
        """
        Checks if RU will report fault in  /run/fault_history_log_temp.txt file within given time.
        :param ru_fault: Ru fault name which should be raised on RU.
        :param filtering_time: Filtering time for given fault, after which fault should be reported.
        :param trigger_timestamp: date time object pointing out moment of triggering fault.
        :param severity:  Severity of fault. Default: critical
        :param step:  Time in seconds to wait between RU fault checks.
        :param timeout: Timeout.
        """
        start_time = time.time()
        while (time.time() - start_time) < timeout:
            try:
                error_timestamp = self.check_if_fault_is_active(ru_fault, severity)
                if error_timestamp - trigger_timestamp < filtering_time:
                    raise WrongFilteringTime(
                        "Fault {} has not been triggered within {}s of filtering time, instead it took {}s".format(
                            ru_fault,
                            filtering_time,
                            (error_timestamp - trigger_timestamp)))
                return
            except FaultNotTriggered:
                logging.info("Fault {} has not yet appeared".format(ru_fault))
                time.sleep(step)
            else:
                raise
        raise FaultNotTriggered("Fault {} has not been triggered within {t}s of waiting".format(ru_fault, t=timeout))

    def _create_script_text_for_frmon(self, carrier_ant_dict):
        """
         Creates frmonShell part of command based on provided dictionary.
         :param carrier_ant_dict: Dictionary containing keys as tx carrier name eg. NR77103.TX_3_500_264 and value as
         antenna name mapped to this carrier eg. antenna1a.
         :return script_text: part of frmonShell command as string.
         """
        script_text = "/ action create CarrierFaultInjection /dfe"
        for carrier in carrier_ant_dict:
            script_text += '\n/dfe action break_tx_data_transmission "{}" "{}"'.format(carrier,
                                                                                       carrier_ant_dict[carrier])
        return script_text

    def _get_time_on_ru(self):
        """
         Get current time on RU.
         :param prompt: prompt of RU.
         :return trigger_timestamp: Date time format, current RU time
         """
        time_exec = self.ru.get_cmd(cmd_name="date")
        trigger_timestamp = time_exec()
        trigger_timestamp = trigger_timestamp['DATE']['FULL'] + "T" + trigger_timestamp['TIME']['FULL']
        trigger_timestamp = datetime.strptime(trigger_timestamp, "%d-%m-%YT%H:%M:%S")
        trigger_timestamp = time.mktime(trigger_timestamp.timetuple())
        return trigger_timestamp

    def trigger_fault_1907(self, dfe_ip, carrier_ant_dict):
        """
         Triggers fault  1907 BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION on RU
         :param dfe_ip: RUs' DFE ip address
         :param carrier_ant_dict: Dictionary containing keys as tx carrier name eg. NR77103.TX_3_500_264 and value as
         antenna name mapped to this carrier eg. antenna1a.
         :return trigger_timestamp: Date time formats, pointing out when fault has been started.
         """
        self.ru.goto_state("RU")
        ssh = self.ru.get_cmd(cmd_name="ssh",
                              cmd_params={
                                  "login": "serviceuser",
                                  "host": "{}".format(dfe_ip),
                                  "prompt_after_login": r'^\$\s*$',
                                  "set_prompt": r'export PS1="\u@molerRU $(pwd)>"',
                                  "expected_prompt": r"\S+@molerRU.*>"
                              })
        ssh()
        script_text = self._create_script_text_for_frmon(carrier_ant_dict)
        echo = self.ru.get_cmd(cmd_name="echo", cmd_params={
                                                            "text": script_text,
                                                            "write_mode": ">",
                                                            "output_file": "/tmp/script1.txt",
                                                            "options": "-e"})
        echo()
        carrier_fault = self.ru.get_cmd(cmd_name="run_script",
                                        cmd_params={
                                            "script_command": "frmonShellClient 127.0.0.1 2000 /tmp/script1.txt"})

        exit_cmd = self.ru.get_cmd("exit", cmd_params={"expected_prompt": r"\S+@molerRU.*>"})
        carrier_fault()
        trigger_timestamp = self._get_time_on_ru()
        exit_cmd()
        return trigger_timestamp

    @alarm_watcher
    def check_if_fault_1907_appeared(self, dfe_ip, carrier_ant_dict, randomize_tx=False,
                                     iteration_number=0, filtering_time=37, ru_id=0,
                                     ru_fault_name="EFaultId_FrDfeNoTxDataAl",
                                     bts_id=0, du_id=0):
        """
         Triggers fault 1907  BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION,
         and checks if everything behave as expected.
         :param dfe_ip: RUs' DFE ip address
         :param carrier_ant_dict: Dictionary containing keys as tx carrier name eg. NR77103.TX_3_500_264 and value as
         antenna name mapped to this carrier eg. antenna1a.
         :param randomize_tx: Bool variable, if True, method will pick randomly key:values paris from carrier_ant_dict.
         Default: False
         :param iteration_number: This parameter is pointing out how many fault trigger attempts were done, cause
         behavior of this fault is different depending on number of tries. Default:0
         :param filtering_time: Time in seconds, points out moment when Ru should spot the fault after it has
         been triggered. Default: 35
         :param ru_id: ID of radio unit related to Test Line configuration file. Default: 0
         :param ru_fault_name: Fault name, that should be visible on RU. Default:EFaultId_FrResetRequestedAl
         :param bts_id: BTS id - related to Test Line configuration. Default: 0
         :param du_id:  DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]. Default: 0
         """
        self.ru = self.login_to_ru(ru_id=ru_id)
        if randomize_tx:
            number_of_tx = random.randint(1, len(carrier_ant_dict))
            carrier_ant_keys_rand = random.sample(carrier_ant_dict.keys(), number_of_tx)
            carrier_ant_dict = dict((key, carrier_ant_dict.pop(key)) for key in carrier_ant_keys_rand)
        self.cells.verify_all_cells_statuses(availability_status="online", operational_state="enabled",
                                             administrative_state="unlocked", blocking_state="unblocked",
                                             procedural_status="configured", usage_state=None,
                                             barring_status="unbarred")
        radio_id_bts = self._get_ru_id_from_bts(bts_id=bts_id, du_id=du_id, ru_id=ru_id)
        trigger_timestamp = self.trigger_fault_1907(dfe_ip=dfe_ip, carrier_ant_dict=carrier_ant_dict)
        self.check_if_fault_appeared_on_ru_after_filtering_time(ru_fault_name, filtering_time, trigger_timestamp)
        self.alarms.wait_for_alarm_activation(bts_id=bts_id, du_id=du_id, fault_id=1907)
        self.verify_radio_unit_statuses(bts_id=bts_id, du_id=du_id, ru_id=radio_id_bts, operational_state="disabled",
                                        procedural_status=None, availability_status="failed",
                                        administrative_state="unlocked", usage_state="idle", power_state='AWAKE')
        if int(iteration_number) >= 3:
            self.reset_radio_unit(bts_id=bts_id, du_id=du_id, radio_unit_id=radio_id_bts)
        self.alarms.wait_for_alarm_deactivation(bts_id=bts_id, du_id=du_id, fault_id=1907)
        self.cells.wait_for_all_cells_to_be_onair(timeout=300)
        self.verify_radio_unit_statuses(bts_id=bts_id, du_id=du_id, ru_id=radio_id_bts, operational_state="enabled",
                                        procedural_status="configured", availability_status=None,
                                        administrative_state="unlocked", usage_state="active", power_state='AWAKE')

    @alarm_watcher
    def check_if_fault_1904_appeared(self, interface, filtering_time=30, iteration_number=0,
                                     ru_fault_name="EFaultId_BBBus_SyncError",
                                     bts_id=0, du_id=0, ru_id=0):
        """
         Triggers fault 1904, and checks if everything behave as expected.
         :param interface: interface names which connects DFE and Beamer on RU
         :param filtering_time: Time in seconds, points out moment when Ru should spot the fault after it has
         been triggered. Default:30
         :param iteration_number: This parameter is pointing out how many fault trigger attempts were done, cause
         behavior of this fault is different depending on number of tries. Default:0
         :param ru_fault_name: Fault name, that should be visible on RU. Default: EFaultId_BBBus_SyncError
         :param ru_id: ID of radio unit related to Test Line configuration file. Default: 0
         :param bts_id: BTS id - related to Test Line configuration. Default: 0
         :param du_id:  DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]. Default: 0
         """
        self.ru = self.login_to_ru(ru_id=ru_id)
        self.cells.verify_all_cells_statuses(availability_status="online", operational_state="enabled",
                                             administrative_state="unlocked", blocking_state="unblocked",
                                             procedural_status="configured", usage_state=None,
                                             barring_status="unbarred")
        radio_id_bts = self._get_ru_id_from_bts(bts_id=bts_id, du_id=du_id, ru_id=ru_id)
        trigger_timestamp = self.trigger_or_cancel_fault_1904(interface, True)
        self.check_if_fault_appeared_on_ru_after_filtering_time(ru_fault_name, filtering_time, trigger_timestamp)
        self.alarms.wait_for_alarm_activation(bts_id=bts_id, du_id=du_id, fault_id=1904)
        self.verify_radio_unit_statuses(bts_id=bts_id, du_id=du_id, ru_id=radio_id_bts, operational_state="disabled",
                                        procedural_status=None, availability_status="failed",
                                        administrative_state="unlocked", usage_state="idle", power_state='AWAKE')

        if int(iteration_number) >= 6:
            self.reset_radio_unit(bts_id=bts_id, du_id=du_id, radio_unit_id=radio_id_bts)
        self.alarms.wait_for_alarm_deactivation(bts_id=bts_id, du_id=du_id, fault_id=1904)
        self.cells.wait_for_all_cells_to_be_onair(timeout=300)
        self.verify_radio_unit_statuses(bts_id=bts_id, du_id=du_id, ru_id=radio_id_bts, operational_state="enabled",
                                        procedural_status="configured", availability_status=None,
                                        administrative_state="unlocked", usage_state="active", power_state='AWAKE')

    @alarm_watcher
    def filtering_of_fault_1904(self, interface, sleep_time=15, filtering_time=30,
                                ru_fault_name="EFaultId_BBBus_SyncError",
                                bts_id=0, du_id=0, ru_id=0):
        """
         Triggers and cancels fault  1904 within filtering time, and checks if everything behave as expected.
         :param interface: interface names which connects DFE and Beamer on RU
         :param sleep_time: Time to wait to cancel fault, it should be smaller than filtering time. DefaultL 15
         :param filtering_time: Time in seconds, points out moment when Ru should spot the fault after it has
         been triggered. Default:30
         :param ru_fault_name: Fault name, that should NOT be visible on RU. Default: EFaultId_BBBus_SyncError
         :param ru_id: ID of radio unit related to Test Line configuration file. Default: 0
         :param bts_id: BTS id - related to Test Line configuration. Default: 0
         :param du_id:  DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]. Default: 0
         """
        self.ru = self.login_to_ru(ru_id=ru_id)
        self.cells.verify_all_cells_statuses(availability_status="online", operational_state="enabled",
                                             administrative_state="unlocked", blocking_state="unblocked",
                                             procedural_status="configured", usage_state=None,
                                             barring_status="unbarred")
        radio_id_bts = self._get_ru_id_from_bts(bts_id=bts_id, du_id=du_id, ru_id=ru_id)
        trigger_timestamp = self.trigger_or_cancel_fault_1904(interface, True)
        time.sleep(sleep_time)
        self.trigger_or_cancel_fault_1904(interface, False)
        try:
            self.check_if_fault_appeared_on_ru_after_filtering_time(ru_fault_name, filtering_time,
                                                                    trigger_timestamp)
        except FaultNotTriggered:
            pass
        else:
            raise
        self.cells.verify_all_cells_statuses(availability_status="online", operational_state="enabled",
                                             administrative_state="unlocked", blocking_state="unblocked",
                                             procedural_status="configured", usage_state=None,
                                             barring_status="unbarred")

        self.verify_radio_unit_statuses(bts_id=bts_id, du_id=du_id, ru_id=radio_id_bts, operational_state="enabled",
                                        procedural_status="configured", availability_status=None,
                                        administrative_state="unlocked", usage_state="active", power_state='AWAKE')
