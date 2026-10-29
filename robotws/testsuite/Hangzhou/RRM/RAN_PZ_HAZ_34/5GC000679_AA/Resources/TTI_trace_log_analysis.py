# -*- coding: utf-8 -*
"""
Author: Chen Xiaodong
Contacts: xiaodong.d.chen@nokia-sbell.com
Description: Verify MCS of ues

"""
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python import check_csv_log
import logging
import pprint
from robot.libraries.BuiltIn import BuiltIn


class Event_trace_alaysis_679(object):
    def __init__(self):
        self.buildIn = BuiltIn()
        self.program = None
        if self.program == "20A" or self.program is None:
            self.INDEX_event = 1

            self.INDEX_ulFdSchedData_rnti = 47
            self.INDEX_dlFdSchedData_rnti = 99

            self.INDEX_rrmDlUsedMcs = 104
            self.INDEX_rrmDlProposedMcs = 105

            self.INDEX_rrmUlUsedMcs = 51
            self.INDEX_rrmUlProposedMcs = 52

            self.INDEX_dlTdSchedSubcellData_resReqClassPrio = 46
            self.INDEX_ulTdSchedSubcellData_resReqClassPrio = 46

            self.INDEX_dlTdSchedSubcellData_rnti = 40

        elif self.program == "20B":
            self.INDEX_event = 1

            self.INDEX_ulFdSchedData_rnti = 47
            self.INDEX_dlFdSchedData_rnti = 101

            self.INDEX_rrmDlUsedMcs = 106
            self.INDEX_rrmDlProposedMcs = 107

            self.INDEX_rrmUlUsedMcs = 51
            self.INDEX_rrmUlProposedMcs = 52

            self.INDEX_dlTdSchedSubcellData_resReqClassPrio = 46
            self.INDEX_ulTdSchedSubcellData_resReqClassPrio = 46

            self.INDEX_dlTdSchedSubcellData_rnti = 40
        else:
            raise Exception("Invalid input for program.")

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
                if 'dlFdSchedData: sfn' in line:
                    dlFdSchedData_column_list = line.split(',')
                    break

        for i, value in enumerate(dlFdSchedData_column_list):
            if value.isdigit():
                last_col_num = i
                break

        rnti_num = dlFdSchedData_column_list.index('rnti') + 1
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
            fdSchedData_event_name = "dlFdSchedData: sfn"
            rnti_index_FdSchedData = self.INDEX_dlFdSchedData_rnti

        elif direction == 'ul':
            fdSchedData_event_name = "ulFdSchedData: sfn"
            rnti_index_FdSchedData = self.INDEX_ulFdSchedData_rnti
        else:
            raise Exception("Un-supported direction value, available values are ul and dl")
        return self.get_event_by_rnti(file_path=file_path, rnti=rnti, event_name=fdSchedData_event_name,
                                      rnti_index_in_target_event=rnti_index_FdSchedData)

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
            filter_schedSubcellData_event = "dlTdSchedSubcellData: sfn"
            value_schedSubcellData_resReqClassPrio = "40"
        elif direction == 'ul':
            index_schedSubcellData_resReqClassPrio = self.INDEX_ulTdSchedSubcellData_resReqClassPrio
            index_schedSubcellData_rnti = self.INDEX_ulTdSchedSubcellData_rnti
            filter_schedSubcellData_event = "ulTdSchedSubcellData: sfn"
            value_schedSubcellData_resReqClassPrio = "30"
        else:
            raise Exception("Fail to get rntis: Unsupported value for direction {}, "
                            "only ul or dl is supported".format(direction))
        try:
            schedSubcellData_event_with_data_traffic = check_csv_log.get_lines_with_multiple_column_filter(
                file_path=file_path,
                column_list=[self.INDEX_event,
                             index_schedSubcellData_resReqClassPrio],
                expected_list=[filter_schedSubcellData_event, value_schedSubcellData_resReqClassPrio])
        except LookupError:
            raise LookupError("Fail to get rnti as no event found for {} with resReqClassPrio={}".format(
                filter_schedSubcellData_event, value_schedSubcellData_resReqClassPrio))
        rntis = check_csv_log.get_unique_values_in_column(
            matrix=schedSubcellData_event_with_data_traffic, column_number=index_schedSubcellData_rnti)
        print("Current available rntis are: {}".format(rntis))
        return rntis

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
            mcs_eventName = 'dlFdSchedData: sfn'
            mcs_rnti_index = self.INDEX_dlFdSchedData_rnti
            mcs_used_index = self.INDEX_rrmDlUsedMcs
        elif direction == 'ul':
            mcs_eventName = 'ulFdSchedData: sfn'
            mcs_rnti_index = self.INDEX_ulFdSchedData_rnti
            mcs_used_index = self.INDEX_rrmUlUsedMcs
        else:
            raise Exception("Un-supported direction value, available values are ul and dl")
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
        rnti_mcs_dict = self.get_mcs_for_ues(file_path=file_path, direction=direction)
        mcs_list = rnti_mcs_dict.values()[0]
        if exp_mcs not in mcs_list:
            self.buildIn.fail("Actual mcs list: {} is not contain expected value: {}".format(mcs_list, exp_mcs))
        print ("All verifications are passed")
        logging.info("All verifications are passed")

    def get_average_used_mcs_for_ues(self, file_path, direction=None, program=None):
        """
        Author: Wang Yixiang
        Description: Get average DL or UL mcs for ues
        :param file_path: /XXX/XXX/TA_Combine_dl_Full_20190220123609.csv
        :param direction: direction can be dl or ul
        :return:{'11369': 25.57764876632801}
        """
        self.program = program
        self.reassign_rnti_layer_column_number(file_path)
        rnti_mcs_dict = {}
        direction = direction.lower()
        rntis = self.get_rntis(file_path=file_path, direction=direction)
        if direction == 'dl':
            mcs_eventName = 'dlFdSchedData: sfn'
            mcs_rnti_index = self.INDEX_dlFdSchedData_rnti
            mcs_used_index = self.INDEX_rrmDlUsedMcs
        elif direction == 'ul':
            mcs_eventName = 'ulFdSchedData: sfn'
            mcs_rnti_index = self.INDEX_ulFdSchedData_rnti
            mcs_used_index = self.INDEX_rrmUlUsedMcs
        else:
            raise Exception("Un-supported direction value, available values are ul and dl")
        for rnti in rntis:
            print("Get average mcs for rnti: {}".format(rnti))
            FdSchedData_event = self.get_event_by_rnti(
                file_path=file_path, rnti=rnti,
                event_name=mcs_eventName,
                rnti_index_in_target_event=mcs_rnti_index)
            sum_mcs = 0
            for i in range(0, len(FdSchedData_event)):
                mcs = int(FdSchedData_event[i][1]
                          [mcs_used_index - 1])
                sum_mcs = sum_mcs + mcs
            avg_mcs = float(sum_mcs) / len(FdSchedData_event)
            rnti_mcs_dict[rnti] = avg_mcs
        pprint.pprint(rnti_mcs_dict)
        return rnti_mcs_dict.values()

    def get_average_proposed_mcs_for_ues(self, file_path, direction=None, program=None):
        """
        Author: Chen Xiaodong
        Description: Get average proposed DL or UL mcs for ues
        :param file_path: /XXX/XXX/TA_Combine_dl_Full_20200520123609.csv
        :param direction: direction can be dl or ul
        :return:{'11369': 25.57764876632801}
        """
        self.program = program
        self.reassign_rnti_layer_column_number(file_path)
        rnti_mcs_dict = {}
        direction = direction.lower()
        rntis = self.get_rntis(file_path=file_path, direction=direction)
        if direction == 'dl':
            mcs_eventName = 'dlFdSchedData: sfn'
            mcs_rnti_index = self.INDEX_dlFdSchedData_rnti
            mcs_used_index = self.INDEX_rrmDlProposedMcs
        elif direction == 'ul':
            mcs_eventName = 'ulFdSchedData: sfn'
            mcs_rnti_index = self.INDEX_ulFdSchedData_rnti
            mcs_used_index = self.INDEX_rrmUlProposedMcs
        else:
            raise Exception("Un-supported direction value, available values are ul and dl")
        for rnti in rntis:
            print("Get average proposed mcs for rnti: {}".format(rnti))
            FdSchedData_event = self.get_event_by_rnti(
                file_path=file_path, rnti=rnti,
                event_name=mcs_eventName,
                rnti_index_in_target_event=mcs_rnti_index)
            sum_mcs = 0
            for i in range(0, len(FdSchedData_event)):
                mcs = int(FdSchedData_event[i][1]
                          [mcs_used_index - 1])
                sum_mcs = sum_mcs + mcs
            avg_mcs = float(sum_mcs) / len(FdSchedData_event)
            rnti_mcs_dict[rnti] = avg_mcs
        pprint.pprint(rnti_mcs_dict)
        return rnti_mcs_dict.values()
