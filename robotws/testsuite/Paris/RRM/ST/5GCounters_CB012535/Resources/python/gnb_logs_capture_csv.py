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
from datetime import datetime, timedelta


GNB_LOGS_SCRIPT_DIR = '/home/localuser/Tools/gnb_logs'
GNB_LOGS_TRACE_DIR = '/home/localuser/Tools/gnb_logs'

# TDD_FRAME_STRUCTURE_SLOTS
TDD_FS_SLOTS = {
    '5GC001116_0ms': [[4, 14], [5, 15]],
    '5GC001116_3ms': [[8, 18], [9, 19]],
    '5GC001070': [[4, 8, 14, 18], [9, 19]]
}


def get_fs_slots(fs):
    if fs not in TDD_FS_SLOTS:
        raise KeyError(f'{fs} framestructure not found')
    return TDD_FS_SLOTS[fs]


def start_trace(IP, duration):
    """
    This keyword starts the collection of gnb_logs traces
    :param IP: public IP OAM address of the gNB
    :param duration: duration of the capture in seconds.
    """
    os.chdir(GNB_LOGS_SCRIPT_DIR)
    time.sleep(1)
    cmd = str(GNB_LOGS_SCRIPT_DIR)+'/gnb_logs ' + str(IP) + ' -b ' + str(duration)
    print(cmd)
    os.system(cmd)


def pcap_collect():
    """
    This keyword starts the collection of gnb_logs traces
    :param IP: public IP OAM address of the gNB
    :param duration: duration of the capture in seconds.
    """
    # BIP_Files_List = sorted(glob.glob('*.zip'))
    BIP_Files_List = sorted(glob.glob('*.zip'), key=lambda t: os.stat(t).st_mtime)
    print("BIP_Files_List")
    print(BIP_Files_List)
    bipFile = BIP_Files_List[-1]
    cmd = 'unzip ' + str(bipFile)

    os.system(cmd)
    newDir = GNB_LOGS_TRACE_DIR + '/' + bipFile.split('.zip')[0] + '/bip'
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


def countNumPdschPrb(l1l2_traces, endTime, period_in_min):
    numPdschPrbUsed = 0
    sfn_value = 65535
    slot_value = 65535

    endTime = datetime.strptime(str(endTime), "%Y%m%d.%H%M%S")
    beginTime = endTime - timedelta(minutes=int(period_in_min))
    with open(l1l2_traces, newline='') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        for row in reader:
            _ws_col_Time = datetime.strptime(row['_ws.col.cls_time'], "%Y-%m-%d %H:%M:%S.%f")
            if (beginTime < _ws_col_Time < endTime and
               row['_ws.col.info'].strip() == 'DlData_PdschSendReq' and
               row['3gpp.rnti'].strip() != '65535'):
                numPdschPrbUsed += (sum(list(map(int, row['DlData_PdschGrant.numOfPrb'].split(',')))))
    return numPdschPrbUsed


def countNumPuschPrb(l1l2_traces, endTime, period_in_min):
    numPuschPrbUsed = 0
    endTime = datetime.strptime(str(endTime), "%Y%m%d.%H%M%S")
    beginTime = endTime - timedelta(minutes=int(period_in_min))
    with open(l1l2_traces, newline='') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        for row in reader:
            _ws_col_Time = datetime.strptime(row['_ws.col.cls_time'], "%Y-%m-%d %H:%M:%S.%f")
            if (beginTime < _ws_col_Time < endTime and
               row['3gpp.rnti'].strip() != '65535' and
               row['3gpp.rnti'].strip() != '65521' and
               row['_ws.col.info'].strip() == 'UlData_PuschReceiveReq'):
                numPuschPrbUsed += (sum(list(map(int, row['UlData_puschReceiveReqGrant_t.numOfPrb'].split(',')))))
    return numPuschPrbUsed


