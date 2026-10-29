# pylint: skip-file
# -*- coding: utf-8 -*-
"""
:created on: 05-16-2024

:copyright: Nokia
"""
from datetime import datetime, timedelta
import importlib
import subprocess
import pkgutil
import os
import re
import logging
import warnings
from difflib import SequenceMatcher
import zipfile
import tarfile
import gzip
import lzma
import shutil

logging.basicConfig(filename='./ERR_WRN_LOG.log',
                    format='[%(asctime)s-%(filename)s-%(levelname)s:%(message)s]',
                    level=logging.DEBUG, filemode='a',
                    datefmt='%Y-%m-%d%I:%M:%S %p')
warnings.filterwarnings('ignore', category=UserWarning)
filter_info_list = ['WRN/', 'ERR/']
log_level_dic = {0: 'ERR/',
                 1: 'WRN/',
                 2: 'INF/',
                 3: 'DBG/'}
log_level_dic = dict(sorted(log_level_dic.items()))
ignore_info_list = []
expected_match_ratio = 0.7
expected_data_line = 7000
compressed_list = ['.gz', '.tar', '.zip', '.xz', '.tgz']
column_names = [
    'Log_Name',
    'Line',
    'Time',
    'Component',
    'Log_Level',
    'Description',
    'Short_description']
Base_column_names = [
    'Component',
    'Log_Level',
    'Description',
    'Sum_Total',
    'Log_Name']
Differ_column_names = [
    'Component',
    'Log_Level',
    'Description',
    'Sum_Total',
    'Status',
    'Log_Name']
http_proxy = '--proxy=http://10.144.1.10:8080'


def install_package(package):
    try:
        logging.info(f'start install {package}')
        subprocess.call(['pip', 'install', '-U', 'numpy', package, http_proxy])
    except Exception as e:
        raise (AssertionError("Error installing package " + str(e)))


def install_and_import_package(package):
    # print("pandas library installation")
    if not bool(pkgutil.find_loader(package)):
        install_package(package)
    return importlib.import_module(package)


def creat_excel_file(log_path, filename, timestamp):
    install_and_import_package('openpyxl')
    import openpyxl
    new_filename = f"{filename}_{timestamp}.xlsx"
    output_dir = os.path.dirname(log_path)
    log_file_name = f"ERR_WRN_LOG_{timestamp}.txt"
    outfile_excel = os.path.join(log_path, new_filename)
    log_file = os.path.join(log_path, log_file_name)
    # print(f"log file is {log_file} ")
    try:
        os.remove(outfile_excel)
    except OSError:
        pass
    wb = openpyxl.Workbook()
    wb.save(outfile_excel)
    return outfile_excel


def find_txt_files(log_path):
    txt_files = []
    loop_flag = 0
    decompression_log = extract_compressed_file(log_path, loop_flag)
    if decompression_log is None:
        decompression_log = log_path
    for root, dirs, files in os.walk(decompression_log):
        for file in files:
            if file.lower().endswith('.log'):
                txt_files.append(os.path.join(root, file))
    if len(txt_files) == 0:
        logging.error(
            f"there is no logs in {log_path} is not found, please check。")
    return txt_files


