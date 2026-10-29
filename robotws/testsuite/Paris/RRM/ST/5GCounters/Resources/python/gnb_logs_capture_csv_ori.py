"""
        Keywords Purpose:
            Keywords to start, stop and collect gNB_Logs traces

        AUTHOR:
            Yvan Maurin       yvan.maurin@nokia.com

        12/May/2023: start gNB_logs capture
"""

import sys
import os.path
import time
import glob
import math
import csv
import pandas as pd
from datetime import datetime, timedelta
from robot.libraries.BuiltIn import BuiltIn

# sys.path.append('../../../')
# from resources.sg_radio_perf.python.bcolors import bcolors


rf_built_in = BuiltIn()


GNB_LOGS_SCRIPT_DIR = '/home/localuser/Tools/gnb_logs'
GNB_LOGS_TRACE_DIR = '/home/localuser/Tools/gnb_logs'


def _log(message, console=True):
    rf_built_in.log(message=message, console=console)


def start_trace(IP, duration):
    """
    This keyword starts the collection of gnb_logs traces
    :param IP: public IP OAM address of the gNB
    :param duration: duration of the capture in seconds.
    """
    os.chdir(GNB_LOGS_SCRIPT_DIR)
    time.sleep(1)
    cmd = str(GNB_LOGS_SCRIPT_DIR)+'/gnb_logs ' + str(IP) + ' -b ' + str(duration)
    os.system(cmd)


def pcap_collect():
    """
    This keyword starts the collection of gnb_logs traces
    :param IP: public IP OAM address of the gNB
    :param duration: duration of the capture in seconds.
    """
    BIP_Files_List = sorted(glob.glob('*.zip'))
    bipFile = BIP_Files_List[-1]
    cmd = 'unzip ' + str(bipFile)

    os.system(cmd)
    newDir = GNB_LOGS_TRACE_DIR + '/' + bipFile.split('.zip')[0]
    os.system('cd ' + str(newDir))
    PCAP_Files_List = glob.glob(newDir + '/*pcap*')
    return (PCAP_Files_List)


def convert_sinr2level(sinr):
    """
    Convert a sinr as a floating representation with 4 decimals to a level as an integer
    Here is the definition of the level:
        Level1: [SINR <= -8dB]
        Level2: [-8dB < SINR <= -6dB]
        ...
        Level24: [36dB < SINR <= 38dB]
        Level25: [38dB < SINR]
    :param sinr: value of the sinr in floating format
    :return level: value of the level in integer format
    """
    return int(max(min(sinr/2 + 5.9999999, 25.0), 1.0))


def countNumPdschPrb_pd(l1l2_traces, endTime, period):
    numPdschPrbUsed = 0
    interval = period.replace('min', '')
    df = pd.read_csv(l1l2_traces, sep=';')
    df['_ws.col.Time'] = pd.to_datetime(df['_ws.col.Time'])
    dt = datetime.strptime(str(endTime), "%Y%m%d.%H%M%S")
    endTime = dt
    beginTime = dt - timedelta(minutes=int(interval))

    df1 = df.loc[df['_ws.col.Time'] >= beginTime]
    df2 = df1.loc[df1['_ws.col.Time'] < endTime]
    df3 = df2.loc[df2['3gpp.rnti'] != 65535]

    filtered_df = df3[df3['_ws.col.Info'].str.contains('DlData_PdschSendReq')]
    for row in filtered_df.index:
        try:
            value = filtered_df['DlData_PdschGrant.numOfPrb'][row].split(',')
            for i in range(0, len(value)):
                numPdschPrbUsed += int(value[i])
        except Exception as e:
            value = filtered_df['DlData_PdschGrant.numOfPrb'][row]
            numPdschPrbUsed += int(value)

    return (numPdschPrbUsed)


def countNumPdschPrb(l1l2_traces, endTime, period_in_min):
    numPdschPrbUsed = 0
    sfn_value = 65535
    slot_value = 65535

    endTime = datetime.strptime(endTime, "%Y%m%d %H%M%S.%f")
    beginTime = endTime - timedelta(minutes=period_in_min)
    with open(l1l2_traces, newline='') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        for row in reader:
            _ws_col_Time = datetime.strptime(row['_ws.col.Time'], "%Y-%m-%d %H:%M:%S.%f")
            if (beginTime < _ws_col_Time < endTime
               and row['_ws.col.Info'].strip() == 'DlData_PdschSendReq'
               and row['3gpp.rnti'].strip() != '65535'):
                numPdschPrbUsed += (sum(list(map(int, row['DlData_PdschGrant.numOfPrb'].split(',')))))
    return numPdschPrbUsed


