import subprocess
from concurrent.futures import ThreadPoolExecutor

from taf.transport.ssh import ssh
import taf.hw.rf_attenuator as att
import yaml
from robot.libraries.BuiltIn import BuiltIn

import asyncio
import aiofiles
import re
import os
import time
from typing import List, Tuple, Set, Dict, Any, Pattern
import logging

from pathlib import Path

tl = BuiltIn().get_variable_value('${tl}')
# 1. Set up logging
log_path = os.path.join('/tmp/', 'ping_pang_common.log')
my_logger = logging.getLogger(log_path)
my_logger.setLevel(logging.DEBUG)
# 2. Create a file handler and a console handler
file_handler = logging.FileHandler(log_path, mode='w')
# console_handler = logging.StreamHandler()
# 3. Set the logging level for handlers
file_handler.setLevel(logging.DEBUG)
# console_handler.setLevel(logging.DEBUG)
# 4. Create a formatter and set it for both handlers
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
file_handler.setFormatter(formatter)
# console_handler.setFormatter(formatter)
# 5. Add the handlers to the logger
my_logger.addHandler(file_handler)


# my_logger.addHandler(console_handler)


def get_info_from_file(file_path):
    with open(file_path, "r") as f:
        test_info = yaml.safe_load(f)
    return test_info


def make_vonr_call(ue_index, phone_num='6688'):
    sn = tl.ues[ue_index].serial_number
    alias = f'cpc_{ue_index}'
    csn = ssh()
    try:
        csn.connect_to(
            hostname=tl.ues[ue_index].ssh_connection_details.addr,
            username=tl.ues[ue_index].ssh_connection_details.username,
            password=tl.ues[ue_index].ssh_connection_details.password,
            alias=alias,
            timeout=60
        )
        time.sleep(3)
        csn.execute(command=f'adb -s {sn} shell am start -a android.intent.action.CALL tel:+{phone_num}',
                    connection=alias)
        my_logger.info(f'adb -s {sn} shell am start -a android.intent.action.CALL tel:+{phone_num}')
        time.sleep(1)
    except Exception as e:
        print(e)
        my_logger.error(f'make_vonr_call: ue_index: {ue_index}: {e}')
    finally:
        csn.disconnect(connection=alias)


def make_vonr_calls(ue_index_list, mt_phone_num_list):
    with ThreadPoolExecutor(max_workers=40) as executor:
        futures = [executor.submit(make_vonr_call, ue_index, mt_phone_num_list[index]) for index, ue_index in
                   enumerate(ue_index_list)]
        for future in futures:
            try:
                future.result()  # Wait for the thread to complete
            except Exception as e:
                print(f'Error occurred: {e}')


def dial_num_to_make_voice_or_video_call(mo_ue_index, mt_phone_num):
    sn = tl.ues[mo_ue_index].serial_number
    alias = f'cpc_{mo_ue_index}'
    csn = ssh()
    try:
        MAX_CONNECT_RETRIES = 5
        RETRY_DELAY_SECONDS = 5
        for attempt in range(1, MAX_CONNECT_RETRIES + 1):
            try:
                csn.connect_to(
                    hostname=tl.ues[mo_ue_index].ssh_connection_details.addr,
                    username=tl.ues[mo_ue_index].ssh_connection_details.username,
                    password=tl.ues[mo_ue_index].ssh_connection_details.password,
                    alias=alias,
                    timeout=60
                )
                my_logger.info(f"UE {mo_ue_index}: Successfully connected on attempt {attempt}.")
                break
            except Exception as e:
                my_logger.warning(f"UE {mo_ue_index}: Connection attempt {attempt} failed: {e}")
                if attempt < MAX_CONNECT_RETRIES:
                    my_logger.info(f"UE {mo_ue_index}: Retrying in {RETRY_DELAY_SECONDS} seconds...")
                    time.sleep(RETRY_DELAY_SECONDS)
                else:
                    my_logger.error(
                        f"UE {mo_ue_index}: All {MAX_CONNECT_RETRIES} connection attempts failed. Giving up.")
                    raise
        time.sleep(3)
        brand = csn.execute(command=f'adb -s {sn} shell getprop ro.product.brand', connection=alias)
        my_logger.info(f'adb -s {sn} shell getprop ro.product.brand')
        if 'samsung' in brand:
            home_key_event = '3'
        is_awake = csn.execute(command=f'adb -s {sn} shell dumpsys window | grep mAwake', connection=alias)
        my_logger.info(f'adb -s {sn} shell dumpsys window | grep mAwake')
        if 'mAwake=false' in is_awake:
            csn.execute(command=f'adb -s {sn} shell input keyevent {home_key_event}', connection=alias)
            my_logger.info(f'adb -s {sn} shell input keyevent {home_key_event}')
            time.sleep(2)
            csn.execute(command=f'adb -s {sn} shell input swipe 500 2050 500 800', connection=alias)
            my_logger.info(f'adb -s {sn} shell input swipe 500 2050 500 800')
            time.sleep(2)
        if 'samsung' in brand:
            csn.execute(command=f'adb -s {sn} shell input tap 302 2108', connection=alias)
            my_logger.info(f'adb -s {sn} shell input tap 302 2108')
            time.sleep(2)
            csn.execute(command=f'adb -s {sn} shell am start -a android.intent.action.DIAL tel:+86{mt_phone_num}',
                        connection=alias)
            my_logger.info(f'adb -s {sn} shell am start -a android.intent.action.DIAL tel:+86{mt_phone_num}')
            time.sleep(2)
            csn.execute(command=f'adb -s {sn} shell input tap 538 1959', connection=alias)
            my_logger.info(f'adb -s {sn} shell input tap 538 1959')
    except Exception as e:
        print(e)
        my_logger.error(f'dial_num_to_make_voice_or_video_call: ue_index: {mo_ue_index}: {e}')
    finally:
        csn.disconnect(connection=alias)


def answer_voice_or_video_call(mt_ue_index):
    sn = tl.ues[mt_ue_index].serial_number
    alias = f'cpc_{mt_ue_index}'
    csn = ssh()
    try:
        MAX_CONNECT_RETRIES = 5
        RETRY_DELAY_SECONDS = 5
        for attempt in range(1, MAX_CONNECT_RETRIES + 1):
            try:
                csn.connect_to(
                    hostname=tl.ues[mt_ue_index].ssh_connection_details.addr,
                    username=tl.ues[mt_ue_index].ssh_connection_details.username,
                    password=tl.ues[mt_ue_index].ssh_connection_details.password,
                    alias=alias,
                    timeout=60
                )
                my_logger.info(f"UE {mt_ue_index}: Successfully connected on attempt {attempt}.")
                break
            except Exception as e:
                my_logger.warning(f"UE {mt_ue_index}: Connection attempt {attempt} failed: {e}")
                if attempt < MAX_CONNECT_RETRIES:
                    my_logger.info(f"UE {mt_ue_index}: Retrying in {RETRY_DELAY_SECONDS} seconds...")
                    time.sleep(RETRY_DELAY_SECONDS)
                else:
                    my_logger.error(
                        f"UE {mt_ue_index}: All {MAX_CONNECT_RETRIES} connection attempts failed. Giving up.")
                    raise
        time.sleep(2)
        brand = csn.execute(command=f'adb -s {sn} shell getprop ro.product.brand', connection=alias)
        my_logger.info(f'adb -s {sn} shell getprop ro.product.brand')
        # if 'samsung' in brand:
        #     home_key_event = '3'
        # is_awake = csn.execute(command=f'adb -s {sn} shell dumpsys window | grep mAwake', connection=alias)
        # my_logger.info(f'adb -s {sn} shell dumpsys window | grep mAwake')
        # if 'mAwake=false' in is_awake:
        #     csn.execute(command=f'adb -s {sn} shell input keyevent {home_key_event}', connection=alias)
        #     my_logger.info(f'adb -s {sn} shell input keyevent {home_key_event}')
        #     time.sleep(2)
        #     csn.execute(command=f'adb -s {sn} shell input swipe 500 2050 500 800', connection=alias)
        #     my_logger.info(f'adb -s {sn} shell input swipe 500 2050 500 800')
        #     time.sleep(2)
        if 'samsung' in brand:
            time.sleep(2)
            # csn.execute(command=f'adb -s {sn} shell input tap 538 1959', connection=alias)
            # my_logger.info(f'adb -s {sn} shell input tap 538 1959')
            csn.execute(command=f'adb -s {sn} shell input swipe 538 1959 538 800', connection=alias)
            my_logger.info(f'adb -s {sn} shell input swipe 538 1959 538 800')
    except Exception as e:
        print(e)
        my_logger.error(f'answer_voice_or_video_call: ue_index: {mt_ue_index}: {e}')
    finally:
        csn.disconnect(connection=alias)


