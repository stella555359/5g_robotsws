# -*- coding: utf-8 -*

"""
Author:         Chen Helen
Contact Mail:   Helen.1.chen@nokia-sbell.com
Description:    Event trace log analysis
                Column index may changes in different program, so when calling this file,
                you will need to set value for program.
"""
import csv


def read_ZAB_privilege_value(csv_file, filter_name):
    with open(csv_file) as f:
        reader = csv.DictReader(f=f)
        for row in reader:
            if row[filter_name] == '1':
                print("has ZAB privilege")
                return True
                break
            else:
                continue
        else:
            return False
    f.close()


def check_dl_muStatus(csv_file, filter_name):
    with open(csv_file) as f:
        reader = csv.DictReader(f=f)
        for row in reader:
            if row[filter_name] == 'MUPAIR':
                print("DL mumimo paired")
                return True
                break
            else:
                continue
        else:
            return False
    f.close()


def check_ul_muStatus(csv_file, filter_name):
    with open(csv_file) as f:
        reader = csv.DictReader(f=f)
        for row in reader:
            if row[filter_name] == 'MUPAIRED_TAPERING':
                print("ul mumimo paired")
                return True
                break
            else:
                continue
        else:
            return False
    f.close()


def get_retx_sfn_info(csv_file, filter_name1, filter_name2, expect_name):
    result = []
    with open(csv_file) as f:
        reader = csv.DictReader(f=f)
        for row in reader:
            if row[filter_name2] == '2' and row[filter_name1] != '0':
                print("Retransmission is Rat0")
                result = row[expect_name]
                return result
                break
            else:
                continue
    f.close()


def get_retx_slot_info(csv_file, filter_name1, filter_name2, expect_name):
    result = []
    with open(csv_file) as f:
        reader = csv.DictReader(f=f)
        for row in reader:
            if row[filter_name2] == '2' and row[filter_name1] != '0':
                print("Retransmission is Rat0")
                result = row[expect_name]
                return result
                break
            else:
                continue
    f.close()


def get_retx_hard_process_info(csv_file, filter_name1, filter_name2, expect_name):
    result = []
    with open(csv_file) as f:
        reader = csv.DictReader(f=f)
        for row in reader:
            if row[filter_name2] == '2' and row[filter_name1] != '0':
                print("Retransmission is Rat0")
                result = row[expect_name]
                return result
                break
            else:
                continue
    f.close()


def get_retx_hard_process_index(csv_file, filter_name1, filter_name2, expect_name):
    result = []
    with open(csv_file) as f:
        reader = csv.DictReader(f=f)
        for index, row in enumerate(reader):
            if row[filter_name2] == '2' and row[filter_name1] != '0':
                print("The index of Retransmission Rat0")
                result = index
                return result
                break
            else:
                continue
    f.close()


def get_intial_Tx_info(csv_file, filter_name1, filter_name2, filter_name3,
                       expect_name1, expect_name2, target_name3):
    result = []
    with open(csv_file) as f:
        Retx_index = expect_name2
        Init_index = -1
        min_distance = float('inf')
        reader = csv.DictReader(f=f)
        for index, row in enumerate(reader):
            if (row[filter_name1] == expect_name1 and index < Retx_index and
                    row[filter_name2] == '1' and row[filter_name3] == '0'):
                distance = Retx_index - index
                if distance < min_distance:
                    min_distance = distance
                    Init_index = index
                    print("This is intial transmission index")
                    print(index)
                    result = row[target_name3]
            else:
                continue
    return result
    f.close()
