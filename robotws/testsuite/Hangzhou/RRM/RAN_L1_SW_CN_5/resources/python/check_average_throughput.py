# -*- coding: utf-8 -*-
"""
Author: Lin Stella
Contacts: stella.lin@nokia-sbell.com
Squard: HGZ SG6
Description: Get UL/DL Average Throughput on L2HI or L2LO on gNB side.

"""
import os
from os import path
import datetime
from time import sleep
from taf.transport.ssh import ssh
from robot.libraries.BuiltIn import BuiltIn
import logging
import decimal
import collections
import re
from taf.rfrl.common_resources.python import stream_manager
import aasyslog


__all__ = [
    "save_average_tput_file_and_download_to_testPC",
    "evaluate_average_tput", "start_tput_log_capturing", "stop_tput_log_capturing", "download_tput_files",
    "get_tput_info_for_l2lo", "get_direction_by_file_name", "calculate_time_interval",
    "save_average_tput_file_from_aasyslog_and_download_to_testPC",
    "start_tput_aasyslog_capturing",
    "stop_tput_aasyslog_capturing",
    "download_tput_aasyslog_files",
    "are_tuput_files_neither_empty",
    "get_dl_ul_tput_file_seperately_from_aasyslog"
]

ssh = ssh()


def save_average_tput_file_and_download_to_testPC(
        direction_component_list, download_dir, duration=180,
        asik_alais='ASIK Master', abil_alais='ABIL Master', abil_index='1',
        abil_slave_alais='ABIL Slave'):
    """
    :param direction_component_list: <list> , value can be single or multi values in [UL_L2HI,UL_L2LO,DL_L2HI,DL_L2LO]
    :param duration:sec
    :param download_dir:path on testPC
    :param asik_alais: asik master
    :param abil_alais: abil master
    :param abil_slave_alais: abil slave
    :param abil_index:<str>,abil blade index , count from 1
    :return: <dict>, download files on testpc ,  keys can be UL_L2HI, UL_L2LO, DL_L2HI, DL_L2LO
                    eg:{'UL_L2LO': '/root/workspace/CIT/Master/Case_Logs/5G19A_FSMK_0006_028352_000193/TS_Demo/
                    TC_Check_Multi_Tput_On_gNB/Tput_UL_L2LO_30sec_20191126110505.txt',
                    'DL_L2LO': '/root/workspace/CIT/Master/Case_Case_Logs/5G19A_FSMK_0006_028352_000193/TS_Demo/
                    TC_Check_Multi_Tput_On_gNB/Tput_DL_L2LO_30sec_20191126110506.txt',
                    'UL_L2HI':'/root/workspace/CIT/Master/Case_Case_Logs/5G19A_FSMK_0006_028352_000193/TS_Demo/
                    TC_Check_Multi_Tput_On_gNB/Tput_UL_L2HI_30sec_20191126110506.txt',
                    'DL_L2HI':'/root/workspace/CIT/Master/Case_Case_Logs/5G19A_FSMK_0006_028352_000193/TS_Demo/
                    TC_Check_Multi_Tput_On_gNB/Tput_DL_L2HI_30sec_20191126110506.txt',
    """
    saved_tput_file_list = start_tput_log_capturing(direction_component_list=direction_component_list,
                                                    asik_alais=asik_alais, abil_alais=abil_alais,
                                                    abil_slave_alais=abil_slave_alais)
    sleep(int(duration))
    stop_tput_log_capturing(saved_tput_file_list=saved_tput_file_list, asik_alais=asik_alais, abil_alais=abil_alais,
                            abil_slave_alais=abil_slave_alais)
    download_tput_file_dict = download_tput_files(
        saved_tput_file_list=saved_tput_file_list, download_dir=download_dir, asik_alais=asik_alais,
        abil_alais=abil_alais, abil_index=abil_index, duration=duration,
        abil_slave_alais=abil_slave_alais)
    return download_tput_file_dict


