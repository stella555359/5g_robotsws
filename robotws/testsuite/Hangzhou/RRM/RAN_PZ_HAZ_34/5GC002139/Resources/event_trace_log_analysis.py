# -*- coding: utf-8 -*
"""
Author: Wang Yixiang
Contacts: yixiang.x.wang@nokia-sbell.com
Description: Verify number of layers

"""
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python import check_csv_log
import logging
import pprint
from robot.libraries.BuiltIn import BuiltIn


class Event_trace_alaysis_2139(object):
    def __init__(self, file_path):
        self.buildIn = BuiltIn()
        self.file_path = file_path
        self.INDEX_event = 1

        self.INDEX_ulFdSchedData_rnti = 45
        self.INDEX_dlFdSchedData_rnti = 94

        self.INDEX_dlFdSchedData_numOfLayers = 120
        self.INDEX_ulFdSchedData_numOfLayers = 71

        self.INDEX_dlTdSchedSubcellData_resReqClassPrio = self.get_column_value_index_from_event(
            'dlTdSchedSubcellData: hfnTickCount', "resReqClassPrio")
        self.INDEX_ulTdSchedSubcellData_resReqClassPrio = 136

        self.INDEX_rrmDlUsedMcs = 98
        self.INDEX_rrmUlUsedMcs = 49

        self.INDEX_dlTdSchedSubcellData_rnti = self.INDEX_dlTdSchedSubcellData_resReqClassPrio - 1

    def reassign_rnti_layer_column_number(self, file_path):
        """
        Author: Wang Yixiang
        Get column number base on log
        :param file_path:
        :return:
        """
        column_list = []
        last_col_num = None
        with open(file_path) as f:
            lines = f.readlines()
            for line in lines:
                if 'dlFdSchedData: hfnTickCount' in line:
                    dlFdSchedData_column_list = line.split(',')
                    break
            print("dlFdSchedData_column_list is: {}".format(
                dlFdSchedData_column_list))

        for i, value in enumerate(dlFdSchedData_column_list):
            if value.isdigit():
                last_col_num = i
                break

        rnti_num = dlFdSchedData_column_list.index('rnti') + 1
        print("Current available rnti_num is: {}".format(rnti_num))
        layer_num = dlFdSchedData_column_list.index('numOfLayers') + 1
        mcs_num = dlFdSchedData_column_list.index('rrmDlUsedMcs') + 1

        self.INDEX_dlFdSchedData_numOfLayers = last_col_num + layer_num
        self.INDEX_dlFdSchedData_rnti = last_col_num + rnti_num
        self.INDEX_rrmDlUsedMcs = last_col_num + mcs_num

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
            fdSchedData_event_name = "dlFdSchedData: hfnTickCount"
            rnti_index_FdSchedData = self.INDEX_dlFdSchedData_rnti
            print("rnti_index_FdSchedData is: {}".format(rnti_index_FdSchedData))
        elif direction == 'ul':
            fdSchedData_event_name = "ulFdSchedData: hfnTickCount"
            rnti_index_FdSchedData = self.INDEX_ulFdSchedData_rnti
        else:
            raise Exception(
                "Un-supported direction value, available values are ul and dl")
        return self.get_event_by_rnti(
            file_path=file_path,
            rnti=rnti,
            event_name=fdSchedData_event_name,
            rnti_index_in_target_event=rnti_index_FdSchedData)

    def get_event_by_rnti(
            self,
            file_path,
            rnti,
            event_name,
            rnti_index_in_target_event):
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
                column_list=[self.INDEX_event, rnti_index_in_target_event],
                expected_list=[event_name, rnti])
        except LookupError:
            raise LookupError("No {} event found".format(event_name))
        else:
            return target_event

    def get_rntis(self, file_path, direction=None):
        """
        Author: Ding Binmei
        Description: Get rntis from event trace log
                     Each UE will have one unique rnti, so rnti can stand for a ue
        :param file_path: log file path with csv format: /XXX/XXX/TA_Combine_dl_Full_20190220123609.csv
        :param direction: values can be ul or dl, if not input, will get the value from input file name
        :return: rntis with list format
        """
        direction = direction.lower()
        if direction == 'dl':
            index_schedSubcellData_resReqClassPrio = self.INDEX_dlTdSchedSubcellData_resReqClassPrio
            index_schedSubcellData_rnti = self.INDEX_dlTdSchedSubcellData_rnti
            print("Current available rnti_index is: {}".format(
                index_schedSubcellData_rnti))
            filter_schedSubcellData_event = "dlTdSchedSubcellData: hfnTickCount"
            value_schedSubcellData_resReqClassPrio = "40"
        elif direction == 'ul':
            index_schedSubcellData_resReqClassPrio = self.INDEX_ulTdSchedSubcellData_resReqClassPrio
            index_schedSubcellData_rnti = self.INDEX_ulTdSchedSubcellData_rnti
            filter_schedSubcellData_event = "ulTdSchedSubcellData: hfnTickCount"
            value_schedSubcellData_resReqClassPrio = "30"
        else:
            raise Exception(
                "Fail to get rntis: Unsupported value for direction {}, "
                "only ul or dl is supported".format(direction))
        try:
            schedSubcellData_event_with_data_traffic = check_csv_log.get_lines_with_multiple_column_filter(
                file_path=file_path, column_list=[
                    self.INDEX_event, index_schedSubcellData_resReqClassPrio], expected_list=[
                    filter_schedSubcellData_event, value_schedSubcellData_resReqClassPrio])
        except LookupError:
            raise LookupError(
                "Fail to get rnti as no event found for {} with resReqClassPrio={}".format(
                    filter_schedSubcellData_event,
                    value_schedSubcellData_resReqClassPrio))
        rntis = check_csv_log.get_unique_values_in_column(
            matrix=schedSubcellData_event_with_data_traffic,
            column_number=index_schedSubcellData_rnti)
        print("Current available rntis are: {}".format(rntis))
        return rntis

    def get_numOfLayers_in_FdSchedData_event(self, file_path, direction=None):
        """
        Author: Wang Yixiang
        Verify num of layers value in event trace from event dlFdSchedData or ulFdSchedData
        :param file_path:/XXX/XXX/TA_Combine_dl_Full_20190220123609.csv
        :param direction:dl or ul
        :return:
        """
        self.reassign_rnti_layer_column_number(file_path)
        rnti_layer_dict = {}
        if direction is None:
            direction = self.get_transmission_direction_from_file_name(
                file_path=file_path)
        direction = direction.lower()
        if direction == 'dl':
            numOfLayers_index = self.INDEX_dlFdSchedData_numOfLayers
            print("numOfLayers_index: {}".format(numOfLayers_index))
        elif direction == 'ul':
            numOfLayers_index = self.INDEX_ulFdSchedData_numOfLayers
        else:
            raise Exception(
                "Un-supported direction value, available values are ul and dl")
        rntis = self.get_rntis(file_path=file_path, direction=direction)
        for rnti in rntis:
            fdSchedData_event = self.get_fdSchedData_event(
                file_path=file_path, rnti=rnti, direction=direction)
            numOfLayers_list = check_csv_log.get_unique_values_in_column(
                matrix=fdSchedData_event, column_number=numOfLayers_index)
            rnti_layer_dict[rnti] = numOfLayers_list
        pprint.pprint(rnti_layer_dict)
        return rnti_layer_dict

    def verify_numOfLayers_single_ue(
            self,
            file_path,
            exp_num_of_layers,
            direction):
        """
        Author: Wang Yixiang
        Verify num of layers value in event trace from event dlFdSchedData
        :param file_path:/XXX/XXX/TA_Combine_dl_Full_20190220123609.csv
        :param exp_num_of_layers:
        :param direction:dl or ul
        :return:
        """
        rnti_layer_dict = self.get_numOfLayers_in_FdSchedData_event(
            file_path=file_path, direction=direction)
        actual_layer_list = list(rnti_layer_dict.values())[0]
        if exp_num_of_layers not in actual_layer_list:
            raise Exception(
                "Expected layer {} not in actual layers {}, pls check." .format(
                    exp_num_of_layers, actual_layer_list))
        logging.info("All verifications are passed")

    def get_mcs_for_ues(self, file_path, direction=None):
        """
        Author: Wang Yixiang
        Description: Get average DL or UL mcs for ues
        :param file_path: /XXX/XXX/TA_Combine_dl_Full_20190220123609.csv
        :param direction: direction can be dl or ul
        :return:{'11369': 25.57764876632801}
        """
        self.reassign_rnti_layer_column_number(file_path)
        rnti_mcs_dict = {}
        direction = direction.lower()
        rntis = self.get_rntis(file_path=file_path, direction=direction)
        if direction == 'dl':
            mcs_eventName = 'dlFdSchedData: hfnTickCount'
            mcs_rnti_index = self.INDEX_dlFdSchedData_rnti
            mcs_used_index = self.INDEX_rrmDlUsedMcs
        elif direction == 'ul':
            mcs_eventName = 'ulFdSchedData: hfnTickCount'
            mcs_rnti_index = self.INDEX_ulFdSchedData_rnti
            mcs_used_index = self.INDEX_rrmUlUsedMcs
        else:
            raise Exception(
                "Un-supported direction value, available values are ul and dl")
        for rnti in rntis:
            print("Get average mcs for rnti: {}".format(rnti))
            fdSchedData_event = self.get_event_by_rnti(
                file_path=file_path, rnti=rnti,
                event_name=mcs_eventName,
                rnti_index_in_target_event=mcs_rnti_index)

            numOfLayers_list = check_csv_log.get_unique_values_in_column(
                matrix=fdSchedData_event, column_number=mcs_used_index)

            rnti_mcs_dict[rnti] = numOfLayers_list
        pprint.pprint(rnti_mcs_dict)
        return rnti_mcs_dict

    def verify_fixed_mcs_single_ue(self, file_path, exp_mcs, direction):
        """
        Author: Wang Yixiang
        verify fixed mcs of single ue
        :param file_path:/XXX/XXX/TA_Combine_dl_Full_20190220123609.csv
        :param exp_mcs:
        :param direction:dl or ul
        :return:
        """
        max_mcs_log = 0
        exp_mcs = int(exp_mcs)
        rnti_mcs_dict = self.get_mcs_for_ues(
            file_path=file_path, direction=direction)