def make_vonr_or_vinr_call_together(mo_ue_index, mt_phone_num, mt_ue_index):
    dial_num_to_make_voice_or_video_call(mo_ue_index=mo_ue_index, mt_phone_num=mt_phone_num)
    answer_voice_or_video_call(mt_ue_index=mt_ue_index)


def make_vonr_or_vinr_calls_together(mo_ue_index_list, mt_ue_index_list, mt_phone_num_list):
    with ThreadPoolExecutor(max_workers=40) as executor:
        futures = [executor.submit(make_vonr_or_vinr_call_together, mo_ue_index, mt_ue_index_list[index],
                                   mt_phone_num_list[index]) for index, mo_ue_index in enumerate(mo_ue_index_list)]
        for future in futures:
            try:
                future.result()  # Wait for the thread to complete
            except Exception as e:
                print(f'Error occurred: {e}')


def hang_up_vonr_call(ue_index):
    sn = tl.ues[ue_index].serial_number
    alias = f'cpc_{ue_index}'
    csn = ssh()
    try:
        csn.connect_to(
            hostname=tl.ues[ue_index].ssh_connection_details.addr,
            username=tl.ues[ue_index].ssh_connection_details.username,
            password=tl.ues[ue_index].ssh_connection_details.password,
            alias=alias,
            timeout=60
        )
        time.sleep(3)
        csn.execute(command=f'adb -s {sn} shell input keyevent 6', connection=alias)
        my_logger.info(f'adb -s {sn} shell input keyevent 6')
        time.sleep(1)
    except Exception as e:
        print(e)
        my_logger.error(f'hang_up_vonr_call: ue_index: {ue_index}: {e}')
    finally:
        csn.disconnect(connection=alias)


def hang_up_vonr_calls(ue_index_list):
    with ThreadPoolExecutor(max_workers=40) as executor:
        futures = [executor.submit(hang_up_vonr_call, ue_index) for ue_index in ue_index_list]
        for future in futures:
            try:
                future.result()  # Wait for the thread to complete
            except Exception as e:
                print(f'Error occurred: {e}')


def make_emc_call(ue_index):
    sn = tl.ues[ue_index].serial_number
    alias = f'cpc_{ue_index}'
    csn = ssh()
    try:
        MAX_CONNECT_RETRIES = 5
        RETRY_DELAY_SECONDS = 5
        for attempt in range(1, MAX_CONNECT_RETRIES + 1):
            try:
                csn.connect_to(
                    hostname=tl.ues[ue_index].ssh_connection_details.addr,
                    username=tl.ues[ue_index].ssh_connection_details.username,
                    password=tl.ues[ue_index].ssh_connection_details.password,
                    alias=alias,
                    timeout=60
                )
                my_logger.info(f"UE {ue_index}: Successfully connected on attempt {attempt}.")
                break
            except Exception as e:
                my_logger.warning(f"UE {ue_index}: Connection attempt {attempt} failed: {e}")
                if attempt < MAX_CONNECT_RETRIES:
                    my_logger.info(f"UE {ue_index}: Retrying in {RETRY_DELAY_SECONDS} seconds...")
                    time.sleep(RETRY_DELAY_SECONDS)
                else:
                    my_logger.error(f"UE {ue_index}: All {MAX_CONNECT_RETRIES} connection attempts failed. Giving up.")
                    raise
        time.sleep(3)
        brand = csn.execute(command=f'adb -s {sn} shell getprop ro.product.brand', connection=alias)
        my_logger.info(f'adb -s {sn} shell getprop ro.product.brand')
        if 'samsung' in brand:
            home_key_event = '3'
        elif 'qti' in brand:
            home_key_event = '82'
        elif 'motorola' in brand:
            home_key_event = '82'
        is_awake = csn.execute(command=f'adb -s {sn} shell dumpsys window | grep mAwake', connection=alias)
        my_logger.info(f'adb -s {sn} shell dumpsys window | grep mAwake')
        if 'mAwake=false' in is_awake:
            csn.execute(command=f'adb -s {sn} shell input keyevent {home_key_event}', connection=alias)
            my_logger.info(f'adb -s {sn} shell input keyevent {home_key_event}')
            time.sleep(2)
            csn.execute(command=f'adb -s {sn} shell input swipe 500 2050 500 800', connection=alias)
            my_logger.info(f'adb -s {sn} shell input swipe 500 2050 500 800')
            time.sleep(2)
        if 'samsung' in brand:
            csn.execute(command=f'adb -s {sn} shell input tap 302 2108', connection=alias)
            my_logger.info(f'adb -s {sn} shell input tap 302 2108')
            time.sleep(2)
            csn.execute(command=f'adb -s {sn} shell am start -a android.intent.action.CALL tel:911',
                        connection=alias)
            my_logger.info(f'adb -s {sn} shell am start -a android.intent.action.CALL tel:911')
            time.sleep(2)
            csn.execute(command=f'adb -s {sn} shell input tap 538 1959', connection=alias)
            my_logger.info(f'adb -s {sn} shell input tap 538 1959')
        elif 'qti' in brand:
            csn.execute(command=f'adb -s {sn} shell am start -a android.intent.action.DIAL', connection=alias)
            my_logger.info(f'adb -s {sn} shell am start -a android.intent.action.DIAL')
            time.sleep(2)
            csn.execute(command=f'adb -s {sn} shell input text 911', connection=alias)
            my_logger.info(f'adb -s {sn} shell input text 911')
            time.sleep(2)
            csn.execute(command=f'adb -s {sn} shell input tap 711 2952', connection=alias)
            my_logger.info(f'adb -s {sn} shell input tap 711 2952')
        time.sleep(1)
    except Exception as e:
        print(e)
        my_logger.error(f'make_emc_call: ue_index: {ue_index}: {e}')
    finally:
        csn.disconnect(connection=alias)


def make_emc_calls(ue_index_list):
    with ThreadPoolExecutor(max_workers=40) as executor:
        futures = [executor.submit(make_emc_call, ue_index) for ue_index in ue_index_list]
        for future in futures:
            try:
                future.result()  # Wait for the thread to complete
            except Exception as e:
                print(f'Error occurred: {e}')


def hang_up_emc_call(ue_index):
    sn = tl.ues[ue_index].serial_number
    alias = f'cpc_{ue_index}'
    csn = ssh()
    try:
        csn.connect_to(
            hostname=tl.ues[ue_index].ssh_connection_details.addr,
            username=tl.ues[ue_index].ssh_connection_details.username,
            password=tl.ues[ue_index].ssh_connection_details.password,
            alias=alias,
            timeout=60
        )
        time.sleep(3)
        brand = csn.execute(command=f'adb -s {sn} shell getprop ro.product.brand', connection=alias)
        my_logger.info(f'adb -s {sn} shell getprop ro.product.brand')
        if 'samsung' in brand:
            home_key_event = '3'
        elif 'qti' in brand:
            home_key_event = '82'
        is_awake = csn.execute(command=f'adb -s {sn} shell dumpsys window | grep mAwake', connection=alias)
        my_logger.info(f'adb -s {sn} shell dumpsys window | grep mAwake')
        if 'mAwake=false' in is_awake:
            csn.execute(command=f'adb -s {sn} shell input keyevent {home_key_event}', connection=alias)
            my_logger.info(f'adb -s {sn} shell input keyevent {home_key_event}')
            time.sleep(2)
            csn.execute(command=f'adb -s {sn} shell input swipe 500 2050 500 800', connection=alias)
            my_logger.info(f'adb -s {sn} shell input swipe 500 2050 500 800')
            time.sleep(2)
        if 'samsung' in brand:
            csn.execute(command=f'adb -s {sn} shell input tap 302 2108', connection=alias)
            my_logger.info(f'adb -s {sn} shell input tap 302 2108')
            time.sleep(2)
            csn.execute(command=f'adb -s {sn} shell input tap 538 1959', connection=alias)
            my_logger.info(f'adb -s {sn} shell input tap 538 1959')
        elif 'qti' in brand:
            csn.execute(command=f'adb -s {sn} shell input tap 711 2752', connection=alias)
            my_logger.info(f'adb -s {sn} shell input tap 711 2752')
        time.sleep(1)
    except Exception as e:
        print(e)
        my_logger.error(f'hang_up_emc_call: ue_index: {ue_index}: {e}')
    finally:
        csn.disconnect(connection=alias)


