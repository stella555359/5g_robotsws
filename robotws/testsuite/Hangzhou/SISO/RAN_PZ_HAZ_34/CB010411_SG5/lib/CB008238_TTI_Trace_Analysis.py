# -*- coding: utf-8 -*

"""
Author:         Zhang Xuewen developped for 22R4
Contact Mail:   22R4:xuewen.zhang@nokia-sbell.com
Description:    Event trace log analysis
                Column index may changes in different program, so when calling this file,
                you will need to set value for program. Currently supported versions are:  22R4
                If program is not set, it's default to 22R4
"""
import logging
import math
import traceback
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.check_csv_log import *


class TTI_Trace_analysis_dl(object):
    def __init__(self, file_path):
        self.INDEX_event = 1
        self.file_path = file_path
        self.INDEX_dlFdSchedData_numOfPrb = self.get_column_value_index_from_event(
            "dlFdSchedData", "numOfPrb"
        )
        self.INDEX_dlFdSchedData_rnti = self.get_column_value_index_from_event(
            "dlFdSchedData", "rnti"
        )
        try:
            self.INDEX_dlPreSchedData_rnti = self.get_column_value_index_from_event(
                "dlPreSchedData", "rnti"
            )
        except ValueError as e:
            logging.info("rnti  not found in dlPreSchedData!{}".format(e))
            self.INDEX_dlPreSchedData_rnti = 0

        try:
            self.INDEX_dlPreSchedData_highestClassPriority = (
                self.get_column_value_index_from_event(
                    "dlPreSchedData", "highestClassPriority"
                )
            )
        except ValueError as e:
            logging.info("highestClassPriority not found in dlPreSchedData!{}".format(e))
            self.INDEX_dlPreSchedData_highestClassPriority = 0

        self.INDEX_dlTdSchedSubcellData_resReqClassPrio = (
            self.get_column_value_index_from_event(
                "dlTdSchedSubcellData", "resReqClassPrio"
            )
        )
        self.INDEX_dlTdSchedSubcellData_rnti = (
            self.INDEX_dlTdSchedSubcellData_resReqClassPrio - 1
        )

    def get_rnti(self):
        """
        Filter for event dlTdSchedSubcellData and find resReqClassPrio=40,
        which means rnti used for DL data traffic in initial transmission.
        :param file_path: Example input : XXX/XXX/XXX.csv
        :return: rnti value
        """
        try:
            dlTdSchedSubcellData_event_with_data_traffic = (
                get_lines_with_multiple_column_filter(
                    file_path=self.file_path,
                    column_list=[
                        self.INDEX_event,
                        self.INDEX_dlTdSchedSubcellData_resReqClassPrio,
                    ],
                    expected_list=["dlTdSchedSubcellData", "40"],
                )
            )
        except LookupError:
            raise LookupError(
                "Fail to get rnti as no event found for dlTdSchedSubcellData with resReqClassPrio=40"
            )
        rnti = dlTdSchedSubcellData_event_with_data_traffic[
            len(dlTdSchedSubcellData_event_with_data_traffic) - 1
        ][1][self.INDEX_dlTdSchedSubcellData_rnti - 1]
        logging.info("Current available rnti is: {}".format(rnti))
        print("Current available rnti is: {}".format(rnti))
        print(
            "INDEX_dlTdSchedSubcellData_rnti is: {}".format(
                self.INDEX_dlTdSchedSubcellData_rnti
            )
        )
        print(dlTdSchedSubcellData_event_with_data_traffic[0][1])
        print(
            "INDEX_dlTdSchedSubcellData_resReqClassPrio is: {}".format(
                self.INDEX_dlTdSchedSubcellData_resReqClassPrio
            )
        )
        return rnti

    def get_dlFdSchedData_event(self):
        rnti = self.get_rnti()
        print(rnti, self.INDEX_dlFdSchedData_rnti)
        try:
            dlFdSchedData_event = get_lines_with_multiple_column_filter(
                file_path=self.file_path,
                column_list=[self.INDEX_event, self.INDEX_dlFdSchedData_rnti],
                expected_list=["dlFdSchedData", rnti],
            )
        except LookupError:
            raise LookupError("No dlFdSchedData event found")
        else:
            return dlFdSchedData_event

    def get_dl_average_numOfPrb(self):
        dlFdSchedData_event = self.get_dlFdSchedData_event()
        sum_numOfPrb = 0
        print("dlFdSchedData_event:{}".format(len(dlFdSchedData_event)))
        for i in range(0, len(dlFdSchedData_event)):
            numOfPrb = int(
                dlFdSchedData_event[i][1][self.INDEX_dlFdSchedData_numOfPrb - 1]
            )
            sum_numOfPrb = sum_numOfPrb + numOfPrb
        avg = math.floor(float(sum_numOfPrb) / len(dlFdSchedData_event))
        logging.info("average numOfPrb is:{}".format(avg))
        print("average numOfPrb is:{}".format(avg))
        return avg

    def if_avg_numOfPrb_morethan_63(self):
        return self.get_dl_average_numOfPrb() >= 63

    def if_highestClassPriority17_in_dlPreSchedData(self, rnti=None):
        try:
            rnti = self.get_rnti() if rnti is None else rnti
            logging.info(
                "INDEX_dlPreSchedData_rnti:{} ".format(self.INDEX_dlPreSchedData_rnti)
            )
            dlPreSchedData_event = get_lines_with_multiple_column_filter(
                file_path=self.file_path,
                column_list=[
                    self.INDEX_event,
                    self.INDEX_dlPreSchedData_highestClassPriority,
                    self.INDEX_dlPreSchedData_rnti,
                ],
                expected_list=["dlPreSchedData", "17", rnti],
            )
            print(dlPreSchedData_event[0][1])
        except LookupError:
            # raise LookupError("No dlPreSchedData event found")
            logging.info(
                "No dlPreSchedData event found for which highestClassPriority=17 "
            )
            print("No dlPreSchedData event found for which highestClassPriority=17 ")
            return False
        else:
            return True

    def reassign_event_column_number(self, event, col_filter=None):
        """
        Author: Ren Biyao
        Get column number base on event
        """
        column_list = []
        last_col_num = None
        with open(self.file_path) as f:
            lines = f.readlines()
            for line in lines:
                if event in line:
                    if col_filter:
                        if col_filter in line:
                            column_list = line.split(",")
                            break
                    else:
                        column_list = line.split(",")
                        break
        for i, value in enumerate(column_list):
            if value.isdigit():
                last_col_num = i
                break
        return column_list, last_col_num

    def get_column_value_index_from_event(self, event, column_name):
        """
        Author: Zhang xuewen
        find column number by column name from event, if multi same column name,
        only return the first index
        :param column_name:
        :param event:
        :return:
        """
        event_column_list, last_col_num = self.reassign_event_column_number(event)
        column_index = event_column_list.index(column_name) + 1
        column_value_index = last_col_num + column_index
        return column_value_index

    def check_cs1size_cs2size_in_event(
        self, event="dlTdSchedSubcellData", expected_cs1size=2, expected_cs2size=2
    ):
        """
        Author: Zhang xuewen
        check cs1Size cs2Size in event
        :param expected_cs1size:
        :param expected_cs2size:
        :param event:
        :return: return rnti list if exist event, else return None
        """
        column1 = "cs1Size"
        column2 = "cs2Size"
        event_column_list, last_col_num = self.reassign_event_column_number(event, column2)
        column1_index = event_column_list.index(column1) + 1
        cs1Size_value_index = last_col_num + column1_index
        column2_index = event_column_list.index(column2) + 1
        cs2Size_value_index = last_col_num + column2_index
        try:
            event_data = get_lines_with_multiple_column_filter(
                file_path=self.file_path,
                column_list=[
                    self.INDEX_event,
                    cs1Size_value_index,
                    cs2Size_value_index,
                ],
                expected_list=[event, "2", "2"],
            )
        except LookupError:
            logging.error("No event:{} found!".format(event))
            return None
        rnti_list = []
        for i in range(0, len(event_data)):
            rnti_list.append(event_data[i][1][self.INDEX_dlTdSchedSubcellData_rnti - 1])
        all_rnti = set(rnti_list)
        logging.debug(
            "All rnti in dlTdSchedSubcellData with cs1Size=2: {}".format(all_rnti)
        )
        if len(all_rnti) < 2:
            logging.warning("UE2 not found!")
        return all_rnti

    def check_highestClassPriority17_for_mutiUE(self, rnti_list):
        """
        Author: Zhang xuewen
        check if all rnti have highestClassPriority = 17 in event dlPreSchedData
        :param rnti_list:
        :return: False or True
        """
        for rnti in rnti_list:
            if not self.if_highestClassPriority17_in_dlPreSchedData(rnti):
                rnti_list.remove(rnti)
                logging.warning(
                    "rnti:{} not have highestClassPriority=17 in dlPreSchedData!".format(
                        rnti
                    )
                )
        if len(rnti_list) < 2:
            return False
        else:
            return True

    def check_dlDtxOptimData_for_mutiUE(self, rnti_list, event="dlDtxOptimData"):
        """
        Author: Zhang xuewen
        check ueList0 and ueList1 should have RNTI in event dlDtxOptimData
        :param event:
        :param rnti_list:
        :return: False or True
        """
        column1 = "ueList_[0]"
        column2 = "ueList_[1]"
        event_column_list, last_col_num = self.reassign_event_column_number(event, column2)
        column1_index = event_column_list.index(column1) + 1
        column1_value_index = last_col_num + column1_index
        column2_index = event_column_list.index(column2) + 1
        column2_value_index = last_col_num + column2_index
        try:
            event_data = get_lines_with_multiple_column_filter(
                file_path=self.file_path,
                column_list=[self.INDEX_event],
                expected_list=[event],
            )
        except LookupError:
            logging.error("No event:{} found!".format(event))
            return False
        for i in range(len(event_data)):
            if (
                event_data[i][1][column1_value_index - 1] in rnti_list
                and event_data[i][1][column2_value_index - 1] in rnti_list
            ):
                return True
        return False

    def check_dlFdSchedData_for_mutiUE(self, rnti_list, event="dlFdSchedData"):
        """
        Author: Zhang xuewen
        check if have 2 rnti in same sfn and same slot in event dlFdSchedData
        :param event:
        :param rnti_list:
        :return: False or True
        """
        column1 = "sfn"
        column2 = "slot"
        column3 = "rnti"
        event_column_list, last_col_num = self.reassign_event_column_number(event)
        try:
            sfn_value_index = last_col_num + event_column_list.index(column1) + 1
        except Exception as e:
            sfn_value_index = last_col_num + 1
            traceback.print_exc()
            print(e)
        slot_value_index = last_col_num + event_column_list.index(column2) + 1
        rnti_value_index = last_col_num + event_column_list.index(column3) + 1
        try:
            event_data = get_lines_with_multiple_column_filter(
                file_path=self.file_path,
                column_list=[self.INDEX_event],
                expected_list=[event],
            )
        except LookupError:
            logging.error("No event:{} found!".format(event))
            return False
        for i in range(len(event_data)):
            if i + 1 < len(event_data):
                if (
                    event_data[i][1][sfn_value_index - 1]
                    == event_data[i + 1][1][sfn_value_index - 1]
                    and event_data[i][1][slot_value_index - 1]
                    == event_data[i + 1][1][slot_value_index - 1]
                    and event_data[i][1][rnti_value_index - 1]
                    != event_data[i + 1][1][rnti_value_index - 1]
                ):
                    return True
        return False

    def check_dtxPrbThreshold_in_dlDtxOptimData(self, dtxPrbThreshold=0.1, event="dlDtxOptimData"):
        """
        Author: Zhang xuewen
        check if dlDtxOptimData.prbDemandInfo.largeBwpPrbs/dlDtxOptimData.prbAvailableInfo.largeBwpPrbs
        =48/273=17.58% > dtxPrbThreshold=10%, then dlDtxOptimData.dlDtxOptimEvent=DTXPRBTHRES
        :param event:
        :param dtxPrbThreshold:
        :return: False or True
        """
        column_name = "largeBwpPrbs"
        event_column_list, last_col_num = self.reassign_event_column_number(event)
        column1_index = event_column_list.index(column_name) + 1
        prbAvailableInfo_largeBwpPrbs = last_col_num + column1_index
        column2_index = event_column_list.index(column_name, column1_index) + 1
        prbDemandInfo_largeBwpPrbs = last_col_num + column2_index
        dlDtxOptimEvent_index = event_column_list.index("dlDtxOptimEvent") + 1
        dlDtxOptimEvent_value_index = last_col_num + dlDtxOptimEvent_index
        try:
            event_data = get_lines_with_multiple_column_filter(
                file_path=self.file_path,
                column_list=[self.INDEX_event, dlDtxOptimEvent_value_index],
                expected_list=[event, "DTXPRBTHRES"],
            )
        except LookupError:
            logging.error("No event:{} found!".format(event))
            return False
        for i in range(len(event_data)):
            if (
                int(event_data[i][1][prbDemandInfo_largeBwpPrbs - 1]) /
                    int(event_data[i][1][prbAvailableInfo_largeBwpPrbs - 1]) > dtxPrbThreshold
            ):
                logging.info("prbDemandInfo.largeBwpPrbs={}/prbAvailableInfo.largeBwpPrbs={}".format(
                    event_data[i][1][prbDemandInfo_largeBwpPrbs - 1],
                    event_data[i][1][prbAvailableInfo_largeBwpPrbs - 1]))
                return True
        return False

    def check_dlDtxOptimEvent_in_dlDtxOptimData(
            self, event="dlDtxOptimData", dlDtxOptimEvent_value="CS1SIZETHRES"):
        """
        Author: Zhang xuewen
        check When num of dlDtxOptimData.ueList >= rdDtxCS1SizeThreshold=2
        Then dlDtxOptimData.dlDtxOptimEvent=CS1SIZETHRES
        :param dlDtxOptimEvent_value:
        :param event:
        :return: return rnti list if exist event, else return None
        """
        column1 = "ueList_[0]"
        column2 = "ueList_[1]"
        event_column_list, last_col_num = self.reassign_event_column_number(event)
        column1_index = event_column_list.index(column1) + 1
        column1_value_index = last_col_num + column1_index
        column2_index = event_column_list.index(column2) + 1
        column2_value_index = last_col_num + column2_index
        dlDtxOptimEvent_index = event_column_list.index("dlDtxOptimEvent") + 1
        dlDtxOptimEvent_value_index = last_col_num + dlDtxOptimEvent_index
        try:
            event_data = get_lines_with_multiple_column_filter(
                file_path=self.file_path,
                column_list=[self.INDEX_event, dlDtxOptimEvent_value_index],
                expected_list=[event, dlDtxOptimEvent_value],
            )
        except LookupError:
            logging.error("No event:{} found!".format(event))
            return False
        for i in range(len(event_data)):
            try:
                if (
                        int(event_data[i][1][column1_value_index - 1]) > 0
                        and int(event_data[i][1][column2_value_index - 1]) > 0
                ):
                    logging.info("ueList_[0]:{},ueList_[1]:{}".format(
                        event_data[i][1][column1_value_index - 1],
                        event_data[i][1][column2_value_index - 1]))
                    return True
            except ValueError:
                logging.error("ueList_[0]:{},ueList_[1]:{}".format(
                    event_data[i][1][column1_value_index - 1],
                    event_data[i][1][column2_value_index - 1]))
        return False

    def check_DtxCellNbUeCs1ThresholdHigh(
            self, rdDtxCellNbUeCs1ThresholdHigh=0.03,
            event="DlDtxCellEnablingData",
            dlDtxCellEnablingEvent="DTXCELLDISABLING"):
        """
        Author: Zhang xuewen
        When DlDtxCellEnablingData.dtxCellNbUeCs1Ratio=dlTdSchedSubcellData.cs1Size/dlLoadControlData.cs1ListAvg
        =2/50=4% >= rdDtxCellNbUeCs1ThresholdHigh_percent=3%
        Then DlDtxCellEnablingData.dlDtxCellEnablingEvent=DTXCELLDISABLING
        :param dlDtxCellEnablingEvent:
        :param event:
        :return: return rnti list if exist event, else return None
        """
        event_column_list, last_col_num = self.reassign_event_column_number(event)
        dtxCellNbUeCs1Ratio_index = event_column_list.index("dtxCellNbUeCs1Ratio") + 1
        dtxCellNbUeCs1Ratio_value_index = last_col_num + dtxCellNbUeCs1Ratio_index
        dlDtxCellEnablingEvent_index = event_column_list.index("dlDtxCellEnablingEvent") + 1
        dlDtxCellEnablingEvent_value_index = last_col_num + dlDtxCellEnablingEvent_index
        try:
            event_data = get_lines_with_multiple_column_filter(
                file_path=self.file_path,
                column_list=[self.INDEX_event, dlDtxCellEnablingEvent_value_index],
                expected_list=[event, dlDtxCellEnablingEvent],
            )
        except LookupError:
            logging.error("No event:{} found!".format(event))
            return False
        logging.info("dtxCellNbUeCs1Ratio_value:{},rdDtxCellNbUeCs1ThresholdHigh:{}".format(
            event_data[0][1][dtxCellNbUeCs1Ratio_value_index - 1], rdDtxCellNbUeCs1ThresholdHigh))
        if (
            int(event_data[0][1][dtxCellNbUeCs1Ratio_value_index - 1])/100 >= rdDtxCellNbUeCs1ThresholdHigh
        ):
            return True
        else:
            return False

    def check_DtxCellNbUeCs1ThresholdLow(
            self, rdDtxCellNbUeCs1ThresholdLow=0.03,
            event="DlDtxCellEnablingData",
            dlDtxCellEnablingEvent="DTXCELLENABLING"):
        """
        Author: Zhang xuewen
        When DlDtxCellEnablingData.dtxCellNbUeCs1Ratio=dlTdSchedSubcellData.cs1Size/dlLoadControlData.cs1ListAvg
        =1/50=2% <= rdDtxCellNbUeCs1ThresholdLow_percent=3% AND
        DlDtxCellEnablingData.dlDtxCellEnablingEvent.DTXCELLENABLINGSTARTTIMER=rdDtxCellEnablingTime_ms=100ms
        Then DlDtxCellEnablingData.dlDtxCellEnablingEvent=DTXCELLENABLING
        :param dlDtxCellEnablingEvent:
        :param event:
        :return: return rnti list if exist event, else return None
        """
        event_column_list, last_col_num = self.reassign_event_column_number(event)
        dlDtxCellEnablingEvent_index = event_column_list.index("dlDtxCellEnablingEvent") + 1
        try:
            sfn_index = event_column_list.index("sfn") + 1
        except Exception as e:
            sfn_index = 1
            traceback.print_exc()
            print(e)
        sfn_value_index = last_col_num + sfn_index
        dlDtxCellEnablingEvent_value_index = last_col_num + dlDtxCellEnablingEvent_index
        dtxCellNbUeCs1Ratio_index = event_column_list.index("dtxCellNbUeCs1Ratio") + 1
        dtxCellNbUeCs1Ratio_value_index = last_col_num + dtxCellNbUeCs1Ratio_index
        try:
            event_data = get_lines_with_multiple_column_filter(
                file_path=self.file_path,
                column_list=[self.INDEX_event, dlDtxCellEnablingEvent_value_index],
                expected_list=[event, dlDtxCellEnablingEvent],
            )
        except LookupError:
            logging.error("No event:{} found!".format(event))
            return False
        for i in range(len(event_data)):
            if (
                event_data[i][1][dlDtxCellEnablingEvent_value_index - 1] == dlDtxCellEnablingEvent and
                    event_data[i-1][1][dlDtxCellEnablingEvent_value_index - 1] == "DTXCELLENABLINGSTARTTIMER" and
                    int(event_data[i][1][sfn_value_index - 1]) - 10 == int(event_data[i-1][1][sfn_value_index - 1]) and
                    int(event_data[i][1][dtxCellNbUeCs1Ratio_value_index - 1]) / 100 <= rdDtxCellNbUeCs1ThresholdLow
            ):
                logging.info("dlDtxCellEnablingEvent[i]:{},dlDtxCellEnablingEvent[i-1]:{},\
                             sfn_value_index[i]:{},sfn_value_index[i-1]:{},dtxCellNbUeCs1Ratio:{}".format(
                    event_data[i][1][dlDtxCellEnablingEvent_value_index - 1],
                    event_data[i-1][1][dlDtxCellEnablingEvent_value_index - 1],
                    event_data[i][1][sfn_value_index - 1],
                    event_data[i - 1][1][sfn_value_index - 1],
                    event_data[i][1][dtxCellNbUeCs1Ratio_value_index - 1]))
                return True
        return False

    def check_SLIV_in_dlFdSchedData(
            self, event="dlFdSchedData", filter_column="SLIV",
            special_slots=None, expected_SLIVs=None):
        """
        Author: Zhang xuewen
        check the num of dlFdSchedData.SLIV 53 on special slot 3,13 and
        dlFdSchedData.SLIV 96 on special slot 7,17
        :param filter_column:
        :param event:
        :param special_slots:
        :param expected_SLIVs:
        :return: return true if special slot have PDSCH Scheduling, else return false
        """
        if expected_SLIVs is None:
            expected_SLIVs = [53, 53, 96, 96]
        if special_slots is None:
            special_slots = [3, 13, 7, 17]
        column1 = "slot"
        column2 = filter_column
        event_column_list, last_col_num = self.reassign_event_column_number(event)
        column1_index = event_column_list.index(column1) + 1
        column1_value_index = last_col_num + column1_index
        column2_index = event_column_list.index(column2) + 1
        column2_value_index = last_col_num + column2_index

        result = True
        for i in range(len(special_slots)):
            try:
                event_data = get_lines_with_multiple_column_filter(
                    file_path=self.file_path,
                    column_list=[self.INDEX_event, column1_value_index, column2_value_index],
                    expected_list=[event, str(special_slots[i]), str(expected_SLIVs[i])],
                )
                logging.info("{} event:{} found for special slot={} and SLIV={}!".format(len(event_data), event,
                                                                                         special_slots[i],
                                                                                         expected_SLIVs[i]))
            except LookupError:
                logging.warning("No event:{} found for special slot={} and SLIV={}!".format(event, special_slots[i],
                                                                                            expected_SLIVs[i]))
                result = False

        return result


def get_tti_analyzer(file_path):
    return TTI_Trace_analysis_dl(file_path)


def CB008238_get_dl_average_numOfPrb(file_path):
    return TTI_Trace_analysis_dl(file_path).get_dl_average_numOfPrb()


def CB008238_check_if_highestClassPriority17_in_dlPreSchedData(file_path):
    return TTI_Trace_analysis_dl(
        file_path
    ).if_highestClassPriority17_in_dlPreSchedData()


# tti = get_tti_analyzer("/home/ute/xuewen/output/TA_Combine_dl_Full_20221111121731.csv")
#
# tti.check_SLIV_in_dlFdSchedData()
