# -*- coding: utf-8 -*-
"""
2022/06/09 first version by @author: sheng.1.ye@nokia.com
    The TestInfoParser class is unittest and example class for InfoParser.
2022/06/20 add test for parsing csv files, by Ye Sheng
2022/06/30 update format of item_list, by Ye Sheng
2022/07/01 add example of any parser support expression, by Ye Sheng
2022/07/06 add example of any parser support filter_expression, by Ye Sheng
2022/07/14 add silent test, by Ye Sheng
"""
import sys
import os
import unittest

try:
    from testsuite.Beijing.et.common.resources.lib.info_parser import InfoParser
except ModuleNotFoundError:
    sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    from info_parser import InfoParser


class TestInfoParser(unittest.TestCase):

    def setUp(self):
        self.base_folder = os.path.dirname(__file__)
        self.test_folder = os.path.join(self.base_folder, r"logs")

    def test01_filter(self):
        info_parser = InfoParser("br0.pcap.txt", self.test_folder)
        item_list = ["Arrival Time"]
        result_no_filter = info_parser.get_info(item_list=item_list)
        result1 = info_parser.get_info(item_list=item_list, filter_pattern=r"SgNBAdditionRequestAcknowledge")
        result2 = info_parser.get_info(item_list=item_list, filter_pattern=r"SgNBModificationRequired")
        result3 = info_parser.get_info(item_list=item_list, filter_pattern=r"UEContextRelease")
        result123 = info_parser.get_info(
            item_list=item_list,
            filter_pattern=r"SgNBAdditionRequestAcknowledge|SgNBModificationRequired|UEContextRelease")

        self.assertTrue(len(result1), 13)
        self.assertTrue(len(result2), 5)
        self.assertTrue(len(result3), 12)
        self.assertTrue(len(result123), len(result1) + len(result2) + len(result3))
        self.assertTrue(len(result_no_filter), 59)

        self.assertEqual(result1[0]["filter_match"], r"SgNBAdditionRequestAcknowledge")
        self.assertEqual(result2[0]["filter_match"], r"SgNBModificationRequired")
        self.assertEqual(result3[0]["filter_match"], r"UEContextRelease")
        self.assertEqual(result123[0]["filter_match"], r"SgNBAdditionRequestAcknowledge")
        self.assertEqual(result123[-1]["filter_match"], r"SgNBModificationRequired")
        self.assertTrue("filter_match" not in result_no_filter[0])

    def test02_value_type(self):
        info_parser = InfoParser("br0.pcap.txt", self.test_folder)
        item_list = ["Arrival Time",
                     "periodicityAndOffset() as periodicityAndOffset_p",
                     "periodicityAndOffset: as periodicityAndOffset_s",
                     "periodicityAndOffset as periodicityAndOffset",
                     r"periodicityAndOffset find \d+ as period"
                     ]
        result = info_parser.get_info(item_list=item_list, filter_pattern=r"SgNBAdditionRequestAcknowledge", count=1)
        self.assertEqual(len(result), 1)
        self.assertEqual(result[0]["periodicityAndOffset_p"], 7)
        self.assertEqual(result[0]["periodicityAndOffset_s"], "sl10")
        self.assertEqual(result[0]["periodicityAndOffset"], ": sl10 (7)")
        self.assertEqual(result[0]["period"], 10)

    def test03_file_type(self):
        info_parser_pcap = InfoParser("br0.pcap.txt", self.test_folder)
        info_parser_egate = InfoParser("7601_egate_console.log.001", self.test_folder)
        info_parser_scf = InfoParser("scf.xml", self.test_folder)
        info_parser_emil = InfoParser("mon.0.emil.txt", self.test_folder)
        info_parser_emil_anyname = InfoParser("mon.txt", self.test_folder)
        info_parser_emil_explicit = InfoParser("mon.txt", self.test_folder, file_type="emil")
        info_parser_emil_json = InfoParser("emil.json", self.test_folder)
        info_parser_emil_json_explicit = InfoParser("emil.json", self.test_folder, file_type="emil_json")
        parsers = (info_parser_pcap, info_parser_egate, info_parser_scf,
                   info_parser_emil, info_parser_emil_anyname, info_parser_emil_explicit,
                   info_parser_emil_json, info_parser_emil_json_explicit
                   )
        numbers = [58, 60, 1, 207, 207, 207, 173, 173]
        for n, parser in enumerate(parsers):
            info = parser.get_info(item_list=["Arrival Time"])
            self.assertEqual(numbers[n], len(info))

    def test04_file_match(self):
        info_parser_pcap_1 = InfoParser("br0.pcap.txt", self.test_folder)
        info_parser_pcap_2 = InfoParser("x2c.pcap.txt", self.test_folder)
        info_parser_pcap_12 = InfoParser("[bx]*pcap.txt", self.test_folder)
        self.assertEqual(2, len(info_parser_pcap_12.file_list))
        self.assertEqual(info_parser_pcap_2.txt_list + info_parser_pcap_1.txt_list, info_parser_pcap_12.txt_list)

    def test05_fullname(self):
        info_parser_pcap_1 = InfoParser(filename=os.path.join(self.base_folder, "logs/br0.pcap.txt"))
        info_parser_pcap_12 = InfoParser(filename=os.path.join(self.base_folder, "logs/[bx]*pcap.txt"))
        self.assertEqual(1, len(info_parser_pcap_1.file_list))
        self.assertEqual(2, len(info_parser_pcap_12.file_list))

    def test06_value_list(self):
        info_parser = InfoParser("br0.pcap.txt", self.test_folder)
        item_list = ["Arrival Time",
                     "periodicityAndOffset()[] as periodicityAndOffset_list",
                     "periodicityAndOffset()[:2] as periodicityAndOffset_list_first2",
                     "periodicityAndOffset()[-1] as periodicityAndOffset_list_last",
                     "periodicityAndOffset()[100] as periodicityAndOffset_list_exceed",
                     "periodicityAndOffset:[:3] as periodicityAndOffset_s_list3"]
        result = info_parser.get_info(item_list=item_list, filter_pattern=r"SgNBAdditionRequestAcknowledge", count=1)
        self.assertEqual(result[0]["periodicityAndOffset_list"], [7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 2])
        self.assertEqual(result[0]["periodicityAndOffset_list_exceed"], None)
        self.assertEqual(result[0]["periodicityAndOffset_list_first2"], [7, 7])
        self.assertEqual(result[0]["periodicityAndOffset_list_last"], 2)
        self.assertEqual(result[0]["periodicityAndOffset_s_list3"], ["sl10", "slots40", "slots40"])

    def test07_match_items_under_name(self):
        info_parser = InfoParser("*egate_console*", self.test_folder)
        item_list = ["Arrival Time",
                     "periodicityAndOffset:[] as offset",
                     "nzp-CSI-RS-ResourceToAddModList->periodicityAndOffset:[] as offset_under_nzp"
                     ]
        result = info_parser.get_info(item_list=item_list, filter_pattern=r"RRCReconfiguration", count=1)
        self.assertEqual(result[0]["offset"], [54, 2, 0, 0, 1, 1, 2])
        self.assertEqual(result[0]["offset_under_nzp"], [2, 0, 0, 1, 1])

    def test08_match_all_under_name(self):
        info_parser = InfoParser("x2c.pcap.txt", self.test_folder)
        item_list = ["Arrival Time",
                     "nzp-CSI-RS-ResourceToAddModList->periodicityAndOffset->:[] as all_under_offset",
                     "nzp-CSI-RS-ResourceToAddModList->periodicityAndOffset:[] as offset"
                     ]
        result = info_parser.get_info(item_list=item_list, filter_pattern=r"RRCReconfiguration", count=1)
        self.assertEqual(result[0]["offset"], ["slots40", "slots160", "slots160", "slots160", "slots160"])
        self.assertEqual(result[0]["all_under_offset"], [6, 0, 0, 1, 1])

    def test09_formatter_func(self):
        info_parser = InfoParser("x2c.pcap.txt", self.test_folder)
        item_list = ["nzp-CSI-RS-ResourceToAddModList->periodicityAndOffset->[] as periodicityAndOffset"]
        result = info_parser.get_info(item_list=item_list, filter_pattern=r"RRCReconfiguration", count=1)
        self.assertEqual(result[0]["periodicityAndOffset"],
                         ["slots40: 6", "slots160: 0", "slots160: 0", "slots160: 1", "slots160: 1"])

        result = info_parser.get_info(item_list=item_list, filter_pattern=r"RRCReconfiguration", count=1,
                                      formatter_func={"periodicityAndOffset": lambda x: x.split(": ")})
        self.assertEqual(
            result[0]["periodicityAndOffset"],
            [["slots40", "6"], ["slots160", "0"], ["slots160", "0"], ["slots160", "1"], ["slots160", "1"]])

    def test10_scf_parameters(self):
        info_parser = InfoParser("scf.xml", self.test_folder)
        item_list = [
            "MRBTS-1/NRBTS-1/NRCELL-1->ulDlDataSlotRatio:",
            "MRBTS-1/NRBTS-1/NRCELL-1->cellCsiRsLocationList->firstOFDMSymbol:[]",
            "MRBTS-1/NRBTS-1/NRCELL-1->cellCsiRsLocationList->offset:[]",
            "MRBTS-1/NRBTS-1/NRCELLGRP-0->numberOfTransmittedSsBlocks:"
        ]
        result = info_parser.get_info(item_list=item_list)
        self.assertEqual(result[0]["ulDlDataSlotRatio"], "3/7")
        self.assertEqual(result[0]["firstOFDMSymbol"], [7, 7, 3, 3])
        self.assertEqual(result[0]["offset"], [8, 8, 8, 8])
        self.assertEqual(result[0]["numberOfTransmittedSsBlocks"], "6 beams")

    def test11_match_n_lines_after_name(self):
        info_parser = InfoParser("x2c.pcap.txt", self.test_folder)
        item_list = ["Arrival Time",
                     "criticality:[]",
                     "successfulOutcome->criticality:[] as criticality_under_successfuloutcome",
                     "procedureCode~criticality:[] as criticality_1_line_after_procedure_code",
                     "successfulOutcome~~criticality:[] as criticality_2_lines_after_successfuloutcome",
                     "procedureCode~:[] as anything_1_line_after_procedure_code"
                     ]
        result = info_parser.get_info(item_list=item_list, filter_pattern=r"RRCReconfiguration", count=1)
        self.assertEqual(result[0]["criticality"],
                         ["reject", "reject", "reject", "ignore", "ignore", "ignore", "ignore", "reject"])
        self.assertEqual(result[0]["criticality_under_successfuloutcome"],
                         ["reject", "reject", "reject", "ignore", "ignore", "ignore", "ignore", "reject"])
        self.assertEqual(result[0]["criticality_1_line_after_procedure_code"], ["reject"])
        self.assertEqual(result[0]["criticality_2_lines_after_successfuloutcome"], ["reject"])
        self.assertEqual(result[0]["anything_1_line_after_procedure_code"], ["reject"])

    def test12_use_expression(self):
        info_parser = InfoParser("x2c.pcap.txt", self.test_folder)
        item_list = ["Arrival Time",
                     "nzp-CSI-RS-ResourceToAddModList->periodicityAndOffset:[0] as period_and_offset",
                     "=int(period_and_offset[5:]) as period"
                     ]
        result = info_parser.get_info(item_list=item_list, filter_pattern=r"RRCReconfiguration", count=1)
        self.assertEqual(result[0]["period_and_offset"], "slots40")
        self.assertEqual(result[0]["period"], 40)

    def test13_filter_expression(self):
        info_parser = InfoParser("br0.pcap.txt", self.test_folder)
        item_list = ["value~ as msg",
                     "periodicityAndOffset:"]
        result = info_parser.get_info(item_list=item_list, filter_expression=r"msg=='SgNBAdditionRequestAcknowledge'",
                                      count=2)
        self.assertEqual(
            result,
            [{'match_id': 0, 'item_id': 1, 'msg': 'SgNBAdditionRequestAcknowledge', 'periodicityAndOffset': 'sl10'},
             {'match_id': 1, 'item_id': 4, 'msg': 'SgNBAdditionRequestAcknowledge', 'periodicityAndOffset': 'sl10'}])

    def test14_test_silent(self):
        info_parser = InfoParser("br0.pcap.txt", self.test_folder)
        item_list = ["value~ as msg",
                     "periodicityAndOffset:"]
        result = info_parser.get_info(item_list=item_list, filter_pattern='not exists', count=2, silent=True)
        self.assertEqual(result, [])
        result = info_parser.get_info(item_list=item_list, count=200, silent=True)
        self.assertEqual(58, len(result))

    def test15_match_values_in_groups(self):
        info_parser = InfoParser("CPlane_E1F1.pcap.txt", self.test_folder)
        item_list = ['Arrival Time', 'nrCellIdentity:',
                     r'(perCsiRsResConfig_item_\d+)->periodicity()',
                     r'(perCsiRsResConfig_item_\d+)->slotOffset:']
        result = info_parser.get_info(item_list=item_list,
                                      filter_pattern='itf_l2_ps_user_usermodifyreq',
                                      filter_expression='nrCellIdentity == 16385',
                                      silent=True)
        self.assertEqual(result[0]['group'],
                         {'perCsiRsResConfig_item_0': {'periodicity': 160, 'slotOffset': 96},
                          'perCsiRsResConfig_item_1': {'periodicity': 160, 'slotOffset': 96},
                          'perCsiRsResConfig_item_2': {'periodicity': 160, 'slotOffset': 96},
                          'perCsiRsResConfig_item_3': {'periodicity': 160, 'slotOffset': 96}}
                         )

    def test30_match_csv_filter(self):
        info_parser = InfoParser("1730_TTI.bin.13.ul__all.csv", self.test_folder)
        item_list = ["sfn", "slot", "rnti"]
        result = info_parser.get_info(item_list=item_list, filter_expression=r"slot==4 and sfn>1001", count=2)
        self.assertEqual(
            result,
            [{"match_id": 0, "item_id": 36, "sfn": 1002, "slot": 4, "rnti": 8312},
             {"match_id": 1, "item_id": 37, "sfn": 1002, "slot": 4, "rnti": 8312}])

    def test31_match_csv_as_new_name(self):
        info_parser = InfoParser("1730_TTI.bin.13.ul__all.csv", self.test_folder)
        item_list = ["sfn", "slot", "rnti as RNTI"]
        result = info_parser.get_info(item_list=item_list, filter_expression=r"slot==13", count=2)
        self.assertEqual(
            result,
            [{"match_id": 0, "item_id": 2, "sfn": 1000, "slot": 13, "RNTI": 40160},
             {"match_id": 1, "item_id": 3, "sfn": 1000, "slot": 13, "RNTI": 40160}])

    def test32_match_csv_expression(self):
        info_parser = InfoParser("1730_TTI.bin.13.ul__all.csv", self.test_folder)
        item_list = ["sfn", "slot", "rnti", "=rnti+1 as rnti_1", "=rnti_1+1 as rnti_2"]
        result = info_parser.get_info(item_list=item_list, filter_expression=r"slot==13", count=2)
        self.assertEqual(
            result,
            [{"match_id": 0, "item_id": 2, "sfn": 1000, "slot": 13, "rnti": 40160, "rnti_1": 40161, "rnti_2": 40162},
             {"match_id": 1, "item_id": 3, "sfn": 1000, "slot": 13, "rnti": 40160, "rnti_1": 40161, "rnti_2": 40162}])

    def test33_match_csv_filter_use_expression_field(self):
        info_parser = InfoParser("1730_TTI.bin.13.ul__all.csv", self.test_folder)
        item_list = ["sfn", "slot", "rnti", "=slot+1 as slot_1"]
        result = info_parser.get_info(item_list=item_list, filter_expression=r"slot_1==14", count=2)
        self.assertEqual(
            result,
            [{"match_id": 0, "item_id": 2, "slot_1": 14, "sfn": 1000, "slot": 13, "rnti": 40160},
             {"match_id": 1, "item_id": 3, "slot_1": 14, "sfn": 1000, "slot": 13, "rnti": 40160}])

    def test34_match_csv_complex_expression_field(self):
        info_parser = InfoParser("1730_TTI.bin.13.ul__all.csv", self.test_folder)
        item_list = ["sfn",
                     "='%02d:%02d:%02d.%03d'%(hours,minutes,seconds,(microSeconds+500)/1000) as Arrival Time"]
        result = info_parser.get_info(item_list=item_list, filter_expression="", count=2)
        self.assertEqual(
            result,
            [{"match_id": 0, "item_id": 0, "sfn": 921, "Arrival Time": "07:44:19.371", "time_ms": 27859371},
             {"match_id": 1, "item_id": 1, "sfn": 547, "Arrival Time": "07:44:25.871", "time_ms": 27865871}])


if __name__ == "__main__":
    unittest.main()