def Check_ERR_WRN_From_Per_Syslog(
        log_file, filter_list, ignore_list, df_log):
    # Log_Level_pattern = re.compile(r"^(?:\S+\s+){5}\S+\s+(\S+)\/.*$", re.I)
    # t0 = datetime.now()
    install_and_import_package('pandas')
    import pandas as pd
    ERR_WRN_num_per_log = 0
    ERR_WRN_num_data = 0
    # for filter_info in filter_list:
    #    filter_info = str(filter_info)
    #    found = False
    #   filter_info_pattern = re.compile(filter_info, re.I)
    found = False
    df_log_new = pd.DataFrame(columns=column_names)
    with open(log_file, 'r+') as file:
        lines = file.readlines()
        # lines = s.splitlines()
        ignore = False
        for line in lines:
            for filter_info in filter_list:
                filter_info = str(filter_info)
                filter_info_pattern = re.compile(filter_info, re.I)
                matches = re.findall(filter_info_pattern, line)
                if matches:
                    break
            if matches:
                t0 = datetime.now()
                if len(ignore_list) != 0:
                    for ignore_info in ignore_list:
                        ignore_info_pattern = re.compile(ignore_info, re.I)
                        ignore = re.findall(ignore_info_pattern, line)
                if not ignore or len(ignore_list) == 0:
                    line_no = line.split(' ')[0]
                    str_time = line.split(' ', 3)
                    if len(str_time) > 3:
                        time = str_time[1] + ' ' + str_time[2]
                    for key, log_level in log_level_dic.items():
                        log_level_pattern = re.compile(log_level, re.I)
                        log_level = re.findall(log_level_pattern, line)
                        if log_level:
                            log_level_list = list(set(log_level))
                            log_level = log_level_list[0]
                            break
                    str_component = line.split(log_level)[1]
                    short_description = log_level + str_component
                    log_level = log_level.replace('/', '')
                    str_component_1 = str_component.split(' ', 1)[0]
                    char_exists_0 = ',' in str_component_1
                    if char_exists_0:
                        str_component_2 = str_component_1.split(',', 1)[0]
                    else:
                        str_component_2 = str_component_1.split(' ', 1)[0]
                    char_exists = '/' in str_component_2
                    if char_exists:
                        component = str_component_2.split('/', 1)[0]
                    else:
                        char_exists = '.' in str_component_2
                        if char_exists:
                            component = str_component_2.split('.', 1)[0]
                        else:
                            char_exists = '(' in str_component_2
                            if char_exists:
                                component = str_component_2.split('(', 1)[0]
                            else:
                                component = str_component_2
                    if len(str_time) > 3:
                        time = str_time[1] + ' ' + str_time[2]
                    data = [
                        log_file, line_no, time, component, log_level, line, short_description]
                    # with open(outfile_csv, 'a', newline='') as file:
                    #    writer = csv.writer(file)
                    #    writer.writerow(data)
                    if ERR_WRN_num_per_log < expected_data_line:
                        df_log.loc[len(df_log.index)] = data
                    elif ERR_WRN_num_per_log >= expected_data_line >= ERR_WRN_num_data:
                        df_log_new.loc[len(df_log_new.index)] = data
                        ERR_WRN_num_data += 1
                    elif ERR_WRN_num_per_log >= expected_data_line and \
                            ERR_WRN_num_data > expected_data_line:
                        df_log_new.loc[len(df_log_new.index)] = data
                        ERR_WRN_num_data = 0
                        df_log = pd.concat(
                            [df_log, df_log_new], ignore_index=True)
                        df_log_new = pd.DataFrame(columns=column_names)
                    found = True
                    ERR_WRN_num_per_log += 1
                    # duration = datetime.now() - t0
                    # print(f'debug time spent is "{duration}".')
                    # print(f'debug ERR_WRN_num_per_log is "{ERR_WRN_num_per_log}".')
        if not found:
            logging.info(
                f'The term "{filter_info}" was not found in the file "{log_file}".')
        # duration = datetime.now() - t0
        # print(f'Check ERR_WRN info in syslog "{log_file}" time spent is "{duration}".')
        # logging.info(f'Check ERR_WRN info in syslog "{log_file}" time spent is "{duration}".')
    return ERR_WRN_num_per_log, df_log


def Check_ERR_WRN_From_All_Syslog(
        log_path, ERR_WRN_path, timestamp, filter_list, ignore_list, case_name='empty_name'):
    t0 = datetime.now()
    install_and_import_package('pandas')
    import pandas as pd
    install_and_import_package('openpyxl')
    import openpyxl
    ERR_WRN_excel_name = 'ERR_WRN_Logs'
    ERR_WRN_log_excel = creat_excel_file(
        ERR_WRN_path, ERR_WRN_excel_name, timestamp)
    syslog_path_name = 'ERR_WRN_Syslog_' + timestamp
    ERR_WRN_syslog_path = os.path.join(ERR_WRN_path, syslog_path_name)
    os.makedirs(ERR_WRN_syslog_path, exist_ok=True)
    for filename in os.listdir(log_path):
        log_file = os.path.join(log_path, filename)
        if os.path.isfile(log_file):
            shutil.copy(log_file, ERR_WRN_syslog_path)
    txt_files_list = find_txt_files(ERR_WRN_syslog_path)
    df_log = pd.DataFrame(columns=column_names)
    ERR_WRN_num = 0
    # filter_info_list = ERR_WRN_Filter_Info.Filter_Info
    # ignore_info_list = ERR_WRN_Filter_Info.white_list
    if len(filter_list) == 0:
        logging.error("filter_list is empty, please check。")
        return
    if len(ignore_list) == 0:
        logging.info("white_list is empty, please check。")
    loop_number = 0
    for log_file in txt_files_list:
        ERR_WRN_num_per_log, df_log = Check_ERR_WRN_From_Per_Syslog(
            log_file, filter_list, ignore_list, df_log)
        ERR_WRN_num += ERR_WRN_num_per_log
    book = openpyxl.load_workbook(ERR_WRN_log_excel)
    df_log.to_excel(ERR_WRN_log_excel, sheet_name='ERR_WRN_Log', index=False)
    duration = datetime.now() - t0
    # print(
    # f'Check ERR_WRN info in syslog "{log_file}" time spent is
    # "{duration}".')
    logging.info(
        f'Check ERR_WRN info in syslog "{log_file}" time spent is "{duration}".')
    return ERR_WRN_log_excel, ERR_WRN_num