def start_tput_log_capturing(direction_component_list, asik_alais='ASIK Master', abil_alais='ABIL Master',
                             abil_slave_alais='ABIL Slave'):
    """
    Method split from save_average_tput_file_and_download_to_testPC
    :param direction_component_list: <list> , value can be single or multi values in [UL_L2HI,UL_L2LO,DL_L2HI,DL_L2LO]
    :param asik_alais: asik master
    :param abil_alais: abil master
    :param abil_slave_alais: abil slave
    :return: <list>, ['/root/workspace/CIT/Master/Case_Logs/5G19A_FSMK_0006_028352_000193/TS_Demo/
                    TC_Check_Multi_Tput_On_gNB/Tput_UL_L2LO_30sec_20191126110505.txt',
                    '/root/workspace/CIT/Master/Case_Case_Logs/5G19A_FSMK_0006_028352_000193/TS_Demo/
                    TC_Check_Multi_Tput_On_gNB/Tput_DL_L2LO_30sec_20191126110506.txt',
                    '/root/workspace/CIT/Master/Case_Case_Logs/5G19A_FSMK_0006_028352_000193/TS_Demo/
                    TC_Check_Multi_Tput_On_gNB/Tput_UL_L2HI_30sec_20191126110506.txt',
                    '/root/workspace/CIT/Master/Case_Case_Logs/5G19A_FSMK_0006_028352_000193/TS_Demo/
                    TC_Check_Multi_Tput_On_gNB/Tput_DL_L2HI_30sec_20191126110506.txt']
    """
    feature1514_flag = stream_manager.feature_1514_opened(connection=asik_alais)
    timestamp = datetime.datetime.now().strftime('%Y%m%d%H%M%S')
    valid_input_list = ['UL_L2HI', 'UL_L2LO', 'DL_L2HI', 'DL_L2LO']
    assert set(direction_component_list) <= set(
        valid_input_list), 'invalid input,parameter direction_component_list should be in {}'.format(valid_input_list)
    saved_tput_file_list = list()
    for item in direction_component_list:
        direction, component = item.split('_')
        if item == 'UL_L2HI':
            grep_command = 'nohup journalctl -f |grep -i ul-pdcp >{} &'
        elif item == 'DL_L2HI':
            grep_command = 'nohup journalctl -f |grep -i dl-pdcp >{} &'
        elif item == 'UL_L2LO':
            grep_command = 'nohup journalctl -f | grep -i UlCounterUpdate >{} &'
        else:
            grep_command = 'nohup journalctl -f | grep -i SentDataMeasurementCounting >{} &'
        tput_file_name = 'Tput_{}_{}_{}.txt'.format(
            direction, component, timestamp)
        tput_file_path = '/tmp/{}'.format(tput_file_name)
        saved_tput_file_list.append(tput_file_path)
        if component == 'L2LO':
            connection = abil_slave_alais if feature1514_flag is True else abil_alais
        elif component == 'L2HI':
            connection = abil_alais if feature1514_flag is True else asik_alais
        else:
            raise Exception("Unsupported component {} and invalid flag {}".format(component, feature1514_flag))
        ssh.send_command(
            command=grep_command.format(tput_file_path),
            connection=connection)
    return saved_tput_file_list


def stop_tput_log_capturing(saved_tput_file_list, asik_alais='ASIK Master', abil_alais='ABIL Master',
                            abil_slave_alais='ABIL Slave'):
    """
    Method split from save_average_tput_file_and_download_to_testPC
    :param saved_tput_file_list: file_paths on cluster returned from start_tput_log_capturing
    :param asik_alais: asik master
    :param abil_alais: abil master
    :param abil_slave_alais: abil slave
    :return:
    """
    feature1514_flag = stream_manager.feature_1514_opened(connection=asik_alais)
    dict_file_paths_based_on_component = _get_component_name_based_on_captured_log_name(
        saved_tput_file_list=saved_tput_file_list)
    for component in dict_file_paths_based_on_component.keys():
        if component == 'L2LO':
            connection = abil_slave_alais if feature1514_flag is True else abil_alais
        elif component == 'L2HI':
            connection = abil_alais if feature1514_flag is True else asik_alais
        else:
            raise Exception("Unsupported component {} and invalid flag {}".format(component, feature1514_flag))
        ssh.send_command(command='killall journalctl', connection=connection)