def count_DlDataSlot(l1l2_traces, endTime, period_in_min):
    numDlDataSlot = 0
    sfn_value = '65535'
    slot_value = '65535'

    endTime = datetime.strptime(str(endTime), "%Y%m%d.%H%M%S")
    beginTime = endTime - timedelta(minutes=int(period_in_min))
    with open(l1l2_traces, newline='') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        data = [row for row in reader]
        filtered_ssb = list(filter(lambda r: 'DlData_SsBlockSendReq , MIB' == r['_ws.col.info'].strip(), data))
        filtered_sfn = {r['3gpp.sfn']: r['3gpp.sfn'] for r in filtered_ssb}
        filtered_slot = {r['3gpp.slot']: r['3gpp.slot'] for r in filtered_ssb}
        for row in data:
            _ws_col_Time = datetime.strptime(row['_ws.col.cls_time'], "%Y-%m-%d %H:%M:%S.%f")
            if (beginTime < _ws_col_Time < endTime
               and row['3gpp.rnti'].strip() != '65535'
               and row['_ws.col.info'].strip() == 'DlData_PdschSendReq'
               and (sfn_value != row['3gpp.sfn'] or slot_value != row['3gpp.slot'])):
                if not (sfn_value in filtered_sfn and slot_value in filtered_slot):
                    numDlDataSlot += 1
                sfn_value = row['3gpp.sfn']
                slot_value = row['3gpp.slot']
    return numDlDataSlot


def count_SsbSlotWithPDSCH(l1l2_traces, endTime, period_in_min):
    numSsbSlotPdsch = 0
    sfn_value = '65535'
    slot_value = '65535'

    endTime = datetime.strptime(str(endTime), "%Y%m%d.%H%M%S")
    beginTime = endTime - timedelta(minutes=int(period_in_min))
    with open(l1l2_traces, newline='') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        data = [row for row in reader]
        filtered_ssb = list(filter(lambda r: 'DlData_SsBlockSendReq , MIB' == r['_ws.col.info'].strip(), data))
        filtered_sfn = {r['3gpp.sfn']: r['3gpp.sfn'] for r in filtered_ssb}
        filtered_slot = {r['3gpp.slot']: r['3gpp.slot'] for r in filtered_ssb}
        for row in data:
            _ws_col_Time = datetime.strptime(row['_ws.col.cls_time'], "%Y-%m-%d %H:%M:%S.%f")
            if (beginTime < _ws_col_Time < endTime
               and row['_ws.col.info'].strip() == 'DlData_PdschSendReq'
               and row['3gpp.rnti'].strip() != '65535'
               and (sfn_value != row['3gpp.sfn'] or slot_value != row['3gpp.slot'])):
                if (sfn_value in filtered_sfn and slot_value in filtered_slot):
                    numSsbSlotPdsch += 1
                sfn_value = row['3gpp.sfn']
                slot_value = row['3gpp.slot']

    return numSsbSlotPdsch


def count_UlDataSlot(l1l2_traces, endTime, period_in_min):
    numUlDataSlot = 0
    numUlRachSlot = 0
    sfn_value = '65535'
    slot_value = '65535'
    rach_sfn = '65535'
    rach_slot = '65535'

    endTime = datetime.strptime(str(endTime), "%Y%m%d.%H%M%S")
    beginTime = endTime - timedelta(minutes=int(period_in_min))

    with open(l1l2_traces, 'r') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        data = [row for row in reader]
        filtered_rach = list(filter(lambda r: 'UlData_PrachReceiveInd' == r['_ws.col.info'].strip(), data))
        filtered_sfn = {r['3gpp.sfn']: r['3gpp.sfn'] for r in filtered_rach}
        filtered_slot = {r['3gpp.slot']: r['3gpp.slot'] for r in filtered_rach}
        for row in data:
            _ws_col_Time = datetime.strptime(row['_ws.col.cls_time'], "%Y-%m-%d %H:%M:%S.%f")
            if (beginTime < _ws_col_Time < endTime
               and row['_ws.col.info'].strip() == 'UlData_PuschReceiveReq'
               and row['3gpp.rnti'].strip() != '65535'
               and (sfn_value != row['3gpp.sfn'] or slot_value != row['3gpp.slot'])):
                if not (sfn_value in filtered_sfn and slot_value in filtered_slot):
                    numUlDataSlot += 1
                sfn_value = row['3gpp.sfn']
                slot_value = row['3gpp.slot']
    return numUlDataSlot


def count_pdsch_rank_tx(l1l2_traces, endTime, period_in_min, numOfLayers='2'):
    cpt_mcs_rank = 32 * [0]
    endTime = datetime.strptime(str(endTime), "%Y%m%d.%H%M%S")
    beginTime = endTime - timedelta(minutes=int(period_in_min))

    with open(l1l2_traces, newline='') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        for row in reader:
            _ws_col_Time = datetime.strptime(row['_ws.col.cls_time'], "%Y-%m-%d %H:%M:%S.%f")
            if (beginTime < _ws_col_Time < endTime
               and row['DlData_PdschGrant.numOfLayers'].strip() == numOfLayers
               and row['3gpp.rnti'].strip() != '65535'):
                try:
                    cpt_mcs_rank[int(row['DlData_PdschGrant.mcs'])] += 1
                except Exception as e:
                    pass
    return cpt_mcs_rank


