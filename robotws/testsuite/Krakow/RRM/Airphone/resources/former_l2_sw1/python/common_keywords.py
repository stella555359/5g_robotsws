from ta_egate_cmd_parser import ta_egate_cmd_parser
from robot.libraries.BuiltIn import BuiltIn
from ta_messaging import ta_messaging
from ta_messaging.message_sources.message_sources_tshark_based import configure_iphy_interfaces
from ta_messaging.message_sources.message_sources_tshark_based import restore_default_iphy_interfaces
from taf.ul.ue.sim.env_setup import env_setup
from ta5g_testline_management import ta5g_testline_management
from ta5g_pm_counters import ta5g_pm_counters
from taf.sw.reporting_portal import reporting_portal
from time import sleep
from testsuite.Krakow.RRM.Airphone.resources.Python.file_management import copy_files_from_local_to_local
import ute_wtssim
import utils


class common_keywords:
    def __init__(self):
        self.ue_manager = UeManager()
        self.env_configurator = EnvConfigurator()
        self.counter_manager = CounterManager()

    def configure_env(self, egate_setup=None, scfc=None, ap_xml=None, rad_params=None):
        """
        Configures test environment
        """
        self.env_configurator.configure_env(egate_setup, scfc, ap_xml, rad_params)

    def create_aliases_for_ues(self):
        """
        Function that creates abstract identification of UE (alias)
        """
        self.ue_manager.create_aliases_for_ues()

    def enable_ue_capture_on_simulated_enb(self, enable=True):
        """
        Enable expectations in ta_messaging for AirPhone UEs RRC flow
        """
        self.ue_manager.enable_ue_capture_on_simulated_enb(enable)

    def get_ues_deployment(self, ues=None):
        """
        Function that creates dictionary key=UE_ID:value=deployment
        :return: ues_info (dict) eg. {'1': 'SA', '2': 'SA', '11': 'NSA', '12': 'NSA'}
        """
        return self.ue_manager.get_ues_deployment(ues)

    def wait_for_next_pm_interval_and_get_counters(self):
        """
        Function that wait for next countyer interval and collect last pm file
        """
        return self.counter_manager.wait_for_next_pm_interval_and_get_counters()

    def get_counters_value_and_report_to_rp(self, counters, localmoid, filepath, id=1):
        """
        Function that report pm counters value to RP
        """
        return self.counter_manager.get_counters_value_and_report_to_rp(counters, localmoid, filepath, id=1)

    def copy_iphy_packet_lua(self):
        packet_iphy_file = "/home/ute/MN/UTE/robotws/testsuite/Krakow/RRM/Airphone/resources/packet_iphy.lua"
        local_packet_iphy_destination = "/home/ute/.local/lib/wireshark/plugins/"
        copy_files_from_local_to_local(packet_iphy_file, local_packet_iphy_destination)


class EnvConfigurator:
    def __init__(self):
        self.env_setup = env_setup()
        self.testline_management = ta5g_testline_management()
        self.basic_egate_config = '/opt/wts/latest/basic_setup.cfg'

    def configure_env(self, egate_setup=None, scfc=None, ap_xml=None, rad_params=None):
        """
        Configures test environment
        """
        if scfc or rad_params:
            self.env_setup.add_gnb_configuration(scfc=scfc, rad_params=rad_params)
        if ap_xml:
            self.env_setup.add_simulator(sim_type='airphone', config=ap_xml)
        if egate_setup:
            self.env_setup.add_5gc(egate_setup)
        else:
            self.env_setup.add_5gc(self.basic_egate_config)
        self.env_setup.configure_environment()


