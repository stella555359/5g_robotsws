import json
import logging
import os
import re
import subprocess
import sys
from asyncio import exceptions
import logging.handlers
from datetime import datetime, timedelta
from concurrent.futures import ThreadPoolExecutor
from typing import List, Dict

import aiofiles
import telnetlib3
import asyncio
import pandas as pd


class WtsFileOperation:
    def __init__(self, host='0', port=20000):
        self.host = host
        self.port = port
        self.reader = None
        self.writer = None
        # self.reader._limit = 1024 * 1024 * 1024

    async def connect(self):
        self.reader, self.writer = await telnetlib3.open_connection(
            self.host, self.port, connect_minwait=0.5)

    async def close(self):
        if self.writer:
            self.writer.close()
            # await self.writer.wait_closed()

    async def read_session_state(self):
        output = await asyncio.wait_for(self.reader.readuntil('State ACTIVE'.encode('utf-8')), timeout=10)
        print(output.decode())
        # assert 'State ACTIVE' in output

    async def set_wts_configuration_file(self, command):
        self.writer.write(f'{command}\n')
        await self.writer.drain()
        self.reader._limit = 1024 * 1024 * 1024
        try:
            output = await asyncio.wait_for(
                self.reader.readuntil('SystemInformationBlockType4-NR updated'.encode('utf-8')), timeout=300)
        except (exceptions.TimeoutError, exceptions.CancelledError) as e:
            print(e)

    async def set_x2_link_up(self, command):
        self.writer.write(f'{command}\n')
        await self.writer.drain()
        self.reader._limit = 1024 * 1024 * 1024
        try:
            output = await asyncio.wait_for(
                self.reader.readuntil('X2AP Link with'.encode('utf-8')), timeout=300)
        except (exceptions.TimeoutError, exceptions.CancelledError) as e:
            print(e)

    async def attach(self, command):
        # async def attach(self, ue_id='1'):
        #     self.writer.write(f'ue_register id={ue_id}\n')
        self.writer.write(f'{command}\n')
        await self.writer.drain()
        self.reader._limit = 1024 * 1024 * 1024
        try:
            output = await asyncio.wait_for(self.reader.readuntil('NG RM Registered state'.encode('utf-8')),
                                            timeout=10)
            # print(output.decode('utf-8'))
        except (exceptions.TimeoutError, exceptions.CancelledError) as e:
            print(e)

    async def set_pdu(self, command):
        # async def set_pdu(self, ue_id='1', pdu_id='1', qos_flow='1'):
        #     self.writer.write(
        #     f'set_pdu_param ue={ue_id} pdu={pdu_id} default_qos_flow={qos_flow} trf_type=internal\n')
        self.writer.write(f'{command}\n')
        await self.writer.drain()

    async def slice_setup(self, command):
        # async def slice_setup(self, ue_id='1', pdu_id='1', slice_id='1'):
        #     self.writer.write(f'ue_pdu_session_setup pdu={pdu_id} ue={ue_id} nwslice={slice_id}\n')
        self.writer.write(f'{command}\n')
        await self.writer.drain()
        self.reader._limit = 1024 * 1024 * 1024
        try:
            # output = await asyncio.wait_for(self.reader.readuntil('rrcReconfigurationComplete'.encode('utf-8')),
            output = await asyncio.wait_for(self.reader.readuntil('Initial Context Setup Successful'.encode('utf-8')),
                                            timeout=10)
            # print(output.decode('utf-8'))
        except (exceptions.TimeoutError, exceptions.CancelledError) as e:
            print(e)

    async def make_traffic(self, command):
        # async def make_traffic(self, ue_id='1', pdu_id='1', qos_flow='1', **kwargs):
        # paras = ' '.join(f'{key}={value}'
        #                  for key, value in kwargs.items()
        #                  if key is not None
        #                  )
        # traffic_command = f'trf_data_start ue={ue_id} pdu={pdu_id} qfi={qos_flow} {paras}\n'
        # self.writer.write(traffic_command)
        self.writer.write(f'{command}\n')
        await self.writer.drain()

    async def stop_traffic(self, command):
        # async def stop_traffic(self, ue_id='1', pdu_id='1', qos_flow='1', **kwargs):
        #     paras = ' '.join(f'{key}={value}'
        #                      for key, value in kwargs.items()
        #                      if key is not None
        #                      )
        #     stop_traffic_command = f'trf_data_stop ue={ue_id} pdu={pdu_id} qfi={qos_flow} {paras}\n'
        #     self.writer.write(stop_traffic_command)
        self.writer.write(f'{command}\n')
        await self.writer.drain()

    async def release_pdu(self, command):
        # async def release_pdu(self, ue_id='1', pdu_id='1'):
        #     self.writer.write(f'ue_pdu_session_release ue={ue_id} pdu={pdu_id}\n')
        self.writer.write(f'{command}\n')
        await self.writer.drain()
        self.reader._limit = 1024 * 1024 * 1024
        try:
            output = await asyncio.wait_for(self.reader.readuntil('Successfully released PDU Session'.encode('utf-8')),
                                            timeout=10)
            # print(output.decode('utf-8'))
        except (exceptions.TimeoutError, exceptions.CancelledError) as e:
            print(e)

    async def detach(self, command):
        # async def detach(self, ue_id='1'):
        #     self.writer.write(f'ue_deregister id={ue_id} ue_deregister_type=switch_off by=ue')
        self.writer.write(f'{command}\n')
        await self.writer.drain()
        self.reader._limit = 1024 * 1024 * 1024
        try:
            output = await asyncio.wait_for(self.reader.readuntil('detached'.encode('utf-8')),
                                            timeout=10)
            # print(output.decode('utf-8'))
        except (exceptions.TimeoutError, exceptions.CancelledError) as e:
            print(e)

    async def execute_required_command(self, command, regexp):
        self.writer.write(f'{command}\n')
        await self.writer.drain()
        self.reader._limit = 1024 * 1024 * 1024
        try:
            # output = await asyncio.wait_for(self.reader.readuntil('detached'.encode('utf-8')), timeout=10)
            output = await asyncio.wait_for(self.reader.read(), timeout=10)
            regexp_pattern = re.compile(pattern=regexp)
            result = regexp_pattern.match(string=output.decode('utf-8'))
            print(f'result: {result.group()}')
            print(f"output: {output.decode('utf-8')}")
        except (exceptions.TimeoutError, exceptions.CancelledError) as e:
            print(e)


