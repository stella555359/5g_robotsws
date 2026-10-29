from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import TSharkCommandAssembler, \
                                                                       remove_luashark_loading_from_output
from testsuite.Wroclaw.RRM.VRF_WRO2_T05.classical.regression.common_keywords.global_var import *
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.robot_globals import robot_globals
import os
import json
from robot.libraries.BuiltIn import BuiltIn


class TShark(TSharkCommandAssembler):
    def __init__(self, tshark_path="tshark"):
        self.parameters = []
        self.grep = ""
        self.parameters.extend([tshark_path])

    def with_filter(self, wireshark_filter):
        self.parameters.extend(["-Y", wireshark_filter])
        return self


def generated_pcap_data_for_paging(pcap_path):
    is_f1_paging = False
    is_ng_paging = False
    tshark = TShark()
    output = tshark \
        .with_filter("ngap || nokiaf1ap.Paging_element") \
        .with_pcap_file(pcap_file=pcap_path) \
        .inject_additional_parameters('-T fields -e nokiaf1ap.Paging_element '
                                      '-e ngap.Paging_element') \
        .build()
    pcap_data = []
    for line in output:
        if line != "\t\t":
            line = line.split("\t")
            pcap_data.append(line)
    for msgs in pcap_data:
        if msgs[0].strip() == '1':
            is_f1_paging = True
        if msgs[1].strip() == '1':
            is_ng_paging = True
    print("is_f1_paging: ", is_f1_paging)
    print("is_ng_paging: ", is_ng_paging)
    return is_f1_paging and is_ng_paging


def read_json_tti(tti_collector_name='TTI', decoded_output_file=None):
    outputdir = robot_globals.outputdir()
    testname = robot_globals.testname()
    decoded_output_file = os.path.join(tti_collector_name, testname) if decoded_output_file is None \
        else os.path.join(tti_collector_name, '{}_{}'.format(testname, decoded_output_file))
    file_json = os.path.join(outputdir, decoded_output_file + '.json')
    BuiltIn().log("file_json: {}".format(file_json))
    with open(file_json, 'r') as json_content:
        content = json.load(json_content)
    return content


def check_bwpId_powersaving_tti():
    tti_content = read_json_tti()
    bwpId_1, bwpId_2 = [], []
    for tti_event in tti_content['events']:
        if 'psBwpSwitchData' in tti_event:
            body = tti_event['psBwpSwitchData']['body']
            bwpId_1.append(body['bwpId']) if body['bwpId'] == 1 else None
            bwpId_2.append(body['bwpId']) if body['bwpId'] == 2 else None
    BuiltIn().log("Bwp1 len: {}, Bwp2 len: {}".format(len(bwpId_1), len(bwpId_2)))
    return len(bwpId_1) > 5 and len(bwpId_2) > 5
