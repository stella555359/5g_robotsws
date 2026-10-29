# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Marek Niescioruk
:contact: marek.niescioruk@nokia.com
"""

from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from robot.errors import ExecutionFailed
from tabulate import tabulate
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2Hi_WRO.resources.common_keywords_vran import get_cu_counter as cu_counter

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
        Cumulative_Time = InSession_time_cell_1
        InSession_time_cell_1 = Cumulative_Time + int(duration.split("s")[0]) * 1000
    elif int(cell_id) == 2:
        Cumulative_Time = InSession_time_cell_2
        InSession_time_cell_2 = Cumulative_Time + int(duration.split("s")[0]) * 1000


def calculate_value_margin(margin, value):
    margin = float(margin.strip('%')) / 100
    return float(value) * (1 - margin), float(value) * (1 + margin)


def verify_if_pm_counter_is_in_range_of_given_values(margin, counter_id, local_moid):
    logger.console("Counter {} verification".format(counter_id))
    InSession_time = get_nrcell_id(local_moid)
    margin_range = calculate_value_margin(margin, InSession_time)
    check_cu_counter_value(margin_range, counter_id, local_moid)


def check_cu_counter_value(margin_range, counter_id, local_moid):
    value = cu_counter(counter_id, local_moid)
    statistic_table = [["Reached Level", "Expected Min", "Expected Max"],
                       [value, min(margin_range), max(margin_range)]]
    logger.console(tabulate(statistic_table))
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


def verify_if_aic_pm_counter_is_in_range_of_given_values(margin, counter_id, local_moid):
    logger.console("Counter {} verification".format(counter_id))
    InSession_time = get_nrcell_id(local_moid)
    margin_range = calculate_value_margin(margin, InSession_time)
    check_cu_counter_value(margin_range, counter_id, local_moid)


def verify_if_aic_pmqap_counter_is_in_range_of_given_values(margin, counter_id, local_moid):
    logger.console("Counter {} verification".format(counter_id))
    InSession_time = get_nrcell_id(local_moid)
    margin_range = calculate_value_margin(margin, InSession_time)
    counter1 = cu_counter(counter_id=counter_id, local_moid=local_moid+'/NRPMQAP-1')
    counter2 = cu_counter(counter_id=counter_id, local_moid=local_moid+'/NRPMQAP-2')
    counter3 = cu_counter(counter_id=counter_id, local_moid=local_moid+'/NRPMQAP-3')
    value = int(counter1) + int(counter2) + int(counter3)
    print("Counter value: {}".format(value))
    if (float(value) < min(margin_range)) or (float(value) > max(margin_range)):
        raise ExecutionFailed(
            message="The PM counter {} doesn't have value in range ({} - {}) Current value - {}".format(
                counter_id, min(margin_range), max(margin_range), value),
            continue_on_failure=True,
        )