async def execute_required_commands_on_egate(commands, regexp):
    wts = WtsFileOperation()
    await wts.connect()
    for command in commands:
        await wts.execute_required_command(command, regexp)
    await wts.close()


def execute_required_commands(commands, regexp):
    asyncio.run(execute_required_commands_on_egate(commands=commands, regexp=regexp))


async def execute_read_session_state_egate_commands():
    wts = WtsFileOperation()
    await wts.connect()
    await wts.read_session_state()
    await wts.close()


def execute_read_session_state():
    asyncio.run(execute_read_session_state_egate_commands())


async def execute_set_wts_configuration_file_egate_commands(command):
    wts = WtsFileOperation()
    await wts.connect()
    await wts.set_wts_configuration_file(command)
    await wts.close()


async def execute_set_x2_link_up_commands(command):
    wts = WtsFileOperation()
    await wts.connect()
    await wts.set_x2_link_up(command)
    await wts.close()


def execute_set_wts_configuration_file(command):
    asyncio.run(execute_set_wts_configuration_file_egate_commands(command=command))


def execute_set_x2_link_up(command):
    asyncio.run(execute_set_x2_link_up_commands(command=command))


async def execute_attach_egate_commands(commands):
    wts = WtsFileOperation()
    await wts.connect()
    for command in commands:
        await wts.attach(command)
    await wts.close()


def execute_attach(commands):
    asyncio.run(execute_attach_egate_commands(commands=commands))


async def execute_set_pdu_egate_commands(commands):
    wts = WtsFileOperation()
    await wts.connect()
    for command in commands:
        await wts.set_pdu(command)
    await wts.close()


def execute_set_pdu(commands):
    asyncio.run(execute_set_pdu_egate_commands(commands=commands))


async def execute_slice_setup_egate_commands(commands):
    wts = WtsFileOperation()
    await wts.connect()
    for command in commands:
        await wts.slice_setup(command)
    await wts.close()


