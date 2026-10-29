# *-coding=utf-8-*

# Name: Ming Shi
# Time: 2022/10/27 18:59


import os
import logging
import random
import re
import threading
import time
from asyncio import gather
from concurrent.futures import ThreadPoolExecutor
import asyncio

from taf.transport.ssh import ssh
from taf.hw.rf_attenuator import rf_attenuator
from robot.libraries.BuiltIn import BuiltIn

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

att = rf_attenuator()


def select_random_values(input_list, num_values):
    """
    Selects a specified number of random values from the input list.

    :param input_list: List of values to select from
    :param num_values: Number of values to select
    :return: List of randomly selected values
    """
    return random.sample(input_list, num_values)


def list_to_string(input_list):
    """
    Converts a list to a string with elements separated by commas.

    :param input_list: List of values to convert
    :return: String with list elements separated by commas
    """
    return ",".join(map(str, input_list))


def select_UE_for_attach(all_UE_list, voNR_list, EMC_list, num_values):
    for value in voNR_list:
        all_UE_list.remove(value)
    for value in EMC_list:
        all_UE_list.remove(value)
    selected_values = select_random_values(all_UE_list, num_values)
    nsa_list = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    combined_list = nsa_list + voNR_list + EMC_list + selected_values
    return combined_list


def replace_value_from_list(list_name, replace_value='NA'):
    for index, item in enumerate(list_name):
        if item is None:
            list_name[index] = replace_value
    return list_name


def get_required_distname_path(search_str, required_distname='LTEENB'):
    obj = re.compile(pattern=rf'{required_distname}" distName="(?P<distName_path>.*?)"', flags=re.S)
    distname_list = obj.finditer(string=search_str)
    distName_path_list = []
    for distname in distname_list:
        distName_path_list.append(distname.group('distName_path'))
    return distName_path_list


def get_mo_parameters_to_delete(mo_name_list):
    """
    tmp_NRREL_delete = [
        dict(dist_name='MRBTS-37511/NRBTS-37511/NRCELL-301/NRREL-256', parameter=[]),
    ]
    """
    mo_para_list = []
    for mo in mo_name_list:
        mo_para_dict = dict()
        mo_para_dict['dist_name'] = mo
        mo_para_dict['parameter'] = []
        mo_para_list.append(mo_para_dict)
    return mo_para_list


def make_vonr_call(ue_index):
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
        # brand = csn.execute(command=f'adb -s {sn} shell getprop ro.product.brand', connection=alias)
        # my_logger.info(f'adb -s {sn} shell getprop ro.product.brand: {brand}')
        # if 'samsung' in brand:
        #     home_key_event = '3'
        # elif 'qti' in brand:
        #     home_key_event = '82'
        # is_awake = csn.execute(command=f'adb -s {sn} shell dumpsys window | grep mAwake', connection=alias)
        # my_logger.info(f'adb -s {sn} shell dumpsys window | grep mAwake')
        # if 'mAwake=false' in is_awake:
        #     csn.execute(command=f'adb -s {sn} shell input keyevent {home_key_event}', connection=alias)
        #     my_logger.info(f'adb -s {sn} shell input keyevent {home_key_event}')
        #     time.sleep(2)
        #     csn.execute(command=f'adb -s {sn} shell input swipe 500 2050 500 800', connection=alias)
        #     my_logger.info(f'adb -s {sn} shell input swipe 500 2050 500 800')
        #     time.sleep(2)
        # if 'samsung' in brand:
        #     csn.execute(command=f'adb -s {sn} shell input tap 302 2108', connection=alias)
        #     my_logger.info(f'adb -s {sn} shell input tap 302 2108')
        #     time.sleep(2)
        csn.execute(command=f'adb -s {sn} shell am start -a android.intent.action.CALL tel:+6688',
                    connection=alias)
        my_logger.info(f'adb -s {sn} shell am start -a android.intent.action.CALL tel:+6688')
        time.sleep(1)
    except Exception as e:
        print(e)
        my_logger.error(f'make_vonr_call: ue_index: {ue_index}: {e}')
    finally:
        csn.disconnect(connection=alias)


def make_vonr_calls(ue_index_list):
    with ThreadPoolExecutor(max_workers=40) as executor:
        futures = [executor.submit(make_vonr_call, ue_index) for ue_index in ue_index_list]
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


def set_pa_attenuation_value(att_ports,
                             values,
                             att_connection_port,
                             att_ipaddr,
                             att_api_port,
                             model,
                             vendor,
                             max_attenuation_value=127):
    att.setup_attenuator(ip_addr=att_ipaddr, port=att_api_port, model=model,
                         attenuation_port_numbers=att_connection_port, max_attenuation=max_attenuation_value,
                         vendor=vendor)
    att.set_ports_attenuation(ports=att_ports, values=values)
    ports_values = att.read_ports_attenuation(ports=att_ports)
    assert sorted(ports_values) == sorted(values)


def adjust_pa_values(pa_name, s_value, e_value, step, ho_times, interval, pa_settime):
    length_s_value = len(s_value)
    initial_s_value = s_value
    unequal_port = []
    for port in range(length_s_value):
        if s_value[port] != e_value[port]:
            unequal_port.append(port)
    need_change_port_index = unequal_port[0]
    steps = float(step)
    ho_time = int(int(ho_times) / 2)
    step_value = float((e_value[need_change_port_index] - s_value[need_change_port_index]) / steps)
    s_value = float(s_value[need_change_port_index])
    e_value = float(e_value[need_change_port_index])
    sleeps = round((float(interval) - steps * float(pa_settime)) / steps, 1)
    for times in range(ho_time):
        print(f"this is {times} HO!")
        for index in range(-step, step, 1):
            index = abs(index)
            pa_value = int(s_value + step_value * index)
            for p in unequal_port:
                initial_s_value[p] = pa_value
            set_pa_attenuation_value(att_ports=pa_name['pa_ports'],
                                     values=initial_s_value,
                                     att_connection_port=tl.attenuator[0].attenuator_ports[5],
                                     att_ipaddr=pa_name['pa_ip'],
                                     att_api_port=tl.attenuator[0].port,
                                     model=tl.attenuator[0].model,
                                     vendor=tl.attenuator[0].vendor)
            time.sleep(sleeps)


def functions_thread_pool(vonr_ue_index_list,
                          emc_ue_index_list,
                          pa_name,
                          s_value,
                          e_value,
                          step,
                          ho_times,
                          interval,
                          pa_settime,
                          wait_voice_call_timer=0.1):
    thread_vonr = threading.Thread(target=make_vonr_calls, args=(vonr_ue_index_list,))
    thread_emc = threading.Thread(target=make_emc_calls, args=(emc_ue_index_list,))
    thread_adjust_pa_values = threading.Thread(target=adjust_pa_values,
                                               args=(pa_name, s_value, e_value, step, ho_times, interval, pa_settime))
    thread_adjust_pa_values.start()
    time.sleep(wait_voice_call_timer)
    thread_vonr.start()
    thread_emc.start()
    # thread_vonr.join()
    # thread_emc.join()
    thread_adjust_pa_values.join()