def hang_up_emc_calls(ue_index_list):
    with ThreadPoolExecutor(max_workers=40) as executor:
        futures = [executor.submit(hang_up_emc_call, ue_index) for ue_index in ue_index_list]
        for future in futures:
            try:
                future.result()  # Wait for the thread to complete
            except Exception as e:
                print(f'Error occurred: {e}')


def check_voice_call(ue_index, state_code=2):
    sn = tl.ues[ue_index].serial_number
    alias = f'cpc_{ue_index}'
    csn = ssh()
    try:
        csn.connect_to(
            hostname=tl.ues[ue_index].ssh_connection_details.addr,
            username=tl.ues[ue_index].ssh_connection_details.username,
            password=tl.ues[ue_index].ssh_connection_details.password,
            alias=alias,
            timeout=60
        )
        time.sleep(3)
        voice_state = csn.execute(command=f'adb -s {sn} shell dumpsys telephony.registry | grep "mCallState"',
                                  connection=alias)
        my_logger.info(f'adb -s {sn} shell dumpsys telephony.registry | grep "mCallState"')
        time.sleep(2)
        assert f'mCallState={state_code}' in voice_state, 'need to check voice status'
        time.sleep(1)
    except Exception as e:
        print(e)
        my_logger.error(f'check_voice_call: ue_index: {ue_index}: {e}')
    finally:
        csn.disconnect(connection=alias)


def check_voice_calls(ue_index_list, state_code=2):
    with ThreadPoolExecutor(max_workers=40) as executor:
        futures = [executor.submit(check_voice_call, ue_index, state_code) for ue_index in ue_index_list]
        for future in futures:
            try:
                future.result()  # Wait for the thread to complete
            except Exception as e:
                print(f'Error occurred: {e}')


def get_ue_ip_for_dl_traffic(sn, pc_ip, pc_username, pc_password):
    p = '{print $2}'
    alias = f'cpc_{sn}'
    csn = ssh()
    output = ''
    try:
        csn.connect_to(
            hostname=pc_ip,
            username=pc_username,
            password=pc_password,
            alias=alias,
            timeout=60
        )
    except Exception as e:
        print(e)
    else:
        output = csn.execute(
            command=f"adb -s ${sn} shell ip -f inet addr |grep inet |grep -v ims00 | cut -d '/' -f 1 |tail -n "
                    f"-1 |head -1 |awk '{p}'",
            connection=alias)
        print(f"ue sn {sn} IP is {output.strip()}")
    finally:
        csn.disconnect(connection=alias)

    return output.strip()


def get_ues_ip_for_dl_traffic(yml_file_path, case_name):
    all_ue_info = get_info_from_file(file_path=yml_file_path)
    futures = []
    all_results = []
    with ThreadPoolExecutor(max_workers=40) as executor:
        for ue_info in all_ue_info[case_name]['ue']:
            futures.append(executor.submit(get_ue_ip_for_dl_traffic,
                                           ue_info['ue_sn'],
                                           ue_info['ue_pc_ip'],
                                           ue_info['ue_pc_username'],
                                           ue_info['ue_pc_password']))
        for future in futures:
            try:
                result = future.result()  # Wait for the thread to complete
                all_results.append(result)
            except Exception as e:
                print(f'Error occurred: {e}')

    return all_results


def change_ue_ip_from_none(all_ue_info, case_name, ue_ip):
    new_ue_info = []
    for ue_info, ip in zip(all_ue_info[case_name]['ue'], ue_ip):
        ue_info['ue_ip'] = ip
        new_ue_info.append(ue_info)
    all_ue_info[case_name]['ue'] = new_ue_info
    return all_ue_info[case_name]['ue']


def operate_action_on_ue():
    pass


# need to drop
def run_sh_file(ip, port, shell_file_name, shell_file_path):
    print(f"cd {shell_file_path}; ./{shell_file_name} {ip} {port} &")
    command = f"cd {shell_file_path}; ./{shell_file_name} {ip} {port} &"
    subprocess.Popen(
        command,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True
    )


# need to drop
def run_sh_file_multi_ues(yml_file_path, case_name):
    all_ue_info = get_info_from_file(file_path=yml_file_path)
    futures = []
    with ThreadPoolExecutor(max_workers=40) as executor:
        for index, ue_info in enumerate(all_ue_info[case_name]['ue']):
            if ue_info['traffic_direction'] == 'DL':
                futures.append(executor.submit(run_sh_file, ue_info['ue_ip'], ue_info['dl_initial_port'] + index,
                                               ue_info['DL_shell_file_name'], ue_info['shell_file_path']))
            elif ue_info['traffic_direction'] == 'UL':
                futures.append(executor.submit(run_sh_file, ue_info['server_ip'], ue_info['ul_initial_port'] + index,
                                               ue_info['UL_shell_file_name'], ue_info['shell_file_path']))
            else:
                futures.append(executor.submit(run_sh_file, ue_info['ue_ip'], ue_info['dl_initial_port'] + index,
                                               ue_info['DL_shell_file_name'], ue_info['shell_file_path']))
                futures.append(executor.submit(run_sh_file, ue_info['server_ip'], ue_info['ul_initial_port'] + index,
                                               ue_info['UL_shell_file_name'], ue_info['shell_file_path']))
        for future in futures:
            try:
                future.result()  # Wait for the thread to complete
            except Exception as e:
                print(f'Error occurred: {e}')


def make_dl_traffic_with_tcp_server(sn, port, interval, pc_ip, pc_username, pc_password):
    alias = f'cpc_{sn}'
    csn = ssh()
    try:
        csn.connect_to(
            hostname=pc_ip,
            username=pc_username,
            password=pc_password,
            alias=alias,
            timeout=60
        )
    except Exception as e:
        print(e)
    else:
        # adb shell iperf -s -i 1 -p 53241
        print(f"adb -s {sn} shell iperf -s -i {interval} -p {port} &")
        csn.send_command(
            command=f"adb -s {sn} shell iperf -s -i {interval} -p {port} &",
            connection=alias)
        # print(f"ue sn {sn} {port} result is {output}")
    finally:
        csn.disconnect(connection=alias)


def make_dl_traffic_with_tcp_client(ue_ip, port, duration, interval, process_num, dl_mtu_size, iperf_server_ip,
                                    iperf_server_user, iperf_server_pwd, index):
    alias = f'iperf_{index}'
    csn = ssh()
    try:
        csn.connect_to(
            hostname=iperf_server_ip,
            username=iperf_server_user,
            password=iperf_server_pwd,
            alias=alias,
            timeout=60
        )
    except Exception as e:
        print(f"{iperf_server_ip} {ue_ip}: {e}")
    else:
        # iperf -i 1 -t 99999 -p 53241 -c 10.70.221.127 -M 1180 -P 10
        csn.send_command(
            command=f'iperf -c {ue_ip} -t {duration} -i {interval} -p {port} -P {process_num} -M {dl_mtu_size} &',
            connection=alias)
        print(f'iperf -c {ue_ip} -u -t {duration} -i {interval} -p {port} -P {process_num} -M {dl_mtu_size} &')
        # print(f"ue ip {ue_ip} {port} result is {output}")
    finally:
        csn.disconnect(connection=alias)


def make_dl_traffic_with_tcp(sn, port, interval, pc_ip, pc_username, pc_password, ue_ip, duration, process_num,
                             dl_mtu_size, iperf_server_ip, iperf_server_user, iperf_server_pwd, index):
    make_dl_traffic_with_tcp_server(sn=sn, port=port, interval=interval, pc_ip=pc_ip, pc_username=pc_username,
                                    pc_password=pc_password)
    make_dl_traffic_with_tcp_client(ue_ip=ue_ip, port=port, duration=duration, interval=interval,
                                    process_num=process_num, dl_mtu_size=dl_mtu_size,
                                    iperf_server_ip=iperf_server_ip, iperf_server_user=iperf_server_user,
                                    iperf_server_pwd=iperf_server_pwd, index=index)


def make_ul_traffic_with_tcp_server(port, interval, iperf_server_ip, iperf_server_user, iperf_server_pwd, index):
    alias = f'iperf_{index}'
    csn = ssh()
    try:
        csn.connect_to(
            hostname=iperf_server_ip,
            username=iperf_server_user,
            password=iperf_server_pwd,
            alias=alias,
            timeout=60
        )
    except Exception as e:
        print(f"{e}")
    else:
        # iperf -s -i -1 -p 53341
        csn.send_command(
            command=f'iperf -s -i {interval} -p {port} &',
            connection=alias)
        print(f'iperf -s -i {interval} -p {port} &')
    finally:
        csn.disconnect(connection=alias)