def execute_slice_setup(commands):
    asyncio.run(execute_slice_setup_egate_commands(commands=commands))


async def execute_make_traffic_egate_commands(commands):
    wts = WtsFileOperation()
    await wts.connect()
    for command in commands:
        await wts.make_traffic(command)
        await asyncio.sleep(1)
    await wts.close()


def execute_make_traffic(commands):
    asyncio.run(execute_make_traffic_egate_commands(commands=commands))


async def execute_stop_traffic_egate_commands(commands):
    wts = WtsFileOperation()
    await wts.connect()
    for command in commands:
        await wts.stop_traffic(command)
    await wts.close()


def execute_stop_traffic(commands):
    asyncio.run(execute_stop_traffic_egate_commands(commands=commands))


async def execute_release_pdu_egate_commands(commands):
    wts = WtsFileOperation()
    await wts.connect()
    for command in commands:
        await wts.release_pdu(command)
    await wts.close()


def execute_release_pdu(commands):
    asyncio.run(execute_release_pdu_egate_commands(commands=commands))


async def execute_detach_egate_commands(commands):
    wts = WtsFileOperation()
    await wts.connect()
    for command in commands:
        await wts.detach(command)
    await wts.close()


def execute_detach(commands):
    asyncio.run(execute_detach_egate_commands(commands=commands))


class AnalysisSyslog:
    def __init__(self, files_path, log_name, syslog_files, log_path):
        # files_path = '/opt/workspace/CRT/Master/Case_Logs/'
        self.all_files = [os.path.join(files_path, file_name) for file_name in syslog_files.split(",")]
        # 1. Set up logging
        log_path = os.path.join(log_path, f'{log_name}.log')
        print(log_path)
        self.my_logger = logging.getLogger(log_path)
        self.my_logger.setLevel(logging.DEBUG)
        # 2. Create a file handler
        file_handler = logging.handlers.RotatingFileHandler(filename=log_path, mode='wb', maxBytes=20 * 1024 * 1024,
                                                            encoding='utf-8')
        # 3. Set the logging level for file handler
        file_handler.setLevel(logging.DEBUG)
        # 4. Create a formatter and set it for file handler
        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        file_handler.setFormatter(formatter)
        # 5. Add file handler to the logger
        self.my_logger.addHandler(file_handler)

    async def analyze_log_file(self, file_path, search_str="ERR/"):
        async with aiofiles.open(file_path, mode='r') as file:
            content = await file.readlines()
            for line in content:
                if search_str in line:
                    self.my_logger.info(f"found in {file_path}: {line.strip()}")

    async def run_script(self, search_str="ERR/"):
        tasks = [self.analyze_log_file(file, search_str) for file in self.all_files]
        await asyncio.gather(*tasks)


async def execute_and_generate_log_file(files_path, log_name, syslog_files, analysis_str, log_path):
    as_instance = AnalysisSyslog(files_path=files_path, log_name=log_name,
                                 syslog_files=syslog_files, log_path=log_path)
    await as_instance.run_script(search_str=analysis_str)


def run_and_generate_log_file(files_path, log_name, syslog_files, analysis_str, log_path):
    asyncio.run(execute_and_generate_log_file(files_path, log_name, syslog_files, analysis_str, log_path))


def get_traffic_info(log_file):
    with open(log_file, 'r') as f:
        contents = f.readlines()
    traffic_TBS = []
    # print(contents[0].split('[TBS')[1].split(':')[1].split('|')[0].strip())
    for content in contents:
        if int(content.split('[TBS')[1].split(':')[1].split('|')[0].strip()) != 0:
            traffic_TBS.append(int(content.split('[TBS')[1].split(':')[1].split('|')[0].strip()))
    traffic_num = len(traffic_TBS)
    print(traffic_num)
    total_traffic = sum(traffic_TBS)
    print(total_traffic)
    if traffic_num == 0:
        raise 'no traffic str is got'
    else:
        avg_traffic = (total_traffic / traffic_num) * 8 / 1024 / 1024
    return avg_traffic


