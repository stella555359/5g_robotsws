'''
Author: Zhang Shuang
Function: check adaptRetxStatus,reservedMCS,data missing,PRBCand,PRBmin.
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
        reservedMCS = 28
    elif (MCS < 11) or (MCS == 29):
        Qm = 4
        reservedMCS = 29
    elif (MCS < 20) or (MCS == 30):
        Qm = 6
        reservedMCS = 30
    elif (MCS < 28) or (MCS == 31):
        Qm = 8
        reservedMCS = 31
    return Qm, reservedMCS


def _map_64QAM_Qm(MCS):
    if (MCS < 10) or (MCS == 29):
        Qm = 2
        reservedMCS = 29
    elif (MCS < 17) or (MCS == 30):
        Qm = 4
        reservedMCS = 30
    elif (MCS < 29) or (MCS == 31):
        Qm = 6
        reservedMCS = 31
    return Qm, reservedMCS


def _map_64QAM_with_transPrecoding(MCS, ulTransPrecodePi2Bpsk):
    # 3gpp 38.214
    # For Table 6.1.4.1-1 and Table 6.1.4.1-2, if higher layer parameter tp-pi2BPSK is configured, q = 1 otherwise q=2
    # CB008662:when Qm=2 and q=2, reserved MCS=29 used
    if ulTransPrecodePi2Bpsk:   #
        q = 1
    else:
        q = 2
    if (MCS < 2):
        Qm = q
        if q == 2:
            reservedMCS = 29
        elif q == 1:    # not APPLY reserved MCS
            print("DFTsOFDM and q=1 and MCS<2, reservedMCS not apply!")
            reservedMCS = -1
    elif (MCS < 10) or (MCS == 29):
        Qm = 2
        reservedMCS = 29
    elif (MCS < 17) or (MCS == 30):
        Qm = 4
        reservedMCS = 30
    elif (MCS < 28) or (MCS == 31):
        Qm = 6
        reservedMCS = 31
    return Qm, reservedMCS


def _get_Qm_reservedMCS(i_line, is_DFTsOFDM, ulTransPrecodePi2Bpsk):
    if i_line['ulFdSchedData.mcsTable'] == 'QAM64' and i_line['ulFdSchedData.rrmUlUsedMcs'] and (not is_DFTsOFDM):
        MCS = int(float(i_line['ulFdSchedData.rrmUlUsedMcs']))
        Qm, reservedMCS = _map_64QAM_Qm(MCS)
    elif i_line['ulFdSchedData.mcsTable'] == 'QAM256' and i_line['ulFdSchedData.rrmUlUsedMcs']:
        MCS = int(float(i_line['ulFdSchedData.rrmUlUsedMcs']))
        Qm, reservedMCS = _map_256QAM_Qm(MCS)
    # QAM name not sure
    elif i_line['ulFdSchedData.mcsTable'] == 'QAM64' and i_line['ulFdSchedData.rrmUlUsedMcs'] and is_DFTsOFDM:
        MCS = int(float(i_line['ulFdSchedData.rrmUlUsedMcs']))
        Qm, reservedMCS = _map_64QAM_with_transPrecoding(MCS, ulTransPrecodePi2Bpsk)
    return Qm, reservedMCS


def _check_log_missing(i_line):
    sfn = int(float(i_line['sfn']))
    slot = int(float(i_line['slot']))
    if (i_line['ulFdSchedData.numOfPrb']) and (not i_line['ulHarqRxData.crcResult']):
        print("WRN: crcResult missing!", str(sfn) + '-' + str(slot), 'rnti:' + i_line['rnti'])
        return 1
    if (not i_line['ulFdSchedData.numOfPrb']) and (i_line['ulHarqRxData.crcResult']):
        print("WRN: data missing!", str(sfn) + '-' + str(slot), 'rnti:' + i_line['rnti'])
        return 2
    else:
        return 0


def _check_PRBCand_PRBmin(j_line, targetPct, minPct, ini_numPRB):
    # check PRBCand and PRBmin
    rnti = j_line['rnti']
    PRBCandRetx = int(float(j_line['ulFdSchedData.PRBCandRetx']))
    expect_PRBCandRetx = math.ceil(ini_numPRB * targetPct)
    ERR_PRBCand = False
    ERR_PRBmin = False
    if PRBCandRetx != expect_PRBCandRetx:
        ERR_PRBCand = True
        print('ERR-PRBCand|', j_line['sfn'] + '-' + j_line['slot'],
              '| expect:' + str(expect_PRBCandRetx) + 'log:' + str(PRBCandRetx),
              '| rnti:' + rnti)

    PRBmin = int(float(j_line['ulFdSchedData.PRBMinRetx']))
    expect_PRBmin = math.ceil(ini_numPRB * minPct)
    if PRBmin != expect_PRBmin:
        print('ERR-PRBmin|', j_line['sfn'] + '-' + j_line['slot'],
              '| expect:' + str(expect_PRBmin) + 'log:' + str(PRBmin),
              '| rnti:' + rnti)
        ERR_PRBmin = True
    return ERR_PRBCand, ERR_PRBmin


def check_reTx_status_and_reservedMCS(csv_filename, str_targetPct, str_minPct,
                                      str_is_DFTsOFDM='0', str_ulTransPrecodePi2Bpsk='0'):
    if str_is_DFTsOFDM == '0':
        is_DFTsOFDM = False
    else:
        is_DFTsOFDM = True
    if str_ulTransPrecodePi2Bpsk == '0':
        ulTransPrecodePi2Bpsk = False
    else:
        ulTransPrecodePi2Bpsk = True
    targetPct = float(str_targetPct)
    minPct = float(str_minPct)
    for_time = 0
    ERR_Status = 0
    ERR_MCS = 0
    ERR_PRB = 0
    ERR_PRBCand = 0
    ERR_PRBmin = 0
    total_pass = 0
    crc_missing = 0
    data_missing = 0
    with open(csv_filename) as csvfile:
        list_reader = list(csv.DictReader(csvfile))
        list_reader_copy = list_reader
        print('---------run check_reTx_status_and_reservedMCS---------')
        for i_line in list_reader:
            # step 0: check log missing
            if _check_log_missing(i_line) == 1:
                crc_missing += 1
                continue
            elif _check_log_missing(i_line) == 2:
                data_missing += 1
                continue
            # step1: find ini NOK
            if (i_line['ulFdSchedData.txNumber'] == '1.0') and (i_line['ulHarqRxData.crcResult'] == 'NOK'):
                rnti = i_line['rnti']
                ini_numPRB = float(i_line['ulFdSchedData.numOfPrb'])
                ini_sfn = int(float(i_line['sfn']))
                ini_slot = int(float(i_line['slot']))
                ini_MCS = int(float(i_line['ulFdSchedData.rrmUlUsedMcs']))
                Qm, reserved_MCS = _get_Qm_reservedMCS(i_line, is_DFTsOFDM, ulTransPrecodePi2Bpsk)
                # if reserved MCS < 0: not apply reserved MCS
                HarqProcessIndex = i_line['ulFdSchedData.ulHarqProcessIndex']
                curr_index = list_reader.index(i_line)
                if i_line['ulHarqRxData.dtx'] == 'NON_DTX':
                    ini_DTX = False
                    pre_NACK = True
                elif i_line['ulHarqRxData.dtx'] == 'DTX':
                    ini_DTX = True
                    pre_NACK = False

                # step2: find reTx in curr harq
                for j_line in list_reader_copy[curr_index + 1:]:
                    if (j_line['ulFdSchedData.numOfPrb']):  # not empty
                        re_rnti = j_line['rnti']
                        re_harq = j_line['ulFdSchedData.ulHarqProcessIndex']
                        re_txnumer = int(float(j_line['ulFdSchedData.txNumber']))
                        re_MCS = int(float(j_line['ulFdSchedData.rrmUlUsedMcs']))
                        # curr harq reTx
                        if (re_rnti == rnti) and (re_harq == HarqProcessIndex) and (re_txnumer > 1):
                            for_time += 1
                            re_numPRB = float(j_line['ulFdSchedData.numOfPrb'])

                            # step 3.1
                            # if (ini DTX and the 1st reTx)and(ini NONDTX and not pre_NACK) should be NOTAPPLYDTX
                            if not pre_NACK:
                                if j_line['ulFdSchedData.adaptRetxStatus'] != 'NOTAPPLYDTX':
                                    ERR_Status += 1
                                    print('ERR-adaptRetxStatus|', j_line['sfn'] + '-' + j_line['slot'],
                                          '| expect:NOTAPPLYDTX', 'log:', j_line['ulFdSchedData.adaptRetxStatus'],
                                          '| rnti:' + rnti, "txnum:" + str(re_txnumer))
                                elif j_line['ulFdSchedData.adaptRetxStatus'] == 'NOTAPPLYDTX':
                                    ERR_print = ''
                                    if not (re_numPRB == ini_numPRB):
                                        ERR_print += 'wrong_PRB,'
                                        ERR_PRB += 1
                                    if not (re_MCS == ini_MCS):
                                        ERR_print += 'wrong_MCS'
                                        ERR_MCS += 1
                                    if ERR_print:
                                        print(ERR_print, j_line['sfn'] + '-' + j_line['slot'], 'rnti:' + rnti)
                                    if not ERR_print:
                                        total_pass += 1
                            # step 3.2: if pre_NACK (include ini_NONDTX and ini_DTX)
                            elif pre_NACK:
                                if j_line['ulFdSchedData.adaptRetxStatus'] != 'APPLY':   # reTx must be APPLLY
                                    ERR_Status += 1
                                    print('ERR-adaptRetxStatus|', j_line['sfn'] + '-' + j_line['slot'],
                                          '| expect:APLLY', 'log:', j_line['ulFdSchedData.adaptRetxStatus'],
                                          '| rnti:' + rnti)
                                elif j_line['ulFdSchedData.adaptRetxStatus'] == 'APPLY':    # if APPLY then check PRB
                                    # step3.2_1 :check PRBCand and PRBmin
                                    _ERR_PRBCand, _ERR_PRBmin = _check_PRBCand_PRBmin(
                                            j_line, targetPct, minPct, ini_numPRB)
                                    if _ERR_PRBCand:
                                        ERR_PRBCand += 1
                                    if _ERR_PRBmin:
                                        ERR_PRBmin += 1
                                    if (not _ERR_PRBCand) and (not _ERR_PRBmin):
                                        # step3.2_2 :chek numPRB and reserved MCS
                                        if re_numPRB < ini_numPRB:  # expect reserved MCS
                                            if re_MCS == reserved_MCS:
                                                total_pass += 1
                                            else:
                                                ERR_MCS += 1
                                                print('ERR-reservedMCS|', j_line['sfn'] + '-' + j_line['slot'],
                                                      '| expect:' + str(reserved_MCS) + 'log:' + str(re_MCS),
                                                      '| rnti:' + rnti)
                                        elif re_numPRB == ini_numPRB:   # expect ini MCS
                                            if re_MCS == ini_MCS:
                                                total_pass += 1
                                            else:
                                                ERR_MCS += 1
                                                print('ERR-MCS|', j_line['sfn'] + '-' + j_line['slot'],
                                                      '| expect:' + str(ini_MCS) + 'log:' + str(re_MCS),
                                                      '| rnti:' + rnti)
                                        else:
                                            ERR_PRB += 1
                                            print('ERR:re_PRB>ini_PRB|', j_line['sfn'] + '-' + j_line['slot'],
                                                  '| rnti:' + rnti)
                            # end step 4
                            # pre_Nack false turn to True, not True to False
                            if (not pre_NACK) and (j_line['ulHarqRxData.dtx'] == 'NON_DTX'):
                                pre_NACK = True   # used for next txnumber
                        # go into next turn of this processIndex, break.
                        if (re_rnti == rnti) and (re_harq == HarqProcessIndex) and (re_txnumer == 1):
                            break
                        # end curr harq
                # end for j_line
        # end for i_line
    print('---------check result---------')
    print('crc_missing:', crc_missing)
    print('data_missing:', data_missing)
    print('for_time:\t', for_time)
    print('ERR_status:\t', ERR_Status)
    print('ERR_MCS:\t', ERR_MCS)
    print('ERR_PRB:\t', ERR_PRB)
    print('ERR_PRBCand:\t', ERR_PRBCand)
    print('ERR_PRBmin:\t', ERR_PRBmin)
    print('total_pass:\t', total_pass)
    if ERR_MCS or ERR_PRB or ERR_PRBCand or ERR_PRBmin or ERR_Status or (crc_missing > 100) or (data_missing > 100):
        print('Fail')
        raise Exception('Fail')
    else:
        print('Pass')

# check_reTx_status_and_reservedMCS('tti_B_case33_ul.csv', 0.75, 0.5)
# check_reTx_status_and_reservedMCS('tti_4R1_bler_ul_case29.csv', 0.8, 0.5)
# check_reTx_status_and_reservedMCS('tti_adapV2_ul.csv', 0.5, 0.5)
# check_reTx_status_and_reservedMCS('tti_bler_case45_ul.csv', 1, 0.5)
# check_reTx_status_and_reservedMCS('tti_bler_case41_ul.csv', 0.75, 0.5)
# check_reTx_status_and_reservedMCS('tti_B_case33_ul_knife.csv', 0.75, 0.5, 0)
# check_reTx_status_and_reservedMCS('tti_US3_ul.csv', 0.75, 0.7, 1)
# check_reTx_status_and_reservedMCS('tti3_targetPct75_4ue_ul_Reorder.csv', 0.75, 0.5)
# check_reTx_status_and_reservedMCS ('tti_B_case33_ul.csv', 0.75,0.5)
# check_reTx_status_and_reservedMCS ('tti_B_case33_ul_3.csv', 0.75,0.5)
