import csv
import subprocess
import pkgutil
import importlib
import os
import time
from datetime import datetime
import math


class AutoDict(dict):
    def __missing__(self, k):
        self[k] = AutoDict()
        return self[k]


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


def Check_maxNumPdschUes(file_name, Phycellid, L1PoolCapacity):
    sfndict = AutoDict()
    tmp = AutoDict()
    count = 0
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
        for line in csv_reader:
            if 'type' in header and line['type'] == 'dlAllocatedPooledResourcesData':
                tmp[line['physCellId']] = int(float(line['maxNumPdschUes']))
                sfndict[line['sfn']] = tmp
                if len(sfndict) == 10:
                    break
    Check = True
    for sfn in sfndict:
        Pool = 0
        for cell in Phycellid:
            print(sfndict[sfn][cell])
            Pool += sfndict[sfn][cell]
            if sfndict[sfn][cell] != int(Phycellid[cell]):
                print('Error : Expected Value of maxNumPdschUes for CellId:{} is {}, But Actual Value:{}'.
                      format(cell, Phycellid[cell], sfndict[sfn][cell]))
            else:
                print('Expected Value of maxNumPdschUes for CellId:{} is {},and Actual Value:{}'.
                      format(cell, Phycellid[cell], sfndict[sfn][cell]))
        if Pool != int(L1PoolCapacity):
            print('Expected Pool Capacity:{}, and Actual Allocation:{}'.format(L1PoolCapacity, Pool))
            Check = False
    return Check


def Check_maxNumPuschUes(file_name, Phycellid, L1PoolCapacity):
    sfndict = AutoDict()
    tmp = AutoDict()
    count = 0
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        header = csv_reader.fieldnames
        for line in csv_reader:
            if 'type' in header and line['type'] == 'ulAllocatedPooledResourcesData':
                tmp[line['physCellId']] = int(float(line['maxNumPuschUes']))
                sfndict[line['sfn']] = tmp
                if len(sfndict) == 10:
                    break
    Check = True
    for sfn in sfndict:
        Pool = 0
        for cell in Phycellid:
            Pool += sfndict[sfn][cell]
            if sfndict[sfn][cell] != int(Phycellid[cell]):
                print('Error : Expected Value of maxNumPuschUes for CellId:{} is {}, But Actual Value:{}'.
                      format(cell, Phycellid[cell], sfndict[sfn][cell]))
            else:
                print('Expected Value of maxNumPuschUes for CellId:{} is {},and Actual Value:{}'.
                      format(cell, Phycellid[cell], sfndict[sfn][cell]))
        if Pool != int(L1PoolCapacity):
            print('Expected Pool Capacity:{}, and Actual Allocation:{}'.format(L1PoolCapacity, Pool))
            Check = False
    return Check
