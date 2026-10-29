"""
:copyright: Nokia Networks
:authors:
    Michal Gorski <michal.gorski@nokia.com>
    Krzysztof Korczak <krzysztof.korczak@nokia.com>
    Maciej Majewski <maciej.majewski@nokia.com>
    Tomasz Siuta <tomasz.siuta@nokia.com>
    Arkadiusz Sobejko <arkadiusz.sobejko@nokia.com>
    Patryk Wojcik <patryk.wojcik@nokia.com>
:maintainers:
    Michal Gorski <michal.gorski@nokia.com>
    Krzysztof Korczak <krzysztof.korczak@nokia.com>
    Maciej Majewski <maciej.majewski@nokia.com>
    Tomasz Siuta <tomasz.siuta@nokia.com>
    Arkadiusz Sobejko <arkadiusz.sobejko@nokia.com>
    Patryk Wojcik <patryk.wojcik@nokia.com>
"""

import os
import subprocess
import threading
import time
from robot.api import logger
from robot.errors import ExecutionFailed
from robot.libraries.BuiltIn import BuiltIn
from ta_emss import ta_emss
from ta5g_pm_counters import ta5g_pm_counters
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2Hi_WRO.resources_kr.python.common_keywords import CounterManager

counter_report = CounterManager()


UE_ADDRESSES = {
    "SA_DL": {"UE1": "1.2.4.2", "UE2": "1.2.4.3", "UE3": "1.2.4.4", "UE4": "1.2.4.5"},
    "SA_UL": {"UE1": "72.23.0.1", "UE2": "72.24.0.1", "UE3": "72.25.0.1", "UE4": "72.26.0.1"},
    "NSA_DL": {"UE11": "4.7.254.208", "UE12": "4.7.254.209", "UE13": "4.7.254.210", "UE14": "4.7.254.211"},
    "NSA_UL": {"UE11": "72.22.0.2", "UE12": "72.22.0.3", "UE13": "72.22.0.4", "UE14": "72.22.0.5"}}


def run_writer(proc, logfile):
    """
    run writer - lets to write logs from server to logfile
    +------------------+-------+------------+------------+
    |     Example                                        |
    +==================+=======+============+============+
    | run writer                                         |
    | ...  proc=iperf_server                             |
    | ...  logfile=iperf_single_ue.log                   |
    +------------------+-------+------------+------------+
    :param proc:        iperf_server
    :param logfile:     describes where iperf logs will be saved
    :return:
    """
    output_dir = BuiltIn().get_variable_value("${OUTPUT_DIR}")
    with open(os.path.join(output_dir, logfile), "a") as iperf_log:
        for line in proc.stdout:
            iperf_log.write(str(line))
    proc.wait()


def start_iperf_server(server='10.0.2.1', port='7070', server_logfile='iperf_server.log'):
    """
    start iperf server
    +------------------+-------+------------+------------+
    |     Example                                        |
    +==================+=======+============+============+
    | start iperf server                                 |
    | ...  server=10.0.2.1                               |
    | ...  port=7070                                     |
    | ...  logfile=multiple_ues.log                      |
     +------------------+-------+------------+------------+
    :param server:       server ip taken from dl_nat_gw/ul_nat_gw(10.0.2.1) in file basic_config.cfg
                        set_pdu_gateway id=1 ue_nat_ip=72.23.0.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    :param port:        port on which server is listening messages
    :param logfile:     describes where iperf logs should be saved
    :return:
    """
    iperf_server_cmd = ['iperf', '-s', '-p', port, '-i', '1', '-B', server, '-u']
    logger.info(f'Executing {" ".join(iperf_server_cmd)} ...', also_console=True)
    iperf_server = subprocess.Popen(iperf_server_cmd, stdout=subprocess.PIPE, universal_newlines=True)
    thread = threading.Thread(target=run_writer, args=(iperf_server, server_logfile))
    thread.start()
    return iperf_server


def start_iperf_client(client, throughput, duration, logfile, port='7070', server='10.0.2.1'):
    """
    start iperf traffic - lets to generate several traffics at the same time. Function used in other functions.
    +------------------+-------+------------+------------+
    |     Example                                        |
    +==================+=======+============+============+
    | start iperf traffic                                |
    | ...  client=1.2.4.2                                |
    | ...  throughput=10M                                |
    | ...  duration=10                                   |
    | ...  logfile=multiple_ues.log                      |
    +------------------+-------+------------+------------+
    :param client:      client ip taken from UPF_ADDR in basic_config.cfg for DL
                        and from ue_nat_ip(72.23.0.1) in file file basic_config.cfg for UL
    :param throughput:  number of packets per second for UE
    :param duration:    time in seconds to transmit for
    :param logfile:     describes where iperf logs should be saved
    :param server:      server ip taken from dl_nat_gw/ul_nat_gw(10.0.2.1) in file basic_config.cfg
                        set_pdu_gateway id=1 ue_nat_ip=72.23.0.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    :param port:        port on which server is listening messages
    :return:
    """
    iperf_client_cmd = \
        ['iperf', '-c', client, '-p', port, '-l', '1400', '-b', throughput, '-i', '1', '-t', duration,
         '-B', server, '-u']
    logger.info(f'Executing {" ".join(iperf_client_cmd)} ...', also_console=True)
    iperf_client = subprocess.Popen(iperf_client_cmd, stdout=subprocess.PIPE, universal_newlines=True)
    thread = threading.Thread(target=run_writer, args=(iperf_client, logfile))
    thread.start()
    return iperf_client


