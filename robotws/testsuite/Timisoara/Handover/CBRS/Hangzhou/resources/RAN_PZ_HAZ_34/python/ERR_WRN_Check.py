# Version: V1.5
# Date: 26/5/2025
# Description: Check ERR/WRN print from BTS syslog and RF runtim log in snapshot
# History:
# 11/8/2024 V1.0: First version of Check ERR/WRN print from BTS syslog
# 13/9/2024 V1.1: Check if there is new ERR/WRN print compared with the previous build
# 23/12/2024 V1.2: Compared with the data in the compass
# 21/3/2025 V1.3:  Check ERR/WRN print from RF runtime log in the snapshot
# 29/5/2025 V1.4:  Compared with the common whitelist
# 3/7/2025 V1.5:  the ERR WRN PR compared with the compass

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
from pathlib import Path
import json
import time
from testsuite.Timisoara.Handover.CBRS.Hangzhou.resources.RAN_PZ_HAZ_34.python.common_Whitelist \
    import Whitelist, confluence_update_date
from robot.libraries.BuiltIn import BuiltIn


# __all__ = ['Test_PC_IP', 'Test_PC_username', 'Test_PC_password','DU_OAM_IP', 'MRBTS_Identifier']

# sys.setrecursionlimit(1500)
logging.basicConfig(filename='./ERR_WRN_LOG.log',
                    format='[%(asctime)s-%(filename)s-%(levelname)s:%(message)s]',
                    level=logging.DEBUG, filemode='a',
                    datefmt='%Y-%m-%d%I:%M:%S %p')
warnings.filterwarnings('ignore', category=UserWarning)
# filter_info_list = ['ERR/']
filter_info_list = [' WRN/', ' ERR/']
# log_level_dic = {0: 'ERR/',
#                 1: 'WRN/',
#                 2: 'INF/',
#                 3: 'DBG/'}
log_level_dic = {0: 'ERR/',
                 1: 'WRN/'}
log_level_dic = dict(sorted(log_level_dic.items()))
ignore_info_list = []
expected_match_ratio = 0.95
expected_data_line = 7000
compressed_list = ['.gz', '.tar', '.zip', '.xz', '.tgz', '.tar.gz']
remote_server_IP = '10.70.226.9'
log_server_link = 'https://10.70.226.9/syslog'
remote_server_user = 'ute'
remote_server_pwd = 'UTE.debian12'
column_names = [
    'Log_Name',
    'Line',
    'Time',
    'Component',
    'Process',
    'Log_Level',
    'Description',
    'Short_description']
Base_column_names = [
    'Component',
    'Process',
    'Log_Level',
    'Description',
    'Sum_Total',
    'Log_Name']
Differ_column_names = [
    'Component',
    'Process',
    'Log_Level',
    'Description',
    'Sum_Total',
    'Status',
    'Log_Name',
    'Whitelist_Common_No',
    'Whitelist_Confluence_link']
Compass_column_names = [
    'Component',
    'Process',
    'Log Detail',
    'Severity',
    'Feature',
    'Release',
    'SW Info',
    'HW Info',
    'Contributor',
    'Squad Group',
    'Status',
    'Analysis Summary',
    'Attached PR',
    'Key Signature',
    'Description',
    'Additional Info',
    'Created',
    'Compass Link']

Compass_column_names_mandatory = [
    'Component',
    'Process',
    'Log Detail',
    'Severity',
    'Feature',
    'Release',
    'SW Info',
    'HW Info',
    'Status',
    'Analysis Summary']

RF_column_names = [
    'SN',
    'Log_Type',
    'Log_Name',
    'Line',
    'Time',
    'Component',
    'Process',
    'Log_Level',
    'Description',
    'Short_description']

RF_Base_column_names = [
    'SN',
    'Log_Type',
    'Component',
    'Process',
    'Log_Level',
    'Description',
    'Sum_Total',
    'Log_Name']
RF_Differ_column_names = [
    'SN',
    'Log_Type',
    'Component',
    'Process',
    'Log_Level',
    'Description',
    'Sum_Total',
    'Status',
    'Log_Name']
Whitelist_Common = [
    'No',
    'Regular_expression',
    'Example',
    'Reason']
Component_Dic = {'BOAM': ['NTS', 'SysAdapter', 'HAS', 'DEM', 'TAS', 'BTSOM', 'DCS', 'MCTRL', 'MCI', 'BM', 'IMS', 'FRI',
                          'NETCONF-Agent', 'GTS', 'LTS', 'NE3SAdapt', 'ONAPAdapt', 'BSTAT', 'SWM', 'TTS', 'PDL', 'WTS',
                          'PMSTAT'],
                 'L3': ['cp_if', 'cp_nb', 'cp_sctp', 'cp_sctp', 'cp_ue', 'cp_rt', 'cp_cell', 'cp_nrt'],
                 'L2': ['L2-PS', 'L2Hi', 'L2Lo'],
                 'L1': ['l1_application_rt', 'l1_application_nrt'],
                 'PS': ['CCS', 'LFS', 'systemd', 'UPHWAPI', 'MCUHWAPI'],
                 'TRS': ['TRSSW', 'dhcp', 'ipsecmgmt', 'nwmgmt', 'nftmgmt', 'TPL', 'trsconfig']}
http_proxy = '--proxy=http://10.144.1.10:8080'
compass_url = "http://compass.dyn.nesc.nokia.net:8080/"
Whitelist_Confluence_link = "https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1637010227#:~:" \
                            "text=and%20requires%20interpretation-,23," \
                            "-%5E(.*)%20kernel%3A%20%5C%5B%5Cs*(.%2B)%5C%5D%20WARNING"
# filter_info = '^(?=.*BL2341N4AQV)(?=.*(runtime(_DEFAULT|slave)?\.log)(\\.\\d{1,2})?$)(?!.*pm\.)'
# filter_info = '^(?=.*(BL2341N4AQV|DH214500039|EB2334R0314))(?=.*(runtime(_DEFAULT|slave)?\\.log)(\\.\\d{1,2})?$)' \
#             '(?!.*(pm\\.|faultLogs|pm_(1[1-9]|[1-9]|20)))'
filter_info = '(?=.*(runtime(_DEFAULT|slave)?\\.log)(\\.\\d{1,2})?$)' \
              '(?!.*(pm\\.|faultLogs|pm_(1[1-9]|[1-9]|20)))'
log_filter_regx = '.*(ERR\\/|WRN\\/).*'
# log_filter_regx = '.*(ERR\/).*'


def install_package(package):
    try:
        logging.info(f'start install {package}')
        subprocess.call(['pip', 'install', '-U', 'numpy', package, http_proxy])
    except Exception as e:
        raise (AssertionError("Error installing package " + str(e)))


def install_and_import_package(package):
    # logging.info("pandas library installation")
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
    # logging.info(f"log file is {log_file} ")
    try:
        os.remove(outfile_excel)
    except Exception as e:
        pass
    wb = openpyxl.Workbook()
    wb.save(outfile_excel)
    return outfile_excel


def find_txt_files(log_path):
    txt_files = []
    loop_flag = 0
    log_root_path = None
    logging.info(
        f"log_path for find_txt_files is {log_path}")
    log_root_path, decompression_log = extract_compressed_file(
        log_path, log_root_path, loop_flag)
    logging.info(
        f"log_root_path is {log_root_path}, decompression_log is {decompression_log}")
    if decompression_log is None:
        decompression_log = log_path
    for root, dirs, files in os.walk(decompression_log):
        for file in files:
            if file.lower().endswith('.log'):
                txt_files.append(os.path.join(root, file))
    if len(txt_files) == 0:
        logging.error(
            f"there is no logs in {log_path} is not found, please check?")
    return txt_files, decompression_log


def Check_ERR_WRN_From_Per_Syslog(
        log_file, filter_list, ignore_list, df_log):
    # Log_Level_pattern = re.compile(r"^(?:\S+\s+){5}\S+\s+(\S+)\/.*$", re.I)
    # t0 = datetime.now()
    install_and_import_package('pandas')
    import pandas as pd
    install_and_import_package('chardet')
    import chardet
    ERR_WRN_num_per_log = 0
    ERR_WRN_num_data = 0
    total_lines_per_file = 0
    # for filter_info in filter_list:
    #    filter_info = str(filter_info)
    #    found = False
    #   filter_info_pattern = re.compile(filter_info, re.I)
    found = False
    df_log_new = pd.DataFrame(columns=column_names)
    if os.path.exists(log_file):
        os.system(f"chmod 777 {log_file}")
        try:
            with open(log_file, 'rb') as f:
                raw_data = f.read(100)
                encode_check = chardet.detect(raw_data)
                encode_type = encode_check['encoding']
                logging.info(f"encode of {log_file} is {encode_type}")
        except Exception as e:
            encode_type = 'utf-8'
            logging.warning(
                f"An error occurred while detect encode of {log_file}: {e}")
        try:
            with open(rf'{log_file}', 'r', errors='replace', encoding=encode_type) as file:
                logging.info(f"read syslog all lines")
                lines = file.readlines()
                # lines = s.splitlines()
                total_lines_per_file = total_lines_per_file + len(lines)
                logging.info(
                    f"there is {len(lines)} lines in the log file : {log_file}")
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
                                ignore_info_pattern = re.compile(
                                    ignore_info, re.I)
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
                            str_component = line.split(log_level, 1)[1]
                            short_description = log_level + str_component
                            log_level = log_level.replace('/', '')
                            str_component_1 = str_component.split(' ', 1)[0]
                            char_exists_0 = ',' in str_component_1
                            if char_exists_0:
                                str_component_2 = str_component_1.split(',', 1)[
                                    0]
                            else:
                                str_component_2 = str_component_1.split(' ', 1)[
                                    0]
                            char_exists = '/' in str_component_2
                            if char_exists:
                                component = str_component_2.split('/', 1)[0]
                            else:
                                char_exists = '.' in str_component_2
                                if char_exists:
                                    component = str_component_2.split('.', 1)[
                                        0]
                                else:
                                    char_exists = '(' in str_component_2
                                    if char_exists:
                                        component = str_component_2.split(
                                            '(', 1)[0]
                                    else:
                                        component = str_component_2
                            if len(str_time) > 3:
                                time = str_time[1] + ' ' + str_time[2]
                            process_description = line.split(log_level)[0]
                            if process_description.endswith(' '):
                                process_description = process_description.rstrip()
                            process_description_1 = process_description.split(
                                ' ', -1)[-1]
                            if '-' in process_description_1:
                                process_name = process_description_1.split(
                                    '-', 1)[-1]
                            else:
                                process_name = component
                            if component == '.':
                                component = process_name
                            data = [
                                log_file, line_no, time, component, process_name, log_level, line, short_description]
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
                            # logging.info(f'debug time spent is "{duration}".')
                            # logging.info(f'debug ERR_WRN_num_per_log is "{ERR_WRN_num_per_log}".')
                if not found:
                    logging.info(
                        f'The term "{filter_info}" was not found in the file "{log_file}".')
                # duration = datetime.now() - t0
                # logging.info(f'Check ERR_WRN info in syslog "{log_file}" time spent is "{duration}".')
                # logging.info(f'Check ERR_WRN info in syslog "{log_file}" time spent is "{duration}".')
        except Exception as e:
            logging.warning(f"An error occurred while open {log_file}: {e}")
    else:
        logging.error(
            f"the log {log_file} not found, please check?")
    return ERR_WRN_num_per_log, df_log, total_lines_per_file


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
    ERR_WRN_num = 0
    total_lines_all_file = 0
    if os.path.exists(log_path):
        if os.path.isdir(log_path):
            for filename in os.listdir(log_path):
                log_file_name = os.path.join(log_path, filename)
                if os.path.isfile(log_file_name):
                    shutil.copy(log_file_name, ERR_WRN_syslog_path)
        elif os.path.isfile(log_path):
            shutil.copy(log_path, ERR_WRN_syslog_path)
    else:
        logging.error(
            f"!!!!!!!!!!{log_path} is not found, please check!!!!!!!!")
        return ERR_WRN_log_excel, ERR_WRN_num, ERR_WRN_syslog_path, total_lines_all_file
    txt_files_list, decompression_log = find_txt_files(ERR_WRN_syslog_path)
    logging.info(
        f'get syslog in {ERR_WRN_syslog_path}: {txt_files_list}')
    df_log = pd.DataFrame(columns=column_names)
    # filter_info_list = ERR_WRN_Filter_Info.Filter_Info
    # ignore_info_list = ERR_WRN_Filter_Info.white_list
    if len(filter_list) == 0:
        logging.error("filter_list is empty, please check?")
        return ERR_WRN_log_excel, ERR_WRN_num, ERR_WRN_syslog_path
    if len(ignore_list) == 0:
        logging.info("white_list is empty, please check?")
    loop_number = 0
    for log_file in txt_files_list:
        ERR_WRN_num_per_log, df_log, total_lines_per_file = Check_ERR_WRN_From_Per_Syslog(
            log_file, filter_list, ignore_list, df_log)
        total_lines_all_file += total_lines_per_file
        ERR_WRN_num += ERR_WRN_num_per_log
    book = openpyxl.load_workbook(ERR_WRN_log_excel)
    df_log.to_excel(ERR_WRN_log_excel, sheet_name='ERR_WRN_Log', index=False)
    duration = datetime.now() - t0
    # logging.info(
    # f'Check ERR_WRN info in syslog "{log_file}" time spent is
    # "{duration}".')
    logging.info(
        f'Check ERR_WRN info in "{log_path}" time spent is "{duration}".')
    try:
        shutil.rmtree(decompression_log)
    except Exception as e:
        logging.warning(
            f"there is one exception when clear path {decompression_log}: {e}")
    return ERR_WRN_log_excel, ERR_WRN_num, ERR_WRN_syslog_path, total_lines_all_file


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
             df_data.loc[0]['Process'],
             df_data.loc[0]['Log_Level'],
             df_data.loc[0]['Short_description'],
             match_number,
             log_name_list]
    df_base_filter = df_base[(df_base['Component'] == df_data.loc[0]['Component']) &
                             (df_base['Log_Level'] == df_data.loc[0]['Log_Level']) &
                             (df_base['Process'] == df_data.loc[0]['Process'])]
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
    df_data_group_dict = df_data.groupby(
        by=['Component', 'Process', 'Log_Level'])
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
    # logging.info(f"ERR_WRN_SUM is {ERR_WRN_SUM} in this test")
    df_base.to_excel(ERR_WRN_base_file, sheet_name='ERR_WRN_Base', index=False)
    with pd.ExcelWriter(ERR_WRN_base_file, engine='openpyxl', mode='a') as writer:
        df_whitelist.to_excel(writer, sheet_name='Whitelist', index=False)
    duration = datetime.now() - t0
    # logging.info(f'generate_ERR_WRN_new_base "{log_dir}" time spent is "{duration}".')
    logging.info(
        f'generate_ERR_WRN_new_base "{log_path}" time spent is "{duration}".')
    return ERR_WRN_base_file, ERR_WRN_Number, ERR_WRN_SUM


