import csv


def check_8360_PRB_overlapping(bip_csv_path):
    '''
    :function: check PRB overlapping function for 8360_B_B3b_case5,
                in MU receiver(layer1+layer1),
                the UE with samll PRB will have additionnal patternid from the UE with big PRB patternid_2
    :Author: Zhang Shuang
    '''
    with open(bip_csv_path, 'r') as infile:
        list_bip_log = list(csv.DictReader(infile))
    # split by','
    for i_line in list_bip_log:
        i_line['3gpp.rnti'] = i_line['3gpp.rnti'].split(',')
        i_line['UlData_puschReceiveReqGrant_t.numOfLayers'] = \
            i_line['UlData_puschReceiveReqGrant_t.numOfLayers'].split(',')
        i_line['UlData_puschReceiveReqGrant_t.pairedUe'] = \
            i_line['UlData_puschReceiveReqGrant_t.pairedUe'].split(',')
        i_line['UlData_puschReceiveReqGrant_t.numOfPrb'] = \
            i_line['UlData_puschReceiveReqGrant_t.numOfPrb'].split(',')
        i_line['UlData_eCpriConfigStruct_t.patternId_item'] = \
            i_line['UlData_eCpriConfigStruct_t.patternId_item'].split(',')
        i_line['UlData_eCpriFcpSectionConfig_t.fcpAddPatternId_item'] = \
            i_line['UlData_eCpriFcpSectionConfig_t.fcpAddPatternId_item'].split(',')
        i_line['UlData_eCpriFcpSectionConfig_t.fcpAddSectionEnable'] = \
            i_line['UlData_eCpriFcpSectionConfig_t.fcpAddSectionEnable'].split(',')
    # save split csv
    output_filename = 'overlapping_split1.csv'
    with open(output_filename, 'w', encoding='utf8', newline='') as outfile:
        writer = csv.DictWriter(
            outfile, fieldnames=list_bip_log[0])  # not change the column
        writer.writeheader()
        for row in list_bip_log:
            writer.writerow(row)

    # start check
    list_bip_log_cp = list_bip_log.copy()
    check_num = 0
    pass_num = 0
    for i_line in list_bip_log:
        # step0: find the fcpAddSectionEnable
        if '1' in i_line['UlData_eCpriFcpSectionConfig_t.fcpAddSectionEnable']:
            check_num += 1
            index_i_line = list_bip_log.index(i_line)

            index_small = i_line['UlData_eCpriFcpSectionConfig_t.fcpAddSectionEnable'].index(
                '1')
            rnti_small = i_line['3gpp.rnti'][index_small]
            rnti_big = i_line['UlData_puschReceiveReqGrant_t.pairedUe'][index_small]
            index_big = i_line['3gpp.rnti'].index(rnti_big)
            PRB_samll = int(
                i_line['UlData_puschReceiveReqGrant_t.numOfPrb'][index_small])
            PRB_big = int(
                i_line['UlData_puschReceiveReqGrant_t.numOfPrb'][index_big])
            print('-------rnti_big:', rnti_big)
            # step1: check in MU receiver: layer1+layer1
            if i_line['UlData_puschReceiveReqGrant_t.numOfLayers'][index_big] != '1' or i_line[
                    'UlData_puschReceiveReqGrant_t.numOfLayers'][index_big] != '1':
                print('ERR: expected 2 1layer in MU receiver',
                      i_line['3gpp.sfn'] + '-' + ['3gpp.slot'])
                raise Exception(
                    'Fail: reason MUreceiver layer should be 2 layer1')

            # step2: check small PRB < big PRB
            if PRB_samll >= PRB_big:
                print(
                    'ERR: PRB_samll >= PRB_big,',
                    i_line['3gpp.sfn'] +
                    '-' +
                    i_line['3gpp.slot'])
                print('PRB_smal:', PRB_samll, 'PRB_big:', PRB_big)
                raise Exception('Fail: reason PRB big small relation')

            # step3: find the rnti_big last pusch patternid_2
            for j_line in list_bip_log_cp[index_i_line - 1::-1]:
                if rnti_big in j_line['3gpp.rnti']:
                    index_rnti_big_last = j_line['3gpp.rnti'].index(rnti_big)
                    # 找不 pair的时候的patternid_2, 如果遇到pair的则跳过
                    if j_line['UlData_puschReceiveReqGrant_t.pairedUe'][index_rnti_big_last] != '0':
                        continue
                    # print('index_rnti_big_Last:',index_rnti_big_last)
                    latest_big_patternid_2 = \
                        j_line['UlData_eCpriConfigStruct_t.patternId_item'][index_rnti_big_last * 4 + 1]
                    print(
                        'last_patternid_2:',
                        latest_big_patternid_2,
                        j_line['3gpp.sfn'] +
                        '-' +
                        j_line['3gpp.slot'])
                    break
            # step4: check latest_big_patternid_2 == fcpAddPatternId
            fcpAddPatternId = i_line['UlData_eCpriFcpSectionConfig_t.fcpAddPatternId_item'][index_small * 2]
            if latest_big_patternid_2 != fcpAddPatternId:
                print('ERR: latest_big_patternid_2 != fcpAddPatternid:', fcpAddPatternId,
                      i_line['3gpp.sfn'] + '-' + i_line['3gpp.slot'])
                raise Exception(
                    'Fail: --check if the patternid is stable.--the exact best and 2nd patternid was selected in tti.')
            else:
                print('fcpAddPatternId:', fcpAddPatternId)
                pass_num += 1
    # end for i_line

    print('check_num:', check_num)
    print('pass_num:', pass_num)
    if check_num == pass_num:
        print('---Pass---')
    else:
        print('Fail: check+num != pass_num')
        raise Exception('Fail: final')


# check_8360_PRB_overlapping('bip_pusch.csv')