def make_ul_traffic_with_tcp_client(sn, sever_ip, ul_mtu_size, interval, duration, port, process_num, pc_ip,
                                    pc_username, pc_password):
    alias = f'cpc_{sn}'
    csn = ssh()
    try:
        csn.connect_to(
            hostname=pc_ip,
            username=pc_username,
            password=pc_password,
            alias=alias,
            timeout=60
        )
    except Exception as e:
        print(e)
    else:
        # adb -s d4be91dc shell iperf -c 10.57.163.50 -M 1180 -i 1 -t 999999 -p 53341 -P 2
        print(
            f"adb -s {sn} shell iperf -c {sever_ip} -M {ul_mtu_size} -i {interval} -t {duration}"
            f"-p {port} -P {process_num} &")
        csn.send_command(
            command=f"adb -s {sn} shell iperf -c {sever_ip} -M {ul_mtu_size} -i {interval} -t {duration}"
                    f"-p {port} -P {process_num} &",
            connection=alias)
        # print(f"ue sn {sn} {port} result is {output}")
    finally:
        csn.disconnect(connection=alias)


def make_ul_traffic_with_tcp(sn, sever_ip, ul_mtu_size, port, duration, process_num, pc_ip, pc_username, pc_password,
                             interval, iperf_server_user, iperf_server_pwd, index):
    make_ul_traffic_with_tcp_server(port=port, interval=interval, iperf_server_ip=sever_ip,
                                    iperf_server_user=iperf_server_user, iperf_server_pwd=iperf_server_pwd,
                                    index=index)
    make_ul_traffic_with_tcp_client(sn=sn, sever_ip=sever_ip, ul_mtu_size=ul_mtu_size, interval=interval,
                                    duration=duration, port=port, process_num=process_num, pc_ip=pc_ip,
                                    pc_username=pc_username, pc_password=pc_password)


def make_dl_traffic(ue_ip, port, duration, interval, process_num, t_size, buffer_size, iperf_server_ip,
                    iperf_server_user, iperf_server_pwd, index):
    alias = f'iperf_{index}'
    csn = ssh()
    try:
        MAX_CONNECT_RETRIES = 5
        RETRY_DELAY_SECONDS = 5
        for attempt in range(1, MAX_CONNECT_RETRIES + 1):
            try:
                csn.connect_to(
                    hostname=iperf_server_ip,
                    username=iperf_server_user,
                    password=iperf_server_pwd,
                    alias=alias,
                    timeout=60
                )
                my_logger.info(f"iperf_{index}: Successfully connected on attempt {attempt}.")
                break
            except Exception as e:
                my_logger.warning(f"iperf_{index}: Connection attempt {attempt} failed: {e}")
                if attempt < MAX_CONNECT_RETRIES:
                    my_logger.info(f"iperf_{index}: Retrying in {RETRY_DELAY_SECONDS} seconds...")
                    time.sleep(RETRY_DELAY_SECONDS)
                else:
                    my_logger.error(
                        f"iperf_{index}: All {MAX_CONNECT_RETRIES} connection attempts failed. Giving up.")
                    raise
    except Exception as e:
        print(f"{iperf_server_ip} {ue_ip}: {e}")
    else:
        csn.send_command(
            command=f'iperf -c {ue_ip} -u -t {duration} -i {interval} -p {port} '
                    f'-P {process_num} -f m -b {t_size} -l {buffer_size} -T 64 &',
            connection=alias)
        print(f'iperf -c {ue_ip} -u -t {duration} -i {interval} -p {port} '
              f'-P {process_num} -f m -b {t_size} -l {buffer_size} -T 64 &')
        # print(f"ue ip {ue_ip} {port} result is {output}")
    finally:
        csn.disconnect(connection=alias)


def make_ul_traffic(sn, sever_ip, b_size, buffer_size, port, duration, interval, w_size, pc_ip, pc_username,
                    pc_password):
    alias = f'cpc_{sn}'
    csn = ssh()
    try:
        MAX_CONNECT_RETRIES = 5
        RETRY_DELAY_SECONDS = 5
        for attempt in range(1, MAX_CONNECT_RETRIES + 1):
            try:
                csn.connect_to(
                    hostname=pc_ip,
                    username=pc_username,
                    password=pc_password,
                    alias=alias,
                    timeout=60
                )
                my_logger.info(f"cpc_{sn}: Successfully connected on attempt {attempt}.")
                break
            except Exception as e:
                my_logger.warning(f"cpc_{sn}: Connection attempt {attempt} failed: {e}")
                if attempt < MAX_CONNECT_RETRIES:
                    my_logger.info(f"cpc_{sn}: Retrying in {RETRY_DELAY_SECONDS} seconds...")
                    time.sleep(RETRY_DELAY_SECONDS)
                else:
                    my_logger.error(
                        f"cpc_{sn}: All {MAX_CONNECT_RETRIES} connection attempts failed. Giving up.")
                    raise
    except Exception as e:
        print(e)
    else:
        print(f"adb -s {sn} shell /data/local/tmp/iperf -c "
              f"{sever_ip} -u -b {b_size} -l {buffer_size} -p {port} "
              f"-t {duration} -i {interval} -w {w_size} &")
        csn.send_command(
            command=f"adb -s {sn} shell /data/local/tmp/iperf -c "
                    f"{sever_ip} -u -b {b_size} -l {buffer_size} -p {port} "
                    f"-t {duration} -i {interval} -w {w_size} &",
            connection=alias)
        # print(f"ue sn {sn} {port} result is {output}")
    finally:
        csn.disconnect(connection=alias)


def make_dl_traffic_via_shell_file(ue_ip, port, shell_file_path, shell_file_name, iperf_server_ip,
                                   iperf_server_user, iperf_server_pwd, index):
    alias = f'iperf_{index}'
    csn = ssh()
    try:
        MAX_CONNECT_RETRIES = 5
        RETRY_DELAY_SECONDS = 5
        for attempt in range(1, MAX_CONNECT_RETRIES + 1):
            try:
                csn.connect_to(
                    hostname=iperf_server_ip,
                    username=iperf_server_user,
                    password=iperf_server_pwd,
                    alias=alias,
                    timeout=60
                )
                my_logger.info(f"iperf_{index}: Successfully connected on attempt {attempt}.")
                break
            except Exception as e:
                my_logger.warning(f"iperf_{index}: Connection attempt {attempt} failed: {e}")
                if attempt < MAX_CONNECT_RETRIES:
                    my_logger.info(f"iperf_{index}: Retrying in {RETRY_DELAY_SECONDS} seconds...")
                    time.sleep(RETRY_DELAY_SECONDS)
                else:
                    my_logger.error(
                        f"iperf_{index}: All {MAX_CONNECT_RETRIES} connection attempts failed. Giving up.")
                    raise
    except Exception as e:
        print(f"{iperf_server_ip} {ue_ip}: {e}")
    else:
        print(f"cd {shell_file_path}; ./{shell_file_name} {ue_ip} {port} &")
        command = f"cd {shell_file_path}; ./{shell_file_name} {ue_ip} {port} &"
        csn.send_command(
            command=command,
            connection=alias)
        # print(f"ue ip {ue_ip} {port} result is {output}")
    finally:
        csn.disconnect(connection=alias)


def make_ul_traffic_via_shell_file(sn, sever_ip, shell_file_path, shell_file_name, port, pc_ip, pc_username,
                                   pc_password):
    alias = f'cpc_{sn}'
    csn = ssh()
    try:
        MAX_CONNECT_RETRIES = 5
        RETRY_DELAY_SECONDS = 5
        for attempt in range(1, MAX_CONNECT_RETRIES + 1):
            try:
                csn.connect_to(
                    hostname=pc_ip,
                    username=pc_username,
                    password=pc_password,
                    alias=alias,
                    timeout=60
                )
                my_logger.info(f"cpc_{sn}: Successfully connected on attempt {attempt}.")
                break
            except Exception as e:
                my_logger.warning(f"cpc_{sn}: Connection attempt {attempt} failed: {e}")
                if attempt < MAX_CONNECT_RETRIES:
                    my_logger.info(f"cpc_{sn}: Retrying in {RETRY_DELAY_SECONDS} seconds...")
                    time.sleep(RETRY_DELAY_SECONDS)
                else:
                    my_logger.error(
                        f"cpc_{sn}: All {MAX_CONNECT_RETRIES} connection attempts failed. Giving up.")
                    raise
    except Exception as e:
        print(e)
    else:
        print(f"cd {shell_file_path}; ./{shell_file_name} {sn} {sever_ip} {port} &")
        command = f"cd {shell_file_path}; ./{shell_file_name} {sn} {sever_ip} {port} &"
        csn.send_command(
            command=command,
            connection=alias)
        # print(f"ue sn {sn} {port} result is {output}")
    finally:
        csn.disconnect(connection=alias)