def compare_ERR_WRN_with_base(log_dir, base_file, new_base):
    global Whitelist_Common_No, Whitelist_Confluence_link
    t0 = datetime.now()
    install_and_import_package('pandas')
    import pandas as pd
    install_and_import_package('openpyxl')
    import openpyxl
    ERR_WRN_diff_csv_line = 0
    expected_ERR_WRN_SUM = 0
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
                    f"ERR_WRN_Base is empty in excel {base_file}, please check?")
            if 'Whitelist' in workbook.sheetnames:
                whitelist_sheet = workbook['Whitelist']
                df_base_2 = pd.read_excel(base_file, sheet_name='Whitelist')
                df_base_whitelist = df_base_2.loc[:, Base_column_names]
                if len(df_base_2) == 0:
                    logging.warning(
                        f"Whitelist is empty in excel {base_file}, please check?")
                df_base = pd.concat([df_base_1, df_base_2], ignore_index=True)
                # df_base = df_base[df_base.duplicated(keep='first')]
            else:
                df_base = df_base_1
        else:
            logging.warning(
                f"There is no ERR_WRN_Base in excel {base_file} "
                f"and will not analyze if there is new additional ERR_WRN")
            return new_base, expected_ERR_WRN_SUM, ERR_WRN_diff_csv_line
        expected_ERR_WRN_SUM = df_base_1['Sum_Total'].sum()
        expected_ERR_WRN_Number = len(df_base)
        logging.info(
            f"expected_ERR_WRN_SUM is {expected_ERR_WRN_SUM}")
        df_base_data = df_base.loc[:, Base_column_names]
        base_file_line_sum = len(df_base_data)
    else:
        logging.warning(f"{base_file} is not found, please check?")
        # return ERR_WRN_diff_csv, ERR_WRN_diff_csv_line
        return new_base, expected_ERR_WRN_SUM, ERR_WRN_diff_csv_line
    if new_base_exist:
        workbook = openpyxl.load_workbook(new_base)
        if 'ERR_WRN_Base' in workbook.sheetnames:
            df_new_base = pd.read_excel(new_base, sheet_name='ERR_WRN_Base')
            if len(df_new_base) == 0:
                logging.warning(
                    f"new ERR_WRN_Base is empty in excel {new_base}, please check?")
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
            return new_base, expected_ERR_WRN_SUM, ERR_WRN_diff_csv_line
        df_new_base_data = df_new_base.loc[:, Base_column_names]
        new_base_line_sum = len(df_base_data)
    else:
        # raise Exception(f"{new_base} is not found, please check?")
        logging.warning(f"{new_base} is not found, please check?")
        # return ERR_WRN_diff_csv, ERR_WRN_diff_csv_line
        return new_base, expected_ERR_WRN_SUM, ERR_WRN_diff_csv_line
    if base_file_line_sum >= 1 and new_base_line_sum >= 1:
        for row_index, row in df_new_base_data.iterrows():
            # for new_base_row in range(0, df_new_base_data_row_count):
            new_base_row = df_new_base_data.loc[row_index]
            component = new_base_row['Component']
            process_name = new_base_row['Process']
            log_level = new_base_row['Log_Level']
            Sum_Total = new_base_row['Sum_Total']
            new_base_ERR_WRN_content = new_base_row['Description']
            log_name = new_base_row['Log_Name']
            Whitelist_Common_No = None
            Whitelist_Confluence_link = None
            data = [
                component,
                process_name,
                log_level,
                new_base_ERR_WRN_content,
                Sum_Total,
                'New',
                log_name,
                Whitelist_Common_No,
                Whitelist_Confluence_link]
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
                # logging.info(f"There is different ERR OR WRN in new base ERR_WRN file {new_base}, please check")
                df_differ.loc[len(df_differ.index)] = data
                logging.error(
                    f"!!!!!!!!!! there is new syslog error: {new_base_ERR_WRN_content}")
                ERR_WRN_diff_csv_line += 1
        if ERR_WRN_diff_csv_line > 0:
            logging.info(f"There is new ERR OR WRN in this test,"
                         f" the diff have {ERR_WRN_diff_csv_line} please check")
        else:
            logging.info(
                f"Congratulations! There is no different ERR OR WRN comparing with the ERR_WRN base file")
        # logging.info("ERR_WRN_diff_csv_line is :{}".format(ERR_WRN_diff_csv_line))
        if len(df_base_data) > 0:
            for row_index, row in df_base_data.iterrows():
                new_base_row = df_base_data.loc[row_index]
                component = new_base_row['Component']
                process_name = new_base_row['Process']
                log_level = new_base_row['Log_Level']
                Sum_Total = new_base_row['Sum_Total']
                new_base_ERR_WRN_content = new_base_row['Description']
                log_name = new_base_row['Log_Name']
                Whitelist_Common_No = None
                Whitelist_Confluence_link = None
                data = [
                    component,
                    process_name,
                    log_level,
                    new_base_ERR_WRN_content,
                    Sum_Total,
                    'Miss',
                    log_name,
                    Whitelist_Common_No,
                    Whitelist_Confluence_link
                ]
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
                  filesSystem='/dev/vda2', max_used_space_ratio=0.9, feature='Regression',
                  Contributor=None, Squad_Group=None, HW_Info=None,
                  Expected_ERR_WRN_number=0, server_type='local', ERR_WRN_remote_path='/data/ERR_WRN_analysis'):
    global test_path_ver, ignore_time
    ignore_time = False
    logging.info("Start Check_ERR_WRN_From_All_Syslog")
    # logging.info("Start Check_ERR_WRN_From_All_Syslog")
    ERR_WRN_differ_number = 0
    expected_ERR_WRN = 0
    ERR_WRN_num = 0
    case_status = 'Fail'
    base_file = None
    ERR_WRN_base_file = None
    ERR_WRN_syslog_path = None
    case_QC_id = get_case_QC_id()
    remote_log_dir = None
    compass_id_list = []
    try:
        if filter_list is None or len(filter_list) == 0:
            filter_list = filter_info_list
        if ignore_list is None or len(ignore_list) == 0:
            ignore_list = ignore_info_list
        case_ERR_WRN_path, test_ERR_WRN_path, TL_ERR_WRN_path = \
            manage_ERR_WRN_analysis_path(
                ERR_WRN_path, testline, sw_ver, case_name)
        if user_base_file is None:
            # logging.info("Start get base")
            if server_type == 'remote':
                return_list = get_remote_refer_base_file(
                    ERR_WRN_remote_path, testline, sw_ver, case_name)
                base_file = return_list[0]
                test_path_ver = return_list[1]
            else:
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
        ERR_WRN_log_file, ERR_WRN_num, ERR_WRN_syslog_path, total_lines_all_file\
            = Check_ERR_WRN_From_All_Syslog(
                log_path, test_ERR_WRN_path, timestamp, filter_list, ignore_list, case_name)
        logging.info(
            "Start generate_ERR_WRN_new_base and calculate_the_number_of_ERR_WRN")
        # logging.info(
        #    f"ERR_WRN_log_file is {ERR_WRN_log_file}")
        ERR_WRN_base_file, ERR_WRN_number, ERR_WRN_sum = generate_ERR_WRN_new_base(
            test_ERR_WRN_path, timestamp, ERR_WRN_log_file)
        set_xlsx_file_version(ERR_WRN_base_file, sw_ver)
        if remove_ERR_WRN_excel:
            try:
                logging.info(
                    f"Remove the ERR_WRN_log_excel: {ERR_WRN_log_file}")
                os.remove(ERR_WRN_log_file)
            except Exception as e:
                logging.warning(
                    f"Failed:there is exception {e} when execute remove_ERR_WRN_excel")
        local_dir = os.path.dirname(ERR_WRN_base_file)
        file_name_new = os.path.basename(ERR_WRN_base_file)
        if base_file is not None:
            refer_base_name = os.path.basename(base_file)
            refer_base_dir = os.path.dirname(base_file)
            if server_type == 'remote':
                ssh = init_ssh_client()
                base_file = download_file_from_remote(
                    ssh, local_dir, refer_base_dir, refer_base_name)
                logging.info(
                    f"remote_refer_base_file in the local server is: {base_file}")
            if check_diff and base_file is not None:
                logging.info(
                    f"Start compare_ERR_WRN_with_base with {base_file}")
                logging.info(
                    f"test_ERR_WRN_path: {test_ERR_WRN_path}, base_file is {base_file}, "
                    f"ERR_WRN_base_file {ERR_WRN_base_file}")
                ERR_WRN_base_file, expected_ERR_WRN, ERR_WRN_differ_number = \
                    compare_ERR_WRN_with_base(
                        test_ERR_WRN_path, base_file, ERR_WRN_base_file)
        else:
            logging.warning(f"there is no base file for reference, "
                            f"maybe this is the first run for this case or base file is cleared")
        refer_base_sw_ver = get_xlsx_file_version(base_file)
        case_status = Check_test_result(expected_ERR_WRN, expected_ERR_WRN_differ,
                                        ERR_WRN_sum, ERR_WRN_differ_number,
                                        expected_ERR_WRN_deviation, fail_case)
        logging.info(
            f"Start generate_compass_upload_data,case_QC_id is {case_QC_id}")
        generate_compass_upload_data(ERR_WRN_base_file, sw_ver, feature, case_QC_id,
                                     Squad_Group, HW_Info)
        compass_data_path = get_ERR_WRN_data_from_compass(compass_url)
        compare_with_compass_data(compass_data_path, ERR_WRN_base_file)
        logging.info(
            f"Start ERR_WRN_Differ_compare_with_whitelist_Common")
        sheet_name_new, ERR_WRN_base_file = create_whitelist_sheet(
            ERR_WRN_base_file, Whitelist, confluence_update_date)
        ERR_WRN_Differ_compare_with_whitelist_Common(
            ERR_WRN_base_file, sheet_name_new)
        if refer_base_sw_ver is None:
            comment_text = 'no compare'
        else:
            comment_text = 'compare with ' + refer_base_sw_ver
        add_column_comments(ERR_WRN_base_file, comment_text)
        if server_type == 'remote':
            ssh = init_ssh_client()
            upload_file_by_ssh(ssh, local_dir, test_path_ver, file_name_new)
            remote_log_dir = upload_syslog_by_ssh(
                ssh,
                local_dir,
                test_path_ver,
                ERR_WRN_syslog_path)
            log_web_link = generate_web_link_for_log(test_path_ver)
            df_data_ERR = update_data_in_sheet(
                ERR_WRN_base_file,
                'ERR_WRN_History',
                'Log Path',
                log_web_link)
            compass_id_list = upload_ERR_WRN_to_compass(
                df_data_ERR, refer_base_sw_ver)
            logging.info(
                f"The total lines in all the syslogs is {total_lines_all_file}")
            if total_lines_all_file == 0:
                logging.error(
                    f"upload the abnormal_scenario data to the compass")
                abnormal_scenario = 'Missing_Syslogs'
                upload_special_data_to_compass(
                    sw_ver, testline, log_web_link, abnormal_scenario)
        # df_data = update_data_in_sheet(
        #     ERR_WRN_base_file,
        #     'ERR_WRN_History',
        #     'Log Path',
        #     ERR_WRN_syslog_path)
        # upload_ERR_WRN_to_compass(df_data)
    except Exception as e:
        logging.error(
            f"!!!!!!there is exception {e} when execute Check_ERR_WRN",
            exc_info=True)
    logging.info(f'case_status is {case_status}')
    return ERR_WRN_num, ERR_WRN_differ_number, case_status, \
        ERR_WRN_base_file, ERR_WRN_syslog_path, ignore_time, \
        remote_log_dir, compass_id_list, base_file


