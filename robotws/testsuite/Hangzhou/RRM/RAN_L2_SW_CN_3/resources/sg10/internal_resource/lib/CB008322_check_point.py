import csv
import math
import tarfile
import re
import shutil
import os


proposedMCS_SE_table_256QAM = [
    {'MCS': 0, 'SE': 0.2344},
    {'MCS': 1, 'SE': 0.377},
    {'MCS': 2, 'SE': 0.6016},
    {'MCS': 3, 'SE': 0.877},
    {'MCS': 4, 'SE': 1.1758},
    {'MCS': 5, 'SE': 1.4766},
    {'MCS': 6, 'SE': 1.6953},
    {'MCS': 7, 'SE': 1.9141},
    {'MCS': 8, 'SE': 2.1602},
    {'MCS': 9, 'SE': 2.4063},
    {'MCS': 10, 'SE': 2.5703},
    {'MCS': 11, 'SE': 2.7305},
    {'MCS': 12, 'SE': 3.0293},
    {'MCS': 13, 'SE': 3.3223},
    {'MCS': 14, 'SE': 3.6094},
    {'MCS': 15, 'SE': 3.9023},
    {'MCS': 16, 'SE': 4.2129},
    {'MCS': 17, 'SE': 4.5234},
    {'MCS': 18, 'SE': 4.8164},
    {'MCS': 19, 'SE': 5.1152},
    {'MCS': 20, 'SE': 5.332},
    {'MCS': 21, 'SE': 5.5547},
    {'MCS': 22, 'SE': 5.8906},
    {'MCS': 23, 'SE': 6.2266},
    {'MCS': 24, 'SE': 6.5703},
    {'MCS': 25, 'SE': 6.9141},
    {'MCS': 26, 'SE': 7.1602},
    {'MCS': 27, 'SE': 7.4063}
]
proposedMCS_SE_table_64QAM = [
    {'MCS': 0, 'SE': 0.2344},
    {'MCS': 1, 'SE': 0.3066},
    {'MCS': 2, 'SE': 0.3700},
    {'MCS': 3, 'SE': 0.4902},
    {'MCS': 4, 'SE': 0.6016},
    {'MCS': 5, 'SE': 0.7402},
    {'MCS': 6, 'SE': 0.877},
    {'MCS': 7, 'SE': 1.0273},
    {'MCS': 8, 'SE': 1.1758},
    {'MCS': 9, 'SE': 1.3262},
    {'MCS': 10, 'SE': 1.3281},
    {'MCS': 11, 'SE': 1.4766},
    {'MCS': 12, 'SE': 1.6953},
    {'MCS': 13, 'SE': 1.9141},
    {'MCS': 14, 'SE': 2.1602},
    {'MCS': 15, 'SE': 2.4063},
    {'MCS': 16, 'SE': 2.5703},
    {'MCS': 17, 'SE': 2.5664},
    {'MCS': 18, 'SE': 2.7305},
    {'MCS': 19, 'SE': 3.0293},
    {'MCS': 20, 'SE': 3.3223},
    {'MCS': 21, 'SE': 3.6094},
    {'MCS': 22, 'SE': 3.9023},
    {'MCS': 23, 'SE': 4.2129},
    {'MCS': 24, 'SE': 4.5234},
    {'MCS': 25, 'SE': 4.8164},
    {'MCS': 26, 'SE': 5.1152},
    {'MCS': 27, 'SE': 5.332},
    {'MCS': 28, 'SE': 5.5547}
]


def get_SE(proposedMCS, table=proposedMCS_SE_table_256QAM):
    for i in table:
        if i['MCS'] == proposedMCS:
            return i['SE']
    print('not find input MCS:', proposedMCS)


def merge_csv(*csv_files):
    list_reader = []
    for i in range(len(csv_files)):
        with open(csv_files[i], 'r') as file1:
            csv_reader1 = csv.reader(file1)
            data1 = [row for row in csv_reader1]
            if i > 0:   # 从第二个文件开始去掉首行
                data1 = data1[1:]
            list_reader = list_reader + data1
    # 将合并后的数据写入新的CSV文件
    file_path = os.path.abspath(csv_files[0])
    # print(file_path)
    if '\\' in file_path:   # 找到斜杠或反斜杠
        flag = '\\'
    elif '/' in file_path:
        flag = '/'
    for i in range(len(file_path)):
        if file_path[i] == flag:
            index = i
    up_path = file_path[:index + 1]
    output_file = up_path + 'merged_file.csv'
    # print(output_file)

    with open(output_file, 'w', newline='') as merged_file:
        csv_writer = csv.writer(merged_file)
        csv_writer.writerows(list_reader)

    print('合并完成，新的CSV文件已生成', output_file)

    with open('merged_file.csv', 'r') as infile:
        list_merge = list(csv.DictReader(infile))
    return list_merge

# merge_csv('merge1.csv', 'merge2.csv', 'merge3.csv')


def _get_pdsch_for_curr_bwv(curr_numBwv_sfn, curr_numBwv_slot):
    # delay=frhdelay+1+delay(l1-UP)=5+1+(反推经验值4)=10个slot开始才是当前bwv调度的pdsch
    delay = 10
    q = (curr_numBwv_slot + 10) // 20  # 商
    r = (curr_numBwv_slot + 10) % 20  # 余数
    # get pdsch for curr_numBwv
    schdule_pdsch_sfn = (curr_numBwv_sfn + q) % 1024
    schdule_pdsch_slot = r
    return schdule_pdsch_sfn, schdule_pdsch_slot


def check_numBwvPerSubban_unequal_to_PdschLayers_beam_fallback(filename):
    '''
    Author: Zhangshuang
    function: check point for CB008322_B2_case12
    input: csv from bip.
    '''
    RT_fall_back = False
    csi_pass = True
    target_ERR = False
    with open(filename, 'r') as infile:
        list_reader = list(csv.DictReader(infile))
        curr_numBwv = ''
        last_numBwv = ''
        numBwv_change = False
        # step1: check csi patternid, should use RT beam all the time
        for i_line in list_reader:
            if i_line['DlData_CsiRsResourceL1sw_t.csiRsConfig'].startswith('4'):
                if int(i_line['DlData_CsiRsResourceL1sw_t.patternId_item'][:4]) > 1430:
                    pass
                else:
                    print(i_line['3gpp.sfn'] +
                          '-' +
                          i_line['3gpp.slot'], 'ERR:csi-rs not using RT beam!')
                    csi_pass = False
                    break   # once err break
        # step2.1: find curr bwv and its pdsch start time
        for i_line in list_reader:
            if i_line['UlData_srsBwvReport_t.numBwvPerSubband']:  # get curr_numBwv
                if curr_numBwv:
                    last_numBwv = curr_numBwv
                curr_numBwv = i_line['UlData_srsBwvReport_t.numBwvPerSubband']
                curr_numBwv_sfn = int(i_line['3gpp.sfn'])
                curr_numBwv_slot = int(i_line['3gpp.slot'])
                # get pdsch start time for curr_numBwv
                curr_bwv_pdsch_sfn, curr_bwv_pdsch_slot = _get_pdsch_for_curr_bwv(
                    curr_numBwv_sfn, curr_numBwv_slot)
                if (curr_numBwv != last_numBwv) and last_numBwv:
                    numBwv_change = True
                    print(
                        'bwv_change:',
                        last_numBwv, '-',
                        curr_numBwv,
                        i_line['3gpp.sfn'] +
                        '-' +
                        i_line['3gpp.slot'])
                    index_numBwv_change = list_reader.index(i_line)
                    print(
                        'curr_bwv_pdsch_Start:',
                        curr_bwv_pdsch_sfn,
                        '-',
                        curr_bwv_pdsch_slot)
                    break
                else:
                    numBwv_change = False
        if not numBwv_change:
            print("WRN: no numBwv change.")
            raise Exception("Fail")
        # step2.2: find next bwv and its pdsch start time
        for i_line in list_reader[index_numBwv_change + 1:]:
            if i_line['UlData_srsBwvReport_t.numBwvPerSubband']:  # next bwv
                next_bwv_sfn = int(i_line['3gpp.sfn'])
                next_bwv_slot = int(i_line['3gpp.slot'])
                next_bwv_pdsch_sfn, next_bwv_pdsch_slot = _get_pdsch_for_curr_bwv(
                    next_bwv_sfn, next_bwv_slot)
                print(
                    'next_bwv_pdsch_time:',
                    next_bwv_pdsch_sfn,
                    '-',
                    next_bwv_pdsch_slot)
                break

        # step2.3 [curr bwv_pdsch start: next bwv_pdsch start)之间判断
        # numbwv!=layers
        for i_line in list_reader[index_numBwv_change + 1:]:
            if i_line['DlData_PdschGrantL1sw.patternId_item']:  # 有pdsch调度
                pdsch_sfn = int(i_line['3gpp.sfn'])
                pdsch_slot = int(i_line['3gpp.slot'])

                # 进入next bwv调度的pdsch则break
                if (pdsch_sfn == next_bwv_pdsch_sfn and pdsch_slot >= next_bwv_pdsch_slot) or (
                        pdsch_sfn > next_bwv_pdsch_sfn):
                    break
                # curr bwv 的pdsch开始
                elif (pdsch_sfn == curr_bwv_pdsch_sfn and pdsch_slot >= curr_bwv_pdsch_slot) or (
                        pdsch_sfn > curr_bwv_pdsch_sfn):
                    if curr_numBwv != i_line['DlData_PdschGrantL1sw.numOfLayers']:
                        if i_line['DlData_PdschGrantL1sw.patternId_item'].startswith(
                                '1'):
                            RT_fall_back = True
                            print(
                                '(^_^) Hit target fallaback DFT due to numBwv != layers|',
                                str(pdsch_sfn) + '-' +
                                str(pdsch_slot), 'numBwv=' + curr_numBwv,
                                'pdsch layers=' + i_line['DlData_PdschGrantL1sw.numOfLayers'])
                        else:
                            print(
                                'ERR: fall back to DFT expected, but got patternid:',
                                i_line['DlData_PdschGrantL1sw.patternId_item'],
                                str(pdsch_sfn) + '-' + str(pdsch_slot),
                                'numBwv=' + curr_numBwv,
                                'pdsch layers=' + i_line['DlData_PdschGrantL1sw.numOfLayers'])
                            target_ERR = True
                            break
        # end for
        # if target US not happen during the whole list_reader:
        if not RT_fall_back:
            print('ERR: RT_fall_back not pappend!')
        if csi_pass and RT_fall_back and (not target_ERR):
            print('pass')
        else:
            print('fail')
            raise Exception("Fail")

# check_numBwvPerSubban_unequal_to_PdschLayers_beam_fallback('bip_8322_0_43.csv)


# ------8322_B2_case8_check point:-----
def is_Rlq_Bad(i_line, rdNumSrsCheck, rdSrsRlqBadPercent):
    if i_line['srsState'] == "'WBSRS'":
        numOfSrsRlqCheck = int(i_line['numOfSrsRlqCheck'])
        if numOfSrsRlqCheck == rdNumSrsCheck:
            sampleRlqBad = int(i_line['sampleRlqBad'])
            RlqBadPercent = sampleRlqBad / numOfSrsRlqCheck * 100
            if RlqBadPercent >= rdSrsRlqBadPercent:
                print('Hit bad RLQ trigger SRS switch:', i_line['sfn'] + '-' + i_line['slot'])
                return True
    return False


def _find_bad_SE(list_reader, bad_SE_thd, rdNumSrsCheck, rdSrsRlqBadPercent):
    for i_line in list_reader:
        if i_line['srsState']:
            if int(i_line['spectrumEfficiencyM100']
                   ) < bad_SE_thd and i_line['sampleRlqBad'] == '1':
                index_bad_SE = list_reader.index(i_line)
                print(
                    'Hit bad SE and RLQ:',
                    i_line['sfn'] +
                    '-' +
                    i_line['slot'])
    if not index_bad_SE:
        print('ERR: not find bad SE.')
        return False
    for i_line in list_reader[index_bad_SE:]:
        if is_Rlq_Bad(i_line, rdNumSrsCheck,
                      rdSrsRlqBadPercent):  # if hit bad Rlq
            index_bad_RLQ_due_to_SE = list_reader.index(i_line)
            return index_bad_RLQ_due_to_SE
    print('ERR: no bad RLQ.')
    return False


def _find_bad_Ri(list_reader, bad_Rank_thd, rdNumSrsCheck, rdSrsRlqBadPercent):
    # find bad ri
    for i_line in list_reader:
        # csiReport.cqi=255.0时不是有效的ri
        find_bad_ri = False
        if i_line['csiSrReportData.csiReport.ri'] and (
                float(i_line['csiSrReportData.csiReport.cqi']) < 255):
            if float(i_line['csiSrReportData.csiReport.ri']) + \
                    1 <= bad_Rank_thd:
                print(
                    'Hit bad Ri: ri=' +
                    i_line['csiSrReportData.csiReport.ri'],
                    i_line['sfn'] +
                    '-' +
                    i_line['slot'])
                index_bad_ri = list_reader.index(i_line)
                find_bad_ri = True
                break
    if not find_bad_ri:
        print('ERR: not find bad ri.')
        return False
    if index_bad_ri:
        # find bad ri 后的第一次RlqBadPercent>rdSrsRlqBadPercent
        for i_line in list_reader[index_bad_ri:]:
            if is_Rlq_Bad(i_line, rdNumSrsCheck,
                          rdSrsRlqBadPercent):     # if hit bad Rlq
                index_bad_RLQ_due_to_Ri = list_reader.index(i_line)
                return index_bad_RLQ_due_to_Ri
        print('ERR: no bad RLQ find')
        return False
    else:
        print('no bad ri.')
        return False


def _srsEpreLinear_to_dbm(
        srsEpreLinear, CellSetupReq_gainCorrection, rxScalingFactorEcpriDbm=-152):
    rrmSrsPower_relative = 10 * math.log10(srsEpreLinear)
    rrmSrsPower_dbm = rrmSrsPower_relative + \
        rxScalingFactorEcpriDbm - CellSetupReq_gainCorrection / 10
    return rrmSrsPower_dbm


def _find_bad_power(list_reader, bad_power_thd_dbm,
                    CellSetupReq_gainCorrection, rdNumSrsCheck, rdSrsRlqBadPercent):
    # to be confirm how to convert dbm to liner
    for i_line in list_reader:
        if i_line['srsState'] == "'WBSRS'" and i_line['srsEpreLinear']\
                and i_line['srsEpreLinear'] != '0':
            '''
            rrmSrsPower_dbm = _srsEpreLinear_to_dbm(
                float(i_line['srsEpreLinear']), CellSetupReq_gainCorrection)
            if rrmSrsPower_dbm < bad_power_thd_dbm:   # 应该bad RLQ
                print(
                    'rrmSrsPower_dbm:',
                    rrmSrsPower_dbm,
                    '< bad power thd=',
                    bad_power_thd_dbm)
            '''
            if float(i_line['srsEpreLinear']) < float(i_line['srsEpreLinearThd']):
                print(
                    'srsEpreLinear < srsEpreLinearThd:',
                    i_line['srsEpreLinear'],
                    '<',
                    i_line['srsEpreLinearThd'])
                if int(i_line['sampleRlqBad']) > 0:
                    print(
                        'Hit bad power, bad RLQ:',
                        i_line['sfn'] + '-' + i_line['slot'])
                    index_bad_power = list_reader.index(i_line)
                    break
                else:
                    print(
                        'ERR: srsEpreLinear < srsEpreLinearThd, sampleRlqBad is expected, but not.',
                        i_line['sfn'] + '-' + i_line['slot'])
                    raise Exception('Fail')
    if not index_bad_power:
        print('ERR: not find bad power.')

    for i_line in list_reader[index_bad_power:]:
        if is_Rlq_Bad(i_line, rdNumSrsCheck,
                      rdSrsRlqBadPercent):  # if hit bad Rlq
            index_bad_RLQ_due_to_power = list_reader.index(i_line)
            return index_bad_RLQ_due_to_power
    print('ERR: no bad RLQ find')
    return False


def _find_bad_corr(
        list_reader, bad_corr_thd, rdNumSrsCheck, rdSrsRlqBadPercent):
    # find 1st bad corr
    for i_line in list_reader:
        if i_line['srsState'] == "'WBSRS'":
            corr = int(i_line['corrSquareM10000'])  # 平方 x 10000
            if corr > 0 and corr < (bad_corr_thd / 100) ** 2 * 10000:
                if int(i_line['sampleRlqBad']) < 1:
                    print(
                        'ERR: Hit bad corr,sampleRlqBad expected but not',
                        i_line['sfn'] + '-' + i_line['slot'])
                    raise Exception('Fail')
                else:
                    print('Hit bad corr', i_line['sfn'] + '-' + i_line['slot'])
                    index_1st_bad_corr = list_reader.index(i_line)
                    break
    # find bad rlq percent
    for i_line in list_reader[index_1st_bad_corr:]:
        if is_Rlq_Bad(i_line, rdNumSrsCheck, rdSrsRlqBadPercent):
            index_bad_Rlq_due_to_corr = list_reader.index(i_line)
            return index_bad_Rlq_due_to_corr
    print('ERR: No bad Rlq due to corr')
    return False


def check_tti_single_UE_bad_RLQ(
        split_tti_filename, target, rdNumSrsCheck=10, rdSrsRlqBadPercent=50, rdSrsBufPercent=60, gainCorrection=12,
        bad_SE_thd=410, bad_Rank_thd=1, bad_power_thd_dbm=-106, bad_corr_thd=50):
    '''
    Author: Zhang Shuang
    tti_filename: tti_dl_after split 8322
    bad_SE_thd: defalt=610
    taret='SE'/'ri'/'corr'/'power'
    function: CB008322_B2_case8: set cqi from 15 to 4: WBSRS-SBSRS;RT-DFT;TWB=80
    '''
    print('gainCorrection:', gainCorrection)
    rdNumSrsCheck = int(rdNumSrsCheck)
    rdSrsRlqBadPercent = int(rdSrsRlqBadPercent)
    rdSrsBufPercent = int(rdSrsBufPercent)
    gainCorrection = int(gainCorrection)
    bad_SE_thd = int(bad_SE_thd)
    bad_Rank_thd = int(bad_Rank_thd)
    bad_power_thd_dbm = float(bad_power_thd_dbm)
    bad_corr_thd = int(bad_corr_thd)
    with open(split_tti_filename, 'r') as infile:
        list_reader = list(csv.DictReader(infile))

        # 1 find bad condition(trigger point)
        if target == 'ri':  # find bad Rank
            index_bad_RLQ = _find_bad_Ri(
                list_reader,
                bad_Rank_thd,
                rdNumSrsCheck,
                rdSrsRlqBadPercent)
        elif target == 'SE':      # 1.1.1:find the bad RLQ smple
            index_bad_RLQ = _find_bad_SE(
                list_reader, bad_SE_thd, rdNumSrsCheck, rdSrsRlqBadPercent)
        elif target == 'power':
            index_bad_RLQ = _find_bad_power(
                list_reader, bad_power_thd_dbm, gainCorrection, rdNumSrsCheck, rdSrsRlqBadPercent)
        elif target == 'corr':
            index_bad_RLQ = _find_bad_corr(
                list_reader, bad_corr_thd, rdNumSrsCheck, rdSrsRlqBadPercent)

        if not index_bad_RLQ:
            print('ERR: no target US:', target)
            raise Exception('Fail')

        # 1.2:bad_RLQ后的第一个SRSstate 应该立即进入过渡态
        for i_line in list_reader[index_bad_RLQ + 1:]:
            if i_line['srsState']:
                if i_line['srsState'] == "'WBTOSBSRS'":
                    index_WB_SB_start = list_reader.index(i_line)
                    print('Hit WB_SB:', i_line['sfn'] + '-' + i_line['slot'])
                    # SRSstate_check = True
                    break
                else:
                    print(
                        '---ERR: bad RLQ, but no WB_to_SB---',
                        i_line['sfn'] + '-' + i_line['slot'])
                    # SRSstate_check = False
                    raise Exception('Fail')

        # 1.3:第一个过渡态之后，找过渡态结束的第一个SB_SRS
        for i_line in list_reader[index_WB_SB_start + 1:]:
            if i_line['srsState'] == "'SBSRS'":
                print(
                    'Switch to SB SRS complete:',
                    i_line['sfn'] + '-' + i_line['slot'])
                index_1st_SBSRS = list_reader.index(i_line)
                sfn_first_SB_SRS = i_line['sfn']
                slot_first_SB_SRS = i_line['slot']
                break
        if not index_1st_SBSRS:
            print('ERR: not switch to SB SRS.')
            raise Exception('Fail')

        # check RT fall back to DFT
        find_beam_fall_back = False
        last_beam_type = '-'
        for i_line in list_reader:
            curr_beam_type = i_line['dlFdSchedData.beamType']
            if curr_beam_type:
                if curr_beam_type.startswith('DFT') and last_beam_type == 'SUBBAND':
                    print('beam fall back: RT——DFT,', i_line['sfn'] + '-' + i_line['slot'],
                          'rtBeamFailureReason:', i_line['dlFdSchedData.rtBeamFailureReason'])
                    find_beam_fall_back = True
                    break
                else:
                    last_beam_type = curr_beam_type

        if find_beam_fall_back:
            print('pass\n')
        else:
            print('ERR: no beam fall back')
            raise Exception('Fail')


'''
check_tti_single_UE_bad_RLQ(
    'tti_UE11_cqi_4_dl_split.csv',
    target='SE',
    rdNumSrsCheck=5,
    rdSrsRlqBadPercent=50,
    rdSrsBufPercent=60)

check_tti_single_UE_bad_RLQ(
    'tti_UE11_rank42_dl_split.csv',
    target='ri',
    rdNumSrsCheck=5,
    rdSrsRlqBadPercent=50,
    rdSrsBufPercent=60)

check_tti_single_UE_bad_RLQ(
    'tti_UE11_power_bad_dl_split.csv',
    target='power',
    rdNumSrsCheck=5,
    rdSrsRlqBadPercent=50,
    rdSrsBufPercent=60,
    gainCorrection=12,
    bad_power_thd_dbm=-95)

check_tti_single_UE_bad_RLQ(
    'tti_case10_dl_split.csv',
    target='corr',
    rdNumSrsCheck=5,
    bad_corr_thd=50,
    rdSrsRlqBadPercent=10)
'''


def _get_L3Timer_out_from_syslog(tar_filename, switch_sfn, switch_slot):
    tar = tarfile.open(tar_filename)
    name = tar.getnames()
    # print('name:', name)
    path = './tmp/'
    if os.path.exists(path):
        shutil.rmtree(path)
    tar.extractall(path)

    # 取解压后的name列表的第一个文件
    syslog_name = path + name[0]
    with open(syslog_name, 'r') as infile:
        list_reader = infile.readlines()
        list_reader_cp = list_reader.copy()
        for i_line in list_reader:
            if 'reason WIDEBAND' in i_line:
                index_reason_WIDBAN = list_reader.index(i_line)
                # print(i_line)
                for j_line in list_reader_cp[index_reason_WIDBAN + 1:]:
                    if 'srsToL3Timer time out' in j_line:    # 找到reason WIDBAND后面紧邻的srsToL3Timer time out
                        # print(j_line)
                        L3Timer_timeout_sfn_slot = re.findall(
                            'slot:\\[(\\d+)/(\\d+)\\]', j_line)
                        # findall的结果是一个元组列表
                        L3_timeout_sfn = int(L3Timer_timeout_sfn_slot[0][0])
                        L3_timeout_slot = int(L3Timer_timeout_sfn_slot[0][1])
                        L3_time = L3_timeout_sfn * 20 + L3_timeout_slot
                        switch_time = switch_sfn * 20 + switch_slot
                        delta = switch_time - L3_time
                        if delta > 0 and delta < 20:
                            print('(^_^)Hit nearest L3timer time out at:', L3_timeout_sfn,
                                  '-',
                                  L3_timeout_slot)
                            return L3_timeout_sfn, L3_timeout_slot


def is_high_buffer_and_goodRlq(
        i_line, rdNumSrsCheck, rdSrsRlqGoodPercent, rdSrsBufPercent):
    if i_line['srsState'] == "'SBSRS'":
        numOfSrsRlqCheck = int(i_line['numOfSrsRlqCheck'])
        numOfDlTrafficCheck = int(i_line['numOfDlTrafficCheck'])
        if (numOfSrsRlqCheck >= rdNumSrsCheck) and (
                numOfDlTrafficCheck >= rdNumSrsCheck):
            sampleRlqGood = int(i_line['sampleRlqGood'])
            sampleDlTrafficHi = int(i_line['sampleDlTrafficHi'])
            RlqGoodPercent = sampleRlqGood / numOfSrsRlqCheck * 100
            bufferHighPercent = sampleDlTrafficHi / numOfSrsRlqCheck * 100
            if (RlqGoodPercent >= rdSrsRlqGoodPercent) and (
                    bufferHighPercent >= rdSrsBufPercent):
                print(
                    'Hit Good RLQ and High Buffer', i_line['rnti_'],
                    i_line['sfn'] + '-' + i_line['slot'], i_line['volatilityStatus'])
                return True
    return False


def check_SB_to_WB_tti(split_tti_filename, syslog_tar_file, rdNumSrsCheck=10, rdSrsRlqGoodPercent=20,
                       rdSrsBufPercent=60, good_SE_thd=910, good_Rank_thd=3, good_power_thd_dbm=-90):
    '''
        Author: Zhang Shuang
        tti_filename: tti_dl_after split 8322
        good_power_thd_dbm:defaut=-120, set -90 in case8,9
        taret='SE'/'ri'/'corr'/'power' the same US and check steps
        function: CB008322_B2_case8,9:  SB-WB; DFT--RT
        '''
    rdNumSrsCheck = int(rdNumSrsCheck)
    rdSrsRlqGoodPercent = int(rdSrsRlqGoodPercent)
    rdSrsBufPercent = int(rdSrsBufPercent)
    good_SE_thd = int(good_SE_thd)
    good_Rank_thd = int(good_Rank_thd)
    good_power_thd_dbm = float(good_power_thd_dbm)

    with open(split_tti_filename, 'r') as infile:
        list_reader = list(csv.DictReader(infile))
        # step1: find SB-WB Switch point
        for i_line in list_reader:
            if i_line['srsState']:
                if i_line['srsState'] == "'SBTOWBSRS'":
                    index_SB_WB = list_reader.index(i_line)
                    print(
                        'Hit SB to WB switch:',
                        i_line['sfn'] + '-' + i_line['slot'])
                    switch_sfn = int(i_line['sfn'])
                    switch_slot = int(i_line['slot'])
                    # syslog_tar_file = 'UE11_US1_gnb.tar.gz'
                    L3Timer_out_sfn, L3Timer_out_slot = _get_L3Timer_out_from_syslog(
                        syslog_tar_file, switch_sfn, switch_slot)
                    L3Timer_out_time = L3Timer_out_sfn * 20 + L3Timer_out_slot
                    break
        if not index_SB_WB:
            print('ERR: no SB_WB switch')
            raise Exception('Fail')

        # step2: find the latest srsState before L3Timer time out,shall be hi buffer and good RLQ
        # maybe change after-G(checknumber=10)
        find_high_buff_and_good_Rlq = False
        for i_line in list_reader[index_SB_WB - 1::-1]:
            if i_line['srsState']:
                srsState_sfn = int(i_line['sfn'])
                srsState_slot = int(i_line['slot'])
                if (1024 - srsState_sfn) < 10:
                    srsState_sfn = srsState_sfn - 1024
                srsState_time = srsState_sfn * 20 + srsState_slot
                if srsState_time <= L3Timer_out_time:
                    if is_high_buffer_and_goodRlq(
                            i_line, rdNumSrsCheck, rdSrsRlqGoodPercent, rdSrsBufPercent):
                        find_high_buff_and_good_Rlq = True
                        break
        if not find_high_buff_and_good_Rlq:
            print(
                'ERR: not hi_buffer or good_RLQ before SB_to_WB switch point:',
                i_line['sfn'] + '-' + i_line['slot'])
            raise Exception('Fail')

        # step3: find the 1st WB SRS after switch
        for i_line in list_reader[index_SB_WB + 1:]:
            if i_line['srsState']:
                if i_line['srsState'] == "'WBSRS'":
                    print(
                        '1st WB SRS after switch:',
                        i_line['sfn'] + '-' + i_line['slot'])
                    index_1st_WB_SRS = list_reader.index(i_line)
                    break
        if not index_1st_WB_SRS:
            print('ERR: not switch to WB SRS successfully.')
            raise Exception('Fail')

        # step4:find the 1st RT beam after WB SRS config complete
        for i_line in list_reader[index_1st_WB_SRS + 1:]:
            if i_line['dlFdSchedData.beamType']:
                if i_line['dlFdSchedData.beamType'] == 'SUBBAND':
                    print(
                        '1st SUBBAND beam after switch:',
                        i_line['sfn'] + '-' + i_line['slot'])
                    index_1st_SUBBAND_beam = list_reader.index(i_line)
                    break
        if not index_1st_SUBBAND_beam:
            print('ERR: no SUBBAND beam after switch to WB SRS.')
            raise Exception('Fail')

        # step5: 1st SUBBAND beam之前的一段（此处取100行）时间应为DFT
        check_DFT_beam = False
        for i_line in list_reader[index_1st_SUBBAND_beam -
                                  100:index_1st_SUBBAND_beam]:
            if i_line['dlFdSchedData.beamType']:
                if not i_line['dlFdSchedData.beamType'].startswith('DFT'):
                    print(
                        'ERR: DFT expected before switch to WB SRS, but got',
                        i_line['dlFdSchedData.beamType'])
                    raise Exception('Fail')
                else:
                    check_DFT_beam = True

        # step6: 1st SUBBAND 及之后的一段时间（此处取100行）时间应为SUBBAND
        check_SUBBAND_beam = False
        for i_line in list_reader[index_1st_SUBBAND_beam:index_1st_SUBBAND_beam + 100]:
            if i_line['dlFdSchedData.beamType']:
                if i_line['dlFdSchedData.beamType'] != 'SUBBAND':
                    print(
                        'ERR: SUBBAND beam expected after switch to WB SRS, but got',
                        i_line['dlFdSchedData.beamType'])
                    raise Exception('Fail')
                else:
                    check_SUBBAND_beam = True
        if check_DFT_beam and check_SUBBAND_beam:
            print('-----SB to WB: pass-----')


