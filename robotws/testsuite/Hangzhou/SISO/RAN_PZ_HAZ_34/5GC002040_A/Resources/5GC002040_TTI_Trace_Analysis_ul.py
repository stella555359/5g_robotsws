# -*- coding: utf-8 -*

"""
Author:         Ding Binmei developped for 19A, Wu Fangmin Modified for 19B
Contact Mail:   19A:binmei.ding@nokia-sbell.com, 19B:fangmin.wu@nokia-sbell.com
Description:    Event trace log analysis
                Column index may changes in different program, so when calling this file,
                you will need to set value for program. Currently supported versions is: 19B.
                it's default to 19B
"""
from check_csv_log import *
import logging


class ParametersSBTS21B(object):
    # Accuracy for digit number when doing calculation
    NDIGITS = 2
    INDEX_event = 1
    INDEX_ulFdSchedData_rnti = 41
    INDEX_ulFdSchedData_rrmUlUsedMcs = 44
    INDEX_ulFdSchedData_txNumber = 59
    INDEX_ulFdSchedData_ulHarqProcessIndex = 60
    INDEX_ulFdSchedData_reScaledCorrAvgSinr = 73
    INDEX_ulFdSchedData_numOfPrb = 54
    INDEX_ulFdSchedData_isDefaultMcsProposed = 46
    INDEX_ulLaDeltaSinr_rnti = 12
    INDEX_ulLaDeltaSinr_crcFb = 17
    INDEX_ulLaDeltaSinr_rrmDeltaSinr = 18
    INDEX_ulHarqRxData_rnti = 11
    INDEX_ulHarqRxData_ulHarqProcessIndex = 16
    INDEX_ulTdSchedSubcellData_rnti = 45
    INDEX_ulTdSchedSubcellData_resReqClassPrio = 46


class ParametersSBTS22R1(object):
    # Accuracy for digit number when doing calculation
    NDIGITS = 2
    INDEX_event = 1
    INDEX_ulFdSchedData_rnti = 41
    INDEX_ulFdSchedData_rrmUlUsedMcs = 44
    INDEX_ulFdSchedData_txNumber = 59
    INDEX_ulFdSchedData_ulHarqProcessIndex = 60
    INDEX_ulFdSchedData_reScaledCorrAvgSinr = 73
    INDEX_ulFdSchedData_numOfPrb = 54
    INDEX_ulFdSchedData_isDefaultMcsProposed = 46
    INDEX_ulLaDeltaSinr_rnti = 12
    INDEX_ulLaDeltaSinr_crcFb = 17
    INDEX_ulLaDeltaSinr_rrmDeltaSinr = 18
    INDEX_ulHarqRxData_rnti = 11
    INDEX_ulHarqRxData_ulHarqProcessIndex = 16
    INDEX_ulTdSchedSubcellData_rnti = 45
    INDEX_ulTdSchedSubcellData_resReqClassPrio = 46


