# -*- coding: utf-8 -*

"""
Author:         Wu Fangmin Modified for trunk
Contact Mail:   fangmin.wu@nokia-sbell.com
Description:    Event trace log analysis
                Column index may changes in different program, so when calling this file,
                you will need to set value for program. Currently supported versions are:  19B trunk
                If program is not set, it's default to trunk
"""
import logging
from check_csv_log import *
from collections import Counter
import re
import os


class Parameters19B(object):
    NDIGITS = 2
    INDEX_event = 1
    INDEX_dlFdSchedData_rnti = 98
    INDEX_dlFdSchedData_onAirTimeSlot = 97
    INDEX_dlFdSchedData_physCellId = 99
    INDEX_dlTdSchedSubcellData_rnti = 45
    INDEX_dlTdSchedSubcellData_resReqClassPrio = 46
    INDEX_ulFdSchedData_rnti = 45
    INDEX_ulFdSchedData_physCellId = 46
    INDEX_ulTdSchedSubcellData_rnti = 45
    INDEX_ulTdSchedSubcellData_resReqClassPrio = 46


class ParametersTrunk(object):
    NDIGITS = 2
    INDEX_event = 1
    INDEX_ulFdSchedData_rnti = 60
    INDEX_ulFdSchedData_SFN = 58
    INDEX_ulFdSchedData_physCellId = 61
    INDEX_ulFdSchedData_pbr = 77
    INDEX_ulFdSchedData_cellDbIndex = 62
    INDEX_ulFdSchedData_txNumber = 90
    INDEX_ulFdSchedData_tbsize = 80
    INDEX_ulFdSchedData_rrmUlUsedMcs = 65
    INDEX_ulFdSchedData_rrmUlProposedMcs = 66
    INDEX_ulTdSchedSubcellData_rnti = 45
    INDEX_ulTdSchedSubcellData_resReqClassPrio = 46
    INDEX_dlFdSchedData_SFN = 138  # for sfn
    INDEX_dlFdSchedData_rnti = 140
    INDEX_dlFdSchedData_physCellId = 141
    INDEX_dlFdSchedData_rrmDlUsedMcs = 145  # for dl MCS calculate
    INDEX_dlFdSchedData_txNumber = 162  # for dl bler check
    INDEX_dlFdSchedData_tbsize = 158
    INDEX_dlFdSchedData_rrmDlProposedMcs = 146
    INDEX_dlTdSchedSubcellData_rnti = 45
    INDEX_dlTdSchedSubcellData_resReqClassPrio = 46
    INDEX_dlLaDeltaCqi_rnti = 265
    INDEX_dlLaDeltaCqi_isDeltaCqiCalculated = 268
    INDEX_dlLaDeltaCqi_harqFb = 270
    INDEX_dlLaDeltaCqi_rrmDeltaCqi = 271
    INDEX_dlFdSchedData_numOfLayers = 168  # for layer check
    INDEX_dlFdSchedData_PMI = 169  # for PMI check
    INDEX_dlFdSchedData_rrmCorrAvgCqi = 178  # for average CQI
    INDEX_csiSrReportData_rnti = 30
    INDEX_csiSrReportData_sfn = 28


class Parameters20B(object):
    NDIGITS = 2
    INDEX_event = 1
    INDEX_ulFdSchedData_rnti = 58
    INDEX_ulFdSchedData_SFN = 56
    INDEX_ulFdSchedData_physCellId = 59
    INDEX_ulFdSchedData_pbr = 75
    INDEX_ulFdSchedData_cellDbIndex = 60
    INDEX_ulFdSchedData_txNumber = 88
    INDEX_ulFdSchedData_tbsize = 78
    INDEX_ulFdSchedData_rrmUlUsedMcs = 63
    INDEX_ulFdSchedData_rrmUlProposedMcs = 64
    INDEX_ulTdSchedSubcellData_rnti = 40
    INDEX_ulTdSchedSubcellData_resReqClassPrio = 46
    INDEX_dlFdSchedData_SFN = 99  # for sfn
    INDEX_dlFdSchedData_rnti = 101
    INDEX_dlFdSchedData_physCellId = 102
    INDEX_dlFdSchedData_rrmDlUsedMcs = 106  # for dl MCS calculate
    INDEX_dlFdSchedData_txNumber = 123  # for dl bler check
    INDEX_dlFdSchedData_tbsize = 119
    INDEX_dlFdSchedData_rrmDlProposedMcs = 107
    INDEX_dlTdSchedSubcellData_rnti = 45
    INDEX_dlTdSchedSubcellData_resReqClassPrio = 46
    INDEX_dlLaDeltaCqi_rnti = 265
    INDEX_dlLaDeltaCqi_isDeltaCqiCalculated = 268
    INDEX_dlLaDeltaCqi_harqFb = 270
    INDEX_dlLaDeltaCqi_rrmDeltaCqi = 271
    INDEX_dlFdSchedData_numOfLayers = 129   # for layer check
    INDEX_dlFdSchedData_PMI = 130  # for PMI check
    INDEX_dlFdSchedData_rrmCorrAvgCqi = 139  # for average CQI
    INDEX_csiSrReportData_rnti = 30
    INDEX_csiSrReportData_sfn = 28


