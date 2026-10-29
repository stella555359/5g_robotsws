# -*- coding: utf-8 -*
"""
Author: Bi jiajian
Contacts: jiajian.bi@nokia-sbell.com
Description: fad caculate
"""

import math
import requests


datas_st = []
datas_lt = []


def caculate_data_st(a, b, c):
    dict_st = dict()
    res = math.atan(c/b)*30*pow(10, 3)/8/3.14159
    res = round(float(res), 3)
    dict_st = dict(time=float(a), st=res, lt=None)
    datas_st.append(dict_st)


def caculate_data_lt(a, b, c):
    dict_lt = dict()
    res = math.atan(c/b)*30*pow(10, 3)/8/3.14159
    res = round(float(res), 3)
    dict_lt = dict(time=float(a), st=None, lt=res)
    datas_lt.append(dict_lt)


def read_st_datas():
    datas = datas_st
    return datas


def read_lt_datas():
    datas = datas_lt
    return datas
