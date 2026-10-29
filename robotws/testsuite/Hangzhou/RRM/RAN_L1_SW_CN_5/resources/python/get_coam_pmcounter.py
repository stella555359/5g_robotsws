# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Cheng Huimin
:contact: huimin.1.cheng@nokia-sbell.com
:maintainer: Andy Cheng
:contact: Andy Cheng
"""
from taf.gnb.oam.coam.admin import admin
import time
import datetime
from openpyxl import Workbook
from openpyxl import load_workbook

coam = admin()


def get_pm_counter_values(counter_id, connection, dic_path='full', date='all'):
    """
    Get given counter values from 5G cOAM BTS.
    :param counter_id: str, counters ID like M55145C00006, can search in NIDD page.
    :param connection: str, connection alias must be given.
    :param dic_path: str, ex: BTS/CELLS/NRCELL-622593/MCC-244_MNC-09/NRANS, default is contain all path.
    :param date:str, ex: 2019/08/22/16/45/00 ,default is to get all date which has this counter id
    and sorted with counter report date.
    """
    counter_info = coam.get_pm_counters(connection=connection, couter_ids=counter_id)
    if dic_path == 'full':
        value_list = counter_info
    else:
        keys_list = dic_path.split('/')
        keys_list.append(counter_id)
        print(keys_list)
        counter_value = _get_dict_value(date=counter_info, keys=keys_list)
        if date == 'all':
            value_list = [counter_value[key] for key in sorted(counter_value, reverse=True)]
        else:
            date_list = date.split('/')
            t = datetime.datetime(int(date_list[0]), int(date_list[1]), int(date_list[2]),
                                  int(date_list[3]), int(date_list[4]), int(date_list[5]))
            date_int = int(time.mktime(t.timetuple()))
            value_list = counter_value.get(str(date_int))
    return value_list


def get_pm_counter_dict(counter_id, connection, dic_path='full'):
    """
    Get given counter values from 5G cOAM BTS.
    :param counter_id: str, counters ID like M55145C00006, can search in NIDD page.
    :param connection: str, connection alias must be given.
    :param dic_path: str, ex: BTS/CELLS/NRCELL-622593/MCC-244_MNC-09/NRANS, default is contain all path.
    :param date:str, ex: 2019/08/22/16/45/00 ,default is to get all date which has this counter id
    and sorted with counter report date.
    """
    counter_info = coam.get_pm_counters(connection=connection, couter_ids=counter_id)
    if dic_path == 'full':
        counter_value = counter_info
    else:
        keys_list = dic_path.split('/')
        keys_list.append(counter_id)
        print(keys_list)
        counter_value = _get_dict_value(date=counter_info, keys=keys_list)
    return counter_value


def create_excel_and_write_date_list(start_date, end_date, filepath, filesheet, counter_period=300):
    """
    Write all counter date list in excel sheet first row. used for multi counters add in excel.
    :param start_date: date with epoch as seconds, like 1616300100
    :param end_date: : date with epoch as seconds, like 1616300100
    :param filepath: the Excel create path and name,like /home/ute/counter.excel.
    :param filesheet:the sheet name which add the counter data
    :param counter_period:seconds, the counter period which in gnb config
    """
    date_list = []
    for i in range(start_date, end_date+1, counter_period):
        date_list.append(i)
    print(date_list)
    date_list.insert(0, 'Date')
    wb = Workbook()
    ws = wb.create_sheet(title=filesheet)
    for i in range(len(date_list)):
        ws.cell(row=i+1, column=1, value=date_list[i])
    wb.save(filename=filepath)


def write_counter_to_excel(counter_value, counter_prop, filepath, filesheet):
    """
    Write all counter data in excel sheet row by row. used for multi counters add in excel.
    :param counter_value: return value get by use "get_pm_counter_dict"
    :param counter_prop: : dict wich contain the counter prop like:
            {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/MCC-310_MNC-260/NRANS', 'counter_id': 'M55145C00301'}
    :param filepath: the Excel exist path.
    :param filesheet:the sheet name which add the counter data
    """
    counter_title = 'GNB{}/{}/{}'.format(counter_prop['gnb_id'], counter_prop['dic_path'], counter_prop['counter_id'])
    wb = load_workbook(filename=filepath)
    ws = wb.get_sheet_by_name(name=filesheet)
    colnum_max = ws.max_column
    ws.cell(row=1, column=colnum_max+1, value=counter_title)
    rownum_max = ws.max_row
    rownum_min = ws.min_row
    for i in range(rownum_min, rownum_max):
        date_value = ws.cell(row=i+1, column=1).value
        print(date_value)
        try:
            ws.cell(row=i+1, column=colnum_max+1, value=counter_value[str(date_value)])
        except KeyError:
            ws.cell(row=i + 1, column=colnum_max + 1, value=0)
    wb.save(filename=filepath)


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