def extract_one_compressed_file(input_file, loop_flag):
    folder_path, gz_filename = os.path.split(input_file)
    extracted_filename = os.path.splitext(gz_filename)[0]
    out_file_path = os.path.join(folder_path, extracted_filename)
    file_size = 0
    try:
        file_size = os.path.getsize(input_file)
    except Exception as e:
        logging.warning(
            f"An error occurred while get file size {input_file}: {e}")
    # logging.info(f'input_file is "{input_file}".')
    if file_size != 0:
        if os.path.exists(out_file_path):
            if os.path.isdir(out_file_path) and loop_flag == 0:
                # logging.info(
                #    f'"{out_file_path}" is exist and delete this path')
                for root, dirs, files in os.walk(out_file_path):
                    for dir_name in dirs:
                        os.chmod(os.path.join(root, dir_name), 0o777)
                    for file_name in files:
                        os.chmod(os.path.join(root, file_name), 0o777)
                shutil.rmtree(out_file_path)
                os.makedirs(out_file_path)
            else:
                return out_file_path
        else:
            os.makedirs(out_file_path)
        os.chmod(out_file_path, 0o777)
        # if file_type == 'tgz':
        path = Path(input_file)
        # if input_file.endswith('.tgz'):
        if path.suffix == '.tgz':
            try:
                with tarfile.open(input_file, 'r:*') as file_in:
                    file_in.extractall(out_file_path)
            except Exception as e:
                logging.warning(
                    f"An error occurred while extracting {input_file}: {e}")
        # if file_type == 'gz':
        # elif input_file.endswith('.gz'):
        elif path.suffix == '.gz':
            # file_name = os.path.basename(input_file).replace('.gz', '')
            base_name = os.path.basename(input_file)
            file_name, file_extension = os.path.splitext(base_name)
            if '.tar' not in file_name:
                try:
                    # with gzip.open(input_file, 'rb') as file_in:
                    #    content = file_in.read()
                    #    with open(os.path.join(out_file_path, file_name), 'wb+') as file_out:
                    #        file_out.write(content)
                    # except (OSError, gzip.BadGzipFile) as e:
                    with gzip.open(input_file, 'rb') as gz_file, \
                            open(os.path.join(out_file_path, file_name), 'wb') as out_file:
                        shutil.copyfileobj(gz_file, out_file)
                except Exception as e:
                    logging.warning(
                        f"Error processing .gz file {input_file}: {e}")
            else:
                # logging.info(f"file suffix is {path.suffix}")
                try:
                    with tarfile.open(input_file, "r:gz") as tar:
                        tar.extractall(path=out_file_path)
                except Exception as e:
                    logging.warning(
                        f"Error processing .gz file {input_file}: {e}")

        # elif file_type == 'tar':
        # elif input_file.endswith('.tar'):
        elif path.suffix == '.tar':
            try:
                with tarfile.open(input_file, "r:*") as file_in:
                    file_in.extractall(out_file_path)
            except tarfile.TarError as e:
                logging.warning(
                    f"Error processing .tar file {input_file}: {e}")
        # elif file_type == 'zip':
        # elif input_file.endswith('.zip'):
        elif path.suffix == '.zip':
            try:
                with zipfile.ZipFile(input_file, 'r') as file_in:
                    file_in.extractall(out_file_path)
            except Exception as e:
                logging.warning(f"Error opening .zip file {input_file}: {e}")
        # elif file_type == 'xz':
        # elif input_file.endswith('.xz'):
        elif path.suffix == '.xz':
            # file_name = os.path.basename(input_file).replace('.xz', '')
            base_name = os.path.basename(input_file)
            file_name, file_extension = os.path.splitext(base_name)
            try:
                with lzma.open(input_file, 'rb') as file_in:
                    content = file_in.read()
                    with open(os.path.join(out_file_path, file_name), 'wb+') as file_out:
                        file_out.write(content)
            except Exception as e:
                logging.warning(f"Error opening .xz file {input_file}: {e}")

        # elif path.suffix == '.tar.gz':
        #    logging.info(f"file suffix is {path.suffix}")
        #    with tarfile.open(input_file, "r:gz") as tar:
        #        tar.extractall(path=out_file_path)
        else:
            logging.info('uncompressed file end.')
    else:
        logging.info(f'"{input_file}" is empty.')
    for root, dirs, files in os.walk(out_file_path):
        for dir_name in dirs:
            if os.path.exists(os.path.join(root, dir_name)):
                os.chmod(os.path.join(root, dir_name), 0o777)
        for file_name in files:
            if os.path.exists(os.path.join(root, file_name)):
                os.chmod(os.path.join(root, file_name), 0o777)
    return out_file_path


def extract_compressed_file(log_path, log_root_path, loop_flag):
    files_list = []
    if os.path.isdir(log_path):
        # logging.info(f'log_path is "{log_path}".')
        files_list = list_compressed_files_in_directory(log_path)
        # logging.info(f'files_list is "{files_list}".')
    elif os.path.isfile(log_path):
        folder_path, gz_filename = os.path.split(log_path)
        suffix = os.path.splitext(gz_filename)[-1]
        # logging.info(f'suffix is "{suffix}".')
        if suffix not in compressed_list:
            # logging.info(f'There is no compressed file in "{log_path}".')
            return
        else:
            files_list.append(log_path)
    else:
        # logging.warning(f"{log_path} is not found, ERR_WRN will not be analyzed ")
        return
    decompression_log = None
    if len(files_list) != 0:
        for file in files_list:
            folder_path, gz_filename = os.path.split(file)
            suffix = Path(file).suffix
            # if input_file.endswith('.tgz'):
            # suffix = os.path.splitext(gz_filename)[-1]
            if suffix in compressed_list:
                decompression_file_path = extract_one_compressed_file(
                    file, loop_flag)
                # if loop_flag == 0 or decompression_log is None:
                decompression_log = decompression_file_path
                extract_compressed_file(
                    decompression_log, log_root_path, loop_flag)
                if loop_flag == 0:
                    log_root_path = decompression_file_path
                loop_flag += 1
            # else:
            #    logging.error(
            #        f'suffix of file "{file}" is "{suffix}",can not be decompressed')
    # else:"
    #   logging.info(f'There is no compressed file in "{log_path}".')
    # if decompression_log is None:
    #    decompression_log = log_path"
    return log_root_path, decompression_log


def list_compressed_files_in_directory(log_path):
    files_list = []
    if os.path.exists(log_path) and os.path.isdir(log_path):
        for root, dirs, files in os.walk(log_path):
            for file in files:
                for suffix in compressed_list:
                    if file.endswith(suffix):
                        files_list.append(os.path.join(root, file))
    return files_list


def manage_ERR_WRN_analysis_path(
        ERR_WRN_path, testline, sw_ver, case_name='empty_case_name'):
    test_ERR_WRN_path = os.path.join(ERR_WRN_path, testline, case_name, sw_ver)
    case_ERR_WRN_path = os.path.join(ERR_WRN_path, testline, case_name)
    TL_ERR_WRN_path = os.path.join(ERR_WRN_path, testline)
    # os.makedirs(test_ERR_WRN_path, exist_ok=True)
    return case_ERR_WRN_path, test_ERR_WRN_path, TL_ERR_WRN_path


def get_refer_ERR_WRN_base(case_ERR_WRN_path, sw_ver, ignore_file=None):
    Base_ERR_WRN_path = os.path.join(case_ERR_WRN_path, sw_ver)
    logging.info(f"Base_ERR_WRN_path is {Base_ERR_WRN_path}")
    key_string = 'ERR_WRN_Analysis'
    basefile = None
    key_info = None
    if 'SBTS' in sw_ver:
        if 'ENB' in sw_ver:
            logging.info(f"5G SW work in the test line")
            key_info = 'ENB'
        elif 'FSM3' in sw_ver:
            key_info = 'FSM3'
            logging.info(f"FSM3 SW work in the test line")
        else:
            logging.error(f"SW version not identify")
            return basefile
    else:
        logging.error(f"SW version not identify")
        return basefile
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
                    if 'SBTS' in name and key_info in name:
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
            # logging.info(f"sw_ver_release is {sw_ver_release}")
            for directories in directories_list:
                if sw_ver_release not in directories:
                    # logging.info(f"directories is {directories}")
                    index = directories_list.index(directories)
                    directories_list.pop(index)
                    # logging.info(f"directories_list is {directories_list}")
                if len(directories_list) == 0:
                    break
            # logging.info(f"directories_list is {directories_list}")
            for directories in directories_list:
                build_name = directories.split('_', 2)[2]
                build_name = int(build_name.replace('_', ''))
                build_dic[build_name] = directories
            # logging.info(f"build_dic is {build_dic}")
            max_key = max(build_dic, key=lambda k: build_dic[k])
            basefile_path = os.path.join(case_ERR_WRN_path, build_dic[max_key])
            basefile = get_first_base_file(
                basefile_path, key_string, ignore_file)
            # logging.info(f"basefile is {basefile}")
        elif os.listdir(Base_ERR_WRN_path):
            basefile = get_first_base_file(
                Base_ERR_WRN_path, key_string, ignore_file)
        else:
            logging.warning(
                f"There is no base file directory for this case {Base_ERR_WRN_path}")
            return basefile
    else:
        logging.warning(
            f"There is no base file directory for this case {Base_ERR_WRN_path}")
        return basefile
    return basefile


def get_first_base_file(Base_ERR_WRN_path, key_string, ignore_file):
    # excel_files = glob.glob(os.path.join(Base_ERR_WRN_path, "*.xlsx"))
    excel_files = []
    for root, dirs, files in os.walk(Base_ERR_WRN_path):
        for file in files:
            if file.endswith('.xlsx'):
                excel_files.append(os.path.join(root, file))
    filtered_files = [
        file for file in excel_files if key_string in os.path.basename(file)]
    if ignore_file is not None and os.path.exists(
            ignore_file) and ignore_file in filtered_files:
        filtered_files.remove(ignore_file)
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
            for root, dirs, files in os.walk(
                    case_ERR_WRN_log_path, topdown=False):
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
    ignore_time = False
    for partitions in disk_partitions:
        if partitions.device == filesSystem:
            dev_mountpoint = partitions.mountpoint
        else:
            dev_mountpoint = None
    if dev_mountpoint is None:
        logging.warning(f"dev_mountpoint is not found when check_disk_state")
        return ignore_time
    usage = psutil.disk_usage(dev_mountpoint)
    used_space_ratio = usage.percent / 100
    logging.info(f"used_space_ratio is {used_space_ratio}")
    if used_space_ratio > max_used_space_ratio:
        ignore_time = True
    return ignore_time


def generate_compass_upload_data(ERR_WRN_analysis, sw_ver, feature, Contributor,
                                 Squad_Group, HW_Info):
    global Process
    install_and_import_package('pandas')
    import pandas as pd
    install_and_import_package('openpyxl')
    import openpyxl
    try:
        workbook = openpyxl.load_workbook(ERR_WRN_analysis)
        sheet_names = workbook.sheetnames
    except Exception as e:
        logging.error(
            f"Failed:there is exception {e}, can't generate compass data failed")
        return False
    sw_ver_release = sw_ver.split('_')[0]
    Analysis_Summary, Attached_PR, Additional_Info, Description = None, None, None, None
    ERR_WRN_Compass_status = 'Open'
    Compass_Link = None
    # logging.info(f"sw_ver_release is {sw_ver_release}")
    if 'ERR_WRN_Differ' in sheet_names:
        df_base_compass = pd.DataFrame(columns=Compass_column_names)
        df_differ = pd.read_excel(
            ERR_WRN_analysis,
            sheet_name='ERR_WRN_Differ')
        if len(df_differ) != 0:
            condition = (df_differ['Status'] == 'New')
            df_differ_new = df_differ[condition]
            for row_index, row in df_differ_new.iterrows():
                # for new_base_row in range(0, df_new_base_data_row_count):
                new_base_row = df_differ_new.loc[row_index]
                Component = new_base_row['Component']
                Process = new_base_row['Process']
                Log_Detail = new_base_row['Description']
                Key_Signature = new_base_row['Description']
                Severity = new_base_row['Log_Level']
                now = datetime.now()
                Created_datatime = now.strftime('%Y-%m-%d %H:%M:%S')
                data = [
                    Component,
                    Process,
                    Log_Detail,
                    Severity,
                    feature,
                    sw_ver_release,
                    sw_ver,
                    HW_Info,
                    Contributor,
                    Squad_Group,
                    ERR_WRN_Compass_status,
                    Analysis_Summary,
                    Attached_PR,
                    Key_Signature,
                    Description,
                    Additional_Info,
                    Created_datatime,
                    Compass_Link]
                df_base_compass.loc[len(df_base_compass.index)] = data
            workbook = openpyxl.load_workbook(ERR_WRN_analysis)
            if 'ERR_WRN_History' in workbook.sheetnames:
                workbook.remove(workbook['ERR_WRN_History'])
                workbook.save(ERR_WRN_analysis)
                workbook.close()
            with pd.ExcelWriter(ERR_WRN_analysis, engine='openpyxl', mode='a') as writer:
                df_base_compass.to_excel(
                    writer, sheet_name='ERR_WRN_History', index=False)
            yellow_fill = openpyxl.styles.PatternFill(
                start_color='FFFF00', end_color='FFFF00', fill_type='solid')
            workbook = openpyxl.load_workbook(ERR_WRN_analysis)
            sheet = workbook['ERR_WRN_History']
            for cell in sheet[1]:
                if cell.value in Compass_column_names_mandatory:
                    cell.fill = yellow_fill
            workbook.save(ERR_WRN_analysis)
            workbook.close()
        else:
            logging.warning(
                f"ERR_WRN_Differ data is empty, generate compass data failed")


def compare_with_compass_data(
        compass_data_path, ERR_WRN_data, filter_list=None):
    global match_ratio
    install_and_import_package('pandas')
    import pandas as pd
    install_and_import_package('openpyxl')
    import openpyxl
    row_index_list = {}
    logging.warning(
        f"ERR_WRN_data is {ERR_WRN_data}")
    if compass_data_path is None:
        logging.error(
            f"compass err wrn data is None, can't compare with compass data")
        return False
    try:
        workbook = openpyxl.load_workbook(compass_data_path)
        sheet_names_compass = workbook.sheetnames
    except Exception as e:
        logging.error(
            f"Failed:there is exception {e}, when load compass_data_path {compass_data_path}")
        return False
    try:
        workbook = openpyxl.load_workbook(ERR_WRN_data)
        sheet_names_analysis = workbook.sheetnames
    except Exception as e:
        logging.error(f"Failed:there is exception {e}, when load ERR_WRN_data {ERR_WRN_data}")
        return False
    if 'ERR_WRN_History' in sheet_names_analysis:
        df_differ = pd.read_excel(
            ERR_WRN_data,
            sheet_name='ERR_WRN_History')
        # df_differ = df_differ[df_differ['Status'] == 'New']
    else:
        logging.warning(
            f"ERR_WRN_History not exist, can't compare with compass data")
        return False
    if 'sheet1' in sheet_names_compass:
        df_compass = pd.read_excel(
            compass_data_path,
            sheet_name='sheet1')
    else:
        logging.warning(
            f"ERR_WRN_History in compass excel not exist, can't compare with compass data")
        return False
    if len(df_differ) > 0:
        for row_index, row in df_differ.iterrows():
            csv_row = df_differ.loc[row_index]
            ERR_WRN_content = csv_row['Log Detail']
            for row_index_c, row_c in df_compass.iterrows():
                csv_row_c = df_compass.loc[row_index_c]
                ERR_WRN_compass = csv_row_c['Log Detail']
                ERR_WRN_compass_link = csv_row_c['Compass Link']
                line_count = ERR_WRN_compass.count('\n') + 1
                if line_count > 1:
                    ERR_WRN_list = ERR_WRN_compass.split('\n')
                    for ERR_WRN in ERR_WRN_list:
                        content_compass = get_ERR_WRN_content_from_compass_data(
                            ERR_WRN, filter_list)
                        if content_compass is not None:
                            matcher = SequenceMatcher(
                                None, ERR_WRN_content, content_compass)
                            match_ratio = matcher.ratio()
                            if match_ratio >= expected_match_ratio:
                                row_index_list[(row_index + 2)
                                               ] = ERR_WRN_compass_link
                                break
                else:
                    content_compass = get_ERR_WRN_content_from_compass_data(
                        ERR_WRN_compass, filter_list)
                    if content_compass is not None:
                        matcher = SequenceMatcher(
                            None, ERR_WRN_content, content_compass)
                        match_ratio = matcher.ratio()
                        if match_ratio >= expected_match_ratio:
                            row_index_list[(row_index + 2)
                                           ] = ERR_WRN_compass_link
    else:
        logging.warning(
            f"There is no new ERR_WRN print, can't compare with compass data")
        return False
    if len(row_index_list) != 0:
        green_fill = openpyxl.styles.PatternFill(
            start_color='00FF00', end_color='00FF00', fill_type='solid')
        workbook = openpyxl.load_workbook(ERR_WRN_data)
        sheet = workbook['ERR_WRN_History']
        # rows = sheet.iter_rows(values_only=False)
        # row_numbers = [row[0].row for row in rows]
        # logging.info(
        #    f"row_numbers is {row_numbers}")
        column_name = 'Compass Link'
        for col in range(1, sheet.max_column + 1):
            cell_value = sheet.cell(row=1, column=col).value
            if cell_value == column_name:
                column_index = col
                # logging.info(f"column_name column_index is '{column_index}'")
                break
        else:
            logging.info(f"column_name'{column_name}' is not found")
            return False
        for row_index in row_index_list.keys():
            for cell in sheet[row_index]:
                # logging.info(
                # f"row {row_index} have the duplicated data compared with
                # compass")
                cell.fill = green_fill
            sheet.cell(
                row=row_index,
                column=column_index,
                value=row_index_list[row_index])
        workbook.save(ERR_WRN_data)
        workbook.close()
    return True


