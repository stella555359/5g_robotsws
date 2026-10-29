import subprocess
import pkgutil
import importlib
import os
import time
from datetime import datetime
import math


def install_package(package):
    try:
        subprocess.call(['pip', 'install', '-U', 'numpy', package])
    except Exception as e:
        raise (AssertionError("Error installing package " + str(e)))


def is_pandas_installed():
    return bool(pkgutil.find_loader('pandas'))


def install_and_import_pandas():
    print("pandas library installation")
    if not is_pandas_installed():
        install_package('pandas')
    return importlib.import_module('pandas')


def verify_rat1_alocation(filepath, physcellid='50'):
    pd = install_and_import_pandas()
    df = pd.read_csv(filepath, low_memory=False)
    df1 = df[(df['type'] == 'dlFdSchedData') & (df['physCellId'].isin([50])) & (df['dciFormat'] == 'DL_11')]
    print("Get rat0Bitmap Values", type(df1.rat0Bitmap.unique()))
    print("Get rat0Bitmap Values", df1.rat0Bitmap.unique())
    if all(x == 0 for x in df1.rat0Bitmap.unique()):
        return 'Pass'
    else:
        return 'Fail'


def verify_DynSwitch_alocation(filepath, physcellid='50'):
    pd = install_and_import_pandas()
    df = pd.read_csv(filepath, low_memory=False)
    df1 = df[(df['type'] == 'dlFdSchedData') & (df['physCellId'].isin([50])) & (df['dciFormat'] == 'DL_11')]
    print("Get rat0Bitmap Values", df1.rat0Bitmap.unique())
    unique_values = df1.rat0Bitmap.unique()
    if all(x == 0 for x in unique_values):
        return "Fail"
    elif all(isinstance(x, (int, float)) for x in unique_values) and not any(x == 0 for x in unique_values):
        return "Fail"
    elif all(isinstance(x, (int, float)) for x in unique_values) and any(x == 0 for x in unique_values):
        return "Array contains both zeros and numbers:pass"


def merge_multiple_csv(filepath, dire):
    pd = install_and_import_pandas()
    df_list = []
    csv_file_list = sorted(os.listdir(filepath))
    print("csv file", csv_file_list)

    for i in range(0, len(csv_file_list)):
        if 'output_' + dire + '_formated_' + str(i) + '.csv' in csv_file_list:
            file = 'output_' + dire + '_formated_' + str(i) + '.csv'
            print('file', file)
            df_list.append(pd.read_csv(os.path.join(filepath, file), low_memory=False))
            os.remove(os.path.join(filepath, file))
    df = pd.concat(df_list, ignore_index=True)
    filename = 'output_' + dire + '_formated.csv'
    df.to_csv(os.path.join(filepath, filename), index=False)


class AutoDict(dict):
    def __missing__(self, k):
        self[k] = AutoDict()
        return self[k]
