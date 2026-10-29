# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: 5G_SW_WRO
:contact: I_MBB_LTE_DEVWRO1_TEST_GMS <I_MBB_LTE_DEVWRO1_TEST@internal.nsn.com>
"""

import time
import io
from taf.gnb.oam.coam.admin import admin
from robot.errors import ExecutionFailed
from robot.api import logger
from ta5g_setups_and_teardowns import ta5g_setups_and_teardowns
from ta5g_commissioning import ta5g_commissioning
from ta5g_testline_management import ta5g_testline_management
from ta5g_iphy import ta5g_iphy
from ta5g_tshark import ta5g_tshark
import datetime as dt
import math


def update_airphone_configuration_and_perform_full_commissioning(iphy_xml_filepath, scfc_filename,
                                                                 output_dirpath=None):
    ta5g_setups_and_teardowns().start_default_logging(output_dirpath=output_dirpath)
    try:
        ta5g_setups_and_teardowns().update_iphy_configuration_and_modify_swconfig(
            iphy_xml_filepath=iphy_xml_filepath,
            output_dirpath=output_dirpath
        )
        ta5g_commissioning().find_scfc_and_fix_and_send_full_commissioning(
            scfc_filename=scfc_filename, output_dirpath=output_dirpath
        )
        ta5g_testline_management().reset_testline()
        ta5g_iphy().check_radios_availability()
    finally:
        ta5g_setups_and_teardowns().stop_default_logging(output_dirpath)


def check_regexp_presence(syslog_path, regexp='regexp'):
    with io.open(syslog_path, encoding='utf-8') as file:
        if regexp in file.read():
            logger.info('regexp available', also_console=True)
            return True
        else:
            raise Exception("regexp not available")
    file.close()


def perform_full_commissioning(scfc_filename, output_dirpath=None):
    ta5g_setups_and_teardowns().start_default_logging(output_dirpath=output_dirpath)
    try:
        ta5g_commissioning().find_scfc_and_fix_and_send_full_commissioning(
            scfc_filename=scfc_filename, output_dirpath=output_dirpath
        )
        ta5g_testline_management().reset_testline()
        ta5g_iphy().check_radios_availability()
    finally:
        ta5g_setups_and_teardowns().stop_default_logging(output_dirpath)


def calculate_and_return_ue_config_bwp_counters_values(alias1, filter1, filter2, filter3, filter4,
                                                       output_pdml_filepath1, output_pdml_filepath2,
                                                       output_pdml_filepath3, output_pdml_filepath4,
                                                       pcap_file_path=None):
    time_format = '%H:%M:%S.%f'
    t1 = dt.datetime.strptime(ta5g_tshark().get_time_from_tshark_message(alias1, filter1, output_pdml_filepath1,
                              pcap_file_path), time_format)
    t2 = dt.datetime.strptime(ta5g_tshark().get_time_from_tshark_message(alias1, filter2, output_pdml_filepath2,
                              pcap_file_path), time_format)
    t3 = dt.datetime.strptime(ta5g_tshark().get_time_from_tshark_message(alias1, filter3, output_pdml_filepath3,
                              pcap_file_path), time_format)
    t4 = dt.datetime.strptime(ta5g_tshark().get_time_from_tshark_message(alias1, filter4, output_pdml_filepath4,
                              pcap_file_path), time_format)
    list_of_times = [t1, t2, t3, t4]
    list_of_times_in_pm_interval = [t4]
    counter_max = 1
    list_index = -1
    while list_of_times[list_index].minute % 5 >= list_of_times[list_index - 1].minute % 5:
        counter_max += 1
        list_of_times_in_pm_interval.append(list_of_times[list_index - 1])
        list_index -= 1
        if list_index == -4:
            break
    modulo_start = list_of_times_in_pm_interval[-1].minute % 5
    time_start = (list_of_times_in_pm_interval[-1] - dt.timedelta(minutes=int(modulo_start))).replace(second=00)
    modulo_end = t4.minute % 5
    time_end = (t4 + dt.timedelta(minutes=int(5-modulo_end))).replace(second=00)
    list_of_times_in_pm_interval.insert(0, time_end)
    list_of_times_in_pm_interval.insert(len(list_of_times_in_pm_interval), time_start)
    list_of_times_in_pm_interval = sorted(list_of_times_in_pm_interval)
    counter_avg = 0
    for element in range(len(list_of_times_in_pm_interval)-1):
        counter_avg += element * ((list_of_times_in_pm_interval[element+1] -
                                   list_of_times_in_pm_interval[element]).total_seconds())
    counter_avg = int(round((counter_avg)/300))
    return [counter_max, counter_avg]


def return_counter_M55351C01001(counters):
    counter_max = counters[0]
    return str(counter_max)


def return_counter_M55351C01002(counters):
    counter_avg = counters[1]
    return str(counter_avg)
