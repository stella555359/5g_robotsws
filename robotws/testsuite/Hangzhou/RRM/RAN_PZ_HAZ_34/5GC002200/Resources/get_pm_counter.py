# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Cheng Huimin
:contact: huimin.1.cheng@nokia-sbell.com
:maintainer: Andy Cheng
:contact: Andy Cheng
"""
from taf.sbts.oam.coam.admin import admin
import time
import datetime

coam = admin()


def get_pm_counter_values(counter_id, connection, dic_path="full", date="all"):
    """
    Get given counter values from 5G cOAM BTS.
    :param counter_id: str, counters ID like M55145C00006, can search in NIDD page.
    :param connection: str, connection alias must be given.
    :param dic_path: str, ex: BTS/CELLS/NRCELL-622593/MCC-244_MNC-09/NRANS,
                              default is contain all path.
    :param date:str, ex: 2019/08/22/16/45/00 ,default is to get all date which has this counter id.
    """
    counter_info = coam.get_pm_counters(connection=connection, couter_ids=counter_id)
    if dic_path == "full":
        value_list = counter_info
    else:
        keys_list = dic_path.split("/")
        keys_list.append(counter_id)
        counter_value = _get_dict_value(date=counter_info, keys=keys_list)
        if date == "all":
            value_list = list(counter_value.values())
        else:
            date_list = date.split("/")
            t = datetime.datetime(
                int(date_list[0]),
                int(date_list[1]),
                int(date_list[2]),
                int(date_list[3]),
                int(date_list[4]),
                int(date_list[5]),
            )
            date_int = int(time.mktime(t.timetuple()))
            value_list = counter_value.get(str(date_int))
    return value_list


def _get_dict_value(date, keys, default=None):
    dictionary = dict(date)
    for i in keys:
        try:
            if dictionary.get(i) is not None:
                dict_values = dictionary.get(i)
            elif dictionary.get(i) is None:
                dict_values = dictionary.get(int(i))
        except Exception:
            return default
        dictionary = dict_values
    return dictionary
