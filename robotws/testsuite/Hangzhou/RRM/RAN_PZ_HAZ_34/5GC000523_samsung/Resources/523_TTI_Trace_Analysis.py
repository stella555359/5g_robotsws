# -*- coding: utf-8 -*

"""
Author:         miao.1.lu
Contact Mail:   debbie.wang@nokia-sbell.com
Description:    Event trace log analysis
                Column index may changes in different program, so when
                you will need to set value for program.
                If program is not set, it's default to 19B
"""
import logging
import os
import sys
from collections import Counter
import csv
import re
from taf.analyzer.ttitrace import *
from check_csv_log import *
from robot.libraries.BuiltIn import BuiltIn
import linecache


class Parameters19B(object):
    NDIGITS = 2
    INDEX_event = 1

    # ul
    INDEX_ulFdSchedData_SFN = 45
    INDEX_ulFdSchedData_rnti = 47
    INDEX_ulFdSchedData_enevt = 45
    INDEX_ulFdSchedData_txNumber = 67
    INDEX_ulFdSchedData_tbsize = 65
    INDEX_ulFdSchedData_physCellId = 48
    INDEX_ulFdSchedData_pbr = 62
    INDEX_ulFdSchedData_cellDbIndex = 49
    INDEX_ulFdSchedData_rrmUlUsedMcs = 51
    INDEX_ulFdSchedData_rrmUlProposedMcs = 52

    INDEX_ulTdSchedSubcellData_rnti = 45
    INDEX_ulTdSchedSubcellData_resReqClassPrio = 46

    # dl
    INDEX_dlFdSchedData_SFN = 96                                # for sfn
    INDEX_dlFdSchedData_rnti = 98
    INDEX_dlFdSchedData_physCellId = 99
    INDEX_dlFdSchedData_numOfLayers = 124  # for layer check
    INDEX_dlFdSchedData_PMI = 125  # for PMI check
    INDEX_dlFdSchedData_rrmCorrAvgCqi = 129  # for average CQI
    INDEX_dlFdSchedData_txNumber = 118  # for dl bler check
    INDEX_dlFdSchedData_tbsize = 115
    INDEX_dlFdSchedData_rrmDlUsedMcs = 102
    INDEX_dlFdSchedData_rrmDlProposedMcs = 103

    INDEX_dlTdSchedSubcellData_rnti = 45
    INDEX_dlTdSchedSubcellData_resReqClassPrio = 46

    INDEX_csiSrReportData_rnti = 19
    INDEX_csiSrReportData_sfn = 17

    INDEX_dlLaDeltaCqi_rnti = 13
    INDEX_dlLaDeltaCqi_isDeltaCqiCalculated = 16
    INDEX_dlLaDeltaCqi_harqFb = 18
    INDEX_dlLaDeltaCqi_rrmDeltaCqi = 19


class ParametersTrunk(object):
    NDIGITS = 2
    INDEX_event = 1
    INDEX_ulFdSchedData_rnti = 63
    INDEX_ulFdSchedData_SFN = 61
    INDEX_ulFdSchedData_physCellId = 64
    INDEX_ulFdSchedData_pbr = 80
    INDEX_ulFdSchedData_cellDbIndex = 65
    INDEX_ulFdSchedData_txNumber = 93
    INDEX_ulFdSchedData_tbsize = 83
    INDEX_ulFdSchedData_rrmUlUsedMcs = 68
    INDEX_ulFdSchedData_rrmUlProposedMcs = 69
    INDEX_ulTdSchedSubcellData_rnti = 46
    INDEX_ulTdSchedSubcellData_resReqClassPrio = 47
    INDEX_dlFdSchedData_SFN = 141  # for sfn
    INDEX_dlFdSchedData_rnti = 143
    INDEX_dlFdSchedData_physCellId = 144
    INDEX_dlFdSchedData_rrmDlUsedMcs = 148  # for dl MCS calculate
    INDEX_dlFdSchedData_txNumber = 165  # for dl bler check
    INDEX_dlFdSchedData_tbsize = 161
    INDEX_dlFdSchedData_rrmDlProposedMcs = 149
    INDEX_dlTdSchedSubcellData_rnti = 46
    INDEX_dlTdSchedSubcellData_resReqClassPrio = 47
    INDEX_dlLaDeltaCqi_rnti = 266
    INDEX_dlLaDeltaCqi_isDeltaCqiCalculated = 269
    INDEX_dlLaDeltaCqi_harqFb = 271
    INDEX_dlLaDeltaCqi_rrmDeltaCqi = 272
    INDEX_dlFdSchedData_numOfLayers = 171  # for layer check
    INDEX_dlFdSchedData_PMI = 172  # for PMI check
    INDEX_dlFdSchedData_rrmCorrAvgCqi = 181  # for average CQI
    INDEX_csiSrReportData_rnti = 30
    INDEX_csiSrReportData_sfn = 28


