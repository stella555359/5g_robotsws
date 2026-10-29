# -*- coding: utf-8 -*

"""
Author:         junjie.fu & caicris
Contact Mail:   junjie.1.fu@nokia-sbell.com & cris.cai@nokia-sbell.com
Description:    Event trace log analysis
                Column index may changes in different program, so when
                you will need to set value for program.
                If program is not set, it's default to 19B
"""
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.check_csv_log import *
import logging


class Parameters19B(object):
    NDIGITS = 2
    INDEX_event = 1
    INDEX_dlFdSchedData_rnti = 98                 # for rnti
    INDEX_dlFdSchedData_rrmDlUsedMcs = 102         # for dl MCS calculate
    INDEX_dlFdSchedData_txNumber = 118            # for dl bler check
    INDEX_dlFdSchedData_numOfLayers = 124         # for layer check
    INDEX_dlFdSchedData_PMI = 125                 # for PMI check
    INDEX_dlFdSchedData_rrmCorrAvgCqi = 133       # for average CQI
    INDEX_dlLaDeltaCqi_rnti = 13
    INDEX_dlLaDeltaCqi_isDeltaCqiCalculated = 16
    INDEX_dlLaDeltaCqi_harqFb = 18
    INDEX_dlLaDeltaCqi_rrmDeltaCqi = 19
    INDEX_dlTdSchedSubcellData_rnti = 45
    INDEX_dlTdSchedSubcellData_resReqClassPrio = 46


class ParametersTrunk(object):
    NDIGITS = 2
    INDEX_event = 1
    INDEX_dlFdSchedData_rnti = 97
    INDEX_dlFdSchedData_rrmDlUsedMcs = 102
    INDEX_dlFdSchedData_txNumber = 119
    INDEX_dlFdSchedData_numOfLayers = 125         # for layer check
    INDEX_dlFdSchedData_PMI = 126                 # for PMI check
    INDEX_dlFdSchedData_rrmCorrAvgCqi = 131       # for average CQI
    INDEX_dlFdSchedData_dlHarqProcessIndex = 120
    INDEX_dlLaDeltaCqi_rnti = 13
    INDEX_dlLaDeltaCqi_isDeltaCqiCalculated = 16
    INDEX_dlLaDeltaCqi_harqFb = 18
    INDEX_dlLaDeltaCqi_rrmDeltaCqi = 19
    INDEX_dlTdSchedSubcellData_rnti = 45
    INDEX_dlTdSchedSubcellData_resReqClassPrio = 46


class Parameters20A(object):
    NDIGITS = 2
    INDEX_event = 1
    INDEX_dlFdSchedData_rnti = 95
    INDEX_dlFdSchedData_rrmDlUsedMcs = 100
    INDEX_dlFdSchedData_txNumber = 116
    INDEX_dlFdSchedData_numOfLayers = 122         # for layer check
    INDEX_dlFdSchedData_PMI = 123                 # for PMI check
    INDEX_dlFdSchedData_rrmCorrAvgCqi = 127       # for average CQI
    INDEX_dlFdSchedData_dlHarqProcessIndex = 117
    INDEX_dlLaDeltaCqi_rnti = 13
    INDEX_dlLaDeltaCqi_isDeltaCqiCalculated = 16
    INDEX_dlLaDeltaCqi_harqFb = 18
    INDEX_dlLaDeltaCqi_rrmDeltaCqi = 19
    INDEX_dlTdSchedSubcellData_rnti = 45
    INDEX_dlTdSchedSubcellData_resReqClassPrio = 46