'''
check_SB_to_WB_tti(
    'tti_buffer_lo_2_hi_dl_split.csv',
    'UE11_US1_gnb.tar.gz',
    rdNumSrsCheck=5,
    rdSrsBufPercent=60,
    rdSrsRlqGoodPercent=60)
'''


def _get_Bwv_available_pdsch_end_time(
        bwv_sfn, bwv_slot, WBSRS_period=80, rdSubbandBeamAgingConstant=5):
    if WBSRS_period < 160:
        rrmSubbandBeamAging = WBSRS_period * 2 + rdSubbandBeamAgingConstant
    else:
        rrmSubbandBeamAging = WBSRS_period + rdSubbandBeamAgingConstant
    avai_bwv_pdsch_start_sfn, avai_bwv_pdsch_start_slot = _get_pdsch_for_curr_bwv(
        bwv_sfn, bwv_slot)
    q = rrmSubbandBeamAging // 20
    r = rrmSubbandBeamAging % 20
    avai_bwv_pdsch_end_sfn = (avai_bwv_pdsch_start_sfn + q) % 1024
    avai_bwv_pdsch_end_slot = avai_bwv_pdsch_start_slot + r - 1
    return avai_bwv_pdsch_end_sfn, avai_bwv_pdsch_end_slot


def _is_DFT(DlData_PdschGrant_patternId_item):
    index_ = DlData_PdschGrant_patternId_item.index(',')
    startPatternid = int(DlData_PdschGrant_patternId_item[:index_])
    if startPatternid < 5000 and startPatternid >= 1054:
        return True
    return False


def check_RT_beam_aging_in_bip(bip_csv_path, WB_SRS_period, rdSubbandBeamAgingConstant=5):
    # if bwv failure, use the latest valid bwv(result=OK)
    WB_SRS_period = int(WB_SRS_period)
    rdSubbandBeamAgingConstant = int(rdSubbandBeamAgingConstant)
    with open(bip_csv_path, 'r') as infile:
        list_reader = list(csv.DictReader(infile))

        # step1: find the 1st failure=1 (only bad power US  can failure exist)
        find_failure = False
        for i_line in list_reader:
            if i_line['UlData_srsBwvReport_t.result'].startswith('1'):
                failure_patternid = i_line['UlData_srsBwvReport_t.startPatternId']
                print('1st_failure_id:', failure_patternid)
                print(
                    '1st result failure:',
                    i_line['3gpp.sfn'] +
                    '-' +
                    i_line['3gpp.slot'])
                index_failure = list_reader.index(i_line)
                find_failure = True
                break
        if not find_failure:
            print('INF: no failure bwv found.')
            index_failure = 0

        # step 2: find the last OK bwv
        find_last_OK = False
        for i_line in list_reader[-1::-1]:
            if i_line['UlData_srsBwvReport_t.result']:
                if i_line['UlData_srsBwvReport_t.result'].startswith('0'):
                    last_OK_startPatternId = i_line['UlData_srsBwvReport_t.startPatternId']
                    last_OK_sfn = int(i_line['3gpp.sfn'])
                    last_OK_slot = int(i_line['3gpp.slot'])
                    index_last_OK = list_reader.index(i_line)
                    print('last_OK_bwv:', last_OK_sfn, '-', last_OK_slot)
                    last_OK_pdsch_end_sfn, last_OK_pdsch_end_slot = _get_Bwv_available_pdsch_end_time(
                        last_OK_sfn, last_OK_slot, WB_SRS_period, rdSubbandBeamAgingConstant)
                    print(
                        'last_OK_pdsch_end_time:',
                        last_OK_pdsch_end_sfn,
                        '-',
                        last_OK_pdsch_end_slot)
                    find_last_OK = True
                    break
        if not find_last_OK:
            print('ERR: not find last bwv OK.')
            raise Exception('Fail')
        print('----------')

        # step3: 定位第一个DFT
        last_OK_pdsch_end_time = last_OK_pdsch_end_sfn * 20 + last_OK_pdsch_end_slot
        for i_line in list_reader[index_last_OK + 1:]:
            if i_line['3gpp.rnti'] != '65535' and i_line['DlData_PdschGrantL1sw.patternId_item']:
                curr_sfn = int(i_line['3gpp.sfn'])
                curr_slot = int(i_line['3gpp.slot'])
                curr_time = curr_sfn * 20 + curr_slot
                if curr_time > last_OK_pdsch_end_time:
                    if not _is_DFT(i_line['DlData_PdschGrantL1sw.patternId_item']):
                        print(
                            'ERR: DFT beam expected after last_OK_pdsch_end_time but got patternid:',
                            i_line['DlData_PdschGrantL1sw.patternId_item'],
                            i_line['3gpp.sfn'] + '-' + i_line['3gpp.slot'])
                        raise Exception('Fail')
                    else:
                        index_1st_DFT = list_reader.index(i_line)
                        print(
                            'find the 1st DFT:',
                            i_line['3gpp.sfn'] +
                            '-' +
                            i_line['3gpp.slot'])
                    break

        # step4: check RT
        check_RT = False
        for i_line in list_reader[:index_1st_DFT]:
            if i_line['DlData_PdschGrantL1sw.patternId_item'] and (i_line['3gpp.rnti'] != '65535'):
                if not i_line['DlData_PdschGrantL1sw.patternId_item'].startswith(
                        '5'):
                    print(
                        'ERR: before index_last_OK_pdsch_end, RT beam expected but got patternid:',
                        i_line['DlData_PdschGrantL1sw.patternId_item'], i_line['3gpp.sfn'] + '-' + i_line['3gpp.slot'])
                    raise Exception('Fail')
                else:
                    check_RT = True

        # step5: check DFT
        check_DFT = False
        for i_line in list_reader[index_1st_DFT:]:
            if i_line['DlData_PdschGrantL1sw.patternId_item'] and (i_line['3gpp.rnti'] != '65535'):
                if not _is_DFT(i_line['DlData_PdschGrantL1sw.patternId_item']):
                    print(
                        'ERR: DFT beam expected but got patternid:',
                        i_line['DlData_PdschGrantL1sw.patternId_item'],
                        i_line['3gpp.sfn'] + '-' + i_line['3gpp.slot'])
                    raise Exception('Fail')
                else:
                    check_DFT = True

        if check_RT and check_DFT:
            print('-----Pass-----')
        else:
            raise Exception('Fail')

# check_RT_beam_aging_in_bip('bip_5_power_bad_0.csv', 20)


def get_gainCorrrection_from_sys_before_onair(
        sys_before_onair_filename='${TEST_LOG_DIRECTORY()}/All/syslog_before_onair/before_onair_gnb.tar.gz'):
    '''
    :param sys_before_onair_filename: default
    :return: int gainCorrection
    '''
    tar = tarfile.open(sys_before_onair_filename)
    name = tar.getnames()
    path = './tmp_gainCorrection/'
    if os.path.exists(path):
        shutil.rmtree(path)
    tar.extractall(path)

    # 取解压后的name列表的第一个文件
    syslog_name = path + name[0]
    with open(syslog_name, 'r', encoding='utf-8') as infile:
        list_reader = infile.readlines()
        for i_line in list_reader:
            if 'gainCorrectionEcpri:' in i_line:
                gainCorrection = re.findall('gainCorrectionEcpri:(.*?),', i_line)[0]
                print('gainCorrectionEcpri:', gainCorrection)
                return int(gainCorrection)
            elif 'gainCorrectionEcpri":' in i_line:
                gainCorrection = re.findall('gainCorrectionEcpri":(.*?),', i_line)[0]
                print('gainCorrectionEcpri":', gainCorrection)
                return int(gainCorrection)
    print('ERR: no gainCorrection find in syslog_Before_onair')


# ------------B2_cas11_check_syslog_for_switch------------
def get_list_reader_from_tar(tar_file_path, save_relative_path):
    tar = tarfile.open(tar_file_path)
    filename_list = tar.getnames()
    path = save_relative_path
    if os.path.exists(path):
        shutil.rmtree(path)
    tar.extractall(path)

    # 取解压后的name列表的所有文件读入到list_reader
    list_reader = []
    for name in filename_list:
        syslog_name = path + name
        with open(syslog_name, 'r', encoding='utf-8') as infile:
            list_reader_curr = infile.readlines()
            # print(len(list_reader_curr))
            list_reader = list_reader + list_reader_curr
    # print(len(list_reader))
    return list_reader


def get_time_s(time):
    time_h_m_s_ms = re.findall('T(.*?)Z', time)[0]
    # 05:22:00.503319
    hour = int(time_h_m_s_ms[0:2])
    min = int(time_h_m_s_ms[3:5])
    s = int(time_h_m_s_ms[6:8])
    ms = int(time_h_m_s_ms[9:]) / 1000
    # print('h_m_s_ms:', hour,min,s,ms)
    h_m_s = [hour, min, s, ms]
    return h_m_s


def get_time_duration_ms(time_start, time_end):
    # print('start:', time_start, 'end:', time_end)
    h_diff = 0
    m_diff = 0
    s_diff = 0
    ms_diff = 0

    if time_end[0] < time_start[0]:
        raise Exception('ERR: Time_end < time_start')
    elif time_end[0] >= time_start[0]:
        h_diff = time_end[0] - time_start[0]
        m_diff = time_end[1] - time_start[1]
        s_diff = time_end[2] - time_start[2]
        ms_diff = time_end[3] - time_start[3]

    time_duration_ms = h_diff * 3600 * 1000 + \
        m_diff * 60 * 1000 + s_diff * 1000 + ms_diff
    # print('dura:', time_duration_ms)
    if time_duration_ms > 0:
        return time_duration_ms
    else:
        print('start:', time_start)
        print('end:  ', time_end)
        raise Exception('ERR: time_duration < 0')


def check_singleUE_SB_WB_from_sys(sys_tar_filename, rnti='a'):
    '''
    :function:check SB to WB SRS from syslog
    :param sys_tar_filename: syslog path
    :param rnti: if single UE case or just check the 1st UE, this parameter is not needed
    :return: none
    '''
    max_duration = 200
    list_reader = get_list_reader_from_tar(sys_tar_filename, './SB_WB/')

    # step 1: time 3: sendRrcReconfigInd reason WIDBAND and restart
    # srsSwitchProhibitTimer
    flag1 = False
    for i_line in list_reader[:]:
        if not flag1 and 'sendRrcReconfigInd' in i_line and 'reason WIDEBAND' in i_line:
            if rnti == 'a':
                rnti = re.findall('rnti (.*?) reason', i_line)[0]
                print('rnti:', rnti)
            index_reason_WIDEBAND = list_reader.index(i_line)
            time = re.findall('Disp_4 (.*?) ', i_line)[0]
            time_reason_WIDEBAND = get_time_s(time)
            # print('time_reason_WIDEBAND:', time_reason_WIDEBAND)
            reason = re.findall('reason (.*?)\n', i_line)[0]
            sendRrcReconfigInd_sfn_slot = re.findall(
                'slot (.*?) cellId', i_line)[0]

            # index_sendRrcReconfigInd = list_reader.index(i_line)
            print(
                time, 'step1: sendRrcReconfigInd, reason WIDEBAND')
            flag1 = True
        if flag1 and 'start srsSwitchProhibitTimer' in i_line and rnti in i_line:
            time = re.findall('Disp_4 (.*?) ', i_line)[0]
            if get_time_duration_ms(time_reason_WIDEBAND, get_time_s(
                    time)) > max_duration:
                raise Exception('ERR: more than max duraion!')
            print(time, '\t\t reStart srsSwitchProhibitTimer')
            index_srsSwitchProhibitTimer_restart = list_reader.index(
                i_line)
            break

    print('\n---------before reason WIDEBAND---------')
    # step2: time1: add UE to WaitingWbSrsUeList after step1
    for i_line in list_reader[index_reason_WIDEBAND - 1::-1]:
        if 'ueList set add rnti:' + rnti in i_line:
            time = re.findall('Disp_4 (.*?) ', i_line)[0]
            if get_time_duration_ms(get_time_s(
                    time), time_reason_WIDEBAND) > max_duration:
                raise Exception('ERR: more than max duraion!')
            print(
                time, 'step2: add rnti ' +
                      rnti +
                      ' to WaitingWbSrsUeList')
            index_add_to_WaitingWbSrsUeList = list_reader.index(i_line)
            break
    print('\n---------after reason WIDEBAND---------')
    # step3: time2: srsToL3Timer time out and select UE from WaitingWbSrsUeList
    for i_line in list_reader[index_add_to_WaitingWbSrsUeList + 1:]:
        if 'srsToL3Timer time out' in i_line:
            time = re.findall('Disp_4 (.*?) ', i_line)[0]
            if get_time_duration_ms(time_reason_WIDEBAND, get_time_s(
                    time)) > max_duration:
                raise Exception('ERR: more than max duraion!')
            L3_timeout_sfn_slot = re.findall('slot:\\[(.*?)\\]', i_line)[0]
            # print(L3_timeout_sfn_slot)
            if sendRrcReconfigInd_sfn_slot != L3_timeout_sfn_slot:
                raise Exception(
                    'ERR: sendRrcReconfigInd_sfn_slot != L3_timeout_sfn_slot')
            print(
                time, 'step3: srsToL3Timer time out and select UE from WaitingWbSrsUeList')
            index_srsToL3Timer_time_out = list_reader.index(i_line)
            break

    # step4: time4:cp Send PsUser_UserModifyReq
    for i_line in list_reader[index_reason_WIDEBAND + 1:]:
        if 'Send PsUser_UserModifyReq' in i_line:
            time = re.findall('Cprt (.*?) ', i_line)[0]
            if get_time_duration_ms(time_reason_WIDEBAND, get_time_s(
                    time)) > max_duration:
                raise Exception('ERR: more than max duraion!')
            print(time, 'step4: cp Send PsUser_UserModifyReq')
            index_PsUser_UserModifyReq = list_reader.index(i_line)
            break

    # step5: time5: cp Recv PsUser_UserModifyResp OK
    flag1 = False
    for i_line in list_reader[index_PsUser_UserModifyReq + 1:]:
        if not flag1 and 'Recv PsUser_UserModifyResp OK' in i_line:
            time = re.findall('Cprt (.*?) ', i_line)[0]
            if get_time_duration_ms(time_reason_WIDEBAND, get_time_s(
                    time)) > max_duration:
                raise Exception('ERR: more than max duraion!')
            print(time, 'step5: cp Recv PsUser_UserModifyResp OK(L2PS OK)')
            index_PsUser_UserModifyResp_OK = list_reader.index(i_line)
            break

    # step6: time6: transient phase complete(after reason WIDEBAND)
    flag1 = False
    for i_line in list_reader[index_reason_WIDEBAND + 1:]:
        if not flag1 and 'Ue Ul TransientPhase:ue.rnti:' + rnti in i_line:
            time = re.findall('Disp_4 (.*?) ', i_line)[0]
            if get_time_duration_ms(time_reason_WIDEBAND, get_time_s(
                    time)) > max_duration:
                raise Exception('ERR: more than max duraion!')
            print(time, 'step6: UL TransientPhase , rnti', rnti)
            flag1 = True
        if flag1 and 'handleRrcReconfCompletedReq' in i_line and 'curState WBSRS' in i_line and rnti in i_line:
            time = re.findall('Disp_4 (.*?) ', i_line)[0]
            print(
                time, '\t\t handleRrcReconfCompletedReq(UE OK), currState2: WB SRS')
            print('Pass')
            return True
    raise Exception('Fail')


def check_singleUE_WB_SB_from_sys(sys_tar_filename, rnti='a'):
    '''
    :function:check WB to SB SRS from syslog
    :param sys_tar_filename: syslog path
    :param rnti: if single UE case or just check the 1st UE, this parameter is not needed
    :return: none
    '''
    max_duration = 200
    list_reader = get_list_reader_from_tar(sys_tar_filename, './WB_SB/')
    sendRrcReconfigInd = False
    # step1: find switch point,sendRrcReconfigInd and start
    # srsSwitchProhibitTimer
    for i_line in list_reader:
        if 'sendRrcReconfigInd' in i_line and 'reason SUBBAND' in i_line:
            index_reason_SUBBAND = list_reader.index(i_line)
            if rnti == 'a':
                rnti = re.findall('rnti (.*?) reason SUBBAND', i_line)[0]
                print('rnti:', rnti)
            else:
                if rnti != re.findall('rnti (.*?) reason SUBBAND', i_line)[0]:
                    continue
            # print(i_line)
            time = re.findall('Disp_4 (.*?) ', i_line)[0]
            time_start = get_time_s(time)
            print('time_start:', time_start)
            reason = re.findall('reason (.*?)\n', i_line)[0]
            print(
                time, 'step1: sendRrcReconfigInd, reason ' +
                reason)
            sendRrcReconfigInd = True
        if sendRrcReconfigInd and 'start srsSwitchProhibitTimer' in i_line and rnti in i_line:
            time = re.findall('Disp_4 (.*?) ', i_line)[0]
            if get_time_duration_ms(time_start, get_time_s(
                    time)) > max_duration:
                raise Exception('ERR: more than max duraion!')
            print(time, '\t\t reStart srsSwitchProhibitTimer.')
            index_sendRrcReconfigInd = list_reader.index(i_line)
            # print('index1:',index_sendRrcReconfigInd, '\n')
            break

    # step2: cp Send PsUser_UserModifyReq
    flag1 = False
    for i_line in list_reader[index_reason_SUBBAND + 1:]:
        if 'Send PsUser_UserModifyReq' in i_line:
            time = re.findall('Cprt (.*?) ', i_line)[0]
            if get_time_duration_ms(time_start, get_time_s(
                    time)) > max_duration:
                raise Exception('ERR: more than max duraion!')
            print(time, 'step2: cp Send PsUser_UserModifyReq')
            falg1 = True
            index_PsUser_UserModifyReq = list_reader.index(i_line)
            # print('index2:',index_PsUser_UserModifyReq, '\n')
            break
    # cprt 时间晚于reason, 但打印可能早于reason，如向下找不到，就向上找，check找到的cprt时间要晚于reason时间
    if not flag1:
        for i_line in list_reader[index_reason_SUBBAND - 1::-1]:
            if 'Send PsUser_UserModifyReq' in i_line:
                time = re.findall('Cprt (.*?) ', i_line)[0]
                if get_time_duration_ms(time_start, get_time_s(
                        time)) > max_duration:
                    raise Exception('ERR: more than max duraion!')
                print(time, 'step2: cp Send PsUser_UserModifyReq')
                falg1 = True
                index_PsUser_UserModifyReq = list_reader.index(i_line)
                # print('index2:',index_PsUser_UserModifyReq, '\n')
                break

    # step3: L2PS HandleUserModifyReq
    for i_line in list_reader[index_PsUser_UserModifyReq + 1:]:
        if 'Recv PsUser_UserModifyResp OK' in i_line:
            time = re.findall('Cprt (.*?) ', i_line)[0]
            if get_time_duration_ms(time_start, get_time_s(
                    time)) > max_duration:
                raise Exception('ERR: more than max duraion!')
            print(time, 'step3: cp Recv PsUser_UserModifyResp OK(L2PS OK)')
            index_PsUser_UserModifyResp_OK = list_reader.index(i_line)
            # print('index3:',index_PsUser_UserModifyResp_OK, '\n')
            break

    # step4: RrcReconfCompletedReq
    for i_line in list_reader[index_PsUser_UserModifyResp_OK + 1:]:
        if 'handleRrcReconfCompletedReq' in i_line and 'curState SBSRS' in i_line and rnti in i_line:
            time = re.findall('Disp_4 (.*?) ', i_line)[0]
            if get_time_duration_ms(time_start, get_time_s(
                    time)) > max_duration:
                raise Exception('ERR: more than max duraion!', time, get_time_duration_ms(time_start, get_time_s(
                    time)))
            print(
                time,
                'step4: handleRrcReconfCompletedReq(UE OK), currState:0/SB SRS')
            print('Pass')
            return True
    raise Exception('Fail')


def check_waitingWbSrsUeList(sys_tar_filename, target_max_length=0):
    # check 8322_B2_case11
    list_reader = get_list_reader_from_tar(
        sys_tar_filename, './waitingWbSrsUeList/')

    target_size_str = 'current size:' + str(target_max_length)
    for i_line in list_reader:
        if 'WaitingWbSrsUeList' in i_line and target_size_str in i_line:
            print('Pass: Hit target max_length=', target_max_length)
            return True
    print('ERR: not hit target length:', target_max_length)
    raise Exception('Fail')


def check_stable_DFT_patternid(tti_filename, target_patternid_1=0, target_patternid_2=0):
    '''
    :function:check the last 700 DFT beam patternid is as expected
    :param tti_filename:tti file path
    :param target_patternid_1: expected patternid as path1 in egate command
    :param target_patternid2:  expected patternid as path2 in egate command
    :return:bool
    '''
    target_patternid_1 = int(target_patternid_1)
    target_patternid_2 = int(target_patternid_2)
    if target_patternid_1 == 0 and target_patternid_2 == 0:  # if no target, only check stable
        with open(tti_filename, 'r') as infile:
            list_reader = list(csv.DictReader(infile))
        for i_line in list_reader:
            if i_line['dlFdSchedData.beamType'].startswith('DFT'):
                target_patternid_1 = float(i_line['dlFdSchedData.streamConfig.patternId1'])
                target_patternid_2 = float(i_line['dlFdSchedData.streamConfig.patternId2'])
                print(
                    'check_patternId_1_2:',
                    int(target_patternid_1), '-',
                    int(target_patternid_2))
                break

    with open(tti_filename, 'r') as infile:
        list_reader = list(csv.DictReader(infile))
        check_num = 0
        pass_num = 0
        for i_line in list_reader[-1::-1]:
            if i_line['dlFdSchedData.beamType']:
                if i_line['dlFdSchedData.beamType'].startswith('DFT'):
                    patternid_1 = float(
                        i_line['dlFdSchedData.streamConfig.patternId1'])
                    patternid_2 = float(
                        i_line['dlFdSchedData.streamConfig.patternId2'])
                    if patternid_1 == target_patternid_1:
                        if patternid_2 == target_patternid_2:
                            pass_num += 1
                        else:
                            print(
                                'ERR: wrong patternid_2:',
                                target_patternid_2,
                                'is expected but got',
                                patternid_2, i_line['sfn'] +
                                '-' + i_line['slot'], 'index:',
                                list_reader.index(i_line),
                                'check_num:', check_num)
                            raise Exception('Fail_patternid_2')
                    else:
                        print(
                            'ERR: wrong patternid_1:',
                            target_patternid_1,
                            'is expected but got',
                            patternid_1, i_line['sfn'] + '-' +
                            i_line['slot'], 'index:', list_reader.index(i_line),
                            'check_num:', check_num)
                        raise Exception('Fail_patternid_1')
                else:
                    print(
                        'ERR: DFT is expected but got ' +
                        i_line['dlFdSchedData.beamType'], i_line['sfn'] +
                        '-' + i_line['slot'],
                        'index:', list_reader.index(i_line), 'check_num:', check_num)
                    raise Exception('Fail_beam_type')
                if check_num > 699:
                    print('Pass_num:', pass_num - 1)
                    # print(i_line['sfn'] + '-' + i_line['slot'], list_reader.index(i_line))
                    return True
                check_num += 1


# ==========8322-D1-check SRS between egate and bip align===================


class periodic_SRS_resource_egate:
    type = '-'
    resource_ID = '-'
    numPorts = '-'
    CombType = '-'
    CombOffset = '-'
    CS = '-'
    freqdomain = '-'
    slot = '-'

    def info(self):
        print('-----resource_ID:', self.resource_ID, '-----')
        print('resource_type_egate:', self.type)
        print('CombType:', self.CombType)
        print('CombOffset:', self.CombOffset)
        print('CS_start:', self.CS)
        print('numPorts:', self.numPorts)
        print('freqdomainPosition:', self.freqdomain)
        print('slot:', self.slot)


def equal_periodic_SRS_resource_egate(SRS1, SRS2):
    return (SRS1.resource_ID == SRS2.resource_ID) and (SRS1.type == SRS2.type) and (SRS1.type == SRS2.type)\
        and (SRS1.CombType == SRS2.CombType) and (SRS1.CombOffset == SRS2.CombOffset) and\
           (SRS1.CS == SRS2.CS) and (SRS1.numPorts ==
                                     SRS2.numPorts) and (SRS1.slot == SRS2.slot)


class periodic_SRS_resource_bip:
    resource_type = '-'
    resource_Identity = '-'
    CombType = '-'
    CombId = '-'
    CS = '-'
    SubbandId = '-'
    slot = '-'

    def info(self):
        print('=====resource_Identity:', self.resource_Identity, '=====')
        print('resource_type_bip:', self.resource_type)
        print('CombType:', self.CombType)
        print('CombId:', self.CombId)
        print('CS:', self.CS)
        print('SubbandID:', self.SubbandId)
        print('slot:', self.slot)


def _get_periodic_SRS_info_from_egate(i_line, periodic_SRS):
    if 'nrofSRS-Ports' in i_line:
        periodic_SRS.numPorts = re.findall(r'\d+', i_line)[0]
    if 'transmissionComb' in i_line:
        periodic_SRS.CombType = re.findall(r'\d+', i_line)[0]
    if 'combOffset' in i_line:
        periodic_SRS.CombOffset = re.findall(r'\d+', i_line)[1]
    if 'cyclicShift' in i_line:
        periodic_SRS.CS = re.findall(r'\d+', i_line)[1]
    if 'freqDomainPosition' in i_line:
        periodic_SRS.freqdomain = re.findall(r'\d+', i_line)[0]
    if 'periodicityAndOffset-p' in i_line:
        periodic_SRS.slot = re.findall(r'\d+', i_line)[1]
        return periodic_SRS


