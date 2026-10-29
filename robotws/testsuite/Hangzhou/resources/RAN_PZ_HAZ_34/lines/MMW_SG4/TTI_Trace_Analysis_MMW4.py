# -*- coding: utf-8 -*

"""
Author:         Hongyu.Jiang
Contact Mail:   hongyu.jiang@nokia-sbell.com
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
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.check_csv_log import *
# from resources.python_libs.check_csv_log import *
from robot.libraries.BuiltIn import BuiltIn
import linecache


class Parameters20B(object):
    NDIGITS = 2
    INDEX_event = 1


project_folder = os.path.abspath(
    os.path.join(
        os.path.dirname(__file__),
        "../../../../.."))


# sys.path.append(project_folder)


class TTI_Trace_analysis(object):
    def __init__(self, program=None):
        self.parameter_dict = {}
        if program == "20B" or program is None:
            self.parameters = Parameters20B()
        else:
            raise Exception("Invalid input for program.")

    def get_columns(self, reader_list, filter, column_name):
        for low in reader_list:
            if len(low) != 0:
                if str(low[0]) == str(filter):
                    low_length = int(len(low) / 2)
                    if low[1] == 'sfn' and column_name == filter:
                        column_index = low.index(column_name) + low_length + 2
                    else:
                        column_index = low.index(column_name) + low_length + 1
                    return column_index

    def get_not_null_columns(self, reader_list, filter, column_name):
        for low in reader_list:
            if len(low) != 0:
                if low[0] == filter:
                    tmp_low = [i for i in low if i != '']
                    low_length = int(len(tmp_low) / 2)
                    if low[1] == 'sfn' and column_name == filter:
                        column_index = low.index(column_name) + low_length + 2
                    else:
                        column_index = low.index(column_name) + low_length + 1
                    return column_index

    def get_Multiple_para_columns(self, reader_list, filter, column_name, column_index):
        tmp_low = []
        filter_column_list = []
        for low in reader_list:
            if len(low) != 0:
                if low[0] == filter:
                    tmp_low = low
                    filter_column_list = [i + 1 for i in range(0, len(tmp_low)) if tmp_low[i] == column_name]
                    break
        for i in range(0, len(tmp_low)):
            if tmp_low[i].isdigit():
                column = i + filter_column_list[column_index]
                return column

    def get_parameters_column(self, file_path, direction):
        with open(file_path, 'r') as csv_file:
            reader = list(csv.reader(csv_file))
        if direction.lower() == 'ul':
            self.parameter_dict['INDEX_ulFdSchedData_rnti'] = \
                self.get_columns(reader_list=reader, filter='ulFdSchedData: sfn', column_name='rnti')
            self.parameter_dict['INDEX_ulFdSchedData_SFN'] = \
                self.get_columns(reader_list=reader, filter='ulFdSchedData: sfn', column_name='ulFdSchedData: sfn')
            self.parameter_dict['INDEX_ulFdSchedData_slot'] = \
                self.get_columns(reader_list=reader, filter='ulFdSchedData: sfn', column_name='slot')
            self.parameter_dict['INDEX_ulFdSchedData_physCellId'] = \
                self.get_columns(reader_list=reader, filter='ulFdSchedData: sfn', column_name='physCellId')
            self.parameter_dict['INDEX_ulFdSchedData_pbr'] = \
                self.get_columns(reader_list=reader, filter='ulFdSchedData: sfn', column_name='numOfPrb')
            self.parameter_dict['INDEX_ulFdSchedData_cellDbIndex'] = \
                self.get_columns(reader_list=reader, filter='ulFdSchedData: sfn', column_name='cellDbIndex')
            self.parameter_dict['INDEX_ulFdSchedData_txNumber'] = \
                self.get_columns(reader_list=reader, filter='ulFdSchedData: sfn', column_name='txNumber')
            self.parameter_dict['INDEX_ulFdSchedData_tbsize'] = \
                self.get_columns(reader_list=reader, filter='ulFdSchedData: sfn', column_name='tbSize')
            self.parameter_dict['INDEX_ulFdSchedData_rrmUlUsedMcs'] = \
                self.get_columns(reader_list=reader, filter='ulFdSchedData: sfn', column_name='rrmUlUsedMcs')
            self.parameter_dict['INDEX_ulFdSchedData_rrmUlProposedMcs'] = \
                self.get_columns(reader_list=reader, filter='ulFdSchedData: sfn', column_name='rrmUlProposedMcs')
            self.parameter_dict['INDEX_ulFdSchedData_startPrb'] = \
                self.get_columns(reader_list=reader, filter='ulFdSchedData: sfn', column_name='startPrb')
            self.parameter_dict['INDEX_ulFdSchedData_rrmBufferedDataUlTotal_bytes'] = \
                self.get_columns(reader_list=reader, filter='ulFdSchedData: sfn',
                                 column_name='rrmBufferedDataUlTotal_bytes')
            self.parameter_dict['INDEX_ulFdSchedData_mcsTable'] = \
                self.get_columns(reader_list=reader, filter='ulFdSchedData: sfn', column_name='mcsTable')
            self.parameter_dict['INDEX_ulTdSchedSubcellData_rnti'] = \
                self.get_Multiple_para_columns(reader_list=reader, filter='ulTdSchedSubcellData: sfn',
                                               column_name='rnti', column_index=1)
            self.parameter_dict['INDEX_ulTdSchedSubcellData_resReqClassPrio'] = \
                self.get_Multiple_para_columns(reader_list=reader, filter='ulTdSchedSubcellData: sfn',
                                               column_name='resReqClassPrio', column_index=0)
            self.parameter_dict['INDEX_ulHarqRxData_sfn'] = \
                self.get_not_null_columns(reader_list=reader, filter='ulHarqRxData: sfn',
                                          column_name='ulHarqRxData: sfn')
            self.parameter_dict['INDEX_ulHarqRxData_crcResult'] = \
                self.get_not_null_columns(reader_list=reader, filter='ulHarqRxData: sfn', column_name='crcResult')
            self.parameter_dict['INDEX_ulFdSchedData_sinrDerivedMcs'] = \
                self.get_columns(reader_list=reader, filter='ulFdSchedData: sfn', column_name='sinrDerivedMcs')
            self.parameter_dict['INDEX_ulTpc_avgSinr'] = \
                self.get_columns(reader_list=reader, filter='ulTpc: sfn', column_name='avgSinr')
            self.parameter_dict['INDEX_ulTpc_ulPathloss'] = \
                self.get_columns(reader_list=reader, filter='ulTpc: sfn', column_name='ulPathloss')
            self.parameter_dict['INDEX_ulTpc_targetSinr'] = \
                self.get_columns(reader_list=reader, filter='ulTpc: sfn', column_name='targetSinr')
            self.parameter_dict['INDEX_ulTpc_tpc'] = \
                self.get_columns(reader_list=reader, filter='ulTpc: sfn', column_name='tpc')
            self.parameter_dict['INDEX_ulTpc_ulAvgCellNoise'] = \
                self.get_columns(reader_list=reader, filter='ulTpc: sfn', column_name='ulAvgCellNoise')
            self.parameter_dict['INDEX_ulLaPhr_sfn'] = \
                self.get_columns(reader_list=reader, filter='ulLaPhr: sfn', column_name='ulLaPhr: sfn')
            self.parameter_dict['INDEX_ulLaPhr_ulPathloss'] = \
                self.get_columns(reader_list=reader, filter='ulLaPhr: sfn', column_name='ulPathloss')
            self.parameter_dict['INDEX_laIniDelta_event_ul'] = \
                self.get_columns(reader_list=reader, filter='laIniDelta: sfn', column_name='event')
            self.parameter_dict['INDEX_laIniDelta_id_ul'] = \
                self.get_columns(reader_list=reader, filter='laIniDelta: sfn', column_name='id')
        elif direction.lower() == 'dl':
            self.parameter_dict['INDEX_dlFdSchedData_SFN'] = \
                self.get_columns(reader_list=reader, filter='dlFdSchedData: sfn', column_name='dlFdSchedData: sfn')
            self.parameter_dict['INDEX_dlFdSchedData_rnti'] = \
                self.get_columns(reader_list=reader, filter='dlFdSchedData: sfn', column_name='rnti')
            self.parameter_dict['INDEX_dlFdSchedData_slot'] = \
                self.get_columns(reader_list=reader, filter='dlFdSchedData: sfn', column_name='slot')
            self.parameter_dict['INDEX_dlFdSchedData_physCellId'] = \
                self.get_columns(reader_list=reader, filter='dlFdSchedData: sfn', column_name='physCellId')
            self.parameter_dict['INDEX_dlFdSchedData_pbr'] = \
                self.get_columns(reader_list=reader, filter='dlFdSchedData: sfn', column_name='numOfPrb')
            self.parameter_dict['INDEX_dlFdSchedData_rrmDlUsedMcs'] = \
                self.get_columns(reader_list=reader, filter='dlFdSchedData: sfn', column_name='rrmDlUsedMcs')
            self.parameter_dict['INDEX_dlFdSchedData_txNumber'] = \
                self.get_columns(reader_list=reader, filter='dlFdSchedData: sfn', column_name='txNumber')
            self.parameter_dict['INDEX_dlFdSchedData_tbsize'] = \
                self.get_columns(reader_list=reader, filter='dlFdSchedData: sfn', column_name='tbSize')
            self.parameter_dict['INDEX_dlFdSchedData_rrmDlProposedMcs'] = \
                self.get_columns(reader_list=reader, filter='dlFdSchedData: sfn', column_name='rrmDlProposedMcs')
            self.parameter_dict['INDEX_dlFdSchedData_numOfLayers'] = \
                self.get_columns(reader_list=reader, filter='dlFdSchedData: sfn', column_name='numOfLayers')
            self.parameter_dict['INDEX_dlFdSchedData_PMI'] = \
                self.get_columns(reader_list=reader, filter='dlFdSchedData: sfn', column_name='PMI')
            self.parameter_dict['INDEX_dlFdSchedData_rrmCorrAvgCqi'] = \
                self.get_columns(reader_list=reader, filter='dlFdSchedData: sfn', column_name='rrmCorrAvgCqi')
            self.parameter_dict['INDEX_dlFdSchedData_cqiDerivedMcs'] = \
                self.get_columns(reader_list=reader, filter='dlFdSchedData: sfn', column_name='cqiDerivedMcs')
            self.parameter_dict['INDEX_dlFdSchedData_mcsTable'] = \
                self.get_columns(reader_list=reader, filter='dlFdSchedData: sfn', column_name='mcsTable')
            self.parameter_dict['INDEX_dlTdSchedSubcellData_rnti'] = \
                self.get_columns(reader_list=reader, filter='dlTdSchedSubcellData: sfn', column_name='rnti')
            self.parameter_dict['INDEX_dlTdSchedSubcellData_resReqClassPrio'] = \
                self.get_columns(reader_list=reader, filter='dlTdSchedSubcellData: sfn', column_name='resReqClassPrio')
            self.parameter_dict['INDEX_dlLaDeltaCqi_rnti'] = \
                self.get_columns(reader_list=reader, filter='dlLaDeltaCqiArray: sfn', column_name='rnti')
            self.parameter_dict['INDEX_dlLaDeltaCqi_isDeltaCqiCalculated'] = \
                self.get_columns(reader_list=reader, filter='dlLaDeltaCqiArray: sfn',
                                 column_name='isDeltaCqiCalculated')
            self.parameter_dict['INDEX_dlLaDeltaCqi_harqFb'] = \
                self.get_columns(reader_list=reader, filter='dlLaDeltaCqiArray: sfn', column_name='harqFb')
            self.parameter_dict['INDEX_dlLaDeltaCqi_rrmDeltaCqi'] = \
                self.get_columns(reader_list=reader, filter='dlLaDeltaCqiArray: sfn', column_name='rrmDeltaCqi')
            self.parameter_dict['INDEX_csiSrReportData_rnti'] = \
                self.get_columns(reader_list=reader, filter='csiSrReportData: sfn', column_name='rnti')
            self.parameter_dict['INDEX_csiSrReportData_sfn'] = \
                self.get_columns(reader_list=reader, filter='csiSrReportData: sfn', column_name='csiSrReportData: sfn')
            self.parameter_dict['INDEX_csiSrReportData_reportType'] = \
                self.get_columns(reader_list=reader, filter='csiSrReportData: sfn', column_name='reportType')
            self.parameter_dict['INDEX_csiSrReportData_ulChannel'] = \
                self.get_columns(reader_list=reader, filter='csiSrReportData: sfn', column_name='ulChannel')
            self.parameter_dict['INDEX_dlHarqRxDataArray_sfn'] = \
                self.get_columns(reader_list=reader, filter='dlHarqRxDataArray: sfn',
                                 column_name='dlHarqRxDataArray: sfn')
            self.parameter_dict['INDEX_dlHarqRxDataArray_ackNack'] = \
                self.get_Multiple_para_columns(reader_list=reader, filter='dlHarqRxDataArray: sfn',
                                               column_name='ackNack', column_index=0)
            self.parameter_dict['INDEX_dlHarqRxDataArray_rnti'] = \
                self.get_Multiple_para_columns(reader_list=reader, filter='dlHarqRxDataArray: sfn',
                                               column_name='rnti', column_index=1)
            self.parameter_dict['INDEX_dlTpc_tpc'] = \
                self.get_columns(reader_list=reader, filter='dlTpc: sfn', column_name='tpc')
            self.parameter_dict['INDEX_csiSrReportData_pucchFormat'] = \
                self.get_columns(reader_list=reader, filter='csiSrReportData: sfn', column_name='pucchFormat')
            self.parameter_dict['INDEX_ulPucchReceiveReqData_pucchFormat'] = \
                self.get_columns(reader_list=reader, filter='ulPucchReceiveReqData: sfn', column_name='pucchFormat')
            self.parameter_dict['INDEX_ulPucchReceiveRespPsData_pucchFormat'] = \
                self.get_columns(reader_list=reader, filter='ulPucchReceiveRespPsData: sfn', column_name='pucchFormat')
            self.parameter_dict['INDEX_ulPucchReceiveReqData_nANPucch'] = \
                self.get_Multiple_para_columns(reader_list=reader, filter='ulPucchReceiveReqData: sfn',
                                               column_name='nANPucch', column_index=0)
            self.parameter_dict['INDEX_laIniDelta_event_dl'] = \
                self.get_columns(reader_list=reader, filter='laIniDelta: sfn', column_name='event')
            self.parameter_dict['INDEX_laIniDelta_id_dl'] = \
                self.get_columns(reader_list=reader, filter='laIniDelta: sfn', column_name='id')
            self.parameter_dict['INDEX_dlFdSchedData_rrmBufferedDataDlTotal'] = \
                self.get_columns(reader_list=reader, filter='dlFdSchedData: sfn', column_name='rrmBufferedDataDlTotal')
            self.parameter_dict['INDEX_preambleData_sfn'] = \
                self.get_columns(reader_list=reader, filter='preambleData: sfn', column_name='preambleData: sfn')
            self.parameter_dict['INDEX_preambleData_slot'] = \
                self.get_columns(reader_list=reader, filter='preambleData: sfn', column_name='slot')
            self.parameter_dict['INDEX_ulPucchReceiveRespPsData_sfn'] = \
                self.get_columns(reader_list=reader, filter='ulPucchReceiveRespPsData: sfn',
                                 column_name='ulPucchReceiveRespPsData: sfn')
            self.parameter_dict['INDEX_ulPucchReceiveRespPsData_slot'] = \
                self.get_columns(reader_list=reader, filter='ulPucchReceiveRespPsData: sfn', column_name='slot')
            self.parameter_dict['INDEX_ulPucchReceiveRespPsData_pucchFormat'] = \
                self.get_columns(reader_list=reader, filter='ulPucchReceiveRespPsData: sfn', column_name='pucchFormat')

    def get_rnti(self, file_path):
        """
        Filter for event dlTdSchedSubcellData and find resReqClassPrio=40,
        which means rnti used for DL data traffic in initial transmission.
        :param file_path: Example input : XXX/XXX/XXX.csv
        :return: rnti value
        """
        self.get_parameters_column(file_path, direction)
        try:
            TdSchedSubcellData_event_with_data_traffic = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.parameters.INDEX_event],
                expected_list=["ulTdSchedSubcellData: sfn"])
        except LookupError:
            raise LookupError("no event found for ulTdSchedSubcellData")
        rnti = TdSchedSubcellData_event_with_data_traffic[1][
            self.parameter_dict['INDEX_ulTdSchedSubcellData_rnti'] - 1]
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
        self.get_parameters_column(file_path, 'ul')
        try:
            ulFdSchedData_event_with_data_traffic = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.parameters.INDEX_event],
                expected_list=["ulFdSchedData: sfn"])
        except LookupError:
            raise LookupError(
                "Fail to get rnti as no event found for ulFdSchedData: sfn with resReqClassPrio")
        rntis, ue_rnti_number = self.get_unique_values_in_column(
            matrix=ulFdSchedData_event_with_data_traffic,
            column_number=self.parameter_dict['INDEX_ulFdSchedData_rnti'])
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
            if len(row[1]) < column:
                continue
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
        self.get_parameters_column(file_path, 'dl')
        rnti = self.get_rnti(file_path=file_path)
        try:
            dlLaDeltaCqi_event = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[
                    self.parameters.INDEX_event,
                    self.parameter_dict['INDEX_dlLaDeltaCqi_rnti']],
                expected_list=["dlLaDeltaCqi: rnti", rnti])
        except LookupError:
            raise LookupError("No dlLaDeltaCqi event found")
        else:
            return dlLaDeltaCqi_event

    def get_dlFdSchedData_event(self, file_path, rnti):
        self.get_parameters_column(file_path, 'dl')
        try:
            dlFdSchedData_event = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[
                    self.parameters.INDEX_event,
                    self.parameter_dict['INDEX_dlFdSchedData_rnti']],
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
                    self.get_parameters_column(file_path, 'dl')
                    index_tbsize = self.parameter_dict['INDEX_dlFdSchedData_tbsize']
                else:
                    self.get_parameters_column(file_path, 'ul')
                    index_tbsize = self.parameter_dict['INDEX_ulFdSchedData_tbsize']
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
            self.get_parameters_column(file_path, 'dl')
            fdSchedData_event_name = "dlFdSchedData: sfn"
            rnti_index_FdSchedData = self.parameter_dict['INDEX_dlFdSchedData_rnti']
        elif direction == 'ul':
            self.get_parameters_column(file_path, 'ul')
            fdSchedData_event_name = "ulFdSchedData: sfn"
            rnti_index_FdSchedData = self.parameter_dict['INDEX_ulFdSchedData_rnti']
        else:
            raise Exception(
                "Un-supported direction value, available values are ul and dl")
        return self.get_event_by_rnti(file_path=file_path, rnti=rnti, event_name=fdSchedData_event_name,
                                      rnti_index_in_target_event=rnti_index_FdSchedData)

    def get_sfn_tbsize_according_fdSchedData(self, file_path, fdSchedData_data, direction):
        sfn_list = []
        tbsize_list = []
        if direction.lower() == 'dl':
            self.get_parameters_column(file_path, 'dl')
            index_tbsize = self.parameter_dict['INDEX_dlFdSchedData_tbsize']
            index_sfn = self.parameter_dict['INDEX_dlFdSchedData_SFN']
        else:
            self.get_parameters_column(file_path, 'ul')
            index_tbsize = self.parameter_dict['INDEX_ulFdSchedData_tbsize']
            index_sfn = self.parameter_dict['INDEX_ulFdSchedData_SFN']

        for i in range(0, len(fdSchedData_data)):
            cur_tbsize = int(fdSchedData_data[i][1][index_tbsize - 1])
            sfn = int(fdSchedData_data[i][1][index_sfn - 1])
            tbsize_list.append(cur_tbsize)
            sfn_list.append(sfn)
        return sfn_list, tbsize_list

    def get_20_sfn_diff_tbsize(self, sfn_list, tbsize_list):
        if len(sfn_list) >= 50:
            sfn_count = 50
        else:
            sfn_count = len(sfn_list)
        sfn_diff_list = []
        for i in range(0, sfn_count - 1):
            diff1 = abs(sfn_list[i + 1] - sfn_list[i])
            sfn_diff_list.append(diff1)
            tbsize_sub_list = tbsize_list
        return sfn_diff_list, tbsize_sub_list

    def get_csiSrReportData_sfn_by_rnti(self, file_path, rnti):
        self.get_parameters_column(file_path, 'dl')
        csiSrReportData_event = get_lines_with_multiple_column_filter(
            file_path=file_path,
            column_list=[self.parameters.INDEX_event],
            expected_list=["csiSrReportData: sfn"])
        sfn_list = []
        sfn_diff_list = []
        for i in range(0, len(csiSrReportData_event)):
            sfn = int(
                csiSrReportData_event[i][1][self.parameter_dict['INDEX_csiSrReportData_sfn'] - 1])
            sfn_list.append(sfn)
        for i in range(0, len(sfn_list) - 1):
            diff = abs(sfn_list[i + 1] - sfn_list[i])
            sfn_diff_list.append(diff)
        return sfn_list, sfn_diff_list

    def get_ulFdSchedData_numofprb_and_tbsize(self, ul_file_path):
        self.get_parameters_column(ul_file_path, 'ul')
        tbsize_prb_dict = {}
        rntis, ue_rnti_number = self.get_multi_rntis(ul_file_path)
        fdSchedData_event = self.get_fdSchedData_event(
            ul_file_path, rntis[0], 'ul')
        index_tbsize = self.parameter_dict['INDEX_ulFdSchedData_tbsize']
        index_prb = self.parameter_dict['INDEX_ulFdSchedData_pbr']
        for i in range(0, len(fdSchedData_event)):
            cur_tbsize = int(fdSchedData_event[i][1][index_tbsize - 1])
            num_of_prb = int(fdSchedData_event[i][1][index_prb - 1])
            tbsize_prb_dict.update({cur_tbsize: num_of_prb})
        return tbsize_prb_dict

    def get_rrmUsedMcs(self, file_path, direction):
        direction = direction.lower()
        if direction == 'dl':
            self.get_parameters_column(file_path, 'dl')
            event_name = 'dlFdSchedData: sfn'
            dlFdSchedData_rrmUsedMcs_index = self.parameter_dict['INDEX_dlFdSchedData_rrmDlUsedMcs']
            dlFdSchedData_rrmDlProposedMcs_index = self.parameter_dict['INDEX_dlFdSchedData_rrmDlProposedMcs']
        elif direction == 'ul':
            self.get_parameters_column(file_path, 'ul')
            event_name = 'ulFdSchedData: sfn'
            dlFdSchedData_rrmUsedMcs_index = self.parameter_dict['INDEX_ulFdSchedData_rrmUlUsedMcs']
            dlFdSchedData_rrmDlProposedMcs_index = self.parameter_dict['INDEX_ulFdSchedData_rrmUlProposedMcs']
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
        if direction == 'dl':
            self.get_parameters_column(file_path, 'dl')
            event_name = 'dlFdSchedData: sfn'
            dlFdSchedData_rrmProposedMcs_index = self.parameter_dict['INDEX_dlFdSchedData_rrmDlProposedMcs']
        elif direction == 'ul':
            self.get_parameters_column(file_path, 'ul')
            event_name = 'ulFdSchedData: sfn'
            dlFdSchedData_rrmProposedMcs_index = self.parameter_dict['INDEX_ulFdSchedData_rrmUlProposedMcs']
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
            self, file_path, row_num_dlFdSchedData_event, dlLaDeltaCqi_event):
        self.get_parameters_column(file_path, 'dl')
        dlLaDeltaCqi_event_row = self.get_related_dlLaDeltaCqi_event_row(
            row_num_dlFdSchedData_event=row_num_dlFdSchedData_event,
            dlLaDeltaCqi_event=dlLaDeltaCqi_event
        )
        if dlLaDeltaCqi_event_row == -1:
            rrmDeltaCqi = 0
        else:
            rrmDeltaCqi = float(
                dlLaDeltaCqi_event_row[1][self.parameter_dict['INDEX_dlLaDeltaCqi_rrmDeltaCqi'] - 1])
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
        self.get_parameters_column(file_path, 'dl')
        dlLaDeltaCqi_event = self.get_dlLaDeltaCqi_event(file_path=file_path)
        rrmDeltaCqiStepup = self.get_rrmDeltaCqiStepup_based_on_calculation(
            dllaDeltaCqiStepdown=dllaDeltaCqiStepdown,
            dllaBlerTarget=dllaBlerTarget)
        for i in range(0, len(dlLaDeltaCqi_event)):
            cur_row = dlLaDeltaCqi_event[i][0]
            cur_isDeltaCqiCalculated = int(
                dlLaDeltaCqi_event[i][1][self.parameter_dict['INDEX_dlLaDeltaCqi_isDeltaCqiCalculated'] - 1])
            cur_harqFb = dlLaDeltaCqi_event[i][1][self.parameter_dict['INDEX_dlLaDeltaCqi_harqFb'] - 1]
            cur_rrmDeltaCqi = float(
                dlLaDeltaCqi_event[i][1][self.parameter_dict['INDEX_dlLaDeltaCqi_rrmDeltaCqi'] - 1])
            if i == 0:
                pre_row = 0
                pre_rrmDeltaCqi = 0
            else:
                pre_row = dlLaDeltaCqi_event[i - 1][0]
                pre_rrmDeltaCqi = float(
                    dlLaDeltaCqi_event[i - 1][1][self.parameter_dict['INDEX_dlLaDeltaCqi_rrmDeltaCqi'] - 1])
            if cur_isDeltaCqiCalculated == 0:
                rrmDeltaCqiExp = pre_rrmDeltaCqi
            elif cur_isDeltaCqiCalculated == 1:
                if cur_harqFb == "ACK":
                    rrmDeltaCqiExp = pre_rrmDeltaCqi + rrmDeltaCqiStepup
                elif cur_harqFb == "NACK":
                    rrmDeltaCqiExp = pre_rrmDeltaCqi - dllaDeltaCqiStepdown
                else:
                    raise Exception(
                        "Current harqFb:{} is not recognized. Please check manually. Row number:{}".format(
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
        self.get_parameters_column(file_path, 'dl')
        dlFdSchedData_event = self.get_dlFdSchedData_event(file_path=file_path)
        dlLaDeltaCqi_event = self.get_dlLaDeltaCqi_event(file_path=file_path)
        for i in range(0, len(dlFdSchedData_event)):
            cur_row = dlFdSchedData_event[i][0]
            cur_txNumber = int(
                dlFdSchedData_event[i][1][self.parameter_dict['INDEX_dlFdSchedData_txNumber'] - 1])
            cur_rrmCorrAvgCqi = float(
                dlFdSchedData_event[i][1][self.parameter_dict['INDEX_dlFdSchedData_rrmCorrAvgCqi'] - 1])
            if i == 0:
                rrmCorrAvgCqi_exp = rdAvgCqi
            else:
                pre_rrmCorrAvgCqi = float(
                    dlFdSchedData_event[i - 1][1][self.parameter_dict['INDEX_dlFdSchedData_rrmCorrAvgCqi'] - 1])
                if cur_txNumber > 1:
                    rrmCorrAvgCqi_exp = pre_rrmCorrAvgCqi
                elif cur_txNumber == 1:
                    rrmDeltaCqi = self.get_rrmDeltaCqi_based_on_dlFdSchedData_event_row_num(
                        file_path, row_num_dlFdSchedData_event=cur_row, dlLaDeltaCqi_event=dlLaDeltaCqi_event)
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
        self.get_parameters_column(file_path, 'dl')
        dlFdSchedData_event = self.get_dlFdSchedData_event(file_path=file_path)
        mcs_list = get_unique_values_in_column(
            matrix=dlFdSchedData_event,
            column_number=self.parameter_dict['INDEX_dlFdSchedData_rrmDlUsedMcs'])
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
            self.get_parameters_column(file_path, 'dl')
            index_txnumber = self.parameter_dict['INDEX_dlFdSchedData_txNumber']
        else:
            self.get_parameters_column(file_path, 'ul')
            index_txnumber = self.parameter_dict['INDEX_ulFdSchedData_txNumber']
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
        self.get_parameters_column(file_path, 'dl')
        dlFdSchedData_event = self.get_dlFdSchedData_event(file_path=file_path)
        sum_mcs = 0
        for i in range(0, len(dlFdSchedData_event)):
            mcs = int(dlFdSchedData_event[i][1]
                      [self.parameter_dict['INDEX_dlFdSchedData_rrmDlUsedMcs'] - 1])
            sum_mcs = sum_mcs + mcs
        avg_mcs = float(sum_mcs) / len(dlFdSchedData_event)
        return avg_mcs

    def get_dl_average_layer(self, file_path):
        self.get_parameters_column(file_path, 'dl')
        dlFdSchedData_event = self.get_dlFdSchedData_event(file_path=file_path)
        sum_layer = 0
        for i in range(0, len(dlFdSchedData_event)):
            layer = int(dlFdSchedData_event[i][1]
                        [self.parameter_dict['INDEX_dlFdSchedData_numOfLayers'] - 1])
            sum_layer = sum_layer + layer
        avg_layer = float(sum_layer) / len(dlFdSchedData_event)
        return avg_layer

    def get_dlFdSchedData_Cellid_event(self, file_path, cell_id):
        """
        Author: Jiang Hongyu
        Description: Get data filter by 'dlFdSchedData: sfn' and 'cell_id"
        :return: list after filter
        """

        self.get_parameters_column(file_path, 'dl')
        try:
            dlFdSchedData_cellid_event = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[
                    self.parameters.INDEX_event,
                    self.parameter_dict['INDEX_dlFdSchedData_physCellId']
                ],
                expected_list=["dlFdSchedData: sfn", cell_id])
        except LookupError:
            raise LookupError("No dlFdSchedData event found")
        else:
            return dlFdSchedData_cellid_event

    def get_ulFdSchedData_Cellid_event(self, file_path, cell_id):
        """
        Author: Jiang Hongyu
        Description: Get data filter by 'ulFdSchedData: sfn' and 'cell_id"
        :return: list after filter
        """

        self.get_parameters_column(file_path, 'ul')
        try:
            ulFdSchedData_cellid_event = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[
                    self.parameters.INDEX_event,
                    self.parameter_dict['INDEX_ulFdSchedData_physCellId']
                ],
                expected_list=["ulFdSchedData: sfn", cell_id])
        except LookupError:
            raise LookupError("No ulFdSchedData event found")
        else:
            return ulFdSchedData_cellid_event

    def get_one_cycle_sfn(self, sfn_col, input_list):
        """
        Author: Jiang Hongyu
        Description: Get one sfn cycle start row and end row
        :param sfn_col: the column for sfn data
        :param input_list: filter list
        :return: one sfn cycle data(all rows)
        """

        sfn_col_list = []
        tmp_index = 0
        last_index = 0
        for i in range(0, len(input_list) - 1):
            if int(input_list[i][1][sfn_col]) > int(input_list[i + 1][1][sfn_col]):
                tmp_index = i + 1
                break
        for j in range(tmp_index, len(input_list) - 1):
            if int(input_list[j][1][sfn_col]) > int(input_list[j + 1][1][sfn_col]):
                last_index = j + 1
                break
        if last_index == 0:
            last_index = len(input_list) - 1
        for m in range(tmp_index, last_index):
            sfn_col_list.append(input_list[m])
        return sfn_col_list

    def get_FdSchedData_one_cycle(self, file_path, cell_id, direction):
        """
        Author: Jiang Hongyu
        Description: Get one cycle sfn
        :param file_path: ul or dl tti trace log path
        :param cell_id:
        :param direction: values can be ul or dl
        :return: one sfn cycle data(all rows)
        """

        if direction.lower() == 'ul':
            self.get_parameters_column(file_path, 'ul')
            sfn_col = self.parameter_dict['INDEX_ulFdSchedData_SFN'] - 1
            ulFdSchedData_cellid_event = self.get_ulFdSchedData_Cellid_event(file_path, cell_id)
            sfn_list = self.get_one_cycle_sfn(sfn_col=sfn_col, input_list=ulFdSchedData_cellid_event)
        elif direction.lower() == 'dl':
            self.get_parameters_column(file_path, 'dl')
            sfn_col = self.parameter_dict['INDEX_dlFdSchedData_SFN'] - 1
            dlFdSchedData_cellid_event = self.get_dlFdSchedData_Cellid_event(file_path, cell_id)
            sfn_list = self.get_one_cycle_sfn(sfn_col=sfn_col, input_list=dlFdSchedData_cellid_event)
        # try:
        #     if int(sfn_list[0][1][sfn_col]) != 0 and int(sfn_list[len(sfn_list) - 1][1][sfn_col]) != 1023:
        #         raise Exception('SFN not start with 0 or end with 1023')
        # except IndexError:
        #     raise IndexError('SFN list is null')
        # else:
        return sfn_list

    def get_each_SFN_responding_slot(self, file_path, input_list, direction):
        """
        Author: Jiang Hongyu
        Description: Get one cycle sfn and each sfn responding slot
        :param input_list: one cycle sfn data
        :param direction: values can be ul or dl
        :return:  a dict that sfn as key and slot as value
        """

        sfn_slot_dict = {}
        if direction.lower() == 'ul':
            self.get_parameters_column(file_path, 'ul')
            slot_col = self.parameter_dict['INDEX_ulFdSchedData_slot'] - 1
            sfn_col = self.parameter_dict['INDEX_ulFdSchedData_SFN'] - 1
        elif direction.lower() == 'dl':
            self.get_parameters_column(file_path, 'ul')
            slot_col = self.parameter_dict['INDEX_dlFdSchedData_slot'] - 1
            sfn_col = self.parameter_dict['INDEX_dlFdSchedData_SFN'] - 1
        for sub_list in input_list:
            sfn = sub_list[1][sfn_col]
            slot = sub_list[1][slot_col]
            if sfn not in sfn_slot_dict.keys():
                sfn_slot_dict[sfn] = []
            sfn_slot_dict[sfn].append(slot)
        return sfn_slot_dict

    def check_one_sfn_cycle_with_diff_slot(self, file_path, cell_id, direction):
        """
        Author: Jiang Hongyu
        Description: Determine whether there are duplicate slots under an SFN
        :param file_path: ul or dl tti trace log path
        :param cell_id:
        :return:  True or Error
        """
        sfn_list = self.get_FdSchedData_one_cycle(file_path=file_path, cell_id=cell_id, direction=direction)
        sfn_slot_dict = self.get_each_SFN_responding_slot(file_path=file_path, input_list=sfn_list,
                                                          direction=direction)
        try:
            for sfn in sfn_slot_dict.keys():
                if len(sfn_slot_dict[sfn]) != len(set(sfn_slot_dict[sfn])):
                    print(sfn)
                    print(sfn_slot_dict[sfn])
                    raise Exception('Under sfn slot has repeat value')
        except LookupError:
            raise LookupError("sfn_slot_dict has is null")
        else:
            return True

    def get_one_sfn_cycle_rnti_proportion(self, file_path, cell_id, rnti_num, direction, unuse_ranti_num):
        """
        Author: Jiang Hongyu
        Description: Get the proportion of each mobile phone scheduling in a sfn cycle
        :param rnti_num: the total number of ues
        """

        sfn_rnti = {}
        rnti_proportion = {}
        sfn_list = self.get_FdSchedData_one_cycle(file_path=file_path, cell_id=cell_id, direction=direction)
        if direction.lower() == 'ul':
            self.get_parameters_column(file_path, 'ul')
            rnti_col = self.parameter_dict['INDEX_ulFdSchedData_rnti'] - 1
        elif direction.lower() == 'dl':
            self.get_parameters_column(file_path, 'dl')
            rnti_col = self.parameter_dict['INDEX_dlFdSchedData_rnti'] - 1
        rnti_avg = float(1) / float(rnti_num)
        for sub_list in sfn_list:
            rnti = sub_list[1][rnti_col]
            if rnti not in sfn_rnti.keys():
                sfn_rnti[rnti] = 0
            sfn_rnti[rnti] += 1
        try:
            if sum(sfn_rnti.values()) != len(sfn_list):
                raise Exception('Caculate rnti total number error!')
            else:
                for rnti in sfn_rnti.keys():
                    if float(sfn_rnti[rnti]) > unuse_ranti_num:
                        rnti_proportion[rnti] = float(sfn_rnti[rnti]) / float(len(sfn_list))
            if len(rnti_proportion.keys()) != rnti_num:
                raise Exception('The total number of rnti did not equal to expectations')
        except LookupError:
            raise LookupError('sfn_rnti dict is null')
        else:
            rnti_proportion['avg'] = rnti_avg
            return rnti_proportion

    def check_continuity_of_sfn_in_sfn_cycle(self, file_path, cell_id, direction):
        """
        Author: Jiang Hongyu
        Description: Check continuity of sfn in a sfn cycle
        :return: if sfn in sfn cycle is continuity,return True
        """

        sfn_list = self.get_FdSchedData_one_cycle(file_path=file_path, cell_id=cell_id, direction=direction)
        if direction.lower() == 'ul':
            self.get_parameters_column(file_path, 'ul')
            sfn_col = self.parameter_dict['INDEX_ulFdSchedData_SFN'] - 1
        elif direction.lower() == 'dl':
            self.get_parameters_column(file_path, 'dl')
            sfn_col = self.parameter_dict['INDEX_dlFdSchedData_SFN'] - 1
        sfn_value_list = [sub_list[1][sfn_col] for sub_list in sfn_list]
        try:
            for i in range(0, len(sfn_value_list) - 1):
                diff_value = int(sfn_value_list[i + 1]) - int(sfn_value_list[i])
                if diff_value > 1:
                    print(sfn_value_list[i], sfn_value_list[i + 1])
                    raise Exception('sfn is not continuite')
        except LookupError:
            raise LookupError('sfn_value_list is null !')
        else:
            return True

    def get_one_sfn_cycle_txNumber(self, file_path, cell_id, direction):
        """
        Author: Jiang Hongyu
        Description: In a sfn cycle ,get txNumber value which are more than 1
        :return: the proportion which are more than 1
        """

        sfn_list = self.get_FdSchedData_one_cycle(file_path=file_path, cell_id=cell_id, direction=direction)
        if direction.lower() == 'ul':
            self.get_parameters_column(file_path, 'ul')
            txNumber_col = self.parameter_dict['INDEX_ulFdSchedData_txNumber'] - 1
        elif direction.lower() == 'dl':
            self.get_parameters_column(file_path, 'dl')
            txNumber_col = self.parameter_dict['INDEX_dlFdSchedData_txNumber'] - 1
        sfn_txNumber_list = [int(sub_list[1][txNumber_col]) for sub_list in sfn_list]
        more_than_one = [i for i in sfn_txNumber_list if i > 1]
        proportion = float(len(more_than_one) * 100) / float(len(sfn_txNumber_list))
        return proportion

    def get_ulHarqRxData_crcResult(self, file_path, crcResult='OK'):
        """
        Author: Jiang Hongyu
        Description: Get data filter by 'ulHarqRxData: sfn' and 'crcResult"
        :return: the value proportion in crcResult columns
        """

        self.get_parameters_column(file_path, 'ul')
        try:
            ulHarqRxData_all_event = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.parameters.INDEX_event],
                expected_list=["ulHarqRxData: sfn"])
            ulHarqRxData_crcResult_event = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[
                    self.parameters.INDEX_event,
                    self.parameter_dict['INDEX_ulHarqRxData_crcResult']
                ],
                expected_list=["ulHarqRxData: sfn", crcResult])
        except LookupError:
            raise LookupError("No ulHarqRxData event found")
        else:
            crcResult_proportion = float(len(ulHarqRxData_crcResult_event) * 100) / float(len(ulHarqRxData_all_event))
            return crcResult_proportion

    def get_dlHarqRxDataArray_rnti_ackNack(self, file_path):
        """
        Author: Jiang Hongyu
        Description: Get data filter by 'dlHarqRxDataArray: sfn' and 'ackNack",
                     Calculated each rnti of ack\nack or dtx proportion
        :return: dict of each rnti ackNack value proportion
        """
        self.get_parameters_column(file_path, 'dl')
        ackNack_col = self.parameter_dict['INDEX_dlHarqRxDataArray_ackNack'] - 1
        rnti_col = self.parameter_dict['INDEX_dlHarqRxDataArray_rnti'] - 1
        try:
            dlHarqRxDataArray_event = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.parameters.INDEX_event],
                expected_list=["dlHarqRxDataArray: sfn"])
            rnti_value_list = set([sub_list[1][rnti_col] for sub_list in dlHarqRxDataArray_event])
        except LookupError:
            raise LookupError("No dlHarqRxDataArray event found")
        else:
            try:
                rnti_ackNack_value = {}
                for rnti in rnti_value_list:
                    dlHarqRxDataArray_rnti_event = get_lines_with_multiple_column_filter(
                        file_path=file_path,
                        column_list=[self.parameters.INDEX_event,
                                     self.parameter_dict['INDEX_dlHarqRxDataArray_rnti']],
                        expected_list=["dlHarqRxDataArray: sfn", rnti])
                    rnti_ackNack_value[rnti] = [sub_list[1][ackNack_col] for sub_list in dlHarqRxDataArray_rnti_event]
            except LookupError:
                raise LookupError("No dlHarqRxDataArray rnti event found")
            else:
                rnti_ackNack_dict = {}
                rnti_ackNack_proportion = {}
                for rnti in rnti_ackNack_value.keys():
                    tmp_dict = {}
                    tmp_dict['ACK'] = len([i for i in rnti_ackNack_value[rnti] if i == 'ACK'])
                    tmp_dict['NACK'] = len([i for i in rnti_ackNack_value[rnti] if i == 'NACK'])
                    tmp_dict['DTX'] = len([i for i in rnti_ackNack_value[rnti] if i == 'DTX'])
                    rnti_ackNack_dict[rnti] = tmp_dict
                print(rnti_ackNack_dict)
                for rnti in rnti_ackNack_dict.keys():
                    tmp_proportion_dict = {}
                    total = sum(rnti_ackNack_dict[rnti].values())
                    tmp_proportion_dict['ACK'] = float(rnti_ackNack_dict[rnti]['ACK']) / float(total)
                    tmp_proportion_dict['NACK'] = float(rnti_ackNack_dict[rnti]['NACK']) / float(total)
                    tmp_proportion_dict['DTX'] = float(rnti_ackNack_dict[rnti]['DTX']) / float(total)
                    rnti_ackNack_proportion[rnti] = tmp_proportion_dict
                return rnti_ackNack_proportion

    def get_csiSrReportData_rnti_sfn_diff(self, file_path, except_value):
        """
        Author: Jiang Hongyu
        Description: Filter by csiSrReportData and get sfn of every rnti;caculate diff of sfn
        :param: for example:if except_value == 4,
        :return: a dict that include csiSrReportData rnti sfn normal diff times and DTX times
        """

        rnti_sfn_dict = {}
        rnti_sfn_diff_dict = {}
        self.get_parameters_column(file_path, 'dl')
        rnti_col = self.parameter_dict['INDEX_csiSrReportData_rnti'] - 1
        sfn_col = self.parameter_dict['INDEX_csiSrReportData_sfn'] - 1
        try:
            csiSrReportData_event = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.parameters.INDEX_event],
                expected_list=["csiSrReportData: sfn"])
        except LookupError:
            raise LookupError("No csiSrReportData event found")
        rnti_vaule_tmp = set([sub_list[1][rnti_col] for sub_list in csiSrReportData_event])
        try:
            for rnti_id in rnti_vaule_tmp:
                csiSrReportData_rnti_event = get_lines_with_multiple_column_filter(
                    file_path=file_path,
                    column_list=[self.parameters.INDEX_event, self.parameter_dict['INDEX_csiSrReportData_rnti']],
                    expected_list=["csiSrReportData: sfn", rnti_id])
                rnti_sfn_dict[rnti_id] = [sub_list[1][sfn_col] for sub_list in csiSrReportData_rnti_event]
        except LookupError:
            raise LookupError("No csiSrReportData rnti event found")
        print(rnti_sfn_dict)
        for key in rnti_sfn_dict.keys():
            rnti_sfn = rnti_sfn_dict[key]
            rnti_sfn_diff_list = [int(rnti_sfn[i]) - int(rnti_sfn[i - 1]) for i in range(1, len(rnti_sfn))]
            rnti_sfn_diff_dict[key] = rnti_sfn_diff_list
        except_value2 = except_value - 1024
        print('rnti_sfn_diff_dict is :')
        print(rnti_sfn_diff_dict)
        try:
            rnti_sfn_diff_time_dict = {}
            for rnti in rnti_sfn_diff_dict.keys():
                tmp_dict = {}
                tmp_dict['natural'] = len([values for values in rnti_sfn_diff_dict[rnti]
                                           if values == except_value or values == except_value2])
                tmp_list = [values for values in rnti_sfn_diff_dict[rnti]
                            if values != except_value and values != except_value2]
                tmp_dict['DTX'] = sum(tmp_list) / except_value - len(tmp_list)
                rnti_sfn_diff_time_dict[rnti] = tmp_dict
        except LookupError:
            raise LookupError("rnti_sfn_diff_dict is null")
        else:
            return rnti_sfn_diff_time_dict

    def get_csiSrReportData_reportType_ulChannel(self, file_path, reportType_value='PERIODIC_CSI',
                                                 ulChannel_value='PUCCH'):
        """
        Author: Jiang Hongyu
        Description: Filter by csiSrReportData and get reportType and ulChannel value and check
        :return: if check pass return True else raise Error
        """

        self.get_parameters_column(file_path, 'dl')
        reporttype_col = self.parameter_dict['INDEX_csiSrReportData_reportType'] - 1
        ulChannel_col = self.parameter_dict['INDEX_csiSrReportData_ulChannel'] - 1
        try:
            csiSrReportData_event = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.parameters.INDEX_event],
                expected_list=["csiSrReportData: sfn"])
            reporttype_list = [sub_list[1][reporttype_col] for sub_list in csiSrReportData_event]
            ulChannel_list = [sub_list[1][ulChannel_col] for sub_list in csiSrReportData_event]
            print("reporttype_list is :")
            print(reporttype_list)
            print("ulChannel_list is : ")
            print(ulChannel_list)
        except LookupError:
            raise LookupError("No csiSrReportData event found")
        try:
            for i in reporttype_list:
                if i != reportType_value:
                    raise Exception("The value in reporttype list not equal as reportType_value")
            for j in ulChannel_list:
                if j != ulChannel_value:
                    raise Exception("The value in ulChannel list not equal as ulChannel_value")
        except LookupError:
            raise LookupError("Reporttype_list or ulChannel_list is empty")
        else:
            return True

    def get_csiSrReportData_pucchFormat_dlChannel(self, file_path):
        """
        Author: Zhangshanshan
        Description: Filter by csiSrReportData and get reportType and ulChannel value and check
        :return: if check pass return True else raise Error
        """
        self.get_parameters_column(file_path, 'dl')
        reporttype_col = self.parameter_dict['INDEX_csiSrReportData_pucchFormat'] - 1
        try:
            csiSrReportData_event = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.parameters.INDEX_event],
                expected_list=["csiSrReportData: sfn"])
            reporttype_list = [sub_list[1][reporttype_col] for sub_list in csiSrReportData_event]
            print("reporttype_list is :")
            reporttype_list = list(set(reporttype_list))
            print(reporttype_list)
        except LookupError:
            raise LookupError("No csiSrReportData event found")
        return reporttype_list

    def get_ulPucchReceiveRespPsData_pucchFormat_dlChannel(self, file_path):
        """
        Author: Zhangshanshan
        Description: Filter by csiSrReportData and get reportType and ulChannel value and check
        :return: if check pass return True else raise Error
        """
        self.get_parameters_column(file_path, 'dl')
        reporttype_col = self.parameter_dict['INDEX_ulPucchReceiveRespPsData_pucchFormat'] - 1
        try:
            csiSrReportData_event = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.parameters.INDEX_event],
                expected_list=["ulPucchReceiveRespPsData: sfn"])
            reporttype_list = [sub_list[1][reporttype_col] for sub_list in csiSrReportData_event]
            print("reporttype_list is :")
            reporttype_list = list(set(reporttype_list))
            print(reporttype_list)
        except LookupError:
            raise LookupError("No csiSrReportData event found")
        return reporttype_list

    def get_ulPucchReceiveReqData_nANPucch_dlChannel(self, file_path):
        """
        Author: Zhangshanshan
        Description: Filter by csiSrReportData and get reportType and ulChannel value and check
        :return: if check pass return True else raise Error
        """
        self.get_parameters_column(file_path, 'dl')
        reporttype_col = self.parameter_dict['INDEX_ulPucchReceiveReqData_nANPucch'] - 1
        try:
            csiSrReportData_event = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.parameters.INDEX_event],
                expected_list=["ulPucchReceiveReqData: sfn"])
            reporttype_list = [sub_list[1][reporttype_col] for sub_list in csiSrReportData_event]
            print("reporttype_list is :")
            print(reporttype_list)
            reporttype_list = list(set(reporttype_list))
            print(reporttype_list)
        except LookupError:
            raise LookupError("No ulPucchReceiveReqData event found")
        return reporttype_list

    def get_laIniDelta_event_dlChannel(self, file_path):
        """
        Author: Zhangshanshan
        Description: Filter by csiSrReportData and get reportType and ulChannel value and check
        :return: if check pass return True else raise Error
        """
        self.get_parameters_column(file_path, 'dl')
        reporttype_col = self.parameter_dict['INDEX_laIniDelta_event_dl'] - 1
        try:
            csiSrReportData_event = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.parameters.INDEX_event],
                expected_list=["laIniDelta: sfn"])
            laIniDelta_event = [sub_list[1][reporttype_col] for sub_list in csiSrReportData_event]
            print("laIniDelta_event is :")
            print(laIniDelta_event)
        except LookupError:
            raise LookupError("No ulPucchReceiveReqData event found")
        return laIniDelta_event

    def get_laIniDelta_event_ulChannel(self, file_path):
        """
        Author: Zhangshanshan
        Description: Filter by csiSrReportData and get reportType and ulChannel value and check
        :return: if check pass return True else raise Error
        """
        self.get_parameters_column(file_path, 'ul')
        reporttype_col = self.parameter_dict['INDEX_laIniDelta_event_ul'] - 1
        try:
            csiSrReportData_event = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.parameters.INDEX_event],
                expected_list=["laIniDelta: sfn"])
            laIniDelta_event = [sub_list[1][reporttype_col] for sub_list in csiSrReportData_event]
            print("laIniDelta_event is :")
            print(laIniDelta_event)
        except LookupError:
            raise LookupError("No ulPucchReceiveReqData event found")
        return laIniDelta_event

    def get_laIniDelta_id_dlChannel(self, file_path):
        """
        Author: Zhangshanshan
        Description: Filter by csiSrReportData and get reportType and ulChannel value and check
        :return: if check pass return True else raise Error
        """
        self.get_parameters_column(file_path, 'dl')
        reporttype_col = self.parameter_dict['INDEX_laIniDelta_id_dl'] - 1
        try:
            csiSrReportData_event = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.parameters.INDEX_event],
                expected_list=["laIniDelta: sfn"])
            laIniDelta_id = [sub_list[1][reporttype_col] for sub_list in csiSrReportData_event]
            print("laIniDelta_id is :")
            print(laIniDelta_id)
        except LookupError:
            raise LookupError("No ulPucchReceiveReqData event found")
        return laIniDelta_id

    def get_laIniDelta_id_ulChannel(self, file_path):
        """
        Author: Zhangshanshan
        Description: Filter by csiSrReportData and get reportType and ulChannel value and check
        :return: if check pass return True else raise Error
        """
        self.get_parameters_column(file_path, 'ul')
        reporttype_col = self.parameter_dict['INDEX_laIniDelta_id_ul'] - 1
        try:
            csiSrReportData_event = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.parameters.INDEX_event],
                expected_list=["laIniDelta: sfn"])
            laIniDelta_id = [sub_list[1][reporttype_col] for sub_list in csiSrReportData_event]
            print("laIniDelta_id is :")
            print(laIniDelta_id)
        except LookupError:
            raise LookupError("No ulPucchReceiveReqData event found")
        return laIniDelta_id

    def get_ulFdSchedData_rrmBufferedDataUlTotal_bytes_tbsize(self, file_path, except_value, Preschedule=False):
        """
        Author: Jiang Hongyu
        Description: Filter by ulFdSchedData\rrmBufferedDataUlTotal_bytes or startPRB get tbsize value and check it
        :return: True or raise error
        """
        tbsize_vlaue_NUM = 0
        self.get_parameters_column(file_path, 'ul')
        startPrb_col = self.parameter_dict['INDEX_ulFdSchedData_startPrb'] - 1
        tbsize_col = self.parameter_dict['INDEX_ulFdSchedData_tbsize'] - 1
        Buffer_col = self.parameter_dict['INDEX_ulFdSchedData_rrmBufferedDataUlTotal_bytes'] - 1
        try:
            ulFdSchedData_event = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.parameters.INDEX_event],
                expected_list=["ulFdSchedData: sfn"])
            ulFdSchedData_tbsize_event = [sub_list for sub_list in ulFdSchedData_event
                                          if sub_list[1][Buffer_col] == '0']
            if Preschedule is False:
                filter_startprb_list = [sub_list for sub_list in ulFdSchedData_tbsize_event
                                        if sub_list[1][startPrb_col] != '0']
            else:
                filter_startprb_list = [sub_list for sub_list in ulFdSchedData_tbsize_event
                                        if sub_list[1][startPrb_col] == '0']
            tbsize_vlaue_list = [int(tmp_list[1][tbsize_col]) for tmp_list in filter_startprb_list]
        except LookupError:
            raise LookupError("No ulFdSchedData and rrmBufferedDataUlTotal_bytes event found")
        else:
            if except_value == 984:
                for i in (tbsize_vlaue_list):
                    if i <= except_value:
                        tbsize_vlaue_NUM += 1
                        # print tbsize_vlaue_list
                        print
                        float(tbsize_vlaue_NUM)
                    else:
                        continue
            # except_tbsize = float(tbsize_vlaue_NUM) / float(len(tbsize_vlaue_list))
            # return except_tbsize
            else:
                for i in (tbsize_vlaue_list):
                    if i == except_value:
                        tbsize_vlaue_NUM += 1
                        # print tbsize_vlaue_list
                        print
                        float(tbsize_vlaue_NUM)
                    else:
                        continue
            print
            float(len(tbsize_vlaue_list))
            except_tbsize = float(tbsize_vlaue_NUM) / float(len(tbsize_vlaue_list))
            return except_tbsize

    def get_ulTdSchedSubcellData_resReqClassPrio(self, file_path, input_value):
        """
        Author: Jiang Hongyu
        Description: Filter by ulTdSchedSubcellData and get resReqClassPrio value evaluate the input_value proportion
        :return: input_value proportion
        """
        self.get_parameters_column(file_path, 'ul')
        resReqClassPrio_col = self.parameter_dict['INDEX_ulTdSchedSubcellData_resReqClassPrio'] - 1
        try:
            ulTdSchedSubcellData_event = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.parameters.INDEX_event],
                expected_list=["ulTdSchedSubcellData: sfn"])
            resReqClassPrio_list = [int(sub_list[1][resReqClassPrio_col]) for sub_list in ulTdSchedSubcellData_event]
        except LookupError:
            raise LookupError("No ulTdSchedSubcellData: sfn event found")
        else:
            except_list = [i for i in resReqClassPrio_list if i == input_value]
            except_value_proportion = float(len(except_list)) / float(len(resReqClassPrio_list))
            return except_value_proportion

    def check_rrmDlUsedMcs_equal_rrmDlProposedMcs(self, file_path, equal_flag):
        """
        Author: Jiang Hongyu
        Description: Filter by dlFdSchedData: sfn ,
        :param: equal_flag: if equal_flag=True
                except:the value of rrmDlUsedMcs should be equal as rrmDlProposedMcs
                for abnormal condition:check txNumber should more than 1 and cqiDerivedMcs should equal 255
                if equal_flag=False
                except:the value of rrmDlUsedMcs should less than rrmDlProposedMcs
        :return: True or raise error
        """
        num_rrmDlUsedMcs_false = 0
        num_rrmDlUsedMcs_txnum_true = 0
        num_rrmDlUsedMcs_cqi_true = 0
        except_rrmDlUsedMcs_txnum_true = 0
        except_rrmDlUsedMcs_cqi_true = 0
        except_rrmDlUsedMcs_false = 0
        self.get_parameters_column(file_path, 'dl')
        rrmDlUsedMcs_col = self.parameter_dict['INDEX_dlFdSchedData_rrmDlUsedMcs'] - 1
        rrmDlProposedMcs_col = self.parameter_dict['INDEX_dlFdSchedData_rrmDlProposedMcs'] - 1
        tbsize_col = self.parameter_dict['INDEX_dlFdSchedData_tbsize'] - 1
        txNumber_col = self.parameter_dict['INDEX_dlFdSchedData_txNumber'] - 1
        cqiDerivedMcs_col = self.parameter_dict['INDEX_dlFdSchedData_cqiDerivedMcs'] - 1
        try:
            dlFdSchedData_event = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.parameters.INDEX_event],
                expected_list=["dlFdSchedData: sfn"])
            dlFdSchedData_tbsize_event = [sub_list for sub_list in dlFdSchedData_event
                                          if int(sub_list[1][tbsize_col]) >= 4040]
            rrmDlUsedMcs_value_list = [int(tmp_list[1][rrmDlUsedMcs_col]) for tmp_list in dlFdSchedData_tbsize_event]
            rrmDlProposedMcs_value_list = [int(tmp_list[1][rrmDlProposedMcs_col])
                                           for tmp_list in dlFdSchedData_tbsize_event]
        except LookupError:
            raise LookupError("No dlFdSchedData: sfn event found")
        else:
            equal_value_list = []
            not_equal_index_list = []
            for i in range(0, len(dlFdSchedData_tbsize_event)):
                if rrmDlUsedMcs_value_list[i] == rrmDlProposedMcs_value_list[i]:
                    equal_value_list.append(rrmDlUsedMcs_value_list[i])
                else:
                    not_equal_index_list.append(i)
            if equal_flag is True:
                txNumber_list = [int(dlFdSchedData_tbsize_event[i][1][txNumber_col]) for i in not_equal_index_list]
                cqiDerivedMcs_list = [int(dlFdSchedData_tbsize_event[i][1][cqiDerivedMcs_col])
                                      for i in not_equal_index_list]
                for j in txNumber_list:
                    if j <= 1:
                        num_rrmDlUsedMcs_txnum_true += 1
                        except_rrmDlUsedMcs_txnum_true = \
                            float(num_rrmDlUsedMcs_txnum_true) / float(len(rrmDlUsedMcs_value_list))
                        # print (j)
                        # raise Exception("rrmDlUsedMcs no less than rrmDlProposedMcs and txNumber=1")
                        # return False
                for j in cqiDerivedMcs_list:
                    if j != 255:
                        num_rrmDlUsedMcs_cqi_true += 1
                        except_rrmDlUsedMcs_cqi_true = float(num_rrmDlUsedMcs_txnum_true) / float(
                            len(rrmDlUsedMcs_value_list))
                        # print (j)
                        # raise Exception("rrmDlUsedMcs no less than rrmDlProposedMcs and cqiDerivedMcs != 255")
                        # return False
                return except_rrmDlUsedMcs_txnum_true, except_rrmDlUsedMcs_cqi_true
                # return True
            else:
                for m in range(0, len(rrmDlUsedMcs_value_list)):
                    if rrmDlUsedMcs_value_list[m] >= rrmDlProposedMcs_value_list[m]:
                        num_rrmDlUsedMcs_false += 1
                        # print (m)
                        # print (rrmDlUsedMcs_value_list)
                        # print (rrmDlProposedMcs_value_list)
                        # raise Exception("rrmDlUsedMcs_value not less than rrmDlProposedMcs")
                        # return False
                except_rrmDlUsedMcs_false = float(num_rrmDlUsedMcs_false) / float(len(rrmDlUsedMcs_value_list))
                return except_rrmDlUsedMcs_false
                # return True

    def get_FdSchedData_numofprb(self, file_path, direction, except_value, equal_flag):
        """
        Author: Jiang Hongyu
        Description: Filter by dlFdSchedData: sfn or ulFdSchedData: sfn
        :param: equal_flag: if equal_flag is True
                except:the value of numOfPrb should equal as except_value
                if if equal_flag is False
                except:when Tbsize<4040, numOfPrb<except_value
        :return: True or raise error
        """
        num_sinrDerivedMcs_true = 0
        exp_num_numOfPrb_true = 0
        num_numOfPrb_false = 0
        exp_num_numOfPrb_false = 0
        if direction.lower() == 'ul':
            self.get_parameters_column(file_path, 'ul')
            numOfPrb_col = self.parameter_dict['INDEX_ulFdSchedData_pbr'] - 1
            tbsize_col = self.parameter_dict["INDEX_ulFdSchedData_tbsize"] - 1
            sinrDerivedMcs_col = self.parameter_dict["INDEX_ulFdSchedData_sinrDerivedMcs"] - 1
            filter = "ulFdSchedData: sfn"
        else:
            self.get_parameters_column(file_path, 'dl')
            numOfPrb_col = self.parameter_dict['INDEX_dlFdSchedData_pbr'] - 1
            tbsize_col = self.parameter_dict["INDEX_dlFdSchedData_tbsize"] - 1
            filter = "dlFdSchedData: sfn"
        try:
            FdSchedData_event_data = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.parameters.INDEX_event],
                expected_list=[filter])
        except LookupError:
            raise LookupError("No dlFdSchedData: sfn or ulFdSchedData: sfn event found")
        else:
            if equal_flag is True:
                numOfPrb_value_list = [int(sub_list[1][numOfPrb_col]) for sub_list in FdSchedData_event_data]
                sinrDerivedMcs_value_list = [int(sub_list[1][sinrDerivedMcs_col]) for sub_list in
                                             FdSchedData_event_data]
                print('xxx')
                # print (numOfPrb_value_list)
                for i in range(0, len(numOfPrb_value_list)):
                    if numOfPrb_value_list[i] != except_value:
                        if str(sinrDerivedMcs_value_list[i]) != '255':
                            num_sinrDerivedMcs_true += 1
                            # print (i)
                            # print (sinrDerivedMcs_value_list[i])
                            # print (numOfPrb_value_list[i])
                            # raise Exception("numOfPrb value not equal as except value")
                            # return False
                exp_num_sinrDerivedMcs_true = float(num_sinrDerivedMcs_true) / float(len(sinrDerivedMcs_value_list))
                return exp_num_sinrDerivedMcs_true
            else:
                FdSchedData_tbsize_event_data = [sub_list for sub_list in FdSchedData_event_data
                                                 if int(sub_list[1][tbsize_col]) < 4040]
                numOfPrb_value_list = [int(sub_list[1][numOfPrb_col]) for sub_list in FdSchedData_tbsize_event_data]
                for i in numOfPrb_value_list:
                    if i >= except_value:
                        num_numOfPrb_false += 1
                #         print (i)
                #         raise Exception("numOfPrb value more than except value")
                #         return False
                # return True
                exp_num_numOfPrb_false = float(num_numOfPrb_false) / float(len(numOfPrb_value_list))
                return exp_num_numOfPrb_false

    def get_ulTpc_Or_dlTpc_Event(self, file_path, direction):
        """
            Author: Jiang Hongyu
            Description: Filter by ulTpc: sfn or dlTpc: sfn
            :return: result is table after filter
        """
        if direction.lower() == 'ul':
            self.get_parameters_column(file_path, 'ul')
            filter = "ulTpc: sfn"
        else:
            self.get_parameters_column(file_path, 'dl')
            filter = "dlTpc: sfn"
        TPC_event_Data = get_lines_with_multiple_column_filter(
            file_path=file_path,
            column_list=[self.parameters.INDEX_event],
            expected_list=[filter])
        return TPC_event_Data

    def get_ulLaPhr_Event(self, file_path):
        """
            Author: Jiang Hongyu
            Description: Filter by ulLaPhr: sfn
            :return: result is table after filter
        """
        self.get_parameters_column(file_path, 'ul')
        filter = "ulLaPhr: sfn"
        LaPhr_event_Data = get_lines_with_multiple_column_filter(
            file_path=file_path,
            column_list=[self.parameters.INDEX_event],
            expected_list=[filter])
        return LaPhr_event_Data

    def get_ulTpc_Or_dlTpc_avgSinr(self, file_path, direction):
        """
        Author: Jiang Hongyu
        Description: Filter by ulTpc: sfn or dlTpc: sfn
        :return: List about row of avgSinr
        """
        avgSinr_list = []
        if direction.lower() == 'ul':
            TPC_event_Data = self.get_ulTpc_Or_dlTpc_Event(file_path, direction='ul')
            avgSinr_col = self.parameter_dict['INDEX_ulTpc_avgSinr'] - 1
        else:
            TPC_event_Data = self.get_ulTpc_Or_dlTpc_Event(file_path, direction='dl')
            avgSinr_col = self.parameter_dict['INDEX_dlTpc_avgSinr'] - 1
        for i in range(0, len(TPC_event_Data)):
            avgSinr_list.append(TPC_event_Data[i][1][avgSinr_col])
        return avgSinr_list

    def get_ulTpc_Or_dlTpc_targetSinr(self, file_path, direction):
        """
            Author: Jiang Hongyu
            Description: Filter by ulTpc: sfn or dlTpc: sfn
            :return: List about row of targetSinr
        """
        targetSinr_list = []
        if direction.lower() == 'ul':
            TPC_event_Data = self.get_ulTpc_Or_dlTpc_Event(file_path, direction='ul')
            targetSinr_col = self.parameter_dict['INDEX_ulTpc_targetSinr'] - 1
        else:
            TPC_event_Data = self.get_ulTpc_Or_dlTpc_Event(file_path, direction='dl')
            targetSinr_col = self.parameter_dict['INDEX_dlTpc_targetSinr'] - 1
        for i in range(0, len(TPC_event_Data)):
            targetSinr_list.append(TPC_event_Data[i][1][targetSinr_col])
        return targetSinr_list

    def get_ulTpc_Or_dlTpc_Tpc(self, file_path, direction):
        """
            Author: Jiang Hongyu
            Description: Filter by ulTpc: sfn or dlTpc: sfn
            :return: List about row of TPC
        """
        tpc_list = []
        if direction.lower() == 'ul':
            TPC_event_Data = self.get_ulTpc_Or_dlTpc_Event(file_path, direction='ul')
            tpc_col = self.parameter_dict['INDEX_ulTpc_tpc'] - 1
        else:
            TPC_event_Data = self.get_ulTpc_Or_dlTpc_Event(file_path, direction='dl')
            tpc_col = self.parameter_dict['INDEX_dlTpc_tpc'] - 1
        for i in range(0, len(TPC_event_Data)):
            tpc_list.append(TPC_event_Data[i][1][tpc_col])
        return tpc_list

    def get_ulTpc_Or_dlTpc_AvgCellNoise(self, file_path, direction):
        """
            Author: Jiang Hongyu
            Description: Filter by ulTpc: sfn or dlTpc: sfn
            :return: List about row of TPC
        """
        AvgCellNoise_list = []
        if direction.lower() == 'ul':
            TPC_event_Data = self.get_ulTpc_Or_dlTpc_Event(file_path, direction='ul')
            AvgCellNoise_col = self.parameter_dict['INDEX_ulTpc_ulAvgCellNoise'] - 1
        else:
            TPC_event_Data = self.get_ulTpc_Or_dlTpc_Event(file_path, direction='dl')
            AvgCellNoise_col = self.parameter_dict['INDEX_dlTpc_dlAvgCellNoise'] - 1
        for i in range(0, len(TPC_event_Data)):
            AvgCellNoise_list.append(TPC_event_Data[i][1][AvgCellNoise_col])
        return AvgCellNoise_list

    def get_ulLaPhr_sfn(self, file_path):
        """
            Author: Jiang Hongyu
            Description: Filter by ulLaPhr:sfn
            :return: List about row of sfn
        """
        LaPhr_list = []
        LaPhr_event_Data = self.get_ulLaPhr_Event(file_path)
        LaPhr_sfn_col = self.parameter_dict['INDEX_ulLaPhr_sfn'] - 1
        for i in range(0, len(LaPhr_event_Data)):
            LaPhr_list.append(LaPhr_event_Data[i][1][LaPhr_sfn_col])
        return LaPhr_list

    def get_ulLaPhr_Pathloss(self, file_path):
        """
            Author: Jiang Hongyu
            Description: Filter by ulLaPhr: sfn
            :return: List about row of Pathloss
        """
        Pathloss_list = []
        LaPhr_event_Data = self.get_ulLaPhr_Event(file_path)
        Pathloss_col = self.parameter_dict['INDEX_ulLaPhr_ulPathloss'] - 1
        for i in range(0, len(LaPhr_event_Data)):
            Pathloss_list.append(LaPhr_event_Data[i][1][Pathloss_col])
        return Pathloss_list

    def get_preambleData_Event(self, file_path):
        """
            Author: Jiang Hongyu
            Description: Filter by preambleData: sfn
            :return:  result is table after filter
        """
        self.get_parameters_column(file_path, 'dl')
        filter = "preambleData: sfn"
        PreambleData_event_Data = get_lines_with_multiple_column_filter(
            file_path=file_path,
            column_list=[self.parameters.INDEX_event],
            expected_list=[filter])
        return PreambleData_event_Data

    def get_preambleData_sfn_slot(self, file_path):
        """
            Author: Jiang Hongyu
            Description: Filter by preambleData: sfn
            :return:  get table of preambleData: sfn list slot and sfn, return dictionary
        """
        result_dict = {'sfn': [], 'slot': []}
        PreambleData_event_Data = self.get_preambleData_Event(file_path)
        sfn_col = self.parameter_dict['INDEX_preambleData_sfn'] - 1
        slot_col = self.parameter_dict['INDEX_preambleData_slot'] - 1
        for i in range(0, len(PreambleData_event_Data)):
            result_dict['sfn'].append(PreambleData_event_Data[i][1][sfn_col])
            result_dict['slot'].append(PreambleData_event_Data[i][1][slot_col])
        return result_dict

    def get_ulPucchReceiveRespPsData_Event(self, file_path):
        """
            Author: Jiang Hongyu
            Description: Filter by ulPucchReceiveRespPsData: sfn
            :return:  result is table after filter
        """
        self.get_parameters_column(file_path, 'dl')
        filter = "ulPucchReceiveRespPsData: sfn"
        ulPucchReceiveRespPsData_event_Data = get_lines_with_multiple_column_filter(
            file_path=file_path,
            column_list=[self.parameters.INDEX_event],
            expected_list=[filter])
        return ulPucchReceiveRespPsData_event_Data

    def get_ulPucchReceiveRespPsData_pucchFormat_filter_sfn_slot(self, file_path, input_dict):
        """
            Author: Jiang Hongyu
            Description: Filter by ulPucchReceiveRespPsData: sfn, slot,
            :return:  get result of pucchFormat after filter by sfn value and slot value
        """
        result_dict = {'sfn': [], 'slot': [], 'pucchFormat': []}
        tmp_list = [[input_dict['sfn'][i], input_dict['slot'][i]] for i in range(0, len(input_dict['sfn']))]
        new_list = []
        for i in tmp_list:
            if i not in new_list:
                new_list.append(i)
        sfn_list = [sub_list[0] for sub_list in new_list]
        slot_list = [sub_list[1] for sub_list in new_list]
        ulPucchReceiveRespPsData_event_Data = self.get_ulPucchReceiveRespPsData_Event(file_path)
        sfn_col = self.parameter_dict['INDEX_ulPucchReceiveRespPsData_sfn'] - 1
        slot_col = self.parameter_dict['INDEX_ulPucchReceiveRespPsData_slot'] - 1
        pucchFormat_col = self.parameter_dict['INDEX_ulPucchReceiveRespPsData_pucchFormat'] - 1
        for i in range(0, len(ulPucchReceiveRespPsData_event_Data)):
            for j in range(0, len(sfn_list)):
                if ulPucchReceiveRespPsData_event_Data[i][1][sfn_col] == sfn_list[j] and \
                        ulPucchReceiveRespPsData_event_Data[i][1][slot_col] == slot_list[j]:
                    result_dict['sfn'].append(sfn_list[j])
                    result_dict['slot'].append(slot_list[j])
                    result_dict['pucchFormat'].append(ulPucchReceiveRespPsData_event_Data[i][1][pucchFormat_col])
        return result_dict

    def get_ulPucchReceiveRespPsData_pucchFormat_filter_slot(self, file_path, slot_value, Frame_period, number):
        """
            Author: Jiang Hongyu
            Description: Filter by ulPucchReceiveRespPsData: sfn, slot,
            :return:  get result of pucchFormat after filter by slot value
        """
        sfn_list = [str(i) for i in range(1, int(Frame_period) * int(number), int(Frame_period))]
        slot_list = [str(slot_value) for i in range(0, len(sfn_list))]
        input_dict = {'sfn': sfn_list, 'slot': slot_list}
        result_dict = \
            self.get_ulPucchReceiveRespPsData_pucchFormat_filter_sfn_slot(file_path=file_path, input_dict=input_dict)
        return result_dict

    def get_ulFdSchedData_Event(self, file_path):
        """
            Author: Jiang Hongyu
            Description: Filter by ulFdSchedData: sfn
            :return:  result is table after filter
        """
        self.get_parameters_column(file_path, 'ul')
        filter = "ulFdSchedData: sfn"
        ulFdSchedData_event_Data = get_lines_with_multiple_column_filter(
            file_path=file_path,
            column_list=[self.parameters.INDEX_event],
            expected_list=[filter])
        return ulFdSchedData_event_Data

    def get_ulFdSchedData_prb_filter_sfn_slot(self, file_path, input_dict):
        """
            Author: Jiang Hongyu
            Description: Filter by ulFdSchedData: sfn, slot,
            :return:  get result of numOfPrb and startPrb after filter by sfn value and slot value
        """
        result_dict = {'sfn': [], 'slot': [], 'startPrb': [], 'numOfPrb': []}
        tmp_list = [[input_dict['sfn'][i], input_dict['slot'][i]] for i in range(0, len(input_dict['sfn']))]
        new_list = []
        for i in tmp_list:
            if i not in new_list:
                new_list.append(i)
        sfn_list = [sub_list[0] for sub_list in new_list]
        slot_list = [sub_list[1] for sub_list in new_list]
        ulFdSchedData_event_Data = self.get_ulFdSchedData_Event(file_path)
        sfn_col = self.parameter_dict['INDEX_ulFdSchedData_SFN'] - 1
        slot_col = self.parameter_dict['INDEX_ulFdSchedData_slot'] - 1
        numOfPrb_col = self.parameter_dict['INDEX_ulFdSchedData_pbr'] - 1
        startPrb_col = self.parameter_dict['INDEX_ulFdSchedData_startPrb'] - 1
        for i in range(0, len(ulFdSchedData_event_Data)):
            for j in range(0, len(sfn_list)):
                if ulFdSchedData_event_Data[i][1][sfn_col] == sfn_list[j] and \
                        ulFdSchedData_event_Data[i][1][slot_col] == slot_list[j]:
                    result_dict['sfn'].append(sfn_list[j])
                    result_dict['slot'].append(slot_list[j])
                    result_dict['numOfPrb'].append(ulFdSchedData_event_Data[i][1][numOfPrb_col])
                    result_dict['startPrb'].append(ulFdSchedData_event_Data[i][1][startPrb_col])
        return result_dict

    def get_ulFdSchedData_Prb_filter_slot(self, file_path, slot_value, Frame_period, number):
        """
            Author: Jiang Hongyu
            Description: Filter by ulFdSchedData: sfn, slot,
            :return:  get result of numOfPrb and startPrb after filter by slot value
        """
        sfn_list = [str(i) for i in range(1, int(Frame_period) * int(number), int(Frame_period))]
        slot_list = [str(slot_value) for i in range(0, len(sfn_list))]
        input_dict = {'sfn': sfn_list, 'slot': slot_list}
        result_dict = \
            self.get_ulFdSchedData_prb_filter_sfn_slot(file_path=file_path, input_dict=input_dict)
        return result_dict

    def get_all_FdSchedData_event(self, file_path, direction):
        """
            Author: Jiang Hongyu
            Description: Filter by "ulFdSchedData: sfn" or "dlFdSchedData: sfn"
            :return:  get result of all data in csv filter by "ulFdSchedData: sfn" or "dlFdSchedData: sfn"
        """
        if direction.lower() == 'dl':
            self.get_parameters_column(file_path, 'dl')
            FdSchedData_event = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.parameters.INDEX_event],
                expected_list=["dlFdSchedData: sfn"])
        else:
            self.get_parameters_column(file_path, 'ul')
            FdSchedData_event = get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.parameters.INDEX_event],
                expected_list=["ulFdSchedData: sfn"])
        return FdSchedData_event

    def get_sfn_slot_according_fdSchedData(self, file_path, direction):
        """
            Author: Jiang Hongyu
            Description: Filter by "ulFdSchedData: sfn" or "dlFdSchedData: sfn"
            :return:  get result of sfn and slot column data
        """
        sfn_list = []
        slot_list = []
        if direction.lower() == 'dl':
            self.get_parameters_column(file_path, 'dl')
            index_slot = self.parameter_dict['INDEX_dlFdSchedData_slot']
            index_sfn = self.parameter_dict['INDEX_dlFdSchedData_SFN']
        else:
            self.get_parameters_column(file_path, 'ul')
            index_slot = self.parameter_dict['INDEX_ulFdSchedData_slot']
            index_sfn = self.parameter_dict['INDEX_ulFdSchedData_SFN']
        fdSchedData_data = self.get_all_FdSchedData_event(file_path, direction)

        for i in range(0, len(fdSchedData_data)):
            cur_slot = int(fdSchedData_data[i][1][index_slot - 1])
            sfn = int(fdSchedData_data[i][1][index_sfn - 1])
            slot_list.append(cur_slot)
            sfn_list.append(sfn)
        return sfn_list, slot_list

    def get_sfn_slot_rnti_mscTable_prb(self, file_path, direction):
        """
            Author: Jiang Hongyu
            Description: Filter by "ulFdSchedData: sfn" or "dlFdSchedData: sfn"
            :return:  get result of sfn,slot,rnti,mscTable,numOfPrb column data
        """
        if direction.lower() == 'dl':
            self.get_parameters_column(file_path, 'dl')
            index_slot = self.parameter_dict['INDEX_dlFdSchedData_slot']
            index_sfn = self.parameter_dict['INDEX_dlFdSchedData_SFN']
            index_rnti = self.parameter_dict['INDEX_dlFdSchedData_rnti']
            index_msc = self.parameter_dict['INDEX_dlFdSchedData_mcsTable']
            index_prb = self.parameter_dict['INDEX_dlFdSchedData_pbr']
        else:
            self.get_parameters_column(file_path, 'ul')
            index_slot = self.parameter_dict['INDEX_ulFdSchedData_slot']
            index_sfn = self.parameter_dict['INDEX_ulFdSchedData_SFN']
            index_rnti = self.parameter_dict['INDEX_ulFdSchedData_rnti']
            index_msc = self.parameter_dict['INDEX_ulFdSchedData_mcsTable']
            index_prb = self.parameter_dict['INDEX_ulFdSchedData_pbr']
        fdSchedData_data = self.get_all_FdSchedData_event(file_path, direction)

        sfn_list = [int(fdSchedData_data[i][1][index_sfn - 1]) for i in range(0, len(fdSchedData_data))]
        slot_list = [int(fdSchedData_data[i][1][index_slot - 1]) for i in range(0, len(fdSchedData_data))]
        rnti_list = [int(fdSchedData_data[i][1][index_rnti - 1]) for i in range(0, len(fdSchedData_data))]
        msc_list = [fdSchedData_data[i][1][index_msc - 1] for i in range(0, len(fdSchedData_data))]
        prb_list = [int(fdSchedData_data[i][1][index_prb - 1]) for i in range(0, len(fdSchedData_data))]
        return sfn_list, slot_list, rnti_list, msc_list, prb_list


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


tti_trace_analysis_19B = TTI_Trace_analysis('20B')


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


def get_sfn_tbsize_according_fdscheddata_19b(file_path, fdSchedData_data, direction):
    return tti_trace_analysis_19B.get_sfn_tbsize_according_fdSchedData(
        file_path, fdSchedData_data, direction)


def get_sfn_diff_tbsize_19b(sfn_list, tbsize_list):
    return tti_trace_analysis_19B.get_20_sfn_diff_tbsize(sfn_list, tbsize_list)


def get_rrmUsedMcs_19b(file_path, direction):
    return tti_trace_analysis_19B.get_rrmUsedMcs(file_path, direction)


def get_rrmProposedMcs_19b(file_path, direction):
    return tti_trace_analysis_19B.get_rrmProposedMcs(file_path, direction)


def get_ulFdSchedData_numofprb_and_tbsize_19b(file_path_dict):
    ul_file_path = file_path_dict['UL']
    return tti_trace_analysis_19B.get_ulFdSchedData_numofprb_and_tbsize(
        ul_file_path)


def check_one_sfn_cycle_with_diff_slot_19b(file_path, cell_id, direction):
    return tti_trace_analysis_19B.check_one_sfn_cycle_with_diff_slot(
        file_path, cell_id, direction)


def get_one_sfn_cycle_rnti_proportion_19b(file_path, cell_id, rnti_num, direction, unuse_ranti_num):
    return tti_trace_analysis_19B.get_one_sfn_cycle_rnti_proportion(
        file_path, cell_id, rnti_num, direction, unuse_ranti_num)


def check_continuity_of_sfn_in_sfn_cycle_19b(file_path, cell_id, direction):
    return tti_trace_analysis_19B.check_continuity_of_sfn_in_sfn_cycle(
        file_path, cell_id, direction)


def get_one_sfn_cycle_txNumber_19b(file_path, cell_id, direction):
    return tti_trace_analysis_19B.get_one_sfn_cycle_txNumber(
        file_path, cell_id, direction)


def get_ulHarqRxData_crcResult_19b(file_path, crcResult='OK'):
    return tti_trace_analysis_19B.get_ulHarqRxData_crcResult(file_path, crcResult)


def get_FdSchedData_numofprb_19b(file_path, direction, except_value, equal_flag):
    return tti_trace_analysis_19B.get_FdSchedData_numofprb(file_path, direction, except_value, equal_flag)


def check_rrmDlUsedMcs_equal_rrmDlProposedMcs_19b(file_path, equal_flag):
    return tti_trace_analysis_19B.check_rrmDlUsedMcs_equal_rrmDlProposedMcs(file_path, equal_flag)


def get_ulFdSchedData_rrmBufferedDataUlTotal_bytes_tbsize_19B(file_path, except_value, Preschedule=False):
    return tti_trace_analysis_19B.get_ulFdSchedData_rrmBufferedDataUlTotal_bytes_tbsize(file_path, except_value,
                                                                                        Preschedule)


def get_ulTdSchedSubcellData_resReqClassPrio_19B(file_path, input_value):
    return tti_trace_analysis_19B.get_ulTdSchedSubcellData_resReqClassPrio(file_path, input_value)


def get_dlHarqRxDataArray_rnti_ackNack_19B(file_path):
    return tti_trace_analysis_19B.get_dlHarqRxDataArray_rnti_ackNack(file_path)


def get_csiSrReportData_reportType_ulChannel_19B(file_path, reportType_value='PERIODIC_CSI', ulChannel_value='PUCCH'):
    return \
        tti_trace_analysis_19B.get_csiSrReportData_reportType_ulChannel(file_path, reportType_value, ulChannel_value)


def get_csiSrReportData_rnti_sfn_diff_19B(file_path, except_value):
    return tti_trace_analysis_19B.get_csiSrReportData_rnti_sfn_diff(file_path, except_value)


def get_csiSrReportData_pucchFormat_dlChannel_19B(file_path):
    return tti_trace_analysis_19B.get_csiSrReportData_pucchFormat_dlChannel(file_path)


def get_ulPucchReceiveRespPsData_pucchFormat_dlChannel_19B(file_path):
    return tti_trace_analysis_19B.get_ulPucchReceiveRespPsData_pucchFormat_dlChannel(file_path)


def get_ulPucchReceiveReqData_nANPucch_dlChannel_19B(file_path):
    return tti_trace_analysis_19B.get_ulPucchReceiveReqData_nANPucch_dlChannel(file_path)


def get_laIniDelta_event_dlChannel_19B(file_path):
    return tti_trace_analysis_19B.get_laIniDelta_event_dlChannel(file_path)


def get_laIniDelta_id_dlChannel_19B(file_path):
    return tti_trace_analysis_19B.get_laIniDelta_id_dlChannel(file_path)


def get_laIniDelta_event_ulChannel_19B(file_path):
    return tti_trace_analysis_19B.get_laIniDelta_event_ulChannel(file_path)


def get_laIniDelta_id_ulChannel_19B(file_path):
    return tti_trace_analysis_19B.get_laIniDelta_id_ulChannel(file_path)


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


def replace_csv_content(file_path):
    new_title = ''
    new_file_path = file_path
    with open(file_path, 'r', encoding='utf-8') as csv_file:
        reader = list(csv.reader(csv_file))
        for row in reader:
            if ':' in row[0]:
                if row[0].split(':')[1].lstrip(' ') != 'sfn':
                    new_title = row[0].split(':')[0] + ': sfn'
                    row[0] = new_title
    csv_file.close()
    if new_title != '':
        new_file_path = os.path.splitext(file_path)[0] + '_new.csv'
        with open(new_file_path, 'w', encoding='utf-8', newline='') as new_csv_file:
            writer = csv.writer(new_csv_file)
            writer.writerows(reader)
        new_csv_file.close()
    return new_file_path
