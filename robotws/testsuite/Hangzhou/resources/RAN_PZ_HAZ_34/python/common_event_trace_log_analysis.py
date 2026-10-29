# -*- coding: utf-8 -*

"""
Author:         Ding Binmei
Contact Mail:   binmei.ding@nokia-sbell.com
Description:    Common check for event trace log analysis, like bler verification, get events...
                Please do not modify the file without the permission from author
"""
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python import check_csv_log
import logging


class Parameters19B(object):
    # Accuracy for digit number when doing calculation
    NDIGITS = 2
    INDEX_event = 1
    INDEX_ulTdSchedSubcellData_rnti = 45
    INDEX_ulTdSchedSubcellData_resReqClassPrio = 46
    INDEX_ulLaDeltaSinr_rnti = 12
    INDEX_ulLaDeltaSinr_crcFb = 17
    INDEX_dlTdSchedSubcellData_rnti = 45
    INDEX_dlTdSchedSubcellData_resReqClassPrio = 46
    FILTER_harqRxData_event_name = "dlHarqRxDataArray: hfnTickCount"


class ParametersMaster(object):
    NDIGITS = 2
    INDEX_event = 1
    INDEX_ulTdSchedSubcellData_rnti = 139
    INDEX_ulTdSchedSubcellData_resReqClassPrio = 140
    INDEX_ulLaDeltaSinr_rnti = 12
    INDEX_ulLaDeltaSinr_crcFb = 17
    INDEX_dlTdSchedSubcellData_rnti = 139
    INDEX_dlTdSchedSubcellData_resReqClassPrio = 140
    FILTER_harqRxData_event_name = "dlHarqRxDataArray: hfnTickCount"


class Parameters20B(object):
    NDIGITS = 2
    INDEX_event = 1
    INDEX_ulTdSchedSubcellData_rnti = 45
    INDEX_ulTdSchedSubcellData_resReqClassPrio = 46
    INDEX_ulLaDeltaSinr_rnti = 12
    INDEX_ulLaDeltaSinr_crcFb = 17
    INDEX_dlTdSchedSubcellData_rnti = 45
    INDEX_dlTdSchedSubcellData_resReqClassPrio = 46
    FILTER_harqRxData_event_name = "dlHarqRxDataArray: hfnTickCount"


class Parameters21A(object):
    NDIGITS = 2
    INDEX_event = 1
    INDEX_ulTdSchedSubcellData_rnti = 45
    INDEX_ulTdSchedSubcellData_resReqClassPrio = 46
    INDEX_ulLaDeltaSinr_rnti = 12
    INDEX_ulLaDeltaSinr_crcFb = 17
    INDEX_dlTdSchedSubcellData_rnti = 45
    INDEX_dlTdSchedSubcellData_resReqClassPrio = 46
    FILTER_harqRxData_event_name = "dlHarqRxDataArray: hfnTickCount"


