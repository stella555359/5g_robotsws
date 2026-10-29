import logging

from moler.util.moler_test import MolerTest
from moler.device import DeviceFactory
from robot.libraries.BuiltIn import BuiltIn
from taf.hw.rf_attenuator import rf_attenuator as attenuator
from taf.ue.rpc.mtk.interface import mtk
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.ue.connections.device_aliases import ue_pc
import time
from taf.rfrl.bts.devices.generic_bts import login_logout_GUI
from taf.rfrl.bts.connections import device_aliases as connection_names
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.ue.custom_ues import AndroidUe

network_selecting_at_cmds = {"NR": ["AT+EFUN=0", "AT+ERAT=0", "AT+ERAT=15", "AT+E5GOPT=3", "AT+EFUN=1"],
                             "LTE": ["AT+EFUN=0", "AT+ERAT=0", "AT+ERAT=3", "AT+EFUN=1"],
                             "WCDMA": ["AT+EFUN=0", "AT+ERAT=0", "AT+ERAT=1", "AT+EFUN=1"],
                             "GSM": ["AT+EFUN=0", "AT+ERAT=0", "AT+ERAT=0", "AT+EFUN=1"]}
attach_at_commands = ["AT+EFUN=1"]
detach_at_commands = ["AT+EFUN=0"]

apn_config = {"5gkrk": {"starting_activity": "android.settings.DATA_ROAMING_SETTINGS",
                        "key_events_combination": [20, 20, 20, 20, 20, 20, 66, 20, 20, 20, 20,
                                                   20, 20, 20, 66, 61, 61, 66]},
              "5gkrk2": {"starting_activity": "android.settings.DATA_ROAMING_SETTINGS",
                         "key_events_combination": [20, 20, 20, 20, 20, 20, 66, 20, 20, 20, 20,
                                                    20, 20, 20, 66, 20, 61, 61, 66]},
              "5gsakrk": {"starting_activity": "android.settings.DATA_ROAMING_SETTINGS",
                          "key_events_combination": [20, 20, 20, 20, 20, 20, 66, 20, 20, 20, 20,
                                                     20, 20, 20, 66, 20, 20, 61, 61, 66]}}

tl = BuiltIn().get_variable_value('${tl}')
att = attenuator()
ue_sn = "lepin"
hostname = tl.ues[0].ssh_connection_details.addr
username = tl.ues[0].ssh_connection_details.username
password = tl.ues[0].ssh_connection_details.password
port = tl.ues[0].server_port
server_dir = tl.ues[0].server_dir
python_path = tl.ues[0].python_path
edb_file_path = tl.ues[0].edb_file_path


@MolerTest.raise_background_exceptions()
def set_cell_attenuation(attenuation_ports, values_in_db):
    """
    Set cell attenuation.

    :param list attenuation_ports: list of attenuator ports
    :param list values_in_db: attenuation values in db
    :return: None
    """
    att1 = att.setup_attenuator(attenuator=tl.attenuator[0], alias='att')
    for attenuation_port, value_in_db in zip(attenuation_ports, values_in_db):
        att.set_attenuation(port=attenuation_port, value=value_in_db, attenuator_device=att1)
        attenuation = att.read_attenuation(port=attenuation_port, attenuator_device=att1)
        if attenuation != value_in_db:
            MolerTest.error("Attenuation not changed")


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def reboot_mtk_ue(timeout=45, interval=5, ue_id=0):
    """
    Reboot mediatek UE.

    :param int timeout: timeout
    :param int interval: interval
    :param int ue_id: UE id in __init__.py
    :return: None
    """
    ue_pc_device = DeviceFactory.get_device(name=ue_pc.format(ue_id), initial_state="UNIX_REMOTE")
    ue_pc_device.get_cmd(cmd_name="run_script", cmd_params={'script_command': "adb reboot"})()
    _time = time.perf_counter() + timeout
    while _time > time.perf_counter():
        adb_devices_cmd = ue_pc_device.get_cmd(cmd_name="adb_devices")
        devices_dict = adb_devices_cmd()
        for ue_device in devices_dict["DEVICES"]:
            if ue_sn == ue_device:
                MolerTest.info("UE reboot successfully completed")
                MolerTest.sleep(15)
                return
        MolerTest.sleep(interval)
    MolerTest.error("UE reboot not completed within {} seconds".format(timeout))


@MolerTest.raise_background_exceptions()
def run_at_commands(at_commands):
    """
    Run AT commands on MTK UE.

    :param list at_commands: list of AT commands
    :return: None
    """
    mtk_device = mtk()
    mtk_device.configure(hostname=hostname, port=port, username=username, password=password, server_dir=server_dir,
                         python_path=python_path)
    mtk_device.setup()
    mtk_device.create_proxy()
    mtk_device.connect_device(edb_file_path=edb_file_path)
    for command in at_commands:
        mtk_device.send_at_command(command)
        MolerTest.sleep(5)
    mtk_device.disconnect_device()
    mtk_device.teardown()