def countNumPuschPrb_pd(l1l2_traces, endTime, period):
    numPuschPrbUsed = 0
    interval = period.replace('min', '')
    df = pd.read_csv(l1l2_traces, sep=';')
    df['_ws.col.Time'] = pd.to_datetime(df['_ws.col.Time'])
    dt = datetime.strptime(str(endTime), "%Y%m%d.%H%M%S")
    endTime = dt
    beginTime = dt - timedelta(minutes=int(interval))
    df1 = df.loc[df['_ws.col.Time'] >= beginTime]
    df2 = df1.loc[df1['_ws.col.Time'] < endTime]

    # print(df2.to_markdown())

    filtered_df = df2[df2['_ws.col.Info'].str.contains('UlData_PuschReceiveReq')]
    for row in filtered_df.index:
        try:
            value = filtered_df['UlData_puschReceiveReqGrant_t.numOfPrb'][row].split(',')
            for i in range(0, len(value)):
                numPuschPrbUsed += int(value[i])
        except Exception as e:
            value = filtered_df['UlData_puschReceiveReqGrant_t.numOfPrb'][row]
            numPuschPrbUsed += int(value)

    return (numPuschPrbUsed)


def countNumPuschPrb(l1l2_traces, endTime, period):
    numPuschPrbUsed = 0
    endTime = datetime.strptime(endTime, "%Y-%m-%d %H:%M:%S")
    beginTime = endTime - timedelta(minutes=period_in_min)
    with open(l1l2_traces, newline='') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        for row in reader:
            _ws_col_Time = datetime.strptime(row['_ws.col.Time'], "%Y-%m-%d %H:%M:%S.%f")
            if (beginTime < _ws_col_Time < endTime
               and row['_ws.col.Info'].strip() == 'UlData_PuschReceiveReq'):
                numPuschPrbUsed += (sum(list(map(int, row['UlData_puschReceiveReqGrant_t.numOfPrb'].split(',')))))
    return numPuschPrbUsed


def count_DlDataSlot_pd(l1l2_traces, endTime, period):
    numDlDataSlot = 0
    interval = period.replace('min', '')
    sfn_value = 65535
    slot_value = 65535
    row_index = 1
    df = pd.read_csv(l1l2_traces, sep=';')

    df['_ws.col.Time'] = pd.to_datetime(df['_ws.col.Time'])
    dt = datetime.strptime(str(endTime), "%Y%m%d.%H%M%S")
    endTime = dt
    beginTime = dt - timedelta(minutes=int(interval))

    df1 = df.loc[df['_ws.col.Time'] >= beginTime]
    df2 = df1.loc[df1['_ws.col.Time'] < endTime]
    df3 = df2[df2['3gpp.rnti'] != 65535]
    ssb_df = df3.loc[df3['_ws.col.Info'] == 'DlData_SsBlockSendReq , MIB']
    filtered_df = df3[df3['_ws.col.Info'].str.contains('DlData_PdschSendReq')]

    for row in filtered_df.index:
        if ((sfn_value != filtered_df['3gpp.sfn'][row]) or (slot_value != filtered_df['3gpp.slot'][row])):
            if not (sfn_value in ssb_df['3gpp.sfn'].values and slot_value in ssb_df['3gpp.slot'].values):
                numDlDataSlot += 1
            sfn_value = filtered_df['3gpp.sfn'][row]
            slot_value = filtered_df['3gpp.slot'][row]
    return (numDlDataSlot)


