# -*- coding: utf-8 -*-
# @Time    : 2022/3/1 9:44
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : niddanalyzer.py
# @Software: PyCharm
import json


def verify_nidd_defination_params(file_path, param_name, param_details):
    with open(file_path, "r") as nidd_file:
        nidd_definations = json.loads(nidd_file.read())
    print(nidd_definations[param_name])
    assert param_details['Data type'] == nidd_definations[param_name]['Data Type']
    assert param_details['Description'] == nidd_definations[param_name]['Description']
    if not param_details['Description of relationship']:
        assert len(nidd_definations[param_name]['Description of parameter relationships']) == 0
    assert param_details['Creation priority'] == nidd_definations[param_name]['Required on creation']
    assert param_details['Modification type'] == nidd_definations[param_name]['Modification']
