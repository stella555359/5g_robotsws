"""
author/contact:   krzysztof.1.wrobel@nokia.com, I_MN_RAN_PZ1_WRO_7_SG_GMS <I_MN_RAN_PZ1_WRO_7_SG@internal.nsn.com>
Description:      functions to tracking params in csv
"""

import math
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.parsers.UplaneTTiParesr import UplaneTTiParesr

MESSAGE_ID = "csiSrReportData"
STRING_TO_SEARCH = "APERIODIC_CSI"


class ACsiParser(UplaneTTiParesr):

    def __init__(self, file_path):
        super(ACsiParser, self).__init__(file_path)
        self.acsi_counter_correct = 0
        self.acsi_counter_failed = 0

    def check_the_csv_file_acsi_report_tdd(self):
        self.read_file_tti_trace_csv(MESSAGE_ID, STRING_TO_SEARCH)
        self._verify_asci_reports_tdd()
        self._confirm_failed_acsi_msg_number()

    def check_the_csv_file_acsi_report_fdd_ol(self):
        self.read_file_tti_trace_csv(MESSAGE_ID, STRING_TO_SEARCH)
        self._verify_asci_reports_fdd_ol()
        self._confirm_failed_acsi_msg_number()

    def check_the_csv_file_acsi_report_fdd_cl(self):
        self.read_file_tti_trace_csv(MESSAGE_ID, STRING_TO_SEARCH)
        self._verify_asci_reports_fdd_cl()
        self._confirm_failed_acsi_msg_number()

    def _verify_asci_reports_tdd(self):
        for acsi_report in self.msg_id_report_data_list:
            if self._are_csi_part_bits_not_zero(acsi_report) and self._is_nodtx_found(acsi_report) \
                    and self._are_crc_checks_zeros(acsi_report):
                self.acsi_counter_correct += 1
            else:
                self.acsi_counter_failed += 1

    def _verify_asci_reports_fdd_ol(self):
        for acsi_report in self.msg_id_report_data_list:
            if self._is_csi_part_1_not_zero(acsi_report) and self._is_nodtx_found(acsi_report) \
                    and self._are_crc_checks_zeros(acsi_report):
                self.acsi_counter_correct += 1
            else:
                self.acsi_counter_failed += 1

    def _verify_asci_reports_fdd_cl(self):
        for acsi_report in self.msg_id_report_data_list:
            if self._are_csi_part_bits_not_zero(acsi_report) and self._is_nodtx_found(acsi_report) \
                    and self._are_crc_checks_zeros(acsi_report):
                self.acsi_counter_correct += 1
            else:
                self.acsi_counter_failed += 1

    @staticmethod
    def _is_csi_part_1_not_zero(acsi_report):
        return int(acsi_report['numOfUciCsiPart1Bits']) != 0

    @staticmethod
    def _are_csi_part_bits_not_zero(acsi_report):
        return int(acsi_report['numOfUciCsiPart1Bits']) != 0 and int(acsi_report['numOfUciCsiPart2Bits']) != 0

    @staticmethod
    def _is_nodtx_found(acsi_report):
        return acsi_report['dtx'] == "NON_DTX" and int(acsi_report['dtxCsiPart1']) == 0 \
            and int(acsi_report['dtxCsiPart2']) == 0

    @staticmethod
    def _are_crc_checks_zeros(acsi_report):
        return int(acsi_report['csiPart1CrcCheck']) == 0 and int(acsi_report['csiPart2CrcCheck']) == 0

    def _confirm_failed_acsi_msg_number(self, failedresp_percent=5):
        assert (self.acsi_counter_correct + self.acsi_counter_failed), "Missing aperiodic CSI reports."
        failed_resp = math.ceil(failedresp_percent * (self.acsi_counter_correct + self.acsi_counter_failed / 100.))
        Logger.info(f"All ACSI {self.acsi_counter_correct + self.acsi_counter_failed},"
                    f" failed {self.acsi_counter_failed}")
        assert failed_resp > self.acsi_counter_failed, f"To many failed ACSI: {self.acsi_counter_failed}"