# TODO remove count_pdsch_rank3_tx and count_pdsch_rank2_tx and update robot code
def count_pdsch_rank3_tx(l1l2_traces, endTime, period_in_min):
    return count_pdsch_rank_tx(l1l2_traces, endTime, period_in_min, numOfLayers='3')


def count_pdsch_rank2_tx(l1l2_traces, endTime, period_in_min):
    return count_pdsch_rank_tx(l1l2_traces, endTime, period_in_min, numOfLayers='2')


def count_pdsch_rank2_tx_tmp(l1l2_traces, endTime, period_in_min):
    cpt_mcs_rank2 = 32 * [0]
    endTime = datetime.strptime(str(endTime), "%Y%m%d.%H%M%S")
    beginTime = endTime - timedelta(minutes=int(period_in_min))

    with open(l1l2_traces, newline='') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        for row in reader:
            _ws_col_Time = datetime.strptime(row['_ws.col.cls_time'], "%Y-%m-%d %H:%M:%S.%f")
            if (beginTime < _ws_col_Time < endTime
               and row['DlData_PdschGrant.numOfLayers'].strip() == '2'
               and row['3gpp.rnti'].strip() != '65535'):
                try:
                    cpt_mcs_rank2[int(row['DlData_PdschGrant.mcs'])] += 1
                except Exception as e:
                    pass
    return cpt_mcs_rank2


def count_pucchDtx(l1l2_traces, endTime, period_in_min):
    numPucch = {}
    numPucch['F1_non_DTX'] = 0
    numPucch['F1_DTX'] = 0
    numPucch['F3_non_DTX'] = 0
    numPucch['F3_DTX'] = 0

    endTime = datetime.strptime(str(endTime), "%Y%m%d.%H%M%S")
    beginTime = endTime - timedelta(minutes=int(period_in_min))
    with open(l1l2_traces, newline='') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        for row in reader:
            _ws_col_Time = datetime.strptime(row['_ws.col.cls_time'], "%Y-%m-%d %H:%M:%S.%f")
            if (beginTime < _ws_col_Time < endTime and row['_ws.col.info'].strip() == 'UlData_PucchReceiveRespPs'):
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


def count_pusch_trns_by_ul_slots(l1l2_traces, endTime, period_in_min, slots):
    numTrns = 0
    endTime = datetime.strptime(str(endTime), "%Y%m%d.%H%M%S")
    beginTime = endTime - timedelta(minutes=int(period_in_min))
    print('Debug slots list: ', slots)
    with open(l1l2_traces, 'r') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        data = [row for row in reader]
        for row in data:
            if row['3gpp.slot'] == '':
                continue
            _ws_col_Time = datetime.strptime(row['_ws.col.cls_time'], "%Y-%m-%d %H:%M:%S.%f")
            if (beginTime < _ws_col_Time < endTime
               and row['_ws.col.info'].strip() == 'UlData_PuschReceiveRespPs'
               and row['3gpp.rnti'].strip() != '65535'
               and row['3gpp.rnti'].strip() != '65521'
               and int(row['3gpp.slot']) in slots):
                numTrns += 1
    return numTrns


def count_pusch_trns_f_by_ul_slots(l1l2_traces, endTime, period_in_min, slots):
    numTrnsF = 0
    endTime = datetime.strptime(str(endTime), "%Y%m%d.%H%M%S")
    beginTime = endTime - timedelta(minutes=int(period_in_min))

    with open(l1l2_traces, 'r') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        data = [row for row in reader]
        for row in data:
            if row['3gpp.slot'] == '':
                continue
            _ws_col_Time = datetime.strptime(row['_ws.col.cls_time'], "%Y-%m-%d %H:%M:%S.%f")
            if (beginTime < _ws_col_Time < endTime
               and row['_ws.col.info'].strip() == 'UlData_PuschReceiveRespPs'
               and row['3gpp.rnti'].strip() != '65535'
               and row['3gpp.rnti'].strip() != '65521'
               and
                (row['UlData_UePuschReceiveRespPs_t.dtx'].strip() == '1'  # (DTX)
                or row['UlData_UePuschReceiveRespPs_t.crc'].strip() == '1')  # NOK
               and int(row['3gpp.slot']) in slots):
                numTrnsF += 1
    return numTrnsF