def generate_one_ERR_WRN_new_base(df_data, df_base):
    drop_row_list = []
    match_number = 0
    log_name_list = []
    ERR_WRN_basic = df_data.loc[0]['Short_description']
    for row_index, row in df_data.iterrows():
        # for row in df_data.itertuples():
        #    row_index = row.Index
        csv_row = df_data.loc[row_index]
        ERR_WRN_content = csv_row['Short_description']
        matcher = SequenceMatcher(
            None, ERR_WRN_content, ERR_WRN_basic)
        match_ratio = matcher.ratio()
        if match_ratio >= expected_match_ratio:
            match_number += 1
            if df_data.loc[0]['Log_Name'] not in log_name_list:
                log_name_list.append(df_data.loc[0]['Log_Name'])
            drop_row_list.append(row_index)
    data0 = [df_data.loc[0]['Component'],
             df_data.loc[0]['Log_Level'],
             df_data.loc[0]['Short_description'],
             match_number,
             log_name_list]
    df_base_filter = df_base[(df_base['Component'] == df_data.loc[0]['Component']) &
                             (df_base['Log_Level'] == df_data.loc[0]['Log_Level'])]
    if len(df_base_filter) > 0:
        match_ratio = 0
        for row_index, row in df_base_filter.iterrows():
            csv_row = df_base_filter.loc[row_index]
            ERR_WRN_content = csv_row['Description']
            matcher = SequenceMatcher(
                None, ERR_WRN_content, ERR_WRN_basic)
            match_ratio = matcher.ratio()
            if match_ratio >= expected_match_ratio:
                match_number = csv_row['Sum_Total'] + match_number
                df_base.loc[row_index, 'Sum_Total'] = match_number
                break
        if match_ratio < expected_match_ratio:
            df_base.loc[len(df_base.index)] = data0
    else:
        df_base.loc[len(df_base.index)] = data0
    if len(drop_row_list) != 0:
        for row_index in drop_row_list:
            df_data = df_data.drop(row_index)
        df_data = df_data.reset_index(drop=True)
    return df_data, df_base


def generate_ERR_WRN_new_base(log_path, timestamp, input_file):
    t0 = datetime.now()
    base_file_name = 'ERR_WRN_Analysis'
    ERR_WRN_base_file = creat_excel_file(
        log_path, base_file_name, timestamp)
    install_and_import_package('pandas')
    import pandas as pd
    df = pd.read_excel(input_file, sheet_name='ERR_WRN_Log')
    df_data = df.loc[:, column_names]
    input_csv_line_sum = len(df_data)
    df_base = pd.DataFrame(columns=Base_column_names)
    df_whitelist = pd.DataFrame(columns=Base_column_names)
    df_data_group_dict = df_data.groupby(by=['Component', 'Log_Level'])
    for name, df_data_group in df_data_group_dict:
        df_data_group = df_data_group.reset_index(drop=True)
        if input_csv_line_sum >= 1:
            loop_max = len(df_data_group) // expected_data_line + 1
            for i in range(loop_max):
                start_row = expected_data_line * i
                end_row = min(
                    start_row + expected_data_line,
                    len(df_data_group))
                df_block = df_data_group.iloc[start_row:end_row]
                df_block = df_block.reset_index(drop=True)
                if len(df_block) == 0:
                    # logging.info("generate_ERR_WRN_new_base is end")
                    break
                for loop in range(0, len(df_block)):
                    df_block, df_base = generate_one_ERR_WRN_new_base(
                        df_block, df_base)
                    if len(df_block) == 0:
                        break
    ERR_WRN_SUM = df_base['Sum_Total'].sum()
    ERR_WRN_Number = len(df_base)
    # print(f"ERR_WRN_SUM is {ERR_WRN_SUM} in this test")
    df_base.to_excel(ERR_WRN_base_file, sheet_name='ERR_WRN_Base', index=False)
    with pd.ExcelWriter(ERR_WRN_base_file, engine='openpyxl', mode='a') as writer:
        df_whitelist.to_excel(writer, sheet_name='Whitelist', index=False)
    duration = datetime.now() - t0
    # print(f'generate_ERR_WRN_new_base "{log_dir}" time spent is "{duration}".')
    logging.info(
        f'generate_ERR_WRN_new_base "{log_path}" time spent is "{duration}".')
    return ERR_WRN_base_file, ERR_WRN_Number, ERR_WRN_SUM


