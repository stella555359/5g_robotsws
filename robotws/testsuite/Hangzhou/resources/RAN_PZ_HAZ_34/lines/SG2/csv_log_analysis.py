# -*- coding: utf-8 -*

import subprocess
import pkgutil
import importlib


def install_package(testline_name, package):
    api = 'https://artifactory-espoo2.int.net.nokia.com/artifactory/api/pypi/ute-pypi-virtual/simple'
    target = '--target=/home/ute/CIENV/' + testline_name + '/lib/python3.10/site-packages/'
    try:
        subprocess.call(['pip', 'install', target, '-i', api, 'numpy', package])
    except Exception as e:
        raise (AssertionError("Error installing package " + str(e)))


def is_pandas_installed():
    return bool(pkgutil.find_loader('pandas'))


def install_and_import_pandas(testline_name):
    if not is_pandas_installed():
        install_package(testline_name, 'pandas')
    return importlib.import_module('pandas')


def read_csv_column(testline_name, source_file, column_title, filter_conditions,
                    calculator=None, dtype=None, need_set=True):
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
    pd = install_and_import_pandas(testline_name)
    df = pd.read_csv(source_file, low_memory=False, dtype=dtype)
    df_query = df.query(filter_conditions)
    if calculator is None:
        if need_set:
            result = list(set(df_query[column_title].tolist()))
        else:
            result = list(df_query[column_title].tolist())
    elif calculator == 'sum':
        result = df_query[column_title].sum()
    elif calculator == 'avg':
        result = df_query[column_title].mean()
    elif calculator == 'max':
        result = df_query[column_title].max()
    return result
