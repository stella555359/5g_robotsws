# -*- coding: utf-8 -*-
# @Time    : 2023/10/9 14:23
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : analysis_operation_history.py
# @Software: PyCharm
from taf.sbts.oam.coam.admin import admin


def verify_operation_succeed_from_operation_history(file_name, operation, connection="GNB_OAM"):
    admin().get_operation_history(output_file_name=file_name, connection=connection)
    results = get_results_from_operation_history(file_name)
    for i in range(3):
        if results[i] == operation:
            assert results[i+1] == "Succeeded"
            return
    raise AssertionError(f"i can not find {operation}")


def verify_results_from_operation_history_normal(file_name, except_results, connection="GNB_OAM"):
    admin().get_operation_history(output_file_name=file_name, connection=connection)
    results = get_results_from_operation_history(file_name)
    for i in range(len(except_results)):
        if except_results[i] != "ANY":
            assert results[i] == except_results[i]


def get_results_from_operation_history(file_name):
    results = []
    with open(file_name, "r") as fr:
        lines = fr.readlines()
        for line in lines:
            if "Nemuadmin" in line:
                result = ""
                split_strs = line.split("    ")
                if "Failed" in split_strs[-1]:
                    result = "Failed"
                elif "Succeeded" in split_strs[-1]:
                    result = "Succeeded"
                else:
                    result = "Unknown"
                results.append(split_strs[0])
                results.append(result)
        print(results)
    return results