class TTI_Trace_analysis_dl(object):
    def __init__(self, program=None):
        if program == "19B" or program is None:
            self.parameters = Parameters19B()
        elif program == "Trunk":
            self.parameters = ParametersTrunk()
        elif program == "20A":
            self.parameters = Parameters20A()
        else:
            raise Exception("Invalid input for program.")

    def get_rnti(self, file_path):
        """
        Filter for event dlTdSchedSubcellData and find resReqClassPrio=40,
        which means rnti used for DL data traffic in initial transmission.
        :param file_path: Example input : XXX/XXX/XXX.csv
        :return: rnti value
        """
        try:
            dlTdSchedSubcellData_event_with_data_traffic = get_lines_with_multiple_column_filter(
                    file_path=file_path,
                    column_list=[self.parameters.INDEX_event,
                                 self.parameters.INDEX_dlTdSchedSubcellData_resReqClassPrio],
                    expected_list=["dlTdSchedSubcellData: sfn", "40"])
        except LookupError:
            raise LookupError("Fail to get rnti as no event found for dlTdSchedSubcellData with resReqClassPrio=40")
        rnti = dlTdSchedSubcellData_event_with_data_traffic[0][1][self.parameters.INDEX_dlTdSchedSubcellData_rnti-1]
        logging.info("Current available rnti is: {}".format(rnti))
        return rnti

    def get_dlLaDeltaCqi_event(self, file_path):
        rnti = self.get_rnti(file_path=file_path)
        try:
            dlLaDeltaCqi_event = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.parameters.INDEX_event, self.parameters.INDEX_dlLaDeltaCqi_rnti],
                expected_list=["dlLaDeltaCqi: rnti", rnti])
        except LookupError:
            raise LookupError("No dlLaDeltaCqi event found")
        else:
            return dlLaDeltaCqi_event

    def get_dlFdSchedData_event(self, file_path):
        rnti = self.get_rnti(file_path=file_path)
        try:
            dlFdSchedData_event = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.parameters.INDEX_event, self.parameters.INDEX_dlFdSchedData_rnti],
                expected_list=["dlFdSchedData: sfn", rnti])
        except LookupError:
            raise LookupError("No dlFdSchedData event found")
        else:
            return dlFdSchedData_event

    def get_related_dlLaDeltaCqi_event_row(self, row_num_dlFdSchedData_event, dlLaDeltaCqi_event):
        """
        Will return the entire row if found in dlLaDeltaCqi event, otherwise will return -1
        :param row_num_dlFdSchedData_event:
        :param dlLaDeltaCqi_event:
        :return:
        """
        try:
            dlLaDeltaCqi_event_row = add_filter_to_matrix_in_given_range(
                dlLaDeltaCqi_event,
                None,
                row_num_dlFdSchedData_event - 1
            )[-1]
        except LookupError:
            logging.debug(
                "Fail to find related dlLaDeltaCqi event row based on row num {} "
                "in dlFdSchedData event".format(row_num_dlFdSchedData_event))
            dlLaDeltaCqi_event_row = -1
        return dlLaDeltaCqi_event_row

    def get_rrmDeltaCqi_based_on_dlFdSchedData_event_row_num(
            self, row_num_dlFdSchedData_event, dlLaDeltaCqi_event):
        dlLaDeltaCqi_event_row = self.get_related_dlLaDeltaCqi_event_row(
            row_num_dlFdSchedData_event=row_num_dlFdSchedData_event,
            dlLaDeltaCqi_event=dlLaDeltaCqi_event
        )
        if dlLaDeltaCqi_event_row == -1:
            rrmDeltaCqi = 0
        else:
            rrmDeltaCqi = float(
                dlLaDeltaCqi_event_row[1][self.parameters.INDEX_dlLaDeltaCqi_rrmDeltaCqi - 1])
        return rrmDeltaCqi

    def get_rrmDeltaCqiStepup_based_on_calculation(self, dllaDeltaCqiStepdown, dllaBlerTarget):
        """
        Calculate rrmDeltaCqiStepup based on NIDD parameter configured
        :param ullaDeltaCqiStepdown: NIDD parameter configured
        :param dllaBlerTarget: NIDD parameter configured
        :return:
        """
        rrmDeltaCqiStepup = float(
            dllaDeltaCqiStepdown * dllaBlerTarget / (1 - dllaBlerTarget))
        return rrmDeltaCqiStepup

    def verify_number_equal(self, act, exp, msg=None):
        """
        Will change the number to float with digit number default to NDIGITD
        :param act: actual value
        :param exp: expect value
        :param msg:
        :return: None
        """
        ndigits = self.parameters.NDIGITS
        act = round(float(act), ndigits)
        exp = round(float(exp), ndigits)

        if cmp(act, exp) == 0:
            pass
        else:
            error_message = "act:{} != exp:{}, msg=".format(act, exp) + msg
            raise Exception(error_message)

    def verify_calculation_of_delta_CQI(self, file_path, dllaDeltaCqiStepdown, dllaBlerTarget):
        """
        Checking dlLaDeltaCqi event:
        1. isDeltaCqiCalculated == 0: rrmDeltaCqi should be same with previous row value
        2. isDeltaCqiCalculated == 1:
            if harqFb == "ACK":  rrmDeltaCqi=pre_rrmDeltaCqi+rrmDeltaCqiStepup
            if harqFb == "NACK": rrmDeltaCqi=pre_rrmDeltaCqi-dllaDeltaCqiStepdown
        :param file_path: Event trace log file path with CSV format
        :param dllaDeltaCqiStepdown: Configured NIDD param from webui
        :param dllaBlerTarget: Configured NIDD param from webui
        :return:
        """
        dlLaDeltaCqi_event = self.get_dlLaDeltaCqi_event(file_path=file_path)
        rrmDeltaCqiStepup = self.get_rrmDeltaCqiStepup_based_on_calculation(
            dllaDeltaCqiStepdown=dllaDeltaCqiStepdown,
            dllaBlerTarget=dllaBlerTarget)
        for i in range(0, len(dlLaDeltaCqi_event)):
            cur_row = dlLaDeltaCqi_event[i][0]
            cur_isDeltaCqiCalculated = int(
                dlLaDeltaCqi_event[i][1][self.parameters.INDEX_dlLaDeltaCqi_isDeltaCqiCalculated - 1])
            cur_harqFb = dlLaDeltaCqi_event[i][1][self.parameters.INDEX_dlLaDeltaCqi_harqFb - 1]
            cur_rrmDeltaCqi = float(
                dlLaDeltaCqi_event[i][1][self.parameters.INDEX_dlLaDeltaCqi_rrmDeltaCqi - 1])
            if i == 0:
                pre_row = 0
                pre_rrmDeltaCqi = 0
            else:
                pre_row = dlLaDeltaCqi_event[i - 1][0]
                pre_rrmDeltaCqi = float(
                    dlLaDeltaCqi_event[i - 1][1][self.parameters.INDEX_dlLaDeltaCqi_rrmDeltaCqi - 1])
            if cur_isDeltaCqiCalculated == 0:
                rrmDeltaCqiExp = pre_rrmDeltaCqi
            elif cur_isDeltaCqiCalculated == 1:
                if cur_harqFb == "ACK":
                    rrmDeltaCqiExp = pre_rrmDeltaCqi + rrmDeltaCqiStepup
                elif cur_harqFb == "NACK":
                    rrmDeltaCqiExp = pre_rrmDeltaCqi - dllaDeltaCqiStepdown
                else:
                    raise Exception(
                        "Current harqFb:{} is not recognized. Please check manually. Row number:{}". format(
                            cur_harqFb, cur_row))
            else:
                raise Exception(
                    "isDeltaCqiCalculated value:{} is neither 0 nor 1. "
                    "Please check manually. Row number:{}".format(
                        cur_isDeltaCqiCalculated, cur_row))
            self.verify_number_equal(
                act=cur_rrmDeltaCqi,
                exp=rrmDeltaCqiExp,
                msg="Calculation for delta CQI is incorrect. i={},"
                "dlLaDeltaCqi event Row num: {}, previous row num is: {}".format(
                    i,
                    cur_row,
                    pre_row))

    def verify_calculation_of_corrected_average_CQI(self, file_path, rdAvgCqi):
        """
        1. txNumber=1, rrmCorrAvgCqi_exp = rdAvgCqi + rrmDeltaCqi
        2. txNumber>1, rrmCorrAvgCqi_exp = previous_rrmCorrAvgCqi
        :param file_path: Event trace log file path with CSV format
        :param rdAvgCqi: R&D parameter defined in swconfig file
        :return: None
        """
        dlFdSchedData_event = self.get_dlFdSchedData_event(file_path=file_path)
        dlLaDeltaCqi_event = self.get_dlLaDeltaCqi_event(file_path=file_path)
        for i in range(0, len(dlFdSchedData_event)):
            cur_row = dlFdSchedData_event[i][0]
            cur_txNumber = int(
                dlFdSchedData_event[i][1][self.parameters.INDEX_dlFdSchedData_txNumber - 1])
            cur_rrmCorrAvgCqi = float(
                dlFdSchedData_event[i][1][self.parameters.INDEX_dlFdSchedData_rrmCorrAvgCqi - 1])
            # print("Calculation for corrected avg CQI: i={}, cur_row={}".format(i, cur_row))
            if i == 0:
                rrmCorrAvgCqi_exp = rdAvgCqi
            else:
                pre_rrmCorrAvgCqi = float(
                    dlFdSchedData_event[i - 1][1][self.parameters.INDEX_dlFdSchedData_rrmCorrAvgCqi - 1])
                if cur_txNumber > 1:
                    rrmCorrAvgCqi_exp = pre_rrmCorrAvgCqi
                elif cur_txNumber == 1:
                    rrmDeltaCqi = self.get_rrmDeltaCqi_based_on_dlFdSchedData_event_row_num(
                        row_num_dlFdSchedData_event=cur_row, dlLaDeltaCqi_event=dlLaDeltaCqi_event)
                    rrmCorrAvgCqi_exp = rdAvgCqi + rrmDeltaCqi
                else:
                    raise Exception(
                        "txNumber: {} is not >=1, Error row number in dlFdSchedData event is: {}".format(
                            cur_txNumber, cur_row))
            self.verify_number_equal(
                act=cur_rrmCorrAvgCqi,
                exp=rrmCorrAvgCqi_exp,
                msg="Calculation for corrected average CQI failed. i={}, "
                "txNumber={}, current row number={}".format(
                    i,
                    cur_txNumber,
                    cur_row))

    def _get_mcs_value_sorted(self, mcs_list):
        new_list = []
        for mcs in mcs_list:
            new_list.append(int(mcs))
        new_list.sort()
        return new_list

    def verify_dl_data_transmission_is_done_with_highest_mcs(self, file_path, mcs_mapping_tables):
        dlFdSchedData_event = self.get_dlFdSchedData_event(file_path=file_path)
        mcs_list = get_unique_values_in_column(
            matrix=dlFdSchedData_event,
            column_number=self.parameters.INDEX_dlFdSchedData_rrmDlUsedMcs)
        mcs_max_act = self._get_mcs_value_sorted(mcs_list)[-1]
        mcs_mapping_table = mcs_mapping_tables[0]
        mcs_max_exp = mcs_mapping_table[len(mcs_mapping_table) - 1]['mcs']
        logging.debug("Actual max MCS value: {}".format(mcs_max_act))
        self.verify_number_equal(
            act=mcs_max_act,
            exp=mcs_max_exp,
            msg="DL data transmission does not reach the highest mcs")
        logging.info("Verify passed. DL transmission has reached the highest MCS")

    def calculate_dl_bler(self, file_path):
        dlFdSchedData_event = self.get_dlFdSchedData_event(file_path=file_path)
        try:
            txNum_with_1_event = add_filters_to_matrix(
                dlFdSchedData_event,
                [self.parameters.INDEX_dlFdSchedData_txNumber, ['1']])
            count_txNum_with_1 = len(txNum_with_1_event)
            print(count_txNum_with_1)
        except LookupError:
            count_txNum_with_1 = 0
        try:
            txNum_with_2_event = add_filters_to_matrix(
                dlFdSchedData_event,
                [self.parameters.INDEX_dlFdSchedData_txNumber, ['2']])
            count_txNum_with_2 = len(txNum_with_2_event)
            print(count_txNum_with_2)
        except LookupError:
            count_txNum_with_2 = 0
        dl_bler = float(count_txNum_with_2) / float(count_txNum_with_1)
        return dl_bler

    def get_dl_average_mcs(self, file_path):
        dlFdSchedData_event = self.get_dlFdSchedData_event(file_path=file_path)
        sum_mcs = 0
        for i in range(0, len(dlFdSchedData_event)):
            mcs = int(dlFdSchedData_event[i][1]
                      [self.parameters.INDEX_dlFdSchedData_rrmDlUsedMcs - 1])
            sum_mcs = sum_mcs + mcs
        avg_mcs = float(sum_mcs) / len(dlFdSchedData_event)
        return avg_mcs

    def get_dl_average_layer(self, file_path):
        dlFdSchedData_event = self.get_dlFdSchedData_event(file_path=file_path)
        sum_layer = 0
        for i in range(0, len(dlFdSchedData_event)):
            layer = int(dlFdSchedData_event[i][1]
                        [self.parameters.INDEX_dlFdSchedData_numOfLayers - 1])
            sum_layer = sum_layer + layer
        avg_layer = float(sum_layer) / len(dlFdSchedData_event)
        return avg_layer