def count_DlDataSlot(l1l2_traces, endTime, period_in_min):
    numDlDataSlot = 0
    sfn_value = '65535'
    slot_value = '65535'

    endTime = datetime.strptime(endTime, "%Y-%m-%d %H:%M:%S")
    beginTime = endTime - timedelta(minutes=period_in_min)
    with open(l1l2_traces, newline='') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        data = [row for row in reader]
        filtered_ssb = list(filter(lambda r: 'DlData_SsBlockSendReq , MIB' == r['_ws.col.Info'].strip(), data))
        filtered_sfn = {r['3gpp.sfn']: r['3gpp.sfn'] for r in filtered_ssb}
        filtered_slot = {r['3gpp.slot']: r['3gpp.sfn'] for r in filtered_ssb}
        for row in data:
            _ws_col_Time = datetime.strptime(row['_ws.col.Time'], "%Y-%m-%d %H:%M:%S.%f")
            if (beginTime < _ws_col_Time < endTime
               and row['3gpp.rnti'].strip() != '65535'
               and row['_ws.col.Info'].strip() == 'DlData_PdschSendReq'
               and (sfn_value != row['3gpp.sfn'] or slot_value != row['3gpp.slot'])):
                if not (sfn_value in filtered_sfn and slot_value in filtered_slot):
                    numDlDataSlot += 1
                sfn_value = row['3gpp.sfn']
                slot_value = row['3gpp.slot']
    return numDlDataSlot


def count_SsbSlotWithPDSCH_pd(l1l2_traces, endTime, period):
    numSsbSlotPdsch = 0
    interval = period.replace('min', '')
    sfn_value = 65535
    slot_value = 65535
    row_index = 1
    df = pd.read_csv(l1l2_traces, sep=';')

    df['_ws.col.Time'] = pd.to_datetime(df['_ws.col.Time'])
    dt = datetime.strptime(str(endTime), "%Y%m%d.%H%M%S")
    endTime = dt
    beginTime = dt - timedelta(minutes=int(interval))

    df1 = df.loc[df['_ws.col.Time'] >= beginTime]
    df2 = df1.loc[df1['_ws.col.Time'] < endTime]
    df3 = df2[df2['3gpp.rnti'] != 65535]
    ssb_df = df3.loc[df3['_ws.col.Info'] == 'DlData_SsBlockSendReq , MIB']
    filtered_df = df3[df3['_ws.col.Info'].str.contains('DlData_PdschSendReq')]

    for row in filtered_df.index:
        # check if new sfn/slot
        if ((sfn_value != filtered_df['3gpp.sfn'][row]) or (slot_value != filtered_df['3gpp.slot'][row])):
            # check if this is an active SSB sfn/slot
            if (sfn_value in ssb_df['3gpp.sfn'].values and slot_value in ssb_df['3gpp.slot'].values):
                numSsbSlotPdsch += 1
            sfn_value = filtered_df['3gpp.sfn'][row]
            slot_value = filtered_df['3gpp.slot'][row]
    return (numSsbSlotPdsch)


def count_SsbSlotWithPDSCH(l1l2_traces, endTime, period_in_min):
    numSsbSlotPdsch = 0
    sfn_value = '65535'
    slot_value = '65535'

    endTime = datetime.strptime(endTime, "%Y-%m-%d %H:%M:%S")
    beginTime = endTime - timedelta(minutes=period_in_min)
    with open(l1l2_traces, newline='') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        data = [row for row in reader]
        filtered_ssb = list(filter(lambda r: 'DlData_SsBlockSendReq , MIB' == r['_ws.col.Info'].strip(), data))
        filtered_sfn = {r['3gpp.sfn']: r['3gpp.sfn'] for r in filtered_ssb}
        filtered_slot = {r['3gpp.slot']: r['3gpp.sfn'] for r in filtered_ssb}
        for row in data:
            _ws_col_Time = datetime.strptime(row['_ws.col.Time'], "%Y-%m-%d %H:%M:%S.%f")
            if (beginTime < _ws_col_Time < endTime
               and row['_ws.col.Info'].strip() == 'DlData_PdschSendReq'
               and row['3gpp.rnti'].strip() != '65535'
               and (sfn_value != row['3gpp.sfn'] or slot_value != row['3gpp.slot'])):
                if (sfn_value in filtered_sfn and slot_value in filtered_slot):
                    numSsbSlotPdsch += 1
                sfn_value = row['3gpp.sfn']
                slot_value = row['3gpp.slot']

    return numSsbSlotPdsch


