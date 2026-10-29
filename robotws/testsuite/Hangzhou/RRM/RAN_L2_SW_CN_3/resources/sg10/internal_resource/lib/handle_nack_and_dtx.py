# -*- coding: UTF-8 -*-

import csv
import os
import sys
import string
import logging as log
import math

cared_title = ['sfn',
               'slot',
               'rnti',
               'ulHarqRxData.crcResult',
               'ulFdSchedData.txNumber',
               'ulFdSchedData.ulHarqProcessIndex',
               'ulHarqRxData.dtx',
               'ulFdSchedData.numOfPrb',
               'ulFdSchedData.rrmUlUsedMcs',
               'ulFdSchedData.adaptRetxStatus',
               'ulFdSchedData.PRBCandRetx',
               'ulFdSchedData.PRBMaxCodeRateRetx',
               'ulFdSchedData.PRBMinRetx',
               'ulFdSchedData.tbSize',
               'ulFdSchedData.numOfLayers',
               'ulFdSchedData.rePerPrbReTx']


class handle_nack_and_dtx(object):
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self, sfn=0, slot=0, rnti=0, ulHarqProcessIndex=0,
                 prb_ini=0, mcs_ini=0, max_retrans_num=4, PRBCandRetx=0,
                 PRBMinRetx=0, tbs_ini=0, Num=1):
        self.sfn = sfn
        self.slot = slot
        self.rnti = rnti
        self.ulHarqProcessIndex = ulHarqProcessIndex
        self.prb_ini = prb_ini
        self.mcs_ini = mcs_ini
        self.max_retrans_num = max_retrans_num
        self.PRBCandRetx = PRBCandRetx
        self.PRBMinRetx = PRBMinRetx
        self.tbs_ini = tbs_ini
        self.Num = Num

    def _find_ttitrace(self, log_path, tag):
        self.fpath = []
        list_file = os.listdir(log_path)
        for index, log in enumerate(list_file):
            if log.endswith("ul.csv") and tag in log:
                target_path = [log_path, log]
                path = '/'.join(target_path)
                self.fpath.append(path)

    def _read_csv_as_dict_list(self, t_path, tag):
        self._find_ttitrace(t_path, tag)
        self.value_dict_list = []
        csv_list = []
        print('ttitrace log full path:{}'.format(self.fpath[0]))
        with open(self.fpath[0], 'r') as csvfile:
            csvreader = csv.reader(csvfile)
            for c in csvreader:
                csv_list.append(c)
        pos_list = []
        for r in range(len(csv_list)):
            row = csv_list[r]
            dline = {}
            if cared_title[0] in row:
                for ca in cared_title:
                    pos_list.append(row.index(ca))
            else:
                for pos in range(len(pos_list)):
                    dline[cared_title[pos]] = row[pos_list[pos]]
                dline['Num'] = r
                self.value_dict_list.append(dline)
        l_list = len(self.value_dict_list)
        sfn_list = []
        for sl_num in range(l_list - 1, 0, -1):
            sfn_list.append(self.value_dict_list[sl_num]['sfn'])
            sfn_num = len(list(set(sfn_list)))
            if sfn_num == 3:
                del self.value_dict_list[sl_num:l_list]
        # print (self.value_dict_list)

    def check_nack_algorithm(
            self, t_path, tag, modulation, targetPct_ul, minPct_ul, codeRate):
        self._read_csv_as_dict_list(t_path, tag)
        df_init_trans = []
        df_not_retrans = []
        for df1 in self.value_dict_list:
            if df1['ulFdSchedData.txNumber']:
                if (df1['ulHarqRxData.crcResult'] == 'NOK') and (
                    int(eval(df1['ulFdSchedData.txNumber'])) == 1) and (
                        df1['ulHarqRxData.dtx'] == 'NON_DTX'):
                    df_init_trans.append(df1)
        print('ini tran NOK and NON_DTX number is {}'.format(len(df_init_trans)))
        title = ''
        all_title = ['Num'] + cared_title
        for n in all_title:
            title += '{}\t'.format(n[-6:])
        # log.info(title)
        content = ''
        for v in df_init_trans:
            for t in all_title:
                content += '{}\t'.format(v[t])
            content += '\r\n'
        # log.info(content)
        for df2 in self.value_dict_list:
            if df2['ulFdSchedData.txNumber']:
                if (df2['ulHarqRxData.crcResult'] == 'OK') and (
                        int(eval(df2['ulFdSchedData.txNumber'])) == 1):
                    df_not_retrans.append(df2)
        # print (df_not_retrans)
        for y_line in df_not_retrans:
            sfn_not_re = int(y_line['sfn'])
            sfn_not_re = int(y_line['slot'])
            mcs_not_re = int(eval(y_line['ulFdSchedData.rrmUlUsedMcs']))
            PRBCandRetx_not_re = int(eval(y_line['ulFdSchedData.PRBCandRetx']))
            PRBMaxCodeRateRetx_not_re = int(eval(
                y_line['ulFdSchedData.PRBMaxCodeRateRetx']))
            PRBMinRetx_not_re = eval(y_line['ulFdSchedData.PRBMinRetx'])
            if PRBCandRetx_not_re == 0 and PRBMaxCodeRateRetx_not_re == 0 and PRBMinRetx_not_re == 0:
                pass
            else:
                raise Exception(
                    'ini trans PRBCandRetx and PRBMaxCodeRateRetx and  PRBMinRetx need equal to 0')
            if mcs_not_re not in self.reserved_mcs_num:
                pass
            else:
                raise Exception(
                    'ini trans is ok, reserved mcs will not been used')
        for i_line in df_init_trans:
            self.sfn = int(i_line['sfn'])
            self.slot = int(i_line['slot'])
            self.rnti = int(i_line['rnti'])
            self.Num = int(i_line['Num'])
            self.ulHarqProcessIndex = i_line['ulFdSchedData.ulHarqProcessIndex']
            if i_line['ulFdSchedData.numOfPrb']:
                self.tbs_ini = int(eval(i_line['ulFdSchedData.tbSize']))
                self.prb_ini = int(eval(i_line['ulFdSchedData.numOfPrb']))
                self.mcs_ini = int(eval(i_line['ulFdSchedData.rrmUlUsedMcs']))
                self.PRBCandRetx = math.ceil(self.prb_ini * targetPct_ul)
                self.PRBMinRetx = math.ceil(self.prb_ini * minPct_ul)
            print("ini trans is on sfn{} slot{}, UE{} prb{}".format(
                self.sfn, self.slot, self.rnti, self.prb_ini))
            n = 1
            stop_flag = False
            retrans_num, stop_flag = self._retrans(n, codeRate)
            while not stop_flag and retrans_num <= self.max_retrans_num:
                print('repeat num is: {}'.format(retrans_num))
                retrans_num, stop_flag = self._retrans(retrans_num, codeRate)
            # print (retrans_num,stop_flag)

    def _retrans(self, n, codeRate):
        df_retrans = []
        for df1 in self.value_dict_list:
            try:
                int(df1['sfn'])
            except Exception as err:
                continue
            if df1['ulFdSchedData.txNumber']:
                if (0 <= int(df1['sfn']) - int(self.sfn) <= n) and (int(df1['rnti']) == self.rnti) and (
                        df1['ulFdSchedData.ulHarqProcessIndex'] == self.ulHarqProcessIndex) and (
                        int(eval(df1['ulFdSchedData.txNumber'])) > 1 and df1['Num'] > self.Num):
                    df_retrans.append(df1)
        # print(df_retrans)
        tx = []
        if df_retrans and n < self.max_retrans_num:
            for item in df_retrans:
                tx.append(int(eval(item['ulFdSchedData.txNumber'])))
                tx_num = tx.count(2)
            stop_flag = False
            if tx_num == 1:
                for j_line in df_retrans:
                    # print (j_line)
                    sfn_re = int(j_line['sfn'])
                    slot_re = int(j_line['slot'])
                    rnti_re = j_line['rnti']
                    prb_re = int(eval(j_line['ulFdSchedData.numOfPrb']))
                    mcs_re = int(eval(j_line['ulFdSchedData.rrmUlUsedMcs']))
                    adaptRetxStatus = j_line['ulFdSchedData.adaptRetxStatus']
                    PRBCandRetx_re = int(
                        eval(j_line['ulFdSchedData.PRBCandRetx']))
                    PRBMinRetx_re = int(
                        eval(j_line['ulFdSchedData.PRBMinRetx']))
                    PRBMaxCodeRateRetx_re = int(
                        eval(j_line['ulFdSchedData.PRBMaxCodeRateRetx']))
                    numOfLayers = int(j_line['ulFdSchedData.numOfLayers'][-1])
                    rePerPrbReTx = int(
                        eval(j_line['ulFdSchedData.rePerPrbReTx']))
                    Kcb = 8448
                    if self.tbs_ini > 3824:
                        CRC = 24
                    else:
                        CRC = 16
                    B = self.tbs_ini + CRC
                    if B <= Kcb:
                        total_CRC = CRC
                    else:
                        C = math.ceil((self.tbs_ini + CRC) / (Kcb - CRC))
                        total_CRC = CRC + C * CRC
                    index = -1
                    for i, x in self.dict_qm.values():
                        index += 1
                        if mcs_re in x or mcs_re in i:
                            qm = list(self.dict_qm.keys())[index]
                    # print('total_CRC is {}'.format(total_CRC))
                    if rePerPrbReTx != 0:
                        PRBMaxCodeRateRetx_cal = math.ceil(
                            (self.tbs_ini + total_CRC) / (codeRate * qm * numOfLayers * rePerPrbReTx))
                    if j_line['ulHarqRxData.crcResult'] == 'OK':
                        stop_flag = True
                        if adaptRetxStatus != 'APPLY':
                            self.err_list.append(
                                'retrans OK but adaptRetxStatus is not APPLY ')
                        if prb_re < self.prb_ini and mcs_re in self.reserved_mcs_num and \
                                PRBCandRetx_re == self.PRBCandRetx and PRBMinRetx_re == self.PRBMinRetx \
                                and PRBMaxCodeRateRetx_re == PRBMaxCodeRateRetx_cal:
                            break
                        elif prb_re == self.prb_ini and mcs_re == self.mcs_ini and \
                                PRBCandRetx_re == self.PRBCandRetx and PRBMinRetx_re == self.PRBMinRetx \
                                and PRBMaxCodeRateRetx_re == PRBMaxCodeRateRetx_cal:
                            break
                        else:
                            self.err_list.append(
                                'when adaptRetxStatus is APPLY,check retrans sfn{} slot{} UE{},'
                                'mcs:re-{}/ini-{},prb:re-{}/ini-{},PRBCand:re-{}/cal-{},PRBMin:re-{}/cal-{},'
                                'PRBMaxCodeRate:re-{}/cal-{}'
                                .format(sfn_re, slot_re, rnti_re, mcs_re, self.mcs_ini,
                                        prb_re, self.prb_ini, PRBCandRetx_re, self.PRBCandRetx,
                                        PRBMinRetx_re, self.PRBMinRetx, PRBMaxCodeRateRetx_re, PRBMaxCodeRateRetx_cal))
                    elif j_line['ulHarqRxData.crcResult'] == 'NOK':
                        if prb_re < self.prb_ini and mcs_re in self.reserved_mcs_num and \
                            PRBCandRetx_re == self.PRBCandRetx and PRBMinRetx_re == self.PRBMinRetx \
                                and PRBMaxCodeRateRetx_re == PRBMaxCodeRateRetx_cal:
                            continue
                        elif prb_re == self.prb_ini and mcs_re == self.mcs_ini and \
                                PRBCandRetx_re == self.PRBCandRetx and PRBMinRetx_re == self.PRBMinRetx \
                                and PRBMaxCodeRateRetx_re == PRBMaxCodeRateRetx_cal:
                            continue
                        else:
                            self.err_list.append(
                                'when retran is NOK,check retrans sfn{} slot{} UE{},'
                                'mcs:re-{}/ini-{},prb:re-{}/ini-{},PRBCand:re-{}/cal-{},PRBMin:re-{}/cal-{},'
                                'PRBMaxCodeRate:re-{}/cal-{}'
                                .format(sfn_re, slot_re, rnti_re, mcs_re, self.mcs_ini, prb_re,
                                        self.prb_ini, PRBCandRetx_re, self.PRBCandRetx,
                                        PRBMinRetx_re, self.PRBMinRetx, PRBMaxCodeRateRetx_re, PRBMaxCodeRateRetx_cal))
                    else:
                        self.err_list.append('Please check the ttitrace crcResult is correct,'
                                             'retrans sfn{} slot{} UE{} mcs{} or prb{} !'.format(
                                                 sfn_re, slot_re, rnti_re, mcs_re, prb_re))
            else:
                stop_flag = True
        elif not df_retrans and n < self.max_retrans_num:
            stop_flag = False
        else:
            stop_flag = True
            print("retrans reach max number and each time is NOK,this is normal")
        n = n + 1
        return n, stop_flag

    def check_dtx_algorithm(
            self, t_path, tag, modulation, targetPct_ul, minPct_ul, codeRate):
        self._read_csv_as_dict_list(t_path, tag)
        df_init_trans = []
        for df1 in self.value_dict_list:
            if df1['ulFdSchedData.txNumber']:
                if (int(eval(df1['ulFdSchedData.txNumber'])) == 1) and (
                        df1['ulHarqRxData.dtx'] == 'DTX'):
                    df_init_trans.append(df1)
        for i_line in df_init_trans:
            self.sfn = int(i_line['sfn'])
            self.slot = int(i_line['slot'])
            self.rnti = int(i_line['rnti'])
            self.ulHarqProcessIndex = i_line['ulFdSchedData.ulHarqProcessIndex']
            if i_line['ulFdSchedData.numOfPrb']:
                self.Num = int(i_line['Num'])
                self.tbs_ini = int(eval(i_line['ulFdSchedData.tbSize']))
                self.prb_ini = int(eval(i_line['ulFdSchedData.numOfPrb']))
                self.mcs_ini = int(eval(i_line['ulFdSchedData.rrmUlUsedMcs']))
                self.PRBCandRetx = math.ceil(self.prb_ini * targetPct_ul)
                self.PRBMinRetx = math.ceil(self.prb_ini * minPct_ul)
            print(
                "ini dtx trans is on sfn{} slot{}, UE{} prb{}".format(
                    self.sfn, self.slot, self.rnti, self.prb_ini))
            n = 1
            stop_flag = False
            retrans_num, stop_flag = self._dtx_retrans(n, codeRate)
            while not stop_flag and retrans_num <= self.max_retrans_num:
                print('repeat num is: {}'.format(retrans_num))
                retrans_num, stop_flag = self._dtx_retrans(
                    retrans_num, codeRate)
        df_not_first_trans_dtx = []
        for df2 in self.value_dict_list:
            if df2['ulFdSchedData.txNumber']:
                if (int(eval(df2['ulFdSchedData.txNumber'])) > 1) and (
                        df2['ulHarqRxData.dtx'] == 'DTX'):
                    df_not_first_trans_dtx.append(df2)
        for x_line in df_not_first_trans_dtx:
            self.sfn = int(x_line['sfn'])
            self.slot = int(x_line['slot'])
            self.rnti = int(x_line['rnti'])
            self.ulHarqProcessIndex = x_line['ulFdSchedData.ulHarqProcessIndex']
            if x_line['ulFdSchedData.numOfPrb']:
                self.prb_ini = int(eval(x_line['ulFdSchedData.numOfPrb']))
                self.mcs_ini = int(eval(x_line['ulFdSchedData.rrmUlUsedMcs']))
            print(
                "re_dtx trans is on sfn{} slot{}, UE{} prb{}".format(
                    self.sfn, self.slot, self.rnti, self.prb_ini))
            self._judge_for_first_trans(targetPct_ul, minPct_ul, codeRate)

    def _judge_for_first_trans(self, targetPct_ul, minPct_ul, codeRate):
        df_first_trans = []
        for df_fir in self.value_dict_list:
            try:
                int(df_fir['sfn'])
            except Exception as err:
                continue
            for n_fir in range(2):  # 2个帧内找重传是dtx的初传状态，根据log看下是否合理？
                if (-n_fir <= int(df_fir['sfn']) - int(self.sfn) <= 0) and (
                        int(df_fir['rnti']) == self.rnti) and (
                        df_fir['ulFdSchedData.ulHarqProcessIndex'] == self.ulHarqProcessIndex) and (
                        int(eval(df_fir['ulFdSchedData.txNumber'])) == 1):
                    df_first_trans.append(df_fir)
                    if df_first_trans:
                        break
                    elif not df_first_trans and df_fir['Num'] < 21:
                        break
                    else:
                        raise Exception(
                            "can not find sfn{} slot{} ue{} re dtx's ini trans".format(df_fir['sfn'],
                                                                                       df_fir['slot'], df_fir['rnti']))
        # print(df_first_trans)
        if df_first_trans:
            for fir_line in df_first_trans:
                dtx_fir = fir_line['ulHarqRxData.dtx']
                if dtx_fir == 'DTX':
                    break
                else:
                    n = 1
                    stop_flag = False
                    self.sfn = int(fir_line['sfn'])
                    self.slot = int(fir_line['slot'])
                    self.rnti = fir_line['rnti']
                    self.Num = int(fir_line['Num'])
                    self.prb_ini = int(
                        eval(fir_line['ulFdSchedData.numOfPrb']))
                    self.mcs_ini = int(
                        eval(fir_line['ulFdSchedData.rrmUlUsedMcs']))
                    self.tbs_ini = int(eval(fir_line['ulFdSchedData.tbSize']))
                    self.prb_ini = int(
                        eval(fir_line['ulFdSchedData.numOfPrb']))
                    self.PRBMinRetx = math.ceil(self.prb_ini * minPct_ul)
                    self.PRBCandRetx = math.ceil(self.prb_ini * targetPct_ul)
                    retrans_num, stop_flag = self._dtx_not_first_retrans(
                        n, codeRate)
                    while not stop_flag and retrans_num <= self.max_retrans_num:
                        print('repeat num is: {}'.format(retrans_num))
                        retrans_num, stop_flag = self._dtx_not_first_retrans(
                            retrans_num, codeRate)

    def _dtx_not_first_retrans(self, n, codeRate):
        df_retrans = []
        for df1 in self.value_dict_list:
            try:
                int(df1['sfn'])
            except Exception as err:
                continue
            if (0 <= int(df1['sfn']) - int(self.sfn) <= n) and (
                    int(df1['rnti']) == self.rnti) and (
                    df1['ulFdSchedData.ulHarqProcessIndex'] == self.ulHarqProcessIndex) and (
                    int(eval(df1['ulFdSchedData.txNumber'])) > 1 and df1['Num'] > self.Num):
                df_retrans.append(df1)
        # print(df_retrans)
        tx = []
        if df_retrans and n < self.max_retrans_num:
            for item in df_retrans:
                tx.append(int(eval(item['ulFdSchedData.txNumber'])))
                tx_num = tx.count(2)
            stop_flag = False
            if tx_num == 1:
                for j_line in df_retrans:
                    # print(j_line)
                    sfn_re = int(j_line['sfn'])
                    slot_re = int(j_line['slot'])
                    rnti_re = j_line['rnti']
                    prb_re = int(eval(j_line['ulFdSchedData.numOfPrb']))
                    mcs_re = int(eval(j_line['ulFdSchedData.rrmUlUsedMcs']))
                    adaptRetxStatus = j_line['ulFdSchedData.adaptRetxStatus']
                    PRBCandRetx_re = int(
                        eval(j_line['ulFdSchedData.PRBCandRetx']))
                    PRBMinRetx_re = int(
                        eval(j_line['ulFdSchedData.PRBMinRetx']))
                    PRBMaxCodeRateRetx_re = int(
                        eval(j_line['ulFdSchedData.PRBMaxCodeRateRetx']))
                    numOfLayers = int(j_line['ulFdSchedData.numOfLayers'][-1])
                    rePerPrbReTx = int(
                        eval(j_line['ulFdSchedData.rePerPrbReTx']))
                    Kcb = 8448
                    if self.tbs_ini > 3824:
                        CRC = 24
                    else:
                        CRC = 16
                    B = self.tbs_ini + CRC
                    if B <= Kcb:
                        total_CRC = CRC
                    else:
                        C = math.ceil((self.tbs_ini + CRC) / (Kcb - CRC))
                        total_CRC = CRC + C * CRC
                    index = -1
                    for i, x in self.dict_qm.values():
                        index += 1
                        if mcs_re in x or mcs_re in i:
                            qm = list(self.dict_qm.keys())[index]
                    # print('total_CRC is {}'.format(total_CRC))
                    if rePerPrbReTx != 0:
                        PRBMaxCodeRateRetx_cal = math.ceil(
                            (self.tbs_ini + total_CRC) / (codeRate * qm * numOfLayers * rePerPrbReTx))
                    if j_line['ulHarqRxData.crcResult'] == 'OK' and j_line['ulHarqRxData.dtx'] == 'NON_DTX':
                        stop_flag = True
                        if adaptRetxStatus != 'APPLY':
                            self.err_list.append(
                                'retrans ok and NON_DTX but adaptRetxStatus is not APPLY')
                        if prb_re < self.prb_ini and mcs_re in self.reserved_mcs_num  \
                                and PRBCandRetx_re == self.PRBCandRetx and PRBMinRetx_re == self.PRBMinRetx \
                                and PRBMaxCodeRateRetx_re == PRBMaxCodeRateRetx_cal:
                            break
                        elif prb_re == self.prb_ini and mcs_re == self.mcs_ini and  \
                                PRBCandRetx_re == self.PRBCandRetx and PRBMinRetx_re == self.PRBMinRetx \
                                and PRBMaxCodeRateRetx_re == PRBMaxCodeRateRetx_cal:
                            break
                        else:
                            self.err_list.append(
                                'dtx adaptRetxStatus APPLY,'
                                'check retrans sfn{} slot{} UE{},mcs:re-{}/ini-{},prb:re-{}/ini-{},'
                                'PRBCand:re-{}/cal-{},PRBMin:re-{}/cal-{},PRBMaxCodeRate:re-{}/cal-{}'
                                .format(sfn_re, slot_re, rnti_re, mcs_re, self.mcs_ini,
                                        prb_re, self.prb_ini, PRBCandRetx_re, self.PRBCandRetx,
                                        PRBMinRetx_re, self.PRBMinRetx, PRBMaxCodeRateRetx_re, PRBMaxCodeRateRetx_cal))
                    elif j_line['ulHarqRxData.crcResult'] == 'NOK':
                        if prb_re < self.prb_ini and mcs_re in self.reserved_mcs_num  \
                            and PRBCandRetx_re == self.PRBCandRetx and PRBMinRetx_re == self.PRBMinRetx \
                                and PRBMaxCodeRateRetx_re == PRBMaxCodeRateRetx_cal:
                            continue
                        elif prb_re == self.prb_ini and mcs_re == self.mcs_ini  \
                                and PRBCandRetx_re == self.PRBCandRetx and PRBMinRetx_re == self.PRBMinRetx \
                                and PRBMaxCodeRateRetx_re == PRBMaxCodeRateRetx_cal:
                            continue
                        else:
                            self.err_list.append(
                                'not first dtx and retran is NOK,'
                                'check retrans sfn{} slot{} UE{},mcs:re-{}/ini-{},prb:re-{}/ini-{},'
                                'PRBCand:re-{}/cal-{},PRBMin:re-{}/cal-{},PRBMaxCodeRate:re-{}/cal-{}'
                                .format(sfn_re, slot_re, rnti_re, mcs_re, self.mcs_ini, prb_re,
                                        self.prb_ini, PRBCandRetx_re, self.PRBCandRetx, PRBMinRetx_re,
                                        self.PRBMinRetx, PRBMaxCodeRateRetx_re, PRBMaxCodeRateRetx_cal))
                    else:
                        self.err_list.append('Please check the ttitrace crcResult is correct,'
                                             'retrans sfn{} slot{} UE{} mcs{} or prb{} !'.format(
                                                 sfn_re, slot_re, rnti_re, mcs_re, prb_re))
            else:
                stop_flag = True
        elif not df_retrans and n < self.max_retrans_num:
            stop_flag = False
        else:
            stop_flag = True
            print("retrans reach max number and each time is NOK,this is normal")
        n = n + 1
        return n, stop_flag

    def _dtx_retrans(self, n, codeRate):
        df_retrans = []
        for df1 in self.value_dict_list:
            try:
                int(df1['sfn'])
            except Exception as err:
                continue
            if (0 <= int(df1['sfn']) - int(self.sfn) <= n) and (
                    int(df1['rnti']) == self.rnti) and (
                    df1['ulFdSchedData.ulHarqProcessIndex'] == self.ulHarqProcessIndex) and (
                    int(eval(df1['ulFdSchedData.txNumber'])) > 1 and df1['Num'] > self.Num):
                df_retrans.append(df1)
        # print(df_retrans)
        tx = []
        if df_retrans and n < self.max_retrans_num:
            for item in df_retrans:
                tx.append(int(eval(item['ulFdSchedData.txNumber'])))
                tx_num = tx.count(2)
            stop_flag = False
            if tx_num == 1:
                for j_line in df_retrans:
                    # print(j_line)
                    sfn_re = int(j_line['sfn'])
                    slot_re = int(j_line['slot'])
                    rnti_re = j_line['rnti']
                    prb_re = int(eval(j_line['ulFdSchedData.numOfPrb']))
                    mcs_re = int(eval(j_line['ulFdSchedData.rrmUlUsedMcs']))
                    adaptRetxStatus = j_line['ulFdSchedData.adaptRetxStatus']
                    PRBCandRetx_re = int(
                        eval(j_line['ulFdSchedData.PRBCandRetx']))
                    PRBMinRetx_re = int(
                        eval(j_line['ulFdSchedData.PRBMinRetx']))
                    txNumber_re = int(eval(j_line['ulFdSchedData.txNumber']))
                    PRBMaxCodeRateRetx_re = int(
                        eval(j_line['ulFdSchedData.PRBMaxCodeRateRetx']))
                    numOfLayers = int(j_line['ulFdSchedData.numOfLayers'][-1])
                    rePerPrbReTx = int(
                        eval(j_line['ulFdSchedData.rePerPrbReTx']))
                    Kcb = 8448
                    if self.tbs_ini > 3824:
                        CRC = 24
                    else:
                        CRC = 16
                    B = self.tbs_ini + CRC
                    if B <= Kcb:
                        total_CRC = CRC
                    else:
                        C = math.ceil((self.tbs_ini + CRC) / (Kcb - CRC))
                        total_CRC = CRC + C * CRC
                    index = -1
                    for i, x in self.dict_qm.values():
                        index += 1
                        if mcs_re in x or mcs_re in i:
                            qm = list(self.dict_qm.keys())[index]
                    # print('total_CRC is {}'.format(total_CRC))
                    if rePerPrbReTx != 0:
                        PRBMaxCodeRateRetx_cal = math.ceil(
                            (self.tbs_ini + total_CRC) / (codeRate * qm * numOfLayers * rePerPrbReTx))
                    if j_line['ulHarqRxData.dtx'] == 'NON_DTX' and j_line['ulHarqRxData.crcResult'] == 'OK' \
                            and txNumber_re == 2:
                        stop_flag = True
                        if prb_re == self.prb_ini and mcs_re == self.mcs_ini \
                                and PRBCandRetx_re == self.PRBCandRetx and PRBMinRetx_re == self.PRBMinRetx \
                                and PRBMaxCodeRateRetx_re == PRBMaxCodeRateRetx_cal:
                            break
                        elif prb_re == self.prb_ini and mcs_re == self.mcs_ini and PRBCandRetx_re == 0 \
                                and PRBMinRetx_re == 0 and PRBMaxCodeRateRetx_re == 0:
                            break
                        else:
                            self.err_list.append(
                                'ini trans dtx second trans will not adapt reTx,'
                                'check retrans sfn{} slot{} UE{},mcs:re-{}/ini-{},prb:re-{}/ini-{},'
                                'PRBCand:re-{}/cal-{},PRBMin:re-{}/cal-{},PRBMaxCodeRate:re-{}/cal-{}'.format(
                                    sfn_re, slot_re, rnti_re, mcs_re, self.mcs_ini, prb_re, self.prb_ini,
                                    PRBCandRetx_re, self.PRBCandRetx, PRBMinRetx_re, self.PRBMinRetx,
                                    PRBMaxCodeRateRetx_re, PRBMaxCodeRateRetx_cal))
                    elif j_line['ulHarqRxData.crcResult'] == 'NOK' and txNumber_re == 2:
                        # if prb_re == self.prb_ini and mcs_re == self.mcs_ini \
                        #     and PRBCandRetx_re == self.PRBCandRetx and PRBMinRetx_re == self.PRBMinRetx \
                        #         and PRBMaxCodeRateRetx_re == PRBMaxCodeRateRetx_cal:
                        #     continue
                        if prb_re == self.prb_ini and mcs_re == self.mcs_ini and PRBCandRetx_re == 0 \
                                and PRBMinRetx_re == 0 and PRBMaxCodeRateRetx_re == 0:
                            continue
                        else:
                            self.err_list.append(
                                'ini trans dtx,txNumber_re=2 with NOK,'
                                'check retrans sfn{} slot{} UE{},mcs:re-{}/ini-{},prb:re-{}/ini-{},'
                                'PRBCand:re-{}/cal-{},PRBMin:re-{}/cal-{},PRBMaxCodeRate:re-{}/cal-{}'.format(
                                    sfn_re, slot_re, rnti_re, mcs_re, self.mcs_ini, prb_re, self.prb_ini,
                                    PRBCandRetx_re, self.PRBCandRetx, PRBMinRetx_re, self.PRBMinRetx,
                                    PRBMaxCodeRateRetx_re, PRBMaxCodeRateRetx_cal))
                    elif j_line['ulHarqRxData.dtx'] == 'NON_DTX' and j_line['ulHarqRxData.crcResult'] == 'OK' \
                            and txNumber_re > 2:
                        stop_flag = True
                        if prb_re == self.prb_ini and mcs_re == self.mcs_ini \
                                and PRBCandRetx_re == self.PRBCandRetx and PRBMinRetx_re == self.PRBMinRetx \
                                and PRBMaxCodeRateRetx_re == PRBMaxCodeRateRetx_cal:
                            break
                        elif prb_re < self.prb_ini and mcs_re in self.reserved_mcs_num  \
                                and PRBCandRetx_re == self.PRBCandRetx and PRBMinRetx_re == self.PRBMinRetx \
                                and PRBMaxCodeRateRetx_re == PRBMaxCodeRateRetx_cal:
                            break
                        else:
                            self.err_list.append(
                                'ini trans dtx and txNumber_re >2,'
                                'check retrans sfn{} slot{} UE{},mcs:re-{}/ini-{},prb:re-{}/ini-{},'
                                'PRBCand:re-{}/cal{},PRBMin:re-{}/cal-{}'.format(
                                    sfn_re, slot_re, rnti_re, mcs_re, self.mcs_ini, prb_re, self.prb_ini,
                                    PRBCandRetx_re, self.PRBCandRetx, PRBMinRetx_re, self.PRBMinRetx))
                    elif txNumber_re > 2 and adaptRetxStatus == 'APPLY':
                        if prb_re == self.prb_ini and mcs_re == self.mcs_ini and \
                            PRBCandRetx_re == self.PRBCandRetx and PRBMinRetx_re == self.PRBMinRetx \
                                and PRBMaxCodeRateRetx_re == PRBMaxCodeRateRetx_cal:
                            continue
                        elif prb_re < self.prb_ini and mcs_re in self.reserved_mcs_num  \
                                and PRBCandRetx_re == self.PRBCandRetx and PRBMinRetx_re == self.PRBMinRetx \
                                and PRBMaxCodeRateRetx_re == PRBMaxCodeRateRetx_cal:
                            continue
                        else:
                            self.err_list.append(
                                'ini trans dtx and txNumber_re>2 NOK,'
                                'check retrans sfn{} slot{} UE{},mcs:re-{}/ini-{},prb:re-{}/ini-{},'
                                'PRBCand:re-{}/cal-{},PRBMin:re-{}/cal-{},PRBMaxCodeRate:re-{}/cal-{}'.format(
                                    sfn_re, slot_re, rnti_re, mcs_re, self.mcs_ini, prb_re, self.prb_ini,
                                    PRBCandRetx_re, self.PRBCandRetx, PRBMinRetx_re, self.PRBMinRetx,
                                    PRBMaxCodeRateRetx_re, PRBMaxCodeRateRetx_cal))
                    elif txNumber_re > 2 and adaptRetxStatus != 'APPLY':
                        if prb_re == self.prb_ini and mcs_re == self.mcs_ini and \
                                PRBCandRetx_re == 0 and PRBMinRetx_re == 0 and PRBMaxCodeRateRetx_re == 0:
                            continue
                        else:
                            self.err_list.append(
                                'ini trans dtx and txNumber_re>2 NOK and adaptRetxStatus not APPLY,'
                                'check retrans sfn{} slot{} UE{},mcs:re-{}/ini-{},prb:re-{}/ini-{},'
                                'PRBCand:re-{}/cal-{},PRBMin:re-{}/cal-{},PRBMaxCodeRate:re-{}/cal-{}'.format(
                                    sfn_re, slot_re, rnti_re, mcs_re, self.mcs_ini, prb_re,
                                    self.prb_ini, PRBCandRetx_re, self.PRBCandRetx,
                                    PRBMinRetx_re, self.PRBMinRetx,
                                    PRBMaxCodeRateRetx_re, PRBMaxCodeRateRetx_cal))
                    else:
                        self.err_list.append('Please check the ttitrace crcResult is correct,'
                                             'retrans sfn{} slot{} UE{} mcs{} or prb{} !'.format(
                                                 sfn_re, slot_re, rnti_re, mcs_re, prb_re))
            else:
                stop_flag = True
        elif not df_retrans and n < self.max_retrans_num:
            stop_flag = False
        else:
            stop_flag = True
            print("retrans reach max number and each time is NOK,this is normal")
        n = n + 1
        return n, stop_flag

    def check_10659_bler_algorithm(
            self, t_path, tag, modulation, targetPct, minPct, DftSOfdm, codeRate, ulTransPrecodePi2Bpsk):
        codeRate = float(codeRate)
        if ulTransPrecodePi2Bpsk == 'true':
            q = 1
        else:
            q = 2
        dict_qm1 = {2: [range(0, 10), range(29, 30)], 4: [range(
            11, 17), range(30, 31)], 6: [range(18, 29), range(31, 32)]}
        dict_qm2 = {2: [range(0, 5), range(28, 29)], 4: [range(5, 11), range(29, 30)], 6: [
            range(11, 20), range(30, 31)], 8: [range(20, 28), range(31, 32)]}
        dict_qm3 = {q: [range(0, 2), range(28, 29)], 2: [range(2, 10), range(29, 30)], 4: [
            range(10, 17), range(30, 32)], 6: [range(17, 28), range(31, 32)]}
        if modulation == 'false' and DftSOfdm == 'false':
            self.dict_qm = dict_qm1
        if modulation == 'true' and DftSOfdm == 'false':
            self.dict_qm = dict_qm2
        if DftSOfdm == 'true':
            self.dict_qm = dict_qm3
        targetPct_ul = int(targetPct) / 100
        minPct_ul = int(minPct) / 100
        self.err_list = []
        if modulation == 'true' or DftSOfdm == 'true':
            self.reserved_mcs_num = [28, 29, 30, 31]
        else:
            self.reserved_mcs_num = [29, 30, 31]
        print('Act 256qam is {} and reserved mcs is {}'.format(
            modulation, self.reserved_mcs_num))
        self.check_nack_algorithm(
            t_path, tag, modulation, targetPct_ul, minPct_ul, codeRate)
        self.check_dtx_algorithm(
            t_path, tag, modulation, targetPct_ul, minPct_ul, codeRate)
        Result = []
        if len(self.err_list) > 0:
            for item in self.err_list:
                if "crcResult is correct" in item:
                    Result.append(item)
                else:
                    print(item, end='\n')
        err_number = len(self.err_list) - (len(Result))
        if err_number > 0 or len(Result) > 80:
            raise AssertionError(
                'check ttitrace fail,there is {} error but crc {} empty '.format(err_number, len(Result)))