@MolerTest.raise_background_exceptions()
def run_at_command(at_command):
    """
    Run AT commands on MTK UE.

    :param list at_commands: list of AT commands
    :return: None
    """
    mtk_device = mtk()
    mtk_device.configure(hostname=hostname, port=port, username=username, password=password, server_dir=server_dir,
                         python_path=python_path)
    mtk_device.setup()
    mtk_device.create_proxy()
    mtk_device.connect_device(edb_file_path=edb_file_path)
    cmd_ret = mtk_device.send_at_command(at_command)
    mtk_device.disconnect_device()
    mtk_device.teardown()
    return cmd_ret


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def prepare_ue_network_type(apn, rat, ue_id=0, airplane_mode_coordinates=None):
    """
    Select network and set apn on MTK UE.

    :param apn: APN name: "5gsakrk", "5gkrk", "5gkrk2"
    :param rat: RAT: "NR", "LTE", "WCDMA", "GSM"
    :return: None
    """
    android_ue = AndroidUe(ue_id=ue_id, airplane_mode_coordinates=airplane_mode_coordinates)
    for _ in range(5):
        set_ue_apn(apn)
        run_at_commands(network_selecting_at_cmds[rat])
        MolerTest.sleep(10)
        ue_ip = android_ue.get_ue_ip()
        if ue_ip:
            MolerTest.info("UE IP:", dump=ue_ip)
            return
        reboot_mtk_ue()
    MolerTest.error("UE_{} cannot get ip".format(ue_id), raise_exception=True)


def attach_mtk_ue():
    """
    Attach Mediatek UE.

    :return: None
    """
    run_at_commands(attach_at_commands)


def detach_mtk_ue():
    """
    Detach Mediatek UE.

    :return: None
    """
    run_at_commands(detach_at_commands)


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def set_ue_apn(apn_name, ue_id=0):
    """
    Set defined APN name on UE.

    :param string apn_name: APN name key in 'apn_config' dictionary
    :param int ue_id: UE id in __init__.py
    :return: None
    """
    ue_pc_device = DeviceFactory.get_device(name=ue_pc.format(ue_id), initial_state="UNIX_REMOTE")
    ue_serial_number = tl.ues[ue_id].serial_number
    start_activity_cmd = "adb -s {} shell 'am start -a {}'".format(ue_serial_number,
                                                                   apn_config[apn_name]["starting_activity"])
    stop_activity_cmd = "adb -s {} shell 'am force-stop {}'".format(ue_serial_number, "com.android.settings")
    time.sleep(5)
    ue_pc_device.get_cmd(cmd_name="run_script", cmd_params={'script_command': start_activity_cmd})()
    for key_event in apn_config[apn_name]["key_events_combination"]:
        time.sleep(0.4)
        key_event_cmd = "adb -s {} shell 'input keyevent {}'".format(ue_serial_number, key_event)
        ue_pc_device.get_cmd(cmd_name="run_script", cmd_params={'script_command': key_event_cmd})()
    ue_pc_device.get_cmd(cmd_name="run_script", cmd_params={'script_command': stop_activity_cmd})()


class SCFKeywords(GnbDuOperations):

    @login_logout_GUI
    def perform_parameter_recommissioning_and_check_report(self, dist, param, value, bts_id=0, du_id=0):
        """
        Perform parameter recommissioning and check report.

        :param dist: param dist name
        :param param: param name
        :param value: param value
        :param bts_id: BTS ID
        :param du_id: DU ID
        :return: None
        """
        gui_alias = self.gui_alias.format(bts_id, du_id)
        self.gui_coam.set_parameter_value(
            dist_name=self.adjust_dist_name(dist_name=dist, bts_id=bts_id, du_id=du_id),
            filter_param=param,
            new_value=value,
            sbts=gui_alias)
        self.gui_coam.validate_plan(sbts=gui_alias)
        logging.info("Plan Validated")
        self.gui_coam.activate_plan(sbts=gui_alias)
        logging.info("Plan Activated")
        GnbDuOperations().wait_for_site_to_be_onair()
        report_path = self.gui_coam.save_report(sbts=gui_alias)
        self.check_report(report_path=report_path, gnb_id=bts_id, du_id=du_id)

    @load_moler_configuration_from_tl()
    def check_report(self, report_path, gnb_id=0, du_id=0):
        """
        Check commissioning report.

        :param report_path: path to report
        :param gnb_id: GNB ID
        :param du_id: DU ID
        :return: None
        """
        vm = DeviceFactory.get_device(format(connection_names.ws_du.format(self.bts_type, gnb_id, du_id)))
        unzip_cmd = vm.get_cmd(cmd_name="unzip", cmd_params={'zip_file': report_path, 'options': '-o'})
        cat_cmd = vm.get_cmd(cmd_name="cat", cmd_params={'path': "report-data.txt", 'options': " | grep result"})
        unzip_cmd()
        results = cat_cmd()['LINES']
        if results[0].find("successfully") == -1 or results[1].find("successfully") == -1:
            raise Exception("Report check failed")