def compare_ERR_WRN_with_base(log_dir, base_file, new_base):
    t0 = datetime.now()
    install_and_import_package('pandas')
    import pandas as pd
    install_and_import_package('openpyxl')
    import openpyxl
    ERR_WRN_diff_csv_line = 0
    df_differ = pd.DataFrame(columns=Differ_column_names)
    df_base_whitelist = pd.DataFrame(columns=Base_column_names)
    base_file_exist = os.path.exists(base_file)
    new_base_exist = os.path.exists(new_base)
    if base_file_exist:
        workbook = openpyxl.load_workbook(base_file)
        if 'ERR_WRN_Base' in workbook.sheetnames:
            df_base_1 = pd.read_excel(base_file, sheet_name='ERR_WRN_Base')
            if len(df_base_1) == 0:
                logging.warning(
                    f"ERR_WRN_Base is empty in excel {base_file}, please check。")
            if 'Whitelist' in workbook.sheetnames:
                whitelist_sheet = workbook['Whitelist']
                df_base_2 = pd.read_excel(base_file, sheet_name='Whitelist')
                df_base_whitelist = df_base_2.loc[:, Base_column_names]
                if len(df_base_2) == 0:
                    logging.warning(
                        f"Whitelist is empty in excel {base_file}, please check。")
                df_base = pd.concat([df_base_1, df_base_2], ignore_index=True)
                # df_base = df_base[df_base.duplicated(keep='first')]
            else:
                df_base = df_base_1
        else:
            logging.warning(
                f"There is no ERR_WRN_Base in excel {base_file} "
                f"and will not analyze if there is new additional ERR_WRN")
            return new_base, ERR_WRN_diff_csv_line
        expected_ERR_WRN_SUM = df_base_1['Sum_Total'].sum()
        expected_ERR_WRN_Number = len(df_base)
        logging.info(
            f"expected_ERR_WRN_SUM is {expected_ERR_WRN_SUM}")
        df_base_data = df_base.loc[:, Base_column_names]
        base_file_line_sum = len(df_base_data)
    else:
        logging.warning(f"{base_file} is not found, please check。")
        # return ERR_WRN_diff_csv, ERR_WRN_diff_csv_line
        return new_base, ERR_WRN_diff_csv_line
    if new_base_exist:
        workbook = openpyxl.load_workbook(new_base)
        if 'ERR_WRN_Base' in workbook.sheetnames:
            df_new_base = pd.read_excel(new_base, sheet_name='ERR_WRN_Base')
            if len(df_new_base) == 0:
                logging.warning(
                    f"new ERR_WRN_Base is empty in excel {new_base}, please check。")
            if 'Whitelist' in workbook.sheetnames:
                workbook.remove(workbook['Whitelist'])
                workbook.save(new_base)
            with pd.ExcelWriter(new_base, engine='openpyxl', mode='a') as writer:
                df_base_whitelist.to_excel(
                    writer, sheet_name='Whitelist', index=False)
        else:
            logging.warning(
                f"There is no new ERR_WRN_Base in excel {new_base} "
                f"and will not analyze if there is new additional ERR_WRN")
            return new_base, ERR_WRN_diff_csv_line
        df_new_base_data = df_new_base.loc[:, Base_column_names]
        new_base_line_sum = len(df_base_data)
    else:
        # raise Exception(f"{new_base} is not found, please check。")
        logging.warning(f"{new_base} is not found, please check。")
        # return ERR_WRN_diff_csv, ERR_WRN_diff_csv_line
        return new_base, ERR_WRN_diff_csv_line
    if base_file_line_sum >= 1 and new_base_line_sum >= 1:
        for row_index, row in df_new_base_data.iterrows():
            # for new_base_row in range(0, df_new_base_data_row_count):
            new_base_row = df_new_base_data.loc[row_index]
            component = new_base_row['Component']
            log_level = new_base_row['Log_Level']
            Sum_Total = new_base_row['Sum_Total']
            new_base_ERR_WRN_content = new_base_row['Description']
            log_name = new_base_row['Log_Name']
            data = [
                component,
                log_level,
                new_base_ERR_WRN_content,
                Sum_Total,
                'New',
                log_name]
            drop_row_list = []
            match_ratio = 0
            for base_row_index, row in df_base_data.iterrows():
                # for base_row in range(0, df_base_data_row_count):
                base_row = df_base_data.loc[base_row_index]
                base_ERR_WRN_content = base_row['Description']
                matcher = SequenceMatcher(
                    None, base_ERR_WRN_content, new_base_ERR_WRN_content)
                match_ratio = matcher.ratio()
                if match_ratio >= expected_match_ratio:
                    drop_row_list.append(base_row_index)
                    # logging.info(
                    # f"There is the same ERR OR WRN in base ERR_WRN file
                    # {base_file}")
                    break
            if match_ratio >= expected_match_ratio:
                if len(drop_row_list) != 0:
                    for row_index in drop_row_list:
                        df_base_data = df_base_data.drop(row_index)
            df_base_data = df_base_data.reset_index(drop=True)
            if match_ratio < expected_match_ratio:
                # print(f"There is different ERR OR WRN in new base ERR_WRN file {new_base}, please check")
                df_differ.loc[len(df_differ.index)] = data
                ERR_WRN_diff_csv_line += 1
        if ERR_WRN_diff_csv_line > 0:
            logging.info(f"There is new ERR OR WRN in this test,"
                         f" the diff have {ERR_WRN_diff_csv_line} please check")
        else:
            logging.info(
                f"Congratulations! There is no different ERR OR WRN comparing with the ERR_WRN base file")
        # print("ERR_WRN_diff_csv_line is :{}".format(ERR_WRN_diff_csv_line))
        if len(df_base_data) > 0:
            for row_index, row in df_base_data.iterrows():
                new_base_row = df_base_data.loc[row_index]
                component = new_base_row['Component']
                log_level = new_base_row['Log_Level']
                Sum_Total = new_base_row['Sum_Total']
                new_base_ERR_WRN_content = new_base_row['Description']
                log_name = new_base_row['Log_Name']
                data = [
                    component,
                    log_level,
                    new_base_ERR_WRN_content,
                    Sum_Total,
                    'Miss',
                    log_name]
                df_differ.loc[len(df_differ.index)] = data
        duration = datetime.now() - t0
        logging.info(
            f'There is {len(df_base_data)} ERR_WRN not found in this test')
        logging.info(
            f'compare_ERR_WRN_with_base "{log_dir}" time spent is "{duration}".')
    with pd.ExcelWriter(new_base, engine='openpyxl', mode='a') as writer:
        df_differ.to_excel(writer, sheet_name='ERR_WRN_Differ', index=False)
    return new_base, expected_ERR_WRN_SUM, ERR_WRN_diff_csv_line