def start_traffic_with_multi_ues(yml_file_path, case_name):
    all_ue_info = get_info_from_file(file_path=yml_file_path)
    futures = []
    with ThreadPoolExecutor(max_workers=40) as executor:
        for index, ue_info in enumerate(all_ue_info[case_name]['ue']):
            if ue_info['traffic'] is True:
                if ue_info['traffic_direction'] == 'DL':
                    if ue_info['dl_traffic_method'] == 'command':
                        if ue_info['traffic_protocol'] == 'udp':
                            futures.append(executor.submit(make_dl_traffic,
                                                           ue_info['ue_ip'],
                                                           ue_info['dl_initial_port'] + index,
                                                           ue_info['dl_duration'],
                                                           ue_info['dl_traffic_interval'],
                                                           ue_info['dl_traffic_process_num'],
                                                           ue_info['dl_traffic_size'],
                                                           ue_info['dl_traffic_buffer_size'],
                                                           ue_info['server_ip'],
                                                           ue_info['server_username'],
                                                           ue_info['server_password'],
                                                           index))
                        elif ue_info['traffic_protocol'] == 'tcp':
                            futures.append(executor.submit(make_dl_traffic_with_tcp,
                                                           ue_info['ue_sn'],
                                                           ue_info['dl_initial_port'] + index,
                                                           ue_info['dl_traffic_interval'],
                                                           ue_info['ue_pc_ip'],
                                                           ue_info['ue_pc_username'],
                                                           ue_info['ue_pc_password'],
                                                           ue_info['ue_ip'],
                                                           ue_info['dl_duration'],
                                                           ue_info['dl_traffic_process_num'],
                                                           ue_info['dl_mtu_size'],
                                                           ue_info['server_ip'],
                                                           ue_info['server_username'],
                                                           ue_info['server_password'],
                                                           index))
                    elif ue_info['dl_traffic_method'] == 'shell_file':
                        futures.append(executor.submit(make_dl_traffic_via_shell_file,
                                                       ue_info['ue_ip'],
                                                       ue_info['dl_initial_port'] + index,
                                                       ue_info['shell_file_path'],
                                                       ue_info['DL_shell_file_name'],
                                                       ue_info['server_ip'],
                                                       ue_info['server_username'],
                                                       ue_info['server_password'],
                                                       index))
                elif ue_info['traffic_direction'] == 'UL':
                    if ue_info['ul_traffic_method'] == 'command':
                        if ue_info['traffic_protocol'] == 'udp':
                            futures.append(executor.submit(make_ul_traffic,
                                                           ue_info['ue_sn'],
                                                           ue_info['server_ip'],
                                                           ue_info['ul_traffic_size'],
                                                           ue_info['ul_traffic_buffer_size'],
                                                           ue_info['ul_initial_port'] + index,
                                                           ue_info['ul_duration'],
                                                           ue_info['ul_traffic_interval'],
                                                           ue_info['ul_traffic_window_size'],
                                                           ))
                        elif ue_info['traffic_protocol'] == 'tcp':
                            futures.append(executor.submit(make_ul_traffic_with_tcp,
                                                           ue_info['ue_sn'],
                                                           ue_info['server_ip'],
                                                           ue_info['ul_mtu_size'],
                                                           ue_info['ul_initial_port'] + index,
                                                           ue_info['ul_duration'],
                                                           ue_info['ul_tcp_traffic_process_num'],
                                                           ue_info['ue_pc_ip'],
                                                           ue_info['ue_pc_username'],
                                                           ue_info['ue_pc_password'],
                                                           ue_info['ul_traffic_interval'],
                                                           ue_info['server_username'],
                                                           ue_info['server_password'],
                                                           index
                                                           ))
                    elif ue_info['ul_traffic_method'] == 'shell_file':
                        futures.append(executor.submit(make_ul_traffic_via_shell_file,
                                                       ue_info['ue_sn'],
                                                       ue_info['server_ip'],
                                                       ue_info['shell_file_path'],
                                                       ue_info['UL_shell_file_name'],
                                                       ue_info['ul_initial_port'] + index,
                                                       ue_info['ue_pc_ip'],
                                                       ue_info['ue_pc_username'],
                                                       ue_info['ue_pc_password']))
                elif ue_info['traffic_direction'] == 'DLUL':
                    if ue_info['dl_traffic_method'] == 'command':
                        if ue_info['traffic_protocol'] == 'udp':
                            futures.append(executor.submit(make_dl_traffic,
                                                           ue_info['ue_ip'],
                                                           ue_info['dl_initial_port'] + index,
                                                           ue_info['dl_duration'],
                                                           ue_info['dl_traffic_interval'],
                                                           ue_info['dl_traffic_process_num'],
                                                           ue_info['dl_traffic_size'],
                                                           ue_info['dl_traffic_buffer_size'],
                                                           ue_info['server_ip'],
                                                           ue_info['server_username'],
                                                           ue_info['server_password'],
                                                           index))
                        elif ue_info['traffic_protocol'] == 'tcp':
                            futures.append(executor.submit(make_dl_traffic_with_tcp,
                                                           ue_info['ue_sn'],
                                                           ue_info['dl_initial_port'] + index,
                                                           ue_info['dl_traffic_interval'],
                                                           ue_info['ue_pc_ip'],
                                                           ue_info['ue_pc_username'],
                                                           ue_info['ue_pc_password'],
                                                           ue_info['ue_ip'],
                                                           ue_info['dl_duration'],
                                                           ue_info['dl_traffic_process_num'],
                                                           ue_info['dl_mtu_size'],
                                                           ue_info['server_ip'],
                                                           ue_info['server_username'],
                                                           ue_info['server_password'],
                                                           index))
                    elif ue_info['dl_traffic_method'] == 'shell_file':
                        futures.append(executor.submit(make_dl_traffic_via_shell_file,
                                                       ue_info['ue_ip'],
                                                       ue_info['dl_initial_port'] + index,
                                                       ue_info['shell_file_path'],
                                                       ue_info['DL_shell_file_name'],
                                                       ue_info['server_ip'],
                                                       ue_info['server_username'],
                                                       ue_info['server_password'],
                                                       index))
                    if ue_info['ul_traffic_method'] == 'command':
                        if ue_info['traffic_protocol'] == 'udp':
                            futures.append(executor.submit(make_ul_traffic,
                                                           ue_info['ue_sn'],
                                                           ue_info['server_ip'],
                                                           ue_info['ul_traffic_size'],
                                                           ue_info['ul_traffic_buffer_size'],
                                                           ue_info['ul_initial_port'] + index,
                                                           ue_info['ul_duration'],
                                                           ue_info['ul_traffic_interval'],
                                                           ue_info['ul_traffic_window_size'],
                                                           ue_info['ue_pc_ip'],
                                                           ue_info['ue_pc_username'],
                                                           ue_info['ue_pc_password']))
                        elif ue_info['traffic_protocol'] == 'tcp':
                            futures.append(executor.submit(make_ul_traffic_with_tcp,
                                                           ue_info['ue_sn'],
                                                           ue_info['server_ip'],
                                                           ue_info['ul_mtu_size'],
                                                           ue_info['ul_initial_port'] + index,
                                                           ue_info['ul_duration'],
                                                           ue_info['ul_tcp_traffic_process_num'],
                                                           ue_info['ue_pc_ip'],
                                                           ue_info['ue_pc_username'],
                                                           ue_info['ue_pc_password'],
                                                           ue_info['ul_traffic_interval'],
                                                           ue_info['server_username'],
                                                           ue_info['server_password'],
                                                           index
                                                           ))
                    elif ue_info['ul_traffic_method'] == 'shell_file':
                        futures.append(executor.submit(make_ul_traffic_via_shell_file,
                                                       ue_info['ue_sn'],
                                                       ue_info['server_ip'],
                                                       ue_info['shell_file_path'],
                                                       ue_info['UL_shell_file_name'],
                                                       ue_info['ul_initial_port'] + index,
                                                       ue_info['ue_pc_ip'],
                                                       ue_info['ue_pc_username'],
                                                       ue_info['ue_pc_password']))
        for future in futures:
            try:
                future.result()  # Wait for the thread to complete
            except Exception as e:
                print(f'Error occurred: {e}')