class TTI_Trace_analysis(object):
    def __init__(self, program="Trunk"):
        if program == "5G19B" or program is None:
            self.parameters = Parameters19B()
        elif program == "Trunk":
            self.parameters = ParametersTrunk()
        elif program == "20B":
            self.parameters = Parameters20B()
        else:
            raise Exception("Invalid input for program.")

    def get_dl_rnti(self, file_path):
        """
        Filter for event dlTdSchedSubcellData and find resReqClassPrio=40,
        which means rnti used for DL data traffic in initial transmission.
        :param file_path: Example input : XXX/XXX/XXX.csv
        :return: rnti value
        """
        try:
            dlTdSchedSubcellData_event_with_data_traffic = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.parameters.INDEX_event],
                expected_list=["dlTdSchedSubcellData: sfn"])
        except LookupError:
            raise LookupError(
                "Fail to get rnti as no event found for dlTdSchedSubcellData with resReqClassPrio=40")
        rnti = dlTdSchedSubcellData_event_with_data_traffic[1][1][
            self.parameters.INDEX_dlTdSchedSubcellData_rnti - 1]
        logging.info("Current available rnti is: {}".format(rnti))
        return rnti

    def get_ul_rnti(self, file_path):
        """
        Filter for event ulTdSchedSubcellData and find resReqClassPrio=30,
        which means rnti used for UL data traffic in initial transmission.
        :param file_path: Example input : XXX/XXX/XXX.csv
        :return: rnti value
        """
        try:
            ulTdSchedSubcellData_event_with_data_traffic = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.parameters.INDEX_event],
                expected_list=["ulTdSchedSubcellData: sfn"])
        except LookupError:
            raise LookupError(
                "Fail to get rnti as no event found for ulTdSchedSubcellData with resReqClassPrio=30")
        rnti = ulTdSchedSubcellData_event_with_data_traffic[1][1][
            self.parameters.INDEX_ulTdSchedSubcellData_rnti - 1]
        logging.info("Current available rnti is: {}".format(rnti))
        return rnti

    def get_dlFdSchedData_event(self, file_path, rnti='none'):
        if rnti == 'none':
            rnti = self.get_dl_rnti(file_path=file_path)
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

    def get_ulFdSchedData_event(self, file_path, rnti='none'):
        if rnti == 'none':
            rnti = self.get_ul_rnti(file_path=file_path)
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

    def get_dl_physCellId_list(self, file_path, rnti='none'):
        if rnti == 'none':
            dlFdSchedData_event = self.get_dlFdSchedData_event(
                file_path=file_path)
        else:
            dlFdSchedData_event = self.get_dlFdSchedData_event(
                file_path=file_path, rnti=rnti)
        physCellId_list = []
        for i in range(0, len(dlFdSchedData_event)):
            physCellId = int(dlFdSchedData_event[i][1]
                             [self.parameters.INDEX_dlFdSchedData_physCellId - 1])
            if physCellId not in physCellId_list:
                physCellId_list.append(physCellId)
        return physCellId_list

    def get_ul_physCellId_list(self, file_path, rnti):
        if rnti == 'none':
            ulFdSchedData_event = self.get_ulFdSchedData_event(
                file_path=file_path)
        else:
            ulFdSchedData_event = self.get_ulFdSchedData_event(
                file_path=file_path, rnti=rnti)
        physCellId_list = []
        for i in range(0, len(ulFdSchedData_event)):
            physCellId = int(ulFdSchedData_event[i][1]
                             [self.parameters.INDEX_ulFdSchedData_physCellId - 1])
            if physCellId not in physCellId_list:
                physCellId_list.append(physCellId)
        return physCellId_list

    def get_multi_rntis_from_tti_trace(self, file_path, direction='UL'):
        direction = direction.upper()
        if direction == 'UL':
            try:
                ulFdSchedData_event_with_data_traffic = get_lines_with_multiple_column_filter(
                    file_path=file_path,
                    column_list=[self.parameters.INDEX_event],
                    expected_list=["ulFdSchedData: sfn"])
            except LookupError:
                raise LookupError(
                    "Fail to get rnti as no event found for ulTdSchedSubcellData")
            rntis, ue_rnti_number = self.get_unique_values_in_column(
                matrix=ulFdSchedData_event_with_data_traffic, column_number=self.parameters.INDEX_ulFdSchedData_rnti)
        else:
            try:
                dlFdSchedData_event_with_data_traffic = get_lines_with_multiple_column_filter(
                    file_path=file_path,
                    column_list=[self.parameters.INDEX_event],
                    expected_list=["dlFdSchedData: sfn"])
            except LookupError:
                raise LookupError(
                    "Fail to get rnti as no event found for dlTdSchedSubcellData")
            rntis, ue_rnti_number = self.get_unique_values_in_column(
                matrix=dlFdSchedData_event_with_data_traffic, column_number=self.parameters.INDEX_dlFdSchedData_rnti)
        print("Current available rntis are: {}".format(rntis))
        return rntis, ue_rnti_number

    def get_multi_cell_from_tti_trace(self, rnti, file_path, direction='DL'):
        direction = direction.upper()
        if direction == 'UL':
            try:
                ulFdSchedData_event_with_data_traffic = get_lines_with_multiple_column_filter(
                    file_path=file_path,
                    column_list=[
                        self.parameters.INDEX_event,
                        self.parameters.INDEX_ulFdSchedData_rnti],
                    expected_list=["ulFdSchedData: sfn", rnti])
            except LookupError:
                raise LookupError(
                    "Fail to get rnti as no event found for ulTdSchedSubcellData")
            cell, ue_cell_number = self.get_unique_values_in_column(
                matrix=ulFdSchedData_event_with_data_traffic,
                column_number=self.parameters.INDEX_ulFdSchedData_physCellId)
        else:
            try:
                dlFdSchedData_event_with_data_traffic = get_lines_with_multiple_column_filter(
                    file_path=file_path,
                    column_list=[
                        self.parameters.INDEX_event,
                        self.parameters.INDEX_dlFdSchedData_rnti],
                    expected_list=["dlFdSchedData: sfn", rnti])
            except LookupError:
                raise LookupError(
                    "Fail to get rnti as no event found for dlTdSchedSubcellData")
            cell, ue_cell_number = self.get_unique_values_in_column(
                matrix=dlFdSchedData_event_with_data_traffic,
                column_number=self.parameters.INDEX_dlFdSchedData_physCellId)
        print("Current available cell are: {}".format(cell))
        return cell, ue_cell_number

    def get_unique_values_in_column(self, matrix, column_number):
        column = self.get_column_from_matrix(matrix, column_number)
        result = list(set(column))
        ue_rnti_number = Counter(column)
        return result, ue_rnti_number

    def get_column_from_matrix(self, matrix, column_nubmer):
        column = int(column_nubmer) - 1
        column_list = []
        for row in matrix:
            if len(row[1]) > column:
                column_list.append(row[1][column])
        return column_list

    def check_each_ue_schedule_ratio(
            self, ue_rnti_number, rnti_list, tolerance):
        if len(rnti_list) == 2:
            ue1_number = ue_rnti_number[rnti_list[0]]
            ue2_number = ue_rnti_number[rnti_list[1]]
            sum_number = int(ue1_number) + int(ue2_number)
            ue1_ratio = float(ue1_number) / float(sum_number)
            ue2_ratio = float(ue2_number) / float(sum_number)
            ue1_2_diff = abs(ue1_ratio - ue2_ratio)
            print(ue1_2_diff)
            if float(ue1_2_diff) >= float(tolerance):
                raise Exception('the two cell not be scheduled equally')
        else:
            print(ue_rnti_number)
            raise Exception('Only get one cell,you have run again')

    def get_physCell_from_rnti(self, file_path, rnti_list, direction):
        try:
            for rnti in rnti_list:
                FdSchedData_event = self.get_fdSchedData_event(
                    file_path, rnti, direction)
                print(len(FdSchedData_event))
                if direction == 'dl':
                    index_scell = self.parameters.INDEX_dlFdSchedData_physCellId
                else:
                    index_scell = self.parameters.INDEX_ulFdSchedData_physCellId
                print(index_scell)
                for i in range(0, len(FdSchedData_event)):
                    cur_tbsize = int(FdSchedData_event[i][1][index_scell - 1])
                    cell_list.append(cur_tbsize)
                cell_list = list(set(cell_list))
                print(cell_list)
        except LookupError:
            raise LookupError("No cell found")
        else:
            return cell_list

    def get_fdSchedData_event(self, file_path, rnti, direction):
        direction = direction.lower()
        if direction == 'dl':
            fdSchedData_event_name = "dlFdSchedData: sfn"
            rnti_index_FdSchedData = self.parameters.INDEX_dlFdSchedData_rnti

        elif direction == 'ul':
            fdSchedData_event_name = "ulFdSchedData: sfn"
            rnti_index_FdSchedData = self.parameters.INDEX_ulFdSchedData_rnti
        else:
            raise Exception(
                "Un-supported direction value, available values are ul and dl")
        return self.get_event_by_rnti(file_path=file_path, rnti=rnti, event_name=fdSchedData_event_name,
                                      rnti_index_in_target_event=rnti_index_FdSchedData)

    def get_cell_idx(self, cell):
        cell_idx = int(cell[0]) - 49
        return cell_idx

    def get_physCell_from_dl(self, file_path):
        try:
            dlFdSchedData_event_with_data_traffic = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.parameters.INDEX_event],
                expected_list=["dlFdSchedData: sfn"])
        except LookupError:
            raise LookupError(
                "Fail to get rnti as no event found for dlTdSchedSubcellData: sfn with resReqClassPrio")

        physCellId_list = []
        for i in range(0, len(dlFdSchedData_event_with_data_traffic)):
            physCellId = int(dlFdSchedData_event_with_data_traffic[i][1]
                             [self.parameters.INDEX_dlFdSchedData_physCellId])
            if physCellId not in physCellId_list:
                physCellId_list.append(physCellId)
        return physCellId_list


