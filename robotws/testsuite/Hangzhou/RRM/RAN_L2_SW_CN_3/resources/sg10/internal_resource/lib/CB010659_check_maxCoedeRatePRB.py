'''
Author: Zhang Shuang
Function: check maxcodeRatePRB is correct for 10659
'''
import csv
import math


def _reservedMCS_used(i_line):
    MCS = float(i_line['ulFdSchedData.rrmUlUsedMcs'])
    MCS_table = i_line['ulFdSchedData.mcsTable']
    if MCS_table == 'QAM64':
        if MCS > 28:
            return MCS
    # 256Qam and 64Qam_transPrecoding
    else:
        if MCS > 27:
            return MCS
    return 0


def _map_256QAM_Qm(MCS):
    if (MCS < 5) or (MCS == 28):
        Qm = 2
    elif (MCS < 11) or (MCS == 29):
        Qm = 4
    elif (MCS < 20) or (MCS == 30):
        Qm = 6
    elif (MCS < 28) or (MCS == 31):
        Qm = 8
    return Qm


def _map_64QAM_Qm(MCS):
    if (MCS < 10) or (MCS == 29):
        Qm = 2
    elif (MCS < 17) or (MCS == 30):
        Qm = 4
    elif (MCS < 29) or (MCS == 31):
        Qm = 6
    return Qm


def _map_64QAM_with_transPrecoding(MCS, pi2BPSK):
    # 3gpp 38.214
    # For Table 6.1.4.1-1 and Table 6.1.4.1-2,
    # if higher layer parameter tp-pi2BPSK is configured, q=1 otherwise q=2
    if pi2BPSK:
        q = 1
    else:
        q = 2
    if (MCS < 2) or (MCS == 28):
        Qm = q
    elif (MCS < 10) or (MCS == 29):
        Qm = 2
    elif (MCS < 17) or (MCS == 30):
        Qm = 4
    elif (MCS < 28) or (MCS == 31):
        Qm = 6
    # print('QM=',q)
    return Qm


def _get_Qm(i_line, is_DFTsOFDM, pi2BPSK):
    if not is_DFTsOFDM:
        if i_line['ulFdSchedData.mcsTable'] == 'QAM64' and i_line['ulFdSchedData.rrmUlUsedMcs']:
            MCS = int(float(i_line['ulFdSchedData.rrmUlUsedMcs']))
            Qm = _map_64QAM_Qm(MCS)
        elif i_line['ulFdSchedData.mcsTable'] == 'QAM256' and i_line['ulFdSchedData.rrmUlUsedMcs']:
            MCS = int(float(i_line['ulFdSchedData.rrmUlUsedMcs']))
            Qm = _map_256QAM_Qm(MCS)
    elif is_DFTsOFDM:
        if i_line['ulFdSchedData.mcsTable'] == 'QAM64' and i_line['ulFdSchedData.rrmUlUsedMcs']:
            MCS = int(float(i_line['ulFdSchedData.rrmUlUsedMcs']))
            Qm = _map_64QAM_with_transPrecoding(MCS, pi2BPSK)
    return Qm


def _get_rank(i_line):
    RANK = i_line['ulFdSchedData.numOfLayers']
    if RANK:
        if RANK == 'RANK1':
            RANK = 1
        elif RANK == 'RANK2':
            RANK = 2
    else:
        print('empty RANK')
    return RANK


def _total_CRC_bits(ini_tbSize):
    # 3gpp.38212.5.22 and 7.21
    # LDPC base graph1, the max code block size is Kcb=8448(LTE 6144); graph2 Kcb=3840
    # decide CRC
    if ini_tbSize > 3824:
        CRC = 24
    else:
        CRC = 16

    Kcb = 8448
    B = ini_tbSize + CRC
    if B <= Kcb:
        total_CRC = CRC
    else:
        # math.ceil : Round up
        C = math.ceil((ini_tbSize + CRC) / (Kcb - CRC))
        total_CRC = CRC + C * CRC
    return total_CRC


def _calculate_PRB_maxCodeRate(ini_tbSize, total_CRC, maxCodeRate, rePerPRBreTx, Qm, Rank):
    # CB010659-6967
    PRB_maxCodeRate = math.ceil((ini_tbSize + total_CRC) / (maxCodeRate * rePerPRBreTx * Qm * Rank))
    return PRB_maxCodeRate


