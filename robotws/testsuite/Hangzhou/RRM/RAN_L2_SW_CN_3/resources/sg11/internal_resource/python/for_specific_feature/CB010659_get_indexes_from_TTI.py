# Created by shuihe
# Maintianed by shuihe
import csv


def get_average(csv_filename, str_index='ulFdSchedData.ueData.reScaledCorrAvgSinrAtb'):
    with open(csv_filename) as csvfile:
        # csv.DictReader(csvfile): read csv as a list of dict
        list_reader = list(csv.DictReader(csvfile))
        sum_001 = 0
        n = 0
        average = 0
        for i_line in list_reader:
            # print(len(i_line['ulFdSchedData.ueData.reScaledCorrAvgSinrAtb']))
            if i_line[str_index] != '' and i_line[str_index] != '65535.0':
                sum_001 += float(i_line[str_index])
                n += 1
                average = sum_001 / n
    return average


def check_not_delta_sinr_calculated(csv_filename):
    with open(csv_filename) as csvfile:
        # csv.DictReader(csvfile): read csv as a list of dict
        list_reader = list(csv.DictReader(csvfile))
        reserve_mcs_list = []
        max_index = len(list_reader)
        check_pass_num = 0
        check_fail_num = 0
        for i_row in list_reader:
            if i_row['ulFdSchedData.rrmUlUsedMcs'] == '29.0' or i_row['ulFdSchedData.rrmUlUsedMcs'] == '30.0'\
                    or i_row['ulFdSchedData.rrmUlUsedMcs'] == '31.0':
                mcs = i_row['ulFdSchedData.rrmUlUsedMcs']
                harq_process_index = i_row['ulFdSchedData.ulHarqProcessIndex']
                print(mcs)
                print(harq_process_index)
                print(list_reader.index(i_row))
                reserve_mcs_index = list_reader.index(i_row)
                reserve_mcs_list.append(list_reader.index(i_row))
                print(reserve_mcs_list)
                print('-'*50)
                for j_index in range(reserve_mcs_index, max_index):
                    if list_reader[j_index]['ulLaAverageSinr.harqProcessIndex'] == harq_process_index:
                        if list_reader[j_index]['ulLaDeltaSinr.isDeltaSinrCalculated'] == "0.0"\
                               and list_reader[j_index]['ulLaDeltaSinr.targetBlerType'] == 'OFF'\
                               and list_reader[j_index]['ulLaDeltaSinr.ulUsedMcs'] == mcs:
                            check_pass_num += 1
                        else:
                            check_fail_num += 1
                        print(check_pass_num)
                        print(check_fail_num)
                        break
                print(check_pass_num)
                print(check_fail_num)
        if check_pass_num > 0:
            print('check_pass_num:', check_pass_num,
                  '\ncheck_fail_num:', check_fail_num,
                  '\nif check_fail_num > 0, it does not mean the case fail, for 2 ulLaAverageSinr.harqProcessIndex may'
                  '\nat the same slot. So at some slot, the target ulLaAverageSinr.harqProcessIndex may not be found'
                  '\nin the TTI csv'
                  '\nPass')

        else:
            raise Exception('check_pass_num:', check_pass_num,
                            '\ncheck_fail_num:', check_fail_num,
                            '\nFail')
        return check_fail_num


# get_average('tti_ul.csv')
# get_average('tti_ul.csv', 'ulLaDeltaSinr.ulUsedMcs')
# get_average('tti_ul.csv', 'ulFdSchedData.numOfPrb')
# get_average('tti_ul.csv', 'ulFdSchedData.tbSize')
# get_average('tti_ul.csv', 'ulFdSchedData.reScaledCorrAvgSinrAllocPrb')
# check_not_delta_sinr_calculated('tti_re_9427_ul (5).csv')