class Parameters20B(object):
    NDIGITS = 2
    INDEX_event = 1
    INDEX_ulFdSchedData_rnti = 59
    INDEX_ulFdSchedData_SFN = 57
    INDEX_ulFdSchedData_physCellId = 60
    INDEX_ulFdSchedData_pbr = 76
    INDEX_ulFdSchedData_cellDbIndex = 61
    INDEX_ulFdSchedData_txNumber = 89
    INDEX_ulFdSchedData_tbsize = 79
    INDEX_ulFdSchedData_rrmUlUsedMcs = 64
    INDEX_ulFdSchedData_rrmUlProposedMcs = 65
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


class Parameters21A(object):
    NDIGITS = 2
    INDEX_event = 1
    INDEX_ulFdSchedData_rnti = 65
    INDEX_ulFdSchedData_SFN = 63
    INDEX_ulFdSchedData_physCellId = 66
    INDEX_ulFdSchedData_pbr = 75
    INDEX_ulFdSchedData_cellDbIndex = 67
    INDEX_ulFdSchedData_txNumber = 95
    INDEX_ulFdSchedData_tbsize = 85
    INDEX_ulFdSchedData_rrmUlUsedMcs = 70
    INDEX_ulFdSchedData_rrmUlProposedMcs = 71
    INDEX_ulTdSchedSubcellData_rnti = 40
    INDEX_ulTdSchedSubcellData_resReqClassPrio = 46
    INDEX_dlFdSchedData_SFN = 142  # for sfn
    INDEX_dlFdSchedData_rnti = 144
    INDEX_dlFdSchedData_physCellId = 145
    INDEX_dlFdSchedData_rrmDlUsedMcs = 149  # for dl MCS calculate
    INDEX_dlFdSchedData_txNumber = 166  # for dl bler check
    INDEX_dlFdSchedData_tbsize = 162
    INDEX_dlFdSchedData_rrmDlProposedMcs = 150
    INDEX_dlTdSchedSubcellData_rnti = 46
    INDEX_dlTdSchedSubcellData_resReqClassPrio = 47
    INDEX_dlLaDeltaCqi_rnti = 266
    INDEX_dlLaDeltaCqi_isDeltaCqiCalculated = 269
    INDEX_dlLaDeltaCqi_harqFb = 271
    INDEX_dlLaDeltaCqi_rrmDeltaCqi = 272
    INDEX_dlFdSchedData_numOfLayers = 172  # for layer check
    INDEX_dlFdSchedData_PMI = 173  # for PMI check
    INDEX_dlFdSchedData_rrmCorrAvgCqi = 182  # for average CQI
    INDEX_csiSrReportData_rnti = 30
    INDEX_csiSrReportData_sfn = 28


