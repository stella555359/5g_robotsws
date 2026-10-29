# -*- coding: utf-8 -*

"""
Author:         Ding Binmei developped for 19A, Wu Fangmin Modified for 19B
Contact Mail:   19A:binmei.ding@nokia-sbell.com, 19B:fangmin.wu@nokia-sbell.com
Description:    Event trace log analysis
                Column index may changes in different program, so when calling this file,
                you will need to set value for program. Currently supported versions are:  19B
                If program is not set, it's default to 19B
"""
import logging
from check_csv_log import *


class Parameters19B(object):
    NDIGITS = 2
    INDEX_event = 1
    INDEX_dlFdSchedData_rnti = 98
    INDEX_dlFdSchedData_onAirTimeSlot = 97
    INDEX_dlFdSchedData_rrmDlUsedMcs = 102
    INDEX_dlFdSchedData_rrmDlProposedMcs = 103
    INDEX_dlFdSchedData_txNumber = 118
    INDEX_dlFdSchedData_dlHarqProcessIndex = 119
    INDEX_dlFdSchedData_rrmCorrAvgCqi = 133
    INDEX_dlLaDeltaCqi_rnti = 13
    INDEX_dlLaDeltaCqi_isDeltaCqiCalculated = 16
    INDEX_dlLaDeltaCqi_harqFb = 18
    INDEX_dlLaDeltaCqi_rrmDeltaCqi = 19
    INDEX_dlTdSchedSubcellData_rnti = 45
    INDEX_dlTdSchedSubcellData_resReqClassPrio = 46


class Parameters20A(object):
    NDIGITS = 2
    INDEX_event = 1
    INDEX_dlFdSchedData_rnti = 99
    INDEX_dlFdSchedData_onAirTimeSlot = 98
    INDEX_dlFdSchedData_rrmDlUsedMcs = 104
    INDEX_dlFdSchedData_rrmDlProposedMcs = 105
    INDEX_dlFdSchedData_txNumber = 120
    INDEX_dlFdSchedData_dlHarqProcessIndex = 121
    INDEX_dlFdSchedData_rrmCorrAvgCqi = 135
    INDEX_dlLaDeltaCqi_rnti = 13
    INDEX_dlLaDeltaCqi_isDeltaCqiCalculated = 16
    INDEX_dlLaDeltaCqi_harqFb = 18
    INDEX_dlLaDeltaCqi_rrmDeltaCqi = 19
    INDEX_dlTdSchedSubcellData_rnti = 45
    INDEX_dlTdSchedSubcellData_resReqClassPrio = 46


class Parameters20B(object):
    NDIGITS = 2
    INDEX_event = 1
    INDEX_dlFdSchedData_rnti = 101
    INDEX_dlFdSchedData_onAirTimeSlot = 100
    INDEX_dlFdSchedData_rrmDlUsedMcs = 106
    INDEX_dlFdSchedData_rrmDlProposedMcs = 107
    INDEX_dlFdSchedData_txNumber = 123
    INDEX_dlFdSchedData_dlHarqProcessIndex = 124
    INDEX_dlFdSchedData_rrmCorrAvgCqi = 139
    INDEX_dlLaDeltaCqi_rnti = 263
    INDEX_dlLaDeltaCqi_isDeltaCqiCalculated = 268
    INDEX_dlLaDeltaCqi_harqFb = 270
    INDEX_dlLaDeltaCqi_rrmDeltaCqi = 271
    INDEX_dlTdSchedSubcellData_rnti = 45
    INDEX_dlTdSchedSubcellData_resReqClassPrio = 46