def get_ERR_WRN_content_from_compass_data(ERR_WRN_content, filter_list):
    if filter_list is None or len(filter_list) == 0:
        filter_list = filter_info_list
    content = None
    for filter_info in filter_list:
        filter_info = str(filter_info)
        filter_info_pattern = re.compile(filter_info, re.I)
        # logging.info(
        #    f"ERR_WRN_content is {ERR_WRN_content}")
        matches = re.findall(filter_info_pattern, ERR_WRN_content)
        if matches:
            if len(ERR_WRN_content.split(filter_info)) > 1:
                content_tmp = ERR_WRN_content.split(filter_info, 1)[1]
                content = filter_info + content_tmp
                break
    return content


def get_ERR_WRN_data_from_compass(compass_url, data_gap_days=0, username='erta',
                                  password='R&D_VRF_HAZ3',
                                  save_path='/home/ute/compass_ERR_WRN/'):
    global res, response_data
    install_and_import_package('requests')
    import requests
    install_and_import_package('urllib')
    import urllib
    compass_file_dic = {}
    if os.path.exists(save_path):
        if len(os.listdir(save_path)) > 0:
            for root, dirs, files in os.walk(save_path):
                for file_name in files:
                    if file_name.endswith(
                            '.xlsx') and 'compass_err_wrn_data_' in file_name:
                        file_path = os.path.join(root, file_name)
                        file_stats = os.stat(file_path)
                        modification_time = file_stats.st_mtime
                        compass_file_dic[modification_time] = file_path
            if len(compass_file_dic) > 0:
                compass_file_dic = {key: compass_file_dic[key]
                                    for key in sorted(compass_file_dic.keys())}
                min_key = max(
                    compass_file_dic,
                    key=lambda k: compass_file_dic[k])
                the_newest_file_path = compass_file_dic[min_key]
                creation_time = datetime.fromtimestamp(
                    os.path.getctime(the_newest_file_path))
                logging.info(f"debug {datetime.now() - creation_time}")
                if datetime.now() - creation_time <= timedelta(days=data_gap_days):
                    del compass_file_dic[min_key]
                    for value in compass_file_dic.values():
                        os.remove(value)
                    logging.info(
                        f"the newest err_wrn referred file is "
                        f"{the_newest_file_path} and don't need to download "
                        f"the new err wrn data")
                    return the_newest_file_path
                else:
                    logging.info(f"the newest err_wrn file "
                                 f"{the_newest_file_path} time exceeds {data_gap_days} days"
                                 f"and will be deleted and download the new err wrn data")
                shutil.rmtree(save_path)
                os.makedirs(save_path, mode=0o777, exist_ok=True)
        else:
            logging.info(
                f"There is no referred data and need to be downloaded")
    else:
        logging.info(f"There is no path {save_path}")
        os.makedirs(save_path, mode=0o777, exist_ok=True)
    session = requests.session()
    # login_url = compass_url + 'common/login_handle/'
    login_url = 'http://compass.dyn.nesc.nokia.net:8080/common/login_handle/'
    try:
        res = session.post(
            login_url,
            data={
                'username': username,
                'password': password},
            timeout=60)
    except Exception as e:
        logging.error(f"there is exception {e} when login compass")
        return None
    response_data = res.text
    # logging.info(f"the res of login compass is {response_data}")
    logging.info(f"the res of login compass is {res.status_code}")
    if res.status_code == 200:
        try:
            session.headers['cookie'] = res.headers.get(
                'Set-Cookie').split(';', 1)[0]
        except Exception as e:
            logging.error(f"there is exception {e} when get cookies")
            return None
    else:
        logging.error(f"login compass failed")
        return None
    logging.info(
        f"login session is {session} and download err_wrn data from compass")
    err_wrn_excel_url = compass_url + 'infoshare/err_wrn_data/export/'
    current_time = datetime.now()
    timestamp = current_time.strftime('%Y%m%d%H%M%S')
    file_name = 'compass_err_wrn_data_' + timestamp + '.xlsx'
    compass_err_wrn_file = save_path + file_name
    export_res = session.post(err_wrn_excel_url, data={'filters': '{}'}, verify=False)
    try:
        with open(compass_err_wrn_file, 'wb') as file:
            for chunk in export_res.iter_content(chunk_size=8192):
                if chunk:
                    file.write(chunk)
    except Exception as e:
        logging.error(
            f"there is exception {e} when download err wrn data from compass")
        return None
    logout_url = compass_url + 'common/logout/'
    res_logout = session.post(logout_url)
    logging.info(f"res_logout_compass is {res_logout}")
    if os.path.exists(compass_err_wrn_file):
        return compass_err_wrn_file
    else:
        return None


def get_expected_files_from_snapshot_by_RegEx(snapshot_files, filter_info):
    install_and_import_package('regex')
    import regex as reg
    files_list = []
    filter_info = str(filter_info)
    filter_regex = reg.compile(filter_info, reg.I)
    for root, dirs, files in os.walk(snapshot_files):
        for file in files:
            file_name_full = os.path.join(root, file)
            if filter_regex.findall(file_name_full):
                files_list.append(file_name_full)
                # logging.info(f"file is {file_name_full}")
    logging.info(f"there is {len(files_list)} rf log file")
    return files_list


def analyze_one_RF_log(rflog_file, df_rflog, serial_number_list,
                       log_type, log_filter_info, log_row_number):
    install_and_import_package('pandas')
    import pandas as pd
    install_and_import_package('regex')
    import regex as reg
    ERR_WRN_num_per_log = 0
    ERR_WRN_num_data = 0
    found = False
    df_rflog_new = pd.DataFrame(columns=RF_column_names)
    filter_regx = reg.compile(log_filter_info, reg.I)
    for sn in serial_number_list:
        sn_regx = reg.compile(sn, reg.I)
        matches = sn_regx.findall(rflog_file)
        # if sn in rflog_file:
        if matches:
            serial_number = sn
            break
        else:
            serial_number = None
    logging.info(
        f"rf_log_file is {rflog_file} and serial_number is {serial_number}")
    # try:
    with open(rflog_file, 'r+', errors='ignore') as file:
        lines = file.readlines()
        for line in lines:
            line_list = line.split(' ')
            if len(line_list) > 3:
                log_row_number += 1
                matches = filter_regx.findall(line)
                if matches:
                    for key, log_level_0 in log_level_dic.items():
                        # log_level_pattern = reg.compile(log_level, reg.I)
                        # log_level = log_level_pattern.findall(line)
                        if log_level_0 in line:
                            # log_level_list = list(set(log_level))
                            # log_level = log_level_list[0]
                            log_level = log_level_0
                            # logging.info(f"log_level {log_level}")
                            break
                    line_no = line_list[0]
                    time = line_list[2]
                    str_component = line.split(log_level, 1)[1]
                    component = str_component.split('/', 1)[0]
                    process_name = line_list[1]
                    short_description = log_level + str_component
                    log_level = log_level.replace('/', '')
                    data = [serial_number, log_type, rflog_file, line_no, time, component,
                            process_name, log_level, line, short_description]
                    found = True
                    # logging.info(f"ERR_WRN_num_per_log is {ERR_WRN_num_per_log} and "
                    #             f"ERR_WRN_num_data is {ERR_WRN_num_data}")
                    if ERR_WRN_num_per_log < expected_data_line:
                        df_rflog.loc[len(df_rflog.index)] = data
                    elif ERR_WRN_num_per_log >= expected_data_line >= ERR_WRN_num_data:
                        df_rflog_new.loc[len(df_rflog_new.index)] = data
                        ERR_WRN_num_data += 1
                    elif ERR_WRN_num_per_log >= expected_data_line and \
                            ERR_WRN_num_data > expected_data_line:
                        df_rflog_new.loc[len(df_rflog_new.index)] = data
                        ERR_WRN_num_data = 0
                        df_rflog = pd.concat(
                            [df_rflog, df_rflog_new], ignore_index=True)
                        df_rflog_new = pd.DataFrame(columns=RF_column_names)
                    found = True
                    ERR_WRN_num_per_log += 1
                # if not found:
                #    logging.info(
                #        f'The term "{log_filter_info}" was not found in the file "{rflog_file}".')
    # except Exception as e:
    #    logging.error(f"An error occurred while open {rflog_file}: {e}")
    logging.info(
        f'Check ERR_WRN print in "{rflog_file}"')
    logging.info(f"ERR_WRN_num in rf_log_file is {ERR_WRN_num_per_log}")
    return log_row_number, ERR_WRN_num_per_log, df_rflog


def manage_RF_ERR_WRN_excel(
        RF_ERR_WRN_base_file, ERR_WRN_path, testline, sw_ver, case_name):
    current_time = datetime.now()
    timestamp = current_time.strftime('%Y%m%d%H%M%S')
    base_file_name = 'ERR_WRN_Analysis'
    if RF_ERR_WRN_base_file is None:
        case_RF_ERR_WRN_path, test_RF_ERR_WRN_path, TL_ERR_WRN_path = \
            manage_ERR_WRN_analysis_path(
                ERR_WRN_path, testline, sw_ver, case_name)
        os.makedirs(test_RF_ERR_WRN_path, exist_ok=True)
        RF_ERR_WRN_base_file = creat_excel_file(
            test_RF_ERR_WRN_path, base_file_name, timestamp)
        logging.info(
            f"new created RF_ERR_WRN_base_file is {RF_ERR_WRN_base_file}")
    elif not os.path.exists(RF_ERR_WRN_base_file):
        test_RF_ERR_WRN_path = os.path.dirname(RF_ERR_WRN_base_file)
        os.makedirs(test_RF_ERR_WRN_path, exist_ok=True)
        RF_ERR_WRN_base_file = creat_excel_file(
            test_RF_ERR_WRN_path, base_file_name, timestamp)
        case_RF_ERR_WRN_path = os.path.dirname(test_RF_ERR_WRN_path)
        logging.info(
            f"new created RF_ERR_WRN_base_file is {RF_ERR_WRN_base_file}")
    else:
        test_RF_ERR_WRN_path = os.path.dirname(RF_ERR_WRN_base_file)
        case_RF_ERR_WRN_path = os.path.dirname(test_RF_ERR_WRN_path)
        logging.info(
            f"there is existed RF_ERR_WRN_base_file {RF_ERR_WRN_base_file}")
    logging.info(f"test_RF_ERR_WRN_path is {test_RF_ERR_WRN_path}")
    logging.info(f"case_RF_ERR_WRN_path is {case_RF_ERR_WRN_path}")
    return RF_ERR_WRN_base_file, case_RF_ERR_WRN_path, test_RF_ERR_WRN_path


def Check_ERR_WRN_From_All_RF_LOG(snapshot_zip_path, serial_number_list,
                                  log_name_filter_regx=filter_info,
                                  log_filter=log_filter_regx):
    install_and_import_package('pandas')
    import pandas as pd
    install_and_import_package('openpyxl')
    import openpyxl
    install_and_import_package('regex')
    import regex as reg
    snapshot_file_path = decompress_snapshot(snapshot_zip_path)
    # snapshot_file_path = '/home/ute/syscom_trace/2025-02-20_06:50:22.759310/MRBTS-906_Snapshot_20250220_064519'
    sn_list = None
    for sn in serial_number_list:
        if sn_list is None:
            sn_list = sn
        else:
            sn_list = sn_list + '|' + sn
    filter_part = '^(?=.*(' + sn_list + '))'
    log_name_filter_regx = filter_part + log_name_filter_regx
    logging.info(
        f'log_name_filter_regx is "{log_name_filter_regx}"".')
    t0 = datetime.now()
    file_list = get_expected_files_from_snapshot_by_RegEx(
        snapshot_file_path, log_name_filter_regx)
    duration = datetime.now() - t0
    logging.info(
        f'there is "{len(file_list)}" log file is found and time cost is {duration}')
    ERR_WRN_num = 0
    df_rf_log = pd.DataFrame(columns=RF_column_names)
    log_row_number = 0
    log_type = 'runtime'
    for log_file in file_list:
        t0 = datetime.now()
        log_row_number, ERR_WRN_num_per_log, df_rflog = analyze_one_RF_log(log_file, df_rf_log,
                                                                           serial_number_list, log_type, log_filter,
                                                                           log_row_number)
        ERR_WRN_num += ERR_WRN_num_per_log
        duration = datetime.now() - t0
        logging.info(
            f'Check RF_ERR_WRN time spent is "{duration}"')
    logging.info(
        f'the log row number in all RF Logs is "{log_row_number}"')
    shutil.rmtree(snapshot_file_path)
    return df_rf_log, ERR_WRN_num


