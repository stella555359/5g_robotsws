# -*- coding: utf-8 -*

"""
Author:         Lin jiangjing
Contact Mail:   jiangjing.lin@nokia-sbell.com
Description:    Common check for event trace log analysis, like bler verification, get events...
                Please do not modify the file without the permission from author
"""
import logging
import csv
import os
from taf.transport.ssh import ssh
ssh = ssh()


def getfilename(path, direction):
    return path.get(direction)


def valueCompare(ttivalue, expect):
    """
    compare the value in the tti log with the expect value

    :param ttivalue: list: all values of the specified parameter in the tti log excel
    :param expect: int: expect value of the parameter
    :option: int: 1-compare with the average value of the list, 2-compare with each value of the list
    :return: average value of the ttivalue list and the compare result
             average is -1 when option is 2
    """
    expect = float(expect)
    result = True
    sum = 0
    average = -1
    length = len(ttivalue)
    for i in range(length):
        sum += float(ttivalue[i])
    average = sum/length
    if average < expect:
        result = False
    return average, result


def ttifilesClear(path):
    try:
        csv_path_list = []
        paths = os.listdir(path)
        for item in paths:
            if item.startswith("TA_Combine_") and item.endswith(".csv"):
                path_absolute = path+"/"+item
                csv_path_list.append(path_absolute)
        if len(csv_path_list) >= 20:
            for csv_path in csv_path_list:
                os.remove(csv_path)
    except Exception as e:
        print(e)


def get_dl_params_col_index(file_path):
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
    cqi_num = dlFdSchedData_column_list.index('rrmCorrAvgCqi') + last_col_num + 1
    ptrs_num = dlFdSchedData_column_list.index('ptrsFlagDlProposedMcs') + last_col_num + 1
    prb_num = dlFdSchedData_column_list.index('numOfPrb') + last_col_num + 1
    list_index_dl = []
    list_index_dl.append(rnti_num)
    list_index_dl.append(mcs_num)
    list_index_dl.append(cqi_num)
    list_index_dl.append(ptrs_num)
    list_index_dl.append(prb_num)
    return list_index_dl


def get_ul_params_col_index(file_path):
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
    list_index_ul = []
    list_index_ul.append(rnti_num)
    list_index_ul.append(mcs_num)
    list_index_ul.append(ptrs_num)
    list_index_ul.append(prb_num)
    return list_index_ul


class TTI_trace_log_analysis(object):
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
        Author: Lin jiangjing
        Description: Get direction based on input csv file name
        :param file_path: log file path with csv format:
                         /XXX/XXX/TA_Combine_dl_Full_20200810110951.csv
                         /XXX/XXX/TA_Combine_ul_Full_220200810110951.csv
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
        Author: Lin Jiangjing
        Description: Get rntis from event trace log
                     Each UE will have one unique rnti, so rnti can stand for a ue
        :param file_path: log file path with csv format:
                         /XXX/XXX/TA_Combine_dl_Full_20200810110951.csv
                         /XXX/XXX/TA_Combine_ul_Full_220200810110951.csv
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
        return rntis[0]

    def get_event_by_rnti(self, file_path, rnti, event_name, rnti_index_in_target_event):
        """
        Author: Lin Jiangjing
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
        return float(len(prbs))/float(len(prbs_list))