def count_pusch_vonr_trns_by_ul_slots(l1l2_traces, endTime, period_in_min, slots):
    numVonrTrns = 0
    return numVonrTrns


def count_sinr_rank1(l1l2_traces, endTime, period_in_min):
    cpt_level_rank1 = 26 * [0]
    endTime = datetime.strptime(str(endTime), "%Y%m%d.%H%M%S")
    beginTime = endTime - timedelta(minutes=int(period_in_min))

    with open(l1l2_traces, newline='') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        for row in reader:
            _ws_col_Time = datetime.strptime(row['_ws.col.cls_time'], "%Y-%m-%d %H:%M:%S.%f")
            if (beginTime < _ws_col_Time < endTime
               and row['_ws.col.info'].strip() == 'UlData_SrsReceiveRespPs'
               and row['3gpp.rnti'].strip() != '65535'):
                try:
                    # print('\tDbg sinr=: ' + row['UlData_srsReceiveRespPsUes_t.ulPmiRank1Sinr'])
                    level = convert_sinr2level(float(row['UlData_srsReceiveRespPsUes_t.ulPmiRank1Sinr']))
                    cpt_level_rank1[level] += 1
                    # print('\tDbg =: {} Compteur = {}' . format(level, cpt_level_rank1[level]))
                except Exception as e:
                    print('\tulPmiRank1Sinr = ' + row['UlData_srsReceiveRespPsUes_t.ulPmiRank1Sinr'])
                    pass

    return cpt_level_rank1


def count_sinr_rank2(l1l2_traces, endTime, period_in_min):
    cpt_level_rank2 = 26 * [0]
    endTime = datetime.strptime(str(endTime), "%Y%m%d.%H%M%S")
    beginTime = endTime - timedelta(minutes=int(period_in_min))

    with open(l1l2_traces, newline='') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        for row in reader:
            _ws_col_Time = datetime.strptime(row['_ws.col.cls_time'], "%Y-%m-%d %H:%M:%S.%f")
            if (beginTime < _ws_col_Time < endTime
               and row['_ws.col.info'].strip() == 'UlData_PuschReceiveRespPs'
               and row['3gpp.rnti'].strip() != '65535'):
                try:
                    sinr0, sinr1, _ = row['UlData_UePuschReceiveRespPs_t.sinr_item'].split(',', 2)
                    sinr = 10 * math.log10(
                        (math.pow(10, float(sinr0) / 10.0) + math.pow(10, float(sinr1) / 10.0)) / 2.0)
                    cpt_level_rank2[convert_sinr2level(sinr)] += 1
                except Exception as e:
                    pass
    return cpt_level_rank2


def get_avg_mcs_pusch_by_ul_slots(l1l2_traces, endTime, period_in_min, slots, mcsTable):
    numMcs = 0
    sumMcs = 0
    numUlRachSlot = 0
    # sfn_value = '65535'
    # slot_value = '65535'
    # rach_sfn = '65535'
    # rach_slot = '65535'
    print('Debug get_avg_mcs_pusch - slots list: ', slots)
    endTime = datetime.strptime(str(endTime), "%Y%m%d.%H%M%S")
    beginTime = endTime - timedelta(minutes=int(period_in_min))

    with open(l1l2_traces, 'r') as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        data = [row for row in reader]
        for row in data:
            if row['3gpp.slot'] == '':
                continue
            _ws_col_Time = datetime.strptime(row['_ws.col.cls_time'], "%Y-%m-%d %H:%M:%S.%f")
            if (beginTime < _ws_col_Time < endTime
               and row['_ws.col.info'].strip() == 'UlData_PuschReceiveReq'
               and row['UlData_puschReceiveReqGrant_t.mcsTable'].strip() == mcsTable
               and row['UlData_puschReceiveReqGrant_t.rvIndex'].strip() == '0'
               and int(row['3gpp.slot']) in slots):
                numMcs += 1
                sumMcs += int(row['UlData_puschReceiveReqGrant_t.mcs'])
    print('Debug get_avg_mcs_pusch - numMcs: ', numMcs)
    print('Debug get_avg_mcs_pusch - sumMcs: ', sumMcs)
    return [sumMcs, numMcs]
    return sumMcs/numMcs if numMcs > 0 else numMcs