class TTI_Trace_analysis_ul(object):
    def __init__(self, program=None):
        if program == "SBTS21B" or program is None:
            self.parameters = ParametersSBTS21B()
        elif program == "SBTS22R1":
            self.parameters = ParametersSBTS22R1()
        else:
            raise Exception("Invalid input for program.")

    def get_rnti(self, file_path):
        """
        Filter for event ulTdSchedSubcellData and find resReqClassPrio=30,
        which means rnti used for UL data traffic in initial transmission.
        :param file_path: Example input : XXX/XXX/XXX.csv
        :return: rnti value
        """
        try:
            ulTdSchedSubcellData_event_with_data_traffic = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.parameters.INDEX_event,
                             self.parameters.INDEX_ulTdSchedSubcellData_resReqClassPrio],
                expected_list=["ulTdSchedSubcellData: sfn", "30"])
        except LookupError:
            raise LookupError(
                "Fail to get rnti as no event found for ulTdSchedSubcellData with resReqClassPrio=30")
        rnti = ulTdSchedSubcellData_event_with_data_traffic[0][1][
            self.parameters.INDEX_ulTdSchedSubcellData_rnti - 1]
        logging.info("Current available rnti is: {}".format(rnti))
        return rnti

    def get_ulLaDeltaSinr_event(self, file_path):
        rnti = self.get_rnti(file_path=file_path)
        try:
            ulLaDeltaSinr_event = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[
                    self.parameters.INDEX_event,
                    self.parameters.INDEX_ulLaDeltaSinr_rnti],
                expected_list=["ulLaDeltaSinr: sfn", rnti])
        except LookupError:
            raise LookupError("No ulLaDeltaSinr event found")
        else:
            return ulLaDeltaSinr_event

    def get_ulHarqRxData_event(self, file_path):
        rnti = self.get_rnti(file_path=file_path)
        try:
            ulHarqRxData_event = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[
                    self.parameters.INDEX_event,
                    self.parameters.INDEX_ulHarqRxData_rnti],
                expected_list=["ulHarqRxData: sfn", rnti])
        except LookupError:
            raise LookupError("No ulHarqRxData event found")
        else:
            return ulHarqRxData_event

    def get_ulFdSchedData_event(self, file_path):
        rnti = self.get_rnti(file_path=file_path)
        try:
            ulFdSchedData_event = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[
                    self.parameters.INDEX_event,
                    self.parameters.INDEX_ulFdSchedData_rnti],
                expected_list=["ulFdSchedData: sfn", rnti])
        except LookupError:
            raise LookupError("No ulFdSchedData event found")
        else:
            return ulFdSchedData_event

    def get_related_ulLaDeltaSinr_event_row(
            self, row_num_ulFdSchedData_event, ulLaDeltaSinr_event):
        ulLaDeltaSinr_event_row = add_filter_to_matrix_in_given_range(
            ulLaDeltaSinr_event,
            None,
            row_num_ulFdSchedData_event - 1
        )[-1]
        return ulLaDeltaSinr_event_row

    def get_related_ulHarqRxData_event_row(
            self, row_num_ulLaDeltaSinr_event, ulHarqRxData_event):
        """
        Find harq_id from ulHarqRxData event(first row behind ulLaDeltaSinr event)
        :param row_num_ulLaDeltaSinr_event: Row number for ulLaDeltaSinr_event
        :param ulHarqRxData_event: matrix for ulHarqRxData event
        :return:
        """
        ulHarqRxData_event_row = add_filter_to_matrix_in_given_range(
            ulHarqRxData_event,
            row_num_ulLaDeltaSinr_event + 1,
            None
        )[0]
        return ulHarqRxData_event_row

    def get_related_ulFdSchedData_event_row(self, row_num_ulLaDeltaSinr_event,
                                            ulHarqRxData_event, ulFdSchedData_event):
        """
        1. Find harq_id from ulHarqRxData event(first row behind ulLaDeltaSinr event)
        2. Use harq_id to search the event ulFdSchedData, should be the row near event ulHarqRxData
        :param row_num_ulLaDeltaSinr_event:  Row number for ulLaDeltaSinr_event
        :param ulHarqRxData_event:
        :param ulFdSchedData_event:
        :return:
        """
        harq_id = self.get_related_ulHarqRxData_event_row(
            row_num_ulLaDeltaSinr_event=row_num_ulLaDeltaSinr_event,
            ulHarqRxData_event=ulHarqRxData_event)[1][self.parameters.INDEX_ulHarqRxData_ulHarqProcessIndex - 1]
        ulFdSchedData_event_row = add_filter_to_matrix_in_given_range(
            ulFdSchedData_event,
            None,
            row_num_ulLaDeltaSinr_event - 1,
            [self.parameters.INDEX_ulFdSchedData_ulHarqProcessIndex, [harq_id]]
        )[-1]
        return ulFdSchedData_event_row

    def get_rrmDeltaSinr_based_on_ulFdSchedData_event_row_num(
            self, row_num_ulFdSchedData_event, ulLaDeltaSinr_event):
        ulLaDeltaSinr_event_row = self.get_related_ulLaDeltaSinr_event_row(
            row_num_ulFdSchedData_event=row_num_ulFdSchedData_event,
            ulLaDeltaSinr_event=ulLaDeltaSinr_event
        )
        rrmDeltaSinr = float(
            ulLaDeltaSinr_event_row[1][self.parameters.INDEX_ulLaDeltaSinr_rrmDeltaSinr - 1])
        return rrmDeltaSinr

    def get_mcs_value_based_on_ulLaDeltaSinr_event_row_num(self, row_num_ulLaDeltaSinr_event,
                                                           ulHarqRxData_event, ulFdSchedData_event):
        """
        Get MCS value based on the row number in  ulLaDeltaSinr event
        :param row_num_ulLaDeltaSinr_event:
        :param ulHarqRxData_event:
        :param ulFdSchedData_event:
        :return: MCS value
        """
        ulFdSchedData_event_row = self.get_related_ulFdSchedData_event_row(
            row_num_ulLaDeltaSinr_event=row_num_ulLaDeltaSinr_event,
            ulHarqRxData_event=ulHarqRxData_event,
            ulFdSchedData_event=ulFdSchedData_event)
        mcs = int(
            ulFdSchedData_event_row[1][self.parameters.INDEX_ulFdSchedData_rrmUlUsedMcs - 1])
        print("ulLaDeltaSinr event row {},the related row number in ulFdSchedData event is {}".format(
            row_num_ulLaDeltaSinr_event, ulFdSchedData_event_row[0]))
        return mcs

    def is_mcs_reach_the_max_value(self, mcs, mcs_mapping_table):
        mcs_max = mcs_mapping_table[len(mcs_mapping_table) - 1]['mcs']
        if int(mcs) == int(mcs_max):
            return True
        else:
            return False

    def is_mcs_reach_the_min_value(self, mcs, mcs_mapping_table):
        mcs_min = mcs_mapping_table[0]['mcs']
        if int(mcs) == int(mcs_min):
            return True
        else:
            return False

    def get_mcs_by_reScaledCorrAvgSin_based_on_mcs_mapping_table(
            self, reScaledCorrAvgSin, mcs_mapping_table):
        """
        Search MCS mapping table and the mcs value based on reScaledCorrAvgSin value get from event ulFdSchedData
        A WA is added as for the event trace tool accuracy issue.
            When  reScaledCorrAvgSin ==   mcs_min_sinr, current mcs and previous mcs can also be passed
        :param reScaledCorrAvgSin: Value from event ulFdSchedData in column reScaledCorrAvgSin
        :param mcs_mapping_table: Should be a list, example input as bellow:
            [
                dict(mcs=18, sinr=10.3),
                dict(mcs=19, sinr=11.4)
            ]
        :return: a list for mcs
        """
        reScaledCorrAvgSin = float(reScaledCorrAvgSin)
        min_sinr = mcs_mapping_table[0]['sinr']
        max_sinr = mcs_mapping_table[len(mcs_mapping_table) - 1]['sinr']
        mcs = []
        if reScaledCorrAvgSin <= min_sinr:
            mcs.append(mcs_mapping_table[0]['mcs'])
        elif reScaledCorrAvgSin > max_sinr:
            mcs.append(mcs_mapping_table[len(mcs_mapping_table) - 1]['mcs'])
        elif reScaledCorrAvgSin == max_sinr:
            mcs.append(mcs_mapping_table[len(mcs_mapping_table) - 2]['mcs'])
            mcs.append(mcs_mapping_table[len(mcs_mapping_table) - 1]['mcs'])
        else:
            for i in range(0, len(mcs_mapping_table)):
                mcs_min_sinr = mcs_mapping_table[i]['sinr']
                mcs_max_sinr = mcs_mapping_table[i + 1]['sinr']
                if reScaledCorrAvgSin > mcs_min_sinr and reScaledCorrAvgSin < mcs_max_sinr:
                    mcs.append(mcs_mapping_table[i]['mcs'])
                    break
                elif reScaledCorrAvgSin == mcs_min_sinr:
                    mcs.append(mcs_mapping_table[i - 1]['mcs'])
                    mcs.append(mcs_mapping_table[i]['mcs'])
                    break
                else:
                    continue
        return mcs

    def is_message_retransmission_based_on_row_num_in_ulLaDeltaSinr_event(self, row_num_ulLaDeltaSinr_event,
                                                                          ulHarqRxData_event, ulFdSchedData_event):
        """
        If message is retransmission, then return True
        :param row_num_ulLaDeltaSinr_event:
        :param ulHarqRxData_event:
        :param ulFdSchedData_event:
        :return: True / False
        """
        ulFdSchedData_event_row = self.get_related_ulFdSchedData_event_row(
            row_num_ulLaDeltaSinr_event=row_num_ulLaDeltaSinr_event,
            ulHarqRxData_event=ulHarqRxData_event,
            ulFdSchedData_event=ulFdSchedData_event)
        txNumber = int(ulFdSchedData_event_row[1]
                       [self.parameters.INDEX_ulFdSchedData_txNumber - 1])
        logging.info(
            "ulLaDeltaSinr event row {},the related row number in ulFdSchedData event is {}".format(
                row_num_ulLaDeltaSinr_event,
                ulFdSchedData_event_row[0]))
        if txNumber == 1:
            return False
        else:
            return True

    def get_rrmDeltaSinrStepup_based_on_calculation(
            self, ullaDeltaSinrStepdown, ullaBlerTarget):
        """
        Calculate rrmDeltaSinrStepup based on NIDD parameter configured
        :param ullaDeltaSinrStepdown: NIDD parameter configured
        :param ullaBlerTarget: NIDD parameter configured
        :return:
        """
        rrmDeltaSinrStepup = float(
            ullaDeltaSinrStepdown * ullaBlerTarget / (1 - ullaBlerTarget))
        return rrmDeltaSinrStepup

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

    def verify_first_used_mcs_and_reScaledCorrAvgSinr_value_match_as_configured(
            self, mcs_mapping_table, rdAvgSinr, file_path):
        """
        1. First used MCS configured same as the first row in mcs mapping table
        2. First used reScaledCorrAvgSinr should be same as R&D parameter rdAvgSinr
        :param mcs_mapping_table:
        :param rdAvgSinr:
        :param file_path:
        :return:
        """
        ulFdSchedData_event = self.get_ulFdSchedData_event(file_path=file_path)
        cur_row = ulFdSchedData_event[0][0]
        mcs_act = ulFdSchedData_event[0][1][self.parameters.INDEX_ulFdSchedData_rrmUlUsedMcs - 1]
        mcs_exp = mcs_mapping_table[0]['mcs']
        reScaledCorrAvgSinr_act = ulFdSchedData_event[0][1][
            self.parameters.INDEX_ulFdSchedData_reScaledCorrAvgSinr - 1]

        self.verify_number_equal(
            act=mcs_act,
            exp=mcs_exp,
            msg="First used mcs is not the same as configured. Row num:{}".format(cur_row))
        self.verify_number_equal(
            act=reScaledCorrAvgSinr_act,
            exp=rdAvgSinr,
            msg="First used reScaledCorrAvgSinr is not the same as configured. Row num:{}".format(cur_row))

    def verify_ul_mcs_is_properly_used_based_on_mcs_mapping_table(
            self, mcs_mapping_table, file_path):
        """
        1. txNumber = 1, use current reScaledCorrAvgSin value to locate MCS value in mcs mapping table,
           then compare with current MCS
        2. txNumber >1 (Means retransmission), MCS value should be the same with the first transmission value
           How to locate first transmission row: Search previous records in ulFdSchedData event
           with current harq_id and txNumber=1, then get the nearest row
        :param mcs_mapping_table:
        :param file_path:
        :return:
        """
        ulFdSchedData_event = self.get_ulFdSchedData_event(file_path=file_path)
        for i in range(0, len(ulFdSchedData_event)):
            cur_row = ulFdSchedData_event[i][0]
            cur_mcs = int(ulFdSchedData_event[i][1]
                          [self.parameters.INDEX_ulFdSchedData_rrmUlUsedMcs - 1])
            cur_harq_id = ulFdSchedData_event[i][1][self.parameters.INDEX_ulFdSchedData_ulHarqProcessIndex - 1]
            cur_txNumber = int(
                ulFdSchedData_event[i][1][self.parameters.INDEX_ulFdSchedData_txNumber - 1])
            cur_reScaledCorrAvgSinr = ulFdSchedData_event[i][1][
                self.parameters.INDEX_ulFdSchedData_reScaledCorrAvgSinr - 1]
            if cur_txNumber == 1:
                mcs_exp = self.get_mcs_by_reScaledCorrAvgSin_based_on_mcs_mapping_table(
                    reScaledCorrAvgSin=cur_reScaledCorrAvgSinr,
                    mcs_mapping_table=mcs_mapping_table)
                if cur_mcs in mcs_exp:
                    pass
                else:
                    raise Exception(
                        "Verify UL MCS mapping table failed for first transmission. "
                        "Error row num:{}, Actual mcs value:{}. "
                        "Expected mcs value:{}".format(
                            cur_row, cur_mcs, mcs_exp))
            else:
                filter_with_txNum_and_harq_id = add_filter_to_matrix_in_given_range(
                    ulFdSchedData_event,
                    None,
                    cur_row - 1,
                    [self.parameters.INDEX_ulFdSchedData_txNumber, ['1']],
                    [self.parameters.INDEX_ulFdSchedData_ulHarqProcessIndex, [cur_harq_id]]
                )
                pre_row = filter_with_txNum_and_harq_id[-1][0]
                pre_mcs = int(
                    filter_with_txNum_and_harq_id[-1][1][self.parameters.INDEX_ulFdSchedData_rrmUlUsedMcs - 1])
                self.verify_number_equal(
                    act=cur_mcs,
                    exp=pre_mcs,
                    msg="Verify UL MCS mapping table failed for retransmission."
                        "Error row number: {}, filtered row number with txnum=1 and harq_id={} is {}".format(
                            cur_row,
                            cur_harq_id,
                            pre_row))

    def verify_calculation_of_delta_average_SINR(self, file_path, mcs_mapping_table,
                                                 ullaDeltaSinrStepdown, ullaBlerTarget):
        """
        Delta average SINR won't be updated in following scenarios:
        1. current message is retransmission
        2. Current CRC==OK, and current MCS reach the MAX value
        3. Current CRC==NOK, and current MCS reach the min value
        4. Current CRC==DTX

        Delta average SINR will increase: rrmDeltaSinrExp = pre_rrmDeltaSinr + rrmDeltaSinrStepup
        5. Current CRC==OK and current MCS didn't reach the max value

        Delta average SINR will decrease: rrmDeltaSinrExp = pre_rrmDeltaSinr - ullaDeltaSinrStepdown
        6. Current CRC==NOK, and current MCS didn't reach the min value

        :param file_path: Event trace log file path with CSV format
        :param mcs_mapping_table:
        :param ullaDeltaSinrStepdown: Configured NIDD param from webui
        :param ullaBlerTarget: Configured NIDD param from webui
        :return:
        """
        ulLaDeltaSinr_event = self.get_ulLaDeltaSinr_event(file_path=file_path)
        ulHarqRxData_event = self.get_ulHarqRxData_event(file_path=file_path)
        ulFdSchedData_event = self.get_ulFdSchedData_event(file_path=file_path)
        rrmDeltaSinrStepup = self.get_rrmDeltaSinrStepup_based_on_calculation(
            ullaDeltaSinrStepdown, ullaBlerTarget)
        for i in range(0, len(ulLaDeltaSinr_event)):
            cur_row = ulLaDeltaSinr_event[i][0]
            cur_crcFb = ulLaDeltaSinr_event[i][1][self.parameters.INDEX_ulLaDeltaSinr_crcFb - 1]
            cur_mcs = self.get_mcs_value_based_on_ulLaDeltaSinr_event_row_num(
                row_num_ulLaDeltaSinr_event=cur_row,
                ulHarqRxData_event=ulHarqRxData_event,
                ulFdSchedData_event=ulFdSchedData_event)
            cur_rrmDeltaSinr = float(
                ulLaDeltaSinr_event[i][1][self.parameters.INDEX_ulLaDeltaSinr_rrmDeltaSinr - 1])
            is_retransmission = self.is_message_retransmission_based_on_row_num_in_ulLaDeltaSinr_event(
                row_num_ulLaDeltaSinr_event=cur_row,
                ulHarqRxData_event=ulHarqRxData_event,
                ulFdSchedData_event=ulFdSchedData_event)
            if i == 0:
                pre_row = 0
                pre_rrmDeltaSinr = 0

            else:
                pre_row = ulLaDeltaSinr_event[i - 1][0]
                pre_rrmDeltaSinr = float(
                    ulLaDeltaSinr_event[i - 1][1][self.parameters.INDEX_ulLaDeltaSinr_rrmDeltaSinr - 1])
            logging.debug(
                "pre_row={},pre_rrmDeltaSinr={},cur_row={},cur_crcFb={},cur_mcs={}"
                "cur_rrmDeltaSinr={},is_retransmission={}".format(
                    pre_row,
                    pre_rrmDeltaSinr,
                    cur_row,
                    cur_crcFb,
                    cur_mcs,
                    cur_rrmDeltaSinr,
                    is_retransmission))
            if is_retransmission:
                rrmDeltaSinrExp = pre_rrmDeltaSinr
            else:
                if cur_crcFb == "OK" and self.is_mcs_reach_the_max_value(
                        mcs=cur_mcs, mcs_mapping_table=mcs_mapping_table) is False:
                    rrmDeltaSinrExp = pre_rrmDeltaSinr + rrmDeltaSinrStepup

                elif cur_crcFb == "NOK" and \
                        self.is_mcs_reach_the_min_value(mcs=cur_mcs, mcs_mapping_table=mcs_mapping_table) is False:
                    rrmDeltaSinrExp = pre_rrmDeltaSinr - ullaDeltaSinrStepdown
                elif (cur_crcFb == "DTX") or \
                    (cur_crcFb == "OK" and
                     self.is_mcs_reach_the_max_value(mcs=cur_mcs, mcs_mapping_table=mcs_mapping_table)) or \
                    (cur_crcFb == "NOK" and
                     self.is_mcs_reach_the_min_value(mcs=cur_mcs, mcs_mapping_table=mcs_mapping_table)):
                    rrmDeltaSinrExp = pre_rrmDeltaSinr
                else:
                    raise Exception(
                        "Current crcFb:{} is not recognized. Please check manually. Row number:{}". format(
                            cur_crcFb, cur_row))
            self.verify_number_equal(
                act=cur_rrmDeltaSinr,
                exp=rrmDeltaSinrExp,
                msg="Calculation for delta average SINR is incorrect. i={},"
                "ulLaDeltaSinr event Row num: {}, previous row num is: {}".format(i, cur_row, pre_row))

    def verify_calculation_of_corrected_average_SINR(
            self, file_path, rdAvgSinr):
        """
        1. txNumber=1, reScaledCorrAvgSinr_exp = rdAvgSinr + rrmDeltaSinr
        2. txNumber>1, reScaledCorrAvgSinr_exp = previous_reScaledCorrAvgSinr
        :param file_path: Event trace log file path with CSV format
        :param rdAvgSinr: R&D parameter defined in swconfig file
        :return: None
        """
        ulFdSchedData_event = self.get_ulFdSchedData_event(file_path=file_path)
        ulLaDeltaSinr_event = self.get_ulLaDeltaSinr_event(file_path=file_path)
        for i in range(0, len(ulFdSchedData_event)):
            cur_row = ulFdSchedData_event[i][0]
            cur_txNumber = int(
                ulFdSchedData_event[i][1][self.parameters.INDEX_ulFdSchedData_txNumber - 1])
            cur_reScaledCorrAvgSinr = float(
                ulFdSchedData_event[i][1][self.parameters.INDEX_ulFdSchedData_reScaledCorrAvgSinr - 1])
            if i == 0:
                reScaledCorrAvgSinr_exp = rdAvgSinr
            else:
                pre_reScaledCorrAvgSinr = float(
                    ulFdSchedData_event[i - 1][1][self.parameters.INDEX_ulFdSchedData_reScaledCorrAvgSinr - 1])
                if cur_txNumber > 1:
                    reScaledCorrAvgSinr_exp = pre_reScaledCorrAvgSinr
                elif cur_txNumber == 1:
                    rrmDeltaSinr = self.get_rrmDeltaSinr_based_on_ulFdSchedData_event_row_num(
                        row_num_ulFdSchedData_event=cur_row, ulLaDeltaSinr_event=ulLaDeltaSinr_event)
                    reScaledCorrAvgSinr_exp = rdAvgSinr + rrmDeltaSinr
                else:
                    raise Exception(
                        "txNumber: {} is not >=1, Error row number in ulFdSchedData event is: {}".format(
                            cur_txNumber, cur_row))
            self.verify_number_equal(
                act=cur_reScaledCorrAvgSinr,
                exp=reScaledCorrAvgSinr_exp,
                msg="Calculation for corrected average SINR failed. i={}, "
                "txNumber={}, current row number={}".format(i, cur_txNumber, cur_row))

    def _get_list_value_sorted(self, list_input):
        new_list = []
        for list_value in list_input:
            new_list.append(int(list_value))
        new_list.sort()
        return new_list

    def verify_ul_data_transmission_is_done_with_highest_mcs(
            self, file_path, mcs_mapping_table):
        ulFdSchedData_event = self.get_ulFdSchedData_event(file_path=file_path)
        mcs_list = get_unique_values_in_column(
            matrix=ulFdSchedData_event,
            column_number=self.parameters.INDEX_ulFdSchedData_rrmUlUsedMcs)
        mcs_max_act = self._get_list_value_sorted(list_input=mcs_list)[-1]
        mcs_max_exp = mcs_mapping_table[len(mcs_mapping_table) - 1]['mcs']
        logging.debug("Actual max MCS value: {}".format(mcs_max_act))
        if mcs_max_exp >= 27:
            logging.info(
                "Expect MCS {} is >=27, skip this checkpoint".format(mcs_max_exp))
        else:
            logging.info(
                "Expect highest MCS {} is <27, do the verification".format(mcs_max_exp))
            self.verify_number_equal(
                act=mcs_max_act,
                exp=mcs_max_exp,
                msg="UL data transmission does not reach the highest mcs")
            logging.info(
                "Verify passed. UL transmission has reached the highest MCS")

    def calculate_ul_bler(self, file_path):
        """
        Formula of Bler :  (txNum_with_2_event - txNum_with_1_event_with_dtx)
                           /(txNum_with_1_event - txNum_with_1_event_with_dtx)
        :param file_path:
        :return:
        """
        # Count DTX when txNum=1(DTX need to be excluded when calculating bler)
        ulLaDeltaSinr_event = self.get_ulLaDeltaSinr_event(file_path=file_path)
        ulHarqRxData_event = self.get_ulHarqRxData_event(file_path=file_path)
        ulFdSchedData_event = self.get_ulFdSchedData_event(file_path=file_path)
        try:
            ulLaDeltaSinr_event_with_dtx = add_filters_to_matrix(
                ulLaDeltaSinr_event, [self.parameters.INDEX_ulLaDeltaSinr_crcFb, ['DTX']])
            ulFdSchedData_event_row_with_dtx = []
            for i in range(0, len(ulLaDeltaSinr_event_with_dtx)):
                cur_row = ulLaDeltaSinr_event_with_dtx[i][0]
                ulFdSchedData_event_row = self.get_related_ulFdSchedData_event_row(
                    row_num_ulLaDeltaSinr_event=cur_row,
                    ulHarqRxData_event=ulHarqRxData_event,
                    ulFdSchedData_event=ulFdSchedData_event)
                ulFdSchedData_event_row_with_dtx.append(
                    ulFdSchedData_event_row)
            txNum_with_1_event_with_dtx = add_filters_to_matrix(
                ulFdSchedData_event_row_with_dtx,
                [self.parameters.INDEX_ulFdSchedData_txNumber, ['1']])
            count_txNum_with_1_with_dtx = len(txNum_with_1_event_with_dtx)
        except LookupError:
            logging.debug("No DTX found during first transmission")
            count_txNum_with_1_with_dtx = 0
        # Count txNum with 1
        try:
            txNum_with_1_event = add_filters_to_matrix(
                ulFdSchedData_event,
                [self.parameters.INDEX_ulFdSchedData_txNumber, ['1']])
            count_txNum_with_1 = len(txNum_with_1_event)
        except LookupError:
            logging.debug(
                "No data found with txNumber=1 in ulFdSchedData event")
            count_txNum_with_1 = 0
        # Count txNum with 2
        try:
            txNum_with_2_event = add_filters_to_matrix(
                ulFdSchedData_event,
                [self.parameters.INDEX_ulFdSchedData_txNumber, ['2']])
            count_txNum_with_2 = len(txNum_with_2_event)
        except LookupError:
            logging.debug(
                "No data found with txNumber=2 in ulFdSchedData event")
            count_txNum_with_2 = 0
        logging.debug("Calculate UL bler with event trace. count_txNum_with_2={}, count_txNum_with_1={}, "
                      "count_txNum_with_1_with_dtx={}".format(count_txNum_with_2,
                                                              count_txNum_with_1,
                                                              count_txNum_with_1_with_dtx))
        ul_bler = float(count_txNum_with_2 - count_txNum_with_1_with_dtx) / \
            float(count_txNum_with_1 - count_txNum_with_1_with_dtx)
        logging.debug("ul_bler={}".format(ul_bler))
        return ul_bler

    def calculate_ul_bler(self, file_path):
        """
        Formula of Bler :  (txNum_with_2_event - txNum_with_1_event_with_dtx)
                           /(txNum_with_1_event - txNum_with_1_event_with_dtx)
        :param file_path:
        :return:
        """
        # Count DTX when txNum=1(DTX need to be excluded when calculating bler)
        ulLaDeltaSinr_event = self.get_ulLaDeltaSinr_event(file_path=file_path)
        ulHarqRxData_event = self.get_ulHarqRxData_event(file_path=file_path)
        ulFdSchedData_event = self.get_ulFdSchedData_event(file_path=file_path)
        try:
            ulLaDeltaSinr_event_with_dtx = add_filters_to_matrix(
                ulLaDeltaSinr_event, [self.parameters.INDEX_ulLaDeltaSinr_crcFb, ['DTX']])
            ulFdSchedData_event_row_with_dtx = []
            for i in range(0, len(ulLaDeltaSinr_event_with_dtx)):
                cur_row = ulLaDeltaSinr_event_with_dtx[i][0]
                ulFdSchedData_event_row = self.get_related_ulFdSchedData_event_row(
                    row_num_ulLaDeltaSinr_event=cur_row,
                    ulHarqRxData_event=ulHarqRxData_event,
                    ulFdSchedData_event=ulFdSchedData_event)
                ulFdSchedData_event_row_with_dtx.append(
                    ulFdSchedData_event_row)
            txNum_with_1_event_with_dtx = add_filters_to_matrix(
                ulFdSchedData_event_row_with_dtx,
                [self.parameters.INDEX_ulFdSchedData_txNumber, ['1']])
            count_txNum_with_1_with_dtx = len(txNum_with_1_event_with_dtx)
        except LookupError:
            logging.debug("No DTX found during first transmission")
            count_txNum_with_1_with_dtx = 0
        # Count txNum with 1
        try:
            txNum_with_1_event = add_filters_to_matrix(
                ulFdSchedData_event,
                [self.parameters.INDEX_ulFdSchedData_txNumber, ['1']])
            count_txNum_with_1 = len(txNum_with_1_event)
        except LookupError:
            logging.debug(
                "No data found with txNumber=1 in ulFdSchedData event")
            count_txNum_with_1 = 0
        # Count txNum with 2
        try:
            txNum_with_2_event = add_filters_to_matrix(
                ulFdSchedData_event,
                [self.parameters.INDEX_ulFdSchedData_txNumber, ['2']])
            count_txNum_with_2 = len(txNum_with_2_event)
        except LookupError:
            logging.debug(
                "No data found with txNumber=2 in ulFdSchedData event")
            count_txNum_with_2 = 0
        logging.debug("Calculate UL bler with event trace. count_txNum_with_2={}, count_txNum_with_1={}, "
                      "count_txNum_with_1_with_dtx={}".format(count_txNum_with_2,
                                                              count_txNum_with_1,
                                                              count_txNum_with_1_with_dtx))
        ul_bler = float(count_txNum_with_2 - count_txNum_with_1_with_dtx) / \
            float(count_txNum_with_1 - count_txNum_with_1_with_dtx)
        logging.debug("ul_bler={}".format(ul_bler))
        return ul_bler

    def get_minimum_num_of_prb(self, file_path):
        """
        Get the minimum number of PRB in ulFdSchedData event. If not found will return -1
        :param file_path:
        :return:
        """
        ulFdSchedData_event = self.get_ulFdSchedData_event(file_path=file_path)
        try:
            numOfPrb_list = get_unique_values_in_column(
                matrix=ulFdSchedData_event,
                column_number=self.parameters.INDEX_ulFdSchedData_numOfPrb)
            minimum_num_of_prb = self._get_list_value_sorted(
                list_input=numOfPrb_list)[0]
        except LookupError:
            minimum_num_of_prb = -1
        finally:
            return minimum_num_of_prb

    def get_ul_average_mcs(self, file_path):
        ulFdSchedData_event = self.get_ulFdSchedData_event(file_path=file_path)
        ulFdSchedData_event_with_la_activate = add_filters_to_matrix(
            ulFdSchedData_event,
            [self.parameters.INDEX_ulFdSchedData_isDefaultMcsProposed, ['0']])
        sum_mcs = 0
        for i in range(0, len(ulFdSchedData_event_with_la_activate)):
            mcs = int(
                ulFdSchedData_event_with_la_activate[i][1][self.parameters.INDEX_ulFdSchedData_rrmUlUsedMcs - 1])
            sum_mcs = sum_mcs + mcs
        avg_mcs = float(sum_mcs) / len(ulFdSchedData_event_with_la_activate)
        return avg_mcs

    def is_value_in_range(self, min, max, value):
        if value > min and value < max:
            return True
        else:
            return False