# 8322_D_check_SRS_allocation_L2_align_with_CP
def check_SRS_allocation_L2_align_with_CP(egate_log_path, bip_csv_path):
    with open(egate_log_path, 'r', encoding='utf-8') as infile:
        list_egate_log = infile.readlines()
    # (1)record SRS allocation in egate log
    # step1.1: find usage antennaSwitching
    for i_line in list_egate_log:
        if 'usage antennaSwitching' in i_line:
            index_usage_antennaSwitching = list_egate_log.index(i_line)
            break
    resource_type_TAS = list_egate_log[index_usage_antennaSwitching - 3]

    # step1.2: find TAS resource ID list
    for i_line in list_egate_log[index_usage_antennaSwitching::-1]:
        if 'srs-ResourceSetId' in i_line:
            index_TAS_ResourceSetId = list_egate_log.index(i_line)
            break
    list_TAS_resource_ID = []
    for i_line in list_egate_log[index_TAS_ResourceSetId + 1:index_usage_antennaSwitching]:
        resource_ID = re.findall(r'\d+', i_line)
        if resource_ID:
            list_TAS_resource_ID.append(resource_ID[0])
    print('TAS ID:', list_TAS_resource_ID)

    # step2.1: find usage codebook
    for i_line in list_egate_log[index_usage_antennaSwitching::-1]:
        if 'usage codebook' in i_line:
            index_usage_codebook = list_egate_log.index(i_line)
            break
    resource_type_codebook = list_egate_log[index_usage_codebook - 3]
    # print('codebook:',resource_type_codebook)
    period_codebook = False
    if 'resourceType periodic' in resource_type_codebook:   # 有周期性codebook
        period_codebook = True
        # step2.2: find codebook resource ID list
        for i_line in list_egate_log[index_usage_codebook::-1]:
            if 'srs-ResourceSetId' in i_line:
                index_codebook_ResourceSetId = list_egate_log.index(i_line)
                break
        list_codebook_resource_ID = []
        for i_line in list_egate_log[index_codebook_ResourceSetId + 1:index_usage_codebook]:
            resource_ID = re.findall(r'\d+', i_line)
            if resource_ID:
                list_codebook_resource_ID.append(resource_ID[0])
        print('codebook ID:', list_codebook_resource_ID)
    else:
        print('NO periodic codebook SRS')

    # step3.1: find codebook SRS allocation
    list_SRS_egate = []
    if period_codebook:
        for ID in list_codebook_resource_ID:
            flag = 0
            for i_line in list_egate_log[index_usage_antennaSwitching + 1:]:
                if ('srs-ResourceId ' + ID) in i_line:
                    flag += 1
                    periodic_SRS = periodic_SRS_resource_egate()
                    periodic_SRS.type = 'periodic_codebook'
                    periodic_SRS.resource_ID = ID
                if flag:
                    _get_periodic_SRS_info_from_egate(i_line, periodic_SRS)
                    if periodic_SRS.slot != '-':
                        list_SRS_egate.append(periodic_SRS)
                        break
    # step3.2: find TAS SRS allocation
    if list_TAS_resource_ID:
        for ID in list_TAS_resource_ID:
            flag = 0
            for i_line in list_egate_log[index_usage_antennaSwitching + 1:]:
                if ('srs-ResourceId ' + ID) in i_line:
                    flag += 1
                    periodic_SRS = periodic_SRS_resource_egate()
                    periodic_SRS.type = 'TAS'
                    periodic_SRS.resource_ID = ID
                if flag:
                    _get_periodic_SRS_info_from_egate(i_line, periodic_SRS)
                    if periodic_SRS.slot != '-':
                        list_SRS_egate.append(periodic_SRS)
                        break
    # print SRS info in egate
    for resource in list_SRS_egate:
        resource.info()

    # step4: find the same Sufreqdomain in egate:
    list_freqdomain = []
    for i in list_SRS_egate:
        list_freqdomain.append(i.freqdomain)
    set_freqdomain = set(list_freqdomain)
    size_set_freqdomain = len(set_freqdomain)

    list_same_freqdomain = []
    for i in set_freqdomain:
        list_resourceID_for_curr_freqdomain = []
        for j in list_SRS_egate:
            if j.freqdomain == i:
                list_resourceID_for_curr_freqdomain.append(j.resource_ID)
        list_same_freqdomain.append(list_resourceID_for_curr_freqdomain)
    print('list_freqdomain:', set_freqdomain)
    print('resouceId:', list_same_freqdomain)
    list_same_freqdomain = sorted(list_same_freqdomain)
    print('resouceId_sorted:', list_same_freqdomain)

    # ste5: check SRS allocation in bip
    with open(bip_csv_path, 'r') as infile:
        list_bip_log = list(csv.DictReader(infile))

    # step5.1: find 倒数第1个resource0(最后一组resource个数不完整，舍弃)
    for i_line in list_bip_log[-1::-1]:
        resourceIdentity_j = i_line['UlData_srsBmCsInfo_t.srsResourceIdentity']
        if period_codebook:
            if resourceIdentity_j and resourceIdentity_j.startswith('0'):
                index_last_resource_start = list_bip_log.index(i_line)
                break
        else:
            if resourceIdentity_j and resourceIdentity_j.startswith('1'):
                index_last_resource_start = list_bip_log.index(i_line)
                break

    # step5.2: check start
    check_num = 0
    pass_num = 0
    list_bip_log_cp = list_bip_log.copy()

    for j_line in list_bip_log[:index_last_resource_start]:
        resourceIdentity_j = j_line['UlData_srsBmCsInfo_t.srsResourceIdentity']
        if not resourceIdentity_j:
            continue
        # step5.3: for i_line start
        if resourceIdentity_j.startswith('0'):   # 每一轮从resource 0 开始check
            index_curr_1st_resource_0 = list_bip_log.index(j_line)
            list_SRS_bip_curr = []
            for egate_SRS in list_SRS_egate:
                int_ID = int(egate_SRS.resource_ID)
                for i_line in list_bip_log_cp[index_curr_1st_resource_0:]:
                    resourceIdentity_i = i_line['UlData_srsBmCsInfo_t.srsResourceIdentity']
                    if resourceIdentity_i and resourceIdentity_i.startswith(egate_SRS.resource_ID):
                        SRS = periodic_SRS_resource_bip()
                        if egate_SRS.resource_ID == '0':
                            SRS.resource_type = 'codebook'
                        else:
                            SRS.resource_type = 'TAS'
                        SRS.resource_Identity = i_line['UlData_srsBmCsInfo_t.srsResourceIdentity']
                        SRS.CombType = i_line['UlData_srsBmStruct_t.transmissionComb']
                        SRS.CombId = i_line['UlData_srsBmCombShiftPairs_t.transmissionCombId']
                        SRS.CS = i_line['UlData_srsBmCsInfo_t.bmCyclicShift']
                        SRS.SubbandId = i_line['UlData_srsBmSubbands_t.srsBmSubbandId']
                        SRS.slot = i_line['3gpp.slot']
                        list_SRS_bip_curr.append(SRS)
                        break
            for i in list_SRS_bip_curr:
                i.info()

            # step5.4: check info the same in egate and bip
            num_SRS_bip = len(list_SRS_bip_curr)
            num_SRS_egate = len(list_SRS_egate)
            if num_SRS_egate == num_SRS_bip:  # SRS num 相等
                for i in range(num_SRS_bip):
                    if int(list_SRS_egate[i].slot) % 20 != int(list_SRS_bip_curr[i].slot):
                        print(
                            'ERR slot:',
                            'egate slot' +
                            list_SRS_egate[i].slot,
                            'bip slot ' +
                            list_SRS_bip_curr[i].slot,
                            'resourceId:' +
                            list_SRS_egate[i].resource_ID)
                        raise Exception('Fail')
                    if list_SRS_egate[i].CombType != list_SRS_bip_curr[i].CombType:
                        print('ERR CombType:', 'egate CombType' + list_SRS_egate[i].CombType,
                              'bip CombType ' + list_SRS_bip_curr[i].CombType,
                              'resourceId:' + list_SRS_egate[i].resource_ID)
                        raise Exception('Fail')
                    if list_SRS_egate[i].CombOffset != list_SRS_bip_curr[i].CombId:
                        print('ERR CombId:', 'egate CombId' + list_SRS_egate[i].CombOffset,
                              'bip CombId ' + list_SRS_bip_curr[i].CombId,
                              'resourceId:' + list_SRS_egate[i].resource_ID)
                        raise Exception('Fail')
                    if not list_SRS_bip_curr[i].CS.startswith(
                            list_SRS_egate[i].CS):
                        print('ERR CS_start:', 'egate CS_start' + list_SRS_egate[i].CS,
                              'bip CS_ ' + list_SRS_bip_curr[i].CS,
                              'resourceId:' + list_SRS_egate[i].resource_ID)
                        raise Exception('Fail')

                    list_CS_bip = re.findall('\\d+', list_SRS_bip_curr[i].CS)
                    if len(list_CS_bip) != int(list_SRS_egate[i].numPorts):
                        print('ERR CS_numPorts:', 'egate numPorts' + list_SRS_egate[i].numPorts,
                              'bip CS_ ' + list_SRS_bip_curr[i].CS,
                              'resourceId:' + list_SRS_egate[i].resource_ID)
                        raise Exception('Fail')

            # step5.5: check the same freqdomain and subbandid for multiple
            # resource
            print('\n----check the same freqdomain and subbandid for multiple resource---')
            check_num += 1

            # find the same SubbandID in bip:
            list_subbandID = []
            for i in list_SRS_bip_curr:
                list_subbandID.append(i.SubbandId)
            set_subbandID = set(list_subbandID)     # 去重
            size_set_subbandID = len(set_subbandID)

            list_same_SubbanID = []
            for i in set_subbandID:
                list_resourceID_for_curr_SubbandID = []
                for j in list_SRS_bip_curr:
                    if j.SubbandId == i:
                        list_resourceID_for_curr_SubbandID.append(j.resource_Identity[0])
                list_same_SubbanID.append(list_resourceID_for_curr_SubbandID)
            print('list_SubbandID:', set_subbandID)
            print('resouceIdentity:', list_same_SubbanID)
            list_same_SubbanID = sorted(list_same_SubbanID)
            print('resouceIdentity_sorted:', list_same_SubbanID)

            if size_set_subbandID != size_set_freqdomain:
                print(
                    'ERR: num of subbandId != num of freqdomain,',
                    'subband num:',
                    size_set_subbandID,
                    'freqdomain num:',
                    size_set_freqdomain,
                    i_line['3gpp.sfn'] + '-' + i_line['3gpp.slot'])
                raise Exception('Fail: maybe just message lost, please double check with srsreceiverespbmps,'
                                'srsreceivereq_x1:srsreceiverespbmps_x2 polar')
            else:
                if list_same_freqdomain == list_same_SubbanID:
                    pass_num += 1
            # for i_line end

    print('check_num:', check_num)
    print('pass_num:', pass_num)
    if check_num == pass_num:
        print('---Pass---')
    else:
        raise Exception('Fail final')

# check_SRS_allocation_L2_align_with_CP('egate_console.log.002', 'BIP_UE2.csv')


# ---------------------check D2---------------------------------------


def change_set_to_sort_list(set_SRS_slot):
    list_set = list(set_SRS_slot)
    list_int = []
    for i in list_set:
        list_int.append(int(i))
    sorted_list = sorted(list_int)
    return sorted_list


def get_SRS_pool_from_sys_before_onair(
        sys_before_onair_filename='${TEST_LOG_DIRECTORY()}/All/syslog_before_onair/before_onair_gnb.tar.gz'):
    tar = tarfile.open(sys_before_onair_filename)
    name = tar.getnames()
    path = './tmp_SRS_pool/'
    if os.path.exists(path):
        shutil.rmtree(path)
    tar.extractall(path)

    # 取解压后的name列表的第一个文件
    syslog_name = path + name[0]
    with open(syslog_name, 'r', encoding='utf-8') as infile:
        list_reader = infile.readlines()
        # step1.1: find index of initial WB SRS pool
        for i_line in list_reader:
            if '[SRS]Initial wideband srs resource pool' in i_line:
                print(
                    'WB SRS pool:',
                    re.findall(
                        'Initial wideband srs resource pool(.*?)\n',
                        i_line)[0])
                index_ini_WB_pool = list_reader.index(i_line)
                break
        # step1.2: find the WB SRS allocation:
        set_WB_slot = set()
        set_WB_combId = set()
        for i_line in list_reader[index_ini_WB_pool + 1:]:
            if 'Wideband srs resource pool' in i_line:
                curr_slot = re.findall('slotId: (.*?),', i_line)[0]
                curr_combId = re.findall('combId: \\[(.*?)\\]', i_line)[0]
                set_WB_slot.add(curr_slot)
                set_WB_combId.add(curr_combId)
            if 'WidebandSrs pool is initialized' in i_line:
                break
        print('WB slot:', change_set_to_sort_list(set_WB_slot))
        print('WB combId:', set_WB_combId)

        # step2.1: find index of initial SB SRS pool
        for i_line in list_reader:
            if '[SRS]Initial main subband srs resource pool' in i_line:
                print(
                    'SB SRS pool:',
                    re.findall(
                        'Initial main subband srs resource pool(.*?)\n',
                        i_line)[0])
                index_ini_SB_pool = list_reader.index(i_line)
                break
        # step2.2: find the SB SRS allocation:
        set_SB_slot = set()
        set_SB_combbId = set()
        for i_line in list_reader[index_ini_SB_pool + 1:]:
            if 'Subband srs resource pool' in i_line:
                curr_slot = re.findall('slotId:(.*?),', i_line)[0]
                curr_combId = re.findall('combId:\\[(.*?)\\]', i_line)[0]
                set_SB_slot.add(curr_slot)
                if '0' in curr_combId:
                    set_SB_combbId.add('0')
                if '1' in curr_combId:
                    set_SB_combbId.add('1')
                if '2' in curr_combId:
                    set_SB_combbId.add('2')
                if '3' in curr_combId:
                    set_SB_combbId.add('3')
            if 'SubbandSrs pool is initialized' in i_line:
                break

        print('SB slot:', change_set_to_sort_list(set_SB_slot))
        print('SB combId:', set_SB_combbId)

        return set_WB_slot, set_WB_combId, set_SB_slot, set_SB_combbId


def _rule_sort_SRS_by_Id(t):
    return int(t.resource_ID)


def SRS_set_to_sorted_list(set_SRS):
    _list = list(set_SRS)
    _list.sort(key=_rule_sort_SRS_by_Id)
    return _list


def get_SB_and_WB_SRS_from_egate(egate_log_path, set_WB_slot, set_WB_combId):
    # 倒序遍历所有周期性SRS，放入set去重
    # 每一个SRS，先找slot
    with open(egate_log_path, 'r', encoding='utf-8') as infile:
        list_egate_log = infile.readlines()
    set_WB_SRS = set()
    set_SB_SRS = set()
    SRS_record_start = False
    SRS_info_complete = False
    for i_line in list_egate_log[-1::-1]:
        if 'periodicityAndOffset-p' in i_line:
            SRS_record_start = True
            periodic_SRS = periodic_SRS_resource_egate()
            periodic_SRS.slot = re.findall('\\d+', i_line)[1]    # 第二组数字是slot
        elif not SRS_record_start:
            continue
        elif 'freqDomainPosition' in i_line:
            periodic_SRS.freqdomain = re.findall('\\d+', i_line)[0]
        elif 'cyclicShift' in i_line:
            periodic_SRS.CS = re.findall('\\d+', i_line)[1]
        elif 'combOffset' in i_line:
            periodic_SRS.CombOffset = re.findall('\\d+', i_line)[1]
        elif 'transmissionComb' in i_line:
            periodic_SRS.CombType = re.findall('\\d+', i_line)[0]
        elif 'nrofSRS-Port' in i_line:
            periodic_SRS.numPorts = re.findall('\\d+', i_line)[0]
        elif 'srs-ResourceId ' in i_line:
            periodic_SRS.resource_ID = re.findall('\\d+', i_line)[0]
            SRS_record_start = False
            SRS_info_complete = True

        SRS_exist = False
        if SRS_info_complete:
            SRS_info_complete = False   # for next turn

            if (periodic_SRS.slot in set_WB_slot) and (
                    periodic_SRS.CombOffset in set_WB_combId):
                periodic_SRS.type = 'WB SRS'

                for i in set_WB_SRS:
                    if equal_periodic_SRS_resource_egate(i, periodic_SRS):
                        SRS_exist = True
                        # print('重复')
                        break
                if not SRS_exist:
                    set_WB_SRS.add(periodic_SRS)

            else:
                periodic_SRS.type = 'SB SRS'

                for i in set_SB_SRS:
                    if equal_periodic_SRS_resource_egate(i, periodic_SRS):
                        SRS_exist = True
                        # print('重复')
                        break
                if not SRS_exist:
                    set_SB_SRS.add(periodic_SRS)
    list_WB_SRS_egate = SRS_set_to_sorted_list(set_WB_SRS)
    list_SB_SRS_egate = SRS_set_to_sorted_list(set_SB_SRS)
    return list_WB_SRS_egate, list_SB_SRS_egate


def check_SRS_info_same_in_egate_and_bip(list_SRS_egate, list_SRS_bip_curr):
    num_SRS_bip = len(list_SRS_bip_curr)
    num_SRS_egate = len(list_SRS_egate)
    if num_SRS_egate == num_SRS_bip:  # SRS num 相等
        for i in range(num_SRS_bip):
            if int(list_SRS_egate[i].slot) % 20 != int(
                    list_SRS_bip_curr[i].slot):
                print(
                    'ERR slot:',
                    'egate slot' +
                    list_SRS_egate[i].slot,
                    'bip slot ' +
                    list_SRS_bip_curr[i].slot,
                    'resourceId:' +
                    list_SRS_egate[i].resource_ID)
                raise Exception('Fail')
            if list_SRS_egate[i].CombType != list_SRS_bip_curr[i].CombType:
                print('ERR CombType:', 'egate CombType' + list_SRS_egate[i].CombType,
                      'bip CombType ' + list_SRS_bip_curr[i].CombType,
                      'resourceId:' + list_SRS_egate[i].resource_ID)
                raise Exception('Fail')
            if list_SRS_egate[i].CombOffset != list_SRS_bip_curr[i].CombId[0]:
                print('ERR CombId:', 'egate CombId ' + list_SRS_egate[i].CombOffset,
                      'bip CombId ' + list_SRS_bip_curr[i].CombId,
                      'resourceId:' + list_SRS_egate[i].resource_ID)
                raise Exception('Fail')
            if not list_SRS_bip_curr[i].CS.startswith(
                    list_SRS_egate[i].CS):
                print('ERR CS_start:', 'egate CS_start' + list_SRS_egate[i].CS,
                      'bip CS_ ' + list_SRS_bip_curr[i].CS,
                      'resourceId:' + list_SRS_egate[i].resource_ID)
                raise Exception('Fail')

            list_CS_bip = re.findall('\\d+', list_SRS_bip_curr[i].CS)
            if len(list_CS_bip) != int(list_SRS_egate[i].numPorts):
                print('ERR CS_numPorts:', 'egate numPorts' + list_SRS_egate[i].numPorts,
                      'bip CS_ ' + list_SRS_bip_curr[i].CS,
                      'resourceId:' + list_SRS_egate[i].resource_ID)
                raise Exception('Fail')
            print('---check step1 OK---')
            return True


def check_egate_freqdomain_and_bip_subbandId_align(list_SRS_egate, list_SRS_bip_curr):
    print('\n----check step2---')
    # step1: find the same Sufreqdomain in egate:
    list_freqdomain = []
    for i in list_SRS_egate:
        list_freqdomain.append(i.freqdomain)
    set_freqdomain = set(list_freqdomain)
    size_set_freqdomain = len(set_freqdomain)

    list_same_freqdomain = []
    for i in set_freqdomain:
        list_resourceID_for_curr_freqdomain = []
        for j in list_SRS_egate:
            if j.freqdomain == i:
                list_resourceID_for_curr_freqdomain.append(j.resource_ID)
        list_same_freqdomain.append(list_resourceID_for_curr_freqdomain)
    print('list_freqdomain:', set_freqdomain)
    print('resourceId:', list_same_freqdomain)
    list_same_freqdomain = sorted(list_same_freqdomain)
    print('resourceId_sorted:', list_same_freqdomain)

    # step2: find the same SubbandID in bip:
    list_subbandID = []
    for i in list_SRS_bip_curr:
        list_subbandID.append(i.SubbandId)
    set_subbandID = set(list_subbandID)  # 去重
    size_set_subbandID = len(set_subbandID)

    list_same_SubbanID = []
    for i in set_subbandID:
        list_resourceID_for_curr_SubbandID = []
        for j in list_SRS_bip_curr:
            if j.SubbandId == i:
                list_resourceID_for_curr_SubbandID.append(
                    j.resource_Identity[0])
        list_same_SubbanID.append(list_resourceID_for_curr_SubbandID)
    print('list_SubbandID:', set_subbandID)
    print('resourceIdentity:', list_same_SubbanID)
    list_same_SubbanID = sorted(list_same_SubbanID)
    print('resourceIdentity_sorted:', list_same_SubbanID)

    if size_set_subbandID != size_set_freqdomain:
        print(
            'ERR: num of subbandId != num of freqdomain,',
            'subband num:',
            size_set_subbandID,
            'freqdomain num:',
            size_set_freqdomain)
        # i_line['3gpp.sfn'] + '-' + i_line['3gpp.slot'])
        raise Exception('Fail: maybe just message lost, please double check with srsreceiverespbmps,'
                        'srsreceivereq_x1:srsreceiverespbmps_x2 polar')
    else:
        if list_same_freqdomain == list_same_SubbanID:      # 个数相同的 resource ID相同即pass
            print('----check step2 OK---')
            return True


def check_SB_and_WB_SRS_From_bip(
        bip_csv_path, list_WB_SRS_egate, list_SB_SRS_egate):
    WB_SRS_start_ID = list_WB_SRS_egate[0].resource_ID
    SB_SRS_start_ID = list_SB_SRS_egate[0].resource_ID
    print('\nWB start ID:', WB_SRS_start_ID)
    print('\\SB start: ID', SB_SRS_start_ID)

    with open(bip_csv_path, 'r') as infile:
        list_bip_log = list(csv.DictReader(infile))

    # step1: find 倒数第1个resource_Id_start(最后一组resource个数可能不完整，舍弃)
    find_last_WB_SRS_start_Id = False
    find_last_SB_SRS_start_Id = False
    for i_line in list_bip_log[-1::-1]:
        resourceIdentity_SB = i_line['UlData_srsBmCsInfo_t.srsResourceIdentity']
        resourceIdentity_WB = i_line['UlData_srsBwvReportRequest_t.srsResourceIdentity']
        if resourceIdentity_SB and resourceIdentity_SB.startswith(
                SB_SRS_start_ID):
            index_last_resource_start = list_bip_log.index(i_line)
            find_last_SB_SRS_start_Id = True
            break
        elif resourceIdentity_WB and resourceIdentity_WB.startswith(WB_SRS_start_ID):
            index_last_resource_start = list_bip_log.index(i_line)
            find_last_WB_SRS_start_Id = True
            break
    print('find_last_WB_SRS_start_Id:', find_last_WB_SRS_start_Id)
    print('find_last_SB_SRS_start_Id:', find_last_SB_SRS_start_Id)
    # step：
    list_bip_log_cp = list_bip_log.copy()
    check_num = 0
    pass_num = 0
    for j_line in list_bip_log[:index_last_resource_start]:
        # copy1
        resourceIdentity_SB = j_line['UlData_srsBmCsInfo_t.srsResourceIdentity']
        resourceIdentity_WB = j_line['UlData_srsBwvReportRequest_t.srsResourceIdentity']

        if not (resourceIdentity_WB or resourceIdentity_SB):
            continue
        # step5.3: for i_line start
        # 每一轮从resource 0 开始check
        # SB SRS
        if j_line['UlData_srsReceiveReqSubcell_t.srsBmEnable'] == '1' and resourceIdentity_SB.startswith(
                SB_SRS_start_ID):
            check_num += 1
            print('debug_ERR')
            index_curr_1st_resource_0 = list_bip_log.index(j_line)
            list_SRS_bip_curr = []
            for egate_SRS in list_SB_SRS_egate:
                int_ID = int(egate_SRS.resource_ID)
                for i_line in list_bip_log_cp[index_curr_1st_resource_0:]:
                    resourceIdentity_i = i_line['UlData_srsBmCsInfo_t.srsResourceIdentity']
                    if resourceIdentity_i and resourceIdentity_i.startswith(
                            egate_SRS.resource_ID):
                        SRS = periodic_SRS_resource_bip()
                        SRS.resource_type = 'SB SRS'
                        SRS.resource_Identity = i_line['UlData_srsBmCsInfo_t.srsResourceIdentity']
                        SRS.CombType = i_line['UlData_srsBmStruct_t.transmissionComb']
                        SRS.CombId = i_line['UlData_srsBmCombShiftPairs_t.transmissionCombId']
                        SRS.CS = i_line['UlData_srsBmCsInfo_t.bmCyclicShift']
                        SRS.SubbandId = i_line['UlData_srsBmSubbands_t.srsBmSubbandId']
                        SRS.slot = i_line['3gpp.slot']
                        list_SRS_bip_curr.append(SRS)
                        break
            print('---list_SRS_bip_curr---', check_num)
            for i in list_SRS_bip_curr:
                i.info()
            # step: check info the same in egate and bip
            if check_SRS_info_same_in_egate_and_bip(list_WB_SRS_egate, list_SRS_bip_curr) and \
                    check_egate_freqdomain_and_bip_subbandId_align(list_WB_SRS_egate, list_SRS_bip_curr):
                pass_num += 1
                print('SB_pass_num +1')
        # WB SRS
        elif j_line['UlData_srsReceiveReqSubcell_t.srsBwvEnable'] == '1' \
                and resourceIdentity_WB.startswith(WB_SRS_start_ID):
            check_num += 1
            index_curr_1st_resource_0 = list_bip_log.index(j_line)
            # print('debug:1')
            list_SRS_bip_curr = []
            for egate_SRS in list_WB_SRS_egate:
                int_ID = int(egate_SRS.resource_ID)
                for i_line in list_bip_log_cp[index_curr_1st_resource_0:]:
                    resourceIdentity_i = i_line['UlData_srsBwvReportRequest_t.srsResourceIdentity']
                    if resourceIdentity_i and resourceIdentity_i.startswith(
                            egate_SRS.resource_ID):
                        SRS = periodic_SRS_resource_bip()
                        SRS.resource_type = 'WB SRS'
                        SRS.resource_Identity = i_line['UlData_srsBwvReportRequest_t.srsResourceIdentity']
                        SRS.CombType = i_line['UlData_srsBwvStruct_t.transmissionComb']
                        SRS.CombId = i_line['UlData_srsCyclicShifts_t.transmissionCombId']
                        SRS.CS = i_line['UlData_srsCyclicShifts_t.cyclicShift']
                        SRS.SubbandId = re.findall(
                            '(.*?),', i_line['UlData_srsBwvReportRequest_t.bfSubbandId_item'])[0]
                        SRS.slot = i_line['3gpp.slot']
                        list_SRS_bip_curr.append(SRS)
                        break
            print('\n--------curr check num:', check_num, '--------')
            for i in list_SRS_bip_curr:
                i.info()

            # step: check info the same in egate and bip
            if check_SRS_info_same_in_egate_and_bip(list_WB_SRS_egate, list_SRS_bip_curr) and \
                    check_egate_freqdomain_and_bip_subbandId_align(list_WB_SRS_egate, list_SRS_bip_curr):
                pass_num += 1
                print('WB_pass_num +1')

    print('\n====check_num:', check_num, '====')
    print('check_num:', check_num)
    print('pass_num:', pass_num)
    if check_num == pass_num:
        print('pass')
        return True
    else:
        print('fail')
        raise Exception('final Fail')