def count_UlDataSlot_pd(l1l2_traces, endTime, period):
    numUlDataSlot = 0
    interval = period.replace('min', '')
    sfn_value = 65535
    slot_value = 65535
    row_index = 1
    df = pd.read_csv(l1l2_traces, sep=';')

    df['_ws.col.Time'] = pd.to_datetime(df['_ws.col.Time'])
    dt = datetime.strptime(str(endTime), "%Y%m%d.%H%M%S")
    endTime = dt
    beginTime = dt - timedelta(minutes=int(interval))

    df1 = df.loc[df['_ws.col.Time'] >= beginTime]
    df2 = df1.loc[df1['_ws.col.Time'] < endTime]
    df3 = df2[df2['3gpp.rnti'] != 65535]

    filtered_df = df3[df3['_ws.col.Info'].str.contains('UlData_PuschReceiveReq')]
    for row in filtered_df.index:
        # !! prach Slot checked for prachConfigIndex = 93
        # prachSlot=checkPrachSlot('93',filtered_df['3gpp.sfn'][row], filtered_df['3gpp.slot'][row])
        # if (prachSlot == 'False'):
        if (filtered_df['3gpp.sfn'][row] % 2 != 0 or filtered_df['3gpp.slot'][row] != 19):
            # exclude prach slots from counting
            if ((sfn_value != filtered_df['3gpp.sfn'][row]) or (slot_value != filtered_df['3gpp.slot'][row])):
                sfn_value = filtered_df['3gpp.sfn'][row]
                slot_value = filtered_df['3gpp.slot'][row]
                numUlDataSlot += 1
    return (numUlDataSlot)


def count_UlDataSlot(l1l2_traces, endTime, period_in_min):
    numUlDataSlot = 0
    sfn_value = '65535'
    slot_value = '65535'

    endTime = datetime.strptime(endTime, "%Y-%m-%d %H:%M:%S")
    beginTime = endTime - timedelta(minutes=period_in_min)
    with open(l1l2_traces, newline='') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        data = [row for row in reader]
        filtered_ssb = list(filter(lambda r: 'DlData_SsBlockSendReq , MIB' == r['_ws.col.Info'].strip(), data))
        filtered_sfn = {r['3gpp.sfn']: r['3gpp.sfn'] for r in filtered_ssb}
        filtered_slot = {r['3gpp.slot']: r['3gpp.sfn'] for r in filtered_ssb}
        for row in data:
            _ws_col_Time = datetime.strptime(row['_ws.col.Time'], "%Y-%m-%d %H:%M:%S.%f")
            if (beginTime < _ws_col_Time < endTime
               and row['_ws.col.Info'].strip() == 'UlData_PuschReceiveReq'
               and row['3gpp.rnti'].strip() != '65535'
               and (int(row['3gpp.sfn']) % 2 != 0 or row['3gpp.slot'] != '19')
               and (sfn_value != row['3gpp.sfn'] or slot_value != row['3gpp.slot'])):
                numUlDataSlot += 1
                sfn_value = row['3gpp.sfn']
                slot_value = row['3gpp.slot']

    return numUlDataSlot


def count_pdsch_rank2_tx_pd(l1l2_traces, endTime, period):
    cpt_mcs_rank2 = 32 * [0]
    interval = period.replace('min', '')
    df = pd.read_csv(l1l2_traces, sep=';')

    df['_ws.col.Time'] = pd.to_datetime(df['_ws.col.Time'])
    dt = datetime.strptime(str(endTime), "%Y%m%d.%H%M%S")
    endTime = dt
    beginTime = dt - timedelta(minutes=int(interval))

    df1 = df.loc[df['_ws.col.Time'] >= beginTime]
    df2 = df1.loc[df1['_ws.col.Time'] < endTime]
    df3 = df2[df2['3gpp.rnti'] != 65535]
    rank2_df = df3.loc[df3['DlData_PdschGrant.numOfLayers'] == 2]

    for row in rank2_df.index:
        try:
            mcs = rank2_df['DlData_PdschGrant.mcs'][row]
            cpt_mcs_rank2[int(mcs)] += 1
        except Exception as e:
            pass

    return cpt_mcs_rank2


