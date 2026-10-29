"""
author/contact:   krzysztof.1.wrobel@nokia.com, I_MN_RAN_PZ1_WRO_7_SG_GMS <I_MN_RAN_PZ1_WRO_7_SG@internal.nsn.com>
Description:      functions to tracking params in csv
"""

import re
import csv


class L1L2TraceCsvFileParser(object):

    @staticmethod
    def parse_msgid_lines(filepath, pattern):
        """
        Function is returning parsed line from required MSGID with the columns
        SHERPA TTI, AIR TTI, RNTI, MSGID, TEXT
        Example:
            ParseCsvFilel1l2Trace.parse_msgid_lines("/home/ute/Desktop/micro__l1l2Trace.csv", "Dl PdcchSendReq")
        :param filepath: Specify file path plus full file name
        :param pattern: Specify pattern to find MSGID
        :return: List of lists with filtered columns as dicts
        """
        err_msg = "The csv file in not contains this column"
        with open(filepath) as csvfile:
            return [[{"SHERPA TTI": line.get("SHERPA TTI", err_msg)},
                     {"AIR TTI": line.get("AIR TTI", err_msg)},
                     {"RNTI": line.get("RNTI", err_msg)},
                     {"MSGID": line.get("MSGID", err_msg)},
                     {"TEXT": line.get("TEXT", err_msg)}]
                    for line in csv.DictReader(csvfile, delimiter=";") if re.search(pattern, line["MSGID"])]