class Parameters21B(object):
    NDIGITS = 2
    INDEX_event = 1
    INDEX_ulFdSchedData_rnti = 76
    INDEX_ulFdSchedData_SFN = 74
    INDEX_ulFdSchedData_physCellId = 77
    INDEX_ulFdSchedData_pbr = 86
    INDEX_ulFdSchedData_cellDbIndex = 78
    INDEX_ulFdSchedData_txNumber = 109
    INDEX_ulFdSchedData_tbsize = 96
    INDEX_ulFdSchedData_rrmUlUsedMcs = 81
    INDEX_ulFdSchedData_rrmUlProposedMcs = 82
    INDEX_ulTdSchedSubcellData_rnti = 40
    INDEX_ulTdSchedSubcellData_resReqClassPrio = 46
    INDEX_dlFdSchedData_SFN = 153  # for sfn
    INDEX_dlFdSchedData_rnti = 155
    INDEX_dlFdSchedData_physCellId = 156
    INDEX_dlFdSchedData_rrmDlUsedMcs = 160  # for dl MCS calculate
    INDEX_dlFdSchedData_txNumber = 179  # for dl bler check
    INDEX_dlFdSchedData_tbsize = 173
    INDEX_dlFdSchedData_rrmDlProposedMcs = 161
    INDEX_dlTdSchedSubcellData_rnti = 57
    INDEX_dlTdSchedSubcellData_resReqClassPrio = 58
    INDEX_dlLaDeltaCqi_rnti = 266
    INDEX_dlLaDeltaCqi_isDeltaCqiCalculated = 269
    INDEX_dlLaDeltaCqi_harqFb = 271
    INDEX_dlLaDeltaCqi_rrmDeltaCqi = 272
    INDEX_dlFdSchedData_numOfLayers = 172  # for layer check
    INDEX_dlFdSchedData_PMI = 173  # for PMI check
    INDEX_dlFdSchedData_rrmCorrAvgCqi = 182  # for average CQI
    INDEX_csiSrReportData_rnti = 30
    INDEX_csiSrReportData_sfn = 28