def check_D2_SB_WB_SRS_align_with_bip(syslog_before_onair, egate_log_path, bip_csv_path):
    # step1: get WB SRS pool and SB SRS pool fron syslog before onair
    set_WB_slot, set_WB_combId, set_SB_slot, set_SB_combId = get_SRS_pool_from_sys_before_onair(
        syslog_before_onair)
    # step2: get WB SRS and SB SRS info from egate log
    list_WB_SRS_egate, list_SB_SRS_egate = get_SB_and_WB_SRS_from_egate(
        egate_log_path,
        set_WB_slot,
        set_WB_combId)

    print('\n WB SRS number:', len(list_WB_SRS_egate))
    for i in list_WB_SRS_egate:
        i.info()

    print('\n SB SRS number:', len(list_SB_SRS_egate))
    for i in list_SB_SRS_egate:
        i.info()

    check_SB_and_WB_SRS_From_bip(
        bip_csv_path,
        list_WB_SRS_egate,
        list_SB_SRS_egate)

# check_D2_SB_WB_SRS_align_with_bip('before_onair_gnb.tar.gz','egate_console.log.001', 'bip_UE5_0.csv')


# -----check point for 8322_G14-----
def _get_time_from_tti_i_line(i_line):
    tti_time_str = i_line['timeStamp'][11:]
    # print('---debug:',tti_time_str)
    hour = int(tti_time_str[0:2])
    min = int(tti_time_str[3:5])
    sec = int(tti_time_str[6:8])
    ms = int(tti_time_str[9:]) / 1000
    tti_time_sum = hour * 60 * 60 * 1000 + min * 60 * 1000 + sec * 1000 + ms
    # print("h,m,s,ms:",hour,min,sec,ms)
    return tti_time_str, tti_time_sum


def _get_time_from_syslog_i_line(i_line):
    sys_time_str = re.findall('<(.*?>)', i_line)[0][11:26]
    # print('sys_time:',sys_time_str)
    hour = int(sys_time_str[:2])
    min = int(sys_time_str[3:5])
    sec = int(sys_time_str[6:8])
    ms = int(sys_time_str[9:]) / 1000
    # print('int_time:', hour, min, sec, ms)
    sys_time_sum = hour * 60 * 60 * 1000 + min * 60 * 1000 + sec * 1000 + ms
    return sys_time_str, sys_time_sum


def _get_L3Timer_sfn_slot(i_line):
    L3Timer_timeout_sfn_slot = re.findall('slot:\\[(\\d+)/(\\d+)\\]', i_line)
    # findall的结果是一个元组列表
    L3_timeout_sfn = int(L3Timer_timeout_sfn_slot[0][0])
    L3_timeout_slot = int(L3Timer_timeout_sfn_slot[0][1])
    return L3_timeout_sfn, L3_timeout_slot


def get_start_end_index_between_2_L3Timer_tti(
        list_tti, switch_L3Timer_sfn, switch_L3Timer_slot, before_switch_L3Timer_sfn, before_switch_L3Timer_slot):
    # step 1: find the index switch_L3Timer in tti
    for i_line in list_tti:
        if i_line['srsState'] == "'SBTOWBSRS'":
            index_switch = list_tti.index(i_line)
            break
    for i_line in list_tti[index_switch::-1]:
        if i_line['srsState']:
            sfn = int(i_line['sfn'])
            slot = int(i_line['slot'])
            time_sum = sfn * 20 + slot
            switch_L3Timer_sum = switch_L3Timer_sfn * 20 + switch_L3Timer_slot
            if time_sum <= switch_L3Timer_sum:
                print(
                    '\nswitch_L3Timer_tti:',
                    i_line['sfn'] +
                    '-' +
                    i_line['slot'])
                _index_switch_L3Timer_tti = list_tti.index(i_line)
                break
    # step 2: find the index before_Switch_L3Timer out in tti
    for i_line in list_tti[_index_switch_L3Timer_tti::-1]:
        if i_line['srsState']:
            sfn = int(i_line['sfn'])
            slot = int(i_line['slot'])
            time_sum = sfn * 20 + slot
            before_switch_L3Timer_sum = before_switch_L3Timer_sfn * \
                20 + before_switch_L3Timer_slot
            if time_sum <= before_switch_L3Timer_sum:
                _index_before_switch_L3Timer_tti = last_index_srsState
                print(
                    'before_switch_L3Timer_tti:',
                    list_tti[_index_before_switch_L3Timer_tti]['sfn'] +
                    '-' +
                    list_tti[_index_before_switch_L3Timer_tti]['slot'])
                break
            last_index_srsState = list_tti.index(i_line)
    return _index_before_switch_L3Timer_tti, _index_switch_L3Timer_tti


def check_G14_rdIncludeHighVolatileUe_single_UE(
        syslog, tti_csv, rdIncludeHighVolatileUe='0', numWbSrsConfigSample=5,
        rlqGoodPercentage=100, prbSampleHighLowPercentage=60):
    print('rdIncludeHighVolatileUe =', rdIncludeHighVolatileUe)
    tar = tarfile.open(syslog)
    name = tar.getnames()
    path = './G14/'
    if os.path.exists(path):
        shutil.rmtree(path)
    tar.extractall(path)
    syslog_name = path + name[0]    # 取解压后的name列表的第一个文件
    with open(syslog_name, 'r') as infile:
        list_sys = infile.readlines()
    print('---------------syslog------------------')
    # step1.1: find the L3Timer out when 'reason wideband'
    for i_line in list_sys:
        if 'reason WIDEBAND' in i_line:
            index_reason_WIDBAN = list_sys.index(i_line)
            sys_time_WB_str, sys_time_sum_WB = _get_time_from_syslog_i_line(
                i_line)
            print('sys_time_switch_to_WB:', sys_time_WB_str)
            break
    for i_line in list_sys[index_reason_WIDBAN + 1:]:
        if 'srsToL3Timer time out' in i_line:
            index_WB_L3Timer_out = list_sys.index(i_line)
            switch_L3Timer_sfn, switch_L3Timer_slot = _get_L3Timer_sfn_slot(
                i_line)
            print(
                'switch_L3Timer_out:',
                switch_L3Timer_sfn,
                '-',
                switch_L3Timer_slot)
            break

    # step1.2: find the L3Timer out before 'reason wideband'
    for i_line in list_sys[index_reason_WIDBAN::-1]:
        if 'srsToL3Timer time out' in i_line:
            index_L3_before_switch = list_sys.index(i_line)
            before_switch_L3Timer_sfn, before_switch_L3Timer_slot = _get_L3Timer_sfn_slot(
                i_line)
            print(
                'before_Switch_L3Timer_out:',
                before_switch_L3Timer_sfn,
                '-',
                before_switch_L3Timer_slot)
            break

    # step1.3: find 'ueList set add rnti' between 2 L3Timer out.
    waitinglist_add_num = 0
    list_waitinglist_add_time = []
    list_time_sum_sys = []
    list_rrmSrsMetric = []
    for i_line in list_sys[index_L3_before_switch:index_WB_L3Timer_out]:
        if 'ueList set add rnti' in i_line:
            waitinglist_add_num += 1
            time_str, time_sum = _get_time_from_syslog_i_line(i_line)
            list_waitinglist_add_time.append(time_str)
            list_time_sum_sys.append(time_sum)
            rrmSrsMetric = re.findall('rrmSrsMetric:(.*?),', i_line)[0]
            list_rrmSrsMetric.append(float(rrmSrsMetric))
    # print('\nwaitinglist add num:', waitinglist_add_num)
    # print('waitinglist add time:',list_waitinglist_add_time)
    # print('time_sum_sys:',list_time_sum_sys)

    print('\n--------------------tti-----------------------------')
    with open(tti_csv, 'r') as infile:
        list_tti = list(csv.DictReader(infile))

    # step 2.0: check there's 'HIGHCHANNELVOLATILEUE' at RLQ_Good, else no
    # need to check further.
    flag_high_rlqGood = False
    for i_line in list_tti:
        if i_line['volatilityStatus'] == '\'HIGHCHANNELVOLATILEUE\'':
            if is_high_buffer_and_goodRlq(
                    i_line, numWbSrsConfigSample, rlqGoodPercentage, prbSampleHighLowPercentage):
                flag_high_rlqGood = True
                break
    if not flag_high_rlqGood:
        raise Exception(
            'Fail_0: no high_volatile and Good_RLQ Hit, please recollect the log.')

    # step2.2: find the L3timer_switch and L3Timer_before_swith
    index_before_switch_L3Timer_tti, index_switch_L3Timer_tti = get_start_end_index_between_2_L3Timer_tti(
        list_tti,
        switch_L3Timer_sfn, switch_L3Timer_slot,
        before_switch_L3Timer_sfn, before_switch_L3Timer_slot)

    # step 2.3: check RLQ_Good and volatilityStatus during
    # [switch_L3Timer:before_switch_L3Timer]
    print('\n----step3: check RLQ_Good and volatilityStatus-----')
    waitinglist_add_num_tti = 0
    list_waitinglist_add_time_tti = []
    list_time_sum_tti = []
    list_volatilityStatus_tti = []
    for i_line in list_tti[index_before_switch_L3Timer_tti:index_switch_L3Timer_tti + 1]:
        if i_line['srsState'] and is_high_buffer_and_goodRlq(
                i_line, numWbSrsConfigSample, rlqGoodPercentage, prbSampleHighLowPercentage):
            time_str_tti, time_sum_tti = _get_time_from_tti_i_line(i_line)
            if rdIncludeHighVolatileUe == '0':
                if i_line['volatilityStatus'] == "'LOWCHANNELVOLATILEUE'":
                    waitinglist_add_num_tti += 1
                    list_waitinglist_add_time_tti.append(time_str_tti)
                    list_time_sum_tti.append(time_sum_tti)
            else:
                waitinglist_add_num_tti += 1
                list_waitinglist_add_time_tti.append(time_str_tti)
                list_time_sum_tti.append(time_sum_tti)
                list_volatilityStatus_tti.append(i_line['volatilityStatus'])
    # output analyse results
    print('\n----out put tti----')
    print('waiting_list_add_num_tti:', waitinglist_add_num_tti)
    print('list_waitinglist_add_time_tti:',
          '\t', list_waitinglist_add_time_tti)
    print('list_time_sum_tti', list_time_sum_tti)
    if rdIncludeHighVolatileUe == '1':
        print('list_volatilityStatus_tti:', list_volatilityStatus_tti)

    print('\n----out put syslog----')
    print('waitinglist add num:', waitinglist_add_num)
    print('list_rrmSrsMetric:', list_rrmSrsMetric)
    print('waitinglist add time:', '\t\t\t', list_waitinglist_add_time)
    print('time_sum_sys:', '\t', list_time_sum_sys)

    # final check
    if waitinglist_add_num != waitinglist_add_num_tti:
        raise Exception(
            'Fail_1: waitinglist_add_num != waitinglist_add_num_tti')

    for i in range(len(list_waitinglist_add_time)):
        if abs(list_time_sum_tti[i] - list_time_sum_sys[i]) >= 1:
            print('ERR: waitinglist time not equal between tti and sys')
            raise Exception('Fail_2')
        '''
        check no LowChannelVolatilityPriorityBonus when
        rdIncludeHighVolatileUe=False:rrmSrsMetric<100
        '''
        if rdIncludeHighVolatileUe == '0':
            if list_rrmSrsMetric[i] > 100:
                raise Exception('Fail_3: rdIncludeHighVolatileUe=False, no LowChannelVolatilityPriorityBonus,'
                                'rrmSrsMetric <100 is expected.')
            continue
        '''
        check lowVolatileUE has LowChannelVolatilityPriorityBonus when
        rdIncludeHighVolatileUe=True:rrmSrsMetric>100
        '''
        if list_volatilityStatus_tti[i].startswith("'LOW"):
            if list_rrmSrsMetric[i] < 100:
                raise Exception(
                    'Fail_4: lowVolatile, rrmSrsMEtric >100 is expected.')
        else:
            if list_rrmSrsMetric[i] > 100:
                raise Exception(
                    'Fail_5: highVolatile, rrmSrsMetric <100 is expected.')

    print('---Pass---')


'''
check_G14_rdIncludeHighVolatileUe_single_UE(
    'UE5_US1_gnb.tar.gz',
    'G14_case2_tti_UE5_to_WB_dl_split.csv',
    rdIncludeHighVolatileUe='0',
    numWbSrsConfigSample=5,
    rlqGoodPercentage=100,
    prbSampleHighLowPercentage=60)

check_G14_rdIncludeHighVolatileUe_single_UE(
    'UE5_US1_gnb_case1.tar.gz',
    'G14_case1_tti_UE5_to_WB_dl_split.csv',
    rdIncludeHighVolatileUe='1',
    numWbSrsConfigSample=5,
    rlqGoodPercentage=100,
    prbSampleHighLowPercentage=60)
'''


def check_G14_rdIncludeHighVolatileUe_true_multiple_UE(syslog, tti_csv, numUE=3, maxNumUeSrs=2, numWbSrsConfigSample=5,
                                                       rlqGoodPercentage=100, prbSampleHighLowPercentage=60):
    numUE = int(numUE)
    maxNumUeSrs = int(maxNumUeSrs)
    list_sys = get_list_reader_from_tar(syslog, './G14_multiple_UEs/')
    print('=====     syslog     =====')
    for i_line in list_sys:     # index_1st_reasonWB
        if 'reason WIDEBAND' in i_line:
            index_1st_reasonWB = list_sys.index(i_line)
            break
    # step1: check if there're >maxNumUeSrs UEs add to waiting list
    for i_line in list_sys[index_1st_reasonWB::-1]:
        if 'ueList set add rnti' in i_line:
            WaitingWbSrsUeList_size = int(
                re.findall('current size:(.*?)\n', i_line)[0])
            if WaitingWbSrsUeList_size <= maxNumUeSrs:
                raise Exception('Fail_1: WaitingWbSrsUeList_size <= maxNumUeSrs,'
                                'not Hit target US,please recollect logs.')
            break

    for i_line in list_sys[index_1st_reasonWB::-
                           1]:     # index_L3Timer_before_switch
        if 'srsToL3Timer time out' in i_line:
            index_L3Timer_before_switch = list_sys.index(i_line)
            L3Timer_before_swicth_sfn, L3Timer_before_swicth_slot = _get_L3Timer_sfn_slot(
                i_line)
            print(
                'L3Timer_before_swicth:',
                L3Timer_before_swicth_sfn,
                '-',
                L3Timer_before_swicth_slot)
            break
    for i_line in list_sys[index_1st_reasonWB:]:     # index_L3Timer_switch
        if 'srsToL3Timer time out' in i_line:
            # index_L3Timer_switch = list_sys.index(i_line)
            L3Timer_swicth_sfn, L3Timer_swicth_slot = _get_L3Timer_sfn_slot(
                i_line)
            print(
                'L3Timer_swicth:',
                L3Timer_swicth_sfn,
                '-',
                L3Timer_swicth_slot)
            break

    for i_line in list_sys[index_1st_reasonWB:]:        # index_1st_WBSRS
        if 'curState WBSRS' in i_line:
            index_1st_WBSRS = list_sys.index(i_line)
            break

    # step1: find the rnti switch to WB
    list_reasonWB_rnti = []
    for i_line in list_sys[index_1st_reasonWB:index_1st_WBSRS]:
        if 'reason WIDEBAND' in i_line:
            list_reasonWB_rnti.append(
                re.findall(
                    'rnti (.*?) reason',
                    i_line)[0])

    # step2: find the UEs info added to list
    list_waiting_rnti = []
    list_waiting_rrmSrsMetric = []
    list_waiting_size = []
    rnti_move = False
    for i_line in list_sys[index_L3Timer_before_switch:index_1st_reasonWB]:
        if 'ueList set add rnti' in i_line:
            rnti = re.findall('rnti:(.*?),', i_line)[0]
            rrmSrsMetric = float(re.findall('rrmSrsMetric:(.*?),', i_line)[0])
            WaitingWbSrsUeList_size = int(
                re.findall('current size:(.*?)\n', i_line)[0])
            if rrmSrsMetric < 100:
                rnti_move = rnti
            list_waiting_rnti.append(rnti)
            list_waiting_rrmSrsMetric.append(rrmSrsMetric)
            list_waiting_size.append(WaitingWbSrsUeList_size)
    print('rnti_move:', rnti_move)
    print('list_waiting_rnti:', list_waiting_rnti)
    print('list_waiting_rrmSrsMetric', list_waiting_rrmSrsMetric)
    print('list_waiting_size', list_waiting_size)
    print('list_reason_WB_rnti:', list_reasonWB_rnti)
    if not rnti_move:
        raise Exception(
            'Fail_2: no highVolatile in waiting list. please recollect logs.')
    # 将rnti list转成 set
    set_waiting_rnti = set(list_waiting_rnti)
    print('set_waiting_rnti:', set_waiting_rnti)
    # step3: judge if the last rnti_move is high.
    index = 0
    for i in list_waiting_rnti[::-1]:
        if i == rnti_move:
            index_last_rnti_move = index
            break
        index += 1
    index_last_rnti_move = len(list_waiting_rnti) - \
        index_last_rnti_move - 1    # 倒序index转成正序index
    # print('debug_index_last_rnti_move:', index_last_rnti_move)
    if list_waiting_rrmSrsMetric[index_last_rnti_move] > 100:   # low
        raise Exception(
            'Fail_3: the last added rnti_move is not highVolatile,please recollect logs.')

    # step4: check 1)maxNumUeSrs is hit and 2)rnti_move not in
    # list_rnti_reasonWB
    if len(list_reasonWB_rnti) < maxNumUeSrs:
        raise Exception('Fail_4: UE reason WB < maxNumUeSrs', maxNumUeSrs)
    elif rnti_move in list_reasonWB_rnti:
        raise Exception('Fail_4: ERR:rnti_move switch to WB, not expected!')
    print('===== syslog check Pass =====')

    print('\n=====     tti     ========')
    with open(tti_csv, 'r') as infile:
        list_tti = list(csv.DictReader(infile))

    # step 0: check high with RLQ good Hited.
    flag_hihgVolatile = False
    for i_line in list_tti:
        if i_line['volatilityStatus'] == "'HIGHCHANNELVOLATILEUE'" and int(
                i_line['sampleRlqGood']) >= numWbSrsConfigSample:
            flag_hihgVolatile = True
            break
    if not flag_hihgVolatile:
        raise Exception(
            'Fail_tti_1: no high with RLQgood Hit, please recollect logs.')

    # step1: find the index_2st_Switch
    for i_line in list_tti:
        if i_line['srsState'] == "'SBTOWBSRS'":
            index_1st_switch = list_tti.index(i_line)
            break
    # step2: find the L3timer_switch and L3Timer_before_swith
    index_start, index_end = get_start_end_index_between_2_L3Timer_tti(
        list_tti, L3Timer_swicth_sfn, L3Timer_swicth_slot, L3Timer_before_swicth_sfn, L3Timer_before_swicth_slot)

    # step3: check the last time rnti_move add to waiting list is high, and
    # other US always low
    list_volatile_rnti_move = []
    for i_line in list_tti[index_start:index_end + 1]:
        if is_high_buffer_and_goodRlq(
                i_line, numWbSrsConfigSample, rlqGoodPercentage, prbSampleHighLowPercentage):
            rnti = i_line['rnti_']
            volatilityStatus = i_line['volatilityStatus']
            if rnti == rnti_move:
                list_volatile_rnti_move.append(volatilityStatus)
            else:
                if volatilityStatus != "'LOWCHANNELVOLATILEUE'":
                    raise Exception(
                        'Fail_: UE_not_move_should be lowVolatile,but got',
                        volatilityStatus)
    if list_volatile_rnti_move[-1] != "'HIGHCHANNELVOLATILEUE'":
        raise Exception(
            'Fail_: the last time rnti_move add to waiting list is expected high, but got', list_volatile_rnti_move[-1])
    print('======= check tti Pass =======')


'''
check_G14_rdIncludeHighVolatileUe_true_multiple_UE(
    'G14_case1_US2_gnb.tar.gz',
    'tti_G14_case1_US2_dl_split.csv',
    numUE=3,
    maxNumUeSrs=2,
    numWbSrsConfigSample=5,
    rlqGoodPercentage=100,
    prbSampleHighLowPercentage=60)
'''


def G14_check_rdWbSrsVolatCorrThreshold_100(split_csv):
    with open(split_csv, 'r') as infile:
        list_tti = list(csv.DictReader(infile))

    index_SBTOWB = False
    for i_line in list_tti:
        if i_line['srsState'] == "'SBTOWBSRS'":
            index_SBTOWB = list_tti.index(i_line)
            break
    if not index_SBTOWB:
        raise Exception('Fail_1: no index_SB-WB.')

    index_WBTOSB = False
    for i_line in list_tti[index_SBTOWB + 1:]:
        if i_line['srsState'] == "'WBTOSBSRS'":
            index_WBTOSB = list_tti.index(i_line)
            break
    if not index_WBTOSB:
        raise Exception('Fail_2: no index_WB-SB.')

    # check 1st SB before switchWB is low
    for i_line in list_tti[index_SBTOWB::-1]:
        if i_line['srsEpreLinear'] != '0' and i_line['srsState'] == "'SBSRS'":
            if i_line['volatilityStatus'] != "'LOWCHANNELVOLATILEUE'":
                print(
                    'Fail_3: SB_1 volatilityStatus = low expected, but got',
                    i_line['volatilityStatus'],
                    i_line['sfn'] + '-' + i_line['slot'])
                break
            else:
                print(i_line['sfn'] + '-' + i_line['slot'])
                print('1st SB: LOWCHANNELVOLATILEUE')
                break

    # check WB is high
    for i_line in list_tti[index_SBTOWB:index_WBTOSB]:
        if i_line['srsEpreLinear'] != '0' and i_line['srsState'] == "'WBSRS'":
            if i_line['volatilityStatus'] != "'HIGHCHANNELVOLATILEUE'":
                raise Exception(
                    'Fail_4: WB volatilityStatus = high expected, but got',
                    i_line['volatilityStatus'],
                    i_line['sfn'] + '-' + i_line['slot'])
    print('WB: HIGHCHANNELVOLATILEUE')
    # check 2nd SB is low
    for i_line in list_tti[index_WBTOSB:]:
        if i_line['srsEpreLinear'] == '0' and i_line['srsState'] == "'SBSRS'":
            if i_line['volatilityStatus'] != "'HIGHCHANNELVOLATILEUE'":
                raise Exception(
                    'Fail_5: HIGHCHANNELVOLATILEUE expected but got',
                    i_line['volatilityStatus'],
                    i_line['sfn'] + '-' + i_line['slot'])

        if i_line['srsEpreLinear'] != '0' and i_line['srsState'] == "'SBSRS'" and i_line['corrSquareM10000'] == '10000':
            if i_line['volatilityStatus'] != "'LOWCHANNELVOLATILEUE'":
                raise Exception(
                    'Fail_6: Low expected but got',
                    i_line['volatilityStatus'],
                    i_line['sfn'] + '-' + i_line['slot'])
    print('2nd SB: LOWCHANNELVOLATILEUE')
    print('-----Pass-----')


# ---------------------------CB012269-A-----case1--------------------
def check_12269_cell_specific_csiRS_slot(
        bip_csv, physcell, csirs_set3_period, set_3_slot=32, set_2_slot=72, set_1_slot=112):

    with open(bip_csv, 'r') as infile:
        list_bip = list(csv.DictReader(infile))

    csi_set3_p = int(csirs_set3_period)
    if csi_set3_p == 40:
        csi_set2_p = 160
        csi_set1_p = 160
    else:
        csi_set2_p = csi_set3_p
        csi_set1_p = csi_set3_p

    print(
        'target: physcell:' + physcell, '\t',
        'CSI-RS set3_2_1 period:', csi_set3_p, csi_set2_p, csi_set1_p, '\t',
        'set3_2_1_slot:',
        set_3_slot,
        set_2_slot,
        set_1_slot)

    # check set3,2,1 period is ok
    csi_period_ERR = 0
    list_bip_cp = list_bip.copy()
    list_csiRsResource_len = [8, 4, 2]
    list_csi_period = [csi_set3_p, csi_set2_p, csi_set1_p]
    for i_line in list_bip:
        for i in range(len(list_csiRsResource_len)):
            if i_line['DlData_CsiRsResourceL1sw_t.csiRsScramblingSequenceInt'].startswith(physcell) and i_line[
                    'DlData_CsiRsResourceL1sw_t.trsInfo'].startswith('0') and i_line[
                    'DlData_CsiRsResourceL1sw_t.csiRsConfig'].startswith('8') and\
                    list_csiRsResource_len[i] <= int(i_line['DlData_CsiRsSendReqL1sw_t.csiRsResources.Length'])\
                    <= 1 + list_csiRsResource_len[i]:   # 有 IM则+1，无则不加。
                # print('debug_1:',i_line['DlData_CsiRsSendReq_t.csiRsResources.Length'])
                sfn_0 = int(i_line['3gpp.sfn'])
                slot_0 = int(i_line['3gpp.slot'])
                index_0 = list_bip.index(i_line)
                # print('i:',i_line['3gpp.sfn']+'-'+i_line['3gpp.slot'])
                for j_line in list_bip_cp[index_0 + 1:]:
                    if j_line['DlData_CsiRsResourceL1sw_t.csiRsScramblingSequenceInt'].startswith(physcell) and j_line[
                            'DlData_CsiRsResourceL1sw_t.trsInfo'].startswith('0') and j_line[
                            'DlData_CsiRsResourceL1sw_t.csiRsConfig'].startswith('8') and j_line[
                            'DlData_CsiRsSendReqL1sw_t.csiRsResources.Length'] == list_csiRsResource_len[i]:
                        sfn_1 = int(j_line['3gpp.sfn'])
                        slot_1 = int(j_line['3gpp.slot'])
                        curr_p = sfn_1 * 20 + slot_1 - sfn_0 * 20 - slot_0
                        if curr_p < 0:  # 遇到1024shibai
                            curr_p = (1024 - sfn_0 + sfn_1) * 20 + slot_1 - slot_0
                        if curr_p != list_csi_period[i]:
                            print(
                                'ERR: target csi_set3_period is',
                                csi_set3_p,
                                'but got',
                                curr_p,
                                '\t',
                                j_line['3gpp.sfn'] +
                                '-' +
                                j_line['3gpp.slot'])
                            csi_period_ERR += 1
                            break
                        break
    if not csi_period_ERR:
        print('\n---check set3,2,1 period is ok--')
    else:
        raise Exception('Fail check csi period')

    ERR_set3 = 0
    ERR_set2 = 0
    ERR_set1 = 0
    pass_set3 = 0
    pass_set2 = 0
    pass_set1 = 0
    for i_line in list_bip:
        if i_line['DlData_CsiRsResourceL1sw_t.csiRsScramblingSequenceInt'].startswith(physcell) and i_line[
                'DlData_CsiRsResourceL1sw_t.trsInfo'].startswith('0') and\
                '8' in i_line['DlData_CsiRsResourceL1sw_t.csiRsConfig']:
            # check set_3
            if int(i_line['DlData_CsiRsSendReqL1sw_t.csiRsResources.Length']) >= 8:
                sfn = int(i_line['3gpp.sfn'])
                slot = int(i_line['3gpp.slot'])
                slot_set3_in_period = (sfn * 20) % csi_set3_p + slot
                # print('set3_slot:', slot_set3_in_period)
                if slot_set3_in_period != int(set_3_slot):
                    print(
                        'ERR: target set3_slot',
                        set_3_slot,
                        'but got',
                        slot_set3_in_period, '\t',
                        i_line['3gpp.sfn'] + '-' + i_line['3gpp.slot'])
                    ERR_set3 += 1
                else:
                    pass_set3 += 1

            # check set_2
            elif int(i_line['DlData_CsiRsSendReqL1sw_t.csiRsResources.Length']) >= 4:
                sfn = int(i_line['3gpp.sfn'])
                slot = int(i_line['3gpp.slot'])
                slot_set2_in_period = (sfn * 20) % csi_set2_p + slot
                # print('set2_slot:', slot_set2_in_period)
                if slot_set2_in_period != int(set_2_slot):
                    print(
                        'ERR: target set2_slot',
                        set_2_slot,
                        'but got',
                        slot_set2_in_period, '\t',
                        i_line['3gpp.sfn'] + '-' + i_line['3gpp.slot'])
                    ERR_set2 += 1
                else:
                    pass_set2 += 1
            # check set_1
            elif int(i_line['DlData_CsiRsSendReqL1sw_t.csiRsResources.Length']) >= 2:
                sfn = int(i_line['3gpp.sfn'])
                slot = int(i_line['3gpp.slot'])
                slot_set1_in_period = (sfn * 20) % csi_set1_p + slot
                # print('set1_slot:', slot_set1_in_period)
                if slot_set1_in_period != int(set_1_slot):
                    print(
                        'ERR: target set1_slot',
                        set_1_slot,
                        'but got',
                        slot_set1_in_period, '\t',
                        i_line['3gpp.sfn'] + '-' + i_line['3gpp.slot'])
                    ERR_set1 += 1
                else:
                    pass_set1 += 1

    print('pass_set1_num:', pass_set1, 'ERR_set1_num:', ERR_set1)
    print('pass_set2_num:', pass_set2, 'ERR_set2_num:', ERR_set2)
    print('pass_set3_num:', pass_set3, 'ERR_set3_num:', ERR_set3)
    if ERR_set1 or ERR_set2 or ERR_set3:
        raise Exception('Fail 1: allocation ERR.')
    if not pass_set1 and not pass_set2 and not pass_set3:
        raise Exception('Fail 2: no pass num, check if there are cell specific csi-rs there.')
    print('---------Pass--------')