class ParametersSBTS22R1(object):
    NDIGITS = 2
    INDEX_event = 1
    INDEX_dlFdSchedData_rnti = 165
    INDEX_dlFdSchedData_onAirTimeSlot = 152
    INDEX_dlFdSchedData_rrmDlUsedMcs = 171
    INDEX_dlFdSchedData_rrmDlProposedMcs = 172
    INDEX_dlFdSchedData_txNumber = 190
    INDEX_dlFdSchedData_dlHarqProcessIndex = 191
    INDEX_dlFdSchedData_rrmCorrAvgCqi = 223
    INDEX_dlLaDeltaCqi_rnti = 519
    INDEX_dlLaDeltaCqi_isDeltaCqiCalculated = 524
    INDEX_dlLaDeltaCqi_harqFb = 526
    INDEX_dlLaDeltaCqi_rrmDeltaCqi = 527
    INDEX_dlTdSchedSubcellData_rnti = 49
    INDEX_dlTdSchedSubcellData_resReqClassPrio = 50


class Parameters21B(object):
    NDIGITS = 2
    INDEX_event = 1
    INDEX_dlFdSchedData_rnti = 102
    INDEX_dlFdSchedData_onAirTimeSlot = 101
    INDEX_dlFdSchedData_rrmDlUsedMcs = 107
    INDEX_dlFdSchedData_rrmDlProposedMcs = 108
    INDEX_dlFdSchedData_txNumber = 124
    INDEX_dlFdSchedData_dlHarqProcessIndex = 125
    INDEX_dlFdSchedData_rrmCorrAvgCqi = 140
    INDEX_dlLaDeltaCqi_rnti = 263
    INDEX_dlLaDeltaCqi_isDeltaCqiCalculated = 268
    INDEX_dlLaDeltaCqi_harqFb = 270
    INDEX_dlLaDeltaCqi_rrmDeltaCqi = 271
    INDEX_dlTdSchedSubcellData_rnti = 45
    INDEX_dlTdSchedSubcellData_resReqClassPrio = 46


class ParametersSBTS21B(object):
    NDIGITS = 2
    INDEX_event = 1
    INDEX_dlFdSchedData_rnti = 156
    INDEX_dlFdSchedData_onAirTimeSlot = 154
    INDEX_dlFdSchedData_rrmDlUsedMcs = 161
    INDEX_dlFdSchedData_rrmDlProposedMcs = 162
    INDEX_dlFdSchedData_txNumber = 180
    INDEX_dlFdSchedData_dlHarqProcessIndex = 181
    INDEX_dlFdSchedData_rrmCorrAvgCqi = 206
    INDEX_dlLaDeltaCqi_rnti = 519
    INDEX_dlLaDeltaCqi_isDeltaCqiCalculated = 524
    INDEX_dlLaDeltaCqi_harqFb = 526
    INDEX_dlLaDeltaCqi_rrmDeltaCqi = 527
    INDEX_dlTdSchedSubcellData_rnti = 45
    INDEX_dlTdSchedSubcellData_resReqClassPrio = 46


class ParametersSBTS22R2(object):
    NDIGITS = 2
    INDEX_event = 1
    INDEX_dlFdSchedData_rnti = 165
    INDEX_dlFdSchedData_onAirTimeSlot = 154
    INDEX_dlFdSchedData_rrmDlUsedMcs = 171
    INDEX_dlFdSchedData_rrmDlProposedMcs = 172
    INDEX_dlFdSchedData_txNumber = 190
    INDEX_dlFdSchedData_dlHarqProcessIndex = 191
    INDEX_dlFdSchedData_rrmCorrAvgCqi = 223
    INDEX_dlLaDeltaCqi_rnti = 519
    INDEX_dlLaDeltaCqi_isDeltaCqiCalculated = 524
    INDEX_dlLaDeltaCqi_harqFb = 526
    INDEX_dlLaDeltaCqi_rrmDeltaCqi = 527
    INDEX_dlTdSchedSubcellData_rnti = 55
    INDEX_dlTdSchedSubcellData_resReqClassPrio = 56