tti_trace_analysis_trunk = TTI_Trace_analysis('20B')


def get_dl_physCellId_list_trunk(path, rnti='none'):
    return tti_trace_analysis_trunk.get_dl_physCellId_list(path, rnti)


def get_ul_physCellId_list_trunk(path, rnti='none'):
    return tti_trace_analysis_trunk.get_ul_physCellId_list(path, rnti)


def get_multi_rntis_from_tti_trace(path, direction='UL'):
    return tti_trace_analysis_trunk.get_multi_rntis_from_tti_trace(
        path, direction)


def get_multi_cell_from_tti_trace(rnti, path, direction='DL'):
    return tti_trace_analysis_trunk.get_multi_cell_from_tti_trace(
        rnti, path, direction)


def check_each_ue_schedule_ratio(ue_rnti_number, rnti_list, tolerance=0.1):
    return tti_trace_analysis_trunk.check_each_ue_schedule_ratio(
        ue_rnti_number, rnti_list, tolerance)


def get_physCell_from_rnti(file_path, rnti_list, direction='dl'):
    return tti_trace_analysis_trunk.get_physCell_from_rnti(
        file_path, rnti_list, direction)


def get_cell_idx(cell):
    return tti_trace_analysis_trunk.get_cell_idx(cell)


def get_physCell_from_dl(file_path):
    return tti_trace_analysis_trunk.get_physCell_from_dl(file_path)