def start_throughput_on_single_ue(tput_type, ue, tput, duration, logfile='iperf_server_single_ue.log',
                                  client_logfile='iperf_client_single_ue.log'):
    """
    start throughput on single ue - generates traffic on 1 UE, saves logs to given logfile
    +------------------+-------+------------+------------+
    |     Example                                        |
    +==================+=======+============+============+
    | start throughput on single ue                      |
    | ...  tput_type=SA_UL                               |
    | ...  ue=UE1                                        |
    | ...  tput=5M                                       |
    | ...  duration=10                                   |
    | ...  logfile=iperf_server_multi_ues.log            |
    | ...  client_logfile=iperf_client_multi_ues.log     |
    +------------------+-------+------------+------------+
    :param tput_type:       describes model of 5G deployment(SA/NSA) and direction of tput(UL/DL),
                            helps to find proper ip_address for given UE from UE_ADDRESSES
                            (SA_DL, SA_UL, NSA_DL or NSA_UL)
    :param ue:              describes on which UE traffic should be generated
    :param tput:            number of packets per second for UE
    :param duration:        time in seconds to transmit for
    :param logfile:         describes where iperf logs from server will be saved
    :param client_logfile:  describes where iperf logs from client will be saved

    :return:
    """
    iperf_server = start_iperf_server(server_logfile=logfile)
    client = UE_ADDRESSES[tput_type][ue]
    iperf_client = start_iperf_client(client, tput, duration, client_logfile)
    iperf_client.wait()
    time.sleep(2)
    iperf_server.kill()


def start_throughput_on_three_ues(tput_type, tput1, tput2, tput3, duration, logfile='iperf_server_multi_ues.log',
                                  client_logfile='iperf_client_multi_ues.log'):
    """
    start throughput on three ues - generates traffics on 3 UEs at the same time, saves logs to given logfile
    +------------------+-------+------------+------------+
    |     Example                                        |
    +==================+=======+============+============+
    | start throughput on three ues                      |
    | ...  tput_type=SA_UL                               |
    | ...  tput1=5M                                      |
    | ...  tput2=25M                                     |
    | ...  duration=10                                   |
    | ...  tput3=45M                                     |
    | ...  duration=20                                   |
    | ...  logfile=iperf_server_multi_ues.log            |
    | ...  client_logfile=iperf_client_multi_ues.log     |
    +------------------+-------+------------+------------+
    :param tput_type:   describes model of 5G deployment and direction of tput(UL/DL),
                        helps to find proper ip_address for given UE from ue_addresses
                        (SA_DL, SA_UL, NSA_DL or NSA_UL)
    :param tput1:       number of packets per second for second UE
    :param tput2:       number of packets per second for third UE
    :param tput3:       number of packets per second for fourth UE
    :param duration:    time in seconds to transmit for
    :param logfile:     describes where iperf logs should be saved
    :param client_logfile:  describes where iperf logs from client will be saved
    :return:
    """
    iperf_server = start_iperf_server(server_logfile=logfile)
    processes = []
    if "NSA" in tput_type:
        processes.append(start_iperf_client(UE_ADDRESSES[tput_type]["UE12"], tput1, duration, client_logfile))
        processes.append(start_iperf_client(UE_ADDRESSES[tput_type]["UE13"], tput2, duration, client_logfile))
        processes.append(start_iperf_client(UE_ADDRESSES[tput_type]["UE14"], tput3, duration, client_logfile))
    else:
        processes.append(start_iperf_client(UE_ADDRESSES[tput_type]["UE2"], tput1, duration, client_logfile))
        processes.append(start_iperf_client(UE_ADDRESSES[tput_type]["UE3"], tput2, duration, client_logfile))
        processes.append(start_iperf_client(UE_ADDRESSES[tput_type]["UE4"], tput3, duration, client_logfile))
    for process in processes:
        process.wait()
    time.sleep(2)
    iperf_server.kill()


def calculate_value_margin(margin, value):
    """
    Calculate value margin
    :param margin: estimated margin error given in percents
    :param value: expected value
    :return: min range and max range valuess
    """
    margin = float(margin.strip('%')) / 100
    return float(value) * (1 - margin), float(value) * (1 + margin)


def get_counter_values(counter_id, local_moid, pm_counter_file):
    """
    Gets counter value
    :param counter_id: name of the counter
    :param local_moid: path to the counter
    :param pm_counter_file: path to the PM counter file
    :return: Value of the desired counter
    """
    counter_values = ta5g_pm_counters().get_pm_counter_value(counter_id, local_moid, pm_counter_file)
    if len(counter_values) == 0:
        raise ExecutionFailed(
            message=f'The PM counter {counter_id} doesn\'t have values',
            continue_on_failure=True,
        )
    else:
        return counter_values