'''
check_12269_cell_specific_csiRS_slot(
    'BIP_case1.csv',
    '50',
    '320',
    set_3_slot=32,
    set_2_slot=72,
    set_1_slot=112)
'''

# ---------------------------CB012269-A-----case6,7--------------------


class cell:
    physCellId = '-'
    nrCellIdentity = '-'
    l1PoolId = '-'
    CsiRsPoolingGroup = '-'

    def info(self):
        print(
            'physCellId:', self.physCellId,
            'nrCellIdentity:', self.nrCellIdentity,
            'CsiRsPoolingGroup:', self.CsiRsPoolingGroup,
            'l1PoolId:', self.l1PoolId)


def get_12269_l1pool_info_from_sys(sys_tar_filename):
    '''
    :function:get cell info from syslog_before_onair
    :param sys_tar_filename: syslog path
    :param rnti: if single UE case or just check the 1st UE, this parameter is not needed
    :owner: Zhang Shuang
    '''
    list_reader = get_list_reader_from_tar(sys_tar_filename, './sys_L1Pool/')
    list_reader_cp = list_reader.copy()
    list_cell = []
    find_flag1 = False
    set_nrCellIdentity = set()
    for i_line in list_reader:
        if 'DlCellSetupReqHandler' in i_line and 'nrCellIdentity' in i_line and 'physCellId' in i_line:
            find_flag1 = True
            # print('debug_1:', i_line)
            curr_cell = cell()
            # curr_cell.nrCellIdentity = re.findall(
            #     'nrCellIdentity:(.*?),', i_line)[0]
            # curr_cell.physCellId = re.findall('physCellId:(.*?),', i_line)[0]
            curr_cell.nrCellIdentity = re.findall(r'nrCellIdentity=(\d+),', i_line)[0]
            curr_cell.physCellId = re.findall(r'physCellId=(\d+),', i_line)[0]
            list_cell.append(curr_cell)
            set_nrCellIdentity.add(curr_cell.nrCellIdentity)

    find_flag2 = False

    set_nrCellIdentity_2 = set()
    for i_line in list_reader:
        if 'CsiRsPoolingGroupsTdd' in i_line and 'added NrCellIdentity' in i_line:
            set_nrCellIdentity_2.add(
                re.findall(
                    'NrCellIdentity:(.*?) ',
                    i_line)[0])

    if len(set_nrCellIdentity_2) > len(set_nrCellIdentity):
        diff_set = set_nrCellIdentity_2 - set_nrCellIdentity
    else:
        diff_set = set_nrCellIdentity - set_nrCellIdentity_2

    flag_diff_set = False
    if len(diff_set):
        print('set_nrCellIdentity:', set_nrCellIdentity)
        print('set_nrCellIdentity_2:', set_nrCellIdentity_2)
        print('diff_set:', diff_set)
        flag_diff_set = True

    for i_line in list_reader:
        if 'CsiRsPoolingGroupsTdd' in i_line and 'added NrCellIdentity' in i_line:
            find_flag2 = True
            # print('debug_2:', i_line)
            NrCellIdentity = re.findall('NrCellIdentity:(.*?) ', i_line)[0]
            CsiRsPoolingGroup = re.findall(
                'CsiRsPoolingGroup (.*?) ', i_line)[0]
            l1PoolId = re.findall('l1PoolId:(.*?),', i_line)[0]
            for i_cell in list_cell:
                if NrCellIdentity == i_cell.nrCellIdentity:
                    i_cell.CsiRsPoolingGroup = CsiRsPoolingGroup
                    i_cell.l1PoolId = l1PoolId
            if not flag_diff_set:
                continue
            for i_nrCellIdentity in diff_set:
                if i_nrCellIdentity == NrCellIdentity:
                    curr_cell = cell()
                    curr_cell.nrCellIdentity = NrCellIdentity
                    curr_cell.CsiRsPoolingGroup = CsiRsPoolingGroup
                    curr_cell.l1PoolId = l1PoolId
                    # not physcellid here for cell in diff_set
                    # find the physcell for curr_cell in diff_set
                    for j_line in list_reader_cp:
                        if 'LongPucchData nrCellIdentity' in j_line:
                            nrCellIdentity_j = re.findall(
                                'nrCellIdentity = (.*?) ', j_line)[0]
                            if nrCellIdentity_j == curr_cell.nrCellIdentity:
                                curr_cell.physCellId = re.findall(
                                    'physCellId = (.*?) ', j_line)[0]
                                break
                    list_cell.append(curr_cell)

    if not find_flag1 or not find_flag2:
        raise Exception('NOT find the target line.')

    set_L1pool_Id = set()
    for i_cell in list_cell:
        set_L1pool_Id.add(i_cell.l1PoolId)
    list_L1pool_ID = sorted(list(set_L1pool_Id))

    for L1pool_ID in list_L1pool_ID:
        for i_cell in list_cell:
            if i_cell.l1PoolId == L1pool_ID:
                i_cell.info()
    return list_cell


def get_12269_cellId(sys_tar_filename, L1pool_ID_index, csirsPoolingGroup_ID):
    '''
    :param sys_tar_filename:
    :param L1pool_ID_index: you can input 0,1,2... 0-the first L1pool, 1-the second L1pool...
    :param csirsPoolingGroup_ID:
    :return: physcellId
    '''
    list_cell = get_12269_l1pool_info_from_sys(sys_tar_filename)
    # get real L1pool ID in syslog
    L1pool_ID_index = int(L1pool_ID_index)
    set_L1PoolId = set()
    for i_cell in list_cell:
        set_L1PoolId.add(int(i_cell.l1PoolId))
    list_L1PoolId = sorted(list(set_L1PoolId))

    if L1pool_ID_index > len(list_L1PoolId) - 1:
        print("---ERR: wrong input L1pool_ID_index:", L1pool_ID_index,
              ",out of range of list_L1PoolId[0,", len(list_L1PoolId) - 1, "]")
        raise Exception('Fail: please check ERR print in html.log')

    for i_cell in list_cell:
        if int(i_cell.l1PoolId) == list_L1PoolId[L1pool_ID_index] and i_cell.CsiRsPoolingGroup == csirsPoolingGroup_ID:
            return i_cell.physCellId


def check_csirsMuting(bip_csv_path, pdsch_muting_physcell_Id='52',
                      csi_other_csirsGroup_physcell='50', csirsMuting=True):
    print('pdsch_muting_physcell_Id:', pdsch_muting_physcell_Id)
    print('csi_other_csirsGroup_physcell:',
          csi_other_csirsGroup_physcell, '\n')
    with open(bip_csv_path, 'r') as infile:
        list_bip = list(csv.DictReader(infile))
    list_bip_copy = list_bip.copy()

    ERR_num = 0
    pass_num = 0
    for i_line in list_bip:
        if i_line['DlData_CsiRsResourceL1sw_t.csiRsScramblingSequenceInt'].startswith(
                csi_other_csirsGroup_physcell) and i_line['DlData_CsiRsResourceL1sw_t.trsInfo'].startswith('0'):
            start_symbol_list = re.findall(
                r'\d+', i_line['DlData_CsiRsResourceL1sw_t.startSymbol'])
            # print(i_line['3gpp.sfn'] + '-' + i_line['3gpp.slot']+'--------------------')
            curr_sfn = i_line['3gpp.sfn']
            curr_slot = i_line['3gpp.slot']
            csi_symbol_set = set(start_symbol_list)
            # print(csi_symbol_set)
            csi_line_index = list_bip.index(i_line)
            csi_resource_length = i_line['DlData_CsiRsSendReqL1sw_t.csiRsResources.Length']
            if csi_resource_length == '2':
                csi_resource_set = 'set_1'
            elif csi_resource_length == '4':
                csi_resource_set = 'set_2'
            elif csi_resource_length == '8':
                csi_resource_set = 'set_3'
            flag_pdsch_this_slot = False
            for j_line in list_bip_copy[csi_line_index:]:
                flag_muting = False
                if j_line['3gpp.sfn'] == curr_sfn and j_line['3gpp.slot'] == curr_slot and j_line[
                        '3gpp.dmrsScramblingSequenceInt'] == pdsch_muting_physcell_Id:     # pdsch
                    pdsch_start_symbol = int(
                        j_line['DlData_PdschGrantL1sw.startSymbol'])
                    pdsch_symbol_lenth = int(
                        j_line['DlData_PdschGrantL1sw.numOfPdschSymbols'])
                    flag_pdsch_this_slot = True
                    pdsch_symbol_list = []
                    for i in range(pdsch_start_symbol,
                                   pdsch_start_symbol + pdsch_symbol_lenth):
                        pdsch_symbol_list.append(str(i))
                    pdsch_symbol_set = set(pdsch_symbol_list)

                    if csi_symbol_set.intersection(
                            pdsch_symbol_set):   # 有交集，则没muting
                        flag_muting = False
                        if csirsMuting == flag_muting:
                            print(
                                'OK, target No Muting:' +
                                j_line['3gpp.sfn'] +
                                '-' +
                                j_line['3gpp.slot'])
                            pass_num += 1
                        else:
                            print('NOK, target Muting: pdsch should not scheduled in csi-RS symbol.',
                                  j_line['3gpp.sfn'] + '-' + j_line['3gpp.slot'])
                            ERR_num += 1
                        print(
                            'csi_symbols:',
                            csi_symbol_set,
                            csi_resource_set,
                            '\t',
                            'cell ' +
                            csi_other_csirsGroup_physcell)
                        print(
                            'pdsch_symbols:',
                            pdsch_symbol_list,
                            'csirsMuting cell ' +
                            pdsch_muting_physcell_Id,
                            '\n')

                    else:   # 无交集则muting
                        flag_muting = True
                        if csirsMuting == flag_muting:
                            print(
                                'OK, target Muting:' +
                                j_line['3gpp.sfn'] +
                                '-' +
                                j_line['3gpp.slot'])
                            pass_num += 1
                        else:
                            print(
                                'NOK: target No Muting, but not muting is expected.')
                            ERR_num += 1
                        print(
                            'csi_symbols:',
                            csi_symbol_set,
                            csi_resource_set,
                            '\t',
                            'cell ' +
                            csi_other_csirsGroup_physcell)
                        print(
                            'pdsch_symbols:',
                            pdsch_symbol_list,
                            'csirsMuting cell ' +
                            pdsch_muting_physcell_Id,
                            '\n')
                    break
            if not flag_pdsch_this_slot:
                print(i_line['3gpp.sfn'] + '-' + i_line['3gpp.slot'],
                      'INF:No pdsch scheduled in this slot on csirsMuting cell',
                      pdsch_muting_physcell_Id,
                      '\n')

    print('ERR_num:', ERR_num)
    print('Pass_num:', pass_num)
    if ERR_num:
        print('---Fail---')
        raise Exception('Fail')
    else:
        print('---PASS---')

# check_csirsMuting('BIP_UE1234_case6.csv', '52', '50', False)
# check_csirsMuting('BIP_UE1234_case6.csv', '50', '52', False)
# check_csirsMuting('BIP_UE1234_case7.csv', '52', '50', True)
# check_csirsMuting('BIP_UE1234_case7.csv', '50', '52', True)


def check_12269_TRS_nonTRS_diff_slot(bip_csv, csirs_set3_period):
    print('check point : sub-band TRS and cell specific CSI-RS are in different slots\n')
    with open(bip_csv, 'r') as infile:
        list_bip = list(csv.DictReader(infile))

    csirs_set3_period = int(csirs_set3_period)
    nonTRS_slot = []
    TRS_slot = []
    for i_line in list_bip:
        # get slot of nonTRS /cell specific CSI-RS
        if i_line['DlData_CsiRsResourceL1sw_t.trsInfo'].startswith('0'):
            sfn = int(i_line['3gpp.sfn'])
            slot = int(i_line['3gpp.slot'])
            slot_in_csi_period = (sfn * 20) % csirs_set3_period + slot
            nonTRS_slot.append(slot_in_csi_period)
        elif i_line['DlData_CsiRsResourceL1sw_t.trsInfo'].startswith('1'):
            sfn = int(i_line['3gpp.sfn'])
            slot = int(i_line['3gpp.slot'])
            slot_in_csi_period = (sfn * 20) % csirs_set3_period + slot
            TRS_slot.append(slot_in_csi_period)
    set_nonTRS_slot = set(nonTRS_slot)
    set_TRS_slot = set(TRS_slot)
    list_nonTRS = sorted(list(set_nonTRS_slot))
    list_TRS = sorted(list(set_TRS_slot))

    print('TRS slot:', list_TRS)
    print('cell specific non-TRS CSI slot:', list_nonTRS)

    if set_TRS_slot.intersection(set_nonTRS_slot):  # 有交集
        print('ERR: sub-band TRS and cell specific CSI-RS should be allocated in different slots.')
        raise Exception('Fail')
    else:
        print('------Pass------\n')


# check_12269_TRS_nonTRS_diff_slot('BIP_case1.csv', csirs_set3_period='320')


def check_12269_subTRS_same_slot_in_same_L1Pool(bip_csv, *physcell_in_this_L1pool):
    print('check point : sub-band TRS for different cells in the same L1 pool are allocated in the same slot\n')
    print(
        'physcell_Id in the same L1Pool:',
        physcell_in_this_L1pool)
    with open(bip_csv, 'r') as infile:
        list_bip = list(csv.DictReader(infile))
    list_set = []
    for cell in physcell_in_this_L1pool:
        print('cell:', cell)
        set_TRS_slot = set()
        for i_line in list_bip:
            if i_line['DlData_CsiRsResourceL1sw_t.csiRsScramblingSequenceInt'].startswith(
                    cell) and i_line['DlData_CsiRsResourceL1sw_t.trsInfo'].startswith('1'):
                set_TRS_slot.add(
                    i_line['3gpp.sfn'] + '-' + i_line['3gpp.slot'])
        print(set_TRS_slot)
        list_set.append(set_TRS_slot)

    for i in range(len(list_set) - 1):        # check 集合相等
        if list_set[i] != list_set[i + 1]:
            print('ERR: TRS slot not same in different cells in same L1pool.')
            print('diff:', list_set[i] ^ list_set[i + 1])
            raise Exception('Fail')
    print('------Pass------')

# check_12269_subTRS_same_slot_in_same_L1Pool('BIP_case1.csv', '50', '52')


class cell_TRS_RB_alloc:
    physCellId = '-'
    start_RB = '-'
    num_RB = '-'

    def info(self):
        print(
            'physcell:',
            self.physCellId,
            '\tstart_RB:',
            self.start_RB,
            '\tnum_RB:',
            self.num_RB)


def check_12269_subTRS_diff_RB_allocation_for_cells(bip_csv, numRB_TRS, *startRB):
    '''
    :param bip_csv:
    :param numRB_TRS:
    :param startRB: 参数数量与cell个数相同，即输入所有celld的TRS startRB
    '''
    print(
        'check point: different cells have different RB allocations, start_RB:',
        startRB,
        '\n')
    with open(bip_csv, 'r') as infile:
        list_bip = list(csv.DictReader(infile))

    # get physcell list
    set_physcell = set()
    for i_line in list_bip:
        if i_line['DlData_CsiRsResourceL1sw_t.trsInfo'].startswith('0'):    # not TRS
            continue
        physcell = i_line['DlData_CsiRsResourceL1sw_t.csiRsScramblingSequenceInt']
        if physcell:
            physcell = re.findall(r'\d+', physcell)[0]
            set_physcell.add(physcell)
    list_physcell = sorted(list(set_physcell))
    print('physcells:', list_physcell)

    # check start RB allocation diff in cells according to input start RB
    list_RB_alloc = []
    for cell in list_physcell:
        # print('physcell:', cell)
        set_RB = set()
        for i_line in list_bip:
            if i_line['DlData_CsiRsResourceL1sw_t.csiRsScramblingSequenceInt'].startswith(
                    cell) and i_line['DlData_CsiRsResourceL1sw_t.trsInfo'].startswith('1'):
                start_PRB = re.findall(
                    r'\d+', i_line['DlData_CsiRsResourceL1sw_t.startPrb'])[0]
                num_PRB = re.findall(
                    r'\d+', i_line['DlData_CsiRsResourceL1sw_t.numOfPrb'])[0]
                RB_tuple = (int(start_PRB), int(num_PRB))
                set_RB.add(RB_tuple)
        # print(len(set_RB))    # should==1
        cell_TRS_RB_alloc_ = cell_TRS_RB_alloc()
        cell_TRS_RB_alloc_.physCellId = cell
        cell_TRS_RB_alloc_.start_RB = start_PRB
        cell_TRS_RB_alloc_.num_RB = num_PRB
        cell_TRS_RB_alloc_.info()
        list_RB_alloc.append(cell_TRS_RB_alloc_)

    ERR = 0
    for i in range(len(startRB)):
        if startRB[i] != list_RB_alloc[i].start_RB:
            print(
                '\nERR: cell',
                list_RB_alloc[i].physCellId,
                'target startRB:',
                startRB[i],
                'but got',
                list_RB_alloc[i].start_RB)
            ERR += 1
        if numRB_TRS != list_RB_alloc[i].num_RB:
            print(
                '\nERR: cell',
                list_RB_alloc[i].physCellId,
                'num_TRS_RB should be:',
                numRB_TRS,
                'but got',
                list_RB_alloc[i].num_RB)
            ERR += 1
    if ERR:
        raise Exception('Fail')
    else:
        print('------Pass------')

# check_12269_subTRS_diff_RB_allocation_for_cells('BIP_case1.csv', '52', '0', '80', '160')


class pdsch_SLIV:
    SLIV = '-'
    start = '-'
    length = '-'

    def __init__(self, SLIV):
        # SLIV_DL14 mapping
        self.SLIV = int(SLIV)
        if self.SLIV == 27:
            self.start = 0
            self.lenth = 14
        elif self.SLIV == 40:
            self.start = 1
            self.lenth = 13
        elif self.SLIV == 54:
            self.start = 1
            self.lenth = 12
        elif self.SLIV == 41:
            self.start = 0
            self.lenth = 13
        elif self.SLIV == 53:
            self.start = 2
            self.lenth = 12
        elif self.SLIV == 55:
            self.start = 0
            self.lenth = 12
        elif self.SLIV == 66:
            self.start = 3
            self.lenth = 11
        elif self.SLIV == 40:
            self.start = 1
            self.lenth = 13
        elif self.SLIV == 66:
            self.start = 3
            self.lenth = 11
        elif self.SLIV == 82:
            self.start = 1
            self.lenth = 10
        elif self.SLIV == 68:
            self.start = 1
            self.lenth = 11
        elif self.SLIV == 81:
            self.start = 2
            self.lenth = 10
        elif self.SLIV == 95:
            self.start = 2
            self.lenth = 9
        elif self.SLIV == 94:
            self.start = 3
            self.lenth = 9
        elif self.SLIV == 87:
            self.start = 3
            self.lenth = 7
        elif self.SLIV == 100:
            self.start = 2
            self.lenth = 8
        elif self.SLIV == 96:
            self.start = 1
            self.lenth = 9
        elif self.SLIV == 99:
            self.start = 1
            self.lenth = 8
        elif self.SLIV == 86:
            self.start = 2
            self.lenth = 7
        elif self.SLIV == 73:
            self.start = 3
            self.lenth = 6
        elif self.SLIV == 67:
            self.start = 2
            self.lenth = 11
        elif self.SLIV == 80:
            self.start = 3
            self.lenth = 10

    def info(self):
        print(
            'SLIV:',
            self.SLIV,
            '\tstart:',
            self.start,
            '\tlength:',
            self.lenth)


def check_csirsMuting_tti(tti_csv_path, pdsch_muting_physcell_Id='52', csi_other_csirsGroup_physcell='50',
                          csirsMuting=True, rdDynamicScheduling=False, rdspectralEfficiencyThd=16, low_SE=False):
    print('pdsch_muting_physcell_Id:', pdsch_muting_physcell_Id)
    print('csi_other_csirsGroup_physcell:', csi_other_csirsGroup_physcell)
    print('csirsMuting:', csirsMuting)
    print('rdDynamicScheduling:', rdDynamicScheduling)
    if rdDynamicScheduling:
        print('rdspectralEfficiencyThd:', rdspectralEfficiencyThd)
        print('target_low_SE:', low_SE, '\n')
    with open(tti_csv_path, 'r') as infile:
        list_tti = list(csv.DictReader(infile))
    list_tti_copy = list_tti.copy()
    list_tti_copy_2 = list_tti.copy()

    pass_num = 0
    ERR_num = 0
    pass_lowSE_overlap_num = 0
    ERR_low_SE_not_overlap_num = 0
    ZAB_num = 0
    pdsch_schedule_num = 0
    UE_specific_csi = 0
    cell_specific_csi = 0
    for i_line in list_tti:
        # step1: find csi
        if i_line['physCellId'] == csi_other_csirsGroup_physcell and i_line['csiRsSchedData.startSymbol']:
            if i_line['csiRsSchedData.csiRsConfig'].startswith('4'):
                print('UE specific CSI-RS')
                UE_specific_csi += 1
            elif i_line['csiRsSchedData.csiRsConfig'].startswith('8'):
                print('cell specific CSI-RS')
                cell_specific_csi += 1
            index_csi = list_tti.index(i_line)
            sfn_csi = i_line['sfn']
            slot_csi = i_line['slot']
            csi_start_symbol = int(float(i_line['csiRsSchedData.startSymbol']))
            print(
                '----------csi start symbol:',
                csi_start_symbol,
                '\t',
                sfn_csi + '-' + slot_csi)
            # step2: find pdsch in the same slot in taret cell
            flag_pdsch = False
            for j_line in list_tti_copy[index_csi:]:
                if j_line['sfn'] == sfn_csi and j_line['slot'] == slot_csi and j_line[
                        'physCellId'] == pdsch_muting_physcell_Id and j_line['dlFdSchedData.SLIV']:  # 目标cell有pdsch调度
                    flag_pdsch = True
                    pdsch_schedule_num += 1
                    pdsch_sfn = int(j_line['sfn'])
                    # step3: check if curr time the target cell has ZAB
                    # previledge,往回找最近一次的hasZabPrivilege
                    flag_find_ZAB = False
                    ZAB_period_sfn = 5   # hardcode according to ttitrace :5 sfn
                    for k_line in list_tti_copy_2[index_csi::-1]:
                        if k_line['dlAllocatedPooledResourcesData.hasZabPrivilege'] and k_line[
                                'physCellId'] == pdsch_muting_physcell_Id:
                            ZAB_sfn = int(k_line['sfn'])
                            if pdsch_sfn - ZAB_sfn < 0:     # 遇到1024
                                diff_pdsch_ZAB_sfn = 1024 - ZAB_sfn + pdsch_sfn     # pdsch在后，ZAB在前
                            else:
                                diff_pdsch_ZAB_sfn = pdsch_sfn - ZAB_sfn
                            if diff_pdsch_ZAB_sfn < ZAB_period_sfn:
                                flag_find_ZAB = True
                            ZAB_flag = int(
                                float(
                                    k_line['dlAllocatedPooledResourcesData.hasZabPrivilege']))
                            print(
                                'ZAB:',
                                ZAB_flag,
                                '\t',
                                k_line['sfn'] +
                                '-' +
                                k_line['slot'])
                            break
                    if not flag_find_ZAB:
                        continue
                    # step4: check with ZAB flag
                    curr_sliv = pdsch_SLIV(
                        int(float(j_line['dlFdSchedData.SLIV'])))
                    curr_sliv.info()
                    # print('pdsch_SLIV:'+j_line['sfn']+'-'+j_line['slot'])
                    pdsch_end_symbol = curr_sliv.start + curr_sliv.lenth - 1
                    curr_Txnum = int(float(j_line['dlFdSchedData.txNumber']))

                    # ZAB_flag = 0
                    if not ZAB_flag:    # 应无交集:
                        if csi_start_symbol > pdsch_end_symbol:
                            pass_num += 1
                            print(
                                'OK: ZAB = False, csi and pdsch symbol not overlapped.\n')
                        else:
                            print(
                                'ERR_nonZAB: target: csi and pdsch symbol not overlapped, but overlapped.\n')
                            ERR_num += 1
                        continue
                    # ZAB_flag = 1
                    ZAB_num += 1
                    if curr_Txnum > 1 or j_line['dlFdSchedData.dciFormat'] == 'DL_10':
                        print('Txnum:', curr_Txnum, '\t', j_line['dlFdSchedData.dciFormat'])
                        if csi_start_symbol > pdsch_end_symbol:
                            ERR_num += 1
                            print('ERR: reTx or DCI_10, csi and pdsch symbol should overlapp but not.\n')
                        else:
                            print('OK: reTx or DCI_10, csi and pdsch symbol overlapp.\n')
                            pass_num += 1
                        continue    # reTx or DCI_1_0, 应有交集(相当于NIDD muting=false, 走legacy)

                    if not csirsMuting:  # 应有交集
                        if csi_start_symbol <= pdsch_end_symbol:
                            pass_num += 1
                            print(
                                'OK: ZAB + not Muting, csi and pdsch symbol overlapped.\n')
                        else:
                            print(
                                'ERR: target:no Muting, but csi symbol and pdsch symbol not overlapped.\n')
                            ERR_num += 1
                    else:       # csirsMuting=True
                        if rdDynamicScheduling:
                            proposedMCS = int(
                                float(j_line['dlFdSchedData.rrmDlProposedMcs']))
                            if j_line['dlFdSchedData.mcsTable'] == 'QAM256':
                                SE = get_SE(
                                    proposedMCS, proposedMCS_SE_table_256QAM)
                            elif j_line['dlFdSchedData.mcsTable'] == 'QAM64':
                                SE = get_SE(
                                    proposedMCS, proposedMCS_SE_table_64QAM)
                            layers = int(
                                re.findall(
                                    r'\d+',
                                    j_line['dlFdSchedData.numOfLayers'])[0])
                            effectiveSE = SE * layers
                            print(
                                'MCS:',
                                proposedMCS,
                                'SE:',
                                SE,
                                'layer:',
                                layers,
                                'effectiveSE=SE*layers=',
                                effectiveSE,
                                'rdspectralEfficiencyThd=',
                                rdspectralEfficiencyThd)
                            if effectiveSE < rdspectralEfficiencyThd:   # 应有交集
                                print('--SE < rdspectralEfficiencyThd--')
                                if csi_start_symbol <= pdsch_end_symbol:
                                    pass_lowSE_overlap_num += 1
                                    print(
                                        'OK: ZAB + low SE, csi and pdsch symbol overlapped.\n')
                                else:
                                    print(
                                        'ERR: ZAB + low SE, but csi symbol and pdsch symbol not overlapped.\n')
                                    ERR_low_SE_not_overlap_num += 1
                            else:   # 应无交集
                                if csi_start_symbol > pdsch_end_symbol:
                                    pass_num += 1
                                    print(
                                        'OK: ZAB + Muting, csi and pdsch symbol not overlapped.\n')
                                else:
                                    print(
                                        'ERR: target: MUting, but csi symbol and pdsch symbol overlapped.\n')
                                    ERR_num += 1

                        else:   # rdDynamicScheduling=False, 应无交集
                            if csi_start_symbol > pdsch_end_symbol:
                                pass_num += 1
                                print(
                                    'OK: ZAB + Muting, csi and pdsch symbol not overlapped.\n')
                            else:
                                print(
                                    'ERR: target: MUting, but csi symbol and pdsch symbol overlapped.\n')
                                ERR_num += 1
            if not flag_pdsch:
                print('INF: curr csi slot, no pdsch in target cell')
            print('\n')

    print('--------summary-------------')
    print('cell_specific_csi_num:', cell_specific_csi)
    print('UE_specific_csi_num:', UE_specific_csi)
    print('pdsch_schedule_num:', pdsch_schedule_num)
    if not pdsch_schedule_num:
        print('---WRN: no pdsch scheduled in target cell ,slot. if UE specific CSR-RS in this slot, as expected')
    print('ZAB_num:', ZAB_num)
    if not ZAB_num:
        print('---WRN: no ZAB in log')
    print('pass_num:', pass_num)
    print('ERR_num:', ERR_num)
    print('pass_lowSE_overlap_num:', pass_lowSE_overlap_num)
    print('ERR_low_SE_not_overlap_num', ERR_low_SE_not_overlap_num)

    if ERR_num or ERR_low_SE_not_overlap_num:
        raise Exception('Fail: 1, ERR')

    if pdsch_schedule_num and not pass_num and not pass_lowSE_overlap_num:
        raise Exception('Fail: 2, no pass_num')

    if ZAB_num and low_SE and not pass_lowSE_overlap_num:
        raise Exception('Fail: 3, not trigger lowSE US')

    if ZAB_num and pass_lowSE_overlap_num and not ERR_low_SE_not_overlap_num:
        print('---Pass US: low SE < rdspectralEfficiencyThd, overlap happened.---')
    else:
        print('---Pass---')