# need to drop
def kill_sh_file(shell_file_name):
    filter_condition = '{print $2}'
    print(f"ps -ef | grep {shell_file_name} |awk '{filter_condition}'|xargs kill -9 &")
    command = f"ps -ef | grep {shell_file_name} |awk '{filter_condition}'|xargs kill -9 &"
    subprocess.Popen(
        command,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True
    )


# need to drop
def kill_sh_file_multi_ue(yml_file_path, case_name):
    all_ue_info = get_info_from_file(file_path=yml_file_path)
    futures = []
    with ThreadPoolExecutor(max_workers=40) as executor:
        for index, ue_info in enumerate(all_ue_info[case_name]['ue']):
            if ue_info['traffic_direction'] == 'DL':
                futures.append(executor.submit(kill_sh_file, ue_info['DL_shell_file_name']))
            elif ue_info['traffic_direction'] == 'UL':
                futures.append(executor.submit(kill_sh_file, ue_info['UL_shell_file_name']))
            else:
                futures.append(executor.submit(kill_sh_file, ue_info['DL_shell_file_name']))
                futures.append(executor.submit(kill_sh_file, ue_info['UL_shell_file_name']))
        for future in futures:
            try:
                future.result()  # Wait for the thread to complete
            except Exception as e:
                print(f'Error occurred: {e}')


def stop_dl_traffic_with_tcp_on_pc(sn, port, pc_ip, pc_username, pc_password):
    p = '{print $2}'
    alias = f'cpc_{sn}'
    csn = ssh()
    try:
        csn.connect_to(
            hostname=pc_ip,
            username=pc_username,
            password=pc_password,
            alias=alias,
            timeout=60
        )
    except Exception as e:
        print(e)
    else:
        print(f"adb -s {sn} shell ps -ef | grep iperf |grep {port} |grep -v grep |awk '{p}'")
        csn.send_command(
            command=f"adb -s {sn} shell ps -ef | grep iperf |grep {port} |grep -v grep |awk '{p}'",
            connection=alias)
        output = csn.read_output(connection=alias)
        time.sleep(0.5)
        # print(f"output: {output.strip()}")
        # print(f"length output: {len(output.strip())}")
        pids = output.strip().split("\n")
        print(pids)
        for pid in pids:
            csn.send_command(
                command=f"adb -s {sn} shell kill -9 {pid} &",
                connection=alias)
            print(f"adb -s {sn} shell kill -9 {pid} &")
        # print(f"{sn} ul port {port} result is: {result}")
        time.sleep(0.5)
    finally:
        csn.disconnect(connection=alias)


def stop_dl_traffic_with_tcp_on_server(iperf_server_ip, iperf_server_user, iperf_server_pwd, index, port):
    p = '{print $2}'
    alias = f'iperf_{index}'
    csn = ssh()
    try:
        csn.connect_to(
            hostname=iperf_server_ip,
            username=iperf_server_user,
            password=iperf_server_pwd,
            alias=alias,
            timeout=60
        )
    except Exception as e:
        print(e)
    else:
        output = csn.execute(
            command=f"ps -ef|grep iperf|grep -v grep|grep {port}| awk '{p}' |xargs kill -9",
            connection=alias)
        print(f"dl port {port} result is: {output}")
    finally:
        csn.disconnect(connection=alias)


def stop_dl_traffic_with_tcp(iperf_server_ip, iperf_server_user, iperf_server_pwd, index, port, sn, pc_ip,
                             pc_username, pc_password):
    stop_dl_traffic_with_tcp_on_server(iperf_server_ip=iperf_server_ip, iperf_server_user=iperf_server_user,
                                       iperf_server_pwd=iperf_server_pwd, index=index, port=port)
    stop_dl_traffic_with_tcp_on_pc(sn=sn, port=port, pc_ip=pc_ip, pc_username=pc_username, pc_password=pc_password)


def stop_ul_traffic_with_tcp(iperf_server_ip, iperf_server_user, iperf_server_pwd, index, port, sn, pc_ip,
                             pc_username, pc_password):
    stop_dl_traffic_with_tcp_on_pc(sn=sn, port=port, pc_ip=pc_ip, pc_username=pc_username, pc_password=pc_password)
    stop_dl_traffic_with_tcp_on_server(iperf_server_ip=iperf_server_ip, iperf_server_user=iperf_server_user,
                                       iperf_server_pwd=iperf_server_pwd, index=index, port=port)


def stop_dl_traffic(iperf_server_ip, iperf_server_user, iperf_server_pwd, index, port):
    p = '{print $2}'
    alias = f'iperf_{index}'
    csn = ssh()
    try:
        MAX_CONNECT_RETRIES = 5
        RETRY_DELAY_SECONDS = 5
        for attempt in range(1, MAX_CONNECT_RETRIES + 1):
            try:
                csn.connect_to(
                    hostname=iperf_server_ip,
                    username=iperf_server_user,
                    password=iperf_server_pwd,
                    alias=alias,
                    timeout=60
                )
                my_logger.info(f"iperf_{index}: Successfully connected on attempt {attempt}.")
                break
            except Exception as e:
                my_logger.warning(f"iperf_{index}: Connection attempt {attempt} failed: {e}")
                if attempt < MAX_CONNECT_RETRIES:
                    my_logger.info(f"iperf_{index}: Retrying in {RETRY_DELAY_SECONDS} seconds...")
                    time.sleep(RETRY_DELAY_SECONDS)
                else:
                    my_logger.error(
                        f"iperf_{index}: All {MAX_CONNECT_RETRIES} connection attempts failed. Giving up.")
                    raise
    except Exception as e:
        print(e)
    else:
        output = csn.execute(
            command=f"ps -ef|grep iperf|grep -v grep|grep {port}| awk '{p}' |xargs kill -9",
            connection=alias)
        print(f"dl port {port} result is: {output}")
    finally:
        csn.disconnect(connection=alias)


def stop_ul_traffic(sn, port, pc_ip, pc_username, pc_password):
    p = '{print $2}'
    alias = f'cpc_{sn}'
    csn = ssh()
    try:
        MAX_CONNECT_RETRIES = 5
        RETRY_DELAY_SECONDS = 5
        for attempt in range(1, MAX_CONNECT_RETRIES + 1):
            try:
                csn.connect_to(
                    hostname=pc_ip,
                    username=pc_username,
                    password=pc_password,
                    alias=alias,
                    timeout=60
                )
                my_logger.info(f"cpc_{sn}: Successfully connected on attempt {attempt}.")
                break
            except Exception as e:
                my_logger.warning(f"cpc_{sn}: Connection attempt {attempt} failed: {e}")
                if attempt < MAX_CONNECT_RETRIES:
                    my_logger.info(f"cpc_{sn}: Retrying in {RETRY_DELAY_SECONDS} seconds...")
                    time.sleep(RETRY_DELAY_SECONDS)
                else:
                    my_logger.error(
                        f"cpc_{sn}: All {MAX_CONNECT_RETRIES} connection attempts failed. Giving up.")
                    raise
    except Exception as e:
        print(e)
    else:
        print(f"adb -s {sn} shell ps -ef | grep iperf |grep {port} |grep -v grep |awk '{p}'")
        csn.send_command(
            command=f"adb -s {sn} shell ps -ef | grep iperf |grep {port} |grep -v grep |awk '{p}'",
            connection=alias)
        output = csn.read_output(connection=alias)
        time.sleep(0.5)
        # print(f"output: {output.strip()}")
        # print(f"length output: {len(output.strip())}")
        pids = output.strip().split("\n")
        print(pids)
        for pid in pids:
            csn.send_command(
                command=f"adb -s {sn} shell kill -9 {pid} &",
                connection=alias)
            print(f"adb -s {sn} shell kill -9 {pid} &")
        # print(f"{sn} ul port {port} result is: {result}")
        time.sleep(0.5)
    finally:
        csn.disconnect(connection=alias)


