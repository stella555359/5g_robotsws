'''
Author: Zhang Shuang
Funtion: for DFTsOFDM trans precoding enabled, check numofPRB following 2-3-5 rule.
'''
import csv


def _get_list_rule235():
    i_max = 8
    j_max = 5
    k_max = 3
    list_235 = []
    for i in range(i_max + 1):
        for j in range(j_max + 1):
            for k in range(k_max + 1):
                result_235 = pow(2, i) * pow(3, j) * pow(5, k)
                if result_235 > 273:
                    break
                if result_235 not in list_235:
                    list_235.append(result_235)
                k += 1
            j += 1
        i += 1
    list_235.sort()
    print("235-Rule_Allowed_Prb_Set:")
    print(list_235)
    return list_235


def check_235_rule(csv_filename):
    list_235 = _get_list_rule235()
    with open(csv_filename) as csvfile:
        # csv.DictReader(csvfile): read csv as a list of dict
        list_reader = list(csv.DictReader(csvfile))
        for_time = 0
        total_ERR = 0
        for i_line in list_reader:
            numPRB = i_line['ulFdSchedData.numOfPrb']
            if numPRB:
                for_time += 1
                numPRB = int(float(numPRB))
                if numPRB not in list_235:
                    print('ERR:numPRB not in 235-Rule_Allowed_Prb_Set: numPRB=' + str(numPRB),
                          'sfn-slot:' + i_line['sfn'] + '-' + i_line['slot'])
                    total_ERR += 1
        print("for_time:", for_time)
        print("total ERR:", total_ERR)
    if total_ERR:
        print("Fail")
        raise Exception('Fail')
    else:
        print("Pass")

# check_235_rule("tti_bler_ul_case47.csv")
