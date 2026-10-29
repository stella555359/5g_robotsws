# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Marek Niescioruk
:contact: marek.niescioruk@nokia.com
"""
import time
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from robot.errors import ExecutionFailed
from tabulate import tabulate


InSession_time_cell_1 = 0
InSession_time_cell_2 = 0


def get_ue_cell_id(ue_id):
    ta5g_ue_wts = BuiltIn().get_library_instance('ute_wtssim')
    ue_disp_table = ta5g_ue_wts.execute_egate_command(cmd='ue_disp id={} type=cell'.format(ue_id), pass_regexp='cell')
    cell_id = ue_disp_table.split("cell")[1].strip().split(" ")[0]
    return cell_id


def increment_in_session_time(ue_id, duration):
    global InSession_time_cell_1
    global InSession_time_cell_2
    cell_id = get_ue_cell_id(ue_id)
    if int(cell_id) == 1:
        InSession_time_cell_1 += int(duration.split("s")[0]) * 1000
    elif int(cell_id) == 2:
        InSession_time_cell_2 += int(duration.split("s")[0]) * 1000


def increment_in_session_time_by_half(ue_id, duration):
    global InSession_time_cell_1, InSession_time_cell_2
    cell_id = get_ue_cell_id(ue_id)
    if int(cell_id) == 1:
        InSession_time_cell_1 += int(duration.split("s")[0]) * 500
    elif int(cell_id) == 2:
        InSession_time_cell_2 += int(duration.split("s")[0]) * 500


def reset_in_session_time():
    global InSession_time_cell_1, InSession_time_cell_2
    InSession_time_cell_1 = 0
    InSession_time_cell_2 = 0


def calculate_value_margin(margin, value):
    margin = float(margin.strip('%')) / 100
    return float(value) * (1 - margin), float(value) * (1 + margin)


def verify_if_pm_counter_is_in_range_of_given_values(margin, counter_id, local_moid, filepath):
    logger.console("Counter {} verification".format(counter_id))
    InSession_time = get_nrcell_id(local_moid)
    margin_range = calculate_value_margin(margin, InSession_time)
    check_counter_value(margin_range, counter_id, local_moid, filepath)


def check_counter_value(margin_range, counter_id, local_moid, filepath):
    ta5g_pm = BuiltIn().get_library_instance('ta5g_pm_counters')
    pm_counters_values_list = ta5g_pm.get_pm_counter_value(counter=counter_id, localmoid=local_moid, filepath=filepath)
    if isinstance(pm_counters_values_list, list):
        value = sum(pm_counters_values_list)
    else:
        pm_counters_values_list = [pm_counters_values_list]
        value = sum(pm_counters_values_list)
    counter_data = [["Reached Level", "Expected Min", "Expected Max"],
                    [value, min(margin_range), max(margin_range)]]
    logger.console(tabulate(counter_data))
    if (float(value) < min(margin_range)) or (float(value) > max(margin_range)):
        raise ExecutionFailed(
            message="The PM counter {} doesn't have value in range ({} - {}) Current value - {}".format(
                counter_id, min(margin_range), max(margin_range), value),
            continue_on_failure=True,
            )


def get_nrcell_id(local_moid):
    nrcell_id = local_moid.split("NRCELL-")[1]
    if int(nrcell_id) == 1:
        return InSession_time_cell_1
    elif int(nrcell_id) == 2:
        return InSession_time_cell_2


def recalculate_in_session_time(ue_id, duration, time_to_handover):
    global InSession_time_cell_1, InSession_time_cell_2
    cell_id_after_ho = get_ue_cell_id(ue_id)
    duration = int(duration.split("s")[0])
    time_to_handover = int(time_to_handover.split("s")[0])
    if int(cell_id_after_ho) == 1:
        InSession_time_cell_1 += (duration - time_to_handover) * 1000
        InSession_time_cell_2 -= (duration - time_to_handover) * 1000
    elif int(cell_id_after_ho) == 2:
        InSession_time_cell_2 += (duration - time_to_handover) * 1000
        InSession_time_cell_1 -= (duration - time_to_handover) * 1000
    time.sleep(duration - time_to_handover)
