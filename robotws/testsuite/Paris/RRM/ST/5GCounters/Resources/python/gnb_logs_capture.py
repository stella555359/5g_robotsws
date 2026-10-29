"""
        Keywords Purpose:
            Keywords to start, stop and collect gNB_Logs traces

        AUTHOR:
            Yvan Maurin       yvan.maurin@nokia.com

        12/May/2023: start gNB_logs capture
"""

import os.path
import time
import glob
import math
import pandas as pd
from datetime import datetime, timedelta

GNB_LOGS_SCRIPT_DIR = '/home/localuser/Tools/gnb_logs'
GNB_LOGS_TRACE_DIR = '/home/localuser/Tools/gnb_logs'


def start_trace(IP, duration):
    """
    This keyword starts the collection of gnb_logs traces
    :param IP: public IP OAM address of the gNB
    :param duration: duration of the capture in seconds.
    """
    # cmd = 'cd ' + GNB_LOGS_SCRIPT_DIR
    # print ("Command: ", cmd)
    os.chdir(GNB_LOGS_SCRIPT_DIR)
    print("New Current Directory is: ", os.getcwd())
    time.sleep(1)
    cmd = str(GNB_LOGS_SCRIPT_DIR)+'/gnb_logs ' + str(IP) + ' -b ' + str(duration)
    print("Command: ", cmd)
    os.system(cmd)


def pcap_collect():
    """
    This keyword starts the collection of gnb_logs traces
    :param IP: public IP OAM address of the gNB
    :param duration: duration of the capture in seconds.
    """

    # BIP_Files_List = sorted(glob.glob('*.zip'))
    BIP_Files_List = sorted(glob.glob('*.zip'), key=lambda t: os.stat(t).st_mtime)
    # Latest BIP file
    bipFile = BIP_Files_List[-1]
    cmd = 'unzip ' + str(bipFile)

    os.system(cmd)
    newDir = GNB_LOGS_TRACE_DIR + '/' + bipFile.split('.zip')[0]
    os.system('cd ' + str(newDir))
    PCAP_Files_List = glob.glob(newDir + '/*pcap*')
    print("PCAP Files List: ", PCAP_Files_List)

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
    level = int(max(min(sinr/2 + 5.9999999, 25.0), 1.0))
    return level


def countNumPuschPrb(l1l2_traces, endTime, period):
    numPuschPrbUsed = 0
    interval = period.replace('min', '')

    df = pd.read_csv(l1l2_traces, sep=';')
    df['_ws.col.Time'] = pd.to_datetime(df['_ws.col.Time'], dayfirst=True)
    dt = datetime.strptime(str(endTime), "%Y%m%d.%H%M%S")
    endTime = dt
    beginTime = dt - timedelta(minutes=int(interval))
    df1 = df.loc[df['_ws.col.Time'] >= beginTime]
    df2 = df1.loc[df1['_ws.col.Time'] < endTime]

    filtered_df = df2[df2['_ws.col.Info'].str.contains('UlData_PuschReceiveReq')]
    for row in filtered_df.index:
        try:
            value = filtered_df['UlData_puschReceiveReqGrant_t.numOfPrb'][row].split(',')
            for i in range(0, len(value)):
                numPuschPrbUsed += int(value[i])
        except Exception as e:
            value = filtered_df['UlData_puschReceiveReqGrant_t.numOfPrb'][row]
            numPuschPrbUsed += int(value)

    print("NumPuschPrbUsed = ", numPuschPrbUsed)
    return (numPuschPrbUsed)


def countNumPdschPrb(l1l2_traces, endTime, period):
    numPdschPrbUsed = 0
    interval = period.replace('min', '')
    df = pd.read_csv(l1l2_traces, sep=';')
    df['_ws.col.Time'] = pd.to_datetime(df['_ws.col.Time'], dayfirst=True)
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

    print("NumPdschPrbUsed = ", numPdschPrbUsed)
    return (numPdschPrbUsed)


def count_DlDataSlot(l1l2_traces, endTime, period):
    numDlDataSlot = 0
    interval = period.replace('min', '')
    sfn_value = 65535
    slot_value = 65535
    row_index = 1
    df = pd.read_csv(l1l2_traces, sep=';')

    df['_ws.col.Time'] = pd.to_datetime(df['_ws.col.Time'], dayfirst=True)
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
            # check it is not a ssb sfn/slot
            if not (sfn_value in ssb_df['3gpp.sfn'].values and slot_value in ssb_df['3gpp.slot'].values):
                numDlDataSlot += 1
            sfn_value = filtered_df['3gpp.sfn'][row]
            slot_value = filtered_df['3gpp.slot'][row]
    return (numDlDataSlot)


def count_SsbSlotWithPDSCH(l1l2_traces, endTime, period):
    numSsbSlotPdsch = 0
    interval = period.replace('min', '')
    sfn_value = 65535
    slot_value = 65535
    row_index = 1
    df = pd.read_csv(l1l2_traces, sep=';')

    df['_ws.col.Time'] = pd.to_datetime(df['_ws.col.Time'], dayfirst=True)
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


def count_UlDataSlot(l1l2_traces, endTime, period):
    numUlDataSlot = 0
    interval = period.replace('min', '')
    sfn_value = 65535
    slot_value = 65535
    row_index = 1
    df = pd.read_csv(l1l2_traces, sep=';')

    df['_ws.col.Time'] = pd.to_datetime(df['_ws.col.Time'], dayfirst=True)
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


def count_sinr_rank1(l1l2_traces, endTime, period):
    cpt_level_rank1 = 26 * [0]
    interval = period.replace('min', '')
    df = pd.read_csv(l1l2_traces, sep=';')

    df['_ws.col.Time'] = pd.to_datetime(df['_ws.col.Time'], dayfirst=True)

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


def count_sinr_rank2(l1l2_traces, endTime, period):
    cpt_level_rank2 = 26 * [0]
    interval = period.replace('min', '')
    df = pd.read_csv(l1l2_traces, sep=';')

    df['_ws.col.Time'] = pd.to_datetime(df['_ws.col.Time'], dayfirst=True)
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


def count_pdsch_rank2_tx(l1l2_traces, endTime, period):
    cpt_mcs_rank2 = 32 * [0]
    interval = period.replace('min', '')
    df = pd.read_csv(l1l2_traces, sep=';')

    df['_ws.col.Time'] = pd.to_datetime(df['_ws.col.Time'], dayfirst=True)
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