def install_package(package, proxy='--proxy=http://10.144.1.10:8080'):
    """
    Install package library using pip

    Returns:
        bool: True if installation succeeded, False otherwise
    """
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", package, proxy])
        print(f"{package} installed successfully!")
    except subprocess.CalledProcessError:
        print(f"Failed to install {package}")
        raise subprocess.CalledProcessError


def excel_sheet_to_json(excel_path, sheet_name, json_path='output.json'):
    """
    Convert specified Excel sheet to JSON file

    Args:
        excel_path (str): Path to Excel file
        sheet_name (str): Name of sheet to convert
        json_path (str, optional): Output JSON file path. Defaults to 'output.json'
    """
    try:
        # install_package(package='pandas')
        # import pandas as pd
        # Read specified sheet
        df = pd.read_excel(excel_path, sheet_name=sheet_name)

        # Convert to JSON format (records orientation)
        json_data = df.to_json(orient='records', force_ascii=False)

        # Write JSON file
        with open(json_path, 'w', encoding='utf-8') as f:
            f.write(json_data)

        print(f"Conversion successful! Sheet '{sheet_name}' saved as {json_path}")

    except Exception as e:
        print(f"Conversion failed: {str(e)}")


def get_required_kpi_value(kpis: List, times: List, distnames: list, json_path='output.json'):
    with open(json_path, 'r') as file:
        kpi_data = json.load(file)
    info_result = []
    for data in kpi_data:
        for kpi in kpis:
            for t in times:
                for distname in distnames:
                    if kpi in data['EntryName'] and distname in data['DistName'] and t == data['TimeStamp']:
                        # print(kpi, t, distname, data['Value'])
                        info = {kpi: {t: {distname: data['Value']}}}
                        info_result.append(info)
    print(info_result)
    return info_result


def get_check_kpi_value(kpi_values, kpi_name, timestamp, distname):
    for value in kpi_values:
        if kpi_name in value:
            timestamp_dict = value[kpi_name]
            if timestamp in timestamp_dict:
                distname_dict = timestamp_dict[timestamp]
                if distname in distname_dict:
                    return distname_dict[distname]
    return None


def get_kpi_value(kpi_name, dist_name, timestamp, json_path='output.json'):
    with open(json_path, 'r') as file:
        kpi_data = json.load(file)
    required_kpi_data = ""
    for kpi in kpi_data:
        if kpi_name in kpi['EntryName'] and dist_name in kpi['DistName'] and timestamp == kpi['TimeStamp']:
            required_kpi_data = kpi['Value']
    print(f"{kpi_name}: {required_kpi_data}")
    return required_kpi_data


def get_related_kpis(kpi_names, dist_names, timestamps, json_path='output.json'):
    kpi_data_list = []
    with ThreadPoolExecutor(max_workers=40) as executor:
        futures = [executor.submit(get_kpi_value, kpi_name, dist_names[index], timestamps[index], json_path) for
                   index, kpi_name in enumerate(kpi_names)]
        for future in futures:
            try:
                kpi_data = future.result()  # Wait for the thread to complete
                kpi_data_list.append(kpi_data)
            except Exception as e:
                print(f'Error occurred: {e}')
    return kpi_data_list


# def get_related_kpis(kpi_name, dist_name, timestamp, json_path='output.json', **kwargs):
#     kpis = get_kpi_value(kpi_name=kpi_name, dist_name=dist_name, timestamp=timestamp, json_path=json_path)
#     record = {}
#     for key, value in kwargs.items():
#         for kpi in kpis:
#             record[key] = kpi['Value']
#     return record