#        mcs_list = rnti_mcs_dict.values()[0]
        mcs_list = list(rnti_mcs_dict.values())[0]
        for i in mcs_list:
            if int(i) > max_mcs_log:
                max_mcs_log = int(i)

        if max_mcs_log < exp_mcs:
            self.buildIn.fail(
                "Actual mcs list: {} should bigger than expected mcs: {}".format(
                    mcs_list, exp_mcs))
        print("All verifications are passed")
        logging.info("All verifications are passed")

    def get_column_value_index_from_event(self, event, column_name):
        """
        Author: Zhang xuewen
        find column number by column name from event
        :param column_name:
        :param event:
        :return:
        """
        event_column_list, last_col_num = self.reassign_event_column_number(
            event)
        column_index = event_column_list.index(column_name) + 1
        column_value_index = last_col_num + column_index
        return column_value_index

    def reassign_event_column_number(self, event):
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
                    column_list = line.split(',')
                    break
        for i, value in enumerate(column_list):
            if value.isdigit():
                last_col_num = i
                break
        return column_list, last_col_num


def Check_numOfLayers_single_ue(file_path):
    return Event_trace_alaysis_2139(file_path).verify_numOfLayers_single_ue(
        file_path, "RANK4", "dl")


def Check_fixed_mcs_single_ue(file_path):
    return Event_trace_alaysis_2139(file_path).verify_fixed_mcs_single_ue(
        file_path, "23", "dl")
