import testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_wts as wts
import testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_gnb as gnb
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.SAS_ET.CB008746.resources.variables import BH_ETH3_IP_ADDR, BH_ETH4_IP_ADDR
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.slice_scheduling.\
    SliceValuesExtractor import SliceValuesExtractor
import testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.slice_scheduling.logs as logs
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities import logger_console, \
    logger_info
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem as Os
from time import sleep
import os
import re

ONLY_ONE_MNC_MCC = 0
TIME_WTS_SETUP = 30
CFG_PATH_SLICES = "testsuite/Wroclaw/RRM/VRF_WRO1_T04/SAS_ET/CB010519/resources/slices_wts.cfg"


class CB010519:

    def __init__(self):
        self.pcap_output_tsc = None
        self.tshark_output = None
        self.admin_mcc = None
        self.admin_mnc = None
        self.admin_mnc_length = None
        self.admin_amf_list = None
        self.admin_amf_number = None
        self.slice_info_pcap = None

    def test_setup_prepare(self):
        wts.ensure_eth3_bh_is_ok(BH_ETH3_IP_ADDR)
        wts.ensure_eth4_bh_is_ok(BH_ETH4_IP_ADDR)
        logs.start_syslog_capture(output_dir=BuiltIn().get_variable_value('${OUTPUT_DIR}'))
        self.kill_wts_if_running()
        self.start_wts()
        sleep(TIME_WTS_SETUP)
        wts.run_egate_cmd("enb_x2_link_up enb=1 target=2")
        sleep(TIME_WTS_SETUP)
        gnb.wait_till_admin_is_online()
        self.update_act_ngc_flex_sa_mode_if_needed()

    def test_teardown_prepare(self):
        self.stop_wts_and_clear()
        logs.stop_syslog_capture()
        if BuiltIn().get_variable_value("${TEST_STATUS}") == "FAIL":
            gnb.collect_gnb_snapshot()

    @staticmethod
    def start_wts(wts_dir_path='/opt/wts/latest', edaemon_port='22222', egate_port='20000'):
        wts_config_filename = os.path.join(os.getcwd(), CFG_PATH_SLICES)
        wts.start_wts(wts_config_filename, wts_dir_path, edaemon_port, egate_port)

    @staticmethod
    def stop_wts_and_clear(subdirectory="wts", unzip=None):
        wts.stop_wts_and_clear(subdirectory, unzip)

    @staticmethod
    def kill_wts_if_running():
        wts.ensure_wts_is_not_running()

    @staticmethod
    def block_ng_link():
        gnb.amf_block_ng_link()

    @staticmethod
    def unblock_ng_link():
        gnb.amf_unblock_ng_link()

    @staticmethod
    def start_ip_capture():
        gnb.start_ip_capture_file()

    def stop_ip_capture_and_download(self):
        gnb.stop_ip_capture_file()
        self._generate_ip_capture_file()
        self._download_ip_capture_file()

    @staticmethod
    def update_act_ngc_flex_sa_mode_if_needed():
        for mrbts_info in gnb.get_managed_objects_parameters():
            if not mrbts_info['parameters']['actNgcFlexSaMode']:
                logger_console("Updating actNgcFlexSaMode to true")
                gnb.update_parameter_value(parameter="actNgcFlexSaMode", value="true")

    def check_admin_output_and_pcap_output(self):
        self._get_slices_information_amf_from_bts_admin()
        self._get_values_from_pcap_slices()
        self._check_request_and_response_included_in_pcap()
        self._check_mnc_mcc()
        self._check_slices_number()
        self._check_slice_support_list()
        self._check_the_same_number_of_supported_slices_in_pcap_and_admin()

    def _convert_pcap_file_with_filter_using_mcshark(self, pcap_file, tshark_filter):
        tshark_cmd = self._get_tshark_with_mcshark_cmd(pcap_file, tshark_filter)
        logger_info("Converting pcap using mcshark with cmd: {}".format(tshark_cmd))
        self.tshark_output = [str(line).strip() for line in Os().run(tshark_cmd).splitlines()]

    @staticmethod
    def _get_tshark_with_mcshark_cmd(pcap_file, tshark_filter):
        return "tshark -V -r {pcap} -Y {t_filter}".format(pcap=pcap_file, t_filter=tshark_filter)

    @staticmethod
    def _generate_ip_capture_file():
        gnb.generate_ip_capture_file()

    def _download_ip_capture_file(self):
        output_tsc = gnb.download_ip_capture_file()
        self.pcap_output_tsc = output_tsc

    def _get_slices_information_amf_from_bts_admin(self):
        amf_info = gnb.get_parameter_by_distname_parameters()
        self.admin_mcc = amf_info[ONLY_ONE_MNC_MCC]['parameters']['mcc']
        self.admin_mnc = amf_info[ONLY_ONE_MNC_MCC]['parameters']['mnc']
        self.admin_mnc_length = amf_info[ONLY_ONE_MNC_MCC]['parameters']['mncLength']
        self.admin_amf_list = amf_info[ONLY_ONE_MNC_MCC]['parameters']['snssaiAMFList']
        self.admin_amf_number = amf_info[ONLY_ONE_MNC_MCC]['parameters']['snssaiAMFNumber']

    def _get_values_from_pcap_slices(self):
        self._convert_pcap_file_with_filter_using_mcshark(self.pcap_output_tsc, 'ngap')
        slice_extractor = SliceValuesExtractor(self.tshark_output)
        slice_extractor.get_values_from_pcap_slices()
        self.slice_info_pcap = slice_extractor.plmnidentities

    def _check_mnc_mcc(self):
        pcap_length = str(len(re.search(r"\((\d+)\)", self.slice_info_pcap[ONLY_ONE_MNC_MCC].mnc).group(1)))
        assert str(self.admin_mnc_length) == pcap_length, f"Admin length: {self.admin_mnc_length} " \
                                                          f"is not equal pcap length: {pcap_length}"
        assert str(self.admin_mcc) in self.slice_info_pcap[ONLY_ONE_MNC_MCC].mcc, \
            f"MCC from Admin is not equal to MCC from pcap." \
            f" MCC from Admin: {self.admin_mcc}, MCC from" \
            f" pcap: {self.slice_info_pcap[ONLY_ONE_MNC_MCC].mcc}"
        assert str(self.admin_mnc) in self.slice_info_pcap[ONLY_ONE_MNC_MCC].mnc, \
            f"MNC from Admin is not equal to MNC from pcap. " \
            f"MNC from Admin: {self.admin_mnc}, MNC from" \
            f" pcap: {self.slice_info_pcap[ONLY_ONE_MNC_MCC].mnc}"

    def _check_slices_number(self):
        pcap_amf_nr = len(self.slice_info_pcap[ONLY_ONE_MNC_MCC].sliceSupportList) + \
            int(self.slice_info_pcap[ONLY_ONE_MNC_MCC].ExtendedSliceSupportList)
        assert pcap_amf_nr == int(self.admin_amf_number), f"AMF number from Admin is not equal to AMF number from " \
                                                          f"pcap. AMF nr admin: {self.admin_amf_number}, " \
                                                          f"AMF nr pcap: {pcap_amf_nr}"

    def _check_slice_support_list(self):
        found_slices = []
        not_found_slices = []
        for _slice_pcap in self.slice_info_pcap[ONLY_ONE_MNC_MCC].sliceSupportList:
            if {'sd': _slice_pcap.sd, 'sst': _slice_pcap.sst} in self.admin_amf_list:
                found_slices.append(_slice_pcap)
                continue
            else:
                not_found_slices.append(_slice_pcap)
        assert not not_found_slices, f"Slice from pcap is not equal to slice from Admin." \
                                     f" Missing slices from pcap {len(not_found_slices)}, first missing slice:" \
                                     f" {not_found_slices[:3]}"
        logger_info(f"Found all slices from pcap in Admin. Found slices: {len(found_slices)}")

    def _check_request_and_response_included_in_pcap(self):
        assert "NGSetupRequest" in self.tshark_output, "Missing NGSetupRequest"
        assert "NGSetupResponse" in self.tshark_output, "Missing NGSetupResponse"

    def _check_the_same_number_of_supported_slices_in_pcap_and_admin(self):
        slice_nr = len(self.slice_info_pcap[ONLY_ONE_MNC_MCC].sliceSupportList)
        assert slice_nr == int(len(self.admin_amf_list)), \
            f"Slices number from pcap {slice_nr} is not equal to number of slices from admin" \
            f" {len(self.admin_amf_list)}"