def download_tput_files(saved_tput_file_list, download_dir,
                        asik_alais='ASIK Master', abil_alais='ABIL Master', abil_index='1', duration=None,
                        abil_slave_alais='ABIL Slave'):
    """
    Method split from save_average_tput_file_and_download_to_testPC
    :param saved_tput_file_list: Value returned from start_tput_log_capturing
    :param download_dir: path on testPC
    :param asik_alais: asik master
    :param abil_alais: abil master
    :param abil_slave_alais: abil slave
    :param abil_index: <str>,abil blade index , count from 1
    :param duration: Should be in sec unit. if None, then download file name will not include such info
    :return: <dict>, download files on testpc ,  keys can be UL_L2HI, UL_L2LO, DL_L2HI, DL_L2LO
                    eg:{'UL_L2LO': '/root/workspace/CIT/Master/Case_Logs/5G19A_FSMK_0006_028352_000193/TS_Demo/
                    TC_Check_Multi_Tput_On_gNB/Tput_UL_L2LO_30sec_20191126110505.txt',
                    'DL_L2LO': '/root/workspace/CIT/Master/Case_Case_Logs/5G19A_FSMK_0006_028352_000193/TS_Demo/
                    TC_Check_Multi_Tput_On_gNB/Tput_DL_L2LO_30sec_20191126110506.txt',
                    'UL_L2HI':'/root/workspace/CIT/Master/Case_Case_Logs/5G19A_FSMK_0006_028352_000193/TS_Demo/
                    TC_Check_Multi_Tput_On_gNB/Tput_UL_L2HI_30sec_20191126110506.txt',
                    'DL_L2HI':'/root/workspace/CIT/Master/Case_Case_Logs/5G19A_FSMK_0006_028352_000193/TS_Demo/
                    TC_Check_Multi_Tput_On_gNB/Tput_DL_L2HI_30sec_20191126110506.txt',
    """
    logging.info('saved tput file are:{}'.format(saved_tput_file_list))
    feature1514_flag = stream_manager.feature_1514_opened(connection=asik_alais)
    download_tput_file_dict = dict()
    for file in saved_tput_file_list:
        file_name = file.split('/')[-1]
        _, direction, component, _ = file_name.split('_')
        local_file_name = _get_new_file_name_with_duration_time_added(file_name=file_name, duration=duration)
        tput_local_file_path = '{}/{}'.format(download_dir, local_file_name)
        download_tput_file_dict[direction + '_' +
                                component] = tput_local_file_path
        logging.info(download_tput_file_dict)
        if component == 'L2LO':
            location = '1' if feature1514_flag is True else '0'
        elif component == 'L2HI' and feature1514_flag is True:
            location = '0'
        logging.info('start to download file from abil to asik')
        download_cmd = 'bget {}:{} {} /tmp/'.format(abil_index, location, file)
        stdout = ssh.execute(command=download_cmd, connection=asik_alais)
        if '100%' not in stdout:
            logging.error('{} not download complete from abil to asik'.format(file))
        if component == 'L2LO':
            connection = abil_slave_alais if feature1514_flag is True else abil_alais
        elif component == 'L2HI' and feature1514_flag is True:
            connection = abil_alais
        ssh.execute(command='rm -rf {}'.format(file), connection=connection)
        logging.info('start to download file from asik master to testPC')
        ssh.download_file(
            local_path=tput_local_file_path,
            remote_path=file,
            connection=asik_alais)
        ssh.execute(command='rm -rf {}'.format(file), connection=asik_alais)
    return download_tput_file_dict


def evaluate_average_tput(tput_file, expect_tput_value=None):
    """
    :param tput_file:<str>, saved tput file on tesPC
    :param expect_tput_value:optional,if need to compare tput value to expect value
    :return: <float> average_throughput

    """
    _, direction, component, duration, _ = tput_file.split('/')[-1].split('_')
    throughput_data = []
    average_throughput = None
    try:
        with open(tput_file) as f:
            logging.info(
                'start to compute avg {} tput of {}'.format(
                    direction, component))
            for line in f.readlines():
                if direction == 'UL' and component == 'L2LO':
                    if "(" in line:
                        value = line.split("(")[1].split(' ')[0].strip()
                        throughput_data.append(value)
                elif direction == 'UL' and component == 'L2HI':
                    if "In:" in line:
                        value = line.split("In:")[1].split('bytes')[0].strip()
                        throughput_data.append(value)
                elif direction == 'DL' and component == 'L2LO':
                    if "DataPdu:" in line:
                        value = line.split("DataPdu:")[1].split('|')[
                            3].split(']')[0].strip()
                        throughput_data.append(value)
                else:
                    if "In:" in line:
                        value = line.split("In:")[1].split('B')[0].strip()
                        throughput_data.append(value)
        throughput_data = map(lambda x: float(x), throughput_data)
        throughput_data = map(lambda x: x * 8 / 1024 / 1000, throughput_data)
        average_throughput = format(
            sum(throughput_data) / len(throughput_data), '.3f')
        if expect_tput_value is not None:
            assert float(average_throughput) >= float(expect_tput_value), \
                'avg {} tput of {} is {}, expect result is {}'.format(
                    direction, component, average_throughput, expect_tput_value)
    except ZeroDivisionError as e:
        logging.exception(
            'avg {} tput of {} data is not collected properly: {}'.format(direction, component, e))
        raise
    except IOError as e:
        logging.exception(
            'avg {} tput of {} data is not collected properly: {}'.format(direction, component, e))
        raise
    else:
        return average_throughput


