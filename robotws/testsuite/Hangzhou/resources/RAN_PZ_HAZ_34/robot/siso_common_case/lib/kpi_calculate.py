# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
:maintainer: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
"""

import os
from datetime import datetime
from taf.sbts.oam.coam.admin import admin
from taf.rfrl.utilities.robot.general import get_builtin_value

coam = admin()
RA_MSG3_RECEP = 'M55306C06001'
RLF_INITIATED_UE_RACH_FAIL = 'M55116C00009'
RLF_INITIATED_UE_SCG_CHGE_FAIL = 'M55116C00012'
RA_COMP_DED_PRMBL = 'M55306C05001'
X2_SGNB_ADD_REQ_ACK_SENT = 'M55112C00002'
SGNB_NSA_HO_ADMISSION_SUCC = 'M55114C00018'
X2_SN_STATUS_TRANSFER_T = 'M55112C00013'
X2_SN_STATUS_TRANSFER_RECEIVED = 'M55112C00006'
X2_SN_STATUS_TRANSFER_T = 'M55112C00013'
NF1CC_UECTXT_STP_RESPRECD = 'M55113C01002'
NF1CC_UECTXT_STP_REQSENT = 'M55113C01001'


class Counter(object):
    def __init__(self, connection='GNB_OAM', save_path='SAVE LOG DIRECTORY'):
        self.connection = connection
        self.save_path = save_path

    def collect_pm_files(self, file_name='pm_file.zip'):
        save_path = get_builtin_value(self.save_path)
        file_path = os.path.join(save_path, file_name)
        coam.collect_pm_files(target_file_name=file_path,  timeout=120, connection=self.connection)

    def get_counter_info(self):
        pass

    def calculate_success_ratio(self):
        pass


class Counter5013a(Counter):
    def get_counter_info(self):
        counter_ids = RA_MSG3_RECEP
        for i in range(1, 65):
            num = '0' + str(i) if i < 10 else str(i)
            counter_id = 'M55306C000' + num
            counter_ids = counter_ids + ',' + counter_id
        counters_info = coam.get_pm_counters(counter_ids=counter_ids, timeout=120, connection=self.connection)
        return counters_info

    def calculate_success_ratio(self, cell_id=1):
        radio_dict = {}
        counters_info = self.get_counter_info()
        self.collect_pm_files(file_name='pm_rach_counter_5013a.zip')
        RA_MSG3_RECEP_INFO = counters_info['BTS']['CELLS']['NRCELL-' + str(cell_id)]['NRACH'][RA_MSG3_RECEP]
        whole_ra_msg3_recep = sum(RA_MSG3_RECEP_INFO.values())
        whole_ra_ssb = 0
        for key, value in RA_MSG3_RECEP_INFO.items():
            ra_msg3_recep = value
            all_ra_ssb = 0
            for i in range(1, 65):
                num = '0' + str(i) if i < 10 else str(i)
                counter_id = 'M55306C000' + num
                ra_ssb_info = counters_info['BTS']['CELLS']['NRCELL-' + str(cell_id)]['NRACH'][counter_id]
                all_ra_ssb = all_ra_ssb + ra_ssb_info[key]
            whole_ra_ssb = whole_ra_ssb + all_ra_ssb
            if all_ra_ssb > 0:
                success_ratio = 100 * ra_msg3_recep / all_ra_ssb
            else:
                success_ratio = 0
            date_time = datetime.fromtimestamp(int(key))
            radio_dict[str(date_time)] = {'RA_MSG3_RECEP_INFO': value, 'rate': str(success_ratio) + '%'}
        whole_ra_msg3_rate = 100 * whole_ra_msg3_recep / whole_ra_ssb if whole_ra_ssb > 0 else 0
        print('NR_5013A:{}'.format(radio_dict))
        return whole_ra_msg3_rate, whole_ra_msg3_recep, whole_ra_ssb


class Counter5022a(Counter):
    def get_counter_info(self):
        counter_ids = RA_MSG3_RECEP + ',' + RLF_INITIATED_UE_RACH_FAIL + ',' + RLF_INITIATED_UE_SCG_CHGE_FAIL
        counters_info = coam.get_pm_counters(counter_ids=counter_ids, timeout=120, connection=self.connection)
        return counters_info

    def calculate_success_ratio(self, cell_id=1):
        radio_dict = {}
        counters_info = self.get_counter_info()
        self.collect_pm_files(file_name='pm_rach_counter_5022a.zip')
        RA_MSG3_RECEP_INFO = counters_info['BTS']['CELLS']['NRCELL-' + str(cell_id)]['NRACH'][RA_MSG3_RECEP]
        RLF_INITIATED_UE_RACH_FAIL_INFO = (
            counters_info['BTS']['CELLS']['NRCELL-' + str(cell_id)]['NNSAUE'][RLF_INITIATED_UE_RACH_FAIL])
        RLF_INITIATED_UE_SCG_CHGE_FAIL_INFO = (
            counters_info['BTS']['CELLS']['NRCELL-' + str(cell_id)]['NNSAUE'][RLF_INITIATED_UE_SCG_CHGE_FAIL])
        whole_ra_msg3_recep = sum(RA_MSG3_RECEP_INFO.values())
        whole_sum = 0
        for key, value in RA_MSG3_RECEP_INFO.items():
            ra_msg3_recep = value
            all_sum = (RA_MSG3_RECEP_INFO[key] + RLF_INITIATED_UE_RACH_FAIL_INFO[key] +
                       RLF_INITIATED_UE_SCG_CHGE_FAIL_INFO[key])
            whole_sum = whole_sum + all_sum
            if all_sum > 0:
                success_ratio = 100 * ra_msg3_recep / all_sum
            else:
                success_ratio = 0
            date_time = datetime.fromtimestamp(int(key))
            radio_dict[str(date_time)] = {'RA_MSG3_RECEP_INFO': value, 'rate': str(success_ratio) + '%'}
        print('NR_5022A:{}'.format(radio_dict))
        whole_ra_msg3_rate = 100 * whole_ra_msg3_recep / whole_sum if whole_sum > 0 else 0
        return whole_ra_msg3_rate, whole_ra_msg3_recep, whole_sum


class Counter5021a(Counter):
    def get_counter_info(self):
        counter_ids = (RA_MSG3_RECEP + ',' + RA_COMP_DED_PRMBL + ',' + X2_SGNB_ADD_REQ_ACK_SENT +
                       ',' + SGNB_NSA_HO_ADMISSION_SUCC)
        counters_info = coam.get_pm_counters(counter_ids=counter_ids, timeout=120, connection=self.connection)
        return counters_info

    def calculate_success_ratio(self, cell_id=1):
        radio_dict = {}
        counters_info = self.get_counter_info()
        self.collect_pm_files(file_name='pm_rach_counter_5021a.zip')
        RA_MSG3_RECEP_INFO = counters_info['BTS']['CELLS']['NRCELL-' + str(cell_id)]['NRACH'][RA_MSG3_RECEP]
        RA_COMP_DED_PRMBL_INFO = counters_info['BTS']['CELLS']['NRCELL-' + str(cell_id)]['NRACH'][RA_COMP_DED_PRMBL]
        X2_SGNB_ADD_REQ_ACK_SENT_INFO = (
            counters_info['BTS']['CELLS']['NRCELL-' + str(cell_id)]['NX2CC'][X2_SGNB_ADD_REQ_ACK_SENT])
        SGNB_NSA_HO_ADMISSION_SUCC_INFO = (
            counters_info['BTS']['CELLS']['NRCELL-' + str(cell_id)]['RACCU'][SGNB_NSA_HO_ADMISSION_SUCC])
        whole_rach_sum = 0
        whole_x2_sum = 0
        for key, value in RA_MSG3_RECEP_INFO.items():
            rach_sum = RA_MSG3_RECEP_INFO[key] + RA_COMP_DED_PRMBL_INFO[key]
            x2_sum = X2_SGNB_ADD_REQ_ACK_SENT_INFO[key] + SGNB_NSA_HO_ADMISSION_SUCC_INFO[key]
            whole_rach_sum = whole_rach_sum + rach_sum
            whole_x2_sum = whole_x2_sum + x2_sum
            if x2_sum > 0:
                success_ratio = 100 * rach_sum / x2_sum
            else:
                success_ratio = 0
            date_time = datetime.fromtimestamp(int(key))
            radio_dict[str(date_time)] = {'RA_MSG3_RECEP_INFO': value, 'rate': str(success_ratio) + '%'}
        print('NR_5021A:{}'.format(radio_dict))
        whole_rate = 100 * whole_rach_sum / whole_x2_sum if whole_x2_sum > 0 else 0
        return whole_rate, whole_rach_sum, whole_x2_sum


class Counter5006a(Counter):
    def get_counter_info(self):
        counter_ids = X2_SN_STATUS_TRANSFER_T + ',' + X2_SN_STATUS_TRANSFER_RECEIVED
        counters_info = coam.get_pm_counters(counter_ids=counter_ids, timeout=120, connection=self.connection)
        return counters_info

    def calculate_success_ratio(self, cell_id=1):
        radio_dict = {}
        counters_info = self.get_counter_info()
        self.collect_pm_files(file_name='pm_rach_counter_5006a.zip')
        X2_SN_STATUS_TRANSFER_T_INFO = (
            counters_info['BTS']['CELLS']['NRCELL-' + str(cell_id)]['NX2CC'][X2_SN_STATUS_TRANSFER_T])
        X2_SN_STATUS_TRANSFER_RECEIVED_INFO = (
            counters_info['BTS']['CELLS']['NRCELL-' + str(cell_id)]['NX2CC'][X2_SN_STATUS_TRANSFER_RECEIVED])
        whole_x2_sn = sum(X2_SN_STATUS_TRANSFER_T_INFO.values())
        whole_sum = 0
        for key, value in X2_SN_STATUS_TRANSFER_T_INFO.items():
            x2_sn = value
            all_sum = X2_SN_STATUS_TRANSFER_RECEIVED_INFO[key] + X2_SN_STATUS_TRANSFER_T_INFO[key]
            whole_sum = whole_sum + all_sum
            if all_sum > 0:
                success_ratio = 100 * x2_sn / all_sum
            else:
                success_ratio = 0
            date_time = datetime.fromtimestamp(int(key))
            radio_dict[str(date_time)] = {'X2_SN_STATUS_TRANSFER_T': value, 'rate': str(success_ratio) + '%'}
        print('NR_5006A:{}'.format(radio_dict))
        whole_rate = 100 * whole_x2_sn / whole_sum if whole_sum > 0 else 0
        return whole_rate, whole_x2_sn, whole_sum


class Counter5009a(Counter):
    def get_counter_info(self):
        counter_ids = NF1CC_UECTXT_STP_RESPRECD + ',' + NF1CC_UECTXT_STP_REQSENT
        counters_info = coam.get_pm_counters(counter_ids=counter_ids, timeout=120, connection=self.connection)
        return counters_info

    def calculate_success_ratio(self, cell_id=1):
        radio_dict = {}
        counters_info = self.get_counter_info()
        self.collect_pm_files(file_name='pm_rach_counter_5009a.zip')
        NF1CC_UECTXT_STP_RESPRECD_INFO = (
            counters_info['BTS']['CELLS']['NRCELL-' + str(cell_id)]['NF1CC'][NF1CC_UECTXT_STP_RESPRECD])
        NF1CC_UECTXT_STP_REQSENT_INFO = (
            counters_info['BTS']['CELLS']['NRCELL-' + str(cell_id)]['NF1CC'][NF1CC_UECTXT_STP_REQSENT])
        whole_uectxt_resprecd = sum(NF1CC_UECTXT_STP_RESPRECD_INFO.values())
        whole_uectxt_resprecdsent = sum(NF1CC_UECTXT_STP_REQSENT_INFO.values())
        for key, value in NF1CC_UECTXT_STP_RESPRECD_INFO.items():
            if NF1CC_UECTXT_STP_REQSENT_INFO[key] > 0:
                success_ratio = 100 * NF1CC_UECTXT_STP_RESPRECD_INFO[key] / NF1CC_UECTXT_STP_REQSENT_INFO[key]
            else:
                success_ratio = 0
            date_time = datetime.fromtimestamp(int(key))
            radio_dict[str(date_time)] = {'NF1CC_UECTXT_STP_RESPRECD_INFO': value, 'rate': str(success_ratio) + '%'}
        print('NR_5009A:{}'.format(radio_dict))
        whole_rate = 100 * whole_uectxt_resprecd / whole_uectxt_resprecdsent if whole_uectxt_resprecdsent > 0 else 0
        return whole_rate, whole_uectxt_resprecd, whole_uectxt_resprecdsent


def rach_setup_success_ratio(cell_id=1, connection='GNB_OAM'):
    object = Counter5013a(connection=connection)
    pass_radio, numerator, denominator = object.calculate_success_ratio(cell_id=cell_id)
    return pass_radio, numerator, denominator


def rach_setup_success_ratio_2(cell_id=1, connection='GNB_OAM'):
    object = Counter5022a(connection=connection)
    pass_radio, numerator, denominator = object.calculate_success_ratio(cell_id=cell_id)
    return pass_radio, numerator, denominator


def rach_setup_success_ratio_3(cell_id=1, connection='GNB_OAM'):
    object = Counter5021a(connection=connection)
    pass_radio, numerator, denominator = object.calculate_success_ratio(cell_id=cell_id)
    return pass_radio, numerator, denominator


def rach_setup_success_ratio_4(cell_id=1, connection='GNB_OAM'):
    object = Counter5006a(connection=connection)
    pass_radio, numerator, denominator = object.calculate_success_ratio(cell_id=cell_id)
    return pass_radio, numerator, denominator


def rach_setup_success_ratio_5(cell_id=1, connection='GNB_OAM'):
    object = Counter5009a(connection=connection)
    pass_radio, numerator, denominator = object.calculate_success_ratio(cell_id=cell_id)
    return pass_radio, numerator, denominator


# if __name__ == '__main__':
#     try:
#         coam.connect_to(bts_host='10.71.213.100', name='GNB_OAM')
#         success_ratio = rach_setup_success_ratio(cell_id=3, connection='GNB_OAM')
#         print(success_ratio)
#         success_ratio_2 = rach_setup_success_ratio_2(cell_id=3, connection='GNB_OAM')
#         print(success_ratio_2)
#         success_ratio_3 = rach_setup_success_ratio_3(cell_id=3, connection='GNB_OAM')
#         print(success_ratio_3)
#         success_ratio_4 = rach_setup_success_ratio_4(cell_id=3, connection='GNB_OAM')
#         print(success_ratio_4)
#         success_ratio_4 = rach_setup_success_ratio_5(cell_id=3, connection='GNB_OAM')
#         print(success_ratio_4)
#     finally:
#         coam.teardown(connection='GNB_OAM')
