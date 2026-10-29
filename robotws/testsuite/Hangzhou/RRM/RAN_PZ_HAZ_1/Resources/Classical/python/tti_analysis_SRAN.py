# -*- coding: utf-8 -*

"""
Author:         Yang Mengli
Contact Mail:   mengli.yang@nokia-sbell.com
Description:    Check tti log
"""

import logging
import csv
import os
from taf.transport.ssh import ssh

ssh = ssh()


class tti_analysis_SRAN(object):
    def __init__(self):
        self.INDEX_dlTdSchedSubcellData_resReqClassPrio = 46
        self.INDEX_dlTdSchedSubcellData_rnti = 45
        self.INDEX_ulTdSchedSubcellData_resReqClassPrio = 46
        self.INDEX_ulTdSchedSubcellData_rnti = 45
        self.INDEX_event = 1

    def read_csv_file_into_matrix(self, file_path, delimiter=","):
        """
        read csv log file , split value by ",", and store all value into the matrix

        :param file_path: String: csv log file path.
        :param delimiter: String: the spliter to split values into cells.
        :return: The value matrix
        """
        with open(file_path) as csvfile:
            reader = csv.reader(csvfile, delimiter=str(delimiter))
            matrix = []
            line_number = 0
            for line in reader:
                if line:
                    line_number += 1
                    line_data = [line_number, line]
                    matrix.append(line_data)
            return matrix

    def get_lines_with_multiple_column_filter(self, file_path, column_list, expected_list, delimiter=","):
        """
        get all lines that match all filter.

        :param file_path: String: csv log file path.
        :param column_list: List: a list content all target filters' column number.
                             column number count start from 1.
        :param expected_list: List: a list content all filters, the sort should match with column_list
        :param delimiter: String: the spliter to split values into cells.
        :return: List: content all lines match the filter.
        """
        result = []
        matrix = self.read_csv_file_into_matrix(file_path, delimiter)
        for line in matrix:
            if line[1]:
                for i in range(len(column_list)):
                    try:
                        target = line[1][int(column_list[i]) - 1]
                        expected = expected_list[i]
                        if expected not in target:
                            break
                    except IndexError:
                        continue
                else:
                    result.append(line)
        if not result:
            raise LookupError("Can't found any line match all column expected.")
        return result

    def get_column_from_matrix(self, matrix, column_nubmer):
        """
        get target column from matrix

        :param matrix: List: the matrix
        :param column_nubmer: Int: the index of target column.
                             column number count start from 1.
        :return: List: target column
        """
        column = int(column_nubmer) - 1
        column_list = []
        for row in matrix:
            column_list.append(row[1][column])
        return column_list

    def get_unique_values_in_column(self, matrix, column_number):
        """
        check the column and return a list ,
        which content all values in the column (already removed duplicate data)

        :param matrix: List: matrix type of csv file content
        :param column_number: target column's number
        :return: List: all unique values in target column
        """
        column = self.get_column_from_matrix(matrix, column_number)
        result = list(set(column))
        return result

    def get_transmission_direction_from_file_name(self, file_path):
        """
        Author: Yang Mengli
        Description: Get direction based on input csv file name
        :param file_path: log file path with csv format:
                         /XXX/XXX/TA_Combine_dl_Full_20210108094424.csv
                         /XXX/XXX/TA_Combine_ul_Full_20210108094424.csv
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
        Author: Yang Mengli
        Description: Get rntis from event trace log
                     Each UE will have one unique rnti, so rnti can stand for a ue
        :param file_path: log file path with csv format:
                         /XXX/XXX/TA_Combine_dl_Full_20210108094424.csv
                         /XXX/XXX/TA_Combine_ul_Full_20210108094424.csv
        :param direction: values can be ul or dl, if not input, will get the value from input file name
        :return: rntis with list format
        """
        if direction is None:
            direction = self.get_transmission_direction_from_file_name(file_path=file_path)
        direction = direction.lower()
        logging.debug("direction value: {}".format(direction))
        if direction == 'dl':
            index_schedSubcellData_resReqClassPrio = self.INDEX_dlTdSchedSubcellData_resReqClassPrio
            index_schedSubcellData_rnti = self.INDEX_dlTdSchedSubcellData_rnti
            filter_schedSubcellData_event = "dlTdSchedSubcellData: sfn"
            value_schedSubcellData_resReqClassPrio = "40"
        elif direction == 'ul':
            index_schedSubcellData_resReqClassPrio = self.INDEX_ulTdSchedSubcellData_resReqClassPrio
            index_schedSubcellData_rnti = self.INDEX_ulTdSchedSubcellData_rnti
            filter_schedSubcellData_event = "ulTdSchedSubcellData: sfn"
            value_schedSubcellData_resReqClassPrio = "30"
        else:
            raise Exception("Fail to get rntis: Unsupported value for direction {}, ""only ul or dl is supported".
                            format(direction))
        try:
            schedSubcellData_event_with_data_traffic = self.get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.INDEX_event,
                             index_schedSubcellData_resReqClassPrio],
                expected_list=[filter_schedSubcellData_event, value_schedSubcellData_resReqClassPrio])
        except LookupError:
            raise LookupError("Fail to get rnti as no event found for {} with resReqClassPrio={}".
                              format(filter_schedSubcellData_event, value_schedSubcellData_resReqClassPrio))
        rntis = self.get_unique_values_in_column(
            matrix=schedSubcellData_event_with_data_traffic, column_number=index_schedSubcellData_rnti)
        # print("Current available rntis are: {}".format(rntis))
        return rntis

    def get_event_by_rnti(self, file_path, rnti, event_name, rnti_index_in_target_event):
        """
        Author: Yang Mengli
        Description: Get event by rnti
        :param file_path:
        :param rnti:
        :param event_name:
        :param rnti_index_in_target_event:
        :return:
        """
        try:
            target_event = self.get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.INDEX_event, rnti_index_in_target_event],
                expected_list=[event_name, rnti])
        except LookupError:
            raise LookupError("No {} event found".format(event_name))
        else:
            return target_event

    def get_event_sfn(self, file_path, sfn, event_name, sfn_index_in_target_event):
        """
        Author: Yang Mengli
        Description: Get event by rnti
        :param file_path:
        :param sfn:
        :param event_name:
        :param rnti_index_in_target_event:
        :return:
        """
        try:
            target_event = self.get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.INDEX_event, sfn_index_in_target_event],
                expected_list=[event_name, sfn])
        except LookupError:
            raise LookupError("No {} event found".format(event_name))
        else:
            return target_event

    def getDlCorrAvgCqi(self, file_path, rnti, event_name, rnti_index_in_target_event, index_cqi):
        target_event = self.get_event_by_rnti(file_path, rnti, event_name, rnti_index_in_target_event)
        column = index_cqi - 1
        column_list = []
        for row in target_event:
            column_list.append(row[1][column])
        return column_list

    def getUsedMcs(self, file_path, rnti, event_name, rnti_index_in_target_event, index_mcs):
        target_event = self.get_event_by_rnti(file_path, rnti, event_name, rnti_index_in_target_event)
        column = index_mcs - 1
        column_list = []
        for row in target_event:
            column_list.append(row[1][column])
        return column_list

    def getptrsFlag(self, file_path, rnti, event_name, rnti_index_in_target_event, index_ptrsflag):
        target_event = self.get_event_by_rnti(file_path, rnti, event_name, rnti_index_in_target_event)
        column = index_ptrsflag - 1
        column_list = []
        for row in target_event:
            column_list.append(row[1][column])
        prts_list = []
        for item in column_list:
            if item != 'PTRS_VOID' and item not in prts_list:
                prts_list.append(item)
        return prts_list

    def getnumOfPrb(self, file_path, rnti, event_name, rnti_index_in_target_event, index_numberofprb):
        """
        Author: Yang Mengli
        Description: Get numOfPrb from event trace log
        :param file_path: log file path with csv format:
                         /XXX/XXX/TA_Combine_dl_Full_20210108094424.csv
                         /XXX/XXX/TA_Combine_ul_Full_20210108094424.csv
        :param rnti: Each UE will have one unique rnti, so rnti can stand for a ue
        :param event_name: here is event name, eg:dlFdSchedData
        :param rnti_index_in_target_event: INDEX_dlFdSchedData_rnti
        :param index_numberofprb:INDEX_dlFdSchedData_numberofprb
        :return: numOfPrb with list format
        """
        target_event = self.get_event_by_rnti(file_path, rnti, event_name, rnti_index_in_target_event)
        column = index_numberofprb - 1
        column_list = []
        for row in target_event:
            column_list.append(int(row[1][column]))
        return column_list

    def getPrbsPercent(self, prbs_list, expect):
        prbs = []
        for item in prbs_list:
            if int(item) == int(expect):
                prbs.append(item)
        return float(len(prbs)) / float(len(prbs_list))

    def getphysCellId(self, file_path, rnti, event_name, rnti_index_in_target_event, index_physCellId):
        """
        Author: Yang Mengli
        Description: Get physCellId from event trace log
        :param file_path: log file path with csv format:
                         /XXX/XXX/TA_Combine_dl_Full_20210108094424.csv
                         /XXX/XXX/TA_Combine_ul_Full_20210108094424.csv
        :param rnti: Each UE will have one unique rnti, so rnti can stand for a ue
        :param event_name: here is event name, eg:dlFdSchedData
        :param rnti_index_in_target_event: INDEX_dlFdSchedData_rnti
        :param index_physCellId:INDEX_dlFdSchedData_physCellId
        :return: physCellId with list format
        """
        target_event = self.get_event_by_rnti(file_path, rnti, event_name, rnti_index_in_target_event)
        column = index_physCellId - 1
        column_list = []
        for row in target_event:
            column_list.append(int(row[1][column]))
        return column_list

    def get_sfn(self, file_path, rnti, event_name, rnti_index_in_target_event, index_sfn):
        """
        Author: Yang Mengli
        Description: Get sfn from event trace log
        :param file_path: log file path with csv format:
                         /XXX/XXX/TA_Combine_dl_Full_20210108094424.csv
                         /XXX/XXX/TA_Combine_ul_Full_20210108094424.csv
        :param rnti: Each UE will have one unique rnti, so rnti can stand for a ue
        :param event_name: here is event name, eg:dlFdSchedData
        :param rnti_index_in_target_event: INDEX_dlFdSchedData_rnti
        :param index_sfn:INDEX_dlFdSchedData_sfn
        :return: sfn with list format
        """
        target_event = self.get_event_by_rnti(file_path, rnti, event_name, rnti_index_in_target_event)
        column = index_sfn - 1
        column_list = []
        for row in target_event:
            column_list.append(int(row[1][column]))
        return column_list

    def getslot(self, file_path, rnti, event_name, rnti_index_in_target_event, index_slot):
        """
        Author: Yang Mengli
        Description: Get slot from event trace log
        :param file_path: log file path with csv format:
                         /XXX/XXX/TA_Combine_dl_Full_20210108094424.csv
                         /XXX/XXX/TA_Combine_ul_Full_20210108094424.csv
        :param rnti: Each UE will have one unique rnti, so rnti can stand for a ue
        :param event_name: here is event name, eg:dlFdSchedData
        :param rnti_index_in_target_event: INDEX_dlFdSchedData_rnti
        :param index_slot:INDEX_dlFdSchedData_slot
        :return: slot with list format
        """
        target_event = self.get_event_by_rnti(file_path, rnti, event_name, rnti_index_in_target_event)
        column = index_slot - 1
        column_list = []
        for row in target_event:
            column_list.append(int(row[1][column]))
        return column_list

    def gettbSize(self, file_path, rnti, event_name, rnti_index_in_target_event, index_tbSize):
        """
        Author: Yang Mengli
        Description: Get tbSize from event trace log
        :param file_path: log file path with csv format:
                         /XXX/XXX/TA_Combine_dl_Full_20210108094424.csv
                         /XXX/XXX/TA_Combine_ul_Full_20210108094424.csv
        :param rnti: Each UE will have one unique rnti, so rnti can stand for a ue
        :param event_name: here is event name, eg:dlFdSchedData
        :param rnti_index_in_target_event: INDEX_dlFdSchedData_rnti
        :param index_tbSize:INDEX_dlFdSchedData_tbSize
        :return: tbSize with list format
        """
        target_event = self.get_event_by_rnti(file_path, rnti, event_name, rnti_index_in_target_event)
        column = index_tbSize - 1
        column_list = []
        for row in target_event:
            column_list.append(int(row[1][column]))
        return column_list

    def gettbSizebysfn(self, file_path, sfn, event_name, sfn_index_in_target_event, index_tbSize):
        """
        Author: Yang Mengli
        Description: Get tbSize from event trace log
        :param file_path: log file path with csv format:
                         /XXX/XXX/TA_Combine_dl_Full_20210108094424.csv
                         /XXX/XXX/TA_Combine_ul_Full_20210108094424.csv
        :param rnti: Each UE will have one unique rnti, so rnti can stand for a ue
        :param event_name: here is event name, eg:dlFdSchedData
        :param rnti_index_in_target_event: INDEX_dlFdSchedData_rnti
        :param index_tbSize:INDEX_dlFdSchedData_tbSize
        :return: tbSize with list format
        """
        target_event = self.get_event_sfn(file_path, sfn, event_name, sfn_index_in_target_event)
        column = index_tbSize - 1
        column_list = []
        for row in target_event:
            column_list.append(int(row[1][column]))
        return column_list

    def get_min_tbsize_from_rnti(self, file_path, rnti_list, rnti_index_in_target_event, index_tbsize, direction='dl'):
        FdSchedData_event_min_tbsize_dict = {}
        direction = direction.lower()
        tbsize_list = []
        if direction == 'dl':
            event_name = "dlFdSchedData: sfn"
        elif direction == 'ul':
            event_name = "ulFdSchedData: sfn"
        try:
            for rnti in rnti_list:
                rnti_dict = {}
                FdSchedData_event = self.get_event_by_rnti(file_path, rnti, event_name, rnti_index_in_target_event)
                for i in range(0, len(FdSchedData_event)):
                    cur_tbsize = int(FdSchedData_event[i][1][index_tbsize - 1])
                    tbsize_list.append(cur_tbsize)
                min_tbsize = min(tbsize_list)
                rnti_dict.update({'min_tbsize': min_tbsize})
                FdSchedData_event_min_tbsize_dict.update({str(rnti): rnti_dict})
        except LookupError:
            raise LookupError("No tbsize found")
        else:
            return FdSchedData_event_min_tbsize_dict

    def get_max_min_sum_ave_tbsize(self, tbsize_list):
        min_tbsize = min(tbsize_list)
        max_tbsize = max(tbsize_list)
        sum_tbsize = 0
        for x in tbsize_list:
            sum_tbsize += int(x)
        ave_tbsize = sum_tbsize / 10.24 / 1000 / 1000
        return min_tbsize, max_tbsize, sum_tbsize, ave_tbsize

    def get_diff_sfn(self, sfn_list):
        sfn_list = list(set(sfn_list))
        return sfn_list

    def get_20_sfn_diff_tbsize(self, sfn_list, tbsize_list):
        if len(sfn_list) >= 20:
            sfn_count = 20
        else:
            sfn_count = len(sfn_list)
        sfn_diff_list = []
        for i in range(0, sfn_count - 1):
            diff1 = abs(sfn_list[i + 1] - sfn_list[i])
            sfn_diff_list.append(diff1)
        tbsize_sub_list = tbsize_list
        return sfn_diff_list, tbsize_sub_list

    def getfilename(self, path, direction):
        return path.get(direction)

    def get_dl_params_col_index(self, file_path):
        last_col_num = None
        with open(file_path) as f:
            lines = f.readlines()
            for line in lines:
                if 'dlFdSchedData: sfn' in line:
                    dlFdSchedData_column_list = line.split(',')
                    break
        for i, value in enumerate(dlFdSchedData_column_list):
            if value.isdigit():
                last_col_num = i
                break
        rnti_num = dlFdSchedData_column_list.index('rnti') + last_col_num + 1
        mcs_num = dlFdSchedData_column_list.index('rrmDlUsedMcs') + last_col_num + 1
        ptrs_num = dlFdSchedData_column_list.index('ptrsFlagDlProposedMcs') + last_col_num + 1
        prb_num = dlFdSchedData_column_list.index('numOfPrb') + last_col_num + 1
        PCI_num = dlFdSchedData_column_list.index('physCellId') + last_col_num + 1
        sfn_num = dlFdSchedData_column_list.index('dlFdSchedData: sfn') + last_col_num + 1
        slot_num = dlFdSchedData_column_list.index('slot') + last_col_num + 1
        tbSize_num = dlFdSchedData_column_list.index('tbSize') + last_col_num + 1
        cqi_num = dlFdSchedData_column_list.index('rrmCorrAvgCqi') + last_col_num + 1
        list_index_dl = []
        list_index_dl.append(rnti_num)
        list_index_dl.append(mcs_num)
        list_index_dl.append(ptrs_num)
        list_index_dl.append(prb_num)
        list_index_dl.append(PCI_num)
        list_index_dl.append(sfn_num)
        list_index_dl.append(slot_num)
        list_index_dl.append(tbSize_num)
        list_index_dl.append(cqi_num)
        return list_index_dl

    def get_ul_params_col_index(self, file_path):
        last_col_num = None
        with open(file_path) as f:
            lines = f.readlines()
            for line in lines:
                if 'ulFdSchedData: sfn' in line:
                    ulFdSchedData_column_list = line.split(',')
                    break
        for i, value in enumerate(ulFdSchedData_column_list):
            if value.isdigit():
                last_col_num = i
                break
        rnti_num = ulFdSchedData_column_list.index('rnti') + last_col_num + 1
        mcs_num = ulFdSchedData_column_list.index('rrmUlUsedMcs') + last_col_num + 1
        ptrs_num = ulFdSchedData_column_list.index('ptrsFlagUlProposedMcs') + last_col_num + 1
        prb_num = ulFdSchedData_column_list.index('numOfPrb') + last_col_num + 1
        PCI_num = ulFdSchedData_column_list.index('physCellId') + last_col_num + 1
        sfn_num = ulFdSchedData_column_list.index('ulFdSchedData: sfn') + last_col_num + 1
        slot_num = ulFdSchedData_column_list.index('slot') + last_col_num + 1
        tbSize_num = ulFdSchedData_column_list.index('tbSize') + last_col_num + 1
        list_index_ul = []
        list_index_ul.append(rnti_num)
        list_index_ul.append(mcs_num)
        list_index_ul.append(ptrs_num)
        list_index_ul.append(prb_num)
        list_index_ul.append(PCI_num)
        list_index_ul.append(sfn_num)
        list_index_ul.append(slot_num)
        list_index_ul.append(tbSize_num)
        return list_index_ul

    def get_index_according_to_value(self, list, expect_value):
        list_index = []
        for index, value in enumerate(list):
            if value == expect_value:
                list_index.append(index)
                logging.debug("list_index value: {}".format(list_index))
        return list_index

    def getindexwithslot(self, file_path, rnti, event_name, rnti_index_in_target_event, index_slot, expect_value):
        """
        Author: Yang Mengli
        Description: Get slot from event trace log
        :param file_path: log file path with csv format:
                         /XXX/XXX/TA_Combine_dl_Full_20210108094424.csv
                         /XXX/XXX/TA_Combine_ul_Full_20210108094424.csv
        :param rnti: Each UE will have one unique rnti, so rnti can stand for a ue
        :param event_name: here is event name, eg:dlFdSchedData
        :param rnti_index_in_target_event: INDEX_dlFdSchedData_rnti
        :param index_slot:INDEX_dlFdSchedData_slot
        :return: slot with list format
        """
        target_event = self.get_event_by_rnti(file_path, rnti, event_name, rnti_index_in_target_event)
        column = index_slot - 1
        column_list = []
        list_index = []
        for row in target_event:
            column_list.append(int(row[1][column]))
            list_index = [index for (index, value) in enumerate(column_list) if value == expect_value]
        return column_list, list_index

    def get_all_index_according_to_value(self, list, expect_value):
        list_index = [index for (index, value) in enumerate(list) if value == expect_value]
        logging.debug("list_index value: {}".format(list_index))
        return list_index

    def get_value_according_to_index(self, list, expect_index):
        list_value = []
        for index, value in enumerate(list):
            if index == expect_index:
                print(index, value)
                list_value.append(value)
                return list_value

    def get_same_value_from_two_list(self, list1, list2):
        list_value = []
        for i in range(len(list1)):
            for j in range(len(list2)):
                if list1[i] == list2[j]:
                    list_value.append(list1[i])
                    return list_value

    def check_column_in_csv(self, file_path, column_name):
        with open(file_path, 'r') as csvfile:
            csv_reader = csv.reader(csvfile)
            for row in csv_reader:
                for cell in row:
                    if column_name in cell:
                        return cell
        return False