def _get_component_name_based_on_captured_log_name(saved_tput_file_list):
    """
    Author: Ding Binmei
    Description:
    :param saved_tput_file_list: file_paths on cluster returned from start_tput_log_capturing
    :return:dict: {'L2LO':[file_path1, file_path2], 'L2HI':[file_path3, file_path4]}
    """
    dict_file_paths_based_on_component = collections.defaultdict(list)
    for file_path in saved_tput_file_list:
        file_name = file_path.split('/')[-1]
        component = file_name.split('_')[2]
        dict_file_paths_based_on_component[component].append(file_path)
    return dict_file_paths_based_on_component


def _get_new_file_name_with_duration_time_added(file_name, duration=None):
    """
    Author: Ding Binmei
    Description: Add duration time to file name if exists
    :param file_name: Tput_DL_L2LO_20200214101851.txt
    :param duration: sec
    :return: Tput_DL_L2LO_30sec_20200214101851.txt
    """
    if duration is None:
        tput_local_file_name = file_name
    else:
        component = file_name.split('_')[2]
        file_name_with_timestamp = file_name.split("_")[-1]
        file_name_before_component = file_name.split(component)[0]
        tput_local_file_name = '{}{}_{}sec_{}'.format(file_name_before_component, component, duration,
                                                      file_name_with_timestamp)
    return tput_local_file_name


def convert_l2lo_tput_format(tput_value, time_interval):
    """
    Author: Ding Binmei
    Description: Convert tput value captured from journal log to mbits/sec unit
    :param tput_value:
    :param time_interval: time_interval for log print. In seconds unit
    :return:
    """
    tput_with_mbit_format = round(float(8 * decimal.Decimal(tput_value) / 1024 / 1000 / time_interval), 3)
    return tput_with_mbit_format


def _get_nrCellIdentity_from_one_line(line_info, direction):
    """
    Author: Ding Binmei
    Description: Get nrCellIdentity from one line
    :param line_info:
    :param direction: ul/dl
    :return:
    """
    nrCellIdentity = None
    if direction == 'dl':
        if line_info.find("DataPdu") != -1:
            nrCellIdentity = int(re.split(pattern=r'\[|\s',
                                          string=line_info.split("nrCellId ")[-1])[0].strip())
    else:
        if line_info.find("nrCellIdentity") != -1:
            nrCellIdentity = int(re.split(pattern=r'#|\s',
                                          string=line_info.split("nrCellIdentity ")[-1].strip())[0].strip())
    return nrCellIdentity


def _get_time_stamp_from_one_line_based_on_nrCellIdentity(line_info, direction, nrCellIdentity):
    """
    Author: Ding Binmei
    Description: Get time stamp value from one line based on nrCellIdentity
    :param line_info:
    :param direction: ul/dl
    :param nrCellIdentity:
    :return: Get timestamp value with datetime format
    """
    timestamp = None
    if direction == 'dl':
        filter_row = "ttisFromUpdate"
        filter_cell = "nrCellId " + str(nrCellIdentity)
    else:
        filter_row = "nrCellIdentity"
        filter_cell = "nrCellIdentity " + str(nrCellIdentity)
    if line_info.find(filter_row) != -1 and line_info.find(filter_cell) != -1:
        pattern = re.compile(r'<(\d+-\d+-\w+:\d+:\d+.\w+)>')
        timestamp_str = pattern.findall(line_info)[-1]
        timestamp = datetime.datetime.strptime(timestamp_str, "%Y-%m-%dT%H:%M:%S.%fZ")
    else:
        logging.debug("Skip this row, as not able to find {} and {} from this row for {}, will remain timestamp as "
                      "None".format(filter_row, filter_cell, direction))
    return timestamp


