# -*- coding: utf-8 -*-
# @Time    : 2023/10/12 21:44
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : analysis_json.xml.py
# @Software: PyCharm
import json


def update_key_value_in_json_file(json_file, key, value):
    with open(json_file, "r") as fr:
        my_json = json.loads(fr.read())
        my_json[key] = float(value)
    with open(json_file, "w") as fw:
        fw.write(json.dumps(my_json, indent=4))


def generate_delta_json_enable_single_cell_qrxlevmin(cells, target_cell, update_qrxlevmin, restore_qrxlevmin):
    cells = sorted(cells)
    enable_delta = []
    for cell in cells:
        dist_param = {}
        parameter = dict()
        if "NRCELL" in cell:
            parameter["parameterName"] = "qRxLevMin"
            dist_param["distName"] = cell
            if cell != target_cell:
                parameter["value"] = "-22"
            else:
                parameter["value"] = "-53"
        elif "LNCEL" in cell:
            parameter["parameterName"] = "qrxlevmin"
            dist_param["distName"] = cell + "/SIB-0"
            if cell != target_cell:
                parameter["value"] = "-44"
            else:
                parameter["value"] = "-120"
        parameter["operation"] = "update"
        dist_param["operation"] = "update"
        dist_param["parameters"] = [parameter]
        enable_delta.append(dist_param)

    with open(update_qrxlevmin, "w") as fw:
        fw.write(json.dumps(enable_delta, indent=4))
    with open(update_qrxlevmin, "r") as fr:
        restore_delta = fr.read()
        restore_delta = restore_delta.replace("\"-22\"", "\"-53\"")
        restore_delta = restore_delta.replace("\"-44\"", "\"-120\"")
    with open(restore_qrxlevmin, "w") as fw:
        fw.write(restore_delta)


if __name__ == "__main__":
    a = ['MRBTS-2026/NRBTS-37051/NRCELL-7', 'MRBTS-2026/NRBTS-37051/NRCELL-8']
    generate_delta_json_enable_single_cell_qrxlevmin(a, "MRBTS-2026/NRBTS-37051/NRCELL-7",
                                                     "update_qrxlevmin.json", "restore_qrxlevmin.json")