class Event_trace_log_analysis(object):

    def __init__(self, program=None):
        if program == "19B":
            self.parameters = Parameters19B()
        elif program == 'master':
            self.parameters = ParametersMaster()
        elif program == '20B':
            self.parameters = Parameters20B()
        elif program == '21A':
            self.parameters = Parameters21A()
        else:
            self.parameters = ParametersMaster()

    def reassign_event_column_number(self, event, file_path):
        """
        Author: Ren Biyao
        Get column number base on event
        """
        column_list = []
        last_col_num = None
        with open(file_path) as f:
            lines = f.readlines()
            for line in lines:
                if event in line:
                    column_list = line.split(',')
                    break
        for i, value in enumerate(column_list):
            if value.isdigit():
                last_col_num = i
                break
        return column_list, last_col_num

    def reassign_dlFdSchedData_column_number(self, file_path):
        """
        Author: Ren Biyao
        Reassign dlFdSchedData event column number
        :param file_path:
        :return:
        """
        dlFdSchedData_column_list, last_col_num = self.reassign_event_column_number(
            event='dlFdSchedData: hfnTickCount',
            file_path=file_path)
        rnti_num = dlFdSchedData_column_list.index('rnti') + 1
        physcellid_num = dlFdSchedData_column_list.index('physCellId') + 1
        tx_num = dlFdSchedData_column_list.index('txNumber') + 1
        dlharqprocess_num = dlFdSchedData_column_list.index('dlHarqProcessIndex') + 1
        maxdatavolumedl_num = dlFdSchedData_column_list.index('maxDataVolumeDl') + 1
        tbsize_num = dlFdSchedData_column_list.index('tbSize') + 1
        sfn_num = dlFdSchedData_column_list.index('dlFdSchedData: hfnTickCount') + 1
        slot_num = dlFdSchedData_column_list.index('slot') + 1
        k1_num = dlFdSchedData_column_list.index('K1') + 1
        layer_num = dlFdSchedData_column_list.index('numOfLayers') + 1
        mcs_num = dlFdSchedData_column_list.index('rrmDlUsedMcs') + 1
        self.INDEX_dlFdSchedData_rnti = last_col_num + rnti_num
        self.INDEX_dlFdSchedData_physCellId = last_col_num + physcellid_num
        self.INDEX_dlFdSchedData_txNumber = last_col_num + tx_num
        self.INDEX_dlFdSchedData_dlHarqProcessIndex = last_col_num + dlharqprocess_num
        self.INDEX_dlFdSchedData_maxdatavolumedl = last_col_num + maxdatavolumedl_num
        self.INDEX_dlFdSchedData_tbsize = last_col_num + tbsize_num
        self.INDEX_dlFdSchedData_sfn = last_col_num + sfn_num
        self.INDEX_dlFdSchedData_slot = last_col_num + slot_num
        self.INDEX_dlFdSchedData_k1 = last_col_num + k1_num
        self.INDEX_dlFdSchedData_numOfLayers = last_col_num + layer_num
        self.INDEX_rrmDlUsedMcs = last_col_num + mcs_num

    def reassign_dlHarqRxData_column_number(self, file_path):
        """
        Author: Ren Biyao
        Reassign dlHarqRxData event column number
        """
        dlHarqRxData_column_list, last_col_num = self.reassign_event_column_number(
            event='dlHarqRxDataArray: hfnTickCount',
            file_path=file_path
        )
        rnti_num = dlHarqRxData_column_list.index('rnti') + 1
        phycellid_num = dlHarqRxData_column_list.index('physCellId') + 1
        dtx_num = dlHarqRxData_column_list.index('dtx') + 1
        sfn_num = dlHarqRxData_column_list.index('dlHarqRxDataArray: hfnTickCount') + 1
        slot_num = dlHarqRxData_column_list.index('slot') + 1
        dlHarqProcessIndex_num = dlHarqRxData_column_list.index('dlHarqProcessIndex') + 1
        self.INDEX_dlHarqRxData_rnti = last_col_num + rnti_num + 3
        self.INDEX_dlHarqRxData_physCellId = last_col_num + phycellid_num
        self.INDEX_dlHarqRxData_dtx = last_col_num + dtx_num
        self.INDEX_dlHarqRxData_sfn = last_col_num + sfn_num
        self.INDEX_dlHarqRxData_slot = last_col_num + slot_num
        self.INDEX_dlHarqRxData_dlHarqProcessIndex = last_col_num + dlHarqProcessIndex_num

    def reassign_ulFdSchedData_column_number(self, file_path):
        """
        Author: Ren Biyao
        Reassign ulFdSchedData event column number
        """
        ulFdSchedData_column_list, last_col_num = self.reassign_event_column_number(
            event='ulFdSchedData: hfnTickCount',
            file_path=file_path)
        rnti_num = ulFdSchedData_column_list.index('rnti') + 1
        tx_num = ulFdSchedData_column_list.index('txNumber') + 1
        ulharq_num = ulFdSchedData_column_list.index('ulHarqProcessIndex') + 1
        physcellid_num = ulFdSchedData_column_list.index('physCellId') + 1
        mcs_num = ulFdSchedData_column_list.index('rrmUlUsedMcs') + 1
        self.INDEX_ulFdSchedData_rnti = last_col_num + rnti_num
        self.INDEX_ulFdSchedData_txNumber = last_col_num + tx_num
        self.INDEX_ulFdSchedData_ulHarqProcessIndex = last_col_num + ulharq_num
        self.INDEX_ulFdSchedData_physCellId = last_col_num + physcellid_num
        self.INDEX_rrmUlUsedMcs = last_col_num + mcs_num

    def reassign_ulHarqRxData_column_number(self, file_path):
        """
        Author: Ren Biyao
        Reassign ulHarqRxData event column number
        """
        ulHarqRxData_column_list, last_col_num = self.reassign_event_column_number(
            event='ulHarqRxData: hfnTickCount',
            file_path=file_path
        )
        rnti_num = ulHarqRxData_column_list.index('rnti') + 1
        dtx_num = ulHarqRxData_column_list.index('dtx') + 1
        ulHarqProcessIndex_num = ulHarqRxData_column_list.index('ulHarqProcessIndex') + 1
        self.INDEX_ulHarqRxData_rnti = last_col_num + rnti_num
        self.INDEX_ulHarqRxData_dtx = last_col_num + dtx_num
        self.INDEX_ulHarqRxData_ulHarqProcessIndex = last_col_num + ulHarqProcessIndex_num

    def reassign_csiSrReportData_column_number(self, file_path):
        """
        Author: Ren Biyao
        Reassign csiSrReportData event column number
        """
        csiSrReportData_column_list, last_col_num = self.reassign_event_column_number(
            event='csiSrReportData: hfnTickCount',
            file_path=file_path
        )
        rnti_num = csiSrReportData_column_list.index('rnti') + 1
        physCellId_num = csiSrReportData_column_list.index('physCellId') + 1
        self.INDEX_csiSrReportData_rnti = last_col_num + rnti_num
        self.INDEX_csiSrReportData_physCellId = last_col_num + physCellId_num
        logging.warning(self.INDEX_csiSrReportData_physCellId)

    def get_transmission_direction_from_file_name(self, file_path):
        """
        Author: Ding Binmei
        Description: Get direction based on input csv file name
        :param file_path: log file path with csv format: /XXX/XXX/TA_Combine_dl_Full_20190220123609.csv
        :return: ul or dl
        """
        file_name = file_path.split('/')[-1].lower()
        file_name_with_direction_info = file_name.split("_full_")[0].split("_")[-1]
        if file_name_with_direction_info.find('ul') != -1:
            return 'ul'
        elif file_name_with_direction_info.find('dl') != -1:
            return 'dl'
        else:
            raise Exception("Fail to get direction based on file name")

    def get_rntis(self, file_path, direction=None):
        """
        Author: Ding Binmei
        Description: Get rntis from event trace log
                     Each UE will have one unique rnti, so rnti can stand for a ue
        :param file_path: log file path with csv format: /XXX/XXX/TA_Combine_dl_Full_20190220123609.csv
        :param direction: values can be ul or dl, if not input, will get the value from input file name
        :return: rntis with list format
        """
        if direction is None:
            direction = self.get_transmission_direction_from_file_name(file_path=file_path)
        direction = direction.lower()
        logging.debug("direction value: {}".format(direction))
        if direction == 'dl':
            index_schedSubcellData_resReqClassPrio = self.parameters.INDEX_dlTdSchedSubcellData_resReqClassPrio
            index_schedSubcellData_rnti = self.parameters.INDEX_dlTdSchedSubcellData_rnti
            filter_schedSubcellData_event = "dlTdSchedSubcellData: hfnTickCount"
            value_schedSubcellData_resReqClassPrio = "40"
        elif direction == 'ul':
            index_schedSubcellData_resReqClassPrio = self.parameters.INDEX_ulTdSchedSubcellData_resReqClassPrio
            index_schedSubcellData_rnti = self.parameters.INDEX_ulTdSchedSubcellData_rnti
            filter_schedSubcellData_event = "ulTdSchedSubcellData: hfnTickCount"
            value_schedSubcellData_resReqClassPrio = "30"
        else:
            raise Exception("Fail to get rntis: Unsupported value for direction {}, "
                            "only ul or dl is supported".format(direction))
        try:
            schedSubcellData_event_with_data_traffic = check_csv_log.get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.parameters.INDEX_event,
                             index_schedSubcellData_resReqClassPrio],
                expected_list=[filter_schedSubcellData_event, value_schedSubcellData_resReqClassPrio])
        except LookupError:
            raise LookupError("Fail to get rnti as no event found for {} with resReqClassPrio={}".format(
                filter_schedSubcellData_event, value_schedSubcellData_resReqClassPrio))
        rntis = check_csv_log.get_unique_values_in_column(
            matrix=schedSubcellData_event_with_data_traffic, column_number=index_schedSubcellData_rnti)
        print("Current available rntis are: {}".format(rntis))
        logging.warning("rntis {}".format(rntis))
        return rntis

    def get_event_by_rnti(self, file_path, rnti, event_name, rnti_index_in_target_event):
        """
        Author: Ding Binmei
        Description: Get event by rnti
        :param file_path:
        :param rnti:
        :param event_name:
        :param rnti_index_in_target_event:
        :return:
        """
        try:
            target_event = check_csv_log.get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.parameters.INDEX_event, rnti_index_in_target_event],
                expected_list=[event_name, rnti])
        except LookupError:
            raise LookupError("No {} event found".format(event_name))
        else:
            return target_event

    def get_fdSchedData_event(self, file_path, rnti, direction):
        """
        Author: Ding Binmei
        Description: Get fdSchedData event
        :param file_path:
        :param rnti:
        :param direction: values can be ul or dl
        :return:
        """
        direction = direction.lower()
        if direction == 'dl':
            self.reassign_dlFdSchedData_column_number(file_path=file_path)
            fdSchedData_event_name = "dlFdSchedData: hfnTickCount"
            rnti_index_FdSchedData = self.INDEX_dlFdSchedData_rnti

        elif direction == 'ul':
            self.reassign_ulFdSchedData_column_number(file_path=file_path)
            fdSchedData_event_name = "ulFdSchedData: hfnTickCount"
            rnti_index_FdSchedData = self.INDEX_ulFdSchedData_rnti
        else:
            raise Exception("Un-supported direction value, available values are ul and dl")
        return self.get_event_by_rnti(file_path=file_path, rnti=rnti, event_name=fdSchedData_event_name,
                                      rnti_index_in_target_event=rnti_index_FdSchedData)

    def get_harqRxData_event(self, file_path, rnti, direction):
        """
        Author: Ding Binmei
        Description: Get harqRxData event
        :param file_path:
        :param rnti:
        :param direction: values can be ul or dl
        :return:
        """
        direction = direction.lower()
        if direction == 'dl':
            self.reassign_dlHarqRxData_column_number(file_path=file_path)
            harqRxData_event_name = "dlHarqRxDataArray: hfnTickCount"
            logging.warning("name".format(harqRxData_event_name))
            rnti_index_harqRxData = self.INDEX_dlHarqRxData_rnti
        elif direction == 'ul':
            self.reassign_ulHarqRxData_column_number(file_path=file_path)
            harqRxData_event_name = "ulHarqRxData: hfnTickCount"
            rnti_index_harqRxData = self.INDEX_ulHarqRxData_rnti
        else:
            raise Exception("Un-supported direction value, available values are ul and dl")
        return self.get_event_by_rnti(file_path=file_path, rnti=rnti, event_name=harqRxData_event_name,
                                      rnti_index_in_target_event=rnti_index_harqRxData)

    def _get_related_FdSchedData_event_by_row_num_and_harq_id_in_HarqRxData_event(
            self, row_num_in_HarqRxData_event, harq_id, fdSchedData_event, direction, file_path):
        """
        Author: Ding Binmei
        Description: use row num and harq_id in HarqRxData_event to location the related row info in
        FdSchedData_event, can support for both ul and dl
        Search the rows before row_num_in_HarqRxData_event and find the nearest row in ulFdSchedData_event,
        with harq id  equals in HarqRxData_event
        :param row_num_in_HarqRxData_event:
        :param harq_id: harq_id value in HarqRxData_event
        :param fdSchedData_event:
        :param direction: can be ul, dl
        :return:
        """
        direction = direction.lower()
        if direction == 'dl':
            self.reassign_dlFdSchedData_column_number(file_path=file_path)
            harq_process_index_in_FdSchedData_event = self.INDEX_dlFdSchedData_dlHarqProcessIndex
        elif direction == 'ul':
            self.reassign_ulFdSchedData_column_number(file_path=file_path)
            harq_process_index_in_FdSchedData_event = self.INDEX_ulFdSchedData_ulHarqProcessIndex
        else:
            raise Exception("Un-supported direction value, available values are ul and dl")
        harq_id = str(harq_id)
        try:
            fdSchedData_event_row = check_csv_log.add_filter_to_matrix_in_given_range(
                fdSchedData_event,
                None,
                row_num_in_HarqRxData_event - 1,
                [harq_process_index_in_FdSchedData_event, [harq_id]]
            )[-1]
        except LookupError:
            raise LookupError("{}: No related FdSchedData_event_row found with harq_id={} in HarqRxData_event, "
                              "with provided row_num_in_HarqRxData_event:{}".format(direction, harq_id,
                                                                                    row_num_in_HarqRxData_event))
        return fdSchedData_event_row

    def _get_FdSchedData_event_with_DTX(self, fdSchedData_event, harqRxData_event, direction, file_path):
        """
        Author: Ding Binmei
        Description: Get FdSchedData_event rows with dtx status, can support for both ul and dl
        :param fdSchedData_event:
        :param harqRxData_event:
        :param direction: can be ul, dl
        :return:
        """
        direction = direction.lower()
        if direction == 'dl':
            self.reassign_dlHarqRxData_column_number(file_path=file_path)
            self.reassign_dlFdSchedData_column_number(file_path=file_path)
            dtx_index_in_HarqRxData = self.INDEX_dlHarqRxData_dtx
            harqProcessIndex_in_harqRxData = self.INDEX_dlHarqRxData_dlHarqProcessIndex
        elif direction == 'ul':
            self.reassign_ulFdSchedData_column_number(file_path=file_path)
            self.reassign_ulHarqRxData_column_number(file_path=file_path)
            dtx_index_in_HarqRxData = self.INDEX_ulHarqRxData_dtx
            harqProcessIndex_in_harqRxData = self.INDEX_ulHarqRxData_ulHarqProcessIndex
        else:
            raise Exception("Un-supported direction value, available values are ul and dl")
        try:
            harqRxData_event_with_dtx = check_csv_log.add_filters_to_matrix(
                harqRxData_event, [dtx_index_in_HarqRxData, ['DTX']])
        except LookupError:
            harqRxData_event_with_dtx = []
            print("No DTX found in {}HarqRxData event".format(direction))
        fdSchedData_event_with_dtx = []
        for i in range(0, len(harqRxData_event_with_dtx)):
            cur_row = harqRxData_event_with_dtx[i][0]
            harq_id = harqRxData_event_with_dtx[i][1][harqProcessIndex_in_harqRxData - 1]
            fdSchedData_event_row = \
                self._get_related_FdSchedData_event_by_row_num_and_harq_id_in_HarqRxData_event(
                    row_num_in_HarqRxData_event=cur_row, harq_id=harq_id, fdSchedData_event=fdSchedData_event,
                    direction=direction, file_path=file_path)
            fdSchedData_event_with_dtx.append(fdSchedData_event_row)
        return fdSchedData_event_with_dtx

    def _get_row_count_in_FdSchedData_event_based_on_txNumber(self, txNumber, fdSchedData_event, direction,
                                                              file_path):
        """
        Author: Ding Binmei
        Description: Get row count in FdSchedData_event with provided txNumber, can support for both ul and dl
        :param txNumber: if txNumber = 1, it means for the first transmission; if >=2, means for re-transmission
        :param FdSchedData_event:
        :param direction: can be ul, dl
        :return:
        """
        direction = direction.lower()
        if direction == 'dl':
            self.reassign_dlFdSchedData_column_number(file_path=file_path)
            txNumber_index_in_FdSchedData_event = self.INDEX_dlFdSchedData_txNumber
        elif direction == 'ul':
            self.reassign_ulFdSchedData_column_number(file_path=file_path)
            txNumber_index_in_FdSchedData_event = self.INDEX_ulFdSchedData_txNumber
        else:
            raise Exception("Un-supported direction value, available values are ul and dl")
        txNumber = str(txNumber)
        try:
            txNum_with_specific_value_event = check_csv_log.add_filters_to_matrix(
                fdSchedData_event,
                [txNumber_index_in_FdSchedData_event, [txNumber]])
            count_txNum_with_specific_value = len(txNum_with_specific_value_event)
        except LookupError:
            print("No data found with txNumber={} in FdSchedData event".format(txNumber))
            count_txNum_with_specific_value = 0
        return count_txNum_with_specific_value

    def _calculate_bler_for_single_ue(self, fdSchedData_event, harqRxData_event, direction, file_path):
        """
        Author: Ding Binmei
        Description: Calculate bler for ul/dl: (count_txNum_with_2 - count_txNum_with_1_with_dtx)/
                                        (count_txNum_with_1 - count_txNum_with_1_with_dtx)
        Based on our manual tester, dtx should not be calculated in bler calculation
        if calculation is failed, then will return 'error' instead
        :param fdSchedData_event:
        :param harqRxData_event:
        :param direction: can be ul, dl
        :return:
        """
        direction = direction.lower()
        if direction == 'dl':
            self.reassign_dlFdSchedData_column_number(file_path=file_path)
            txNumber_index_in_FdSchedData_event = self.INDEX_dlFdSchedData_txNumber
        elif direction == 'ul':
            self.reassign_ulFdSchedData_column_number(file_path=file_path)
            txNumber_index_in_FdSchedData_event = self.INDEX_ulFdSchedData_txNumber
        else:
            raise Exception("Un-supported direction value, available values are ul and dl")
        fdSchedData_event_with_dtx = self._get_FdSchedData_event_with_DTX(
            fdSchedData_event=fdSchedData_event,
            harqRxData_event=harqRxData_event,
            direction=direction,
            file_path=file_path
        )
        if fdSchedData_event_with_dtx:
            try:
                txNum_with_1_event_with_dtx = check_csv_log.add_filters_to_matrix(
                    fdSchedData_event_with_dtx,
                    [txNumber_index_in_FdSchedData_event, ['1']])
                count_txNum_with_1_with_dtx = len(txNum_with_1_event_with_dtx)
            except LookupError:
                print("{}: No DTX during first transmission".format(direction))
                count_txNum_with_1_with_dtx = 0
        else:
            count_txNum_with_1_with_dtx = 0
        count_txNum_with_1 = self._get_row_count_in_FdSchedData_event_based_on_txNumber(
            txNumber='1', fdSchedData_event=fdSchedData_event, direction=direction, file_path=file_path)
        count_txNum_with_2 = self._get_row_count_in_FdSchedData_event_based_on_txNumber(
            txNumber='2', fdSchedData_event=fdSchedData_event, direction=direction, file_path=file_path)
        try:
            bler = float(count_txNum_with_2 - count_txNum_with_1_with_dtx) / float(count_txNum_with_1 -
                                                                                   count_txNum_with_1_with_dtx)
        except ZeroDivisionError:
            logging.error("ZeroDivisionError: will set bler value as error")
            bler = "error"
        print("count_txNum_with_2: {}, count_txNum_with_1: {}, count_txNum_with_1_with_dtx: {}, {} bler: {}".format(
            count_txNum_with_2, count_txNum_with_1, count_txNum_with_1_with_dtx, direction, bler))
        return bler

    def calculate_bler(self, file_path, direction=None):
        """
        Author: Ding Binmei
        Description: Calculate bler from event trace log. DTX is not calculated in bler
        :param file_path:
        :param direction: values can be ul or dl, if not input, will get the value from input file name
        :return:
        """
        if direction is None:
            direction = self.get_transmission_direction_from_file_name(file_path=file_path)
        direction = direction.lower()
        rntis = self.get_rntis(file_path=file_path, direction=direction)
        dict_blers = {}
        for rnti in rntis:
            fdSchedData_event = self.get_fdSchedData_event(file_path=file_path, rnti=rnti, direction=direction)
            harqRxData_event = self.get_harqRxData_event(file_path=file_path, rnti=rnti, direction=direction)
            bler = self._calculate_bler_for_single_ue(fdSchedData_event=fdSchedData_event,
                                                      harqRxData_event=harqRxData_event, direction=direction,
                                                      file_path=file_path)
            dict_blers[rnti] = bler
        return dict_blers

    def verify_bler_is_as_expected(self, file_path, exp_bler, direction=None, exp_ue_number=1):
        """
        Author: Ding Binmei
        Description: Verify if bler is as expected for each ue
        :param file_path:
        :param direction:
        :param exp_bler:
        :return:
        """
        exp_bler = float(exp_bler)
        exp_ue_number = int(exp_ue_number)
        if direction is None:
            direction = self.get_transmission_direction_from_file_name(file_path=file_path)
        direction = direction.lower()
        dict_blers = self.calculate_bler(file_path=file_path, direction=direction)
        act_ue_number = len(dict_blers.keys())
        if act_ue_number != exp_ue_number:
            raise Exception("Expected ue number is:{}, actually only {} ue(s) found from event trace log."
                            "Detail bler info from log:{}".format(exp_ue_number, act_ue_number, dict_blers))
        else:
            error_count = 0
            for rnti in dict_blers.keys():
                if dict_blers[rnti] > exp_bler:
                    logging.error("Fail to verify {} bler for rnti {}. actual value: {}, exp value: {}".format(
                        direction, rnti, dict_blers[rnti], exp_bler
                    ))
                    error_count = error_count + 1
            if error_count > 0:
                raise Exception("Bler verification failed for {} UEs, "
                                "details please check the error log print out above".format(error_count))
            else:
                print("Verify bler for {} ue(s) passed from event trace log. Detail bler info:{}".format(
                    exp_ue_number, dict_blers))