'''
check_csirsMuting_tti(
    'tti_bad_SE_39_dl_Reorder.csv',
    pdsch_muting_physcell_Id='50',
    csi_other_csirsGroup_physcell='53',
    csirsMuting=True, rdDynamicScheduling=True, rdspectralEfficiencyThd=16, low_SE=True)
'''


def get_data_slot_offset(frame_structure, actInfTddFrameMuting=False):
    if frame_structure == 'tdlte_0ms':
        data_slot_offset = [28, 27, 29, 36, 37]
    elif frame_structure == 'tdlte_3ms':
        data_slot_offset = [24, 23, 25, 34, 35]
    elif frame_structure == 'tdlte_3ms_Canada':
        data_slot_offset = [34, 33, 35, 24, 25]
    elif frame_structure == 'semi_static_14':
        data_slot_offset = [25, 26, 27, 36, 37]
    elif frame_structure == 'semi_static_37':
        data_slot_offset = [32, 31, 35, 22, 25]
    elif frame_structure == 'semi_static_46':  # not test
        data_slot_offset = [32, 31, 36, 22, 26]
    if actInfTddFrameMuting:
        if frame_structure == 'tdlte_0ms':
            data_slot_offset = [30, 27, 31, 36, 37]
        elif frame_structure == 'tdlte_3ms':
            data_slot_offset = [34, 31, 35, 24, 25]
        elif frame_structure == 'tdlte_3ms_Canada':
            data_slot_offset = [34, 31, 35, 24, 25]
        elif frame_structure == 'semi_static_14':
            data_slot_offset = [32, 31, 36, 22, 27]
        elif frame_structure == 'semi_static_37':
            data_slot_offset = [32, 31, 35, 22, 25]
        elif frame_structure == 'semi_static_46':  # not test
            data_slot_offset = [32, 31, 36, 22, 26]
    return data_slot_offset


def get_CSI_IM_slot_offset(frame_structure, actInfTddFrameMuting=False):
    if not actInfTddFrameMuting:
        if frame_structure == 'tdlte_0ms':
            CSI_IM_slot_offset = 26
        elif frame_structure == 'tdlte_3ms':
            CSI_IM_slot_offset = 22
        elif frame_structure == 'tdlte_3ms_Canada':
            CSI_IM_slot_offset = 32
        elif frame_structure == 'semi_static_14':
            CSI_IM_slot_offset = 22
        elif frame_structure == 'semi_static_37':
            CSI_IM_slot_offset = 30
        elif frame_structure == 'semi_static_46':   # not test
            CSI_IM_slot_offset = 30
    else:
        if frame_structure == 'tdlte_0ms':
            CSI_IM_slot_offset = 26
        elif frame_structure == 'tdlte_3ms':
            CSI_IM_slot_offset = 30
        elif frame_structure == 'tdlte_3ms_Canada':
            CSI_IM_slot_offset = 30
        elif frame_structure == 'semi_static_14':
            CSI_IM_slot_offset = 30
        elif frame_structure == 'semi_static_37':
            CSI_IM_slot_offset = 30
        elif frame_structure == 'semi_static_46':  # not test
            CSI_IM_slot_offset = 30
    return CSI_IM_slot_offset


def get_cell_specific_CSI_RS_slot(
        frame_structure, csi_set3_period, csiGroupId, actInfTddFrameMuting=False):
    csi_set3_period = int(csi_set3_period)
    csiGroupId = int(csiGroupId)
    data_slot_offset = get_data_slot_offset(frame_structure, actInfTddFrameMuting)
    CSI_IM_slot_offset = get_CSI_IM_slot_offset(frame_structure, actInfTddFrameMuting)

    maxCsiRsPoolingGroups = 3   # hardcode here
    RS4_slot = -1
    RS2_slot = -1
    RS1_slot = -1
    CSI_IM_slot = -1

    if csi_set3_period == 40:
        RS4_slot = data_slot_offset[csiGroupId]
        CSI_IM_slot = CSI_IM_slot_offset
        if csiGroupId == 0:
            RS2_slot = data_slot_offset[3]
            RS1_slot = data_slot_offset[3] + 80
        elif csiGroupId == 1:
            RS2_slot = data_slot_offset[3] + 40
            RS1_slot = data_slot_offset[3] + 120
        elif csiGroupId == 2:
            RS2_slot = data_slot_offset[4] + 80
            RS1_slot = data_slot_offset[4]
    elif csi_set3_period == 80:
        if csiGroupId == 0:
            RS4_slot = data_slot_offset[csiGroupId] + 40
            CSI_IM_slot = CSI_IM_slot_offset + 40
            RS2_slot = data_slot_offset[csiGroupId]
            RS1_slot = data_slot_offset[3]
        elif csiGroupId == 1:
            RS4_slot = data_slot_offset[csiGroupId]
            CSI_IM_slot = CSI_IM_slot_offset
            RS2_slot = data_slot_offset[3] + 40
            RS1_slot = data_slot_offset[csiGroupId] + 40
        elif csiGroupId == 2:
            RS4_slot = data_slot_offset[csiGroupId]
            CSI_IM_slot = CSI_IM_slot_offset
            RS2_slot = data_slot_offset[csiGroupId] + 40
            RS1_slot = data_slot_offset[4]
    elif csi_set3_period == 160 or csi_set3_period == 320:
        RS4_slot = data_slot_offset[csiGroupId] + \
            (csiGroupId % maxCsiRsPoolingGroups) * 40
        CSI_IM_slot = CSI_IM_slot_offset + \
            (csiGroupId % maxCsiRsPoolingGroups) * 40
        RS2_slot = data_slot_offset[csiGroupId] + \
            ((csiGroupId + 1) % maxCsiRsPoolingGroups) * 40
        RS1_slot = data_slot_offset[csiGroupId] + \
            ((csiGroupId + 2) % maxCsiRsPoolingGroups) * 40

    curr_csiGroup_RS421_csiIM_slot = [
        RS4_slot, RS2_slot, RS1_slot, CSI_IM_slot]
    return curr_csiGroup_RS421_csiIM_slot


def print_all_cell_specific_and_csiIM_slot():
    list_actInfTddFrameMuting = [False, True]
    list_frame_structure = [
        'tdlte_0ms',
        'tdlte_3ms',
        'tdlte_3ms_Canada',
        'semi_static_14',
        'semi_static_37',
        'semi_static_46']
    list_csi_period = [40, 80, 160, 320]
    list_csiGroupId = [0, 1, 2]
    for actInfTddFrameMuting in list_actInfTddFrameMuting:
        for frame_structure in list_frame_structure:
            for csi_set3_period in list_csi_period:
                print('---',
                      frame_structure, '/',
                      'csi_set3_period=', csi_set3_period, '/',
                      'actInfTddFrameMuting=', actInfTddFrameMuting,
                      '\n[RS4,RS2,RS1,CSI-IM] slot:')
                for csi_GroupId in list_csiGroupId:
                    print(
                        get_cell_specific_CSI_RS_slot(
                            frame_structure,
                            csi_set3_period,
                            csi_GroupId,
                            actInfTddFrameMuting),
                        '\tcsi_GroupId',
                        csi_GroupId)
            print('\n')


# print_all_cell_specific_and_csiIM_slot()


def get_TRS_slot(frame_structure, actTddCsirsAllocOptimization=False, numberOfTransmittedSsBlocks=6):
    numberOfTransmittedSsBlocks = int(numberOfTransmittedSsBlocks)
    if numberOfTransmittedSsBlocks < 5:
        return [20, 21]
    if frame_structure == 'tdlte_0ms':
        target_TRS_slot = [20, 21, 18, 19]
    elif frame_structure == 'tdlte_3ms':
        target_TRS_slot = [20, 21, 15, 16]
    elif frame_structure == 'tdlte_3ms_Canada':
        target_TRS_slot = [20, 21, 22, 23]
    elif frame_structure == 'semi_static_14':
        target_TRS_slot = [20, 21, 16, 17]
    elif frame_structure == 'semi_static_37':
        target_TRS_slot = [20, 21, 15, 16]
    elif frame_structure == 'semi_static_46':   # not cover
        target_TRS_slot = [20, 21, 16]
    if actTddCsirsAllocOptimization:
        if frame_structure == 'tdlte_0ms':
            target_TRS_slot = [20, 21, 36, 37]
        elif frame_structure == 'tdlte_3ms_Canada':
            target_TRS_slot = [20, 21, 30, 31]
        elif frame_structure == 'semi_static_46':  # not cover
            target_TRS_slot = [20, 21, 31, 32]
    return target_TRS_slot


def check_TRS_slot_allocation(bip_csv_file, frame_structure, csirsTrackingPeriod_ms,
                              actTddCsirsAllocOptimization=False, numberOfTransmittedSsBlocks=6):
    '''
    :param bip_csv_file:
    :param csirsTrackingPeriod_ms: the value of NIDD csirsTrackingPeriod
    :param frame_structure:
    :return:
    '''
    print('INF: for input parameter frame_structure:')
    print('you can input one of: tdlte_0ms/tdlte_3ms/tdlte_3ms_Canada/semi_static_14/semi_static_37/semi_static_46')
    TRS_period = int(csirsTrackingPeriod_ms) / 10 * 20  # 1 sfn = 10 ms
    print(
        '---input---:\ncsirsTrackingPeriod_ms:',
        csirsTrackingPeriod_ms,
        'ms\nframe_structure:',
        frame_structure,
        '\n---')
    target_TRS_slot = get_TRS_slot(frame_structure, actTddCsirsAllocOptimization, numberOfTransmittedSsBlocks)
    print('check point: TRS slot', target_TRS_slot, '\n---')

    with open(bip_csv_file, 'r') as infile:
        list_bip = list(csv.DictReader(infile))
    set_TRS_slot_bip = set()

    ERR_num = 0
    pass_num = 0
    for i_line in list_bip:
        if i_line['DlData_CsiRsResourceL1sw_t.trsInfo'].startswith('1'):
            curr_sfn = int(i_line['3gpp.sfn'])
            curr_slot = int(i_line['3gpp.slot'])
            curr_TRS_slot = int((curr_sfn * 20) % TRS_period + curr_slot)
            set_TRS_slot_bip.add(curr_TRS_slot)
            if curr_TRS_slot not in target_TRS_slot:
                print(
                    'ERR: curr TRS slot:',
                    curr_TRS_slot,
                    i_line['3gpp.sfn'] +
                    '-' +
                    i_line['3gpp.slot'],
                    'is not target TRS slot',
                    target_TRS_slot)
                ERR_num += 1
            else:
                pass_num += 1
    print('INF: TRS slot in bip:', sorted(list(set_TRS_slot_bip)))
    if set_TRS_slot_bip != set(target_TRS_slot):
        print('ERR: TRS slot in bip not equal to target.', target_TRS_slot)
        raise Exception('Fail_1')
    if not ERR_num and pass_num:
        print('---Check TRS alot allocation ---Pass---\n')
    else:
        raise Exception('Fail_2')

# check_TRS_slot_allocation('BIP_case1_1116_3ms_Canada.csv', csirsTrackingPeriod_ms='80', frame_structure='tdlte_3ms')


def check_TRS_slot_with_pdsch(bip_csv_file, TRS_slot_pdsch=False):
    '''
    :param bip_csv_file:
    :param TRS_slot_pdsch: if ==False,TRS slot not schedule pdsch, if == True,TRS slot can schedule pdsch.
    :return:
    '''
    if TRS_slot_pdsch:
        print('check point: TRS slot can schedule pdsch.')
    else:
        print('check point: TRS slot can NOT schedule pdsch.')

    with open(bip_csv_file, 'r') as infile:
        list_bip = list(csv.DictReader(infile))
    list_bip_cp = list_bip.copy()

    num_TRS_pdsch = 0
    num_TRS_no_pdsch = 0
    for i_line in list_bip:
        if i_line['DlData_CsiRsResourceL1sw_t.trsInfo'].startswith('1'):
            TRS_sfn = int(i_line['3gpp.sfn'])
            TRS_slot = int(i_line['3gpp.slot'])
            physcell = re.findall(
                r'\d+', i_line['DlData_CsiRsResourceL1sw_t.csiRsScramblingSequenceInt'])[0]
            index_TRS = list_bip.index(i_line)
            for j_line in list_bip_cp[index_TRS + 1:]:  # 往下找pdsch
                if j_line['DlData_PdschGrantL1sw.numOfPrb'] and j_line['3gpp.dmrsScramblingSequenceInt'].startswith(
                        physcell):
                    pdsch_sfn = int(j_line['3gpp.sfn'])
                    pdsch_slot = int(j_line['3gpp.slot'])
                    if pdsch_sfn != TRS_sfn or pdsch_slot != TRS_slot:  # TRS slot 无 pdsch
                        num_TRS_no_pdsch += 1
                        if TRS_slot_pdsch:
                            print('WRN: no pdsch in TRS slot:', TRS_sfn,
                                  '-', TRS_slot, 'physcell', physcell)
                        break   # 已经进入非TRS slot
                    else:   # TRS slot 有 pdsch
                        num_TRS_pdsch += 1
                        if not TRS_slot_pdsch:
                            print(
                                'ERR: unexpected pdsch scheduled in TRS slot:',
                                TRS_sfn,
                                '-',
                                TRS_slot,
                                'physcell',
                                physcell)
                        break   # 找到一个就结束

    print('num_TRS_no_pdsch:', num_TRS_no_pdsch)
    print('num_TRS_pdsch', num_TRS_pdsch)
    if not TRS_slot_pdsch:
        if num_TRS_pdsch:
            print('Fali: there should not pdsch in TRS slot.')
            raise Exception('Fail_1')
        else:
            print('---Pass---')
    else:
        if not num_TRS_pdsch:
            print('Fail: there should be pdsch in TRS slot, but not.')
            raise Exception('Fail_2')
        else:
            print('---Pass---')


# check_TRS_slot_with_pdsch('BIP_case1_L1pool_10.csv', TRS_slot_pdsch=False)


def check_12269_subTRSratematch_bip(bip_csv_file, physcellId):
    print(
        '--- check point: TRS slot can schedule pdsch when actSubTRSRateMatch=true ---',
        'physcell:',
        physcellId,
        '\n')
    with open(bip_csv_file, 'r') as infile:
        list_bip = list(csv.DictReader(infile))
    list_bip_cp = list_bip.copy()
    set_TRS_slot = set()
    num_pdsch_in_TRS_slot = 0
    for i_line in list_bip:
        # step1: find TRS
        if i_line['DlData_CsiRsResourceL1sw_t.trsInfo'].startswith(
                '1') and i_line['DlData_CsiRsResourceL1sw_t.csiRsScramblingSequenceInt'].startswith(physcellId):
            TRS_sfn = int(i_line['3gpp.sfn'])
            TRS_slot = int(i_line['3gpp.slot'])
            TRS_slot_in_period = (TRS_sfn * 20) % 160 + \
                TRS_slot  # TRS period=80 ms= 160 slot
            set_TRS_slot.add(TRS_slot_in_period)
            TRS_symbol = i_line['DlData_CsiRsResourceL1sw_t.startSymbol']
            physcell = re.findall(
                r'\d+', i_line['DlData_CsiRsResourceL1sw_t.csiRsScramblingSequenceInt'])[0]
            index_TRS = list_bip.index(i_line)
            # step2: find pdsch in this TRS slot
            curr_pdsch_in_TRS = 0
            for j_line in list_bip_cp[index_TRS + 1:]:  # 往下找pdsch
                if j_line['DlData_PdschGrantL1sw.numOfPrb'] and j_line['3gpp.dmrsScramblingSequenceInt'].startswith(
                        physcellId) and j_line['DlData_PdschGrantL1sw.rateMatchingOption'] == '4':
                    pdsch_sfn = int(j_line['3gpp.sfn'])
                    pdsch_slot = int(j_line['3gpp.slot'])
                    ratematch_symbol_not_pdsch = j_line['DlData_PdschGrantL1sw.symbolRateMatchingPositions']
                    if pdsch_sfn == TRS_sfn and pdsch_slot == TRS_slot:  # curr TRS slot 有 pdsch
                        curr_pdsch_in_TRS += 1
                        print(
                            '\npdsch scheduled in TRS slot',
                            TRS_slot_in_period,
                            '\t',
                            i_line['3gpp.sfn'] +
                            '-' +
                            i_line['3gpp.slot'],
                            'rnti:',
                            j_line['3gpp.rnti'])
                    else:   # curr TRS slot has no pdsch
                        break
                    if TRS_symbol == '4,4,5,5,8,8,9,9' and int(
                            ratematch_symbol_not_pdsch) == 816:
                        print('\tratematch_symbol_in_TRS_no_pdsch:4,5,8,9')
                    elif TRS_symbol == '4,4,8,8' and int(ratematch_symbol_not_pdsch) == 272:
                        print('\tratematch_symbol_in_TRS_no_pdsch:4,8')
                    else:
                        print(
                            'ERR: TRS symbol:',
                            TRS_symbol,
                            'ratematch_symbol:',
                            ratematch_symbol_not_pdsch,
                            'not matched')
            if not curr_pdsch_in_TRS:
                print('---WRN: curr TRS no pdsch')
            num_pdsch_in_TRS_slot += curr_pdsch_in_TRS
    if not num_pdsch_in_TRS_slot:
        print('ERR: no pdsch in TRS slot.')
        raise Exception('Fail_1.')
    else:
        print('---Pass---')

# check_subTRSratematch('BIP_case9.csv', physcellId='50')


def check_tti_DCI_10_not_in_TRS_slot(tti_csv, *TRS_slot, csirsTrackingPeriod_ms=80):
    print('---check point: pdsch with DCI_10 should NOT scheduled in TRS slot---')
    for i in TRS_slot:
        i = int(i)
    print('TRS slot:', TRS_slot)
    TRS_period_slot = int(csirsTrackingPeriod_ms) / 10 * 20  # 1 sfn = 10 ms
    with open(tti_csv, 'r') as infile:
        list_tti = list(csv.DictReader(infile))
    ERR_num = 0
    for i_line in list_tti:
        if i_line['dlFdSchedData.dciFormat'].startswith('DL_10'):
            slot_in_TRS_period = int(
                (int(i_line['sfn']) * 20) % TRS_period_slot + int(i_line['slot']))
            if slot_in_TRS_period not in TRS_slot:
                print(
                    i_line['dlFdSchedData.dciFormat'],
                    'in slot',
                    slot_in_TRS_period)
            else:
                ERR_num += 1
                print('ERR: DCI_10 should not scheduled in TRS slot.',
                      i_line['sfn'] + '-' + i_line['slot'] + i_line['rnti'])
    if not ERR_num:
        print('---Pass---')
    else:
        raise Exception('Fail')

# check_tti_DCI_10_not_in_TRS_slot('tti_case9_HO_dl_Reorder.csv',20,21,22,23,csirsTrackingPeriod_ms=80)


def _get_curr_UE_info_in_egate(
        list_egate_log, index_start_line, index_stop_line):
    RS4 = False
    RS2 = False
    RS1 = False
    RS = ''
    index = index_start_line
    for i_line in list_egate_log[index_start_line:index_stop_line]:
        if 'ue_register id=' in i_line:
            ue_id = re.findall('ue_register id=(.*?)\n', i_line)[0]
            print('\n------UE', ue_id, '-----')
        if 'nzp-CSI-RS-ResourceId 183' in i_line:
            RS4 = True
            index_RS4 = index
        if 'nzp-CSI-RS-ResourceId 181' in i_line:
            RS2 = True
            index_RS2 = index
        if 'nzp-CSI-RS-ResourceId 0' in i_line:
            RS1 = True
            index_RS1 = index
        if 'csi-IM-ResourceId' in i_line:
            index_csiIM = index
        if 'drx-onDurationTimer milliSeconds' in i_line:
            DRX_duration_slot = int((re.findall(r'\d+', i_line)[0])) / 10 * 20
            # print(i_line)
        if 'drx-LongCycleStartOffset' in i_line:
            DRX_period_slot = int((re.findall(r'\d+', i_line)[0])) / 10 * 20
            DRX_start_slot = int((re.findall(r'\d+', i_line)[1])) / 10 * 20

            # print(i_line)
        if 'drx-SlotOffset 16' in i_line:
            DRX_start_slot += 1
            # print(i_line)
        # if 'drx-SlotOffset 0' in i_line:
            # print(i_line)
        index += 1
    DRX_end_slot = int(DRX_start_slot + DRX_duration_slot - 1)
    print('DRX_on_duration_slot:', int(DRX_start_slot), '-', DRX_end_slot)
    if RS4:
        print('RS4')
        RS = 'RS4'
        for i_line in list_egate_log[index_RS4:index_csiIM]:
            if 'periodicityAndOffset slots' in i_line:
                csi_period = int(re.findall(r'\d+', i_line)[0])
                csi_slot = int(re.findall(r'\d+', i_line)[1])
                # print('CSI-RS:',i_line)
    elif RS2:
        print('RS2')
        RS = 'RS2'
        for i_line in list_egate_log[index_RS2:index_csiIM]:
            if 'periodicityAndOffset slots' in i_line:
                csi_period = int(re.findall(r'\d+', i_line)[0])
                csi_slot = int(re.findall(r'\d+', i_line)[1])
                # print('CSI-RS:', i_line)
    else:   # RS1
        print('RS1')
        RS = 'RS1'
        for i_line in list_egate_log[index_RS1:index_csiIM]:
            if 'periodicityAndOffset slots' in i_line:
                csi_period = int(re.findall(r'\d+', i_line)[0])
                csi_slot = int(re.findall(r'\d+', i_line)[1])
                # print('CSI-RS:', i_line)
    # csi-im
    for i_line in list_egate_log[index_csiIM:index_stop_line]:
        if 'periodicityAndOffset slots' in i_line:
            # csiIM_period = int(re.findall(r'\d+', i_line)[0])
            csiIM_slot = int(re.findall(r'\d+', i_line)[1])
            # print('CSI-IM:', i_line)
    # DRX info
    # for i_line in
    print(
        'CSI_period_slot:',
        csi_period,
        '\tCSI-RS slot:',
        csi_slot,
        '\tCSI-IM slot:',
        csiIM_slot)
    print('DRX_period_slot:', int(DRX_period_slot))

    flag_csi_in_duration = False
    flag_csiIM_in_duration = False
    if csi_period >= DRX_period_slot:
        list_duration_in_csi_period = []
        n = int(csi_period / DRX_period_slot)
        for i in range(0, n):
            DRX_start_slot += DRX_period_slot * i
            DRX_end_slot += DRX_period_slot * i
            DRX_end_slot %= csi_period  # 可能会超出周期大小，取余yu
            DRX_on_duration = [int(DRX_start_slot), int(DRX_end_slot)]
            list_duration_in_csi_period.append(DRX_on_duration)
        print('list_duration_in_csi_period:', list_duration_in_csi_period)

        for duration in list_duration_in_csi_period:
            if duration[0] < duration[1]:  # 没跨周期尾
                if duration[0] <= csi_slot <= duration[1]:
                    flag_csi_in_duration = True
                    print('---csi in DRX on-duration---')
                    break
            else:
                if duration[1] <= csi_slot <= csi_period - \
                        1 or 0 <= csi_slot <= duration[0]:
                    flag_csi_in_duration = True
                    print('---csi in DRX on-duration---')
                    break

        if not flag_csi_in_duration:
            print('---WRN: csi outside DRX on-duration---')

        for duration in list_duration_in_csi_period:
            if duration[0] < duration[1]:  # 没跨周期尾
                if duration[0] <= csiIM_slot <= duration[1]:
                    flag_csiIM_in_duration = True
                    print('---csi-im in DRX on-duration---')
                    break
            else:
                if duration[1] <= csiIM_slot <= csi_period - \
                        1 or 0 <= csiIM_slot <= duration[0]:
                    flag_csiIM_in_duration = True
                    print('---csi-im in DRX on-duration---')
                    break

        if not flag_csiIM_in_duration:
            print('---WRN: csi-im outside DRX on-duration---')

    if csi_period < DRX_period_slot:    # 一个DRX 窗口内有多个csi
        list_csi_in_DRX_period = []
        list_csiIM_in_DRX_period = []
        n = int(DRX_period_slot / csi_period)
        for i in range(0, n):
            csi_slot += csi_period * i  # 可能会超出周期
            csi_slot %= DRX_period_slot
            list_csi_in_DRX_period.append(int(csi_slot))
            csiIM_slot += csi_period * i
            csiIM_slot %= DRX_period_slot
            list_csiIM_in_DRX_period.append(int(csiIM_slot))
        print('list_csi_in_DRX_period:', list_csi_in_DRX_period)
        print('list_csiIM_in_DRX_period:', list_csiIM_in_DRX_period)
        for csi in list_csi_in_DRX_period:  # 只要有一个csi落在当前UE的DRX on-duration上即可
            if DRX_start_slot <= csi <= DRX_end_slot:
                flag_csi_in_duration = True
                print('---csi in DRX on-duration---')
                break
        if not flag_csi_in_duration:
            print('---WRN: csi outside DRX on-duration---')
        for csiIM in list_csiIM_in_DRX_period:
            if DRX_start_slot <= csiIM <= DRX_end_slot:
                flag_csiIM_in_duration = True
                print('---csi in DRX on-duration---')
                break
        if not flag_csiIM_in_duration:
            print('---WRN: csi-im outside DRX on-duration---')

    return flag_csi_in_duration & flag_csiIM_in_duration, RS


