# -*- coding: utf-8 -*

"""
Author:         Ding Binmei
Contact Mail:   binmei.ding@nokia-sbell.com
Description:    Event trace log analysis for 1726 feature
"""
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python import check_csv_log
import logging
import pprint
import csv
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.common_event_trace_log_analysis import (
    Parameters19B, ParametersMaster, Event_trace_log_analysis)


class Event_trace_log_analysis_1726(Event_trace_log_analysis):
    def calculate_dtx_ratio_in_dlHarqRxData_event(self, dlHarqRxData_event, file_path):
        """
        Author: Ding Binmei
        Description: DTX_ratio = DTX row num/ ALL row num
        :param dlHarqRxData_event:
        :return:
        """
        self.reassign_dlHarqRxData_column_number(file_path=file_path)
        try:
            dtx_event = check_csv_log.add_filters_to_matrix(dlHarqRxData_event,
                                                            [self.INDEX_dlHarqRxData_dtx, ['DTX']])
        except LookupError:
            count_with_dtx = 0
        else:
            count_with_dtx = len(dtx_event)
        count_all = len(dlHarqRxData_event)
        dtx_ratio = float(count_with_dtx) / float(count_all)
        return dtx_ratio

    def verify_dtx_ratio_is_as_expected(self, dtx_ratio, exp_dtx_ratio):
        """
        Author: Ding Binmei
        Description: verify is dtx ratio meets the requirement
        :param dtx_ratio:
        :param exp_dtx_ratio:
        :return:
        """
        if float(dtx_ratio) <= float(exp_dtx_ratio):
            print("Verify dtx ratio passed. Actual dtx ratio {} is as expected".format(dtx_ratio))
        else:
            raise Exception("Actual dtx ratio: {} > {}(expected dtx ratio)".format(dtx_ratio, exp_dtx_ratio))

    def verify_dlHarqRxData_event_matches_with_dlFdSchedData_event(self, dlHarqRxData_event, dlFdSchedData_event):
        """
        Author: Ding Binmei
        Description: one dlFdSchedData_event should have one dlHarqRxData_event followed.
        But in case that logs may not captured completely. So the row count gap between these 2 events should <=2
        :param dlHarqRxData_event:
        :param dlFdSchedData_event:
        :return:
        """
        count_dlHarqRxData_event = len(dlHarqRxData_event)
        count_dlFdSchedData_event = len(dlFdSchedData_event)
        row_num_gap = abs(count_dlFdSchedData_event - count_dlHarqRxData_event)
        if row_num_gap > 2:
            raise Exception("Row count gap between dlFdSchedData_event and dlHarqRxData_event is {}, which is > 2,"
                            " count_dlHarqRxData_event: {}, count_dlFdSchedData_event: {}"
                            "".format(row_num_gap, count_dlHarqRxData_event, count_dlFdSchedData_event))
        else:
            print("Verify dlHarqRxData_event matches with dlFdSchedData_event pass, row_num_gap: {}, "
                  "expected row num gap should <=2".format(row_num_gap))

    def verify_harq_transmission_is_via_pucch_on_pscell(self,
                                                        dlHarqRxData_event,
                                                        physical_cell_id_for_attach,
                                                        file_path):
        """
        Author: Ding Binmei
        Description: Verify physCellId in dlHarqRxData_event is the same with physCellId used for attach
        :param dlHarqRxData_event:
        :param physical_cell_id_for_attach:
        :return:
        """
        self.reassign_dlHarqRxData_column_number(file_path=file_path)
        physCellId_harq = check_csv_log.get_unique_values_in_column(
            matrix=dlHarqRxData_event, column_number=self.INDEX_dlHarqRxData_physCellId)
        if len(physCellId_harq) == 1 and physCellId_harq[0] == str(physical_cell_id_for_attach):
            print("Verify harq transmission is via pucch on psell passed. "
                  "physical cell id for attach is: {}".format(physical_cell_id_for_attach))
        else:
            raise Exception("Verify harq transmission is via pucch on psell failed. "
                            "Physical cell id for attach is :{}, "
                            "but physical cell id in harq event is: {}".format(physical_cell_id_for_attach,
                                                                               physCellId_harq))

    def check_csi_reports_scheduled_for_all_CCs_for_ue(self, file_path, expected_physCellId_list):
        """
        Author: Wang Yixiang
        Description: 1. Check that CSI reports are scheduled for all the allocated component carriers for the UE
                     2. Verify csiSrReportData event
        :param file_path: /XXX/XXX/TA_Combine_dl_Full_20190220123609.csv
        :param physCellId_list:
        :return:
        """
        self.reassign_csiSrReportData_column_number(file_path=file_path)
        rntis = self.get_rntis(file_path=file_path, direction='dl')
        int_actual_physCellId_list = []
        for rnti in rntis:
            print("Check DL HARQ feedbacks are received successfully for rnti: {}".format(rnti))
            csiSrReportData_event = self.get_event_by_rnti(
                file_path=file_path, rnti=rnti,
                event_name='csiSrReportData: hfnTickCount',
                rnti_index_in_target_event=self.INDEX_csiSrReportData_rnti)
            actual_physCellId_list = check_csv_log.get_unique_values_in_column(
                matrix=csiSrReportData_event, column_number=self.INDEX_csiSrReportData_physCellId)
        # convert the str data to int
            for cur_physcellid in actual_physCellId_list:
                int_actual_physCellId_list.append(int(cur_physcellid))
        assert set(int_actual_physCellId_list) <= set(expected_physCellId_list), \
            "physCellId list not match, actual physCellId_list:{}, expected physCellId_list:{}"\
            .format(actual_physCellId_list, expected_physCellId_list)

    def Verify_physCellId_in_FdSchedData_event(self, file_path, direction, physical_cell_id_for_attach):
        """
        Author: Ren Biyao
        Description: Get row count in FdSchedData_event with provided txNumber, can support for both ul and dl
        :param txNumber: if txNumber = 1, it means for the first transmission; if >=2, means for re-transmission
        :param FdSchedData_event:
        :param direction: can be ul, dl
        :return:
        """
        direction = direction.lower()
        rntis = self.get_rntis(file_path=file_path, direction=direction)
        if direction == 'dl':
            self.reassign_dlFdSchedData_column_number(file_path=file_path)
            physCellId_index_in_FdSchedData_event = self.INDEX_dlFdSchedData_physCellId
        elif direction == 'ul':
            self.reassign_ulFdSchedData_column_number(file_path=file_path)
            physCellId_index_in_FdSchedData_event = self.INDEX_ulFdSchedData_physCellId
        else:
            raise Exception("Un-supported direction value, available values are ul and dl")
        for rnti in rntis:
            fdSchedData_event = self.get_fdSchedData_event(file_path=file_path, rnti=rnti, direction=direction)
            physcellid_in_fdSchedData_event = check_csv_log.get_unique_values_in_column(
                matrix=fdSchedData_event, column_number=physCellId_index_in_FdSchedData_event
            )
            if len(physcellid_in_fdSchedData_event) == 1:
                if int(physcellid_in_fdSchedData_event[0]) == int(physical_cell_id_for_attach):
                    print('physcellid in fdSchedData event is {}, which equals to actual attach physical cell '
                          'id {}'.format(int(physcellid_in_fdSchedData_event[0]), physical_cell_id_for_attach))
                else:
                    raise Exception('physcellid in fdSchedData event is {}, which does not equals to attach physical '
                                    'cell id {}'.format(physcellid_in_fdSchedData_event,
                                                        physical_cell_id_for_attach))
            else:
                raise Exception('physcellid in fdSchedData event for rnti{} is not unique.'. format(rnti))

    def get_average_mcs_for_ues(self, file_path, direction=None):
        """
        Author: Wang Yixiang
        Description: Get average DL or UL mcs for ues
        :param file_path: /XXX/XXX/TA_Combine_dl_Full_20190220123609.csv
        :param direction: direction can be dl or ul
        :return:{'11369': 25.57764876632801}
        """
        rnti_mcs_dict = {}
        if direction is None:
            direction = self.get_transmission_direction_from_file_name(file_path=file_path)
        direction = direction.lower()
        rntis = self.get_rntis(file_path=file_path, direction=direction)
        if direction == 'dl':
            self.reassign_dlFdSchedData_column_number(file_path=file_path)
            mcs_eventName = 'dlFdSchedData: hfnTickCount'
            mcs_rnti_index = self.INDEX_dlFdSchedData_rnti
            mcs_used_index = self.INDEX_rrmDlUsedMcs
        elif direction == 'ul':
            self.reassign_ulFdSchedData_column_number(file_path=file_path)
            mcs_eventName = 'ulFdSchedData: hfnTickCount'
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
        return rnti_mcs_dict

    def get_bler_mcs_single_ue(self, file_path, direction=None):
        """
        Author: Wang Yixiang
        Description: Get dl bler and mcs from DL event trace
        :param dict_event_trace_log: /XXX/XXX/TA_Combine_dl_Full_20190220123609.csv
        :param direction: direction can be dl or ul
        :return:{'bler': 0.006165228113440197, 'mcs': 3.582167832167832}
        """
        bler_mcs_dict = {}
        if direction is None:
            direction = self.get_transmission_direction_from_file_name(file_path=file_path)
        direction = direction.lower()
        rnti_bler_dict = self.calculate_bler(file_path=file_path, direction=direction)
        rnti_mcs_dict = self.get_average_mcs_for_ues(file_path=file_path, direction=direction)
        bler_mcs_dict['bler'] = rnti_bler_dict.values()[0]
        bler_mcs_dict['mcs'] = rnti_mcs_dict.values()[0]
        pprint.pprint(bler_mcs_dict)
        return bler_mcs_dict

    def verify_dl_max_data_rate_indicated_by_uecapability_not_exceed_in_any_slot(self, file_path):
        """
        Author: Ren Biyao
        Description: CP for 1726-GE case
                     max data rate as indicated by UE capability is not exceeded in any slot
        :param file_path:
        :return:
        """
        max_tbsize = 0
        self.reassign_dlFdSchedData_column_number(file_path=file_path)
        rntis = self.get_rntis(file_path=file_path, direction='dl')
        for rnti in rntis:
            fdSchedData_event = self.get_fdSchedData_event(file_path=file_path, rnti=rnti, direction='dl')
            list_tbsize = check_csv_log.get_column_from_matrix(
                matrix=fdSchedData_event,
                column_nubmer=self.INDEX_dlFdSchedData_tbsize)
            list_maxdatavolumedl = check_csv_log.get_unique_values_in_column(
                matrix=fdSchedData_event,
                column_number=self.INDEX_dlFdSchedData_maxdatavolumedl
            )
        for cur_tbsize in list_tbsize:
            cur_tbsize = int(cur_tbsize)
            if max_tbsize <= cur_tbsize:
                max_tbsize = cur_tbsize
        maxdatavolumedl = int(list_maxdatavolumedl[0])
        if max_tbsize <= maxdatavolumedl:
            print("Verify dl max data rate indicated_by ue capability not exceed in any slot--pass!")
        else:
            raise Exception("Act max tbsize is {}, maxdatavolumedl is {}".format(max_tbsize, maxdatavolumedl))

    def verify_dl_adaption_of_scheduled_cell_number(self, file_path, expect_scheduled_scell_num=8):
        self.reassign_dlFdSchedData_column_number(file_path=file_path)
        rntis = self.get_rntis(file_path=file_path, direction='dl')
        for rnti in rntis:

            list_scheduled_cell_number = []
            fdSchedData_event = self.get_fdSchedData_event(file_path=file_path, rnti=rnti, direction='dl')
            list_sfn = check_csv_log.get_column_from_matrix(
                matrix=fdSchedData_event,
                column_nubmer=self.INDEX_dlFdSchedData_sfn)
            total_len_to_check = len(fdSchedData_event)-1

            for i in range(0, total_len_to_check):
                count_scheduled_cell_number = 1
                cur_sfn = int(fdSchedData_event[i][1][self.INDEX_dlFdSchedData_sfn - 1])
                next_sfn = int(fdSchedData_event[i+1][1][self.INDEX_dlFdSchedData_sfn - 1])
                cur_slot = int(fdSchedData_event[i][1][self.INDEX_dlFdSchedData_slot - 1])
                next_slot = int(fdSchedData_event[i+1][1][self.INDEX_dlFdSchedData_slot - 1])
                if cur_sfn == next_sfn and cur_slot != next_slot:
                    count_scheduled_cell_number = count_scheduled_cell_number + 1
                    list_scheduled_cell_number.append(count_scheduled_cell_number)
                else:
                    count_scheduled_cell_number = 1
                    list_scheduled_cell_number.append(count_scheduled_cell_number)
            if expect_scheduled_scell_num in list_scheduled_cell_number:
                print("Verify dl adaption of scheduled cell number--pass!")
            else:
                raise Exception("Verify dl adaption of scheduled cell number--fail!")
