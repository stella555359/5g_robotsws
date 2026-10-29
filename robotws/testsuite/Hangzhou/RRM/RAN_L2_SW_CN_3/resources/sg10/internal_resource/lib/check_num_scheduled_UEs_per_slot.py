'''
Author: Zhang Shuang
Funtion: check number of scheduled UEs per slot with target input 'str_num_of_UE'
'''
import csv


def get_ul_data_slot(framestructure):
    if framestructure == '1208':
        return ['4', '9', '14', '19']
    elif framestructure == '1070':
        return ['4', '8', '9', '14', '18', '19']
    elif framestructure == '1116_0ms':
        return ['4', '5', '14', '15']
    elif framestructure == '1116_3ms':
        return ['8', '9', '18', '19']


def get_dl_data_slot(framestructure):
    if framestructure == '1208':
        return ['0', '1', '2', '5', '6', '7',
                '10', '11', '12', '15', '16', '17']
    elif framestructure == '1070':
        return ['0', '1', '2', '5', '6', '10', '11', '12', '15', '16']
    elif framestructure == '1116_0ms':
        return ['0', '1', '2', '6', '7', '8', '9',
                '10', '11', '12', '16', '17', '18', '19']
    elif framestructure == '1116_3ms':
        return ['0', '1', '2', '3', '4', '5', '6',
                '10', '11', '12', '13', '14', '15', '16']
    else:
        print('unkown framestructure: framestructure')


def check_scheduled_num_of_UE_per_ul_slot(
        csv_filename, physCellId, str_num_of_UE, framestructure):
    list_data_slot = get_ul_data_slot(framestructure)
    print('ul slot should be:', list_data_slot)
    num_of_ue = int(str_num_of_UE)
    pass_flag = False
    with open(csv_filename) as csvfile:
        list_reader = list(csv.DictReader(csvfile))
        # get start sfn-slot
        for i_line in list_reader:
            if i_line['rnti'] != '0' and i_line['physCellId'] == physCellId and (
                    i_line['slot'] in list_data_slot):
                curr_sfn = i_line['sfn']
                curr_slot = i_line['slot']
                # print(curr_sfn,curr_slot)
                break
        # for
        UE_in_curr_slot = 0
        UE_list = []
        for i_line in list_reader:
            if i_line['rnti'] != '0' and i_line['physCellId'] == physCellId and (
                    i_line['slot'] in list_data_slot):
                if (i_line['sfn'] == curr_sfn) and (
                        i_line['slot'] == curr_slot):
                    if i_line['ulFdSchedData.numOfPrb']:    # ul data scheduled
                        rnti = i_line['rnti']
                        if rnti not in UE_list:
                            UE_list.append(rnti)
                            UE_in_curr_slot += 1
                            if UE_in_curr_slot == num_of_ue:
                                print('sfn-slot:', curr_sfn + '-' + curr_slot)
                                print(
                                    str(num_of_ue),
                                    'UEs scheduled per ul slot with data:',
                                    UE_list)
                                print('Pass')
                                pass_flag = True
                                break
                else:   # next slot
                    if i_line['ulFdSchedData.numOfPrb']:  # with ul data
                        curr_sfn = i_line['sfn']
                        curr_slot = i_line['slot']
                        UE_in_curr_slot = 1
                        UE_list = []
                        UE_list.append(i_line['rnti'])
        if pass_flag is False:
            print('Fail')
            print('less than ' + str_num_of_UE + ' UEs scheduled per ul slot.')
            raise Exception('Fail')


# usage:
# check_scheduled_num_of_UE_per_ul_slot('tti_16_UE_ul.csv', '50', '5', '1116_0ms')


def check_scheduled_num_of_UE_per_ul_slot_bip(
        bip_csv_file, physCellId, str_num_of_UE, framestructure):
    list_data_slot = get_ul_data_slot(framestructure)
    '''
    collect bip log with:
    ${filter_csv}	(uldata_puschreceivereq) && (3gpp.rnti != 65535)
    @{title_16UE}   3gpp.sfn   3gpp.slot   3gpp.rnti   3gpp.dmrsScramblingSequenceInt
    '''
    print('ul slot should be:', list_data_slot)
    num_of_ue = int(str_num_of_UE)
    pass_flag = False
    with open(bip_csv_file) as csvfile:
        list_reader = list(csv.DictReader(csvfile))
        # get start sfn-slot

    for i_line in list_reader:
        if i_line['3gpp.rnti'] and i_line['3gpp.dmrsScramblingSequenceInt'].startswith(
                physCellId) and (i_line['3gpp.slot'] in list_data_slot):
            start_sfn = i_line['3gpp.sfn']
            start_slot = i_line['3gpp.slot']
            break

    rnti_num = 0
    curr_rnti_num = 0
    check_sfn = start_sfn
    check_slot = start_slot
    str_rnti = ''
    for i_line in list_reader:
        if not i_line['3gpp.dmrsScramblingSequenceInt'].startswith('50'):
            # print('other cell')
            continue
        if i_line['3gpp.rnti'] and i_line['3gpp.slot'] == check_slot and i_line['3gpp.sfn'] == check_sfn:
            curr_sfn = i_line['3gpp.sfn']
            curr_slot = i_line['3gpp.slot']
            curr_rnti_num = 1 + i_line['3gpp.rnti'].count(',')
            str_rnti = str_rnti + ',' + i_line['3gpp.rnti']
            rnti_num += curr_rnti_num

            check_sfn = curr_sfn
            check_slot = curr_slot
            if rnti_num == num_of_ue:
                print(
                    'pass in ',
                    curr_sfn + '-' + curr_slot + ',',
                    str_num_of_UE,
                    'UE are shceduled on one slot.')
                print('rnti:', str_rnti)
                return True
            continue
        if i_line['3gpp.sfn'] != check_sfn or i_line['3gpp.slot'] != check_slot:       # next check turn
            rnti_num = 1 + i_line['3gpp.rnti'].count(',')
            str_rnti = i_line['3gpp.rnti']
            check_sfn = i_line['3gpp.sfn']
            check_slot = i_line['3gpp.slot']
            if rnti_num == num_of_ue:
                print('pass in ', curr_sfn + '-' + curr_slot)
                print('rnti:', str_rnti)
                return True
    print('Fail')
    raise Exception('not enough rnti scheduled in 1 ul slot')


# check_scheduled_num_of_UE_per_ul_slot_bip('BIP_16UE.csv', '50', '16', '1116_0ms')