def stop_dl_traffic_with_shell_file(iperf_server_ip, iperf_server_user, iperf_server_pwd,
                                    index, port, shell_file_name):
    alias = f'iperf_{index}'
    csn = ssh()
    try:
        MAX_CONNECT_RETRIES = 5
        RETRY_DELAY_SECONDS = 5
        for attempt in range(1, MAX_CONNECT_RETRIES + 1):
            try:
                csn.connect_to(
                    hostname=iperf_server_ip,
                    username=iperf_server_user,
                    password=iperf_server_pwd,
                    alias=alias,
                    timeout=60
                )
                my_logger.info(f"iperf_{index}: Successfully connected on attempt {attempt}.")
                break
            except Exception as e:
                my_logger.warning(f"iperf_{index}: Connection attempt {attempt} failed: {e}")
                if attempt < MAX_CONNECT_RETRIES:
                    my_logger.info(f"iperf_{index}: Retrying in {RETRY_DELAY_SECONDS} seconds...")
                    time.sleep(RETRY_DELAY_SECONDS)
                else:
                    my_logger.error(
                        f"iperf_{index}: All {MAX_CONNECT_RETRIES} connection attempts failed. Giving up.")
                    raise
    except Exception as e:
        print(e)
    else:
        filter_condition = '{print $2}'
        print(f"ps -ef | grep {shell_file_name} |awk '{filter_condition}'|xargs kill -9 &")
        command = f"ps -ef | grep {shell_file_name} |awk '{filter_condition}'|xargs kill -9 &"
        output = csn.send_command(
            command=command,
            connection=alias)
        print(f"dl port {port} result is: {output}")
    finally:
        csn.disconnect(connection=alias)


def stop_ul_traffic_with_shell_file(sn, port, pc_ip, pc_username, pc_password):
    p = '{print $2}'
    alias = f'cpc_{sn}'
    csn = ssh()
    try:
        MAX_CONNECT_RETRIES = 5
        RETRY_DELAY_SECONDS = 5
        for attempt in range(1, MAX_CONNECT_RETRIES + 1):
            try:
                csn.connect_to(
                    hostname=pc_ip,
                    username=pc_username,
                    password=pc_password,
                    alias=alias,
                    timeout=60
                )
                my_logger.info(f"cpc_{sn}: Successfully connected on attempt {attempt}.")
                break
            except Exception as e:
                my_logger.warning(f"cpc_{sn}: Connection attempt {attempt} failed: {e}")
                if attempt < MAX_CONNECT_RETRIES:
                    my_logger.info(f"cpc_{sn}: Retrying in {RETRY_DELAY_SECONDS} seconds...")
                    time.sleep(RETRY_DELAY_SECONDS)
                else:
                    my_logger.error(
                        f"cpc_{sn}: All {MAX_CONNECT_RETRIES} connection attempts failed. Giving up.")
                    raise
    except Exception as e:
        print(e)
    else:
        output = csn.execute(
            command=f"adb -s {sn} shell ps -ef | grep iperf |grep {port} |grep -v grep |awk '{p}'",
            connection=alias)
        time.sleep(0.5)
        pid = str(output, encoding='utf-8').strip()
        result = csn.execute(
            command=f"adb -s {sn} shell kill -9 {pid} &",
            connection=alias)
        print(f"adb -s {sn} shell kill -9 {pid} &")
        print(f"{sn} ul port {port} result is: {result}")
        time.sleep(0.5)
    finally:
        csn.disconnect(connection=alias)


def stop_traffic_with_multi_ues(yml_file_path, case_name):
    all_ue_info = get_info_from_file(file_path=yml_file_path)
    futures = []
    with ThreadPoolExecutor(max_workers=40) as executor:
        for index, ue_info in enumerate(all_ue_info[case_name]['ue']):
            if ue_info['traffic'] is True:
                if ue_info['traffic_direction'] == 'DL':
                    if ue_info['dl_traffic_method'] == 'command':
                        if ue_info['traffic_protocol'] == 'udp':
                            futures.append(executor.submit(stop_dl_traffic,
                                                           ue_info['server_ip'],
                                                           ue_info['server_username'],
                                                           ue_info['server_password'],
                                                           index,
                                                           ue_info['dl_initial_port'] + index))
                        elif ue_info['traffic_protocol'] == 'tcp':
                            futures.append(executor.submit(stop_dl_traffic_with_tcp,
                                                           ue_info['server_ip'],
                                                           ue_info['server_username'],
                                                           ue_info['server_password'],
                                                           index,
                                                           ue_info['dl_initial_port'] + index,
                                                           ue_info['ue_sn'],
                                                           ue_info['ue_pc_ip'],
                                                           ue_info['ue_pc_username'],
                                                           ue_info['ue_pc_password']
                                                           ))
                    elif ue_info['dl_traffic_method'] == 'shell_file':
                        futures.append(executor.submit(stop_dl_traffic_with_shell_file,
                                                       ue_info['server_ip'],
                                                       ue_info['server_username'],
                                                       ue_info['server_password'],
                                                       index,
                                                       ue_info['dl_initial_port'] + index,
                                                       ue_info['DL_shell_file_name']))
                elif ue_info['traffic_direction'] == 'UL':
                    if ue_info['ul_traffic_method'] == 'command':
                        if ue_info['traffic_protocol'] == 'udp':
                            futures.append(executor.submit(stop_ul_traffic,
                                                           ue_info['ue_sn'],
                                                           ue_info['ul_initial_port'] + index,
                                                           ue_info['ue_pc_ip'],
                                                           ue_info['ue_pc_username'],
                                                           ue_info['ue_pc_password']))
                        elif ue_info['traffic_protocol'] == 'tcp':
                            futures.append(executor.submit(stop_dl_traffic_with_tcp,
                                                           ue_info['server_ip'],
                                                           ue_info['server_username'],
                                                           ue_info['server_password'],
                                                           index,
                                                           ue_info['ul_initial_port'] + index,
                                                           ue_info['ue_sn'],
                                                           ue_info['ue_pc_ip'],
                                                           ue_info['ue_pc_username'],
                                                           ue_info['ue_pc_password']
                                                           ))
                    elif ue_info['ul_traffic_method'] == 'shell_file':
                        # futures.append(executor.submit(kill_sh_file, ue_info['UL_shell_file_name']))
                        futures.append(executor.submit(stop_ul_traffic_with_shell_file,
                                                       ue_info['ue_sn'],
                                                       ue_info['ul_initial_port'] + index,
                                                       ue_info['ue_pc_ip'],
                                                       ue_info['ue_pc_username'],
                                                       ue_info['ue_pc_password']))
                elif ue_info['traffic_direction'] == 'DLUL':
                    if ue_info['dl_traffic_method'] == 'command':
                        if ue_info['traffic_protocol'] == 'udp':
                            futures.append(executor.submit(stop_dl_traffic,
                                                           ue_info['server_ip'],
                                                           ue_info['server_username'],
                                                           ue_info['server_password'],
                                                           index,
                                                           ue_info['dl_initial_port'] + index))
                            futures.append(executor.submit(stop_ul_traffic,
                                                           ue_info['ue_sn'],
                                                           ue_info['ul_initial_port'] + index,
                                                           ue_info['ue_pc_ip'],
                                                           ue_info['ue_pc_username'],
                                                           ue_info['ue_pc_password']))
                        elif ue_info['traffic_protocol'] == 'tcp':
                            futures.append(executor.submit(stop_dl_traffic_with_tcp,
                                                           ue_info['server_ip'],
                                                           ue_info['server_username'],
                                                           ue_info['server_password'],
                                                           index,
                                                           ue_info['dl_initial_port'] + index,
                                                           ue_info['ue_sn'],
                                                           ue_info['ue_pc_ip'],
                                                           ue_info['ue_pc_username'],
                                                           ue_info['ue_pc_password']
                                                           ))
                            futures.append(executor.submit(stop_dl_traffic_with_tcp,
                                                           ue_info['server_ip'],
                                                           ue_info['server_username'],
                                                           ue_info['server_password'],
                                                           index,
                                                           ue_info['ul_initial_port'] + index,
                                                           ue_info['ue_sn'],
                                                           ue_info['ue_pc_ip'],
                                                           ue_info['ue_pc_username'],
                                                           ue_info['ue_pc_password']
                                                           ))
                    elif ue_info['dl_traffic_method'] == 'shell_file':
                        futures.append(executor.submit(stop_dl_traffic_with_shell_file,
                                                       ue_info['server_ip'],
                                                       ue_info['server_username'],
                                                       ue_info['server_password'],
                                                       index,
                                                       ue_info['dl_initial_port'] + index,
                                                       ue_info['DL_shell_file_name']))
                        # futures.append(executor.submit(kill_sh_file, ue_info['UL_shell_file_name']))
                        futures.append(executor.submit(stop_ul_traffic_with_shell_file,
                                                       ue_info['ue_sn'],
                                                       ue_info['ul_initial_port'] + index,
                                                       ue_info['ue_pc_ip'],
                                                       ue_info['ue_pc_username'],
                                                       ue_info['ue_pc_password']))
        for future in futures:
            try:
                future.result()  # Wait for the thread to complete
            except Exception as e:
                print(f'Error occurred: {e}')


