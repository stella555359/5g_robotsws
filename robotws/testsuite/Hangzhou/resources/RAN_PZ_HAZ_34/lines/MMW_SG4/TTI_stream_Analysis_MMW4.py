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


class TTI_Stream_analysis(object):
    def __init__(self):
        self.parameter_dict = {}
        self.Tabel_list = []

    def get_columns(self, reader_list, column_name):
        if len(reader_list[0]) != 0:
            if column_name not in reader_list[0]:
                column_index = 1
            else:
                column_index = reader_list[0].index(column_name) + 1
        return column_index

    def get_parameters_column(self, file_path, direction):
        with open(file_path, 'r') as csv_file:
            reader = list(csv.reader(csv_file))
        self.Tabel_list = reader
        if direction.lower() == 'ul':
            self.parameter_dict['INDEX_ul_rnti'] = \
                self.get_columns(reader_list=reader, column_name='rnti')
            self.parameter_dict['INDEX_ul_sfn'] = \
                self.get_columns(reader_list=reader, column_name='sfn')
            self.parameter_dict['INDEX_ul_slot'] = \
                self.get_columns(reader_list=reader, column_name='slot')
            self.parameter_dict['INDEX_ul_physCellId'] = \
                self.get_columns(reader_list=reader, column_name='physCellId')
            self.parameter_dict['INDEX_ulFdSchedData_pbr'] = \
                self.get_columns(reader_list=reader, column_name='ulFdSchedData.numOfPrb')
            self.parameter_dict['INDEX_ulFdSchedData_mcsTable'] = \
                self.get_columns(reader_list=reader, column_name='ulFdSchedData.mcsTable')
            self.parameter_dict['INDEX_ulFdSchedData_txNumber'] = \
                self.get_columns(reader_list=reader, column_name='ulFdSchedData.txNumber')
            self.parameter_dict['INDEX_ulHarqRxData_crcResult'] = \
                self.get_columns(reader_list=reader, column_name='ulHarqRxData.crcResult')
        elif direction.lower() == 'dl':
            self.parameter_dict['INDEX_dl_sfn'] = \
                self.get_columns(reader_list=reader, column_name='sfn')
            self.parameter_dict['INDEX_dl_rnti'] = \
                self.get_columns(reader_list=reader, column_name='rnti')
            self.parameter_dict['INDEX_dl_slot'] = \
                self.get_columns(reader_list=reader, column_name='slot')
            self.parameter_dict['INDEX_dl_physCellId'] = \
                self.get_columns(reader_list=reader, column_name='physCellId')
            self.parameter_dict['INDEX_dlFdSchedData_pbr'] = \
                self.get_columns(reader_list=reader, column_name='dlFdSchedData.numOfPrb')
            self.parameter_dict['INDEX_dlFdSchedData_mcsTable'] = \
                self.get_columns(reader_list=reader, column_name='dlFdSchedData.mcsTable')
            self.parameter_dict['INDEX_dlFdSchedData_numOfLayers'] = \
                self.get_columns(reader_list=reader, column_name='dlFdSchedData.numOfLayers')
            self.parameter_dict['INDEX_dlFdSchedData_rrmDlProposedMcs'] = \
                self.get_columns(reader_list=reader, column_name='dlFdSchedData.rrmDlProposedMcs')
            self.parameter_dict['INDEX_dlFdSchedData_dmrsConfigType'] = \
                self.get_columns(reader_list=reader, column_name='dlFdSchedData.dmrsConfigType')
            self.parameter_dict['INDEX_dlFdSchedData_rat0Bitmap'] = \
                self.get_columns(reader_list=reader, column_name='dlFdSchedData.rat0Bitmap')
            self.parameter_dict['INDEX_dlFdSchedData_rrmDlUsedMcs'] = \
                self.get_columns(reader_list=reader, column_name='dlFdSchedData.rrmDlUsedMcs')
            self.parameter_dict['INDEX_dlFdSchedData_startPrb'] = \
                self.get_columns(reader_list=reader, column_name='dlFdSchedData.startPrb')
            self.parameter_dict['INDEX_csiSrReportData_reportType'] = \
                self.get_columns(reader_list=reader, column_name='csiSrReportData.reportType')
            self.parameter_dict['INDEX_csiSrReportData_ulChannel'] = \
                self.get_columns(reader_list=reader, column_name='csiSrReportData.ulChannel')
            self.parameter_dict['INDEX_dlHarqRxDataArray_ackNack'] = \
                self.get_columns(reader_list=reader, column_name='dlHarqRxDataArray.ackNack')
            self.parameter_dict['INDEX_dlDtxOptimData_dlDtxOptimEvent'] = \
                self.get_columns(reader_list=reader, column_name='dlDtxOptimData.dlDtxOptimEvent')

    def get_not_empty_list_from_stand_col(self, total_dict, stand_col_name):
        new_total_dict = {}
        stand_list_index = [i for i in range(0, len(total_dict[stand_col_name]))
                            if len(total_dict[stand_col_name][i]) != 0]
        for key in total_dict.keys():
            new_total_dict[key] = [total_dict[key][i] for i in stand_list_index]
        return new_total_dict

    def get_sfn_slot_rnti_mscTable_prb(self, file_path, direction):
        """
            Author: Jiang Hongyu
            Description: Filter by "ulFdSchedData: sfn" or "dlFdSchedData: sfn"
            :return:  get result of sfn,slot,rnti,mscTable,numOfPrb column data
        """
        if direction.lower() == 'dl':
            self.get_parameters_column(file_path, 'dl')
            index_slot = self.parameter_dict['INDEX_dl_slot']
            index_sfn = self.parameter_dict['INDEX_dl_sfn']
            index_rnti = self.parameter_dict['INDEX_dl_rnti']
            index_msc = self.parameter_dict['INDEX_dlFdSchedData_mcsTable']
            index_prb = self.parameter_dict['INDEX_dlFdSchedData_pbr']
        else:
            self.get_parameters_column(file_path, 'ul')
            index_slot = self.parameter_dict['INDEX_ul_slot']
            index_sfn = self.parameter_dict['INDEX_ul_sfn']
            index_rnti = self.parameter_dict['INDEX_ul_rnti']
            index_msc = self.parameter_dict['INDEX_ulFdSchedData_mcsTable']
            index_prb = self.parameter_dict['INDEX_ulFdSchedData_pbr']
        total_dict = {}
        total_dict['sfn_list'] = [int(self.Tabel_list[i][index_sfn - 1]) for i in range(1, len(self.Tabel_list))]
        total_dict['slot_list'] = [int(self.Tabel_list[i][index_slot - 1]) for i in range(1, len(self.Tabel_list))]
        total_dict['rnti_list'] = [int(self.Tabel_list[i][index_rnti - 1]) for i in range(1, len(self.Tabel_list))]
        total_dict['msc_list'] = [self.Tabel_list[i][index_msc - 1] for i in range(1, len(self.Tabel_list))]
        total_dict['prb_list'] = [self.Tabel_list[i][index_prb - 1].split('.')[0]
                                  for i in range(1, len(self.Tabel_list))]
        new_total_dict = self.get_not_empty_list_from_stand_col(total_dict=total_dict, stand_col_name='prb_list')
        sfn_list = new_total_dict['sfn_list']
        slot_list = new_total_dict['slot_list']
        rnti_list = new_total_dict['rnti_list']
        msc_list = new_total_dict['msc_list']
        prb_list = [int(i) for i in new_total_dict['prb_list']]
        return sfn_list, slot_list, rnti_list, msc_list, prb_list

    def get_rnti_value_of_same_sfn_slot(self, file_path, direction, expect_rnti_num):
        """
            Author: Jiang Hongyu
            Description: Filter by "ulFdSchedData: sfn" or "dlFdSchedData: sfn"
            :return:  get result of sfn,slot,rnti,mscTable,numOfPrb column data
        """
        all_value_list = self.get_sfn_slot_rnti_mscTable_prb(file_path=file_path, direction=direction)
        sfn_list = all_value_list[0]
        slot_list = all_value_list[1]
        rnti_list = all_value_list[2]
        sfn_slot_list = [[sfn_list[i], slot_list[i]] for i in range(0, len(sfn_list))]
        print(sfn_slot_list)
        diff_index_list = [i for i in range(0, len(sfn_slot_list)-1) if sfn_slot_list[i] != sfn_slot_list[i + 1]]
        diff_index_list.append(len(sfn_slot_list)-1)
        print(diff_index_list)
        index_diff_list = [[diff_index_list[j] + 1, diff_index_list[j + 1] + 1] for j in
                           range(0, len(diff_index_list) - 1)
                           if diff_index_list[j + 1] - diff_index_list[j] >= expect_rnti_num]
        print(index_diff_list)
        for sub_index_list in index_diff_list:
            rnti_value_list = rnti_list[sub_index_list[0]:sub_index_list[1]]
            rnti_value_list = list(filter(lambda x: x != 65535, rnti_value_list))
            print(rnti_value_list)
            if len(rnti_value_list) == expect_rnti_num:
                return True
        return False

    def get_numOfLayers_rrmDlProposedMcs_value(self, file_path, numOfLayers_value, rrmDlProposedMcs_value,
                                               mcsTable_value='QAM64LOWSE'):
        """
            Author: Jiang Hongyu
            Description: Filter by "dlFdSchedData"
            :numOfLayers_value: expect the value of numOfLayers_value
            :rrmDlProposedMcs_value: expect the value of rrmDlProposedMcs_value
            :mcsTable_value: expect the value of mcsTable_value
            fuction:  get result of numOfLayers, mcsTable, rrmDlProposedMcs column data and check value
            :return 0:Indicates that no corresponding numOfLayers and mcsTable value was found;
            -1:The rrmDlProposedMcs_value corresponding to numOfLayers_value is incorrect
            1:The rrmDlProposedMcs_value corresponding to numOfLayers_value is correct
        """
        self.get_parameters_column(file_path, 'dl')
        index_numOfLayers = self.parameter_dict['INDEX_dlFdSchedData_numOfLayers']
        index_rrmDlProposedMcs = self.parameter_dict['INDEX_dlFdSchedData_rrmDlProposedMcs']
        index_mcsTable = self.parameter_dict['INDEX_dlFdSchedData_mcsTable']
        total_dict = {}
        total_dict['numOfLayers_list'] = [self.Tabel_list[i][index_numOfLayers - 1]
                                          for i in range(1, len(self.Tabel_list))]
        total_dict['rrmDlProposedMcs_list'] = [self.Tabel_list[i][index_rrmDlProposedMcs - 1]
                                               for i in range(1, len(self.Tabel_list))]
        total_dict['mcsTable_list'] = [self.Tabel_list[i][index_mcsTable - 1]
                                       for i in range(1, len(self.Tabel_list))]
        new_total_dict = self.get_not_empty_list_from_stand_col(total_dict=total_dict,
                                                                stand_col_name='numOfLayers_list')
        expect_numOfLayers_value_index = [i for i in range(0, len(new_total_dict['numOfLayers_list']))
                                          if new_total_dict['numOfLayers_list'][i] == numOfLayers_value]
        expect_mcsTable_value_index = [i for i in range(0, len(new_total_dict['mcsTable_list']))
                                       if new_total_dict['mcsTable_list'][i] == mcsTable_value]
        actual_numOfLayers_value = [i for i in new_total_dict['numOfLayers_list'] if i == numOfLayers_value]
        actual_mcsTable_value = [i for i in new_total_dict['mcsTable_list'] if i == mcsTable_value]
        final_index = list(set(expect_numOfLayers_value_index).intersection(set(expect_mcsTable_value_index)))
        actual_rrmDlProposedMcs_value = [eval(new_total_dict['rrmDlProposedMcs_list'][i])
                                         for i in final_index]
        print(actual_rrmDlProposedMcs_value)
        if len(actual_numOfLayers_value) == 0 and len(actual_mcsTable_value) == 0:
            return 0
        for i in actual_rrmDlProposedMcs_value:
            if (i != 255 and i > rrmDlProposedMcs_value and i <= 28):
                return -1
        return 1

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
        total_dict = {}
        try:
            total_dict['reporttype_list'] = [self.Tabel_list[i][reporttype_col] for i
                                             in range(1, len(self.Tabel_list))]
            total_dict['ulChannel_list'] = [self.Tabel_list[i][ulChannel_col] for i in range(1, len(self.Tabel_list))]
            new_total_dict = self.get_not_empty_list_from_stand_col(total_dict=total_dict,
                                                                    stand_col_name='reporttype_list')
            reporttype_list = new_total_dict['reporttype_list']
            ulChannel_list = new_total_dict['ulChannel_list']
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
        rnti_col = self.parameter_dict['INDEX_dl_rnti'] - 1
        sfn_col = self.parameter_dict['INDEX_dl_sfn'] - 1
        reporttype_col = self.parameter_dict['INDEX_csiSrReportData_reportType'] - 1
        try:
            total_dict = {}
            total_dict['rnti_list'] = [self.Tabel_list[i][rnti_col] for i in range(1, len(self.Tabel_list))]
            total_dict['sfn_list'] = [self.Tabel_list[i][sfn_col] for i in range(1, len(self.Tabel_list))]
            total_dict['reporttype_list'] = [self.Tabel_list[i][reporttype_col]
                                             for i in range(1, len(self.Tabel_list))]
            new_total_dict = self.get_not_empty_list_from_stand_col(total_dict=total_dict,
                                                                    stand_col_name='reporttype_list')
            for i in range(0, len(new_total_dict['reporttype_list'])):
                rnti_id = new_total_dict['rnti_list'][i]
                if rnti_id not in rnti_sfn_dict.keys():
                    rnti_sfn_dict[rnti_id] = []
                rnti_sfn_dict[rnti_id].append(new_total_dict['sfn_list'][i])
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
            print(rnti_sfn_diff_time_dict)
            return rnti_sfn_diff_time_dict

    def get_HarqRxDataArray_ackNack_number(self, file_path, direction):
        """
        Author: Jiang Hongyu
        Description: Filter by dlHarqRxDataArray and get the number of ack and nack
        :param: for example:if except_value == 4,
        :return: ack and nack number
        """
        value_list = ['OK', 'NOK', 'ACK', 'NACK']
        if direction.lower() == 'dl':
            self.get_parameters_column(file_path, 'dl')
            ackNack_col = self.parameter_dict['INDEX_dlHarqRxDataArray_ackNack'] - 1
        else:
            self.get_parameters_column(file_path, 'ul')
            ackNack_col = self.parameter_dict['INDEX_ulHarqRxData_crcResult'] - 1
        try:
            total_dict = {}
            total_dict['ackNack_list'] = [self.Tabel_list[i][ackNack_col] for i in range(1, len(self.Tabel_list))
                                          if self.Tabel_list[i][ackNack_col] in value_list]
            new_total_dict = self.get_not_empty_list_from_stand_col(total_dict=total_dict,
                                                                    stand_col_name='ackNack_list')
            ackNack_content = new_total_dict['ackNack_list']
        except LookupError:
            raise LookupError("Tabel is null")
        NACK_list = [i for i in ackNack_content if (i.upper() == 'NACK' or i.upper() == 'NOK')]
        if len(NACK_list) != 0:
            bler = float(len(NACK_list)/len(ackNack_content))*100
        else:
            bler = 0
        return bler

    def get_ulFdSchedData_txNumber_data(self, file_path):
        """
        Author: Jiang Hongyu
        Description: Filter by ulFdSchedData and get the data of txNumber
        :return: ul bler value
        """
        value_list = ['', '255.0']
        self.get_parameters_column(file_path, 'ul')
        txNumber_col = self.parameter_dict['INDEX_ulFdSchedData_txNumber'] - 1
        try:
            txNumber_list = [int(float(self.Tabel_list[i][txNumber_col])) for i in range(1, len(self.Tabel_list))
                             if self.Tabel_list[i][txNumber_col] not in value_list]
            NACK_list = [i for i in txNumber_list if i != 1]
        except LookupError:
            raise LookupError("Tabel is null")
        if len(NACK_list) != 0:
            bler = float(len(NACK_list)/len(txNumber_list))*100
        else:
            bler = 0
        return bler

    def get_dlFdSchedData_dmrsConfigType_value(self, file_path):
        """
        Author: Jiang Hongyu
        Description: Filter by dlFdSchedData and get the value of dmrsConfigType
        :return: dmrsConfigType value list
        """
        self.get_parameters_column(file_path, 'dl')
        dmrsConfigType_col = self.parameter_dict['INDEX_dlFdSchedData_dmrsConfigType'] - 1
        total_dict = {}
        total_dict['dmrsConfigType_list'] = [self.Tabel_list[i][dmrsConfigType_col] for
                                             i in range(1, len(self.Tabel_list))]
        new_total_dict = self.get_not_empty_list_from_stand_col(total_dict=total_dict,
                                                                stand_col_name='dmrsConfigType_list')
        value_list = new_total_dict['dmrsConfigType_list']
        print(value_list)
        return value_list

    def get_dlFdSchedData_rat0Bitmap_value(self, file_path):
        """
        Author: Jiang Hongyu
        Description: Filter by dlFdSchedData and get the value of rat0Bitmap
        :return: rat0Bitmap value list
        """
        self.get_parameters_column(file_path, 'dl')
        rat0Bitmap_col = self.parameter_dict['INDEX_dlFdSchedData_rat0Bitmap'] - 1
        total_dict = {}
        total_dict['rat0Bitmap_list'] = [self.Tabel_list[i][rat0Bitmap_col].split('.')[0]
                                         for i in range(1, len(self.Tabel_list))]
        new_total_dict = self.get_not_empty_list_from_stand_col(total_dict=total_dict,
                                                                stand_col_name='rat0Bitmap_list')
        value_list = new_total_dict['rat0Bitmap_list']
        return value_list

    def get_dlFdSchedData_startPrb_value(self, file_path):
        """
        Author: Jiang Hongyu
        Description: Filter by dlFdSchedData and get the value of startPrb
        :return: startPrb value list
        """
        self.get_parameters_column(file_path, 'dl')
        startPrb_col = self.parameter_dict['INDEX_dlFdSchedData_startPrb'] - 1
        total_dict = {}
        total_dict['startPrb_list'] = [self.Tabel_list[i][startPrb_col].split('.')[0]
                                       for i in range(1, len(self.Tabel_list))]
        new_total_dict = self.get_not_empty_list_from_stand_col(total_dict=total_dict,
                                                                stand_col_name='startPrb_list')
        value_list = [int(i) for i in new_total_dict['startPrb_list']]
        return value_list

    def get_dlFdSchedData_rat0Bitmap_physCellId(self, file_path):
        """Author: Jiang Hongyu
        Description: Filter by dlFdSchedData and get the value of rat0Bitmap and physCellId
        :return: A dict that include physCellId:rat0Bitmap
        """
        self.get_parameters_column(file_path, 'dl')
        rat0Bitmap_col = self.parameter_dict['INDEX_dlFdSchedData_rat0Bitmap'] - 1
        physCellId_col = self.parameter_dict['INDEX_dl_physCellId'] - 1
        total_dict = {}
        total_dict['rat0Bitmap_list'] = [self.Tabel_list[i][rat0Bitmap_col].split('.')[0]
                                         for i in range(1, len(self.Tabel_list))]
        total_dict['physCellId_list'] = [self.Tabel_list[i][physCellId_col] for i in range(1, len(self.Tabel_list))]
        new_total_dict = self.get_not_empty_list_from_stand_col(total_dict=total_dict,
                                                                stand_col_name='rat0Bitmap_list')
        result_dict = {}
        physCellId_value_list = new_total_dict['physCellId_list']
        rat0Bitmap_value_list = new_total_dict['rat0Bitmap_list']
        for i in range(0, len(physCellId_value_list)):
            if physCellId_value_list[i] not in result_dict.keys():
                result_dict[physCellId_value_list[i]] = []
            result_dict[physCellId_value_list[i]].append(rat0Bitmap_value_list[i])
        return result_dict

    def get_dlFdSchedData_slot_numOfPrb_rrmDlUsedMcs(self, file_path):
        """Author: Jiang Hongyu
        Description: Filter by dlFdSchedData and get the values of numOfPrb and rrmDlUsedMcs for a specific slot
        :return: A dict that include slot:[rrmDlUsedMcs, numOfPrb]
        """
        self.get_parameters_column(file_path, 'dl')
        slot_col = self.parameter_dict['INDEX_dl_slot'] - 1
        numOfPrb_col = self.parameter_dict['INDEX_dlFdSchedData_pbr'] - 1
        rrmDlUsedMcs_col = self.parameter_dict['INDEX_dlFdSchedData_rrmDlUsedMcs'] - 1
        sfn_col = self.parameter_dict['INDEX_dl_sfn'] - 1
        total_dict = {}
        total_dict['slot_list'] = [self.Tabel_list[i][slot_col] for i in range(1, len(self.Tabel_list))]
        total_dict['sfn_list'] = [self.Tabel_list[i][sfn_col] for i in range(1, len(self.Tabel_list))]
        total_dict['numOfPrb_list'] = [self.Tabel_list[i][numOfPrb_col].split('.')[0]
                                       for i in range(1, len(self.Tabel_list))]
        total_dict['rrmDlUsedMcs_list'] = [self.Tabel_list[i][rrmDlUsedMcs_col].split('.')[0]
                                           for i in range(1, len(self.Tabel_list))]
        new_total_dict = self.get_not_empty_list_from_stand_col(total_dict=total_dict,
                                                                stand_col_name='rrmDlUsedMcs_list')
        slot_value_list = new_total_dict['slot_list']
        sfn_value_list = new_total_dict['sfn_list']
        numOfPrb_value_list = new_total_dict['numOfPrb_list']
        rrmDlUsedMcs_value_list = new_total_dict['rrmDlUsedMcs_list']
        result_dict = {}
        for i in range(0, len(slot_value_list)):
            if slot_value_list[i] not in result_dict.keys():
                result_dict[slot_value_list[i]] = []
            result_dict[slot_value_list[i]].append([rrmDlUsedMcs_value_list[i], numOfPrb_value_list[i],
                                                    sfn_value_list[i]])
        return result_dict

    def get_dlDtxOptimData_dlDtxOptimEvent(self, file_path):
        """Author: Jiang Hongyu
        Description: Filter by dlDtxOptimData and get the values of dlDtxOptimEvent
        :return: A dict that include {value_name:list_len}
        """
        self.get_parameters_column(file_path, 'dl')
        dlDtxOptimEvent_col = self.parameter_dict['INDEX_dlDtxOptimData_dlDtxOptimEvent'] - 1
        total_dict = {}
        result_dict = {}
        total_dict['dlDtxOptimEvent_list'] = [self.Tabel_list[i][dlDtxOptimEvent_col]
                                              for i in range(1, len(self.Tabel_list))]
        new_total_dict = self.get_not_empty_list_from_stand_col(total_dict=total_dict,
                                                                stand_col_name='dlDtxOptimEvent_list')
        dlDtxOptimEvent_value_list = list(set(new_total_dict['dlDtxOptimEvent_list']))
        for value in dlDtxOptimEvent_value_list:
            value_list = [i for i in new_total_dict['dlDtxOptimEvent_list'] if i == value]
            result_dict[value] = len(value_list)
        return result_dict
