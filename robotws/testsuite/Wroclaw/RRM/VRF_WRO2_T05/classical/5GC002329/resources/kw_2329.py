'''
author: Sebastian Mikos
contact: sebastian.mikos@nokia.com
'''

from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import TSharkCommandAssembler, \
                                                                       remove_luashark_loading_from_output
from collections import Counter
from testsuite.Wroclaw.RRM.VRF_WRO2_T05.classical.regression.common_keywords.global_var import *


class TShark_for_2329(TSharkCommandAssembler):
    def __init__(self, tshark_path="tshark"):
        self.parameters = []
        self.grep = ""
        self.parameters.extend([tshark_path])

    def with_filter(self, wireshark_filter):
        self.parameters.extend(["-Y", wireshark_filter])
        return self


def generated_pcap_data_for_VoNR(pcap_path):
    tshark = TShark_for_2329()
    output = tshark \
        .with_filter("ngap") \
        .with_pcap_file(pcap_file=pcap_path) \
        .inject_additional_parameters('-T fields -e ngap.fiveQI') \
        .build()
    pcap_data = []
    for line in output:
        if line != "\t\t":
            line = line.split("\t")
            pcap_data.append(line)
    return pcap_data


def check_vonr_call_success(pcap_path):
    '''
    :param pcap_path: path to pcap file
    :return: True if ngap.fiveQI message value is equal to 1, else return False
    '''
    pcap_msgs = generated_pcap_data_for_VoNR(pcap_path)
    return [True if '1' in [item for sublist in pcap_msgs for item in sublist] else False][0]


def check_vonr_release_success(pcap_path):
    pcap_msgs = generated_pcap_data_for_VoNR(pcap_path)
    return [False if '1' in [item for sublist in pcap_msgs for item in sublist] else True][0]
