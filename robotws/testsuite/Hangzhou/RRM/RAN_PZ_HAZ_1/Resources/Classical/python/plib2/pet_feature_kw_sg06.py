#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""
:copyright: Nokia
:author: Liu Amy
:contact: amy.c.liu@nokia-sbell.com
:maintainer: amy.c.liu@nokia-sbell.com
"""

import logging
import os
import sys
import re
import csv
from collections import Counter
if 'petbase' not in sys.modules:
    import petbase

gv = sys.modules['petbase'].gv
logger = gv.logger
kw = gv.kw
gv.smf = None
columns = [
            'type', 'sfn', 'slot', 'rnti', 'physCellId', 'numOfPrb',
            'startPrb', 'rat0Bitmap', 'ackNack', 'txNumber', 'dciFormat',
            'dlHarqProcessIndex', 'numOfLayers', 'rrmDlUsedMcs',
            'numOf5qi1Prb', 'rrmInstCqi', 'rrmAvgCqi',
            'rrmDeltaCqi', 'ueBwpId', 'cellBwpId']


class pet_anaysis_tti_sg06(object):

    def __init__(self):
        pass

    def load_tti_data(self, in_file_name):
        with open(in_file_name, 'r') as in_file:
            csv_reader = csv.DictReader(in_file)
            csv_data = [row for row in csv_reader if row['type'] ==
                        'dlFdSchedData']
        return csv_data

    def load_tti_data_2(self, in_file_name):
        with open(in_file_name, 'r') as in_file:
            csv_reader = csv.DictReader(in_file)
            csv_data = [row for row in csv_reader if row['type'] in
                        ['ulFdSchedData', 'csiSrReportData']]
        return csv_data

    def tti_data_filter(self, tti_data, columns):
        for row in tti_data:
            yield dict((k, row[k]) for k in columns)

    def checkConsective(self, alist):
        sorted_list = sorted(alist)
        range_list = list(range(min(alist), max(alist) + 1))
        logging.info(sorted_list, range_list)
        if sorted_list == range_list:
            return True
        else:
            return False

    def veri_bitmap(self, data_item, rat):
        slot_num = 10 if rat == 'FDD' else 20
        sfn = int(data_item['sfn'])
        slot = int(data_item['slot'])
        pci = int(data_item['physCellId'])
        startprb = int(data_item['startPrb'])
        numofprb = int(data_item['numOfPrb'])
        txnumber = int(data_item['txNumber'])
        used_mcs = int(data_item['rrmDlUsedMcs'])
        cell_bwpid = int(data_item['cellBwpId'])
        bandwidth = '15MHz' if pci == 162 else '20MHz'
        rbg_order_list = []
        if bandwidth == '5MHz':
            prb_num = 2
            bwp_width = 25
        elif bandwidth == '10MHz':
            prb_num = 4
            bwp_width = 52
        elif bandwidth == '15MHz':
            prb_num = 8
            bwp_width = 79
        elif bandwidth == '20MHz':
            prb_num = 8
            bwp_width = 106
        else:
            raise Exception('Bandwidth {} input is error! \
                Application terminated!'.format(bandwidth))
        rbg_num = bwp_width // prb_num
        if (((bwp_width == 25) and (rat == 'FDD')) or
                ((bwp_width == 51) and (rat == 'TDD'))):
            primeNumber = 991
        else:
            primeNumber = 997

        for rbg_id in range(rbg_num):
            order_id = 1 + (int(sfn) * slot_num + int(slot) + 1 + int(pci)
                            + rbg_id) * primeNumber % rbg_num
            rbg_order_list.append(order_id)

        if bwp_width % prb_num != 0:
            rbg_num = rbg_num + 1
            rbg_order_list.append(rbg_num)

        data_item['rat0Bitmap'] = bin(int(data_item['rat0Bitmap']))[2:]
        rat0bitmap = data_item['rat0Bitmap'].zfill(rbg_num)
        bitmap_dict = dict(enumerate(rat0bitmap))
        # ==============TTITrace Verification==============
        # logging.info(data_item)
        # step0: verify special case, such as crnti=65535,
        # i.e. RBG allocate to SSB
        if (int(data_item['rnti']) == 65535 or (cell_bwpid != 1) or
                (data_item['dciFormat'] != 'DL_11')):
            return True
        # step1: verify startprb
        index_1 = rat0bitmap.index('1') if '1' in rat0bitmap else -1
        startprb_index = startprb // prb_num
        if index_1 != startprb_index:
            logging.info(data_item)
            logging.info(index_1, startprb_index)
            logging.error('step1 failed!')
            return False
        # step2: verify numofprb
        used_rbg_num_bitmap = Counter(rat0bitmap)['1']
        if numofprb % prb_num == 0:
            used_rbg_num_prb = numofprb // prb_num
        else:
            used_rbg_num_prb = numofprb // prb_num + 1
        if used_rbg_num_bitmap != used_rbg_num_prb:
            logging.info(data_item)
            logging.info(used_rbg_num_bitmap, used_rbg_num_prb)
            logging.error('step2 failed!')
            return False
        # step3: check retransmission case when last RBG used
        if rat0bitmap[-1] == '1':
            if (txnumber > 1) or (used_mcs > 28):
                return True
        # step4: verify if the assigned RGB is continuous ----------
        bitmap_key_used = [i for i in bitmap_dict if bitmap_dict[i] == '1']
        used_rbg_list = [rbg_order_list[i] for i in bitmap_key_used]
        # slot0 - SSB, slot1 - CSI-RS for tracking
        if (slot != 0) and (slot != 1):
            if not self.checkConsective(used_rbg_list):
                logging.debug(sfn, slot, rbg_order_list, bitmap_dict, startprb,
                              numofprb, used_rbg_list, '\n')
                return False

        return True

    def veri_bitmap2(self, data_item, rat):
        slot_num = 10 if rat == 'FDD' else 20
        sfn = int(data_item['sfn'])
        slot = int(data_item['slot'])
        pci = int(data_item['physCellId'])
        startprb = int(data_item['startPrb'])
        numofprb = int(data_item['numOfPrb'])
        txnumber = int(data_item['txNumber'])
        used_mcs = int(data_item['rrmDlUsedMcs'])
        cell_bwpid = int(data_item['cellBwpId'])
        bandwidth = '15MHz' if pci == 162 else '20MHz'
        rbg_order_list = []

        bwp_width = 106
        prb_num = 8

        bwp_width_lc = 79
        prb_num_lc = 8

        rbg_num = bwp_width // prb_num
        if (((bwp_width == 25) and (rat == 'FDD')) or
                ((bwp_width == 51) and (rat == 'TDD'))):
            primeNumber = 991
        else:
            primeNumber = 997

        for rbg_id in range(rbg_num):
            order_id = 1 + (int(sfn) * slot_num + int(slot) + 1 + int(pci)
                            + rbg_id) * primeNumber % rbg_num
            rbg_order_list.append(order_id)

        if bwp_width % prb_num != 0:
            rbg_num = rbg_num + 1
            rbg_order_list.append(rbg_num)

        data_item['rat0Bitmap'] = bin(int(data_item['rat0Bitmap']))[2:]
        rat0bitmap = data_item['rat0Bitmap'].zfill(rbg_num)
        bitmap_dict = dict(enumerate(rat0bitmap))
        # ==============TTITrace Verification==============
        # logging.info(data_item)
        # step0: verify special case, such as crnti=65535,
        # i.e. RBG allocate to SSB
        if (int(data_item['rnti']) == 65535 or (cell_bwpid != 2) or
                (data_item['dciFormat'] != 'DL_11')):
            return True
        # step1: verify startprb
        index_1 = rat0bitmap.index('1') if '1' in rat0bitmap else -1
        startprb_index = startprb // prb_num + 4  # LC
        if index_1 != startprb_index:
            logging.info(data_item)
            logging.info(index_1, startprb_index)
            logging.error('step1 failed!')
            return False
        # step2: verify numofprb
        used_rbg_num_bitmap = Counter(rat0bitmap)['1']
        if numofprb % prb_num == 0:
            used_rbg_num_prb = numofprb // prb_num
        else:
            used_rbg_num_prb = numofprb // prb_num + 1
        if ((used_rbg_num_prb == (bwp_width_lc // prb_num_lc)) or
                (used_rbg_num_prb == (bwp_width_lc // prb_num_lc + 1))):
            logging.info('LC UE used all or all-1 LC PRB')
            return True  # LC UE used all or all-1 LC PRB
        if used_rbg_num_bitmap != used_rbg_num_prb:
            logging.info(data_item)
            logging.info(used_rbg_num_bitmap, used_rbg_num_prb)
            logging.error('step2 failed!')
            return False
        # step3: check retransmission case when last RBG used
        if rat0bitmap[-1] == '1':
            if (txnumber > 1) or (used_mcs > 28):
                return True
        # step4: verify if the assigned RGB is continuous ----------
        bitmap_key_used = [i for i in bitmap_dict if bitmap_dict[i] == '1']
        if len(bitmap_key_used) == 1:
            return True
        # slot0 - SSB, slot1 - CSI-RS for tracking
        if (slot != 0) and (slot != 1):
            if self.checkConsective(bitmap_key_used):
                logging.debug(sfn, slot, rbg_order_list, bitmap_dict, startprb,
                              numofprb, bitmap_key_used, '\n')
                return False

        return True

    def veri_reportType(self, data_item):
        if 'reportType' in data_item:
            if data_item['reportType'] == 'APERIODIC_CSI':
                logging.info('dlul tti file [sfn, slot, reportType] is: {}, {}, {}'.format(
                    data_item['sfn'], data_item['slot'], data_item['reportType']))
                return False
        return True

    def veri_reportType2(self, data_item, sfn_a, slot_a):
        if 'reportType' in data_item:
            if data_item['sfn'] == sfn_a and data_item['slot'] == slot_a:
                logging.info('dlul tti file 2 [sfn, slot, rnti, csRnti, reportType] is: {}, {}, {}, {}, {}'.format(
                    data_item['sfn'], data_item['slot'], data_item['rnti'], data_item['csRnti'],
                    data_item['reportType']))
                if data_item['rnti'] == data_item['csRnti']:
                    return True
                else:
                    return False
        return True


class pet_feature_kw_sg06(object):

    def unzip_tti(self, work_dire):
        import zipfile
        zip_filename = [x for x in os.listdir(work_dire) if
                        x.endswith('.zip')][0]
        ttilog_filename = os.path.join(work_dire, zip_filename)
        logging.info('tti zip file: {}'.format(ttilog_filename))
        zf = zipfile.ZipFile(ttilog_filename)
        zf.extractall(work_dire)
        logging.info('tti log file: {}'.format(zf.namelist()))
        dl_tti_file = [filename for filename in zf.namelist() if '.dl__all.csv' in filename][0]
        dlul_tti_file = [filename for filename in zf.namelist() if '.dlAndUl__all.csv' in filename][0]
        ul_tti_file = [filename for filename in zf.namelist() if '.ul__all.csv' in filename][0]
        dl_tti_file = os.path.join(work_dire, dl_tti_file)
        dlul_tti_file = os.path.join(work_dire, dlul_tti_file)
        ul_tti_file = os.path.join(work_dire, ul_tti_file)
        logging.info('dl tti file: {}'.format(dl_tti_file))
        logging.info('dl ul tti file: {}'.format(dlul_tti_file))
        logging.info('ul tti file: {}'.format(ul_tti_file))
        self.dl_tti_file = dl_tti_file
        self.dlul_tti_file = dlul_tti_file
        self.ul_tti_file = ul_tti_file
        return dl_tti_file

    def unzip_and_check_ttitrace_for_CB009426(self, work_dire):
        dl_tti_file = self.unzip_tti(work_dire)
        tti = pet_anaysis_tti_sg06()
        csv_data = tti.load_tti_data(dl_tti_file)
        verdict = []
        for row in tti.tti_data_filter(csv_data, columns):
            if tti.veri_bitmap(row, 'FDD'):
                verdict.append(1)
            else:
                verdict.append(0)
        rate = sum(verdict)/len(verdict)
        logging.info('rate is: {}'.format(rate))
        if rate < 1.0:
            raise Exception('Test Case CB009426 Check Tti failed!')
        else:
            logging.info('Test Case CB009426 Check Tti Passed!')

    def unzip_and_check_ttitrace_for_CB009426_case8_case10(self, work_dire):
        dl_tti_file = self.unzip_tti(work_dire)
        tti = pet_anaysis_tti_sg06()
        csv_data = tti.load_tti_data(dl_tti_file)
        verdict = []
        for row in tti.tti_data_filter(csv_data, columns):
            if tti.veri_bitmap2(row, 'FDD'):
                verdict.append(1)
            else:
                verdict.append(0)
        rate = sum(verdict)/len(verdict)
        logging.info('rate is: {}'.format(rate))
        if rate < 0.999:
            raise Exception('Test Case CB009426 Check Tti failed!')
        else:
            logging.info('Test Case CB009426 Check Tti Passed!')

    def unzip_and_check_ttitrace_for_CB008124_D01(self, work_dire):
        self.unzip_tti(work_dire)
        tti = pet_anaysis_tti_sg06()
        csv_data = tti.load_tti_data_2(self.dlul_tti_file)
        logging.info('Test Case CB009426 Check Tti file is {}!'.format(self.dlul_tti_file))
        columns = ['sfn', 'slot', 'rnti', 'csRnti', 'reportType']
        flag = False
        flag_a = False
        for row in tti.tti_data_filter(csv_data, columns):
            if tti.veri_reportType(row) is False:
                sfn_a = row['sfn']
                slot_a = row['slot']
                flag = True
                flag_a = True
                logging.info('Test Case CB008124 find Tti reportType is "APERIODIC_CSI"!')
            if flag and row['reportType'] != 'APERIODIC_CSI':
                if tti.veri_reportType2(row, sfn_a, slot_a) is False:
                    raise Exception('Test Case CB008124 Check Tti failed!')
                else:
                    logging.info('Test Case CB008124 has check APERIODIC_CSI first time!')
                    flag = False
        if flag_a is False:
            logging.info('Test Case CB008124 not find Tti reportType is "APERIODIC_CSI"!')
        logging.info('Test Case CB008124 Check Tti Passed!')

    def unzip_biplog(self, work_dire):
        import zipfile
        zip_filename = [x for x in os.listdir(work_dire) if
                        x.endswith('.zip')][0]
        ttilog_filename = os.path.join(work_dire, zip_filename)
        logging.info('bip zip file: {}'.format(ttilog_filename))
        zf = zipfile.ZipFile(ttilog_filename)
        zf.extractall(work_dire)
        logging.info('bip log file: {}'.format(zf.namelist()))
        biplog = [filename for filename in zf.namelist() if '.pcap'
                  in filename][0]
        biplog = os.path.join(work_dire, biplog)
        logging.info('bip log file: {}'.format(biplog))
        return biplog

    def check_biplog_by_tshark(self, pcapfile='', filter='', keyword=''):
        filter_str = '-Y "{}"'.format(filter) if filter else ''
        # perference_str = '-o {}'.format(perference) if perference else ''
        cmd = 'sudo tshark -r {} {} 2>/dev/null'.format(pcapfile, filter_str)
        logging.info(cmd)
        lines = os.popen(cmd).readlines()
        for line in lines:
            logging.debug(line)
        if keyword:
            lines = [x for x in lines if keyword.lower() in x.lower()]
        logging.info('return length: {}'.format(len(lines)))
        return len(lines)

    def unzip_and_check_biplog(self, work_dire, filter, keyword=''):
        biplog = self.unzip_biplog(work_dire)
        count = self.check_biplog_by_tshark(biplog, filter, keyword)
        if count > 0:
            logging.info('Test Case Check BIPlog Passed!')
        else:
            raise Exception('Test Case Check BIPlog failed!')


if __name__ == '__main__':
    p = pet_feature_kw_sg06()
    import urllib3
    logging.basicConfig(format='%(asctime)s [%(levelname)5s] %(message)s',
                        datefmt='%Y-%m-%d %H:%M:%S',
                        level=logging.DEBUG)
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
    work_dire = '/home/ute/tarun/amy/'
    p.unzip_and_check_ttitrace_for_CB008124_D01(work_dire)
