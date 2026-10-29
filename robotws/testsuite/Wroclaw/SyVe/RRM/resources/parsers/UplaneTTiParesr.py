"""
author/contact:   krzysztof.1.wrobel@nokia.com, I_MN_RAN_PZ1_WRO_7_SG_GMS <I_MN_RAN_PZ1_WRO_7_SG@internal.nsn.com>
Description:      functions to tracking params in csv
"""

import re


class UplaneTTiParesr(object):

    def __init__(self, file_path):
        self._csv_file_path = file_path
        self.msg_id_report_data_list = []

    def read_file_tti_trace_csv(self, message_id, string_to_search):
        resp_pattern = self._choose_pattern_for_mimo_mode(message_id, string_to_search)
        with open(self._csv_file_path) as csvfile:
            self._convert_raw_csv_data_to_list_of_dicts(resp_pattern, message_id, csvfile)

    @staticmethod
    def _choose_pattern_for_mimo_mode(message_id, string_to_search):
        return re.compile(f"({message_id}).*({string_to_search})")

    def _convert_raw_csv_data_to_list_of_dicts(self, resp_pattern, message_id, csvfile):
        for line in csvfile.readlines():
            if re.search(resp_pattern, line):
                msg_report_data = line.lstrip(f"{message_id}:")
                msg_report_data_list = msg_report_data.split(",")
                key = msg_report_data_list[:len(msg_report_data_list) // 2]
                value = msg_report_data_list[len(msg_report_data_list) // 2:]
                self.msg_id_report_data_list.append(dict(zip(key, value)))