def get_time_stamp_records_for_one_cell(tput_file, direction, record_count=10):
    """
    Author: Ding Binmei
    Description: Get timestamp value for one cell, will return with 10 records at most
    :param tput_file: file_paths on cluster returned from start_tput_log_capturing
                      Format like bellow: /XXX/XXX/Tput_UL_L2LO_20191126110505.txt
    :param direction: Available values are: None, ul, dl
                      if tput_file format is not the same format as above, then direction value must be ul/dl
    :param record_count: max record num
    :return:
    """
    direction = get_direction_by_file_name(tput_file=tput_file, direction=direction)
    record_count = int(record_count)
    try:
        with open(tput_file) as f:
            lines = f.readlines()
            first_nrCellIdentity = None
            list_time_stamp_for_first_nrCellIdentity = []
            for line in lines:
                # print("line_info:{}".format(line))
                if first_nrCellIdentity is None:
                    print("nrCellIdentity does not exist, will get the first nrCellIdentity from tput_file")
                    first_nrCellIdentity = _get_nrCellIdentity_from_one_line(line_info=line, direction=direction)
                    time_stamp = _get_time_stamp_from_one_line_based_on_nrCellIdentity(
                        line_info=line, direction=direction, nrCellIdentity=first_nrCellIdentity)
                else:
                    time_stamp = _get_time_stamp_from_one_line_based_on_nrCellIdentity(
                        line_info=line, direction=direction, nrCellIdentity=first_nrCellIdentity)
                print("first_nrCellIdentity:{}, time_stamp={}".format(first_nrCellIdentity, time_stamp))
                if time_stamp is not None:
                    list_time_stamp_for_first_nrCellIdentity.append(time_stamp)
                if len(list_time_stamp_for_first_nrCellIdentity) == record_count:
                    print("Will check for {} records in max".format(record_count))
                    break
                else:
                    continue
    except IOError as err:
        raise IOError("File Error: {}".format(err))
    else:
        f.close()
    return list_time_stamp_for_first_nrCellIdentity


def calculate_time_interval(tput_file, direction):
    """
    Author: Ding Binmei
    Description: Calculate time interval.
    Will select one cell for calculate the time interval. The max row count for calculation will be 10.
    If records in file is less than 2, then exception will be raised
    2020/05/29/Wang Yixiang: calculate the min time interval due to sometimes log item miss
    :param tput_file:
    :param direction: ul/dl
    :return: time interval for seconds
    """
    time_interval = None
    print("Start to calculate time interval from file {} for {}".format(tput_file, direction))
    list_time_stamp = get_time_stamp_records_for_one_cell(tput_file=tput_file, direction=direction)
    print("list_time_stamp:{}".format(list_time_stamp))
    count = len(list_time_stamp)
    if count >= 2:
        for i in range(1, count):
            temp_time_interval = int(round((list_time_stamp[i]-list_time_stamp[i-1]).total_seconds(), 0))
            time_interval = temp_time_interval if time_interval is None else time_interval
            if temp_time_interval < time_interval:
                time_interval = temp_time_interval
        print("time_interval for {} is: {}".format(direction, time_interval))
        return time_interval
    else:
        raise Exception("Only {} records found from {} for {}, not able to calculate time interval value".format(
            count, tput_file, direction
        ))


