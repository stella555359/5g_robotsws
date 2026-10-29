from moler.util.moler_test import MolerTest
from moler.device import DeviceFactory
from taf.rfrl.utilities.transfer_files import download_files
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.utilities.robot.general import get_builtin_value, get_builtin_instance
from taf.sbts.oam.coam.admin import admin
import os
import re


class AmfReleaseKeywords(object):
    """Class for UE AMF release validation"""

    def __init__(self):
        self.syslog_validator = None
        self.gnb_sniffer = None
        self.pcap_validator = None
        self.moler_devices_created = False
        self.gnb_sniffer_cmd = None

    @load_moler_configuration_from_tl()
    def _create_moler_devices(self):
        if not self.moler_devices_created:
            self.syslog_validator = \
                DeviceFactory.get_cloned_device("GNB0", "SYSLOG_validator", initial_state="PROXY_PC")
            self.gnb_sniffer = DeviceFactory.get_cloned_device("GNB0", "GNB_sniffer", initial_state="FCT")
            self.pcap_validator = DeviceFactory.get_cloned_device("GNB0", "PCAP_validator", initial_state="PROXY_PC")
            self.moler_devices_created = True

    def validate_ue_context_release_in_syslog(self):
        """
        Validate UE context release in syslog.

        :return: None
        """
        connection = admin().connect_to()
        bts_info = connection.get_bts_info()
        scf_parsed = self._extract_configuration_from_scf(
            connection.get_scf(export_type="configurationAndRuntimeObjects").split("\n"))
        connection.disconnect()
        cell_ids = [cell_info["globalCellId"] for cell_info in bts_info["cells"]["nr"]]
        bts_id = bts_info["mrbtsID"]
        for cell_id in cell_ids:
            nr_cell_id = scf_parsed["MRBTS-{}/NRBTS-{}/NRCELL-{}".format(bts_id, bts_id, cell_id)]["nrCellIdentity"]
            validation_patter = r".*UeContextReleaseDone.*TaskDone.*cellId:\s{}\n".format(nr_cell_id)
            self._check_if_string_is_present_in_syslog(pattern=validation_patter)

    def start_sniffer(self):
        """
        Start sctp traffic sniffer gNB.

        :return: None
        """
        self._create_moler_devices()
        self.gnb_sniffer.goto_state("FCT")
        self.gnb_sniffer_cmd = self.gnb_sniffer.get_cmd(cmd_name="tcpdump", cmd_params={
            "options": "-i any -w {} sctp -v".format("/tmp/xn.pcap")})
        self.gnb_sniffer_cmd.start(timeout=600)

    def stop_sniffer_and_collect_pcap(self):
        """
        Stop sctp traffic sniffer gNB and collect results.

        :return: None
        """
        self._create_moler_devices()
        self.gnb_sniffer.goto_state("FCT")
        self.gnb_sniffer_cmd.break_cmd()
        download_files(local_dir="/tmp/", remote_file="xn.pcap", device_name="GNB_sniffer", remote_dir="/tmp/",
                       from_state="FCT", timeout=100, remove_source_file=True)
        self.gnb_sniffer.goto_state("FCT")

    def validate_ngap_ue_context_release_procedure(self):
        """
        Validate NGAP UEContextRelease procedure in pcap file.

        :return: None
        """
        self._create_moler_devices()
        self.pcap_validator.get_cmd(cmd_name="tshark", cmd_params={
            "options": """ -r {} -Y 'ngap.UEContextReleaseComplete_element||ngap.UEContextReleaseCommand_element \
            ||f1ap.UEContextReleaseComplete_element||f1ap.UEContextReleaseCommand_element||\
            e1ap.BearerContextReleaseComplete_element||e1ap.BearerContextReleaseCommand_element' > result"""
                                    .format("/tmp/xn.pcap")})(timeout=100)
        self._validate_ngap_release_procedure()

    def validate_f1ap_ue_context_release_procedure(self):
        """
        Validate F1AP UEContextRelease procedure in pcap file.

        :return: None
        """
        self._create_moler_devices()
        self.pcap_validator.get_cmd(cmd_name="tshark", cmd_params={
            "options": """-r {} -Y 'f1ap.UEContextReleaseComplete_element||f1ap.UEContextReleaseCommand_element' -T\
             fields -e f1ap.radioNetwork -e f1ap.UEContextReleaseComplete_element > result""".
                                    format("/tmp/xn.pcap")})(timeout=100)
        self._validate_f1ap_release_procedure()

    def validate_e1ap_ue_context_release_procedure(self):
        """
        Validate E1AP UEContextRelease procedure in pcap file.

        :return: None
        """
        self._create_moler_devices()
        self.pcap_validator.get_cmd(cmd_name="tshark", cmd_params={
            "options": """-r {} -Y \
            'e1ap.BearerContextReleaseComplete_element||e1ap.BearerContextReleaseCommand_element' -T fields -e \
            _ws.col.Info -e e1ap.radioNetwork > result""".format("/tmp/xn.pcap")})(timeout=100)
        self._validate_e1ap_release_procedure()

    def _check_if_string_is_present_in_syslog(self, pattern):
        self._create_moler_devices()
        syslog_path = os.path.join(get_builtin_value('OUTPUT_DIR'), "moler", "moler.GNB0_DU0_SYSLOG.raw.log")
        with open(syslog_path) as f:
            syslog_content = f.readlines()
        for line_id, line_content in enumerate(syslog_content):
            if re.match(pattern, line_content):
                MolerTest.info("Pattern -> {} found in syslog (line -> {})".format(pattern, line_id))
                break
        else:
            MolerTest.error("Pattern -> {} NOT found in syslog".format(pattern), raise_exception=True)

    def _validate_ngap_release_procedure(self):
        with open('/home/ute/result') as f:
            result_file_content = f.readlines()
            self._validate_result_file(result_file_content)
        release_procedure_flow = []
        for line in result_file_content:
            match = re.search(r".*(?P<PROTOCOL>(NGAP|F1AP|E1AP|F1AP\/NR RRC))\s+\d+\s+(?P<MESSAGE_NAME>.*)", line)
            release_procedure_flow.append(
                {"message_name": match.group("MESSAGE_NAME"), "message_protocol": match.group("PROTOCOL")})
        ngap_start = release_procedure_flow[0] == {"message_name": "UEContextReleaseCommand",
                                                   "message_protocol": "NGAP"}
        ngap_end = release_procedure_flow[-1] == {"message_name": "UEContextReleaseComplete",
                                                  "message_protocol": "NGAP"}
        if ngap_start and ngap_end:
            MolerTest.info("NGAP procedure flow -> OK")
        else:
            MolerTest.error("NGAP procedure flow -> NOT OK", raise_exception=True)

    def _validate_f1ap_release_procedure(self):
        with open('/home/ute/result') as f:
            result_file_content = f.readlines()
            self._validate_result_file(result_file_content)
        if "10" in result_file_content[0] and "10" in result_file_content[1]:
            MolerTest.info("F1AP release cause -> OK")
        else:
            MolerTest.error("F1AP release cause -> NOT OK", raise_exception=True)
        if "1" in result_file_content[-2] and "1" in result_file_content[-1]:
            MolerTest.info("F1AP UEContextReleaseComplete -> OK")
        else:
            MolerTest.error("F1AP UEContextReleaseComplete -> NOT OK", raise_exception=True)

    def _validate_e1ap_release_procedure(self):
        with open('/home/ute/result') as f:
            result_file_content = f.readlines()
            self._validate_result_file(result_file_content)
        if "BearerContextReleaseCommand" in result_file_content[0] and "BearerContextReleaseComplete" in \
                result_file_content[1]:
            MolerTest.info("E1AP messages flow -> OK")
        else:
            MolerTest.error("E1AP messages flow -> NOT OK", raise_exception=True)

        if "20" in result_file_content[0]:
            MolerTest.info("E1AP BearerContextReleaseCommand cause = normal-release'")
        else:
            MolerTest.error("E1AP BearerContextReleaseCommand cause != normal-release'", raise_exception=True)

    @staticmethod
    def _validate_result_file(file_lines):
        if len(file_lines) >= 1:
            MolerTest.info("Packets details extracted with success.")
        else:
            MolerTest.error("Cannot extract packets details from pcap file. Requested fields don't exist or "
                            "pcap file is damaged", raise_exception=True)

    @staticmethod
    def _extract_configuration_from_scf(scf_content):
        parsed_scf_in_dict = {}
        object_regex = r"\s+<managedObject\s+class=.*distName=(?P<DIST_NAME>.*)\s+version.*"
        param_regex = r"\s+<p\s+name=(?P<PARAM_NAME>.*)>(?P<VALUE>.*)<\/p>"
        list_regex = r"\s+<list\s+name=(?P<LIST_NAME>.*)>"
        actual_dist_name = ""
        actual_list_name = ""
        for line in scf_content:
            object_matched = re.search(object_regex, line)
            list_matched = re.search(list_regex, line)
            param_matched = re.search(param_regex, line)
            if object_matched:
                key_name = object_matched.group("DIST_NAME").replace('"', "")
                actual_dist_name = key_name
                actual_list_name = None
                if key_name not in parsed_scf_in_dict.keys():
                    parsed_scf_in_dict.update({key_name: {}})
            elif list_matched:
                list_name = list_matched.group("LIST_NAME").replace('"', "")
                actual_list_name = list_name
                parsed_scf_in_dict[actual_dist_name].update({actual_list_name: {}})
            elif param_matched and actual_list_name:
                param_name = param_matched.group("PARAM_NAME").replace('"', "")
                param_value = param_matched.group("VALUE").replace('"', "")
                parsed_scf_in_dict[actual_dist_name][actual_list_name].update({param_name: param_value})
            elif param_matched:
                param_name = param_matched.group("PARAM_NAME").replace('"', "")
                param_value = param_matched.group("VALUE").replace('"', "")
                parsed_scf_in_dict[actual_dist_name].update({param_name: param_value})
            else:
                continue
        return parsed_scf_in_dict