def get_values_of_specific_counters(counter_ids, local_moid, counter_file_path):
    """
    Gets values of counters specified by counter_ids
    :param counter_ids: dictionary mapping counter names to counter ids
    :param local_moid: path to the counters
    :param counter_file_path: path to the PM counter file
    :return: dictionary mapping counter names to counter values
    """
    counter_values = {}
    for counter_name in counter_ids:
        counter_values[counter_name] = get_counter_values(counter_ids[counter_name], local_moid, counter_file_path)
    return counter_values


def check_counter_value(counter_id, pm_counters_values, expected_value, margin='10%'):
    """
    Check if counters have desired value within margin
    :param counter_id: name of the counter
    :param pm_counters_values: collected PM Counter values
    :param expected_value: expected PM Counter value
    :return: Value of the desired counter
    """
    margin_range = calculate_value_margin(margin, expected_value)
    if type(pm_counters_values) is not list:
        values = [pm_counters_values]
    else:
        values = pm_counters_values
    for counter_value in values:
        if (float(counter_value) < min(margin_range)) or (float(counter_value) > max(margin_range)):
            raise ExecutionFailed(
                message=f'The PM counter {counter_id} doesn\'t have value in range '
                        f'({min(margin_range)} - {max(margin_range)}) Current value - {counter_value}',
                continue_on_failure=True,
            )


def get_nonzero_counter_values(counter_id, local_moid, pm_counter_file):
    """
    Gets value of the counter specified by counter_id
    :param counter_id: name of the counter
    :param local_moid: path to the counter
    :return: value of the specified counter as a non zero integer
    """
    counter_nonzero_values = ta5g_pm_counters().get_pm_counter_value(counter_id, local_moid, pm_counter_file)
    for pm_counter_values in counter_nonzero_values:
        if pm_counter_values != 0:
            return pm_counter_values
        else:
            break


def set_parameter_in_all_objects_to_value(parameter, value, object_name='NRDRB', nested_param=None):
    """
    Sets parameter value in multiple objects of the same type, by creating ad-hoc yaml configuration file.
    :param parameter: name of the parameter
    :param value: desired value of parameter
    :param object_name: name of the object where parameter is stored
    :param nested_param: name of the nested parameter (if present)
    """
    yaml_path = f'/tmp/{parameter}.yaml'
    with open(yaml_path, 'w') as yaml:

        for object_id in range(1, 15):
            if nested_param:
                yaml.write(f'- ID: \'{object_id}\'\n  MOC: {object_name}\n'
                           f'  {parameter}:\n  - {nested_param}: {value}\n')
            else:
                yaml.write(f'- ID: \'{object_id}\'\n  MOC: {object_name}\n  {parameter}: {value}\n')

    emssim = ta_emss(host='10.0.1.1', port=4001)
    emssim.configure(yaml_path)


def start_throughput_to_sweep_through_provided_counters(tput_type, ue, duration, logfile='iperf_server_single_ue.log',
                                                        tput_delay=1, **throughputs):
    """
    Starts throughput on ue with various speed levels in order to increment certain counters.
    +------------------+-------+------------+-----------------+
    |     Example                                             |
    +==================+=======+============+=================+
    | Start throughput to sweep through provided counters     |
    | ...  tput_type=SA_DL                                    |
    | ...  ue=UE1                                             |
    | ...  duration=10                                        |
    | ...  logfile=single_ue.log                              |
    | ...  BIN1_tput=10m    BIN2_tput=22m     BIN3_tput=25m   |
    | ...  BIN4_tput=28m    BIN5_tput=32m     BIN6_tput=36m   |
    | ...  BIN7_tput=40m    BIN8_tput=45m     BIN9_tput=51m   |
    | ...  BIN10_tput=58m   BIN11_tput=66m    BIN12_tput=73m  |
    | ...  BIN13_tput=83m   BIN14_tput=95m    BIN15_tput=105m |
    | ...  BIN16_tput=120m  BIN17_tput=135m   BIN18_tput=150m |
    | ...  BIN19_tput=175m  BIN20_tput=200m                   |
    +------------------+-------+------------+-----------------+
    :param tput_type:   describes model of 5G deployment and direction of tput(UL/DL),
                        helps to find proper ip_address for given UE from UE_ADDRESSES
                        (SA_DL, SA_UL, NSA_DL or NSA_UL)
    :param ue:          UE ID
    :param duration:    duration of the throughput bursts
    :param duration:    time in seconds to transmit for
    :param logfile:     describes where iperf logs should be saved
    :param tput_delay:  describes delay between throughput bursts
    :param throughputs: Dictionary which contains throughput levels to be used in order to increment provided counters
    """
    for tput in throughputs.values():
        start_throughput_on_single_ue(tput_type, ue, tput, duration, logfile=logfile)
        time.sleep(tput_delay)
