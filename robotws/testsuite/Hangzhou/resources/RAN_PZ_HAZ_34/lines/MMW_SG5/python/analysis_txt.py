# -*- coding: utf-8 -*-
# @Time    : 2024/2/22 16:37
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : analysis_txt.py
# @Software: PyCharm
import requests


def add_operation_history_for_qos(time, operation, environment, file_path="/home/ute/MMW_SG5/qos_operation.txt"):
    with open(file_path, "a", encoding="utf-8") as fa:
        fa.write(time.ljust(33) + operation.ljust(32) + environment.ljust(20) + "\n")
    url = "http://10.0.176.127:8080/update_qos_txt"
    files = {'file': open(file_path, 'rb')}
    res = requests.post(url=url, files=files, verify=False)


if __name__ == "__main__":
    add_operation_history_for_qos("1111", "2222", "3333")