class UeManager:
    @utils.skip_if_dryrun
    def __init__(self):
        self.egate_parser = ta_egate_cmd_parser()
        self.ta_messaging = BuiltIn().get_library_instance('ta_messaging')
        self.wtssim_instance = ute_wtssim.ute_wtssim()
        self.wtssim_instance.setup_egate(egate_port=20000)

    def create_aliases_for_ues(self):
        """
        Function that creates abstract identification of UE (alias)
        """
        self.ta_messaging.create_ues_alias(alias='UE', id_type='wts_5g')

    @staticmethod
    def enable_ue_capture_on_simulated_enb(enable=True):
        """
        Enable expectations in ta_messaging for AirPhone UEs RRC flow
        +------------------+-------+------------+------------+
        |     Example                                        |
        +==================+=======+============+============+
        | Enable UE Capture On Simulated Enb  enable=${True} |
        | Create UEs alias  alias=UE  id_type=wts            |
        | Expect Message Flow                                |
        | ...  UE_1:RRC_RRCConnectionReconfiguration         |
        | ...  alias=your_flow_alias                         |
        | ...  overall_timeout=30                            |
        +------------------+-------+------------+------------+
        :param enable:
        :return:
        """
        if enable:
            configure_iphy_interfaces(['any'])
        else:
            restore_default_iphy_interfaces()

    def get_ues_deployment(self, ues=None):
        """
        Function that creates dictionary key=UE_ID:value=deployment
        :return: ues_info (dict) eg. {'1': 'SA', '2': 'SA', '11': 'NSA', '12': 'NSA'}
        """
        deployment_mapping = {'enb': 'NSA', 'gnb': 'SA'}
        ues_deployment = {}
        if ues:
            selected_ues = self._get_ues_list(ues)
            for ue in selected_ues:
                output = self.get_bts_type(self.get_bts_id_for_ue(ue))
                sleep(0.5)
                ues_deployment[ue] = deployment_mapping[output.lower()]
        else:
            all_ue = self.get_all_ues()
            for ue in all_ue:
                output = self.get_bts_type(self.get_bts_id_for_ue(ue))
                sleep(0.5)
                ues_deployment[ue] = deployment_mapping[output.lower()]
        return ues_deployment

    @staticmethod
    def _get_ues_list(ues):
        """
        Function that create list of ues from given string eg '1,2,3,4,5'
        :param ues:
        :return: all_ue (list) eg. ['1','2','3','4','5']
        """
        return [ue for ue in ues.replace(' ', '').split(',')]

    @staticmethod
    def _are_ues_configured(ues, all_ue):
        for ue in ues:
            if ue not in all_ue:
                return False
        return True

    def get_all_ues(self):
        """
        Function that gets all configured UEs
        :return: output (list)
        """
        sleep(0.5)
        try:
            cmd = self.egate_parser.get_command('ue_disp')
            cmd_inst = cmd()
            output = list(cmd_inst.execute_and_parse().keys())
        except ValueError:
            output = self.wtssim_instance.execute_egate_command_and_wait_for_data(cmd='ue_disp')
            output = [output.split()[0].split('-')[-1]]
        sleep(0.5)
        return output

    def get_bts_id_for_ue(self, ue):
        """
        Function that gets bts id for specific ue
        :param ue: UE id
        :return: output (int)
        """
        sleep(0.5)
        cmd = self.egate_parser.get_command('ue_disp')
        cmd_inst = cmd(id=ue)
        sleep(0.5)
        try:
            output = cmd_inst.execute_and_parse()
        except Exception as e:
            output = self.wtssim_instance.execute_egate_command_and_wait_for_data(cmd=f'ue_disp id={ue}')
            lines = output.splitlines()
            for line in lines:
                if "enb" in line:
                    enb_value = line.split()[-1]
                    return enb_value
        sleep(0.5)

        return output['enb']['Value']

    def get_bts_type(self, bts_id):
        """
        Function that gets bts type for specific id
        :param bts_id: BTS id
        :return: output (str) eg. ENB or GNB
        """
        cmd = self.egate_parser.get_command('enb_disp')
        cmd_inst = cmd.without_id()
        output = cmd_inst.execute_and_parse()

        return output[str(bts_id)]['RAN Type']


class CounterManager:
    def __init__(self):
        self.pm_counters = ta5g_pm_counters()
        self.ute_reporting_portal = reporting_portal()

    def wait_for_next_pm_interval_and_get_counters(self):
        """
        wait_for_next_pm_interval_and_get_counters - lets to collect pm counters from latest pm interval
        +------------------+-------+------------+------------+------------+
        |     Example                                                     |
        +==================+=======+============+============+============+
        | ${pm_counters}=  Wait for next pm interval and get counters     |
        +------------------+-------+------------+------------+------------+

        :return:  file with last pm counters
        """
        self.pm_counters.wait_for_next_full_pm_interval()
        pm_counters_file = self.pm_counters.get_latest_unpacked_full_pm_counters_file()
        return pm_counters_file

    def get_counters_value_and_report_to_rp(self, counters, localmoid, filepath, id=1):
        """
        Function to report counters and their values to RP after whole test passed execution
        :param: counters - counter list, can be as string split by ", " or list of string, "-" to use range
                localmoid - object from which counters should be collected for example NRBTS-1 or NRCELL-1
                filepath - path to file with counters collected by wait_for_next_pm_interval_and_get_counters
                id - for specific counters group, for example different profile under NRCELL
        """
        if isinstance(counters, str):
            counters = self.parse_string_to_list_of_counters(counters)

        for counter in counters:

            if not self.pm_counters.get_pm_counter_value(counter, localmoid, filepath):
                counter_value = 0
            else:
                counter_value = self.pm_counters.get_pm_counter_value(counter, localmoid, filepath)[id-1]
            BuiltIn().run_keyword("report_pm_counter", counter, counter_value, "Passed")

    def parse_string_to_list_of_counters(self, counters):
        """
        Function to parse string to list of counters
        :param: counters - counter list, can be as string split by ",", "-" to use range
        :return: list eg.${counters}=M55308C00071-M55308C00073 returns ['M55308C00071', 'M55308C00072', 'M55308C00073']
        """
        counters = counters.replace(" ", "").split(',')
        for counter in counters:
            if '-' in counter:
                index = counters.index(counter)
                first, last = counter.split('-')
                header = first[:-4]
                first, last = int(first[-4:]), int(last[-4:])
                del counters[index]
                for rest_of_counter_name in range(last, first - 1, -1):
                    counters.insert(index, header + str(rest_of_counter_name).zfill(4))
        return counters
