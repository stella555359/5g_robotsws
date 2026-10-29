# ====================================================================================================
# This is a Python File, which helps to implement the Robot Keywords used in CB012121_verification.robot
# Team: 'i_mn_ran_rd_vrf_ulm_vt2'
# Email: 'i_mn_ran_rd_vrf_ulm_vt2@internal.nsn.com'
# Author: Juergen Richter
# ----------------------------------------------------------------------------------------------------[120 characters]

import lxml.etree as et
import re
from taf.analyzer.pdml import PdmlReader
from robot.libraries.BuiltIn import BuiltIn


def get_messages(file_name):
    rbi = BuiltIn()
    xnap = rbi.get_variable_value("${XNAP}")

    def timestamp(cu_record):
        timestamp = cu_record.xpath("nsetapx.timestamp_element")[0]
        seconds = timestamp.xpath("nsetapx.seconds/@show")[0]
        useconds = timestamp.xpath("nsetapx.useconds/@show")[0]
        return f"{seconds}.{useconds:0>6}"

    for log_entry in PdmlReader.from_file(
            file_path=file_name):
        packet = log_entry.packet
        if "nsetapx.CuRecord_element" in packet:
            for cu_record in packet.xml.xpath("//nsetapx.CuRecord_element"):
                if (handover_requests := cu_record.xpath(f".//{xnap}.HandoverRequest_element")):
                    message = {
                        'type': "handover_request",
                        'timestamp': timestamp(cu_record)}
                    if (candidate_cell_info_lists := handover_requests[0].xpath(".//nr-rrc.candidateCellInfoList")):
                        if (serving_pcis := candidate_cell_info_lists[0].xpath(
                                ".//nr-rrc.measResultServingCell_element/nr-rrc.physCellId/@show")):
                            message['serving_pcis'] = serving_pcis
                        if (neighbor_pcis := candidate_cell_info_lists[0].xpath(
                                ".//nr-rrc.measResultNeighCellListNR//nr-rrc.physCellId/@show")):
                            message['neighbor_pcis'] = neighbor_pcis
                    yield message
                elif (ue_meas_records := cu_record.xpath(".//nsetapx.ueMeasRecord")):
                    ue_meas_record = ue_meas_records[0]
                    message = {
                        'type': 'ue_meas',
                        'timestamp': timestamp(cu_record)}
                    if (trigger_types := ue_meas_record.xpath(".//nsetapx.triggerType/@showname")):
                        trigger_type = re.search(r"triggerType: (\w+)", trigger_types[0]).groups(1)[0]
                        message['trigger_type'] = trigger_type
                    if (serving_pcis := ue_meas_record.xpath(
                            ".//nsetapx.measResultServingMos//nsetapx.pci/@show")):
                        message['serving_pcis'] = serving_pcis
                    if (neighbor_pcis := ue_meas_record.xpath(
                            ".//nsetapx.measResultNeighCellsNR//nsetapx.pci/@show")):
                        message['neighbor_pcis'] = neighbor_pcis
                    yield message


def timediff_between_a3_and_handover_should_be_greater_than_max_value(file_name, max_value=10000):
    messages = list(get_messages(file_name))
    handover_timestamp = float(
        next(
            message
            for message in messages
            if message['type'] == 'handover_request')['timestamp'])
    a3_timestamp = float(
        next(
            message
            for message in messages
            if message['type'] == 'ue_meas'
            and message['trigger_type'] == 'a3')['timestamp'])
    assert handover_timestamp - a3_timestamp > max_value / 1000, (
           f"handover_timestamp: {handover_timestamp!r}, "
           f"a3_timestamp: {a3_timestamp!r}, "
           f"max_value: {max_value!r}")


if __name__ == '__main__':
    for message in get_messages(file_name):
        print(message)
    print(f"time difference: first A3 event & first handover: S{get_timediff_between_a3_and_handover(file_name):.2f}")