def Check_ERR_WRN(log_path, ERR_WRN_path, sw_ver, testline,
                  check_diff=True, fail_case=False, user_base_file=None,
                  filter_list=None, ignore_list=None, case_name='empty_case_name', remove_ERR_WRN_excel=True,
                  expected_ERR_WRN_differ=0, expected_ERR_WRN_deviation=0.2,
                  enable_clear_log=False, keep_log_days=20,
                  filesSystem='/dev/vda2', max_used_space_ratio=0.9):
    logging.info("Start Check_ERR_WRN_From_All_Syslog")
    # print("Start Check_ERR_WRN_From_All_Syslog")
    ERR_WRN_differ_number = 0
    expected_ERR_WRN = 0
    if filter_list is None or len(filter_list) == 0:
        filter_list = filter_info_list
    if ignore_list is None or len(ignore_list) == 0:
        ignore_list = ignore_info_list
    case_ERR_WRN_path, test_ERR_WRN_path, TL_ERR_WRN_path = \
        manage_ERR_WRN_analysis_path(ERR_WRN_path, testline, sw_ver, case_name)
    if user_base_file is None:
        # print("Start get base")
        base_file = get_refer_ERR_WRN_base(case_ERR_WRN_path, sw_ver)
    else:
        base_file = user_base_file
    logging.info(f"ERR_WRN base file is {base_file}")
    if enable_clear_log:
        logging.info(
            f"begin clear old ERR_WRN analysis and log in path {case_ERR_WRN_path}")
        ignore_time = check_disk_state(filesSystem, max_used_space_ratio)
        clear_ERR_WRN_analysis_log(
            case_ERR_WRN_path,
            base_file,
            ignore_time,
            keep_log_days)
    current_time = datetime.now()
    timestamp = current_time.strftime('%Y%m%d%H%M%S')
    os.makedirs(test_ERR_WRN_path, exist_ok=True)
    ERR_WRN_log_file, ERR_WRN_num = Check_ERR_WRN_From_All_Syslog(
        log_path, test_ERR_WRN_path, timestamp, filter_list, ignore_list, case_name)
    logging.info(
        "Start generate_ERR_WRN_new_base and calculate_the_number_of_ERR_WRN")
    # logging.info(
    #    f"ERR_WRN_log_file is {ERR_WRN_log_file}")
    ERR_WRN_base_file, ERR_WRN_number, ERR_WRN_sum = generate_ERR_WRN_new_base(
        test_ERR_WRN_path, timestamp, ERR_WRN_log_file)
    if base_file is not None:
        if check_diff:
            logging.info(f"Start compare_ERR_WRN_with_base with {base_file}")
            # print(f"Start compare_ERR_WRN_with_base with {base_file}")
            df_differ, expected_ERR_WRN, ERR_WRN_differ_number = compare_ERR_WRN_with_base(
                test_ERR_WRN_path, base_file, ERR_WRN_base_file)
    else:
        logging.warning(f"there is no base file for reference, "
                        f"maybe this is the first run for this case or base file is cleared")

    case_status = Check_test_result(expected_ERR_WRN, expected_ERR_WRN_differ,
                                    ERR_WRN_sum, ERR_WRN_differ_number,
                                    expected_ERR_WRN_deviation, fail_case)
    if remove_ERR_WRN_excel:
        try:
            logging.info(f"Remove the ERR_WRN_log_excel: {ERR_WRN_log_file}")
            os.remove(ERR_WRN_log_file)
        except FileNotFoundError:
            # print(f"{ERR_WRN_base_file} not exist")
            logging.info(f"{ERR_WRN_log_file} not exist")
    return ERR_WRN_num, ERR_WRN_differ_number, case_status