def count_pdsch_rank2_tx(l1l2_traces, endTime, period_in_min):
    cpt_mcs_rank2 = 32 * [0]
    endTime = datetime.strptime(endTime, "%Y-%m-%d %H:%M:%S")
    beginTime = endTime - timedelta(minutes=period_in_min)

    with open(l1l2_traces, newline='') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        data = [row for row in reader]
        for row in data:
            _ws_col_Time = datetime.strptime(row['_ws.col.Time'], "%Y-%m-%d %H:%M:%S.%f")
            if (beginTime < _ws_col_Time < endTime
               and row['DlData_PdschGrant.numOfLayers'].strip() == '2'
               and row['3gpp.rnti'].strip() != '65535'):
                try:
                    cpt_mcs_rank2[int(row['DlData_PdschGrant.mcs'])] += 1
                except Exception as e:
                    pass
    return cpt_mcs_rank2


def count_pucchDtx_pd(l1l2_traces, endTime, period):
    numPucch = {}
    numPucch['F1_non_DTX'] = 0
    numPucch['F1_DTX'] = 0
    numPucch['F3_non_DTX'] = 0
    numPucch['F3_DTX'] = 0

    interval = period.replace('min', '')
    df = pd.read_csv(l1l2_traces, sep=';')
    df['_ws.col.Time'] = pd.to_datetime(df['_ws.col.Time'])
    dt = datetime.strptime(str(endTime), "%Y%m%d.%H%M%S")
    endTime = dt
    beginTime = dt - timedelta(minutes=int(interval))

    df1 = df.loc[df['_ws.col.Time'] >= beginTime]
    df2 = df1.loc[df1['_ws.col.Time'] < endTime]

    filtered_df = df2[df2['_ws.col.Info'].str.contains('UlData_PucchReceiveRespPs')]
    for row in filtered_df.index:
        if filtered_df['UlData_pucchReceiveRespPsPucchResource_t.pucchFormat'][row] == 1:
            if filtered_df['UlData_pucchReceiveRespPsPucchResource_t.dtx'][row] == 1:
                numPucch['F1_DTX'] += 1
            else:
                numPucch['F1_non_DTX'] += 1
        if filtered_df['UlData_pucchReceiveRespPsPucchResource_t.pucchFormat'][row] == 3:
            if filtered_df['UlData_pucchReceiveRespPsPucchResource_t.dtx'][row] == 1:
                numPucch['F3_DTX'] += 1
            else:
                numPucch['F3_non_DTX'] += 1
    return numPucch


def count_pucchDtx(l1l2_traces, endTime, period_in_min):
    numPucch = {}
    numPucch['F1_non_DTX'] = 0
    numPucch['F1_DTX'] = 0
    numPucch['F3_non_DTX'] = 0
    numPucch['F3_DTX'] = 0

    endTime = datetime.strptime(endTime, "%Y-%m-%d %H:%M:%S")
    beginTime = endTime - timedelta(minutes=period_in_min)
    with open(l1l2_traces, newline='') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        data = [row for row in reader]
        for row in data:
            _ws_col_Time = datetime.strptime(row['_ws.col.Time'], "%Y-%m-%d %H:%M:%S.%f")
            if (beginTime < _ws_col_Time < endTime and row['_ws.col.Info'].strip() == 'UlData_PucchReceiveRespPs'):
                if row['UlData_pucchReceiveRespPsPucchResource_t.pucchFormat'] == 1:
                    if row['UlData_pucchReceiveRespPsPucchResource_t.dtx'] == 1:
                        numPucch['F1_DTX'] += 1
                    else:
                        numPucch['F1_non_DTX'] += 1
                elif row['UlData_pucchReceiveRespPsPucchResource_t.pucchFormat'] == 3:
                    if row['UlData_pucchReceiveRespPsPucchResource_t.dtx'] == 1:
                        numPucch['F3_DTX'] += 1
                    else:
                        numPucch['F3_non_DTX'] += 1
    return numPucch