class TTI_Trace_analysis(object):
    def __init__(self, program=None):
        if program == "19B" or program is None:
            self.parameters = Parameters19B()
        elif program.lower() == "trunk":
            self.parameters = ParametersTrunk()
        elif program.lower() == "20b":
            self.parameters = Parameters20B()
        elif program.lower() == "21a":
            self.parameters = Parameters21A()
        elif program.lower() == "21b":
            self.parameters = Parameters21B()
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
            TdSchedSubcellData_event_with_data_traffic = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.parameters.INDEX_event],
                expected_list=["ulTdSchedSubcellData: sfn"])
        except LookupError:
            raise LookupError("no event found for ulTdSchedSubcellData")
        rnti = TdSchedSubcellData_event_with_data_traffic[1][
            self.parameters.INDEX_ulTdSchedSubcellData_rnti - 1]
        logging.info("Current available rnti is: {}".format(rnti))
        return rnti

    def get_transmission_direction_from_file_name(self, file_path):
        """
        Author: Ding Binmei
        Description: Get direction based on input csv file name
        :param file_path: log file path with csv format: /XXX/XXX/TA_Combine_dl_Full_20190220123609.csv
        :return: ul or dl
        """
        file_name = file_path.split('/')[-1].lower()
        file_name_with_direction_info = file_name.split("_full_")[
            0].split("_")[-1]
        if file_name_with_direction_info.find('ul') != -1:
            return 'ul'
        elif file_name_with_direction_info.find('dl') != -1:
            return 'dl'
        else:
            raise Exception("Fail to get direction based on file name")

    def get_multi_rntis(self, file_path):
        """
        :param file_path:
        :return:
        """
        try:
            ulFdSchedData_event_with_data_traffic = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.parameters.INDEX_event],
                expected_list=["ulFdSchedData: sfn"])
        except LookupError:
            raise LookupError(
                "Fail to get rnti as no event found for ulFdSchedData: sfn with resReqClassPrio")
        rntis, ue_rnti_number = self.get_unique_values_in_column(
            matrix=ulFdSchedData_event_with_data_traffic, column_number=self.parameters.INDEX_ulFdSchedData_rnti)
        print("Current available rntis are: {}".format(rntis))
        return rntis, ue_rnti_number

    def get_unique_values_in_column(self, matrix, column_number):
        column = self.get_column_from_matrix(matrix, column_number)
        result = list(set(column))
        ue_rnti_number = Counter(column)
        return result, ue_rnti_number

    def get_column_from_matrix(self, matrix, column_nubmer):
        column = int(column_nubmer) - 1
        column_list = []
        for row in matrix:
            column_list.append(row[1][column])
        return column_list

    def check_each_ue_schedule_ratio(
            self, ue_rnti_number, rnti_list, tolerance):
        ue1_number = ue_rnti_number[rnti_list[0]]
        ue2_number = ue_rnti_number[rnti_list[1]]
        ue3_number = ue_rnti_number[rnti_list[2]]
        sum_number = int(ue1_number) + int(ue2_number) + int(ue3_number)
        ue1_ratio = float(ue1_number) / float(sum_number)
        ue2_ratio = float(ue2_number) / float(sum_number)
        ue3_ratio = float(ue3_number) / float(sum_number)
        ue1_2_diff = abs(ue1_ratio - ue2_ratio)
        ue1_3_diff = abs(ue1_ratio - ue3_ratio)
        ue2_3_diff = abs(ue2_ratio - ue3_ratio)
        if ue1_2_diff >= tolerance or ue1_3_diff >= tolerance or ue2_3_diff >= tolerance:
            raise Exception('the multi ue not be scheduled equally')

    def get_dlLaDeltaCqi_event(self, file_path):
        rnti = self.get_rnti(file_path=file_path)
        try:
            dlLaDeltaCqi_event = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[
                    self.parameters.INDEX_event,
                    self.parameters.INDEX_dlLaDeltaCqi_rnti],
                expected_list=["dlLaDeltaCqi: rnti", rnti])
        except LookupError:
            raise LookupError("No dlLaDeltaCqi event found")
        else:
            return dlLaDeltaCqi_event

    def get_dlFdSchedData_event(self, file_path, rnti):
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

    def get_min_tbsize_from_rnti(self, file_path, rnti_list, direction='dl'):
        FdSchedData_event_min_tbsize_dict = {}
        direction = direction.lower()
        tbsize_list = []
        try:
            for rnti in rnti_list:
                rnti_dict = {}
                FdSchedData_event = self.get_fdSchedData_event(
                    file_path, rnti, direction)
                if direction == 'dl':
                    index_tbsize = self.parameters.INDEX_dlFdSchedData_tbsize
                else:
                    index_tbsize = self.parameters.INDEX_ulFdSchedData_tbsize
                for i in range(0, len(FdSchedData_event)):
                    cur_tbsize = int(FdSchedData_event[i][1][index_tbsize - 1])
                    tbsize_list.append(cur_tbsize)
                min_tbsize = min(tbsize_list)
                rnti_dict.update({'min_tbsize': min_tbsize})
                FdSchedData_event_min_tbsize_dict.update(
                    {str(rnti): rnti_dict})
        except LookupError:
            raise LookupError("No tbsize found")
        else:
            return FdSchedData_event_min_tbsize_dict

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

    def get_sfn_tbsize_according_fdSchedData(
            self, fdSchedData_data, direction):
        sfn_list = []
        tbsize_list = []
        if direction.lower() == 'dl':
            index_tbsize = self.parameters.INDEX_dlFdSchedData_tbsize
            index_sfn = self.parameters.INDEX_dlFdSchedData_SFN
        else:
            index_tbsize = self.parameters.INDEX_ulFdSchedData_tbsize
            index_sfn = self.parameters.INDEX_ulFdSchedData_SFN

        for i in range(0, len(fdSchedData_data)):
            cur_tbsize = int(fdSchedData_data[i][1][index_tbsize - 1])
            sfn = int(fdSchedData_data[i][1][index_sfn - 1])
            tbsize_list.append(cur_tbsize)
            sfn_list.append(sfn)
        return sfn_list, tbsize_list

    def get_20_sfn_diff_tbsize(self, sfn_list, tbsize_list):
        if len(sfn_list) >= 20:
            sfn_count = 20
        else:
            sfn_count = len(sfn_list)
        sfn_diff_list = []
        tbsize_sub_list = None
        for i in range(0, sfn_count - 1):
            diff1 = abs(sfn_list[i + 1] - sfn_list[i])
            sfn_diff_list.append(diff1)
            tbsize_sub_list = tbsize_list
        return sfn_diff_list, tbsize_sub_list

    def get_csiSrReportData_sfn_by_rnti(self, file_path, rnti):
        csiSrReportData_event = get_lines_with_multiple_column_filter(
            file_path=file_path,
            column_list=[self.parameters.INDEX_event],
            expected_list=["csiSrReportData: sfn"])
        sfn_list = []
        sfn_diff_list = []
        for i in range(0, len(csiSrReportData_event)):
            sfn = int(
                csiSrReportData_event[i][1][self.parameters.INDEX_csiSrReportData_sfn - 1])
            sfn_list.append(sfn)
        for i in range(0, len(sfn_list) - 1):
            diff = abs(sfn_list[i + 1] - sfn_list[i])
            sfn_diff_list.append(diff)
        return sfn_list, sfn_diff_list

    def get_ulFdSchedData_numofprb_and_tbsize(self, ul_file_path):
        tbsize_prb_dict = {}
        rntis, ue_rnti_number = self.get_multi_rntis(ul_file_path)
        fdSchedData_event = self.get_fdSchedData_event(
            ul_file_path, rntis[0], 'ul')
        index_tbsize = self.parameters.INDEX_ulFdSchedData_tbsize
        index_prb = self.parameters.INDEX_ulFdSchedData_pbr
        for i in range(0, len(fdSchedData_event)):
            cur_tbsize = int(fdSchedData_event[i][1][index_tbsize - 1])
            num_of_prb = int(fdSchedData_event[i][1][index_prb - 1])
            tbsize_prb_dict.update({cur_tbsize: num_of_prb})
        return tbsize_prb_dict

    def get_rrmUsedMcs(self, file_path, direction):
        direction = direction.lower()
        event_name = 'dlFdSchedData: sfn'
        dlFdSchedData_rrmUsedMcs_index = self.parameters.INDEX_dlFdSchedData_rrmDlUsedMcs
        dlFdSchedData_rrmDlProposedMcs_index = self.parameters.INDEX_dlFdSchedData_rrmDlProposedMcs
        if direction == 'ul':
            event_name = 'ulFdSchedData: sfn'
            dlFdSchedData_rrmUsedMcs_index = self.parameters.INDEX_ulFdSchedData_rrmUlUsedMcs
            dlFdSchedData_rrmDlProposedMcs_index = self.parameters.INDEX_ulFdSchedData_rrmUlProposedMcs
        fdSchedData_event = get_lines_with_multiple_column_filter(
            file_path=file_path,
            column_list=[self.parameters.INDEX_event],
            expected_list=[event_name])
        rrmUsedMcs_list = []
        full_rrmUsedMcs = 0
        for i in range(0, len(fdSchedData_event)):
            rrmUsedMcs = int(
                fdSchedData_event[i][1][dlFdSchedData_rrmUsedMcs_index - 1])
            rrmDlProposedMcs = int(
                fdSchedData_event[i][1][dlFdSchedData_rrmDlProposedMcs_index - 1])
            rrmUsedMcs_list.append(rrmUsedMcs)
            if rrmUsedMcs < rrmDlProposedMcs:
                full_rrmUsedMcs += 1
        return rrmUsedMcs_list, full_rrmUsedMcs

    def get_rrmProposedMcs(self, file_path, direction):
        direction = direction.lower()
        event_name = 'dlFdSchedData: sfn'
        dlFdSchedData_rrmProposedMcs_index = self.parameters.INDEX_dlFdSchedData_rrmDlProposedMcs
        if direction == 'ul':
            event_name = 'ulFdSchedData: sfn'
            dlFdSchedData_rrmProposedMcs_index = self.parameters.INDEX_ulFdSchedData_rrmUlProposedMcs
        fdSchedData_event = get_lines_with_multiple_column_filter(
            file_path=file_path,
            column_list=[self.parameters.INDEX_event],
            expected_list=[event_name])
        rrmProposedMcs_list = []
        for i in range(0, len(fdSchedData_event)):
            rrmProposedMcs = int(
                fdSchedData_event[i][1][dlFdSchedData_rrmProposedMcs_index - 1])
            rrmProposedMcs_list.append(rrmProposedMcs)
        return rrmProposedMcs_list

    def get_event_by_rnti(self, file_path, rnti, event_name,
                          rnti_index_in_target_event):
        try:
            target_event = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[
                    self.parameters.INDEX_event,
                    rnti_index_in_target_event],
                expected_list=[event_name, rnti])
        except LookupError:
            raise LookupError("No {} event found".format(event_name))
        else:
            return target_event

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

    def calculate_dl_bler(self, file_path, rnti, direction):
        FdSchedData_event = self.get_fdSchedData_event(
            file_path, rnti, direction)
        if direction.lower() == 'dl':
            index_txnumber = self.parameters.INDEX_dlFdSchedData_txNumber
        else:
            index_txnumber = self.parameters.INDEX_ulFdSchedData_txNumber
        # dlFdSchedData_event = self.get_dlFdSchedData_event(file_path=file_path,rnti=rnti)
        try:
            txNum_with_1_event = add_filters_to_matrix(
                FdSchedData_event,
                [index_txnumber, ['1']])
            count_txNum_with_1 = len(txNum_with_1_event)
        except LookupError:
            count_txNum_with_1 = 0
        try:
            txNum_with_2_event = add_filters_to_matrix(
                FdSchedData_event,
                [index_txnumber, ['2']])
            count_txNum_with_2 = len(txNum_with_2_event)
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


