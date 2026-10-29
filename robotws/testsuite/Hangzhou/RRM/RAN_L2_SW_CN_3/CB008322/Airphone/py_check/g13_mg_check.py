# Created by shuihe
# Maintianed by shuihe
import csv
import math
import ast
import os
import datetime
# import pandas as pd
# from datetime import datetime
from dateutil import parser


def combine_csv(input_folder, output_file):
    # initialize the output file
    with open(output_file, 'w', newline='') as combined_csv:
        writer = csv.writer(combined_csv)
        # traverse each file in the folder
        print(os.listdir(input_folder))
        for filename in os.listdir(input_folder):
            if filename.endswith('.csv'):
                csv_path = os.path.join(input_folder, filename)
                # open CSV file and read the data
                with open(csv_path, 'r') as csv_file:
                    reader = csv.reader(csv_file)
                    # skip the header
                    # next(reader)
                    # write the remaining rows into the output file
                    for row in reader:
                        writer.writerow(row)


def get_entering_mg_time(csv_filename):
    with open(csv_filename) as csvfile:
        # csv.DictReader(csvfile): read csv as a list of dict
        list_reader = list(csv.DictReader(csvfile))
        entering_time = 0
        dlshort_index = 0
        for i_row in list_reader:
            if i_row['itf_l2_ps_UeCapability.dlShortTermBeamformingCapability_item'] == '0':
                dlshort_index = list_reader.index(i_row)
        for j in range(dlshort_index, len(list_reader)):
            if list_reader[j]['nr-rrc.criticalExtensions'] == '0':
                entering_time_str = list_reader[j]['frame.time']
                rnti = list_reader[j]['3gpp.rnti']
                # entering_time = pd.to_datetime(entering_time_str)
                # entering_time = datetime.strptime(entering_time_str, '%Y-%m-%d %H:%M:%S.%f %Z')
                entering_time = parser.parse(entering_time_str)
                print(entering_time_str)
                print(entering_time)
                print(rnti)
                break
        return entering_time


def check_bwv_request_not_sent_entering_mg(csv_filename, entering_time):
    with open(csv_filename) as csvfile:
        # csv.DictReader(csvfile): read csv as a list of dict
        list_reader = list(csv.DictReader(csvfile))
        pass_num = 0
        fail_num = 0
        for i_row in list_reader:
            # print('-'*50)
            # print(pd.to_datetime(i_row['frame.time']))
            if i_row['frame.time'] != 'frame.time':
                if parser.parse(i_row['frame.time']) > entering_time:
                    if i_row['UlData_srsReceiveReqSubcell_t.srsBwvEnable'] == '0':
                        pass_num += 1
                    else:
                        fail_num += 1
                        # print(pd.to_datetime(i_row['frame.time']))
                        print(i_row['UlData_srsReceiveReqSubcell_t.srsBwvEnable'])
        if fail_num > 0 and pass_num == 0:
            print('check_fail_num:', fail_num)
            print("check_pass_num:", pass_num)
            raise Exception('Fail')
        else:
            print("check_pass_num:", pass_num)
            print('Pass')


def get_leaving_mg_time_and_rnti(csv_filename):
    with open(csv_filename) as csvfile:
        # csv.DictReader(csvfile): read csv as a list of dict
        list_reader = list(csv.DictReader(csvfile))
        leaving_time = 0
        rnti = 0
        for i_row in list_reader:
            if i_row['itf_l2_ps_user_RrcReconfCompletedReq_t.tasSrsResourceChangeInd_item'] == '1':
                leaving_time_str = i_row['frame.time']
                rnti = i_row['3gpp.rnti']
                leaving_time = parser.parse(leaving_time_str)
                print(leaving_time_str)
                print(leaving_time)
                print(rnti)
                break
        return leaving_time, rnti


def check_bwv_request_sent_leaving_mg(csv_filename, leaving_time, rnti):
    with open(csv_filename) as csvfile:
        # csv.DictReader(csvfile): read csv as a list of dict
        list_reader = list(csv.DictReader(csvfile))
        bwv_request_sent_num = 0
        l1_response_ok_num = 0
        for i_row in list_reader:
            # print('-'*50)
            # print(pd.to_datetime(i_row['frame.time']))
            if i_row['frame.time'] != 'frame.time':
                if parser.parse(i_row['frame.time']) > leaving_time:
                    if i_row['UlData_srsReceiveReqSubcell_t.srsBwvEnable'] == '1' and i_row['3gpp.rnti'] == rnti:
                        bwv_request_sent_num += 1
                    elif (i_row['UlData_srsReceiveReqSubcell_t.srsBwvEnable'] == '' and
                          i_row['UlData_srsBwvReport_t.result'] == '0'):
                        l1_response_ok_num += 1
        a = math.floor(bwv_request_sent_num)
        if (bwv_request_sent_num > 0 and l1_response_ok_num > 0 and
                (l1_response_ok_num == a or l1_response_ok_num == a-1 or l1_response_ok_num == a-2)):
            # leaving MG, the first OK need 2 srs bwv requests for T2R4, 4 srs bwv requests for t1r4.
            print("bwv_request_sent_num:", bwv_request_sent_num)
            print("l1_response_ok_num:", l1_response_ok_num)
            print('Pass')
        else:
            print("bwv_request_sent_num:", bwv_request_sent_num)
            print("l1_response_ok_num:", l1_response_ok_num)
            raise Exception('Fail')


# combine_csv('/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_3/CB008322/Airphone/py_check/leave_mg/',
#             'combined_leave_mg.csv')
# time_001 = get_entering_mg_time('cplog_enterMG.csv')
# check_bwv_request_not_sent_entering_mg('combined.csv', time_001)
# time_rnti = get_leaving_mg_time_and_rnti('cplog_leaveMG.csv')
# print(time_rnti)
# check_bwv_request_sent_leaving_mg('combined_leave_mg.csv', time_rnti[0], time_rnti[1])
