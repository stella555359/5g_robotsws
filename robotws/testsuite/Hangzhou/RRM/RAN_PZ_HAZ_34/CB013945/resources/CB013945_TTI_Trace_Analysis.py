# -*- coding: utf-8 -*

"""
Author:         Chen Helen
Contact Mail:   Helen.1.chen@nokia-sbell.com
Description:    Event trace log analysis
                Column index may changes in different program, so when calling this file,
                you will need to set value for program.
"""
import csv


def check_dynamic_switch_status(csv_file, filter_name):
    with open(csv_file) as f:
        reader = csv.DictReader(f=f)
        for row in reader:
            if row[filter_name] != '0':
                print("has dynamic switch ")
                return True
                break
            else:
                continue
        else:
            return False
    f.close()


def check_start_prb_num(csv_file, filter_name, expect_name):
    with open(csv_file) as f:
        reader = csv.DictReader(f=f)
        result = 0
        num = 0
        for row in reader:
            if row[filter_name] == 'dlFdSchedData':
                differ = int(row[expect_name]) - result
                result = int(row[expect_name])
                if differ == '0':
                    num = num
                else:
                    num = num + 1
            else:
                continue
        return num
    f.close()
