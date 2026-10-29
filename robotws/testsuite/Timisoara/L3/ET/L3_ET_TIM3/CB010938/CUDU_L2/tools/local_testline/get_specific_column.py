#!/usr/bin/env python3

import sys
import os

check_pandas = 2
check_configpar = 2

# Check and install needed libraries
print('---------------------------------------')
while check_pandas:
    try:
        import pandas as pd
        print('pandas has been installed')
        break
    except Exception:
        print('pandas is not installed.')
        os.system("pip install pandas")
        check_pandas -= 1
        continue

while check_configpar:
    try:
        from configparser import ConfigParser
        print("configparser has been installed.")
        break
    except Exception:
        print("configparser is not installed.")
        os.system("pip install ConfigParser")
        check_configpar -= 1
        continue

# Get the name of Original file and determines the Generated file name.
print('---------------------------------------')
input_file = sys.argv[1]
print("input_file:", input_file)
file_name = os.path.splitext(input_file)
output_file = file_name[0]+'_Filter'+'.csv'
print("output_file:", output_file)

# Get And Print filter items from ini file
cfg = ConfigParser()
cfg.read("column_name.ini")
column_cfg = dict(cfg.items("UserCfg"))
filters = column_cfg["filter_column"]
# convert str to list
filter_list = filters.split(',')
print("filter_list:", filter_list)

# Generate new file based on the original file and filter items.
df = pd.read_csv(input_file)
df0 = df.loc[:, filter_list]
df0.to_csv(output_file, index=False, encoding='utf-8-sig')
print('---------------------------------------')
print(df0)   # if don't need show the file content ,please remark this line.