def get_file_type(file_name):
    if file_name.endswith('.gz'):
        try:
            with gzip.open(file_name, 'rt') as gz:
                return 'gz'
        except gzip.BadGzipFile:
            return None
        except FileNotFoundError:
            return None
    elif file_name.endswith('.tar'):
        try:
            with tarfile.open(file_name, 'r:*') as tar:
                tar.getmembers()
                return 'tar'
        except tarfile.TarError:
            return None
    elif file_name.endswith('.xz'):
        try:
            with open(file_name, 'rb') as xz:
                lzma.open(file_name)
                return 'xz'
        except lzma.LZMAError:
            return None
        except OSError:
            return None
    elif file_name.endswith('.zip'):
        try:
            with zipfile.ZipFile(file_name, 'r') as zip:
                zip.read(zip.namelist()[0])
                return 'zip'
        except Exception:
            return None
    elif file_name.endswith('.tgz'):
        try:
            with tarfile.open(file_name, 'r:gz') as tar:
                tar.getmembers()
            return 'tgz'
        except tarfile.TarError:
            return None
    else:
        return None


def extract_one_compressed_file(input_file):
    file_type = get_file_type(input_file)
    folder_path, gz_filename = os.path.split(input_file)
    extracted_filename = os.path.splitext(gz_filename)[0]
    out_file_path = os.path.join(folder_path, extracted_filename)
    file_size = os.path.getsize(input_file)
    # print(f'input_file is "{input_file}".')
    if file_size != 0:
        if os.path.exists(out_file_path):
            if os.path.isdir(out_file_path):
                logging.info(
                    f'"{out_file_path}" is exist and delete this path')
                for root, dirs, files in os.walk(out_file_path):
                    for dir_name in dirs:
                        os.chmod(os.path.join(root, dir_name), 0o777)
                    for file_name in files:
                        os.chmod(os.path.join(root, file_name), 0o777)
                shutil.rmtree(out_file_path)
                os.makedirs(out_file_path)
            else:
                logging.info(
                    f'File "{out_file_path}" is exist, do not compressed file.')
                return out_file_path
        else:
            os.makedirs(out_file_path)
        os.chmod(out_file_path, 0o777)
        if file_type == 'tgz':
            with tarfile.open(input_file, 'r:*') as file_in:
                file_in.extractall(out_file_path)
        if file_type == 'gz':
            file_name = os.path.basename(input_file).replace('.gz', '')
            with gzip.open(input_file, 'rb') as file_in:
                content = file_in.read()
                with open(os.path.join(out_file_path, file_name), 'wb+') as file_out:
                    file_out.write(content)
        elif file_type == 'tar':
            with tarfile.open(input_file, "r:*") as file_in:
                file_in.extractall(out_file_path)
        elif file_type == 'zip':
            with zipfile.ZipFile(input_file, 'r') as file_in:
                file_in.extractall(out_file_path)
        elif file_type == 'xz':
            file_name = os.path.basename(input_file).replace('.xz', '')
            try:
                with lzma.open(input_file, 'rb') as file_in:
                    content = file_in.read()
                    with open(os.path.join(out_file_path, file_name), 'wb+') as file_out:
                        file_out.write(content)
            except EOFError:
                logging.warning("There is EOFError")
        else:
            logging.info('uncompressed file end.')
    else:
        logging.info(f'"{input_file}" is empty.')
    for root, dirs, files in os.walk(out_file_path):
        for dir_name in dirs:
            os.chmod(os.path.join(root, dir_name), 0o777)
        for file_name in files:
            os.chmod(os.path.join(root, file_name), 0o777)
    return out_file_path


def extract_compressed_file(log_path, loop_flag):
    files_list = list_compressed_files_in_directory(log_path)
    decompression_log = None
    if len(files_list) != 0:
        for file in files_list:
            decompression_file_path = extract_one_compressed_file(file)
            if loop_flag == 0 and decompression_log is None:
                decompression_log = decompression_file_path
            loop_flag += 1
            extract_compressed_file(decompression_file_path, loop_flag)
    else:
        logging.info(f'There is no compressed file in "{log_path}".')
        # if decompression_log is None:
        #    decompression_log = log_path
    return decompression_log


def list_compressed_files_in_directory(log_path):
    files_list = []
    if os.path.exists(log_path) and os.path.isdir(log_path):
        for root, dirs, files in os.walk(log_path):
            for file in files:
                for suffix in compressed_list:
                    if file.endswith(suffix):
                        files_list.append(os.path.join(root, file))
    # print(f'files_list is "{files_list}".')
    return files_list