def _collect_l2lo_tput_data_from_file(tput_file, direction):
    """
    Author: Ding Binmei
    Description: Collect tput data from the file collected from journal/aasys log
    time_interval must be calculated for ul and dl. For ul it's static to 1s now,
    for dl it's the time gap got from log. If time_interval also need to be calculated form log, then it can call
    function calculate_time_interval the same way as dl. this function also supported for UL
    :param tput_file:
    :param direction: valid value can be: ul, dl
    :return: a dict with format: {nrCellIdentity1:[tput1, tput2], nrCellIdentity2:[tput1, tput2]}
            Example output: {16385: [0.0, 0.0], 16386: [0.0, 0.0]}
    """
    dict_tput_for_cells = collections.defaultdict(list)
    direction = get_direction_by_file_name(tput_file=tput_file, direction=direction)
    if direction == 'ul':
        time_interval = 1
        print("Time interval for ul is now static to {}, if also need to get it from log, "
              "then it must be changed".format(time_interval))
    else:
        time_interval = calculate_time_interval(tput_file=tput_file, direction=direction)
    try:
        with open(tput_file) as f:
            lines = f.readlines()

            for line in lines:
                logging.debug("line_info:{}".format(line))
                if line != lines[-1]:
                    if direction == 'ul':
                        if line.find("nrCellIdentity") != -1:
                            nrCellIdentity = int(
                                re.split(pattern=r'#|\s', string=line.split("nrCellIdentity ")[-1].strip())[0].strip())
                            tput_value_str = line.split("(")[-1].split(" ")[0].strip()
                            tput_value = convert_l2lo_tput_format(tput_value=tput_value_str,
                                                                  time_interval=time_interval)
                            dict_tput_for_cells[nrCellIdentity].append(tput_value)
                    elif direction == 'dl':
                        if line.find("DataPdu") != -1:
                            nrCellIdentity = int(re.split(pattern=r'\[|\s',
                                                          string=line.split("nrCellId ")[-1])[0].strip())
                            tput_value_str = line.split("DataPdu:")[-1].split('|')[3].split(']')[0].strip()
                            tput_value = convert_l2lo_tput_format(tput_value=tput_value_str,
                                                                  time_interval=time_interval)
                            dict_tput_for_cells[nrCellIdentity].append(tput_value)
                    else:
                        raise Exception("Unsupported input of direction {}, supported values are: ul, dl".format(
                            direction))
                else:
                    logging.info("Skip last line in file in case the captured log is incomplete.")
    except IOError as err:
        raise IOError("File Error: {}".format(err))
    else:
        f.close()
    return dict_tput_for_cells


def get_tput_info_for_l2lo(tput_file, direction=None):
    """
    Author: Ding Binmei
    Description: Added average tput calculation to tput info for each cell
    The log decoder is based on 19A, 19B
    :param tput_file: tput log file path for ul/dl
    :param direction: Available values are: None, ul, dl
                      if tput_file format is not the same format as above, then direction value must be ul/dl
    :return: A dict with bellow format:
        {nrCellIdentity:{'average_tput':value, 'detail_tput_info':[value1, value2,...]}}
    Example output:
        {16385: {'average_tput': 0.0, 'detail_tput_info': [0.0, 0.0, 0.0, 0.0, 0.0]},
         16386: {'average_tput': 0.0, 'detail_tput_info': [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]}
    """
    direction = get_direction_by_file_name(tput_file=tput_file, direction=direction)
    print("direction: {}".format(direction))
    dict_tput_for_cells = _collect_l2lo_tput_data_from_file(tput_file=tput_file, direction=direction)
    dict_tput_with_average_tput_info = {}
    if dict_tput_for_cells:
        for nrCellIdentity in dict_tput_for_cells.keys():
            dict_tput_info_per_cell = {"detail_tput_info": dict_tput_for_cells[nrCellIdentity]}
            if len(dict_tput_for_cells[nrCellIdentity]) == 0:
                average_tput_per_cell = "No data"
            else:
                average_tput_per_cell = round(sum(dict_tput_for_cells[nrCellIdentity]) /
                                              len(dict_tput_for_cells[nrCellIdentity]), 3)
            dict_tput_info_per_cell["average_tput"] = average_tput_per_cell
            dict_tput_with_average_tput_info[nrCellIdentity] = dict_tput_info_per_cell
        return dict_tput_with_average_tput_info
    else:
        raise Exception("No throughput data info found from file {}".format(tput_file))


def get_direction_by_file_name(tput_file, direction=None):
    """
    Author: Ding Binmei
    Description: Get direction by input file path, if direction is not filled
    :param tput_file: file_paths on cluster returned from start_tput_log_capturing
                      Format like bellow: /XXX/XXX/Tput_UL_L2LO_20191126110505.txt
    :param direction: Available values are: None, ul, dl
                      if tput_file format is not the same format as above, then direction value must be ul/dl
    :return:
    """
    if direction is not None:
        direction = direction.lower()
    else:
        logging.info("Input direction is None, will try to get direction from file name")
        file_name = tput_file.split('/')[-1]
        direction = file_name.split('_')[1].lower()
    if direction not in ['ul', 'dl']:
        raise Exception("Fail to get direction value, supported values are ul/dl. "
                        "Current value: {} is invalid".format(direction))
    else:
        return direction