def check_maxCodeRatePRB(csv_filename, str_maxCodeRate, str_is_DFTsOFDM='0', str_pi2BPSK='0'):
    if str(str_is_DFTsOFDM) == '0':
        is_DFTsOFDM = False
    else:
        is_DFTsOFDM = True
    if str(str_pi2BPSK) == '0':
        pi2BPSK = False
    else:
        pi2BPSK = True
    maxCodeRate = float(str_maxCodeRate)

    for_time = 0
    total_ERR = 0
    total_pass = 0
    with open(csv_filename) as csvfile:
        # csv.DictReader(csvfile): read csv as a list of dict
        list_reader = list(csv.DictReader(csvfile))
        list_reader_copy = list_reader
        for i_line in list_reader:
            if i_line['ulFdSchedData.PRBMaxCodeRateRetx']:
                PRB_maxCodeRate = int(float(i_line['ulFdSchedData.PRBMaxCodeRateRetx']))
                # check PCBmaxCodeRate
                if PRB_maxCodeRate > 0:
                    Qm = _get_Qm(i_line, is_DFTsOFDM, pi2BPSK)
                    Rank = _get_rank(i_line)
                    rePerPRBreTx = int(float(i_line['ulFdSchedData.rePerPrbReTx']))
                    # find ini tbSize
                    rnti = i_line['rnti']
                    curr_sfn = int(float(i_line['sfn']))
                    curr_slot = int(float(i_line['slot']))
                    '''
                    if not _reservedMCS_used(i_line):
                        continue
                    '''
                    HarqProcessIndex = i_line['ulFdSchedData.ulHarqProcessIndex']
                    curr_index = list_reader.index(i_line)
                    # print("curr_index:", curr_index, str(curr_sfn)+'-'+str(curr_slot), rnti)
                    # Iteration in reverse order, from curr line, to find ini_line
                    for j_line in list_reader_copy[curr_index + 1:0:-1]:
                        if (j_line['ulFdSchedData.numOfPrb']):
                            sfn = int(float(j_line['sfn']))
                            slot = int(float(j_line['slot']))
                            if (j_line['rnti'] == rnti) and (
                                        j_line['ulFdSchedData.ulHarqProcessIndex'] == HarqProcessIndex) and (
                                        j_line['ulFdSchedData.txNumber'] == '1.0'):
                                ini_tbSize = int(float(j_line['ulFdSchedData.tbSize']))
                                find_ini_line = 1
                                # print("find ini")
                                break
                            else:
                                find_ini_line = 0

                    if not find_ini_line:
                        # print("not find ini_line")
                        continue
                    for_time += 1

                    total_CRC = _total_CRC_bits(ini_tbSize)
                    PRB_maxCodeRate = _calculate_PRB_maxCodeRate(
                            ini_tbSize, total_CRC, maxCodeRate, rePerPRBreTx, Qm, Rank)
                    PRB_maxCodeRate_log = int(float(i_line['ulFdSchedData.PRBMaxCodeRateRetx']))
                    if PRB_maxCodeRate != PRB_maxCodeRate_log:
                        print('ERR:PRB_maxCodeRate|', str(curr_sfn) + '-' + str(curr_slot),
                              '| expect:', PRB_maxCodeRate, 'log:', PRB_maxCodeRate_log,
                              '| rnti:'+str(rnti), '| MCS:'+i_line['ulFdSchedData.rrmUlUsedMcs'])
                        total_ERR += 1
                        # raise Exception('Fail')
                    elif PRB_maxCodeRate == PRB_maxCodeRate_log:
                        total_pass += 1
        print("for_time:", for_time)
        print("total_ERR:", total_ERR)
        print("total_pass:", total_pass)
    if total_ERR:
        print("Fail")
        raise Exception('Fail')
    else:
        print("Pass")
# check_maxCodeRatePRB('tti_B_case33_ul.csv', 1.3)
# check_maxCodeRatePRB('tti_4R1_bler_ul_case29.csv', 1.3)
# check_maxCodeRatePRB('tti_adapV2_ul.csv', 0.97)
# check_maxCodeRatePRB('tti_bler_case45_ul.csv', 0.97)
# check_maxCodeRatePRB('tti_US3_ul.csv', 0.97, '1', '0')