def manage_ERR_WRN_analysis_path(
        ERR_WRN_path, testline, sw_ver, case_name='empty_case_name'):
    test_ERR_WRN_path = os.path.join(ERR_WRN_path, testline, case_name, sw_ver)
    case_ERR_WRN_path = os.path.join(ERR_WRN_path, testline, case_name)
    TL_ERR_WRN_path = os.path.join(ERR_WRN_path, testline)
    # os.makedirs(test_ERR_WRN_path, exist_ok=True)
    return case_ERR_WRN_path, test_ERR_WRN_path, TL_ERR_WRN_path


def get_refer_ERR_WRN_base(case_ERR_WRN_path, sw_ver):
    Base_ERR_WRN_path = os.path.join(case_ERR_WRN_path, sw_ver)
    logging.info(f"Base_ERR_WRN_path is {Base_ERR_WRN_path}")
    key_string = 'ERR_WRN_Analysis'
    basefile = None
    if os.path.exists(case_ERR_WRN_path) and os.listdir(case_ERR_WRN_path):
        if not os.path.exists(Base_ERR_WRN_path):
            sw_ver_release = sw_ver.split('_')[0]
            logging.info(f"sw_ver_release is {sw_ver_release}")
            name_list = []
            directories_list = []
            build_dic = {}
            release_dic = {}
            for root, dirs, files in os.walk(case_ERR_WRN_path):
                for name in dirs:
                    if 'SBTS' in name and 'ENB' in name:
                        name_split = name.split('_')
                        name_list.append(name_split[0])
                        directories_list.append(name)
            if sw_ver_release not in name_list:
                if 'SBTS' in sw_ver_release:
                    name_target = sw_ver_release.replace('SBTS', '')
                    if 'R' in sw_ver_release:
                        name_target = name_target.replace('R', '')
                else:
                    logging.warning(
                        f"There is no base file directory for this case {Base_ERR_WRN_path}")
                    return basefile
                name_target = int(name_target)
                release_dic[name_target] = sw_ver
                for name in name_list:
                    name_id = name.split('_', 1)[0]
                    if 'SBTS' in sw_ver_release:
                        name_id = name_id.replace('SBTS', '')
                        if 'R' in sw_ver_release:
                            name_id = name_id.replace('R', '')
                    else:
                        logging.warning(
                            f"Get the SW release from the name of {case_ERR_WRN_path}")
                        return basefile
                    name_id = int(name_id)
                    release_dic[name_id] = name
                sorted_keys = sorted(release_dic.keys())
                release_dic_sorted = {
                    key: release_dic[key] for key in sorted_keys}
                target_index = sorted_keys.index(name_target)
                if target_index == 0 and len(sorted_keys) >= 2:
                    expect_release_key = sorted_keys[1]
                    expect_release = release_dic_sorted[expect_release_key]
                elif target_index != 0 and len(sorted_keys) >= 2:
                    expect_release_key = sorted_keys[target_index - 1]
                    expect_release = release_dic_sorted[expect_release_key]
                else:
                    logging.warning(
                        f"There is no base file directory for this case {Base_ERR_WRN_path}")
                    return basefile
                sw_ver_release = expect_release
            # print(f"sw_ver_release is {sw_ver_release}")
            for directories in directories_list:
                if sw_ver_release not in directories:
                    # print(f"directories is {directories}")
                    index = directories_list.index(directories)
                    directories_list.pop(index)
                    # print(f"directories_list is {directories_list}")
                if len(directories_list) == 0:
                    break
            # print(f"directories_list is {directories_list}")
            for directories in directories_list:
                build_name = directories.split('_', 2)[2]
                build_name = int(build_name.replace('_', ''))
                build_dic[build_name] = directories
            # print(f"build_dic is {build_dic}")
            max_key = max(build_dic, key=lambda k: build_dic[k])
            basefile_path = os.path.join(case_ERR_WRN_path, build_dic[max_key])
            basefile = get_first_base_file(basefile_path, key_string)
            # print(f"basefile is {basefile}")
        elif os.listdir(Base_ERR_WRN_path):
            basefile = get_first_base_file(Base_ERR_WRN_path, key_string)
        else:
            logging.warning(
                f"There is no base file directory for this case {Base_ERR_WRN_path}")
            return basefile
    else:
        logging.warning(
            f"There is no base file directory for this case {Base_ERR_WRN_path}")
        return basefile
    return basefile