def get_version(AT_PATH):
    import string
    import re
    A19_list = [6.8351, 5.8352, 6.28351, 6.28352, 6.38351, 6.38352]
    B19_list = [7.1836, 7.1816, 7.2836, 7.2816, 7.3836, 7.3816]
    master_list = [0.816, 0.836, 0.830, 0.810, 0.800]
    A20_list = [9.1800]
    stream_version = str.split(AT_PATH, '/')[-2]
    pattern = re.compile(r'^(\d+).(\d+)')
    stream = re.search(pattern, stream_version).group(1)
    version = None
    if stream in A19_list:
        version = '19A'
    elif stream in B19_list:
        version = '19B'
    elif stream in master_list:
        version = 'trunk'
    elif stream in A20_list:
        version = '20A'
    return version


# tti_trace_analysis_19B = TTI_Trace_analysis(tl.version)
tti_trace_analysis_19B = TTI_Trace_analysis('Trunk')


def get_multi_rntis_from_tti_trace_19b(path):
    """
    - get multi rnti according ul tti trace
    :param path:
    :return: rnti list
    """
    return tti_trace_analysis_19B.get_multi_rntis(path)


def get_min_tbsize_from_tti_trace_19b(file_path, rnti_list, direction='dl'):
    return tti_trace_analysis_19B.get_min_tbsize_from_rnti(
        file_path, rnti_list, direction)


