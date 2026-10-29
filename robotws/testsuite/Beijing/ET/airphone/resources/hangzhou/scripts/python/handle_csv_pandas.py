# pylint: skip-file
# -*- coding: utf-8 -*-
"""
:created on: 05-11-2023

:copyright: Nokia
:author: Zhang Xiaping
:contact: xiaping.zhang@nokia-sbell.com.cn
"""
import subprocess
import pkgutil
import importlib
import os
import math


def install_package(package):
    try:
        subprocess.call(['pip', 'install', '-U', 'numpy', package])
    except Exception as e:
        raise (AssertionError("Error installing package " + str(e)))


def is_pandas_installed():
    return bool(pkgutil.find_loader('pandas'))


def install_and_import_pandas():
    if not is_pandas_installed():
        install_package('pandas')
    return importlib.import_module('pandas')


def read_csv_column(source_file, column_title, filter_conditions, calculator=None):
    """read_csv_columns to read csv specific one or more columns.

        +--------------------+------+------------------------------------------------+
        | Input Paramaters   | Man. | Description                                    |
        +--------------------+------+------------------------------------------------+
        | source_file        | yes  | Path of csv file                               |
        +--------------------+------+------------------------------------------------+
        | column_title       | yes  | one cared column's title                       |
        +--------------------+------+------------------------------------------------+
        | filter_conditions  | no   | core_id==2 ; support: and, or, not             |
        +--------------------+------+------------------------------------------------+
        | calculator         | no   | combine result,support sum,max,avg             |
        +--------------------+------+------------------------------------------------+
        | return             | [colA_list] or [[colA_list], [colB_list]]             |
        +--------------------+------+------------------------------------------------+

        Example:

        +------------------+--------------+------+-----+----------------+--------------------------+
        | read_csv_columns | /opt/xxx.csv | Time |     |                |                          |
        +------------------+--------------+------+-----+----------------+--------------------------+
        | read_csv_columns | /opt/xxx.csv | Time | SFN |                |                          |
        +------------------+--------------+------+-----+----------------+--------------------------+
        | read_csv_columns | /opt/xxx.csv | Time | SFN |`SFN`==1        |                          |
        +------------------+--------------+------+-----+----------------+--------------------------+
        | read_csv_columns | /opt/xxx.csv | Time | SFN |`cat`=='L2'     | sum                      |
        +------------------+--------------+------+-----+----------------+--------------------------+
        | read_csv_columns | /opt/xxx.csv | Time | SFN |`SFN`==1 and `cat`=='L2'| avg              |
        +------------------+--------------+------+-----+----------------+--------------------------+
        | read_csv_columns | /opt/xxx.csv | Time | SFN |
        | ...              |`args.specific.event_id`.str.contains('LoCtrl_PduMuxReq', na=False)|avg|
        +------------------+--------------+------+-----+----------------+--------------------------+
    """
    pd = install_and_import_pandas()
    df = pd.read_csv(source_file)
    df_query = df.query(filter_conditions, engine='python')
    if calculator is None:
        result = list(set(df_query[column_title].tolist()))
    elif calculator == 'sum':
        result = df_query[column_title].sum()
    elif calculator == 'avg':
        result = df_query[column_title].mean()
    elif calculator == 'max':
        result = df_query[column_title].max()
    return result


if __name__ == "__main__":
    source_file = './BTS1_1730_L2RT20_L2RtCpu_TimeMarkerSnapshot.json.csv'
    # filter_conditions = "`args.specific.event_id`=='LoCtrl_PduMuxReq (55840, 0xda20)'"
    # result = read_csv_column(source_file, 'dur', filter_conditions, 'sum')
    # result = read_csv_column(source_file, 'dur', filter_conditions, 'avg')
    # filter_conditions = "core_id==2 and name=='EO_L2_LO_ADD_GENERIC_DATA_TO_TB'"
    # result = read_csv_column(source_file, 'dur', filter_conditions, 'avg')
    filter_conditions = "`args.specific.event_id`.str.contains('LoCtrl_PduMuxReq', na=False)"
    result = read_csv_column(source_file, 'dur', filter_conditions, 'avg')