if __name__ == '__main__':
    csv_file = 'fct_L2L1_Bip_filtered_ASOE_SBTS25R1_ENB_9999_240812_000010.pcap3_uplink.csv'
    csv_file_ul = '/tmp/fct_L2L1_Bip_filtered_ASOE_SBTS25R1_ENB_9999_240812_000010.pcap2_uplink_formatted 2.csv'
    csv_file = csv_file_ul
    end_time = '20240823.132000'
    period_in_min = 20

    # print('countNumPdschPrb (csv) :\t' + str(countNumPdschPrb(csv_file, end_time, period_in_min)))
    # print('countNumPuschPrb (csv) :\t' + str(countNumPuschPrb(csv_file_ul, end_time, period_in_min)))
    # print('count_DlDataSlot (csv) :\t' + str(count_DlDataSlot(csv_file, end_time, period_in_min)))
    # print('count_SsbSlotWithPDSCH (csv) :\t' + str(count_SsbSlotWithPDSCH(csv_file, end_time, period_in_min)))

    fs_slots = [
        get_fs_slots('5GC001116_0ms'),
        get_fs_slots('5GC001116_3ms'),
        get_fs_slots('5GC001070')]

    print('count_pusch_trns_f_by_ul_slots M55308C00125 first(csv) :\t' + str(
        count_pusch_trns_f_by_ul_slots(csv_file, end_time, period_in_min, fs_slots[2][0])))
    print('count_pusch_trns_f_by_ul_slots M55308C00126 scnd(csv) :\t' + str(
        count_pusch_trns_f_by_ul_slots(csv_file, end_time, period_in_min, fs_slots[2][1])))
    print('count_pusch_trns_by_ul_slots M55308C00123 first(csv) :\t' + str(
        count_pusch_trns_by_ul_slots(csv_file, end_time, period_in_min, fs_slots[1][1])))
    for slots in fs_slots:
        print('count_pusch_trns_by_ul_slots M55308C00123 first(csv) :\t' + str(
            count_pusch_trns_by_ul_slots(csv_file, end_time, period_in_min, slots[0])))
        print('count_pusch_trns_by_ul_slots M55308C00124 scnd (csv) :\t' + str(
            count_pusch_trns_by_ul_slots(csv_file, end_time, period_in_min, slots[1])))
        print('get_avg_mcs_pusch_by_ul_slots M55308C00133 first (csv) :\t' + str(
            get_avg_mcs_pusch_by_ul_slots(csv_file, end_time, period_in_min, slots[0], 'max64QAM')))
        print('get_avg_mcs_pusch_by_ul_slots M55308C00134 scnd (csv) :\t' + str(
            get_avg_mcs_pusch_by_ul_slots(csv_file, end_time, period_in_min, slots[1], 'max64QAM')))
        print('get_avg_mcs_pusch_by_ul_slots M55308C00135 first (csv) :\t' + str(
            get_avg_mcs_pusch_by_ul_slots(csv_file, end_time, period_in_min, slots[0], 'max256QAM')))
        print('get_avg_mcs_pusch_by_ul_slots M55308C00136 scnd (csv) :\t' + str(
            get_avg_mcs_pusch_by_ul_slots(csv_file, end_time, period_in_min, slots[1], 'max256QAM')))
        print('get_avg_mcs_pusch_by_ul_slots M55308C00137 first (csv) :\t' + str(
            get_avg_mcs_pusch_by_ul_slots(csv_file, end_time, period_in_min, slots[0], 'max64QAM')))
        print('get_avg_mcs_pusch_by_ul_slots M55308C00138 scnd (csv) :\t' + str(
            get_avg_mcs_pusch_by_ul_slots(csv_file, end_time, period_in_min, slots[1], 'max64QAM')))
    # print('count_UlDataSlot (csv) :\t' + str(count_UlDataSlot(csv_file_ul, end_time, period_in_min)))
    # print('count_sinr_rank1 (csv) :\t' + str(count_sinr_rank1(csv_file_ul, end_time, period_in_min)))
    # print('count_sinr_rank2 (csv) :\t' + str(count_sinr_rank2(csv_file, end_time, period_in_min)))
    # print('count_pdsch_rank2_tx (csv) :\t' + str(count_pdsch_rank2_tx(csv_file, end_time, period_in_min)))
    # print('count_pucchDtx (csv) :\t\t' + str(count_pucchDtx(csv_file, end_time, period_in_min)))