def calculate_dl_bler_from_tti_trace_19b(file_path, rnti, direction):
    return tti_trace_analysis_19B.calculate_dl_bler(file_path, rnti, direction)


def check_each_ue_schedule_ratio_19b(ue_rnti_number, rnti_list, tolerance=0.1):
    return tti_trace_analysis_19B.check_each_ue_schedule_ratio(
        ue_rnti_number, rnti_list, tolerance)


def get_fdscheddata_event_from_tti_trace_19b(file_path, rnti, direction):
    return tti_trace_analysis_19B.get_fdSchedData_event(
        file_path, rnti, direction)


def get_sfn_tbsize_according_fdscheddata_19b(fdSchedData_data, direction):
    return tti_trace_analysis_19B.get_sfn_tbsize_according_fdSchedData(
        fdSchedData_data, direction)


def get_sfn_diff_tbsize_19b(sfn_list, tbsize_list):
    return tti_trace_analysis_19B.get_20_sfn_diff_tbsize(sfn_list, tbsize_list)


def get_csisrreportdata_sfn_by_rnti_19b(file_path, rnti):
    return tti_trace_analysis_19B.get_csiSrReportData_sfn_by_rnti(
        file_path, rnti)


def get_rrmUsedMcs_19b(file_path, direction):
    return tti_trace_analysis_19B.get_rrmUsedMcs(file_path, direction)