def generate_one_RF_ERR_WRN(df_rf_log, df_RF_LOG_base):
    drop_row_list = []
    match_number = 0
    log_name_list = []
    ERR_WRN_basic = df_rf_log.loc[0]['Short_description']
    for row_index, row in df_rf_log.iterrows():
        # for row in df_data.itertuples():
        #    row_index = row.Index
        csv_row = df_rf_log.loc[row_index]
        ERR_WRN_content = csv_row['Short_description']
        matcher = SequenceMatcher(
            None, ERR_WRN_content, ERR_WRN_basic)
        match_ratio = matcher.ratio()
        if match_ratio >= expected_match_ratio:
            match_number += 1
            if df_rf_log.loc[0]['Log_Name'] not in log_name_list:
                log_name_list.append(df_rf_log.loc[0]['Log_Name'])
            drop_row_list.append(row_index)
    data0 = [df_rf_log.loc[0]['SN'],
             df_rf_log.loc[0]['Log_Type'],
             df_rf_log.loc[0]['Component'],
             df_rf_log.loc[0]['Process'],
             df_rf_log.loc[0]['Log_Level'],
             df_rf_log.loc[0]['Short_description'],
             match_number,
             log_name_list]
    df_RF_LOG_base_filter = df_RF_LOG_base[(df_RF_LOG_base['Component'] == df_rf_log.loc[0]['Component']) &
                                           (df_RF_LOG_base['Log_Level'] == df_rf_log.loc[0]['Log_Level']) &
                                           (df_RF_LOG_base['Process'] == df_rf_log.loc[0]['Process']) &
                                           (df_RF_LOG_base['SN'] == df_rf_log.loc[0]['SN']) &
                                           (df_RF_LOG_base['Log_Type'] == df_rf_log.loc[0]['Log_Type'])]
    if len(df_RF_LOG_base_filter) > 0:
        match_ratio = 0
        for row_index, row in df_RF_LOG_base_filter.iterrows():
            csv_row = df_RF_LOG_base_filter.loc[row_index]
            ERR_WRN_content = csv_row['Description']
            matcher = SequenceMatcher(
                None, ERR_WRN_content, ERR_WRN_basic)
            match_ratio = matcher.ratio()
            if match_ratio >= expected_match_ratio:
                match_number = csv_row['Sum_Total'] + match_number
                df_RF_LOG_base.loc[row_index, 'Sum_Total'] = match_number
                break
        if match_ratio < expected_match_ratio:
            df_RF_LOG_base.loc[len(df_RF_LOG_base.index)] = data0
    else:
        df_RF_LOG_base.loc[len(df_RF_LOG_base.index)] = data0
    if len(drop_row_list) != 0:
        for row_index in drop_row_list:
            df_rf_log = df_rf_log.drop(row_index)
        df_rf_log = df_rf_log.reset_index(drop=True)
    return df_rf_log, df_RF_LOG_base


def generate_RF_ERR_WRN(RF_ERR_WRN_base_file, df_rf_log_data):
    install_and_import_package('pandas')
    import pandas as pd
    install_and_import_package('openpyxl')
    import openpyxl
    t0 = datetime.now()
    input_csv_line_sum = len(df_rf_log_data)
    df_RF_LOG_base = pd.DataFrame(columns=RF_Base_column_names)
    df_RF_LOG_group_dict = df_rf_log_data.groupby(
        by=['SN', 'Log_Type', 'Component', 'Process', 'Log_Level'])
    logging.info(
        f'start generate_RF_ERR_WRN')
    for name, df_data_group in df_RF_LOG_group_dict:
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
                    df_block, df_base = generate_one_RF_ERR_WRN(
                        df_block, df_RF_LOG_base)
                    if len(df_block) == 0:
                        break
    ERR_WRN_SUM = df_RF_LOG_base['Sum_Total'].sum()
    ERR_WRN_Number = len(df_RF_LOG_base)
    logging.info(
        f'RF ERR_WRN_Number "{ERR_WRN_Number}".')
    workbook = openpyxl.load_workbook(RF_ERR_WRN_base_file)
    sheet_names = workbook.sheetnames
    for sheet_name in sheet_names:
        if len(workbook[sheet_name]._cells) == 0:
            del workbook[sheet_name]
    if 'RF_ERR_WRN' in workbook.sheetnames:
        workbook.remove(workbook['RF_ERR_WRN'])
        workbook.save(RF_ERR_WRN_base_file)
        workbook.close()
    with pd.ExcelWriter(RF_ERR_WRN_base_file, engine='openpyxl', mode='a') as writer:
        df_RF_LOG_base.to_excel(writer, sheet_name='RF_ERR_WRN', index=False)
    duration = datetime.now() - t0
    # logging.info(f'generate_ERR_WRN_new_base "{log_dir}" time spent is "{duration}".')
    logging.info(
        f'generate_ERR_WRN_new_base time spent is "{duration}".')
    return RF_ERR_WRN_base_file, ERR_WRN_Number, ERR_WRN_SUM