def Find_Element_In_Wireshark(file_path, element):
    element_value_list = []
    with open(file_path, 'r') as file:
        for line in file.readlines():
            if element + ':' in line:
                tmp_emlement_value = re.findall(r'\d+', line)
                for value in tmp_emlement_value:
                    element_value_list.append(value)
    return element_value_list


def Get_Access_Cell_Id(cell_tp_list):
    dl_cell_list = []
    ul_cell_list = []
    cell_list = []
    for item in cell_tp_list:
        for cell_keys in item.keys():
            cell_list.append(cell_keys)
    for i in range(0, len(cell_tp_list)):
        if cell_tp_list[i][cell_list[i]][0] > 0:
            ul_cell_list.append(cell_list[i])
        if cell_tp_list[i][cell_list[i]][1] > 1:
            dl_cell_list.append(cell_list[i])
    ul_dl_cell_list = [{'ul': ul_cell_list}, {'dl': dl_cell_list}]
    return ul_dl_cell_list


def Get_Dl_Or_Ul_Access_Id(ul_dl_cell_list, cell_key):
    for cell_dict in ul_dl_cell_list:
        key_list = cell_dict.keys()
        if cell_key in key_list:
            cell_list = cell_dict[cell_key]
            return cell_list


def Get_Parameter_Value_By_Object_Name(get_object_value, dist_name, parameter_list):
    parameter_value_list = []
    for object_value in get_object_value:
        if dist_name in object_value['distName']:
            parameter_value_dict = object_value['parameters']
            for parameter in parameter_list:
                parameter_value_list.append(parameter_value_dict[parameter])
    return parameter_value_list


def Get_Modify_SCF_Basepath(file_path):
    dir_path = os.path.dirname(file_path)
    return dir_path