def check_12269_CSI_rs_in_DRX_duration(
        egate_log_path, original_RS='RS4', target_outside_on_duration=True, target_CSI_downgrage=False):
    '''
    :param egate_log_path:
    :param original_RS: if no CSI-RS downgrade, the RS shoud be original_RS. robot文件使用时此参数不加引号.
    :param target_outside_on_duration: if true, csi-rs/im is expected to be outside DRX on-duration.
    :param target_CSI_downgrage:
    :return:
    '''
    with open(egate_log_path, 'r', encoding='utf-8') as infile:
        list_egate_log = infile.readlines()
    list_index_register = []
    for i_line in list_egate_log:
        if 'ue_register id' in i_line:
            index_register = list_egate_log.index(i_line)
            list_index_register.append(index_register)
    # egate log的末行作为list_index_register的末尾元素。
    list_index_register.append(len(list_egate_log) - 1)

    list_flag_in_duration = []
    list_csi_RS = []
    for i in range(len(list_index_register) - 1):
        # print('i=',i)
        flag_csi_and_im_in_duration, RS = _get_curr_UE_info_in_egate(
            list_egate_log, list_index_register[i], list_index_register[i + 1])
        list_flag_in_duration.append(flag_csi_and_im_in_duration)
        list_csi_RS.append(RS)

    flag_outside = False
    for flag in list_flag_in_duration:
        if not flag:
            print('===csi outside DRX on-duration===')
            flag_outside = True
            break
    flag_downgrade = False
    for RS in list_csi_RS:
        if RS != original_RS:
            print('---original_RS:', original_RS, 'downgrade to', RS)
            flag_downgrade = True
            break

    print('\n-----final check----')
    ERR_flag = False
    if target_outside_on_duration:
        if flag_outside:
            print('---pass_1: target Hit: CSI-RS/IM outside DRX on-duration ----')
        else:
            print('---ERR_1: target CSI-RS/IM outside DRX on-duration not happened---')
            ERR_flag = True
    else:   # 预期落在DRX内
        if flag_outside:
            print('---ERR_2: unexpected CSI-RS/IM outside DRX on-duration ---')
            ERR_flag = True
        else:
            print('---pass_2: target Hit: CSI-RS/IM in DRX on-duration ----')

    if target_CSI_downgrage:
        if flag_downgrade:
            print('---pass_3: target Hit: CSI-RS downgrade----')
        else:
            print('---ERR_3: target CSI downgrade not happened---')
            ERR_flag = True
    else:
        if flag_downgrade:
            print('---ERR_4: unexpected CSI-RS downgrade----')
            ERR_flag = True
        else:
            print('---pass_4: No CSI downgrade ---')
    if ERR_flag:
        raise Exception('Fail')


'''
check_12269_CSI_rs_in_DRX_duration(
    'egate_console.log.001',
    target_outside_on_duration=True,
    target_CSI_downgrage=False)
'''

# ------12269_C7_adaptiveReTx-----------------------------------------


def _find_newTx_slot(list_tti_cp, csirs_set3_p, TRS_period_slot, index_reTx, curr_rnti,
                     curr_HarqProcessIndex, set_CSI_RS_slot, set_CSI_IM_slot, list_TRS_slot):
    for j_line in list_tti_cp[index_reTx::-1]:
        if j_line['rnti'] == curr_rnti and j_line[
            'dlFdSchedData.dlHarqProcessIndex'] == curr_HarqProcessIndex and float(
                j_line['dlFdSchedData.txNumber']) == 1:
            newTx_slot_in_csi_period = (
                int(j_line['sfn']) * 20) % csirs_set3_p + int(j_line['slot'])
            newTx_slot_in_TRS_period = (
                int(j_line['sfn']) * 20) % TRS_period_slot + int(j_line['slot'])
            if newTx_slot_in_csi_period in set_CSI_RS_slot:
                # print('~ newTx_CSI-RS_slot:', j_line['sfn'] + '-' + j_line['slot'])
                return 'CSI_RS_slot', j_line['sfn'], j_line['slot']
            elif newTx_slot_in_csi_period in set_CSI_IM_slot:
                # print('~newTx_Im_slot:', j_line['sfn'] + '-' + j_line['slot'])
                return 'CSI_IM_slot', j_line['sfn'], j_line['slot']
            elif newTx_slot_in_TRS_period in list_TRS_slot:
                # print('~ newTx_TRS_slot:', j_line['sfn'] + '-' + j_line['slot'])
                return 'TRS_slot', j_line['sfn'], j_line['slot']
            else:
                # print('~ newTx_data_slot:', j_line['sfn'] + '-' + j_line['slot'])
                return 'data_slot', j_line['sfn'], j_line['slot']
    return '-', '-', '-'    # not find newTx


def _write_reTx_output(fpath, output_list_dict):
    colu_list = [
        'newTx_sfn',
        'newTx_slot',
        'newTx_slot_type',
        'reTx_sfn',
        'reTx_slot',
        'reTx_slot_type',
        'rnti']

    with open(fpath, "w", newline='') as csv_file:
        writer = csv.writer(csv_file, delimiter=',')
        keys = colu_list
        writer.writerow(keys)
        for i in output_list_dict:
            values = []
            for key in colu_list:
                values.append(i[key])
            writer.writerow(values)


def check_tti_reTx_in_TRS_CSI_RS_IM_slot(
        tti_csv, physcellId, frame_startucture, csirs_set3_p, csirsTrackingPeriod_ms=80):
    print('---check point: REtx scheduled in CSI-RS/IM,TRS slot---')
    csirs_set3_p = int(csirs_set3_p)
    TRS_period_slot = int(csirsTrackingPeriod_ms) / 10 * 20  # 1 sfn = 10 ms
    # get TRS slot allocationaccoding to frame structure
    list_TRS_slot = get_TRS_slot(frame_startucture, actTddCsirsAllocOptimization=False,
                                 numberOfTransmittedSsBlocks=6)
    print('TRS_Slot:', list_TRS_slot)

    with open(tti_csv, 'r') as infile:
        list_tti = list(csv.DictReader(infile))
    list_tti_cp = list_tti.copy()
    # find CSI-RS/IM slot in tti
    set_CSI_RS_slot = set()
    set_CSI_IM_slot = set()
    for i_line in list_tti:
        if i_line['physCellId'] == physcellId:
            if i_line['csiRsSchedData.csiRsConfig'].startswith('8'):  # csi-rs
                curr_csi_rs_slot = int(
                    i_line['sfn']) * 20 % csirs_set3_p + int(i_line['slot'])
                set_CSI_RS_slot.add(curr_csi_rs_slot)
            if i_line['csiRsSchedData.csiRsConfig'].startswith('4'):  # csi-im
                curr_csi_im_slot = int(
                    i_line['sfn']) * 20 % csirs_set3_p + int(i_line['slot'])
                set_CSI_IM_slot.add(curr_csi_im_slot)
        if len(set_CSI_RS_slot) >= 3 and len(set_CSI_IM_slot) >= 3:
            break

    print('set_CSI_RS_slot(in tti):', set_CSI_RS_slot)
    print('set_CSI_IM_slot(in tti):', set_CSI_IM_slot)

    num_reTx_csi_slot = 0
    num_reTx_csiIM_slot = 0
    num_reTx_TRS_slot = 0
    num_reTx_data_slot = 0
    set_reTx_in_data_slot_in_csi_period = set()
    set_reTx_in_TRS_slot_in_TRS_period = set()
    set_reTx_in_csi_slot_in_csi_period = set()
    set_reTx_in_csiIm_slot_in_csi_period = set()
    num_newTx_csi_slot = 0
    num_newTx_im_slot = 0
    num_newTx_TRS_slot = 0
    num_newTx_data_slot = 0

    output_list_dict = []

    for i_line in list_tti:
        if not i_line['dlFdSchedData.txNumber']:
            continue
        if i_line['physCellId'] == physcellId and float(
                i_line['dlFdSchedData.txNumber']) > 1:
            slot_in_csi_period = (
                int(i_line['sfn']) * 20) % csirs_set3_p + int(i_line['slot'])
            slot_in_TRS_period = int(
                int(i_line['sfn']) * 20) % TRS_period_slot + int(i_line['slot'])

            curr_rnti = i_line['rnti']
            curr_HarqProcessIndex = i_line['dlFdSchedData.dlHarqProcessIndex']
            index_reTx = list_tti.index(i_line)
            i_dict = {'newTx_sfn': '-',
                      'newTx_slot': '-',
                      'newTx_slot_type': '-',
                      'reTx_sfn': '-',
                      'reTx_slot': '-',
                      'reTx_slot_type': '-',
                      'rnti': '-'}

            # cehck reTx slot type
            if slot_in_csi_period in set_CSI_IM_slot:
                # print('--reTx in csi-IM slot',slot_in_csi_period, '\t' + i_line['sfn'] + '-' + i_line['slot'])
                set_reTx_in_csiIm_slot_in_csi_period.add(slot_in_csi_period)
                num_reTx_csiIM_slot += 1
                newTx_slot_type, newTx_sfn, newTx_slot = _find_newTx_slot(
                    list_tti_cp, csirs_set3_p, TRS_period_slot, index_reTx, curr_rnti, curr_HarqProcessIndex,
                    set_CSI_RS_slot, set_CSI_IM_slot, list_TRS_slot)

                i_dict['newTx_sfn'] = newTx_sfn
                i_dict['newTx_slot'] = newTx_slot
                i_dict['newTx_slot_type'] = newTx_slot_type
                i_dict['reTx_sfn'] = i_line['sfn']
                i_dict['reTx_slot'] = i_line['slot']
                i_dict['reTx_slot_type'] = 'CSI-IM'
                i_dict['rnti'] = curr_rnti

                if newTx_slot_type == 'CSI_RS_slot':
                    num_newTx_csi_slot += 1
                elif newTx_slot_type == 'CSI_IM_slot':
                    num_newTx_im_slot += 1
                elif newTx_slot_type == 'TRS_slot':
                    num_newTx_TRS_slot += 1
                else:
                    num_newTx_data_slot += 1
            elif slot_in_csi_period in set_CSI_RS_slot:
                # print('--reTx in csiRS slot',slot_in_csi_period, '\t' + i_line['sfn'] + '-' + i_line['slot'])
                set_reTx_in_csi_slot_in_csi_period.add(slot_in_csi_period)
                num_reTx_csi_slot += 1
                newTx_slot_type, newTx_sfn, newTx_slot = _find_newTx_slot(
                    list_tti_cp, csirs_set3_p, TRS_period_slot, index_reTx, curr_rnti, curr_HarqProcessIndex,
                    set_CSI_RS_slot, set_CSI_IM_slot, list_TRS_slot)
                i_dict['newTx_sfn'] = newTx_sfn
                i_dict['newTx_slot'] = newTx_slot
                i_dict['newTx_slot_type'] = newTx_slot_type
                i_dict['reTx_sfn'] = i_line['sfn']
                i_dict['reTx_slot'] = i_line['slot']
                i_dict['reTx_slot_type'] = 'CSI-RS'
                i_dict['rnti'] = curr_rnti

                if newTx_slot_type == 'CSI_RS_slot':
                    num_newTx_csi_slot += 1
                elif newTx_slot_type == 'CSI_IM_slot':
                    num_newTx_im_slot += 1
                elif newTx_slot_type == 'TRS_slot':
                    num_newTx_TRS_slot += 1
                else:
                    num_newTx_data_slot += 1

            elif slot_in_TRS_period in list_TRS_slot:
                # print('==reTx in TRS slot', slot_in_TRS_period, '\t' + i_line['sfn'] + '-' + i_line['slot'])
                set_reTx_in_TRS_slot_in_TRS_period.add(int(slot_in_TRS_period))
                num_reTx_TRS_slot += 1
                newTx_slot_type, newTx_sfn, newTx_slot = _find_newTx_slot(
                    list_tti_cp, csirs_set3_p, TRS_period_slot, index_reTx, curr_rnti, curr_HarqProcessIndex,
                    set_CSI_RS_slot, set_CSI_IM_slot, list_TRS_slot)
                i_dict['newTx_sfn'] = newTx_sfn
                i_dict['newTx_slot'] = newTx_slot
                i_dict['newTx_slot_type'] = newTx_slot_type
                i_dict['reTx_sfn'] = i_line['sfn']
                i_dict['reTx_slot'] = i_line['slot']
                i_dict['reTx_slot_type'] = 'TRS'
                i_dict['rnti'] = curr_rnti

                if newTx_slot_type == 'CSI_RS_slot':
                    num_newTx_csi_slot += 1
                elif newTx_slot_type == 'CSI_IM_slot':
                    num_newTx_im_slot += 1
                elif newTx_slot_type == 'TRS_slot':
                    num_newTx_TRS_slot += 1
                else:
                    num_newTx_data_slot += 1
            else:
                # print('>>reTx in data slot:', slot_in_csi_period)
                set_reTx_in_data_slot_in_csi_period.add(slot_in_csi_period)
                num_reTx_data_slot += 1
                newTx_slot_type, newTx_sfn, newTx_slot = _find_newTx_slot(
                    list_tti_cp, csirs_set3_p, TRS_period_slot, index_reTx, curr_rnti, curr_HarqProcessIndex,
                    set_CSI_RS_slot, set_CSI_IM_slot, list_TRS_slot)
                i_dict['newTx_sfn'] = newTx_sfn
                i_dict['newTx_slot'] = newTx_slot
                i_dict['newTx_slot_type'] = newTx_slot_type
                i_dict['reTx_sfn'] = i_line['sfn']
                i_dict['reTx_slot'] = i_line['slot']
                i_dict['reTx_slot_type'] = 'data'
                i_dict['rnti'] = curr_rnti

                if newTx_slot_type == 'CSI_RS_slot':
                    num_newTx_csi_slot += 1
                elif newTx_slot_type == 'CSI_IM_slot':
                    num_newTx_im_slot += 1
                elif newTx_slot_type == 'TRS_slot':
                    num_newTx_TRS_slot += 1
                else:
                    num_newTx_data_slot += 1

            # print('\n')
        output_list_dict.append(i_dict)

    _write_reTx_output('output_reTx.csv', output_list_dict)

    list_reTx_in_data_slot_in_csi_period = sorted(
        list(set_reTx_in_data_slot_in_csi_period))
    list_reTx_in_TRS_slot_in_TRS_period = sorted(
        list(set_reTx_in_TRS_slot_in_TRS_period))
    list_reTx_in_csi_slot_in_csi_period = sorted(
        list(set_reTx_in_csi_slot_in_csi_period))
    list_reTx_in_csiIm_slot_in_csi_period = sorted(
        list(set_reTx_in_csiIm_slot_in_csi_period))

    print('\n----------summary--------------------')
    print('list_reTx_in_data_slot_in_csi_period:',
          list_reTx_in_data_slot_in_csi_period)
    print('num_reTx_data_slot', num_reTx_data_slot)

    print('list_reTx_in_TRS_slot_in_TRS_period:',
          list_reTx_in_TRS_slot_in_TRS_period)
    print('num_reTx_TRS_slot:', num_reTx_TRS_slot)

    print('list_reTx_in_csi_slot_in_csi_period:',
          list_reTx_in_csi_slot_in_csi_period)
    print('num_reTx_csi_slot:', num_reTx_csi_slot)

    print('list_reTx_in_csiIm_slot_in_csi_period:',
          list_reTx_in_csiIm_slot_in_csi_period)
    print('num_reTx_Im_slot:', num_reTx_csiIM_slot)

    # print('\nnum_newTx_data_slot:', num_newTx_data_slot)
    # print('num_reTx_TRS_slot:', num_reTx_TRS_slot)
    # print('num_newTx_csi_slot:', num_newTx_csi_slot)
    # print('num_newTx_im_slot:', num_newTx_im_slot)


'''
check_tti_reTx_in_TRS_CSI_RS_IM_slot(
    'tti_C7_reTx_RS3_im_dl_Reorder_4UE.csv',
    physcellId='50',
    frame_startucture='tdlte_3ms_Canada',
    csirs_set3_p=80)

check_tti_reTx_in_TRS_CSI_RS_IM_slot(
    '2730_L2TtiTrace_EventsSnapshot.bin.0002_5_dl.csv',
    physcellId='51',
    frame_startucture='tdlte_0ms',
    csirs_set3_p=80)
'''


def check_tti_reTx_in_TRS_CSI_RS_IM_slot_2(
        tti_csv, physcellId, frame_startucture, csirsTrackingPeriod_ms=80):
    print('---check point: REtx scheduled in CSI-RS/IM,TRS slot---')

    TRS_period_slot = int(csirsTrackingPeriod_ms) / 10 * 20  # 1 sfn = 10 ms
    # get TRS slot allocationaccoding to frame structure
    list_TRS_slot = get_TRS_slot(frame_startucture, actTddCsirsAllocOptimization=False,
                                 numberOfTransmittedSsBlocks=6)
    print('TRS_Slot:', list_TRS_slot)

    with open(tti_csv, 'r') as infile:
        list_tti = list(csv.DictReader(infile))
    list_tti_cp = list_tti.copy()

    num_reTx_in_IM_slot = 0
    num_reTx_in_CSI_slot = 0
    num_reTx_in_TRS_slot = 0
    num_reTx_in_data_slot = 0

    for i_line in list_tti:
        if not i_line['dlFdSchedData.txNumber']:
            continue
        if i_line['physCellId'] == physcellId and float(
                i_line['dlFdSchedData.txNumber']) > 1:
            index_reTx = list_tti.index(i_line)
            reTx_sfn = i_line['sfn']
            reTx_slot = i_line['slot']
            reTx_rnti = i_line['rnti']
            slot_in_TRS_period = int(
                int(i_line['sfn']) * 20) % TRS_period_slot + int(i_line['slot'])
            for j_line in list_tti_cp[index_reTx::-1]:
                if j_line['sfn'] != reTx_sfn or j_line['slot'] != reTx_slot:  # 离开此slot即结束遍历
                    num_reTx_in_data_slot += 1
                    break
                elif j_line['physCellId'] == physcellId:
                    if j_line['csiRsSchedData.csiRsConfig'].startswith('4'):
                        if j_line['csiRsSchedData.startSymbol'].startswith('13'):
                            IM_set = 'CSI-IM for RS4'
                        elif j_line['csiRsSchedData.startSymbol'].startswith('10'):
                            IM_set = 'CSI-IM for RS2/1'
                        print(
                            '^^^ReTx in CSI-IM slot:',
                            i_line['sfn'] +
                            '-' +
                            i_line['slot'],
                            reTx_rnti,
                            i_line['dlFdSchedData.ackNack'],
                            '\tadaptRetxStatus:', i_line['dlFdSchedData.adaptRetxStatus'],
                            '\tcsiRs_startSymbol', int(float(j_line['csiRsSchedData.startSymbol'])),
                            IM_set)
                        num_reTx_in_IM_slot += 1
                        break
                    elif j_line['csiRsSchedData.csiRsConfig'].startswith('8'):
                        print(
                            '---ReTx in CSI-RS slot:',
                            i_line['sfn'] +
                            '-' +
                            i_line['slot'],
                            reTx_rnti)
                        num_reTx_in_CSI_slot += 1
                        break
                    elif slot_in_TRS_period in list_TRS_slot:
                        print(
                            '===reTx in TRS slot:',
                            i_line['sfn'] +
                            '-' +
                            i_line['slot'],
                            int(slot_in_TRS_period),
                            reTx_rnti)
                        num_reTx_in_TRS_slot += 1
                        break
    print('num_reTx_in_data_slot:', num_reTx_in_data_slot)
    print('num_reTx_in_TRS_slot:', num_reTx_in_TRS_slot)
    print('num_reTx_in_CSI_slot:', num_reTx_in_CSI_slot)
    print('num_reTx_in_IM_slot:', num_reTx_in_IM_slot)

    '''
    # find CS2_NOTALLOWEDDCI11RETXINCSIIMSLOT:
    for i_line in list_tti:
        if 'IM' in i_line['dlPreTdBlockUeData.cs2BlockUeList']:
            print('---block IM happend---')
            return True
    print('___ no IM block')
    '''

    if not num_reTx_in_TRS_slot:
        print('ERR_1: reTx not happened in TRS slot.')
    if not num_reTx_in_CSI_slot:
        print('ERR_2: reTx not happened in CSI-RS slot.')
    if not num_reTx_in_IM_slot:
        print('ERR_3: reTx not happened in CSI-IM slot.')
    if num_reTx_in_TRS_slot and num_reTx_in_CSI_slot and num_reTx_in_IM_slot:
        print('---Pass---')
    else:
        raise Exception('Fail')


def check_bip_12269_TRS_ratematch(
        bip_csv, physcellId, actPdschRmCsirsForTracking=False, actPdschAtSsbSlots=False, actSubTrsRateMatch=False):
    '''
    :param bip_csv:
    :param physcellId:
    :function: 12269_C9
    '''
    print('\n**************** check phscell',
          physcellId, '*******************')
    print('actSubTrsRateMatch:', actSubTrsRateMatch)
    print('actPdschRmCsirsForTracking:', actPdschRmCsirsForTracking)
    print('actPdschAtSsbSlots:', actPdschAtSsbSlots)

    if actPdschRmCsirsForTracking and actSubTrsRateMatch:
        raise Exception(
            'Fail,actPdschRmCsirsForTracking and actSubTrsRateMatch can not be true at the same time.')
    if actPdschRmCsirsForTracking and not actPdschAtSsbSlots:
        raise Exception(
            'Fail: PDL rule: when actPdschRmCsirsForTracking=true,actPdschAtSsbSlots should be true.')

    if actPdschAtSsbSlots:
        print('check point: pdsch can be sheduled in SSB slot.')
    else:
        print('check point: pdsch can NOT be scheduled in SSB slot.')
    if actSubTrsRateMatch:
        print('check point: pdsch can be scheduled in non-TRS symbol in TRS slot.\n')
    if actPdschRmCsirsForTracking:
        print('check point: pdsch can be scheduled in TRS symbol in TRS slot.\n')
    if not actPdschRmCsirsForTracking and not actSubTrsRateMatch:
        print('check point: pdsch can NOT be scheduled in TRS slot.\n')

    with open(bip_csv, 'r') as infile:
        list_bip = list(csv.DictReader(infile))
    list_bip_cp = list_bip.copy()

    # 1. check pdsch with SSB slot
    ERR_pdsch_ssb = False
    num_pdsch_in_SSB_slot = 0
    last_ssb_sfn = -1
    last_ssb_slot = -1
    for i_line in list_bip:   # DlData_SsBlockSendReq 会连续多条出现在相同slot
        if i_line['_ws.col.info'].startswith('DlData_SsBlockSendReqL1sw'):
            index_ssb = list_bip.index(i_line)
            ssb_sfn = i_line['3gpp.sfn']
            ssb_slot = i_line['3gpp.slot']
            if ssb_sfn == last_ssb_sfn and ssb_slot == last_ssb_slot:   # 避免处理相同slot的ssb消息
                continue
            for j_line in list_bip_cp[index_ssb:]:
                if j_line['3gpp.sfn'] != ssb_sfn or j_line['3gpp.slot'] != ssb_slot:    # 离开ssb slot
                    break
                # ssb slot找pdsch:
                if j_line['3gpp.dmrsScramblingSequenceInt'].startswith(physcellId):
                    num_pdsch_in_SSB_slot += 1
            last_ssb_sfn = ssb_sfn
            last_ssb_slot = ssb_slot
    print('num_pdsch_in_SSB_slot:', num_pdsch_in_SSB_slot)
    if actPdschAtSsbSlots:
        if num_pdsch_in_SSB_slot:
            print('---check pdsch in ssb slot Pass---')
        else:
            print('---ERR: no pdsch in ssb slot---')
            ERR_pdsch_ssb = True
    if not actPdschAtSsbSlots:
        if not num_pdsch_in_SSB_slot:
            print('---check pdsch not in ssb slot Pass---')
        else:
            print('---ERR: pdsch should NOT be in ssb slot---')
            ERR_pdsch_ssb = True
    print('\n')

    # 2. check pdsch with TRS slot,symbol
    num_pdsch_ratematch_TRS_slot = 0
    ERR_num = 0
    for i_line in list_bip:
        if i_line['DlData_CsiRsResourceL1sw_t.csiRsScramblingSequenceInt'].startswith(
                physcellId) and i_line['DlData_CsiRsResourceL1sw_t.trsInfo'].startswith('1'):    # find TRS slot
            TRS_sfn = i_line['3gpp.sfn']
            TRS_slot = i_line['3gpp.slot']
            index_TRS = list_bip.index(i_line)

            for j_line in list_bip_cp[index_TRS:]:
                if j_line['3gpp.dmrsScramblingSequenceInt'].startswith(physcellId):  # find pdsch
                    # 离开 TRS slot
                    if TRS_sfn != j_line['3gpp.sfn'] or TRS_slot != j_line['3gpp.slot']:
                        break
                    flag_rateMatchingOption_OK = False
                    flag_symbolRateMatchingPositions_OK = False
                    # pdsch in TRS slot
                    if actPdschRmCsirsForTracking:  # case1: pdsch overlap with TRS symbol
                        if j_line['DlData_PdschGrantL1sw.rateMatchingOption'].startswith('1'):  # RATEMATCHINGCSIRS
                            flag_rateMatchingOption_OK = True
                        else:
                            ERR_num += 1
                            print(
                                'ERR: actPdschRmCsirsForTracking=true,'
                                'rateMatchingOption should be 1:RATEMATCHINGCSIRS,',
                                j_line['3gpp.sfn'] + '-' + j_line['3gpp.slot'])
                        if j_line['DlData_PdschGrantL1sw.symbolRateMatchingPositions'].startswith('0'):
                            # all TRS symbol used for pdsch
                            flag_symbolRateMatchingPositions_OK = True
                        else:
                            ERR_num += 1
                            print(
                                'ERR: actPdschRmCsirsForTracking=true, symbolRateMatchingPositions should be 0,',
                                j_line['3gpp.sfn'] + '-' + j_line['3gpp.slot'])

                        if flag_rateMatchingOption_OK and flag_symbolRateMatchingPositions_OK:
                            num_pdsch_ratematch_TRS_slot += 1
                            # print('OK: pdsch overlap with TRS symbol',j_line['3gpp.sfn']+'-'+j_line['3gpp.slot'])

                    if actSubTrsRateMatch:  # case2: pdsch not overlap with TRS symbol in TRS slot
                        if j_line['DlData_PdschGrantL1sw.rateMatchingOption'].startswith('4'):  # RATEMATCHINGSYMBOL
                            flag_rateMatchingOption_OK = True
                        else:
                            ERR_num += 1
                            print(
                                'ERR: actSubTrsRateMatch=true, rateMatchingOption should be 4:RATEMATCHINGSYMBOL,',
                                j_line['3gpp.sfn'] + '-' + j_line['3gpp.slot'])
                        if not j_line['DlData_PdschGrantL1sw.symbolRateMatchingPositions'].startswith('0'):
                            # not all TRS symbol used for pdsch
                            flag_symbolRateMatchingPositions_OK = True
                        else:
                            ERR_num += 1
                            print(
                                'ERR: actSubTrsRateMatch=true, symbolRateMatchingPositions should not be 0,',
                                j_line['3gpp.sfn'] + '-' + j_line['3gpp.slot'])

                        if flag_rateMatchingOption_OK and flag_symbolRateMatchingPositions_OK:
                            num_pdsch_ratematch_TRS_slot += 1
                            '''
                            print(
                                'OK: pdsch not overlap with TRS symbol in TRS slot',
                                j_line['3gpp.sfn'] + '-' + j_line['3gpp.slot'])
                            '''

                    if not actPdschRmCsirsForTracking and not actSubTrsRateMatch:   # case3: pdsch not in TRS slot
                        print(
                            'ERR: pdsch should not in TRS slot.',
                            j_line['3gpp.sfn'] + '-' + j_line['3gpp.slot'])
                        num_pdsch_ratematch_TRS_slot += 1

    print('ERR_num:', ERR_num)
    print('num_pdsch_ratematch_TRS_slot:', num_pdsch_ratematch_TRS_slot)

    if not actPdschRmCsirsForTracking and not actSubTrsRateMatch:
        if not num_pdsch_ratematch_TRS_slot:
            print('---Pass---no pdsch in TRS slot')
            return True
        else:
            print('ERR: when actPdschRmCsirsForTracking and actSubTrsRateMatch are both false,'
                  'pdsch should not scheduled in TRS slot')
            raise Exception('Fail_1')

    if not ERR_num and num_pdsch_ratematch_TRS_slot:
        print('---check pdsch with TRS slot/symbol Pass---')
    else:
        raise Exception('Fail_2')

    if ERR_pdsch_ssb:
        raise Exception('Fail_3: pdsch with slot check fail.')