class TTI_Trace_analysis_dl(object):
    def __init__(self, program=None):
        if program == "5G19B" or program is None:
            self.parameters = Parameters19B()
        elif program == "5G20A":
            self.parameters = Parameters20A()
        elif program == "5G20B":
            self.parameters = Parameters20B()
        elif program == "SBTS22R1":
            self.parameters = ParametersSBTS22R1()
        elif program == "5G21B":
            self.parameters = Parameters21B()
        elif program == "SBTS21B":
            self.parameters = ParametersSBTS21B()
        elif program == "SBTS22R2":
            self.parameters = ParametersSBTS22R2()
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
            raise LookupError(
                "Fail to get rnti as no event found for dlTdSchedSubcellData with resReqClassPrio=40")
        rnti = dlTdSchedSubcellData_event_with_data_traffic[0][1][
            self.parameters.INDEX_dlTdSchedSubcellData_rnti - 1]
        logging.info("Current available rnti is: {}".format(rnti))
        return rnti

    def get_dlLaDeltaCqi_event(self, file_path):
        rnti = self.get_rnti(file_path=file_path)
        try:
            dlLaDeltaCqi_event = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[
                    self.parameters.INDEX_event,
                    self.parameters.INDEX_dlLaDeltaCqi_rnti],
                expected_list=["dlLaDeltaCqi: sfn", rnti])
        except LookupError:
            raise LookupError("No dlLaDeltaCqi event found")
        else:
            return dlLaDeltaCqi_event

    def get_dlFdSchedData_event(self, file_path):
        rnti = self.get_rnti(file_path=file_path)
        try:
            dlFdSchedData_event = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[
                    self.parameters.INDEX_event,
                    self.parameters.INDEX_dlFdSchedData_rnti],
                expected_list=["dlFdSchedData: sfn", rnti])
        except LookupError:
            raise LookupError("No dlFdSchedData event found")
        else:
            return dlFdSchedData_event

    def get_related_dlLaDeltaCqi_event_row(
            self, row_num_dlFdSchedData_event, dlLaDeltaCqi_event):
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

    def get_mcs_mapping_table(self, onAirTimeSlot, mcs_mapping_tables):
        """
        if onAriTimeSlot is 2 or 12, select mcs mapping table with symbol 12,
        others select mcs mapping table with symbol 13
        :param onAirTimeSlot: Value selected from dlFdSchedData event
        :param mcs_mapping_tables: should be a matrix, mcs_mapping_table[0] refers to symbol 12 table,
                                   mcs_mapping_table[1] refers to symbol 13 table
        :return:
        """

        if int(onAirTimeSlot) in [2, 12]:
            mcs_mapping_table = mcs_mapping_tables[0]
        else:
            mcs_mapping_table = mcs_mapping_tables[1]
        return mcs_mapping_table

    def get_rrmDeltaCqiStepup_based_on_calculation(
            self, dllaDeltaCqiStepdown, dllaBlerTarget):
        """
        Calculate rrmDeltaCqiStepup based on NIDD parameter configured
        :param ullaDeltaCqiStepdown: NIDD parameter configured
        :param dllaBlerTarget: NIDD parameter configured
        :return:
        """
        rrmDeltaCqiStepup = float(
            dllaDeltaCqiStepdown * dllaBlerTarget / (1 - dllaBlerTarget))
        return rrmDeltaCqiStepup

    def verify_first_used_mcs_and_rrmCorrAvgCqi_value_match_as_configured(
            self, mcs_mapping_tables, rdAvgCqi, file_path):
        """
        1. First used MCS configured same as the first row in mcs mapping table
        2. First used rrmCorrAvgCqi should be same as R&D parameter rdAvgCqi
        :param mcs_mapping_tables: should be a matrix, mcs_mapping_table[0] refers to symbol 12,
                                  mcs_mapping_table[1] refers to symbol 13
        :param rdAvgCqi: R&D parameter
        :param file_path: Event trace log file path with CSV format
        :return:
        """
        dlFdSchedData_event = self.get_dlFdSchedData_event(file_path=file_path)
        onAirTimeSlot_act = int(
            dlFdSchedData_event[0][1][self.parameters.INDEX_dlFdSchedData_onAirTimeSlot - 1])
        mcs_mapping_table = self.get_mcs_mapping_table(
            onAirTimeSlot=onAirTimeSlot_act,
            mcs_mapping_tables=mcs_mapping_tables)
        cur_row = dlFdSchedData_event[0][0]
        mcs_act = dlFdSchedData_event[0][1][self.parameters.INDEX_dlFdSchedData_rrmDlUsedMcs - 1]
        mcs_exp = mcs_mapping_table[0]['mcs']
        rrmCorrAvgCqi_act = dlFdSchedData_event[0][1][self.parameters.INDEX_dlFdSchedData_rrmCorrAvgCqi - 1]
        self.verify_number_equal(
            act=rrmCorrAvgCqi_act,
            exp=rdAvgCqi,
            msg="First used rrmCorrAvgCqi is not the same as configured. onAirTimeSlot={}, row num={}".format(
                onAirTimeSlot_act,
                cur_row))

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

    def get_mcs_by_rrmCorrAvgCqi_based_on_mcs_mapping_table(
            self, rrmCorrAvgCqi, onAirTimeSlot, mcs_mapping_tables):
        """
        Search MCS mapping table and the mcs value based on rrmCorrAvgCqi value get from event dlFdSchedData
        A WA is added as for the event trace tool accuracy issue.
            When  rrmCorrAvgCqi ==   mcs_min_cqi, current mcs and previous mcs can also be passed
        :param rrmCorrAvgCqi: Value from event dlFdSchedData in column rrmCorrAvgCqi
        :param mcs_mapping_tables: should be a matrix, mcs_mapping_table[0] refers to symbol 12,
                                  mcs_mapping_table[1] refers to symbol 13. Example input for this field:
                                  [[dict(mcs=18, cqi=9.65), dict(mcs=19, cqi=10.13)],
                                   [dict(mcs=18, cqi=9.72), dict(mcs=19, cqi=10.15)]]
        :return: a list for mcs
        """
        rrmCorrAvgCqi = float(rrmCorrAvgCqi)
        mcs_mapping_table = self.get_mcs_mapping_table(
            onAirTimeSlot=onAirTimeSlot,
            mcs_mapping_tables=mcs_mapping_tables)
        min_cqi = mcs_mapping_table[0]['cqi']
        max_cqi = mcs_mapping_table[len(mcs_mapping_table) - 1]['cqi']
        mcs = []
        if rrmCorrAvgCqi <= min_cqi:
            mcs.append(mcs_mapping_table[0]['mcs'])
        elif rrmCorrAvgCqi > max_cqi:
            mcs.append(mcs_mapping_table[len(mcs_mapping_table) - 1]['mcs'])
        elif rrmCorrAvgCqi == max_cqi:
            mcs.append(mcs_mapping_table[len(mcs_mapping_table) - 2]['mcs'])
            mcs.append(mcs_mapping_table[len(mcs_mapping_table) - 1]['mcs'])
        else:
            for i in range(0, len(mcs_mapping_table)):

                mcs_min_cqi = mcs_mapping_table[i]['cqi']
                mcs_max_cqi = mcs_mapping_table[i + 1]['cqi']
                if rrmCorrAvgCqi > mcs_min_cqi and rrmCorrAvgCqi < mcs_max_cqi:
                    mcs.append(mcs_mapping_table[i]['mcs'])
                    break
                elif rrmCorrAvgCqi == mcs_min_cqi:
                    mcs.append(mcs_mapping_table[i - 1]['mcs'])
                    mcs.append(mcs_mapping_table[i]['mcs'])
                    break
                else:
                    continue
        return mcs

    def verify_dl_mcs_is_properly_used_based_on_mcs_mapping_table(
            self, mcs_mapping_tables, file_path):
        """
        1. txNumber = 1, use current rrmCorrAvgCqi value to locate MCS value in mcs mapping table,
           then compare with current MCS
        2. txNumber >1 (Means retransmission), MCS value should be the same with the first transmission value
           How to locate first transmission row: Search previous records in dlFdSchedData event
           with current harq_id and txNumber=1, then get the nearest row
        :param mcs_mapping_tables:
        :param file_path:
        :return:
        """
        dlFdSchedData_event = self.get_dlFdSchedData_event(file_path=file_path)
        for i in range(0, len(dlFdSchedData_event)):
            cur_row = dlFdSchedData_event[i][0]
            cur_mcs = int(dlFdSchedData_event[i][1]
                          [self.parameters.INDEX_dlFdSchedData_rrmDlProposedMcs - 1])
            cur_harq_id = dlFdSchedData_event[i][1][self.parameters.INDEX_dlFdSchedData_dlHarqProcessIndex - 1]
            cur_onAirTimeSlot = int(
                dlFdSchedData_event[i][1][self.parameters.INDEX_dlFdSchedData_onAirTimeSlot - 1])
            cur_txNumber = int(
                dlFdSchedData_event[i][1][self.parameters.INDEX_dlFdSchedData_txNumber - 1])
            cur_rrmCorrAvgCqi = dlFdSchedData_event[i][1][self.parameters.INDEX_dlFdSchedData_rrmCorrAvgCqi - 1]
            if cur_txNumber == 1:
                mcs_exp = self.get_mcs_by_rrmCorrAvgCqi_based_on_mcs_mapping_table(
                    rrmCorrAvgCqi=cur_rrmCorrAvgCqi,
                    onAirTimeSlot=cur_onAirTimeSlot,
                    mcs_mapping_tables=mcs_mapping_tables)
                if cur_mcs in mcs_exp:
                    pass
                else:
                    raise Exception(
                        "Verify DL MCS mapping table failed for first transmission. "
                        "Error row num:{}, Actual mcs value:{}. "
                        "Expected mcs value:{}".format(
                            cur_row, cur_mcs, mcs_exp))
            else:
                filter_with_txNum_and_harq_id = add_filter_to_matrix_in_given_range(
                    dlFdSchedData_event,
                    None,
                    cur_row - 1,
                    [self.parameters.INDEX_dlFdSchedData_txNumber, ['1']],
                    [self.parameters.INDEX_dlFdSchedData_dlHarqProcessIndex, [cur_harq_id]]
                )
                pre_row = filter_with_txNum_and_harq_id[-1][0]
                pre_mcs = int(
                    filter_with_txNum_and_harq_id[-1][1][self.parameters.INDEX_dlFdSchedData_rrmDlUsedMcs - 1])
                self.verify_number_equal(
                    act=cur_mcs,
                    exp=pre_mcs,
                    msg="Verify DL MCS mapping table failed for retransmission. "
                        "Error row number: {}, filtered row number with txnum=1 and harq_id={} is {}".format(
                            cur_row,
                            cur_harq_id,
                            pre_row))

    def verify_calculation_of_delta_CQI(
            self, file_path, dllaDeltaCqiStepdown, dllaBlerTarget):
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

    def verify_dl_data_transmission_is_done_with_highest_mcs(
            self, file_path, mcs_mapping_tables):
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
        logging.info(
            "Verify passed. DL transmission has reached the highest MCS")

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

    def calculation_average_rrmCorrAvgCqi(self, file_path):
        """
        :param file_path: Event trace log file path with CSV format
        :return: None
        """
        dlFdSchedData_event = self.get_dlFdSchedData_event(file_path=file_path)
        dlLaDeltaCqi_event = self.get_dlLaDeltaCqi_event(file_path=file_path)
        sum_cqi = 0
        for i in range(0, len(dlFdSchedData_event)):
            cur_rrmCorrAvgCqi = float(
                dlFdSchedData_event[i][1][self.parameters.INDEX_dlFdSchedData_rrmCorrAvgCqi - 1])
            sum_cqi = sum_cqi + cur_rrmCorrAvgCqi
        avg_cqi = float(sum_cqi) / len(dlFdSchedData_event)
        return avg_cqi

    def get_mcs_list(self, file_path):
        dlFdSchedData_event = self.get_dlFdSchedData_event(file_path=file_path)
        mcs_list = []
        for i in range(0, len(dlFdSchedData_event)):
            mcs = int(dlFdSchedData_event[i][1]
                      [self.parameters.INDEX_dlFdSchedData_rrmDlUsedMcs - 1])
            if mcs not in mcs_list:
                mcs_list.append(mcs)
        return mcs_list