def get_first_base_file(Base_ERR_WRN_path, key_string):
    # excel_files = glob.glob(os.path.join(Base_ERR_WRN_path, "*.xlsx"))
    excel_files = []
    for root, dirs, files in os.walk(Base_ERR_WRN_path):
        for file in files:
            if file.endswith('.xlsx'):
                excel_files.append(os.path.join(root, file))
    filtered_files = [
        file for file in excel_files if key_string in os.path.basename(file)]
    base_file_dic = {}
    basefile = None
    if len(filtered_files) > 0:
        for base_file in filtered_files:
            file_stats = os.stat(base_file)
            modification_time = file_stats.st_mtime
            base_file_dic[modification_time] = base_file
        base_file_dic = {key: base_file_dic[key]
                         for key in sorted(base_file_dic.keys())}
        min_key = max(base_file_dic, key=lambda k: base_file_dic[k])
        basefile = base_file_dic[min_key]
    else:
        logging.info(
            f"There is no base files in {Base_ERR_WRN_path}")
    return basefile


def Check_test_result(expected_ERR_WRN, expected_ERR_WRN_differ, NEW_ERR_WRN, ERR_WRN_differ,
                      expected_ERR_WRN_deviation, fail_case=False):
    case_status = 'Pass'
    if expected_ERR_WRN < NEW_ERR_WRN <= expected_ERR_WRN * \
            (1 + expected_ERR_WRN_deviation):
        ERR_WRN_deviation = round(
            (NEW_ERR_WRN - expected_ERR_WRN) / expected_ERR_WRN, 2)
        logging.warning(f"!!!!ERR_WRN sum {NEW_ERR_WRN} exceed expectations by {ERR_WRN_deviation * 100}% "
                        f"in this testing")
    elif NEW_ERR_WRN > expected_ERR_WRN * (1 + expected_ERR_WRN_deviation):
        logging.error(f"!!!!ERR_WRN sum exceed expectations by {expected_ERR_WRN_deviation * 100}% "
                      f"in this testing, please check!!!!")
        if fail_case:
            case_status = 'Fail'
    elif NEW_ERR_WRN <= expected_ERR_WRN:
        logging.info(
            f"Congratulation!!ERR_WRN sum {NEW_ERR_WRN} is less than expected_ERR_WRN sum {expected_ERR_WRN}")
    logging.info(f"Expected ERR_WRN_differ num is {expected_ERR_WRN_differ}")
    if ERR_WRN_differ > expected_ERR_WRN_differ:
        logging.error(
            f"!!!!Additional new ERR_WRN num {ERR_WRN_differ} are in this testing, please check!!!!")
        if fail_case:
            case_status = 'Fail'
    else:
        logging.info(
            f"Congratulation!!!new ERR_WRN num meet expectations in this testing")
    return case_status


def clear_ERR_WRN_analysis_log(
        case_ERR_WRN_log_path, base_file, ignore_time, keep_log_days):
    logging.info(f"Start clear_ERR_WRN_analysis_log")
    if os.path.exists(case_ERR_WRN_log_path):
        if len(os.listdir(case_ERR_WRN_log_path)) > 0:
            for root, dirs, files in os.walk(case_ERR_WRN_log_path):
                for file_name in files:
                    file_path = os.path.join(root, file_name)
                    creation_time = datetime.fromtimestamp(
                        os.path.getctime(file_path))
                    if datetime.now() - creation_time > timedelta(days=keep_log_days) or ignore_time:
                        if base_file is not None:
                            if base_file != file_path:
                                os.remove(file_path)
                        else:
                            os.remove(file_path)
            for root, dirs, files in os.walk(case_ERR_WRN_log_path, topdown=False):
                if not os.listdir(root):
                    os.rmdir(root)
        else:
            logging.info(f"There is no logs need to be cleared")
    else:
        logging.info(f"There is no path {case_ERR_WRN_log_path}")


def check_disk_state(filesSystem, max_used_space_ratio):
    install_and_import_package('psutil')
    import psutil
    disk_partitions = psutil.disk_partitions()
    for partitions in disk_partitions:
        if partitions.device == filesSystem:
            dev_mountpoint = partitions.mountpoint
    usage = psutil.disk_usage(dev_mountpoint)
    used_space_ratio = usage.percent / 100
    logging.info(f"used_space_ratio is {used_space_ratio}")
    ignore_time = False
    if used_space_ratio > max_used_space_ratio:
        ignore_time = True
    return ignore_time


if __name__ == "__main__":
    log_path = '/home/ute/ERR_WRN_analysis/'
    syslog_path = '/home/ute/BTS_logs/7_5_UTE5G402T928/'
    testline = '7_5_UTE5G402T928'
    ERR_WRN_num, ERR_WRN_differ_number, case_status = \
        Check_ERR_WRN(log_path=syslog_path, testline=testline, ERR_WRN_path=log_path,
                      check_diff=True, sw_ver='SBTS25R1_ENB_9999_240813_000011',
                      case_name='[1]CB010636_A_01_RLC_PDU_volume_counters_SA_IGNB')