def save_average_tput_file_from_aasyslog_and_download_to_testPC(download_dir, gnb_index=0,
                                                                duration=180, asik_alais='ASIK Master'):
    """
    Author: Chen Jun
    Modified by:xiangyue.zhou@nokia-sbell.com
    :param download_dir:path on testPC
    :param duration:sec
    :param asik_alais: asik master
    :return: <dict>, download files on testpc ,  keys can be UL_L2LO, DL_L2LO
                    eg:{'UL_L2LO': '/root/workspace/CIT/Master/Case_Logs/5G19A_FSMK_0006_028352_000193/TS_Demo/
                    TC_Check_Multi_Tput_On_gNB/Tput_UL_L2LO_30sec_20191126110505.txt',
                    'DL_L2LO': '/root/workspace/CIT/Master/Case_Case_Logs/5G19A_FSMK_0006_028352_000193/TS_Demo/
                    TC_Check_Multi_Tput_On_gNB/Tput_DL_L2LO_30sec_20191126110506.txt'}
    """
    saved_tput_file_path = start_tput_aasyslog_capturing(gnb_index=gnb_index, asik_alais=asik_alais)
    sleep(int(duration))
    stop_tput_aasyslog_capturing(asik_alais=asik_alais)
    tput_local_file_path = download_tput_aasyslog_files(saved_tput_file_path=saved_tput_file_path,
                                                        download_dir=download_dir, asik_alais=asik_alais,
                                                        duration=duration)
    download_tput_file_dict = get_dl_ul_tput_file_seperately_from_aasyslog(tput_local_file_path=tput_local_file_path)
    return download_tput_file_dict


def start_tput_aasyslog_capturing(gnb_index=0, asik_alais='ASIK Master'):
    """
    Author: Chen Jun
    Modified by : xiangyue.zhou@nokia-sbell.com
    Method split from save_average_tput_file_and_download_to_testPC
    :param asik_alais: asik master
    :return: file path,
    for example:'/root/workspace/CIT/Master/Case_Logs/5G19A_FSMK_0006_028352_000193/TS_Demo/
                 TC_Check_Multi_Tput_On_gNB/Tput_DL_UL_L2LO_30sec_20191126110505.txt'
    """
    tl = BuiltIn().get_variable_value("${tl}")
    host = tl.gnbs[int(gnb_index)].cu.oam_ssh_connection_details.addr
    username = tl.gnbs[int(gnb_index)].cu.oam_ssh_connection_details.username
    password = tl.gnbs[int(gnb_index)].cu.oam_ssh_connection_details.password
    aasyslog.aasyslog_realtime_output_configuration(host=host, username=username, password=password, type='mcu')
    ssh.send_command(command="ps -ef |grep 52000|grep -v grep| awk '{print $2}'|xargs kill -9",
                     connection=asik_alais)
    timestamp = datetime.datetime.now().strftime('%Y%m%d%H%M%S')
    grep_command = 'nc -u -w 100 -l 127.0.0.1 52000 | grep -aE "UlCounterUpdate|SentDataMeasurementCounting" >{} &'
    saved_tput_file_path = '/tmp/Tput_DL_UL_{}.txt'.format(timestamp)
    logging.info('save tput file path is:{}'.format(saved_tput_file_path))
    ssh.send_command(command=grep_command.format(saved_tput_file_path), connection=asik_alais)
    nc_pid = ssh.execute(command="ps -ef |grep nc|grep 52000|grep -v grep| awk '{print $2}'", connection=asik_alais)
    logging.info("----- The nc_pid is {}".format(nc_pid))
    if not nc_pid:
        raise ValueError("Failed to start the capture, the nc_pid is not exist: {}".format(nc_pid))

    return saved_tput_file_path