'''
check_bip_12269_TRS_ratematch(
    'BIP_C9.csv',
    physcellId='50',
    actPdschRmCsirsForTracking=True,
    actPdschAtSsbSlots=True,
    actSubTrsRateMatch=False)
check_bip_12269_TRS_ratematch(
    'BIP_C9.csv',
    physcellId='51',
    actPdschRmCsirsForTracking=False,
    actPdschAtSsbSlots=False,
    actSubTrsRateMatch=False)
check_bip_12269_TRS_ratematch(
    'BIP_C9.csv',
    physcellId='52',
    actPdschRmCsirsForTracking=False,
    actPdschAtSsbSlots=True,
    actSubTrsRateMatch=True)
'''


def check_csiIM_12269(tti_csv, frame_structure, csi_set3_period, actInfTddFrameMuting=True):
    '''
    :param tti_csv:
    :param frame_structure:
    :param csi_set3_period:
    :param actInfTddFrameMuting:
    :function: when actcsiImRm=true and maxcsirsnumber=4, check the csi-im slot allacation in ttiTrace.
    '''
    list_csiGroup0_RS421_csiIM_slot = get_cell_specific_CSI_RS_slot(frame_structure, csi_set3_period, csiGroupId=0,
                                                                    actInfTddFrameMuting=True)
    list_csiGroup1_RS421_csiIM_slot = get_cell_specific_CSI_RS_slot(frame_structure, csi_set3_period, csiGroupId=1,
                                                                    actInfTddFrameMuting=True)
    # list_csiGroup2_RS421_csiIM_slot = get_cell_specific_CSI_RS_slot(frame_structure, csi_set3_period, csiGroupId=2,
    #                                                                actInfTddFrameMuting=True)
    list_csiGroup0_RS421_csirs_slot = list_csiGroup0_RS421_csiIM_slot[:3]
    list_csiGroup0_RS214_IM_slot = list_csiGroup0_RS421_csiIM_slot[1:]
    list_csiGroup1_RS421_csirs_slot = list_csiGroup1_RS421_csiIM_slot[:3]
    list_csiGroup1_RS214_IM_slot = list_csiGroup1_RS421_csiIM_slot[1:]
    # list_csiGroup2_RS421_csirs_slot = list_csiGroup2_RS421_csiIM_slot[:3]
    # list_csiGroup2_RS214_IM_slot = list_csiGroup2_RS421_csiIM_slot[1:]
    # print('list_csiGroup0_RS421_csirs_slot:',list_csiGroup0_RS421_csirs_slot)
    print('check point:')
    print('list_csiGroup0_RS214_IM_slot:', list_csiGroup0_RS214_IM_slot)
    # print('list_csiGroup1_RS421_csirs_slot:', list_csiGroup1_RS421_csirs_slot)
    print('list_csiGroup1_RS214_IM_slot:', list_csiGroup1_RS214_IM_slot)
    # print('list_csiGroup2_RS421_csirs_slot:', list_csiGroup2_RS421_csirs_slot)
    # print('list_csiGroup2_RS214_IM_slot:', list_csiGroup2_RS214_IM_slot, '\n')
    list_csiGroup_012_IM_slot = [
        set(list_csiGroup0_RS214_IM_slot),
        set(list_csiGroup1_RS214_IM_slot),
        # set(list_csiGroup2_RS214_IM_slot)]
    ]
    csi_set3_period = int(csi_set3_period)
    if csi_set3_period == 40:
        csi_set21_period = 160
    else:
        csi_set21_period = csi_set3_period

    with open(tti_csv, 'r') as infile:
        list_tti = list(csv.DictReader(infile))
    list_tti_cp = list_tti.copy()

    # find all physcell
    set_physcell = set()

    for i_line in list_tti:
        if i_line['csiRsSchedData.csiRsConfig']:
            set_physcell.add(i_line['physCellId'])
            if len(set_physcell) >= 6:
                break

    for i_phycell in set_physcell:
        set_IM_slot = set()
        for i_line in list_tti:
            if i_line['csiRsSchedData.csiRsConfig'].startswith(
                    '4') and i_line['physCellId'] == i_phycell:
                if float(i_line['csiRsSchedData.csiTransmitPower']) < -700:   # csi-IM, for  AP it's -734
                    if i_line['csiRsSchedData.startSymbol'].startswith('13'):   # csi-IM for RS4
                        IM_slot = (
                            int(i_line['sfn']) * 20) % csi_set3_period + int(i_line['slot'])
                    else:   # csi-IM for RS21
                        IM_slot = (
                            int(i_line['sfn']) * 20) % csi_set21_period + int(i_line['slot'])
                    set_IM_slot.add(IM_slot)
                    if len(set_IM_slot) >= 3:
                        if set_IM_slot in list_csiGroup_012_IM_slot:
                            print('OK for cell', i_phycell)
                        else:
                            print('set_IM_slot:', set_IM_slot)
                            print('Fail: wrong csi-IM slot allocation.')
                            raise Exception('Fail: csi-IM slot allacation wrong.')
                        break
                else:   # UE specific csirs
                    pass


'''
check_csiIM_12269_IWK_frameMuting(
    'tti_B_p40_dl_Reorder_new.csv',
    frame_structure='tdlte_3ms_Canada',
    csi_set3_period=40,
    actInfTddFrameMuting=True)
'''

# >>>>>>>>>>>>>>>>>>>>>>12269_B>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


def _get_curr_UE_specific_csirs_info_in_egate(
        list_egate_log, index_start_line, index_stop_line):
    '''
    :used for check_12269_B_UE_specific_csirs_in_egate()
    '''
    ue_id = re.findall('UE\\d+:', list_egate_log[index_start_line])[0]
    cell_id = re.findall('cell-ID .*? ', list_egate_log[index_start_line])[0]
    print('\n', ue_id, '\t', cell_id)
    index = index_stop_line
    list_egate_log_cp = list_egate_log.copy()

    for i_line in list_egate_log[index_stop_line:index_start_line:-1]:
        if 'csi-IM-ResourceToAddModList' in i_line:
            index_IM = index
            # print('index_IM:',index_IM)
            index_j = index_IM
            for j_line in list_egate_log_cp[index_IM:index_start_line:-1]:
                if 'periodicityAndOffset slots' in j_line:
                    csi_slot = re.findall('\\d+', j_line)[1]
                    print('\tslot:', csi_slot)
                if 'scramblingID' in j_line:
                    scramblingID = re.findall('\\d+', j_line)[0]
                    print('\tscramblingID:', scramblingID)
                if 'nrofPorts p' in j_line:
                    nrofPorts = re.findall('\\d+', j_line)[0]
                    print('\tnrofPorts:', nrofPorts)
                if 'firstOFDMSymbolInTimeDomain' in j_line:
                    start_symbol = re.findall('\\d+', j_line)[0]
                    print('\tstart_symbol:', start_symbol)
                if 'nzp-CSI-RS-ResourceId' in j_line:
                    resource_id = re.findall('\\d+', j_line)[0]
                    print('\tresource_id:', resource_id)
                    break
                index_j -= 1
            break
        index -= 1
    if resource_id == '0' and nrofPorts == '4':
        return csi_slot
    else:
        return None


def check_12269_B_UE_specific_csirs_in_egate(egate_log_path):
    '''
    :param egate_log_path:
    :function: print UE csi-rs info from egate_log. won't fail case.
    '''
    with open(egate_log_path, 'r', encoding='utf-8') as infile:
        list_egate_log = infile.readlines()
    list_index_register = []
    for i_line in list_egate_log:
        if 'Registering for cell-ID' in i_line:
            index_register = list_egate_log.index(i_line)
            list_index_register.append(index_register)
    # egate log的末行作为list_index_register的末尾元素。
    list_index_register.append(len(list_egate_log) - 1)

    set_csi_slot = set()
    for i in range(len(list_index_register) - 1):
        # print('i=',i)
        csi_slot = (_get_curr_UE_specific_csirs_info_in_egate(
            list_egate_log, list_index_register[i], list_index_register[i + 1]))
        if csi_slot:
            set_csi_slot.add(csi_slot)
    print(
        'set_csi_slot',
        set_csi_slot,
        '\tnum_of_UE_csirs_slot:',
        len(set_csi_slot))


# check_12269_B_UE_specific_csirs_in_egate('egate_console.log')


def check_12269_B_UE_specific_csirs_slots_syslog(before_onair_syslog_path, target_total_UEcsi_slots_num=4):
    '''
    :param before_onair_syslog_path:
    :param target_total_UEcsi_slots_num: should be <= rdMaxUeSpecCsiRsSlots*ueSpecCsiRsSlotsRatio,normally==.
    '''
    print('---check point: total UE csirs slots number=', target_total_UEcsi_slots_num,
          '\n',
          'phase1: selection of UE specific csirs should be ballanced in L1pool cells,\n',
          'phase2: all cells in the same L1pool use the same UE specific csirs slots from phase1.\n')
    list_sys = get_list_reader_from_tar(
        before_onair_syslog_path,
        './12269_B_sys_before_onair/')

    maxCsiRsPoolingGroups = 3   # hardcode: csirspoolinggroup:0,1,2
    # 'L2-PS/src/dl/sch/csiRsOpt/UeCsiLogger.hpp' in syslog

    ERR_total_num = False
    ERR_ballanced_UEcsi_num = False
    for i_line in list_sys:
        if 'selectedUeCsiForAllGroup:' in i_line:
            str_UEcsi_all_Group = re.findall(
                'selectedUeCsiForAllGroup:\\{(.*?)\n', i_line)[0]
            UEcsi_all_Group = re.findall('\\d+', str_UEcsi_all_Group)
            UEcsi_all_Group = [int(i) for i in UEcsi_all_Group]
            num_UEcsi_all = len(UEcsi_all_Group)
            print(
                '>>UEcsi_all_Group:',
                UEcsi_all_Group,
                'total:',
                num_UEcsi_all)
            if num_UEcsi_all != target_total_UEcsi_slots_num:
                print(
                    '--ERR:  num_UEcsi_all != target',
                    target_total_UEcsi_slots_num)
                ERR_total_num = True
            min_num_UEcsi_slot_per_cell = num_UEcsi_all // maxCsiRsPoolingGroups  # 整除=向下取整
            max_num_UEcsi_slot_per_cell = math.ceil(
                num_UEcsi_all / maxCsiRsPoolingGroups)  # 向上取整
            print(
                'range of num_UEcsi_slots_per_cell:[',
                min_num_UEcsi_slot_per_cell,
                ',',
                max_num_UEcsi_slot_per_cell,
                ']')

        if 'selectedUeCsi:' in i_line:
            csirsPoolingGroupId = re.findall(
                '\\d+', re.findall('currentGroup \\d+', i_line)[0])[0]
            UEcsi_slot_curr_Group = re.findall(
                '\\d+',
                re.findall(
                    'selectedUeCsi:\\{(.*?)\n',
                    i_line)[0])
            UEcsi_slot_curr_Group = [int(i) for i in UEcsi_slot_curr_Group]
            num_UEcsi_curr_Group = len(UEcsi_slot_curr_Group)
            print('\ncsirsPoolingGroupId:', csirsPoolingGroupId)
            print('UEcsi_slot_curr_Group:', UEcsi_slot_curr_Group)
            if num_UEcsi_curr_Group < min_num_UEcsi_slot_per_cell or num_UEcsi_curr_Group > max_num_UEcsi_slot_per_cell:
                print('--ERR: num_UEcsi_curr_Group is out of range num_UEcsi_slots_per_cell:[',
                      min_num_UEcsi_slot_per_cell, ',', max_num_UEcsi_slot_per_cell, '] not ballanced in L1pool cells')
                ERR_ballanced_UEcsi_num = True

        if '[CellSetup] stopTimer: nrCellIdentity:' in i_line:
            nrCellIdentity = re.findall(
                '\\d+',
                re.findall(
                    'nrCellIdentity:\\d+',
                    i_line)[0])[0]
            print('nrCellIdentity:', nrCellIdentity)
            print('\n')
    if ERR_total_num or ERR_ballanced_UEcsi_num:
        raise Exception('Fail')
    else:
        print('---Pass---')


'''
check_12269_B_UE_specific_csirs_slots_syslog(
    'before_onair_gnb.tar.gz',
    target_total_UEcsi_slots_num=4)
'''
# <<<<<<<<<<<<<<<<<<<<< 12269_B <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

# =================CB011117=====================================


def check_comb4_CS6_in_bip_csv(bip_csv, comb4_CS6=True):
    '''
    :param bip_csv:
    :param comb4_CS6: if Thor & 8322-enable & rdEnable6CsForComb4=true, comb4_CS6=True;else comb4_CS6=False
    :function: check CS usage when comb4 (comb4_CS6 or comb4_CS4)
    '''
    print('check point: CS usage with comb4.', 'comb4_CS6=', comb4_CS6)
    with open(bip_csv, 'r') as infile:
        list_bip = list(csv.DictReader(infile))

    # step1: find all rnti
    set_rnti = set()
    for i_line in list_bip:
        if i_line['_ws.col.info'] == 'UlData_SrsReceiveReq ' and i_line[
                'UlData_srsReceiveReqSubcell_t.srsBwvEnable'] == '1':
            rnti = i_line['3gpp.rnti']
            if rnti != '65535' and rnti != '0':
                set_rnti.add(i_line['3gpp.rnti'])
    list_rnti = list(set_rnti)
    # print('list_rnti:', list_rnti)

    # step2: find rnti's physcell
    list_physcell = []
    for rnti in list_rnti:
        for i_line in list_bip:
            if i_line['_ws.col.info'] == 'DlData_PdschSendReqL1sw ' and i_line['3gpp.rnti'] == rnti:
                physcell = i_line['DlData_PdschGrantL1sw.pdschScramblingSeqInit']
                list_physcell.append(physcell)
                break
    # print('list_physcell:', list_physcell)

    # step3: find combId , CS, numofports
    list_combID = []
    list_CS = []
    list_numSrsPorts = []
    for rnti in list_rnti:
        for i_line in list_bip:
            if i_line['UlData_srsReceiveReqSubcell_t.srsBwvEnable'] == '1' and i_line['3gpp.rnti'] == rnti:
                comb_Id = i_line['UlData_srsCyclicShifts_t.transmissionCombId']
                CS = i_line['UlData_srsCyclicShifts_t.cyclicShift']
                numSrsPorts = i_line['UlData_srsBwvReportRequest_t.numSrsPorts']
                list_combID.append(comb_Id)
                list_CS.append(CS)
                list_numSrsPorts.append(numSrsPorts)
                break
    # print('list_combID:',list_combID)
    # print('list_CS:',list_CS)
    # print('list_numSrsPorts:', list_numSrsPorts)

    # step4: zip 4 list to dict_list
    dict_list_UE_info = [
        {
            'rnti': rnti,
            'physcell': physcell,
            'combID': combID,
            'CS': CS,
            'numSrsPorts': numSrsPorts
        }
        for rnti, physcell, combID, CS, numSrsPorts in
        zip(list_rnti, list_physcell, list_combID, list_CS, list_numSrsPorts)
    ]
    print('dict_list_UE_info', dict_list_UE_info)

    # step5: check combID and CS in dict_list_UE_info
    ERR_num = 0
    for i in dict_list_UE_info:
        print(
            '\nrnti:',
            i['rnti'],
            '\tcell:',
            i['physcell'],
            '\tcombID:',
            i['combID'],
            '\tCS:',
            i['CS'],
            '\tnumSrsPorts:',
            i['numSrsPorts'])
        physcell_int = int(i['physcell'])

        if comb4_CS6:   # CB011117 new function
            # check RT beam combID, the same as legacy.
            target_combID = (1 + (physcell_int % 4)) % 4
            combID_in_bip = int(re.findall('\\d+', i['combID'])[0])
            if combID_in_bip != target_combID:
                print('===ERR_1: wrong combID, target combID is',
                      target_combID, 'but got', combID_in_bip)
                ERR_num += 1
            else:
                print('OK: check RT beam comb4 combID. target:',
                      target_combID, 'actual:', combID_in_bip)

            # {(0),(6),(2),(8),(4),(10)} is selected.
            if physcell_int % 2 == 0:
                # check CS6
                if i['numSrsPorts'] == '1':
                    list_CS_set = ['0', '2', '4', '6', '8', '10']
                elif i['numSrsPorts'] == '2':
                    list_CS_set = ['0,6', '2,8', '4,10']
                if i['CS'] in list_CS_set:
                    print('OK: CS6')
                else:
                    print('---ERR_2: wrong CS6. CS should be in', list_CS_set)
                    ERR_num += 1
            else:  # {(1),(7),(3),(9),(5),(11)} is selected
                # check CS6
                if i['numSrsPorts'] == '1':
                    list_CS_set = ['1', '3', '5', '7', '9', '11']
                elif i['numSrsPorts'] == '2':
                    list_CS_set = ['1,7', '3,9', '5,11']
                if i['CS'] in list_CS_set:
                    print('OK: CS6')
                else:
                    print('---ERR_3: wrong CS6. CS should be in', list_CS_set)
                    ERR_num += 1
        else:   # 8322 comb4_CS4 function
            # check RT beam combID
            target_combID = (1 + (physcell_int % 4)) % 4
            combID_in_bip = int(re.findall('\\d+', i['combID'])[0])
            if combID_in_bip != target_combID:
                print('===ERR_4: wrong combID, target combID is',
                      target_combID, 'but got', combID_in_bip)
                ERR_num += 1
            else:
                print('OK: check RT beam comb4 combID. target:',
                      target_combID, 'actual:', combID_in_bip)
            # check RT beam CS
            if physcell_int % 3 == 0:    # {(0),(3),(6),(9)} is selected
                if i['numSrsPorts'] == '1':
                    list_CS_set = ['0', '3', '6', '9']
                elif i['numSrsPorts'] == '2':
                    list_CS_set = ['0,6', '3,9']
                if i['CS'] in list_CS_set:
                    print('OK: CS4')
                else:
                    print('---ERR_5: wrong CS4. CS should be in', list_CS_set)
                    ERR_num += 1
            elif physcell_int % 3 == 1:  # {(1),(4),(7),(10)} is selected
                if i['numSrsPorts'] == '1':
                    list_CS_set = ['1', '4', '7', '10']
                elif i['numSrsPorts'] == '2':
                    list_CS_set = ['1,7', '4,10']
                if i['CS'] in list_CS_set:
                    print('OK: CS4')
                else:
                    print('---ERR_6: wrong CS4. CS should be in', list_CS_set)
                    ERR_num += 1
            else:   # {(2),(5),(8),(11)} is selected
                if i['numSrsPorts'] == '1':
                    list_CS_set = ['2', '5', '8', '11']
                elif i['numSrsPorts'] == '2':
                    list_CS_set = ['2,8', '5,11']
                if i['CS'] in list_CS_set:
                    print('OK: CS4')
                else:
                    print(
                        '---ERR_7: wrong CS4. CS set should be in',
                        list_CS_set)
                    ERR_num += 1
    print('\n--->ERR_num:', ERR_num)
    if ERR_num:
        raise Exception('Fail')
    else:
        print('--->Pass')


# check_comb4_CS6_in_bip_csv('comb4_CS6_physcell_50_51_52.csv', comb4_CS6=False)


def check_additional_BWV_calculation_in_bip(bip_csv, physcell_ID='50', additional_BWV_cal=True):
    '''
    :param bip_csv:
    :param physcell_ID:
    :param additional_BWV_cal: True or False.
    [CB011117-B]
    If Cplane indicate current cell has minimal SRS periodicity for subband BF:
        5G-L2-PS shall enabled additional BWV calculation(legacy 8322 use fast beam update mode).
        each SrsReceiveReq has a SrsReceiveRespBwvPs.
    else:
        5G-L2-PS shall disable additional BWV calculation.(in discuss)
        all SrsReceiveReq received then there's a SrsReceiveRespBwvPs.
    :function:check whether additional BWV calculation happened in bip_csv.
    '''
    print('\n---check point: in physcell', physcell_ID,
          'additional_BWV_calculation=', additional_BWV_cal)
    with open(bip_csv, 'r') as infile:
        list_bip = list(csv.DictReader(infile))
    list_bip_cp = list_bip.copy()

    # step1: find rnti in target physcell
    set_rnti = set()
    for i_line in list_bip:
        if i_line['DlData_PdschGrantL1sw.pdschScramblingSeqInit'] == physcell_ID and i_line['3gpp.rnti'] != '65535':
            set_rnti.add(i_line['3gpp.rnti'])
    if len(set_rnti) == 0:
        print('\\ZS\\WRN:no rnti in current physcell', physcell_ID)
        return
    print('rnti:', set_rnti)

    # step2: check rnti's UlData_SrsReceiveReq and UlData_SrsReceiveRespBwvPs
    ERR_rnti = 0
    if additional_BWV_cal:
        for rnti in set_rnti:
            print('\n\t--- physcell:', physcell_ID, 'rnti:', rnti)
            # find the last 2 bwv, skip the check of the last 2 srs req and bwv
            num_bwv = 0
            for i_line in list_bip[::-1]:
                if i_line['_ws.col.info'].startswith(
                        'UlData_SrsReceiveRespBwvPs') and i_line['3gpp.rnti'] == rnti:
                    num_bwv += 1
                    if num_bwv > 1:
                        last_bwv_index = list_bip.index(i_line)
                        break

            SrsReceiveReq_num = 0
            ERR_curr_rnti = 0
            last_SrsReceiveRespBwvPs_sfn = -1
            last_SrsReceiveRespBwvPs_slot = -1
            for i_line in list_bip[:last_bwv_index +
                                   1]:  # not check the last srs req maybe without bwv resp
                if i_line['_ws.col.info'].startswith(
                        'UlData_SrsReceiveReq') and i_line['3gpp.rnti'] == rnti:
                    SrsReceiveReq_sfn = int(i_line['3gpp.sfn'])
                    SrsReceiveReq_slot = int(i_line['3gpp.slot'])
                    index_SrsReceiveReq = list_bip.index(i_line)
                    SrsReceiveReq_num += 1
                    '''
                    print(
                        'OK: find UlData_SrsReceiveReq in\t',
                        SrsReceiveReq_sfn,
                        '-',
                        SrsReceiveReq_slot)
                    '''
                    if (SrsReceiveReq_sfn * 20 + SrsReceiveReq_slot) - \
                            (last_SrsReceiveRespBwvPs_sfn * 20 + last_SrsReceiveRespBwvPs_slot) < 10:
                        continue    # not calculate bwv if 2 bwvresp slot diff <10
                    find_SrsReceiveRespBwvPs = False
                    for j_line in list_bip_cp[index_SrsReceiveReq:]:
                        if j_line['_ws.col.info'].startswith(
                                'UlData_SrsReceiveRespBwvPs') and i_line['3gpp.rnti'] == rnti:
                            index_SrsReceiveRespBwvPs = list_bip_cp.index(
                                j_line)
                            SrsReceiveRespBwvPs_sfn = int(j_line['3gpp.sfn'])
                            SrsReceiveRespBwvPs_slot = int(j_line['3gpp.slot'])
                            if SrsReceiveRespBwvPs_sfn * 20 + \
                                    SrsReceiveRespBwvPs_slot > SrsReceiveRespBwvPs_sfn * 20 + SrsReceiveRespBwvPs_slot:
                                print(
                                    'WRN: SrsReceiveReq has no SrsReceiveRespBwvPs in',
                                    SrsReceiveReq_sfn,
                                    '-',
                                    SrsReceiveReq_slot)
                                break
                            if SrsReceiveRespBwvPs_sfn == SrsReceiveReq_sfn and \
                                    SrsReceiveRespBwvPs_slot == SrsReceiveReq_slot:
                                '''
                                print(
                                    'OK: find SrsReceiveRespBwvPs in\t\t',
                                    SrsReceiveRespBwvPs_sfn,
                                    '-',
                                    SrsReceiveRespBwvPs_slot)
                                '''
                                last_SrsReceiveRespBwvPs_sfn = SrsReceiveRespBwvPs_sfn
                                last_SrsReceiveRespBwvPs_slot = SrsReceiveRespBwvPs_slot
                                find_SrsReceiveRespBwvPs = True
                                break
                    if not find_SrsReceiveRespBwvPs:
                        print(
                            'ERR: not find SrsReceiveRespBwvPs for SrsReceiveReq',
                            SrsReceiveReq_sfn,
                            '-',
                            SrsReceiveReq_slot)
                        ERR_curr_rnti += 1

            if ERR_curr_rnti:
                print('\t---Fail curr rnti', rnti)
                ERR_rnti += 1
            else:
                print('\t---Pass curr rnti', rnti)
        if ERR_rnti:
            raise Exception('Fail')
        else:
            print('---Pass all---')
    else:   # not additional_BWV_calculation, only one bwv resp between srsreq
        print('To be done')


# check_additional_BWV_calculation_in_bip('BIP.csv', physcell_ID='50', additional_BWV_cal=True)


def check_3UE_bwv_calc_per_slot(bip_csv, surpport_3UE_bwv_calc=True, surpport_2UE_bwv_calc=False):
    with open(bip_csv, 'r') as infile:
        list_bip = list(csv.DictReader(infile))
    falg_3UE_per_slot = 0
    ERR = 0
    for i_line in list_bip:
        if i_line['_ws.col.info'].startswith('UlData_SrsReceiveReq'):
            list_operation = i_line['UlData_srsBwvReportRequest_t.operation'].split(
                ',')
            if len(list_operation) >= 2:
                falg_3UE_per_slot += 1
                list_operation = [int(i) for i in list_operation]
                num_bwv_calc = 0
                for operation in list_operation:
                    if operation >= 6:
                        num_bwv_calc += 1
                if surpport_3UE_bwv_calc:
                    if num_bwv_calc != 3:
                        print(
                            '-- ERR: surport 3UE bwv calc expected, but got',
                            num_bwv_calc)
                        ERR += 1
                else:   # not surport 3 UE bwv calc
                    if num_bwv_calc >= 3:
                        print(
                            '-- ERR: not surport 3 UE bwv calc, but got',
                            num_bwv_calc)
                        ERR += 1

                if surpport_2UE_bwv_calc:
                    if num_bwv_calc != 2:
                        print(
                            '-- ERR: surport 2UE bwv calc expected, but got',
                            num_bwv_calc)
                        ERR += 1
#                else:   # not surport 2 UE bwv calc
#                    if num_bwv_calc >= 2:
#                        print(
#                            '-- ERR: not surport 2 UE bwv calc, but got',
#                            num_bwv_calc)
#                        ERR += 1

    if not falg_3UE_per_slot:
        raise Exception('WRN: not 3 UE in 1 srsreq message, cannot judge.')
    if ERR:
        raise Exception('Fail')
    else:
        print('---Pass--')
