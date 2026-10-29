# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Chen Jun
:contact: jun.8.chen@nokia-sbell.com
"""

from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
SOURCE_BTS_ID = "NRBTS-" + str(tl.gnbs[0].global_bts_id)


TESTCASE_INFO_MAPPING_TABLE = {
    "T272": {
        "0": {"pci": "721",
              "cell_index": "1",
              "expect_ul_tput": "150",
              "expect_dl_tput": "1500",
              "send_ul_tput": "200000",
              "send_dl_tput": "1600M"},
        "1": {"pci": "722",
              "cell_index": "2",
              "expect_ul_tput": "70",
              "expect_dl_tput": "705",
              "send_ul_tput": "100000",
              "send_dl_tput": "800M"},
        "2": {"pci": "723",
              "cell_index": "3",
              "expect_ul_tput": "25",
              "expect_dl_tput": "270",
              "send_ul_tput": "50000",
              "send_dl_tput": "300M"},
        "3": {"pci": "724",
              "cell_index": "4",
              "expect_ul_tput": "25",
              "expect_dl_tput": "270",
              "send_ul_tput": "50000",
              "send_dl_tput": "300M"},
    },
}
