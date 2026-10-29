'''
author: Sebastian Mikos
contact: sebastian.mikos@nokia.com
'''
import re
from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import TSharkCommandAssembler, \
                                                                       remove_luashark_loading_from_output
from collections import Counter


class TShark_for_8531(TSharkCommandAssembler):
    def __init__(self, tshark_path="tshark"):
        self.parameters = []
        self.grep = ""
        self.parameters.extend([tshark_path])

    def with_filter(self, wireshark_filter):
        self.parameters.extend(["-Y", wireshark_filter])
        return self


def generated_pcap_data_for_enquiry_procedure(pcap_path):
    tshark = TShark_for_8531()
    output = tshark \
        .with_filter("ngap.UERadioCapabilityInfoIndication_element && nr-rrc.appliedFreqBandListFilter") \
        .with_pcap_file(pcap_file=pcap_path) \
        .inject_additional_parameters('-T fields -e nr-rrc.bandNR') \
        .build()
    pcap_data = []
    for line in output:
        if line != "\t\t":
            line = line.split("\t")
            pcap_data.append(line)
    return pcap_data


def generated_pcap_data_for_inter_gnb_handover(pcap_path):
    tshark = TShark_for_8531()
    output = tshark \
        .with_filter("xnap.HandoverRequest_element") \
        .with_pcap_file(pcap_file=pcap_path) \
        .inject_additional_parameters('-T fields -e xnap.NR-Cell-Identity') \
        .build()
    pcap_data = []
    for line in output:
        if line != "\t\t":
            line = line.split("\t")
            pcap_data.append(line)
    return pcap_data


def verify_ue_capability_enquiry_procedure_pcap(pcap_path):
    pcap_msgs = generated_pcap_data_for_enquiry_procedure(pcap_path)
    print("pcap_msgs: ", pcap_msgs[0])
    band = (pcap_msgs[0][0].split(","))
    return [True if '41' in band else False][0]


def verify_inter_gnb_handover_procedure_pcap(pcap_path):
    pcap_msgs = generated_pcap_data_for_inter_gnb_handover(pcap_path)
    print("pcap_msgs: ", pcap_msgs)
    return [False if '1' in [item for sublist in pcap_msgs for item in sublist] else True][0]