def get_rrmProposedMcs_19b(file_path, direction):
    return tti_trace_analysis_19B.get_rrmProposedMcs(file_path, direction)


def get_ulFdSchedData_numofprb_and_tbsize_19b(file_path_dict):
    ul_file_path = file_path_dict['UL']
    return tti_trace_analysis_19B.get_ulFdSchedData_numofprb_and_tbsize(
        ul_file_path)


def Get_X2log_Element_Value_From_List(element_list, txt_file):
    element_dict = {}
    for element in element_list:
        element_dict[element] = []
    with open(txt_file, 'r') as file:
        for line in file.readlines():
            line_content = line.strip(' ')
            for element in element_list:
                if line_content.startswith(element + ':'):
                    element_value = re.findall(r'\d+', line_content.split(':')[-1])
                    for value in element_value:
                        element_dict[element].append(value)
    file.close()
    return element_dict


def Get_txt_content_By_Linecache(txt_file, element, check_element):
    count = len(open(txt_file).readlines())
    for i in range(0, count):
        line_txt = linecache.getline(txt_file, i)
        if line_txt.strip(' ').split(':')[0] == element:
            for new_line_index in range(i, count):
                new_line_txt = linecache.getline(txt_file, new_line_index)
                if new_line_txt.strip(' ').startswith(check_element):
                    return int(new_line_txt.strip('\n').split(':')[-1])


def Get_Element_Value_From_Bip_Log(element, txt_file, exp_value):
    with open(txt_file, 'r') as file:
        for line in file.readlines():
            line_content = line.strip(' ')
            if line_content.startswith(element):
                element_value = line_content.split(':')[-1]
                if exp_value in element_value:
                    return True
    return False


def Check_symbolLocation_p1_Value(txt_file, check_parameter1, check_parameter2):
    count = len(open(txt_file).readlines())
    check_parameter1_line_index = []
    check_parameter2_value_list = []
    tmp_parameter_list = []
    for i in range(0, count):
        line_txt1 = linecache.getline(txt_file, i)
        if check_parameter1 in line_txt1:
            check_parameter1_line_index.append(i)
            for j in range(i, 0, -1):
                line_txt2 = linecache.getline(txt_file, j)
                if 'Item ' in line_txt2:
                    tmp_parameter_list.append(j)
                    break
    for line_index in range(0, len(check_parameter1_line_index)):
        for line in range(tmp_parameter_list[line_index], check_parameter1_line_index[line_index]):
            line_txt3 = linecache.getline(txt_file, line)
            if check_parameter2 in line_txt3:
                check_parameter2_value = re.search(r'\d+', line_txt3).group()
                check_parameter2_value_list.append(check_parameter2_value)
    return check_parameter2_value_list


def Get_Attach_ue_rnti(rnti_list, ue_rnti_number):
    attach_list = []
    for key in rnti_list:
        if ue_rnti_number[key] > 1:
            attach_list.append(key)
    return attach_list


def Covert_BTS_Version(version):
    package = version.split('_')[0]
    if package == 'SBTS22R1':
        scf_name = 'SCF_SBTS22R1.xml'
    elif package == 'SBTS21B':
        scf_name = 'SCF_SBTS21B.xml'
    else:
        scf_name = 'SCF_SBTS00.xml'
    return scf_name