def check_RF_ERR_WRN_Differ_with_base(base_file, new_base):
    t0 = datetime.now()
    install_and_import_package('pandas')
    import pandas as pd
    install_and_import_package('openpyxl')
    import openpyxl
    ERR_WRN_diff_csv_line = 0
    expected_ERR_WRN_Number = 0
    df_rf_log_differ = pd.DataFrame(columns=RF_Differ_column_names)
    base_file_exist = os.path.exists(base_file)
    new_base_exist = os.path.exists(new_base)
    if base_file_exist:
        workbook_RF = openpyxl.load_workbook(base_file)
        logging.info(
            f"sheetnames is {workbook_RF.sheetnames}")
        sheet_name_RF = 'RF_ERR_WRN'
        if sheet_name_RF in workbook_RF.sheetnames:
            df_base_1 = pd.read_excel(base_file, sheet_name='RF_ERR_WRN')
            df_base = df_base_1
        else:
            logging.warning(
                f"There is no RF ERR_WRN referred Base in excel {base_file} "
                f"and will not analyze if there is new additional ERR_WRN")
            return new_base, expected_ERR_WRN_Number, ERR_WRN_diff_csv_line
        expected_ERR_WRN_SUM = df_base_1['Sum_Total'].sum()
        expected_ERR_WRN_Number = len(df_base)
        logging.info(
            f"RF expected_ERR_WRN_Number is {expected_ERR_WRN_Number}")
        df_base_data = df_base.loc[:, RF_Base_column_names]
        base_file_line_sum = len(df_base_data)
    else:
        logging.warning(f"{base_file} is not found, please check?")

        # return ERR_WRN_diff_csv, ERR_WRN_diff_csv_line
        return new_base, expected_ERR_WRN_Number, ERR_WRN_diff_csv_line
    if new_base_exist:
        workbook = openpyxl.load_workbook(new_base)
        if 'RF_ERR_WRN' in workbook.sheetnames:
            df_new_base = pd.read_excel(new_base, sheet_name='RF_ERR_WRN')
            if len(df_new_base) == 0:
                logging.warning(
                    f"new ERR_WRN_Base is empty in excel {new_base}, please check?")
        else:
            logging.warning(
                f"There is no new ERR_WRN_Base in excel {new_base} "
                f"and will not analyze if there is new additional ERR_WRN")
            return new_base, expected_ERR_WRN_Number, ERR_WRN_diff_csv_line
        df_new_base_data = df_new_base.loc[:, RF_Base_column_names]
        new_base_line_sum = len(df_base_data)
    else:
        # raise Exception(f"{new_base} is not found, please check?")
        logging.warning(f"{new_base} is not found, please check?")
        # return ERR_WRN_diff_csv, ERR_WRN_diff_csv_line
        return new_base, expected_ERR_WRN_SUM, ERR_WRN_diff_csv_line
    if base_file_line_sum >= 1 and new_base_line_sum >= 1:
        for row_index, row in df_new_base_data.iterrows():
            # for new_base_row in range(0, df_new_base_data_row_count):
            new_base_row = df_new_base_data.loc[row_index]
            serial_number = new_base_row['SN']
            log_type = new_base_row['Log_Type']
            component = new_base_row['Component']
            process_name = new_base_row['Process']
            log_level = new_base_row['Log_Level']
            Sum_Total = new_base_row['Sum_Total']
            new_base_ERR_WRN_content = new_base_row['Description']
            log_name = new_base_row['Log_Name']
            data = [serial_number,
                    log_type,
                    component,
                    process_name,
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
                # logging.info(f"There is different ERR OR WRN in new base ERR_WRN file {new_base}, please check")
                df_rf_log_differ.loc[len(df_rf_log_differ.index)] = data
                logging.error(
                    f"!!!!!!!!!!!!!!!!! there is new RF error: {serial_number}_{new_base_ERR_WRN_content}")
                ERR_WRN_diff_csv_line += 1
        if ERR_WRN_diff_csv_line > 0:
            logging.info(f"There is new ERR OR WRN in this test,"
                         f" the diff have {ERR_WRN_diff_csv_line} please check")
        else:
            logging.info(
                f"Congratulations! There is no different ERR OR WRN comparing with the ERR_WRN base file")
        # logging.info("ERR_WRN_diff_csv_line is :{}".format(ERR_WRN_diff_csv_line))
        if len(df_base_data) > 0:
            for row_index, row in df_base_data.iterrows():
                new_base_row = df_base_data.loc[row_index]
                serial_number = new_base_row['SN']
                log_type = new_base_row['Log_Type']
                component = new_base_row['Component']
                process_name = new_base_row['Process']
                log_level = new_base_row['Log_Level']
                Sum_Total = new_base_row['Sum_Total']
                new_base_ERR_WRN_content = new_base_row['Description']
                log_name = new_base_row['Log_Name']
                data = [serial_number,
                        log_type,
                        component,
                        process_name,
                        log_level,
                        new_base_ERR_WRN_content,
                        Sum_Total,
                        'Miss',
                        log_name]
                df_rf_log_differ.loc[len(df_rf_log_differ.index)] = data
        duration = datetime.now() - t0
        logging.info(
            f'There is {len(df_base_data)} ERR_WRN not found in this test')
        logging.info(
            f'compare_ERR_WRN_with_base time spent is "{duration}".')
    with pd.ExcelWriter(new_base, engine='openpyxl', mode='a') as writer:
        df_rf_log_differ.to_excel(
            writer, sheet_name='RF_ERR_WRN_Differ', index=False)
    return new_base, expected_ERR_WRN_SUM, ERR_WRN_diff_csv_line


def decompress_snapshot(log_path):
    t0 = datetime.now()
    loop_flag = 0
    log_root_path = None
    log_root_path, decompression_log = extract_compressed_file(
        log_path, log_root_path, loop_flag)
    logging.info(
        f"log_root_path is {log_root_path}, decompression_log is {decompression_log}")
    if decompression_log is None:
        decompression_log = log_path
    duration = datetime.now() - t0
    logging.info(
        f'decompress_snapshot time spent is "{duration}".')
    return decompression_log


def analyze_RF_LOG_ERR_WRN_From_Snapshot(snapshot_zip_path, ERR_WRN_path, ERR_WRN_analysis_file, sw_ver,
                                         user_base_file, ERR_WRN_syslog_path,
                                         serial_number_list, testline,
                                         check_diff=True, case_name='empty_case_name', fail_case=False,
                                         expected_ERR_WRN_differ=0, expected_ERR_WRN_deviation=0.2,
                                         keep_log_number=2, filesSystem='/dev/vda2', max_used_space_ratio=0.9):
    logging.info("Start Analyze_RF_LOG_ERR_WRN_From_Snapshot")
    RF_ERR_WRN_differ_number = 0
    expected_RF_ERR_WRN = 0
    RF_case_status = 'Fail'
    RF_ERR_WRN_number = 0
    try:
        current_time = datetime.now()
        timestamp = current_time.strftime('%Y%m%d%H%M%S')
        ignore_time = check_disk_state(filesSystem, max_used_space_ratio)
        if ignore_time:
            RF_case_status = 'Pass'
            logging.warning(
                "There is no enough disk space, will not execute Analyze_RF_LOG_ERR_WRN_From_Snapshot")
            return RF_ERR_WRN_differ_number, RF_case_status
        RF_ERR_WRN_base_file, case_RF_ERR_WRN_path, test_RF_ERR_WRN_path = \
            manage_RF_ERR_WRN_excel(
                ERR_WRN_analysis_file,
                ERR_WRN_path,
                testline,
                sw_ver,
                case_name)
        snapshot_path_name = 'ERR_WRN_Snapshot_' + timestamp
        if ERR_WRN_syslog_path is None:
            ERR_WRN_syslog_path_name = 'ERR_WRN_Syslog_' + timestamp
            ERR_WRN_syslog_path = os.path.join(
                test_RF_ERR_WRN_path, ERR_WRN_syslog_path_name)
        ERR_WRN_snapshot_path = os.path.join(
            ERR_WRN_syslog_path, snapshot_path_name)
        os.makedirs(ERR_WRN_snapshot_path, exist_ok=True)
        if os.path.exists(snapshot_zip_path):
            if os.path.isdir(snapshot_zip_path):
                for filename in os.listdir(snapshot_zip_path):
                    log_file_name = os.path.join(snapshot_zip_path, filename)
                    if os.path.isfile(log_file_name):
                        shutil.copy(log_file_name, ERR_WRN_snapshot_path)
            elif os.path.isfile(snapshot_zip_path):
                shutil.copy(snapshot_zip_path, ERR_WRN_snapshot_path)
        else:
            logging.error(f"{snapshot_zip_path} is not found, please check?")
            return RF_ERR_WRN_number, RF_ERR_WRN_differ_number, RF_case_status
        df_rf_log, ERR_WRN_num = \
            Check_ERR_WRN_From_All_RF_LOG(
                ERR_WRN_snapshot_path, serial_number_list)
        logging.info(
            "Start generate_ERR_WRN_new_base and calculate_the_number_of_ERR_WRN")
        # logging.info(
        #    f"ERR_WRN_log_file is {ERR_WRN_log_file}")
        t1 = datetime.now()
        if user_base_file is None or user_base_file == 'None':
            logging.info(
                "Start get the reffered err_wrn file")
            RF_base_file = get_refer_ERR_WRN_base(
                case_RF_ERR_WRN_path, sw_ver, RF_ERR_WRN_base_file)
        else:
            RF_base_file = user_base_file
        RF_ERR_WRN_base_file, RF_ERR_WRN_number, RF_ERR_WRN_sum = generate_RF_ERR_WRN(
            RF_ERR_WRN_base_file, df_rf_log)
        duration1 = datetime.now() - t1
        logging.info(
            f'the reference RF ERR_WRN excel file is "{RF_base_file}"')
        logging.info(
            f'the time spent is "{duration1}" in generate_RF_ERR_WRN and get_refer_ERR_WRN_base')
        if RF_base_file is not None:
            if check_diff:
                logging.info(
                    f"Start compare_ERR_WRN_with_base with {RF_base_file}")
                RF_ERR_WRN_base_file, expected_RF_ERR_WRN, RF_ERR_WRN_differ_number = \
                    check_RF_ERR_WRN_Differ_with_base(
                        RF_base_file, RF_ERR_WRN_base_file)
        else:
            logging.warning(f"there is no RF base file for reference, "
                            f"maybe this is the first run for this case or base file is cleared")
        RF_case_status = Check_test_result(expected_RF_ERR_WRN, expected_ERR_WRN_differ,
                                           RF_ERR_WRN_sum, RF_ERR_WRN_differ_number,
                                           expected_ERR_WRN_deviation, fail_case)
        clear_snapshot_for_rf_log(case_RF_ERR_WRN_path, keep_log_number)
        logging.info(f'RF ERR_WRN check case status is {RF_case_status}')
    except Exception as e:
        logging.error(
            f"!!!!!!there is exception {e} when execute Check_RF_ERR_WRN",
            exc_info=True)
    return RF_ERR_WRN_differ_number, RF_case_status


def clear_snapshot_for_rf_log(
        case_log_path, keep_log_number=2):
    logging.info(
        f"Start clear_snapshot, keep the latest {keep_log_number} snapshot")
    file_list = []
    if os.path.exists(case_log_path):
        if len(os.listdir(case_log_path)) > 0:
            for root, dirs, files in os.walk(case_log_path):
                for file_name in files:
                    if 'snapshot' in file_name.lower() and '.zip' in file_name.lower():
                        file_path = os.path.join(root, file_name)
                        file_list.append(file_path)
            files_with_mtime = [(f, os.path.getmtime(f)) for f in file_list]
            files_with_mtime.sort(key=lambda x: x[1], reverse=True)
            if len(files_with_mtime) > 2:
                files_to_delete = [f for f,
                                   mtime in files_with_mtime[keep_log_number:]]
                for file_path in files_to_delete:
                    try:
                        os.remove(file_path)
                    except Exception as e:
                        logging.info(f"Failed to delete {file_path}: {e}")
        else:
            logging.info(f"There is no logs need to be cleared")
    else:
        logging.info(f"There is no path {case_log_path}")


def create_whitelist_sheet(
        ERR_WRN_analysis, whitelist, update_date):
    install_and_import_package('pandas')
    import pandas as pd
    install_and_import_package('openpyxl')
    import openpyxl
    sheet_name_new = f"Whitelist_Common_{update_date}"
    try:
        workbook = openpyxl.load_workbook(ERR_WRN_analysis)
        sheet_names = workbook.sheetnames
    except Exception as e:
        logging.warning(
            f"Failed:there is exception {e} when load ERR_WRN_analysis file ,can't create_whitelist_sheet")
        return False
    df_Whitelist_Common = pd.DataFrame(whitelist, columns=Whitelist_Common)
    for sheet_name in sheet_names:
        if 'Whitelist_Common' in sheet_name:
            workbook.remove(workbook[sheet_name])
    workbook.save(ERR_WRN_analysis)
    workbook.close()
    with pd.ExcelWriter(ERR_WRN_analysis, engine='openpyxl', mode='a') as writer:
        df_Whitelist_Common.to_excel(
            writer, sheet_name=sheet_name_new, index=False)
    return sheet_name_new, ERR_WRN_analysis


def ERR_WRN_Differ_compare_with_whitelist_Common(
        ERR_WRN_analysis, sheet_name):
    global match_ratio
    install_and_import_package('pandas')
    import pandas as pd
    install_and_import_package('openpyxl')
    import openpyxl
    install_and_import_package('regex')
    import regex as reg
    row_index_list = {}
    logging.warning(
        f"ERR_WRN_data is {ERR_WRN_analysis}")
    if ERR_WRN_analysis is None:
        logging.error(
            f"compass err wrn data is None, can't compare with Whitelist_Common")
        return False
    try:
        workbook = openpyxl.load_workbook(ERR_WRN_analysis)
        sheet_names_analysis = workbook.sheetnames
    except Exception as e:
        logging.error(
            f"Failed:there is exception {e},when load ERR_WRN_analysis file, can't compare_with_whitelist_Common")
        return False
    if f'{sheet_name}' in sheet_names_analysis:
        df_whitelist = pd.read_excel(
            ERR_WRN_analysis,
            sheet_name=f'{sheet_name}')
    else:
        logging.warning(
            f"Whitelist_Common not exist, can't compare with Whitelist_Common")
        return False
    if 'ERR_WRN_Differ' in sheet_names_analysis:
        df_differ = pd.read_excel(
            ERR_WRN_analysis,
            sheet_name='ERR_WRN_Differ')
    else:
        logging.warning(
            f"ERR_WRN_Differ is not exist, can't compare with Whitelist_Common")
        return False
    for row_index, row in df_differ.iterrows():
        csv_row = df_differ.loc[row_index]
        ERR_WRN_content = csv_row['Description']
        for row_index_c, row_c in df_whitelist.iterrows():
            csv_row_c = df_whitelist.loc[row_index_c]
            whitelist_reg = csv_row_c['Regular_expression']
            Whitelist_Common_No = csv_row_c['No']
            whitelist_reg = reg.compile(whitelist_reg, reg.I)
            if whitelist_reg is not None:
                matches = whitelist_reg.findall(ERR_WRN_content)
                if matches:
                    row_index_list[(row_index + 2)
                                   ] = Whitelist_Common_No
                    break
    if len(row_index_list) != 0:
        green_fill = openpyxl.styles.PatternFill(
            start_color='00FF00', end_color='00FF00', fill_type='solid')
        workbook = openpyxl.load_workbook(ERR_WRN_analysis)
        sheet = workbook['ERR_WRN_Differ']
        column_name = 'Whitelist_Common_No'
        column_name_1 = 'Whitelist_Confluence_link'
        for col in range(1, sheet.max_column + 1):
            cell_value = sheet.cell(row=1, column=col).value
            if cell_value == column_name:
                column_index = col
                break
            else:
                column_index = None
        for col in range(1, sheet.max_column + 1):
            cell_value = sheet.cell(row=1, column=col).value
            if cell_value == column_name_1:
                column_index_1 = col
                break
            else:
                column_index_1 = None
        logging.info(f"row_index_list' is {row_index_list}'")
        if column_index is not None and column_index_1 is not None:
            for row_index in row_index_list.keys():
                for cell in sheet[row_index]:
                    cell.fill = green_fill
                new_value = int(row_index_list[row_index])
                sheet.cell(
                    row=row_index,
                    column=column_index,
                    value=new_value)
                sheet.cell(
                    row=row_index,
                    column=column_index_1,
                    value=Whitelist_Confluence_link)
        else:
            logging.info(
                f"column_name'{column_name}' or '{column_name_1}' is not found")
            return False
        workbook.save(ERR_WRN_analysis)
        workbook.close()
    return True


def find_header_in_excel(file_path, header_name='Problem ID', max_rows=20):
    install_and_import_package('pandas')
    import pandas as pd
    with open(file_path, 'r') as file:
        for row_idx, line in enumerate(file, start=1):
            # logging.info(f"line is {line}")
            if header_name in line.strip():
                logging.info(f"header is in row {row_idx}")
                df_pr = pd.read_csv(f'{file_path}', skiprows=(row_idx - 1))
                df_pr = df_pr.dropna(how='all')
                return df_pr
            if row_idx >= max_rows:
                break
    return None


def find_the_newest_pronto_file(file_path):
    file_list = []
    if os.path.exists(file_path):
        if len(os.listdir(file_path)) > 0:
            for root, dirs, files in os.walk(file_path):
                for file_name in files:
                    if 'pronto' in file_name.lower() and '.csv' in file_name.lower():
                        file_path = os.path.join(root, file_name)
                        file_list.append(file_path)
            files_with_mtime = [(f, os.path.getmtime(f)) for f in file_list]
            files_with_mtime.sort(key=lambda x: x[1], reverse=True)
            pronto_file = files_with_mtime[0][0]
            logging.info(f"pronto file is {pronto_file}")
            return pronto_file
        else:
            logging.warning(f"there is no pronto file in {file_path}")
            return None
    else:
        logging.warning(f"pronto file path {file_path} is not found")
        return None


def get_ERR_WRN_print_from_log_detail(log_detail, filter_list=None):
    log_list_in_pronto = []
    pattern_start = "Analysis of Logs:"
    pattern_end = "Pronto Creation Insights:"
    lines = [line for line in log_detail.splitlines() if line.strip()]
    cleaned_text = '\n'.join(lines)
    lines = cleaned_text.split('\n')
    after_line = None
    for i, line in enumerate(lines):
        if pattern_start in line:
            after_line = '\n'.join(lines[lines.index(line) + 1:])
    if after_line is not None:
        lines = after_line.split('\n')
        before_line = None
        for i, line in enumerate(lines):
            if pattern_end in line:
                before_line = '\n'.join(lines[:(lines.index(line))])
        logging.warning(
            f"before_line is {before_line}")
        if before_line is not None:
            line_count = before_line.count('\n') + 1
            log_list_in_pronto = []
            if line_count > 0:
                ERR_WRN_list = before_line.split('\n')
                for ERR_WRN in ERR_WRN_list:
                    content_compass = get_ERR_WRN_content_from_compass_data(
                        ERR_WRN, filter_list)
                    # logging.warning(
                    #    f"content_compass is {content_compass}")
                    if content_compass not in log_list_in_pronto and content_compass is not None:
                        log_list_in_pronto.append(content_compass)
    return log_list_in_pronto


def pronto_compare_with_compass_data(
        compass_data_path, pronto_data, filter_list=None):
    global match_ratio, pronto_log_sum
    install_and_import_package('pandas')
    import pandas as pd
    install_and_import_package('openpyxl')
    import openpyxl
    row_index_list = {}
    logging.warning(
        f"pronto_data is {pronto_data}")
    if compass_data_path is None:
        logging.error(
            f"compass err wrn data is None, can't compare with compass data")
        return False
    try:
        workbook = openpyxl.load_workbook(compass_data_path)
        sheet_names_compass = workbook.sheetnames
    except Exception as e:
        logging.warning(
            f"compass_data_path not exist, can't compare with compass data")
        return False
    try:
        workbook = openpyxl.load_workbook(pronto_data)
        sheet_names_analysis = workbook.sheetnames
        logging.warning(
            f"sheet_names_analysis is {sheet_names_analysis}")
    except Exception as e:
        logging.warning(
            f"ERR_WRN_data not exist, can't compare with compass data")
        return False
    if 'ERR_WRN_IN_PRONTO' in sheet_names_analysis:
        df_differ = pd.read_excel(
            pronto_data,
            sheet_name='ERR_WRN_IN_PRONTO')
    else:
        logging.warning(
            f"ERR_WRN_IN_PRONTO not exist, can't compare with compass data")
        return False
    if 'sheet1' in sheet_names_compass:
        df_compass = pd.read_excel(
            compass_data_path,
            sheet_name='sheet1')
    else:
        logging.warning(
            f"sheet1 in compass excel not exist, can't compare with compass data")
        return False
    for row_index, row in df_differ.iterrows():
        csv_row = df_differ.loc[row_index]
        pronto_content = csv_row['Description']
        pronto_id = csv_row['Problem ID']
        match_num = 0
        compass_link_list = []
        pronto_log_list = []
        similar_pr = False
        for row_index_c, row_c in df_compass.iterrows():
            csv_row_c = df_compass.loc[row_index_c]
            ERR_WRN_compass_link = csv_row_c['Compass Link']
            pronto_id_in_in_compass = csv_row_c['Attached PR']
            if pronto_id in str(pronto_id_in_in_compass):
                logging.info(f"this PR {pronto_id} is found in compass")
                if ERR_WRN_compass_link not in compass_link_list:
                    compass_link_list.append(
                        ERR_WRN_compass_link)
                row_index_list[(row_index + 2)
                               ] = compass_link_list
                similar_pr = True
                break
        if similar_pr:
            logging.info(f"go to the next pr")
            continue
        for row_index_c, row_c in df_compass.iterrows():
            csv_row_c = df_compass.loc[row_index_c]
            ERR_WRN_compass = str(csv_row_c['Log Detail'])
            ERR_WRN_compass_link = csv_row_c['Compass Link']
            pronto_id_in_in_compass = csv_row_c['Attached PR']
            if len(pronto_log_list) == 0:
                logging.info(
                    f"PR {pronto_id} : get_ERR_WRN_print_from_log_detail")
                pronto_log_list = get_ERR_WRN_print_from_log_detail(
                    pronto_content)
                pronto_log_sum = len(pronto_log_list)
                logging.info(
                    f"pronto is {csv_row['Problem ID']} and pronto_log_sum is {pronto_log_sum}")
            line_count = ERR_WRN_compass.count('\n') + 1
            if pronto_log_sum > 0:
                for pronto_log in pronto_log_list:
                    if line_count > 1:
                        ERR_WRN_list = ERR_WRN_compass.split('\n')
                        for ERR_WRN in ERR_WRN_list:
                            content_compass = get_ERR_WRN_content_from_compass_data(
                                ERR_WRN, filter_list)
                            if content_compass is not None:
                                matcher = SequenceMatcher(
                                    None, pronto_log, content_compass)
                                match_ratio = matcher.ratio()
                                if match_ratio >= expected_match_ratio:
                                    match_num += 1
                                    if ERR_WRN_compass_link not in compass_link_list:
                                        compass_link_list.append(
                                            ERR_WRN_compass_link)
                                    row_index_list[(row_index + 2)
                                                   ] = compass_link_list
                                    break
                    else:
                        content_compass = get_ERR_WRN_content_from_compass_data(
                            ERR_WRN_compass, filter_list)
                        if content_compass is not None:
                            matcher = SequenceMatcher(
                                None, pronto_log, content_compass)
                            match_ratio = matcher.ratio()
                            if match_ratio >= expected_match_ratio:
                                match_num += 1
                                if ERR_WRN_compass_link not in compass_link_list:
                                    compass_link_list.append(
                                        ERR_WRN_compass_link)
                                row_index_list[(row_index + 2)
                                               ] = compass_link_list
                                break
        if match_num != 0 and len(pronto_log_list) != 0:
            log_match_ratio = match_num / len(pronto_log_list)
            if log_match_ratio > 0.8:
                logging.info(
                    f"for pronto {csv_row['Problem ID']} there is similar data find in compass")
    if len(row_index_list) != 0:
        green_fill = openpyxl.styles.PatternFill(
            start_color='00FF00', end_color='00FF00', fill_type='solid')
        workbook = openpyxl.load_workbook(pronto_data)
        sheet = workbook['ERR_WRN_IN_PRONTO']
        update_column_1 = 'link_in_compass'
        update_column_2 = 'sam_with_Compass'
        column_index_1 = 0
        column_index_2 = 0
        for col in range(1, sheet.max_column + 1):
            cell_value = sheet.cell(row=1, column=col).value
            if cell_value == update_column_1:
                column_index_1 = col
                break
        for col in range(1, sheet.max_column + 1):
            cell_value = sheet.cell(row=1, column=col).value
            if cell_value == update_column_2:
                column_index_2 = col
                break
        else:
            logging.info(f"column_name'{update_column_1}' is not found")
            return False
        for row_index in row_index_list.keys():
            link_str = '\n'.join(row_index_list[row_index])
            for cell in sheet[row_index]:
                cell.fill = green_fill
            sheet.cell(
                row=row_index,
                column=column_index_1,
                value=link_str)
            sheet.cell(
                row=row_index,
                column=column_index_2,
                value='True')
        workbook.save(pronto_data)
        workbook.close()
    return True


def creat_pronto_analysis_file(file_path, df_data):
    install_and_import_package('pandas')
    import pandas as pd
    install_and_import_package('openpyxl')
    import openpyxl
    current_time = datetime.now()
    df_data = df_data.assign(sam_with_Compass='False', link_in_compass=None)
    timestamp = current_time.strftime('%Y%m%d%H%M%S')
    pronto_analysis_file = creat_excel_file(
        file_path, 'Pronto_ERR_WRN', timestamp)
    workbook = openpyxl.load_workbook(pronto_analysis_file)
    if 'ERR_WRN_IN_PRONTO' in workbook.sheetnames:
        workbook.remove(workbook['ERR_WRN_IN_PRONTO'])
    workbook.save(pronto_analysis_file)
    workbook.close()
    with pd.ExcelWriter(pronto_analysis_file, engine='openpyxl', mode='a') as writer:
        df_data.to_excel(writer, sheet_name='ERR_WRN_IN_PRONTO', index=False)
    return pronto_analysis_file


def get_HW_INFO_pronto_description(pronto_description):
    pattern_start = "Test-Line Reference/used HW/configuration/tools/SW version:"
    pattern_end = "Used Flags:"
    lines = [line for line in pronto_description.splitlines() if line.strip()]
    cleaned_text = '\n'.join(lines)
    lines = cleaned_text.split('\n')
    after_line = None
    for i, line in enumerate(lines):
        if pattern_start in line:
            after_line = '\n'.join(lines[lines.index(line) + 1:])
    HW_info = 'Not_Found_From_PR_Tool'
    if after_line is not None:
        lines = after_line.split('\n')
        before_line = None
        for i, line in enumerate(lines):
            if pattern_end in line:
                before_line = '\n'.join(lines[:(lines.index(line) - 1)])
        if before_line is not None:
            lines_1 = before_line.split('\n')
            for i, line in enumerate(lines_1):
                if line.count('A') > 1:
                    HW_info = line
                    break
    logging.info(
        f"HW info is {HW_info}")
    return HW_info


def generate_compass_upload_data_for_pronto(pronto_data):
    global Process
    install_and_import_package('pandas')
    import pandas as pd
    install_and_import_package('openpyxl')
    import openpyxl
    try:
        workbook = openpyxl.load_workbook(pronto_data)
        sheet_names = workbook.sheetnames
    except Exception as e:
        logging.warning(
            f"ERR_WRN_Differ sheet not exist, can't generate compass data")
        return False
    Key_Signature, Additional_Info = 'TODO', 'From_Pronto_Tool'
    ERR_WRN_Compass_status = 'Open'
    Compass_Link = None
    if 'ERR_WRN_IN_PRONTO' in sheet_names:
        df_base_compass = pd.DataFrame(columns=Compass_column_names)
        df_differ = pd.read_excel(
            pronto_data,
            sheet_name='ERR_WRN_IN_PRONTO')
        if len(df_differ) != 0:
            df_differ_new = df_differ[~df_differ['sam_with_Compass']]
            for row_index, row in df_differ_new.iterrows():
                # for new_base_row in range(0, df_new_base_data_row_count):
                new_base_row = df_differ_new.loc[row_index]
                Component = new_base_row['Group in Charge']
                pronto_detail = new_base_row['Description']
                pronto_log_list = get_ERR_WRN_print_from_log_detail(
                    pronto_detail)
                Log_Detail_str = '\n'.join(pronto_log_list)
                if 'ERR/' in Log_Detail_str:
                    Severity = 'ERR'
                else:
                    Severity = 'WRN'
                Process = new_base_row['Group in Charge']
                Attached_PR = new_base_row['Problem ID']
                Analysis_Summary = 'TODO'
                Contributor = new_base_row['Author']
                Squad_Group = new_base_row['Author Group']
                feature = new_base_row['Feature']
                sw_ver_release = new_base_row['Release']
                sw_ver = new_base_row['Build']
                now = datetime.now()
                Created_datatime = now.strftime('%Y-%m-%d %H:%M:%S')
                HW_Info = get_HW_INFO_pronto_description(pronto_detail)
                logging.warning(
                    f"{Attached_PR} pronto_log_list is {pronto_log_list}")
                data = [
                    Component,
                    Process,
                    Log_Detail_str,
                    Severity,
                    feature,
                    sw_ver_release,
                    sw_ver,
                    HW_Info,
                    Contributor,
                    Squad_Group,
                    ERR_WRN_Compass_status,
                    Analysis_Summary,
                    Attached_PR,
                    Key_Signature,
                    pronto_detail,
                    Additional_Info,
                    Created_datatime,
                    Compass_Link]
                df_base_compass.loc[len(df_base_compass.index)] = data
            workbook = openpyxl.load_workbook(pronto_data)
            if 'ERR_WRN_History' in workbook.sheetnames:
                workbook.remove(workbook['ERR_WRN_History'])
                workbook.save(pronto_data)
                workbook.close()
            with pd.ExcelWriter(pronto_data, engine='openpyxl', mode='a') as writer:
                df_base_compass.to_excel(
                    writer, sheet_name='ERR_WRN_History', index=False)
            yellow_fill = openpyxl.styles.PatternFill(
                start_color='FFFF00', end_color='FFFF00', fill_type='solid')
            workbook = openpyxl.load_workbook(pronto_data)
            sheet = workbook['ERR_WRN_History']
            for cell in sheet[1]:
                if cell.value in Compass_column_names_mandatory:
                    cell.fill = yellow_fill
            workbook.save(pronto_data)
            workbook.close()
        else:
            logging.warning(
                f"ERR_WRN_Differ data is empty, generate compass data failed")
    workbook = openpyxl.load_workbook(pronto_data)
    if 'Sheet' in workbook.sheetnames:
        workbook.remove(workbook['Sheet'])
        workbook.save(pronto_data)
        workbook.close()


def upload_ERR_WRN_to_compass(
        df_data, refer_base_sw_ver=None, compass_url=compass_url, username='erta', password='R&D_VRF_HAZ3'):
    global res, response_data
    install_and_import_package('requests')
    import requests
    install_and_import_package('urllib')
    import urllib
    install_and_import_package('pandas')
    import pandas as pd
    install_and_import_package('openpyxl')
    import openpyxl
    compass_file_dic = {}
    compass_id_list = []
    session = requests.session()
    case_test_run_link = get_case_test_run_link()
    if df_data is None:
        logging.warning(f"there is no data need to upload to the compass")
        return None
    # condition = (df_data['Compass Link'].isnull())
    # condition = (
    #    df_data['Compass Link'].isnull()) & (
    #    df_data['Severity'] == 'ERR')
    condition = (df_data['Severity'] == 'ERR')
    df_data_new = df_data[condition]
    if len(df_data_new) == 0:
        logging.warning(f"there is no ERR data need to upload to the compass")
        return None
    login_url = 'http://compass.dyn.nesc.nokia.net:8080/common/login_handle/'
    try:
        res = session.post(
            login_url,
            data={
                'username': username,
                'password': password},
            timeout=60)
    except Exception as e:
        logging.error(f"there is exception {e} when login compass")
        return None
    response_data = res.text
    # logging.info(f"the res of login compass is {response_data}")
    logging.info(f"the res of login compass is {res.status_code}")
    if res.status_code == 200:
        try:
            session.headers['cookie'] = res.headers.get(
                'Set-Cookie').split(';', 1)[0]
        except Exception as e:
            logging.error(f"there is exception {e} when get cookies")
            return None
    else:
        logging.error(f"login compass failed")
        return None
    logging.info(
        f"login session is {session} and download err_wrn data from compass")
    save_err_wrn_url = compass_url + 'infoshare/api/create_err_wrn_data/'
    for row_index, row in df_data_new.iterrows():
        new_base_row = df_data_new.loc[row_index]
        Component = new_base_row['Component']
        Process = new_base_row['Process']
        Log_Detail = new_base_row['Log Detail']
        Severity = new_base_row['Severity']
        feature = new_base_row['Feature']
        sw_ver_release = new_base_row['Release']
        sw_ver = new_base_row['SW Info']
        HW_INFO = new_base_row['HW Info']
        Analysis_Summary = new_base_row['Analysis Summary']
        Key_Signature = new_base_row['Key Signature']
        pronto_detail = new_base_row['Description']
        attached_pr = new_base_row['Attached PR']
        Contributor = new_base_row['Contributor']
        log_path = new_base_row['Log Path']
        # Squad_Group = new_base_row['Author Group']
        if Severity == 'WRN':
            Severity = 'Warning'
        if Severity == 'ERR':
            Severity = 'Error'
        info = [{"component": f"{Component}", "process": f'{Process}',
                "log_detail": f'{Log_Detail}', "severity": f'{Severity}',
                 "feature": f'{feature}', "release": f'{sw_ver_release}', "sw_info": f'{sw_ver}',
                 "test_line": f'{HW_INFO}',
                 "key_signature": f'{Key_Signature}',
                 "description": 'from ERR WRN check', 'log_path': f'{log_path}',
                 "test_instance_id": f'{Contributor}', "test_run_link": f'{case_test_run_link}',
                 "last_sw_info": f'{refer_base_sw_ver}',
                 "additional_info": 'from ERR WRN check'}]
        if info is not None:
            json_info = json.dumps(info)
            logging.info(f"info is {json_info}")
            # save_res = session.post(save_err_wrn_url, data={'info': json_info})
            save_res = session.post(save_err_wrn_url, data=json_info)
            if save_res.status_code == 200:
                logging.info(f"save_res_json is {save_res.json()}")
                result = json.loads(save_res.content)
                if not result.get('success'):
                    logging.error(
                        f"Failed: upload data to compass : {result.get('error')}")
                else:
                    if isinstance(result.get('data'), list):
                        if len(result.get('data')) != 0:
                            compass_id_one_data = result.get('data')[0]
                            logging.info(
                                f"Success: upload data to compass : {compass_id_one_data}")
                            compass_id_list.append(compass_id_one_data)
                        else:
                            logging.error(f"Failed: get compass data ID")
                    else:
                        logging.error(
                            f"Failed: get compass data ID because of data not list")
            else:
                logging.error(
                    f"Failed: upload data to compass, status_code is :{save_res.status_code}")
    logout_url = compass_url + 'common/logout/'
    res_logout = session.post(logout_url)
    logging.info(f"res_logout_compass is {res_logout}")
    if len(compass_id_list) != 0:
        logging.info(f"Success: get compass data ID list : {compass_id_list}")
    else:
        logging.error(f"Failed: get compass data ID list")
    return compass_id_list


def upload_special_data_to_compass(
        sw_ver, test_line, log_web_link, abnormal_scenario='zero_logs',
        compass_url=compass_url, username='erta', password='R&D_VRF_HAZ3'):
    global res, response_data
    install_and_import_package('requests')
    import requests
    install_and_import_package('urllib')
    import urllib
    install_and_import_package('pandas')
    import pandas as pd
    install_and_import_package('openpyxl')
    import openpyxl
    case_QC_id = get_case_QC_id()
    case_test_run_link = get_case_test_run_link()
    sw_ver_release = sw_ver.split('_')[0]
    logging.info(f"sw_ver_release is {sw_ver_release}")
    session = requests.session()
    login_url = 'http://compass.dyn.nesc.nokia.net:8080/common/login_handle/'
    try:
        res = session.post(
            login_url,
            data={
                'username': username,
                'password': password},
            timeout=60)
    except Exception as e:
        logging.error(f"there is exception {e} when login compass")
        return None
    response_data = res.text
    # logging.info(f"the res of login compass is {response_data}")
    logging.info(f"the res of login compass is {res.status_code}")
    if res.status_code == 200:
        try:
            session.headers['cookie'] = res.headers.get(
                'Set-Cookie').split(';', 1)[0]
        except Exception as e:
            logging.error(f"there is exception {e} when get cookies")
            return None
    else:
        logging.error(f"login compass failed")
        return None
    logging.info(
        f"login session is {session} and download err_wrn data from compass")
    save_err_wrn_url = compass_url + 'infoshare/api/create_err_wrn_data/'
    Component = abnormal_scenario
    Process = abnormal_scenario
    Log_Detail = abnormal_scenario
    Severity = 'Error'
    feature = abnormal_scenario
    sw_ver_release = sw_ver_release
    sw_ver = sw_ver
    HW_INFO = test_line
    Key_Signature = abnormal_scenario
    Contributor = case_QC_id
    log_path = log_web_link
    info = [{"component": f"{Component}", "process": f'{Process}',
             "log_detail": f'{Log_Detail}', "severity": f'{Severity}',
             "feature": f'{feature}', "release": f'{sw_ver_release}', "sw_info": f'{sw_ver}',
             "test_line": f'{HW_INFO}',
             "key_signature": f'{Key_Signature}',
             "description": 'from ERR WRN check', 'log_path': f'{log_path}',
             "test_instance_id": f'{Contributor}', "test_run_link": f'{case_test_run_link}',
             "additional_info": 'from ERR WRN check'}]
    if info is not None:
        json_info = json.dumps(info)
        logging.info(f"info is {json_info}")
        # save_res = session.post(save_err_wrn_url, data={'info': json_info})
        save_res = session.post(save_err_wrn_url, data=json_info)
        if save_res.status_code == 200:
            logging.info(f"save_res_json is {save_res.json()}")
        else:
            logging.info(f"save_res_status_code is {save_res.status_code}")
    logout_url = compass_url + 'common/logout/'
    res_logout = session.post(logout_url)
    logging.info(f"res_logout_compass is {res_logout}")


def analysis_err_wrn_in_pronto(file_path):
    # try:
    pronto_file_csv = find_the_newest_pronto_file(file_path)
    df_pr = find_header_in_excel(pronto_file_csv)
    pronto_analysis_file = creat_pronto_analysis_file(file_path, df_pr)
    compass_data_path = get_ERR_WRN_data_from_compass(
        compass_url, data_gap_days=0)
    pronto_compare_with_compass_data(
        compass_data_path, pronto_analysis_file)
    logging.info(f"start generate_compass_upload_data_for_pronto")
    generate_compass_upload_data_for_pronto(pronto_analysis_file)
    upload_ERR_WRN_to_compass(pronto_analysis_file)
    # except Exception as e:
    #    logging.error(
    #        f"there is exception {e} when analysis_err_wrn_in_pronto")


def upload_syslog_by_ssh(ssh, local_dir, remote_dir, syslog_dir):
    remote_file_dir = None
    if os.path.exists(f'{local_dir}'):
        sftp = ssh.open_sftp()
        stdin, stdout, stderr = ssh.exec_command(
            f'[ ! -d "{remote_dir}" ] && mkdir -p "{remote_dir}"')
        for root, dirs, files in os.walk(syslog_dir):
            for file_name in files:
                local_file = os.path.join(root, file_name)
                file_size = os.path.getsize(local_file)
                remote_file = local_file.replace(local_dir, remote_dir)
                remote_file_dir = os.path.dirname(remote_file)
                stdin, stdout, stderr = ssh.exec_command(
                    f'[ ! -d "{remote_file_dir}" ] && mkdir -p "{remote_file_dir}"')
                logging.info(f"Uploaded: {local_file} -> {remote_file}")
                time.sleep(1)
                sftp.put(local_file, remote_file)
        logging.info("All syslog upload completed successfully!")
        if 'sftp' in locals():
            sftp.close()
    return remote_file_dir


def upload_file_by_ssh(ssh, local_dir, remote_dir, file_name):
    remote_file = None
    if os.path.exists(f'{local_dir}/{file_name}'):
        sftp = ssh.open_sftp()
        stdin, stdout, stderr = ssh.exec_command(
            f'[ ! -d "{remote_dir}" ] && mkdir -p "{remote_dir}"')
        logging.info(f"the local file: {local_dir}/{file_name}")
        logging.info(f"the remote file: {remote_dir}/{file_name}")
        remote_file = f"{remote_dir}/{file_name}"
        time.sleep(1)
        sftp.put(f'{local_dir}/{file_name}', f'{remote_dir}/{file_name}')
        if 'sftp' in locals():
            sftp.close()
    return remote_file


def upload_file_to_remote_server(local_file, remote_dir):
    if os.path.exists(local_file):
        file_name = os.path.basename(local_file)
        local_dir = os.path.dirname(local_file)
        ssh = init_ssh_client()
        remote_file = upload_file_by_ssh(ssh, local_dir, remote_dir, file_name)
    else:
        logging.error(
            "Failed:upload_file_to_remote_server because this file not exist")
    if 'ssh' in locals():
        ssh.close()


def download_file_from_remote(ssh, local_dir, remote_dir, file_name):
    remote_file = os.path.join(remote_dir, file_name)
    local_file = os.path.join(local_dir, file_name)
    if not os.path.exists(local_dir):
        logging.info(
            f"local dir {local_dir} not exist and create this directory")
        os.makedirs(local_dir, exist_ok=True)
    try:
        sftp = ssh.open_sftp()
        try:
            sftp.stat(remote_file)
        except Exception as e:
            logging.error(
                f"download fail:remote file {remote_file}, there is error {e}")
            local_file = None
            return local_file
        sftp.get(remote_file, local_file)
        logging.info(f"download {remote_file} to {local_dir} successfully")
    except Exception as e:
        local_file = None
        logging.error(f"download fail: {str(e)}")
    finally:
        if 'sftp' in locals():
            sftp.close()
    return local_file


def clean_remote_files_and_keep_the_latest_file(
        ssh, target_dir, file_type='f'):
    latest_cmd = 'ls'
    if file_type == 'f':
        latest_cmd = f'find "{target_dir}" -type f -name "*.xlsx" -not -empty ' \
            f'-printf "%TY-%Tm-%Td %Tk:%Tp %p\n" | sort -n | tail -n 1'
    if file_type == 'd':
        latest_cmd = f'find "{target_dir}" -mindepth 1 -maxdepth 1 -type d -not -empty ' \
                     f'-printf "%TY-%Tm-%Td %Tk:%Tp %p\n" | sort -n | tail -n 1'
    stdin, stdout, stderr = ssh.exec_command(latest_cmd)
    latest_info = stdout.read().decode().strip()
    refer_base_file = None
    delete_cmd = 'ls'
    if latest_info:
        date_str, time_str, path = latest_info.split(maxsplit=2)
        logging.info(f"keep the latest file: {path} ({date_str} {time_str})")
        refer_base_file = path
        '''
            search_cmd = f'find "{target_dir}" -type "{file_type}" -mindepth 1 ' \
                         f'-print 2>/dev/null || echo "ERROR: Directory not found"'
            stdin, stdout, stderr = ssh.exec_command(search_cmd)
            file_list = stdout.read().decode().splitlines()
            if file_list and file_list[0].startswith('ERROR'):
                if file_list and file_list[0].startswith('ERROR'):
                    logging.warning(f"there is error in directory {target_dir}: {str(file_list[0])}")
            logging.info(f"file list in directory {target_dir} is : {file_list}")
            file_list.remove(path)
            for file in file_list:
                if file_type == 'f':
                    delete_cmd = f'rm -f {file}'
                if file_type == 'd':
                    delete_cmd = f'rm -rf {file}'
                ssh.exec_command(delete_cmd)
            '''
    return refer_base_file


def init_ssh_client(host=remote_server_IP,
                    user=remote_server_user, pwd=remote_server_pwd):
    install_and_import_package('paramiko')
    import paramiko
    if 'ssh' in locals():
        ssh.close()
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(host, username=user, password=pwd)
    return ssh


def check_directory_exist(ssh, target_dir):
    sftp = ssh.open_sftp()
    try:
        sftp.stat(target_dir)
        dir_exist = True
    except Exception as e:
        dir_exist = False
        logging.warning(f"target_dir {target_dir} not exist")
    finally:
        sftp.close()
    return dir_exist


def manage_directory_in_remote_server(
        ERR_WRN_path, testline, sw_ver, case_name='empty_case_name'):
    sw_ver_release = sw_ver.split('_')[0]
    logging.info(f"sw_ver_release is {sw_ver_release}")
    test_path = os.path.join(ERR_WRN_path, testline, case_name, sw_ver_release)
    test_path_ver = os.path.join(
        ERR_WRN_path,
        testline,
        case_name,
        sw_ver_release,
        sw_ver)
    case_path = os.path.join(ERR_WRN_path, testline, case_name)
    TL_path = os.path.join(ERR_WRN_path, testline)
    # os.makedirs(test_ERR_WRN_path, exist_ok=True)
    return case_path, test_path, test_path_ver, TL_path


def get_remote_refer_base_file(
        ERR_WRN_path, testline, sw_ver, case_name='empty_case_name'):
    refer_base_file = None
    path_list = manage_directory_in_remote_server(
        ERR_WRN_path, testline, sw_ver, case_name)
    test_path_ver = path_list[2]
    logging.info(f"test_path: {test_path_ver}")
    test_path = path_list[1]
    ssh = init_ssh_client()
    test_path_ver_exist = check_directory_exist(ssh, test_path_ver)
    if test_path_ver_exist:
        refer_base_file = clean_remote_files_and_keep_the_latest_file(
            ssh, test_path_ver, 'f')
    else:
        if refer_base_file is None:
            refer_base_directory = clean_remote_files_and_keep_the_latest_file(
                ssh, test_path, 'd')
            refer_base_file = clean_remote_files_and_keep_the_latest_file(
                ssh, refer_base_directory, 'f')
    logging.info(f"refer_base_file from remote server:{refer_base_file}")
    if 'ssh' in locals():
        ssh.close()
    return refer_base_file, test_path_ver


def get_case_QC_id():
    try:
        case_QC_id = BuiltIn().get_variable_value('${CASE_QC_ID}')
        logging.info(f"case_QC_id is {case_QC_id}")
    except Exception as e:
        logging.warning(f"parameter CASE_QC_ID not found")
        case_QC_id = None
    return case_QC_id


def get_case_test_run_link():
    try:
        case_test_run_link = BuiltIn().get_variable_value(
            '${CASE_TEST_RUN_LINK}')
        logging.info(f"case_test_run_link is {case_test_run_link}")
    except Exception as e:
        logging.warning(f"parameter case_test_run_link not found")
        case_test_run_link = None
    return case_test_run_link


def get_data_in_sheet(file_path, sheet_name):
    """
    update the data of specified columns of Excel Sheet
    :param file_path: Excel file path
    :param sheet_name: sheet name needs to be updated
    :return the data in the sheet:  dataframe
    """
    install_and_import_package('openpyxl')
    import openpyxl
    install_and_import_package('pandas')
    import pandas as pd
    df_data = None
    try:
        workbook = openpyxl.load_workbook(file_path)
        sheet_names_analysis = workbook.sheetnames
    except Exception as e:
        logging.warning(
            f"{file_path} not exist, can't get_data_in_sheet")
        return df_data
    if sheet_name in sheet_names_analysis:
        df_data = pd.read_excel(
            file_path,
            sheet_name=sheet_name)
        logging.info(f"Successful get_data_in_sheet, file is {file_path}")
    else:
        logging.warning(
            f"sheet {sheet_name} not exist, can't get_data_in_sheet")
        return df_data
    return df_data


def update_data_in_sheet(file_path, sheet_name, column_name, new_value):
    df_data = get_data_in_sheet(file_path, sheet_name)
    if df_data is not None:
        df_data[column_name] = new_value
        logging.info(f"update_data_in_sheet successfully")
    return df_data


def generate_web_link_for_log(
        remote_dir, log_server_link=log_server_link, target_str='ERR_WRN_analysis'):
    log_web_link = log_server_link
    index = remote_dir.find(target_str)
    if index != -1:
        dir_part = remote_dir[index + len(target_str):]
    else:
        dir_part = None
    if dir_part is not None:
        log_web_link = log_server_link + dir_part
    else:
        log_web_link = log_server_link
        logging.error(f"Failed: generate_web_link_for_log")
    return log_web_link


def set_xlsx_file_version(file_path, sw_ver):
    """
    set the site SW version in xlsx file
    :param file_path: Excel file path
    :param sw_ver: SW version in the site
    """
    install_and_import_package('openpyxl')
    import openpyxl
    if file_path is not None:
        try:
            workbook = openpyxl.load_workbook(file_path)
            workbook.properties.version = str(sw_ver)
            workbook.properties.creator = "Generated_ERR_WRN"
            workbook.save(file_path)
        except Exception as e:
            logging.error(
                f"{file_path} not exist, can't set_xlsx_file_version")
            return None
    else:
        logging.error(
            f"{file_path} is none, can't set_xlsx_file_version")
        return None


def get_xlsx_file_version(file_path):
    """
    get the site SW version in xlsx file
    :param file_path: Excel file path
    """
    install_and_import_package('openpyxl')
    import openpyxl
    if file_path is not None:
        try:
            workbook = openpyxl.load_workbook(file_path, read_only=True)
        except Exception as e:
            logging.error(
                f"{file_path} not exist, can't get_xlsx_file_version")
            file_sw_ver = None
            return file_sw_ver
        if hasattr(workbook, 'properties') and hasattr(
                workbook.properties, 'version'):
            file_sw_ver = workbook.properties.version
            logging.info(
                f"the sw version of xlsx file is {file_sw_ver}")
        else:
            logging.error(
                f"workbook.properties.version not found, can't get_xlsx_file_version")
            file_sw_ver = None
    else:
        file_sw_ver = None
        logging.error(
            f"{file_path} is none, can't get_xlsx_file_version")
    return file_sw_ver


def add_column_comments(file_path, comment_text,
                        sheet_name='ERR_WRN_Differ', column_name='Description'):
    """
     add some comments in the specified column of specified sheet
     :param file_path: Excel file path
     :param comment_text: comment text
     :param sheet_name: sheet name
     :param sheet_name: column name
    """
    install_and_import_package('openpyxl')
    import openpyxl
    try:
        workbook = openpyxl.load_workbook(file_path)
        ws = workbook[sheet_name]
        header = next(ws.iter_rows(min_row=1, max_row=1))
        col_idx = None
        for cell in header:
            if str(cell.value).strip() == column_name.strip():
                col_idx = cell.column
                break
        if not col_idx:
            logging.error(
                f"{column_name} is not found, can't add_column_comments")
            return None
        for row in ws.iter_rows(min_row=2, min_col=col_idx, max_col=col_idx):
            for cell in row:
                if cell.value and str(cell.value).strip():
                    if cell.comment:
                        cell.comment.text = comment_text
                    else:
                        cell.comment = openpyxl.comments.Comment(
                            comment_text, "ERR_WRN")
        workbook.save(file_path)
    except Exception as e:
        logging.warning(
            f"Failed: there is error {e}, can't add_column_comments")
    return file_path


'''
if __name__ == "__main__":
    local_dir = '/home/ute/ERR_WRN_analysis'
    ERR_WRN_base_file = '/home/ute/ERR_WRN_analysis/ERR_WRN_Analysis_20250811164658.xlsx'
    sw_ver = 'SBTS26R1_ENB_9999_250728_000009'
    testline = '7_5_UTE5G402T930'
    file_name = 'ERR_WRN_Analysis_20250731171047.xlsx'
    comment_text = 'compare with ' + sw_ver
    total_lines_all_file = 0
    ERR_WRN_syslog_path = '/data/ERR_WRN_analysis'
    compass_data_path = get_ERR_WRN_data_from_compass(compass_url)
'''