def count_sinr_rank1_pd(l1l2_traces, endTime, period):
    cpt_level_rank1 = 26 * [0]
    interval = period.replace('min', '')
    df = pd.read_csv(l1l2_traces, sep=';')

    df['_ws.col.Time'] = pd.to_datetime(df['_ws.col.Time'])

    dt = datetime.strptime(str(endTime), "%Y%m%d.%H%M%S")
    endTime = dt
    beginTime = dt - timedelta(minutes=int(interval))

    df1 = df.loc[df['_ws.col.Time'] >= beginTime]
    df2 = df1.loc[df1['_ws.col.Time'] < endTime]
    df3 = df2[df2['3gpp.rnti'] != 65535]

    filtered_df = df3[df3['_ws.col.Info'].str.contains('UlData_SrsReceiveRespPs')]

    for row in filtered_df.index:
        try:
            sinr = filtered_df['UlData_srsReceiveRespPsUes_t.ulPmiRank1Sinr'][row]
            # sinr1=filtered_df['UlData_UePuschReceiveRespPs_t.sinr_item'][row].split(',')[1]
            print('Dbg sinr= ', sinr)
            # sinr = 10 * math.log10((math.pow(10, float(sinr0) / 10.0) + math.pow(10, float(sinr1) / 10.0)) / 2.0)
            level = convert_sinr2level(sinr)

            cpt_level_rank1[level] += 1
            print('Dbg level= ', level, 'Compteur = ', cpt_level_rank1[level])
        except Exception as e:
            pass
    return cpt_level_rank1


def count_sinr_rank1(l1l2_traces, endTime, period_in_min):
    cpt_level_rank1 = 26 * [0]
    endTime = datetime.strptime(endTime, "%Y-%m-%d %H:%M:%S")
    beginTime = endTime - timedelta(minutes=period_in_min)

    with open(l1l2_traces, newline='') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        data = [row for row in reader]
        for row in data:
            _ws_col_Time = datetime.strptime(row['_ws.col.Time'], "%Y-%m-%d %H:%M:%S.%f")
            if (beginTime < _ws_col_Time < endTime
               and row['_ws.col.Info'].strip() == 'UlData_SrsReceiveRespPs'
               and row['3gpp.rnti'].strip() != '65535'):
                try:
                    _log('\tDbg sinr=: ' + row['UlData_srsReceiveRespPsUes_t.ulPmiRank1Sinr'])
                    level = convert_sinr2level(row['UlData_srsReceiveRespPsUes_t.ulPmiRank1Sinr'])
                    cpt_level_rank1[level] += 1
                    _log('\tDbg =: {} Compteur = {}' . format(level, cpt_level_rank1[level]))
                except Exception as e:
                    _log('\tulPmiRank1Sinr = ' + row['UlData_srsReceiveRespPsUes_t.ulPmiRank1Sinr'])
                    pass

    return cpt_level_rank1


def count_sinr_rank2_pd(l1l2_traces, endTime, period):
    cpt_level_rank2 = 26 * [0]
    interval = period.replace('min', '')
    df = pd.read_csv(l1l2_traces, sep=';')

    df['_ws.col.Time'] = pd.to_datetime(df['_ws.col.Time'])
    dt = datetime.strptime(str(endTime), "%Y%m%d.%H%M%S")
    endTime = dt
    beginTime = dt - timedelta(minutes=int(interval))

    df1 = df.loc[df['_ws.col.Time'] >= beginTime]
    df2 = df1.loc[df1['_ws.col.Time'] < endTime]
    df3 = df2[df2['3gpp.rnti'] != 65535]

    filtered_df = df3[df3['_ws.col.Info'].str.contains('UlData_PuschReceiveRespPs')]

    for row in filtered_df.index:
        try:
            sinr0 = filtered_df['UlData_UePuschReceiveRespPs_t.sinr_item'][row].split(',')[0]
            sinr1 = filtered_df['UlData_UePuschReceiveRespPs_t.sinr_item'][row].split(',')[1]
            sinr = 10 * math.log10((math.pow(10, float(sinr0) / 10.0) + math.pow(10, float(sinr1) / 10.0)) / 2.0)
            level = convert_sinr2level(sinr)
            cpt_level_rank2[level] += 1
        except Exception as e:
            pass
    return cpt_level_rank2


def count_sinr_rank2(l1l2_traces, endTime, period_in_min):
    cpt_level_rank2 = 26 * [0]
    endTime = datetime.strptime(endTime, "%Y-%m-%d %H:%M:%S")
    beginTime = endTime - timedelta(minutes=period_in_min)

    with open(l1l2_traces, newline='') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        data = [row for row in reader]
        for row in data:
            _ws_col_Time = datetime.strptime(row['_ws.col.Time'], "%Y-%m-%d %H:%M:%S.%f")
            if (beginTime < _ws_col_Time < endTime
               and row['_ws.col.Info'].strip() == 'UlData_PuschReceiveRespPs'
               and row['3gpp.rnti'].strip() != '65535'):
                try:
                    sinr0, sinr1, _ = row['UlData_UePuschReceiveRespPs_t.sinr_item'].split(',', 2)
                    sinr = 10 * math.log10(
                        (math.pow(10, float(sinr0) / 10.0) + math.pow(10, float(sinr1) / 10.0)) / 2.0)
                    cpt_level_rank2[convert_sinr2level(sinr)] += 1
                except Exception as e:
                    pass
    return cpt_level_rank2