def get_dl_ul_tput_file_seperately_from_aasyslog(tput_local_file_path):
    """
    Author: xiangyue.zhou@nokia-sbell.com
    :param tput_local_file_path : <str> , path on testPC
    :return: {dict}, {'UL_L2LO': '/root/workspace/CIT/Master/Case_Logs/5G20A_GNB_0000_000800_000291/TS_Test/
                      TC_Test_Aasyslog/Tput_UL_L2LO_20191126110505.txt',
                      'DL_L2LO':'/root/workspace/CIT/Master/Case_Logs/5G20A_GNB_0000_000800_000291/TS_Test/
                       TC_Test_Aasyslog/Tput_DL_L2LO_20191126110506.txt'}
    """
    logging.info('saved tput file are:{}'.format(tput_local_file_path))
    timestamp = datetime.datetime.now().strftime('%Y%m%d%H%M%S')
    download_tput_file_dict = dict()
    current_dir = os.path.dirname(os.path.abspath(tput_local_file_path))
    tput_local_dl_file_path = os.path.join(current_dir, 'Tput_DL_L2LO_{}.txt'.format(timestamp))
    tput_local_ul_file_path = os.path.join(current_dir, 'Tput_UL_L2LO_{}.txt'.format(timestamp))
    tput_local_dl_file = open(tput_local_dl_file_path, "w")
    tput_local_ul_file = open(tput_local_ul_file_path, "w")
    try:
        with open(tput_local_file_path) as f:
            for line in f.readlines():
                if re.findall('UlCounterUpdate', line):
                    tput_local_ul_file.write(line+'\n')
                elif re.findall('SentDataMeasurementCounting', line):
                    tput_local_dl_file.write(line+'\n')
    except IOError as err:
        raise IOError("File Error: {}".format(err))
    else:
        f.close()
        tput_local_ul_file.close()
        tput_local_dl_file.close()
        download_tput_file_dict = {'DL_L2LO': tput_local_dl_file_path, 'UL_L2LO': tput_local_ul_file_path}
    return download_tput_file_dict


def stop_tput_aasyslog_capturing(asik_alais='ASIK Master'):
    """
    Author: Chen Jun
    Method split from save_average_tput_file_and_download_to_testPC
    :param asik_alais: asik master
    :return:
    """
    nc_pid_before_kill = ssh.execute(
        command="ps -ef |grep nc|grep 52000|grep -v grep| awk '{print $2}'",
        connection=asik_alais)
    logging.info("----- The nc_pid_before_kill is {}----".format(nc_pid_before_kill))
    ssh.send_command(command="ps -ef |grep 52000|grep -v grep| awk '{print $2}'|xargs kill -9",
                     connection=asik_alais)
    sleep(2)
    nc_pid = ssh.execute(
        command="ps -ef |grep nc|grep 52000|grep -v grep| awk '{print $2}'",
        connection=asik_alais)
    logging.info("----- The nc_pid is {}----".format(nc_pid))
    if nc_pid:
        raise ValueError("Failed to stop the capture, the nc_pid is still exist: {}".format(nc_pid))


def download_tput_aasyslog_files(saved_tput_file_path, download_dir, asik_alais='ASIK Master', duration=None):
    """
    Author: Chen Jun
    Modified by :xiangyue.zhou@nokia-sbell.com
    Method split from save_average_tput_file_and_download_to_testPC
    :param saved_tput_file_path: Value returned from start_tput_aasyslog_capturing
    :param download_dir: path on testPC
    :param asik_alais: asik master
    :param duration: Should be in sec unit. if None, then download file name will not include such info
    :return: <str>, download files on testpc ,
    For example:/root/workspace/CIT/Master/Case_Logs/5G19A_FSMK_0006_028352_000193/TS_Demo/
                TC_Check_Multi_Tput_On_gNB/Tput_DL_UL_20200430135153.txt
    """
    logging.info('saved tput file are:{}'.format(saved_tput_file_path))
    file_name = saved_tput_file_path.split('/')[-1]
    local_file_name = _get_new_file_name_with_duration_time_added(file_name=file_name, duration=duration)
    tput_local_file_path = '{}/{}'.format(download_dir, local_file_name)
    logging.info('tput_local_file_path is {}'.format(tput_local_file_path))
    ssh.download_file(local_path=tput_local_file_path, remote_path=saved_tput_file_path, connection=asik_alais)
    ssh.execute(command='rm -rf {}'.format(saved_tput_file_path), connection=asik_alais)
    return tput_local_file_path


def are_tuput_files_neither_empty(list_file_path, asik_alias="ASIK Master"):
    """
    Author: Ding Binmei
    Description: Check that if tput files for UL and DL are generated with content exist. if content exist,
    will return True, else return False
    otherwise return False
    :param list_file_path:
    :param asik_alias:
    :return:
    """
    list_file_path_with_content_empty = []
    for tput_file_path in list_file_path:
        is_tput_file_empty = ssh_common_commands.is_file_empty(file_path=tput_file_path, connection=asik_alias)
        if is_tput_file_empty:
            list_file_path_with_content_empty.append(tput_file_path)
    if list_file_path_with_content_empty:
        logging.debug(msg="Bellow files:{} with contents are empty on {}".format(list_file_path_with_content_empty,
                                                                                 asik_alias))
        return False
    else:
        return True