def set_diff_tput_variable(dl_tput, ul_tput):
    schedulWeight = [20, 10, 5, 1]
    dl_diff_tput_1 = [int(dl_tput * 0.45 * i / 36) for i in schedulWeight]
    dl_diff_tput_2 = [int(dl_tput * 0.55 * i / 36) for i in schedulWeight]
    check_dl_diff_tput = dl_diff_tput_1 + dl_diff_tput_2
    real_check_dl_diff_tput = [i * 0.65 for i in check_dl_diff_tput]
    dl_diff_tput = [str(i) + 'M' for i in check_dl_diff_tput]
    print(check_dl_diff_tput)
    print(dl_diff_tput)
    ul_diff_tput_1 = [int(ul_tput * 0.45 * i / 36) for i in schedulWeight]
    ul_diff_tput_2 = [int(ul_tput * 0.55 * i / 36) for i in schedulWeight]
    check_ul_diff_tput = ul_diff_tput_1 + ul_diff_tput_2
    ul_diff_tput = [i * 1000 for i in check_ul_diff_tput]
    real_check_ul_diff_tput = [float(tput) * 0.6 for tput in check_ul_diff_tput]
    print(check_ul_diff_tput)
    print(ul_diff_tput)
    print(real_check_ul_diff_tput)
    return dl_diff_tput, real_check_dl_diff_tput, ul_diff_tput, real_check_ul_diff_tput


def round_datetime_advance(target_time=None):
    if target_time is None:
        target_time = datetime.now()
    # floor
    total_minutes = target_time.hour * 60 + target_time.minute
    floor_minutes = (total_minutes // 10) * 10
    floor_time = target_time.replace(hour=floor_minutes // 60, minute=floor_minutes % 60, second=0, microsecond=0)

    # ceiling
    ceil_minutes = ((total_minutes + 9) // 10) * 10
    ceil_time = target_time.replace(hour=ceil_minutes // 60, minute=ceil_minutes % 60, second=0, microsecond=0)

    print(f"floor: {format_datetime(floor_time)}")
    print(f"ceiling: {format_datetime(ceil_time)}")


def round_datetime(target_time=None, round_to_minutes=5):
    """
    Round the time to the specified minute interval
    Args:
        target_time: Target time, default to current time
        round_to_minutes: The rounded minute interval is set to 10 minutes by default
    Returns:
        datetime: The time object after rounding
    """
    if target_time is None:
        target_time = datetime.now()
    # Calculate total minutes
    total_minutes = target_time.hour * 60 + target_time.minute
    # Calculate the minutes after rounding
    rounded_minutes = (total_minutes // round_to_minutes) * round_to_minutes
    # Building a new time object
    rounded_time = target_time.replace(
        hour=rounded_minutes // 60,
        minute=rounded_minutes % 60,
        second=0,
        microsecond=0
    )
    return rounded_time


def format_datetime(dt, format_str="%Y-%m-%d %H:%M:%S"):
    """Format time output"""
    return dt.strftime(format_str)


def get_required_record_time(required_time=None, round_to_minutes=5):
    # current_time = datetime.now()
    rounded_current = round_datetime(required_time, round_to_minutes)
    # required_record_time = format_datetime(rounded_current)
    # print(f"required_time: {format_datetime(current_time)}")
    # print(f"Round up to {round_to_minutes} minutes: {format_datetime(rounded_current)}")
    # return required_record_time
    # return int(rounded_current.timestamp() * 1000)
    return rounded_current.timestamp() * 1000


def get_kpi_excel_data(excel_path,
                       sheet_name='Chart Data',
                       header=0,
                       usecols=None):
    # install_package(package='pandas')
    # import pandas
    df = pd.read_excel(io=excel_path,
                       sheet_name=sheet_name,
                       header=header,
                       usecols=usecols)
    # print(df)
    return df


def check_required_kpi_value(df,
                             distname: str,
                             entryname: str,
                             timestamp_1: int,
                             timestamp_2: int,
                             ):
    """
    Args:
        df: Dataframe
        distname: 7_5_UTE5G402Txxx/NRCELL-3
        entryname: NR_5259a
        timestamp_1: 1766032800000
        timestamp_2: 1766034000000

    Returns: [180.169368, 180.209072, 180.291672], 540.670112

    """
    # install_package(package='pandas')
    # import pandas
    df['TimeStamp'] = pd.to_datetime(df['TimeStamp'])

    time_1 = pd.to_datetime(timestamp_1, unit='ms')
    time_2 = pd.to_datetime(timestamp_2, unit='ms')

    result = df.query(
        f"DistName == '{distname}' and EntryName.str.contains('{entryname}') and "
        f"'{time_1}' <= TimeStamp < '{time_2}'")

    # return result['Value'].tolist(), result['Value'].sum()
    return result['Value'].sum()