# need to drop
def make_traffic_via_commands(yml_file_path, case_name):
    all_ue_info = get_info_from_file(file_path=yml_file_path)
    all_results = get_ues_ip_for_dl_traffic(yml_file_path=yml_file_path, case_name=case_name)
    new_all_ue_info = change_ue_ip_from_none(all_ue_info=all_ue_info, case_name=case_name, ue_ip=all_results)
    futures = []
    with ThreadPoolExecutor(max_workers=40) as executor:
        for index, ue_info in enumerate(new_all_ue_info[case_name]['ue']):
            if ue_info['traffic_direction'] == 'DL':
                futures.append(executor.submit(make_dl_traffic,
                                               ue_info['ue_ip'],
                                               ue_info['dl_initial_port'] + index,
                                               ue_info['dl_duration'],
                                               ue_info['dl_traffic_interval'],
                                               ue_info['dl_traffic_process_num'],
                                               ue_info['dl_traffic_size'],
                                               ue_info['dl_traffic_buffer_size'],
                                               ue_info['server_ip'],
                                               ue_info['server_username'],
                                               ue_info['server_password'],
                                               index))
            elif ue_info['traffic_direction'] == 'UL':
                futures.append(executor.submit(make_ul_traffic,
                                               ue_info['ue_sn'],
                                               ue_info['server_ip'],
                                               ue_info['ul_traffic_size'],
                                               ue_info['ul_traffic_buffer_size'],
                                               ue_info['ul_initial_port'] + index,
                                               ue_info['ul_duration'],
                                               ue_info['ul_traffic_interval'],
                                               ue_info['ul_traffic_window_size'],
                                               ue_info['ue_pc_ip'],
                                               ue_info['ue_pc_username'],
                                               ue_info['ue_pc_password']))
            else:
                futures.append(executor.submit(make_dl_traffic,
                                               ue_info['ue_ip'],
                                               ue_info['dl_initial_port'] + index,
                                               ue_info['dl_duration'],
                                               ue_info['dl_traffic_interval'],
                                               ue_info['dl_traffic_process_num'],
                                               ue_info['dl_traffic_size'],
                                               ue_info['dl_traffic_buffer_size'],
                                               ue_info['server_ip'],
                                               ue_info['server_username'],
                                               ue_info['server_password'],
                                               index))
                futures.append(executor.submit(make_ul_traffic,
                                               ue_info['ue_sn'],
                                               ue_info['server_ip'],
                                               ue_info['ul_traffic_size'],
                                               ue_info['ul_traffic_buffer_size'],
                                               ue_info['ul_initial_port'] + index,
                                               ue_info['ul_duration'],
                                               ue_info['ul_traffic_interval'],
                                               ue_info['ul_traffic_window_size'],
                                               ue_info['ue_pc_ip'],
                                               ue_info['ue_pc_username'],
                                               ue_info['ue_pc_password']))
        for future in futures:
            try:
                future.result()  # Wait for the thread to complete
            except Exception as e:
                print(f'Error occurred: {e}')


# need to drop
def stop_traffic_via_commands(yml_file_path, case_name):
    all_ue_info = get_info_from_file(file_path=yml_file_path)
    futures = []
    with ThreadPoolExecutor(max_workers=40) as executor:
        for index, ue_info in enumerate(all_ue_info[case_name]['ue']):
            if ue_info['traffic_direction'] == 'DL':
                futures.append(executor.submit(stop_dl_traffic,
                                               ue_info['server_ip'],
                                               ue_info['server_username'],
                                               ue_info['server_password'],
                                               index,
                                               ue_info['dl_initial_port'] + index))
            elif ue_info['traffic_direction'] == 'UL':
                futures.append(executor.submit(stop_ul_traffic,
                                               ue_info['ue_sn'],
                                               ue_info['ul_initial_port'] + index,
                                               ue_info['ue_pc_ip'],
                                               ue_info['ue_pc_username'],
                                               ue_info['ue_pc_password']))
            else:
                futures.append(executor.submit(stop_dl_traffic,
                                               ue_info['server_ip'],
                                               ue_info['server_username'],
                                               ue_info['server_password'],
                                               index,
                                               ue_info['dl_initial_port'] + index))
                futures.append(executor.submit(stop_ul_traffic,
                                               ue_info['ue_sn'],
                                               ue_info['ul_initial_port'] + index,
                                               ue_info['ue_pc_ip'],
                                               ue_info['ue_pc_username'],
                                               ue_info['ue_pc_password']))
        for future in futures:
            try:
                future.result()  # Wait for the thread to complete
            except Exception as e:
                print(f'Error occurred: {e}')


class SyslogAnalyzer:
    def __init__(self):
        pass

    @staticmethod
    async def analyze_log_file(file_path: str, search_str="ERR/"):
        results = []
        async with aiofiles.open(file_path, mode='r') as file:
            lines = await file.readlines()
            for line in lines:
                if search_str in line:
                    results.append(line.strip())
        return results

    async def analyze_all_log_file(self, file_paths: List[str], search_str="ERR/"):
        tasks = [self.analyze_log_file(file, search_str) for file in file_paths]
        all_results = await asyncio.gather(*tasks)
        return all_results

    @staticmethod
    def load_regex_patterns(regex_file_path: str) -> List[Pattern]:
        """Load regular expressions based on file type"""
        file_path = Path(regex_file_path)
        patterns = []

        with open(file_path, 'r', encoding='utf-8') as f:
            data = yaml.safe_load(f)
            if isinstance(data, list):
                patterns = [re.compile(pattern) for pattern in data]
            elif isinstance(data, dict) and 'Regular expression' in data:
                patterns = [re.compile(pattern) for pattern in data['Regular expression']]

        return patterns

    @staticmethod
    def filter_unmatched_lines(all_err_lines, patterns: List[Pattern]) -> List[str]:
        """Filter rows that are not matched by any regular expression"""
        unmatched_lines = []

        for err_lines in all_err_lines:
            for line in err_lines:
                matched = False
                for pattern in patterns:
                    if pattern.search(line):
                        matched = True
                        break
                if not matched:
                    unmatched_lines.append(line)

        return unmatched_lines

    @staticmethod
    async def write_unmatched_lines(unmatched_lines: List[str], output_file: str):
        """Asynchronous writing of unmatched lines to a file"""
        if unmatched_lines:
            async with aiofiles.open(output_file, 'w', encoding='utf-8') as f:
                for line in unmatched_lines:
                    await f.write(line + '\n')
            print(f"already write {len(unmatched_lines)} unmatched lines to {output_file}")
        else:
            async with aiofiles.open(output_file, 'w', encoding='utf-8') as f:
                await f.write('No unmatched lines need to be written')
            print("No unmatched lines need to be written")

    async def analyze(self, syslog_paths: List[str], regex_file_path: str, output_file: str = "unmatched_lines.txt",
                      search_str="ERR/"):
        """Main analysis process"""
        err_lines = await self.analyze_all_log_file(file_paths=syslog_paths, search_str=search_str)

        print("Load regular expression pattern...")
        regex_patterns = self.load_regex_patterns(regex_file_path)
        print(f"loaded {len(regex_patterns)} regular expression pattern")

        print("Perform regular expression matching...")
        unmatched_lines = self.filter_unmatched_lines(err_lines, regex_patterns)
        print(f"found {len(unmatched_lines)} unmatched lines")

        print(f"Write the result to {output_file}...")
        await self.write_unmatched_lines(unmatched_lines, output_file)

        return unmatched_lines


async def main_syslog_analysis(syslog_files: List[str], regex_file: str, output_file: str, search_str="ERR/"):
    analyzer = SyslogAnalyzer()
    try:
        unmatched = await analyzer.analyze(syslog_files, regex_file, output_file, search_str)
        print("Analysis completed！")

        # Display partial results
        if unmatched:
            print("\nThe first 5 unmatched lines:")
            for i, line in enumerate(unmatched[:5]):
                print(f"{i + 1}. {line}")
        else:
            print("All ERR rows are matched by at least one regular expression")

    except Exception as e:
        print(f"Error occurred during the analysis process: {e}")


def run_main_syslog_analysis(
        syslog_files: List[str],
        regex_file: str,
        output_file: str,
        search_str="ERR/"):
    """Asynchronous execution of main analysis syslog program"""
    asyncio.run(main_syslog_analysis(
        syslog_files=syslog_files,
        regex_file=regex_file,
        output_file=output_file,
        search_str=search_str))


def check_syslog_analysis_file(output_file: str):
    with open(output_file, "r") as f:
        data = f.read()

    return data