if __name__ == '__main__':
    csv_file = 'L2L1_Bip_filtered_ABIO5.pcap0_M55301C010xx.csv'
    end_time = '2023-06-22 13:15:52'
    end_time_pd = '20230622.131552'

    csv_file = 'L2L1_Bip_filtered_ABIO5.pcap1_M55303C1xxxx.csv'
    end_time = '2023-06-30 15:24:49'
    end_time_pd = '20230630.152449'

    csv_file = 'L2L1_Bip_filtered_ABIO5.pcap1_M55308C000xx.csv'
    end_time = '2023-06-16 09:54:36'
    end_time_pd = '20230616.095436'

    csv_file = 'L2L1_Bip_filtered_ABIO5_SBTS23R4_ENB_9999_230718_000012.pcap_M55301C010xx.csv'
    csv_file_ul = 'L2L1_Bip_filtered_ABIO5_SBTS23R4_ENB_9999_230718_000012.pcap_uplink.csv'

    end_time = '2023-07-19 07:21:37'
    end_time_pd = '20230719.072137'
    period = '10 min'
    period_in_min = 10

    # _log('countNumPdschPrb (pd) :\t' + str(countNumPdschPrb_pd(csv_file, end_time_pd, period)))
    # _log(
    # 'countNumPdschPrb (csv) :\t' + str(countNumPdschPrb(csv_file, end_time_pd, period_in_min)))
    # _log('countNumPuschPrb (pd) :\t' + str(countNumPuschPrb_pd(csv_file_ul, end_time_pd, period)))
    # _log(
    # 'countNumPuschPrb (csv) :\t' + str(countNumPuschPrb(csv_file_ul, end_time, period_in_min)))
    # _log('count_DlDataSlot (pd) :\t' + str(count_DlDataSlot_pd(csv_file, end_time_pd, period)))
    # _log('count_DlDataSlot (csv) :\t' + str(count_DlDataSlot(csv_file, end_time, period_in_min)))
    # _log('count_SsbSlotWithPDSCH (pd) :\t' +
    # str(count_SsbSlotWithPDSCH_pd(csv_file, end_time_pd, period)))
    # _log('count_SsbSlotWithPDSCH (csv) :\t' +
    # str(count_SsbSlotWithPDSCH(csv_file, end_time, period_in_min)))
    # _log('count_UlDataSlot (pd) :\t'
    # + str(count_UlDataSlot_pd(csv_file_ul, end_time_pd, period)))
    # _log('count_UlDataSlot (csv) :\t'
    # + str(count_UlDataSlot(csv_file_ul, end_time, period_in_min)))
    # _log('count_sinr_rank1 (pd) :\t'
    # + str(count_sinr_rank1_pd(csv_file_ul, end_time_pd, period)))
    # _log('count_sinr_rank1 (csv) :\t'
    # + str(count_sinr_rank1(csv_file_ul, end_time, period_in_min)))
    # _log('count_sinr_rank2 (pd) :\t' + str(count_sinr_rank2_pd(csv_file, end_time_pd, period)))
    # _log('count_sinr_rank2 (csv) :\t' + str(count_sinr_rank2(csv_file, end_time, period_in_min)))
    # _log('count_pdsch_rank2_tx (pd) :\t'
    # + str(count_pdsch_rank2_tx_pd(csv_file, end_time_pd, period)))
    # _log('count_pdsch_rank2_tx (csv) :\t'
    # + str(count_pdsch_rank2_tx(csv_file, end_time, period_in_min)))
    # _log('count_pucchDtx (pd) :\t\t' + str(count_pucchDtx_pd(csv_file, end_time_pd, period)))
    # _log('count_pucchDtx (csv) :\t\t' + str(count_pucchDtx(csv_file, end_time, period_in_min)))
