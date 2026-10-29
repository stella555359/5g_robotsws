"""
:copyright: Nokia Networks
:author: Gall Anonim
:maintainer: Mateusz Bilewicz
:contact: mateusz.bilewicz@nokia.com
:team: MN_RAN_L2_SW_WRO_7_SG
:description: Small set of functions allowing for PM counters collection and validation
:justification: The file originates from testsuite/RRM/Krakow/resources/pm_counters.py,
                unfortunately I could not reuse it, as the interface to admin api library used here
                was not consistent with the one I was using, and thus resulted in random hangs from admin api side.
"""

from robot.libraries.BuiltIn import BuiltIn
from ta5g_pm_counters import ta5g_pm_counters
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.common_gnb import (
    handle_admin, get_mrbts_nrbts_ids, get_parameter_value_from_scf
)
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.common_vdu import vDU
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.utilities import (
    logger_console, logger_console_info, logger_warning
)
import robot.api.logger as logger
import datetime
import operator
import time
import re
import os


class CounterNotFound(Exception):
    pass


class WrongFormat(Exception):
    pass


def get_library_instance(library):
    instance = BuiltIn().get_library_instance(library)
    if not instance:
        raise ImportError("Unable to access %s instance, check if library is imported" % instance)
    return instance


def verify_if_counter_is_incremented_correctly(counter_id, nr_cell_id=None, expected_value=1):
    """Checks if selected counter has specified expected value

    :param counter_id: counter id eg: M55117C02003
    :param nr_cell_id: cell id as denoted in SCF by NRCELL object
    :param expected_value: value that is expected of the counter
    """
    period, counter_value = get_latest_counter_value(counter_id, nr_cell_id)
    print("Counter value: {} Counter period: {}".format(counter_value, period))
    assert counter_value == expected_value, "Value for period {} is {} but expected is {}".\
        format(period, counter_value, expected_value)


def wait_for_next_pm_period(interval=15, delay=30):
    """Sleeps until interval starts. Unit is minutes, default value 15min"""
    next_pm_period = int(interval) * 60 - time.time() % (int(interval) * 60)
    time.sleep(next_pm_period + delay)


def wait_for_next_pm_period_aic():
    du = vDU()
    mrbts_id = BuiltIn().get_variable_value("${MRBTS_ID}")
    meas_period = int(du.get_meas_period_from_vdu(mrbts_id).strip('min'))
    wait_for_next_pm_period(interval=meas_period, delay=30)


@handle_admin
def get_latest_counter_value(counter_id, nr_cell_id=None, dist_name='', *args, **kwargs):
    """

    :param counter_id: counter id eg: M55117C02003
    :param dist_name: eg: BTS/BTS/NRBTS-1/NRDU-1/NF1CD . It's optional parameter.
                      If not defined, it's get automatically.
    :param nr_cell_id: If you would like get counter for particular nrcell.
    :return:
    """
    counters = kwargs["connection"].get_pm_counters(couter_ids=counter_id)
    return _get_latest_counter_value(counters, counter_id, nr_cell_id, dist_name)


@handle_admin
def get_pm_counters_values(counter_ids_list, *args, **kwargs):
    """Get counter data from admin api

    :param counter_ids_list: counter id eg: M55117C02003
    :return:
    """
    return kwargs["connection"].get_pm_counters(couter_ids=",".join(counter_ids_list))


def get_latest_values_for_specified_counters(counter_ids_list, nr_cell_id=None, dist_name='', *args, **kwargs):
    """

    :param counter_ids_list: counter id list eg: ["M55117C02003", ]
    :param dist_name: eg: BTS/BTS/NRBTS-1/NRDU-1/NF1CD . It's optional parameter.
                      If not defined, it's get automatically.
    :param nr_cell_id: If you would like get counter for particular nrcell.
    :return:
    """
    counters_data = kwargs.pop('counters_data', None)
    if not counters_data:
        counters_data = get_pm_counters_values(counter_ids_list=counter_ids_list)
    logger.info("PM Counters: {}".format(counters_data))
    flattened_counters_data = _flatten(counters_data)
    logger.info("flattened_counters_data: {}".format(flattened_counters_data))
    latest_counter_values = {}
    for counter_id in counter_ids_list:
        latest_value = _get_latest_counter_value_from_flattened_data_dict(
            counter_id=counter_id, counters_dict=flattened_counters_data, nr_cell_id=nr_cell_id)
        latest_counter_values[counter_id] = latest_value
    return latest_counter_values


def check_if_latest_counters_values_satisfy_the_expression(comparison_operator, value, counter_ids_list, nr_cell_id):
    ops = {">": operator.gt, ">=": operator.ge, "<": operator.lt, "==": operator.eq, "!=": operator.ne}
    counter_values = get_latest_values_for_specified_counters(counter_ids_list=counter_ids_list, nr_cell_id=nr_cell_id)
    logger.info("Latest PM Counter values: {}".format(counter_values))
    bool_result = {}
    for counter in counter_ids_list:
        bool_result[counter] = ops[comparison_operator](counter_values[counter], value)
    assert all(bool_result.values()), "Counters: {} do not satisfy the expression {} {}".format(
        [counter_id for counter_id, result in bool_result.items() if result is False], comparison_operator, value)
    logger_console_info("Counters satisfy the expression: {} {}".format(comparison_operator, value))


def _flatten(d, parent_key='', sep='_'):
    items = []
    for k, v in d.items():
        new_key = parent_key + sep + k if parent_key else k
        if isinstance(v, dict) and not re.search(r"^M.*\d+$", k):
            items.extend(_flatten(v, new_key, sep=sep).items())
        else:
            items.append((new_key, v))
    return dict(items)


def _get_latest_counter_value_from_flattened_data_dict(counter_id, counters_dict, nr_cell_id=None):
    def get_latest_value(dictionary, key):
        sorted_timestamps = sorted(counters_dict[key].keys(), reverse=True)
        latest_timestamp = sorted_timestamps[0]
        latest_counter_value = counters_dict[key][latest_timestamp]
        return latest_counter_value
    for key in counters_dict.keys():
        if counter_id in key:
            if nr_cell_id:
                if "NRCELL-{}".format(nr_cell_id) in key:
                    return get_latest_value(counters_dict, key)
            else:
                if "NRCELL" not in key:
                    return get_latest_value(counters_dict, key)
    raise CounterNotFound("Counter {} could not have been found".format(counter_id))


def verify_any_counters(*args, **kwargs):
    counters_data = kwargs.pop('counters_data', None)
    counters_expect_list = __parse_args(args)
    counters_list = [counter_dict["counter_id"] for counter_dict in counters_expect_list]
    if not counters_data:
        counters_data = get_pm_counters_values(counter_ids_list=counters_list)
    flattened_counters_data = _flatten(counters_data)
    results = {}
    all_counters_set = set([expect_dict['counter_id'] for expect_dict in counters_expect_list])
    for expect_dict in counters_expect_list:
        result, latest_value = __verify_counter_conditions(expect_dict, flattened_counters_data)
        results[expect_dict['counter_id']] = {"result": result,
                                              "latest_value": latest_value,
                                              "expect_dict": expect_dict}

    results_bools_list = [result_dict["result"] for counter, result_dict in results.items()]
    failed_counters = [counter for counter, result_dict in results.items() if result_dict["result"] is False]
    if not all(results_bools_list):
        error_msgs = []
        for counter in failed_counters:
            comparator = results[counter]["expect_dict"]["comparator"]
            nr_cell_id = results[counter]["expect_dict"]["nr_cell_id"]
            value = results[counter]["expect_dict"]["value"]
            latest_value = results[counter]["latest_value"]
            error_string = "Counter {}(cell: {}) value: {} does not satisfy the expression {} {}".format(
                counter, nr_cell_id, latest_value, comparator, value)
            error_msgs.append(error_string)
        raise AssertionError("\n".join(error_msgs))
    logger_console_info("All counters: {} verified successfully".format(list(all_counters_set)))


def __args_to_table(args, values=2):
    parsed_data = []
    for num in range(0, len(args), values):
        try:
            data_set = args[num:num + values]
            data_set_size = len(data_set)
            assert data_set_size == values
            if data_set_size == 1:
                parsed_data.append(data_set[0])
            else:
                parsed_data.append(data_set)
        except AssertionError:
            raise ValueError('Data subsets are incomplete or inconsistent')
    return parsed_data


def __parse_args(args):
    parsed_expectations = []
    expectations_table = __args_to_table(args, values=3)
    for counter_id, expectations, nr_cell_id in expectations_table:
        match = re.search(r"\d+", expectations)
        if not match:
            raise WrongFormat("Could not parse the number from expectation string")
        value = int(match.group(0))
        comparator = expectations.split(str(value))[0].strip()
        parsed_expectations.append({'counter_id': counter_id, 'comparator': comparator,
                                    "value": value, 'nr_cell_id': nr_cell_id})
    return parsed_expectations


def __verify_counter_conditions(expect_dict, counters_data):
    ops = {">": operator.gt, ">=": operator.ge, "<": operator.lt, "==": operator.eq, "!=": operator.ne}
    counter_id = expect_dict['counter_id']
    nr_cell_id = expect_dict['nr_cell_id']
    comparator = expect_dict['comparator']
    value = expect_dict['value']
    latest_value = _get_latest_counter_value_from_flattened_data_dict(
        counter_id=counter_id, counters_dict=counters_data, nr_cell_id=nr_cell_id)
    return ops[comparator](latest_value, value), latest_value


@handle_admin
def get_latest_counter_value_for_all_cells(counter_id, *args, **kwargs):
    values = {}
    counters = kwargs["connection"].get_pm_counters(couter_ids=counter_id)
    nr_cell_ids = get_all_nrcell_ids()
    for nr_cell_id in nr_cell_ids:
        values[nr_cell_id] = _get_latest_counter_value(counters, counter_id, nr_cell_id)

    return values


@handle_admin
def get_all_nrcell_ids(*args, **kwargs):
    nr_cells = set()
    subcell_info = kwargs["connection"].get_subcells_info()
    for cell_group in subcell_info:
        for cell in subcell_info[cell_group]:
            for subcell in subcell_info[cell_group][cell]:
                nr_cell_id = subcell_info[cell_group][cell][subcell]['parameters']['nrCellIdentity']
                if nr_cell_id:
                    nr_cells.add(nr_cell_id)

    return nr_cells


def _get_latest_counter_value(counters, counter_id, nr_cell_id=None, dist_name=''):
    if not dist_name:
        dist_name = _find_dist_name(counters, nr_cell_id)

    counter_values = _get_counter_values(counters, dist_name)

    sorted_timestamps = sorted(counter_values[counter_id].keys(), reverse=True)
    latest_timestamp = sorted_timestamps[0]
    latest_counter_value = counter_values[counter_id][latest_timestamp]

    return latest_timestamp, latest_counter_value


def _find_dist_name(counters, nr_cell_id=None):
    def build_dist_path(counters_dict, dist_path=''):
        for key in counters_dict:
            recursive_flag = False
            if len(counters_dict.keys()) == 1 and not re.search(r"^M.*\d+$", key):
                recursive_flag = True
            elif len(counters_dict.keys()) > 1 and re.search(r"^NRCELL-", key):
                key = "NRCELL-{}".format(nr_cell_id)
                recursive_flag = True

            if recursive_flag:
                new_dist_path = "{}/{}".format(dist_path, key)
                dist_path = build_dist_path(counters_dict[key], new_dist_path)
                break
        return dist_path

    dist_name = build_dist_path(counters)
    dist_name = dist_name.strip("/")
    return dist_name


def _get_counter_values(counters, dist_name):
    dist_name = dist_name.strip("/")
    dist_keys = dist_name.split('/')
    for key in dist_keys:
        counters = counters[key]
    return counters


def _get_counter_values_for_multiple_counters(counters, dist_name):
    dist_name = dist_name.strip("/")
    dist_keys = dist_name.split('/')
    for key in dist_keys:
        counters = counters[key]
    if all([not re.search(r"^M.*\d+$", key) for key in counters.keys()]):
        counters_merged = {}
        for key in counters.keys():
            counters_merged.update(counters[key])
        logger.info("Counter merged: {}".format(counters_merged))
        counters = counters_merged
    return counters


def wait_for_next_pm_period_if_little_time_left(min_minutes_left=5, interval=15):
    """
    Sleeps until new interval starts if current interval ends in less than min_minutes_left.

    :param min_minutes_left:    int, Minimum number of minutes left in current interval
    :param interval:            int, PM Counters period in minutes
    """
    delay = 10
    seconds_left = int(interval) * 60 - time.time() % (int(interval) * 60)
    if seconds_left < min_minutes_left * 60:
        time.sleep(seconds_left + delay)


def get_last_quarter(time_offset=None):
    """
    :param time_offset:    int, When provided, the returned time is UTC shifted by that many hours
    """
    if time_offset:
        date = datetime.datetime.utcnow() + datetime.timedelta(hours=time_offset)
    else:
        date = datetime.datetime.now()
    date = date.replace(minute=15 * (date.minute // 15))
    return date.strftime("%Y-%m-%d %H:%M:00")


def check_pm(cells=[1], counter_list=None):
    """
    Downloads pm counters file from gnb and checks if counters changed correctly for all cells.

    :param cells:           list of nrCellIds
    :param counter_list:    list of pm counters to check with constraints and names to display:
                            counter_list = ['M55303C14001', '>0', 'PUCCH_FORMAT1_NON_DTX',
                                            'M55303C13001', '0', 'PUCCH_FORMAT1_DTX']
                            for more information check ta5g_pm_counters documentation
    """
    pm = get_library_instance("ta5g_pm_counters")
    out_dir = BuiltIn().get_variable_value("${OUTPUT_DIR}")
    mrbts, nrbts = get_mrbts_nrbts_ids()
    pm_file = pm.get_latest_unpacked_full_pm_counters_file(output_dirpath=out_dir, remote_host=None)
    for cell in cells:
        mo_id = "PLMN-PLMN/MRBTS-{}/NRBTS-{}/NRCELL-{}".format(mrbts, nrbts, cell)
        pm.verify_last_counters_in_file(*counter_list, local_moid=mo_id, file_path=pm_file)


def verify_if_any_counter_from_list_incremented(counter_list, cells=[1]):
    """
        Author: Damian Piasecki
        Contact: damian.piasecki@nokia.com
        Creation Date: 28.06.2021
        Modified Date: -

        The function verifies if any counter from a given counter list incremented

        Args:
            counter_list(list): List of counters IDs

        Returns:
            None
    """
    pm = get_library_instance("ta5g_pm_counters")
    out_dir = BuiltIn().get_variable_value("${OUTPUT_DIR}")
    mrbts, nrbts = get_mrbts_nrbts_ids()
    file = pm.get_latest_unpacked_full_pm_counters_file(output_dirpath=out_dir, remote_host=None)
    for cell in cells:
        mo_id = "PLMN-PLMN/MRBTS-{}/NRBTS-{}/NRCELL-{}".format(mrbts, nrbts, cell)
        values_list = []
        for counter in counter_list:
            counter_values_list = pm.get_pm_counter_value(counter=counter, localmoid=mo_id, filepath=file)
            counter_value = counter_values_list[-1]
            values_list.append(counter_value)
        sum_values = sum(values_list)
        assert sum_values > 0, \
            "Sum of counters values {} is not greater than 0. No counter has increased.".format(sum_values)


def verify_if_counters_from_list_not_incremented(counter_list, first_file, second_file, cells=[1]):
    """
        Author: Damian Piasecki
        Contact: damian.piasecki@nokia.com
        Creation Date: 28.06.2021
        Modified Date: -

        The function verifies if any counter from a given counter list incremented

        Args:
            counter_list(list): List of counters IDs
            first_file: PM counters file that was got in the first phase of the test (e.g before UE attach)
            second_file: PM counters file that was got in the second phase of the test (e.g after e UE attach)

        Returns:
            None
    """
    pm = get_library_instance("ta5g_pm_counters")
    mrbts, nrbts = get_mrbts_nrbts_ids()
    for cell in cells:
        mo_id = "PLMN-PLMN/MRBTS-{}/NRBTS-{}/NRCELL-{}".format(mrbts, nrbts, cell)
        prev_values_list = []
        next_values_list = []
        for counter in counter_list:
            prev_counter_values_list = pm.get_pm_counter_value(counter=counter, localmoid=mo_id, filepath=first_file)
            prev_counter_value = prev_counter_values_list[-1]
            prev_values_list.append(prev_counter_value)
            next_counter_values_list = pm.get_pm_counter_value(counter=counter, localmoid=mo_id, filepath=second_file)
            next_counter_value = next_counter_values_list[-1]
            next_values_list.append(next_counter_value)
        prev_sum_values = sum(prev_values_list)
        next_sum_values = sum(next_values_list)
        assert next_sum_values == prev_sum_values, \
            "Sum of counters values {} is greater than {}. " \
            "Some counter has increased.".format(next_sum_values, prev_sum_values)


def wait_next_meas_period(meas_period=300, add_time=30, with_console_output=False):
    """Author: Nikolay Shkulepov; Abstraction Level is LOW
    introduced 30s delay time, for writing pm counter files

    :param meas_period -> int
    :param with_console_output -> Boolean (default False)"""
    logger.debug("============================== Begin wait_next_meas_period()")
    logger.debug("wait_next_meas_period: meas_period = {} ".format(meas_period))
    start_time = time.time()
    logger.debug("wait_next_meas_period: start_time='{}' started".format(start_time))
    delta = meas_period
    if with_console_output:
        logger.console(" Wait next measurement period: ({}) ".format(datetime.datetime.fromtimestamp(
            int(time.time()))), newline=False)
    counter = 0
    while delta > 0:
        time.sleep(1)
        delta = meas_period - time.time() + start_time
        if int(time.time() - int(add_time)) % meas_period == 0:
            break
        counter += 1
        if counter % 30 == 0 and with_console_output:
            logger.console(".", newline=False)
    if with_console_output:
        logger.console(".done (%s)" % datetime.datetime.fromtimestamp(int(time.time())))
    logger.debug("wait_next_meas_period: start_time='{}' finished with wait of {} min {} sec".format(
        start_time, counter/60, counter % 60))
    logger.debug("============================== End wait_next_meas_period()")


def modify_value_in_counter_list(counter_list, new_value=0, constraint='', default_counter='M55303C17001'):
    """
    Author: Szymon Lange
    Contact: szymon.lange@nokia.com
    Creation Date: 26.08.2021
    Modified Date: 21.12.2021

    Replace default tolerance in a counter with another value and constraint.

    :param counter_list: (list) List of pm counters to check with constraints and names to display:
        counter_list = ['M55303C14001', '>0', 'PUCCH_FORMAT1_NON_DTX', 'M55303C13001', '0', 'PUCCH_FORMAT1_DTX']
        for more information check ta5g_pm_counters documentation
    :param new_value: (int) New counter tolerance
    :param constraint: (str) check ta5g_pm_counters documentation for possible values
    :param default_counter: (str) Counter for which tolerance is replaced
    :return counter_list: (list) Modified counter list
    """
    where = counter_list.index(default_counter) + 1
    counter_list[where] = constraint + str(new_value)
    return counter_list


def get_latest_counter_values_for_cells(counter_id, cells=[1]):
    """
    Author: Szymon Lange
    Contact: szymon.lange@nokia.com
    Creation Date: 26.08.2021
    Modified Date: 10.11.2021

    Get latest counter value for specified cells.

    :param counter_id: (str) Counter name
    :param cells: (list) List with cell's ids for which counter will be check
    """
    pm = BuiltIn().get_library_instance("ta5g_pm_counters")
    output_dir = BuiltIn().get_variable_value("${OUTPUT_DIR}")
    mrbts, nrbts = get_mrbts_nrbts_ids()
    pm_file = pm.get_latest_unpacked_full_pm_counters_file(output_dirpath=output_dir, remote_host=None)
    counter_values = {}
    for cell in cells:
        mo_id = "PLMN-PLMN/MRBTS-{}/NRBTS-{}/NRCELL-{}".format(mrbts, nrbts, cell)
        counter_values[cell] = pm.get_latest_pm_counter_value(counter_id, mo_id, pm_file)
    return counter_values


def check_pm_counters_for_cells_with_transient_phase(counter_list, forced_cells=[1], num_of_ues=1):
    """
    Author: Szymon Lange
    Contact: szymon.lange@nokia.com
    Creation Date: 26.08.2021
    Modified Date: 28.12.2021

    Validate PM counters consulting transient phase - allowed DTXs are ignored.

    :param counter_list: List of counters to be validated.
    :param forced_cells: List with cell's ids for which counters will be validated.
    :param num_of_ues:      Number of UEs attached in test.
    """
    ues_per_cell = int(num_of_ues)/len(forced_cells)
    dtx_f3_transient_phase = get_latest_counter_values_for_cells(counter_id='M55303C28002', cells=forced_cells)
    for cell in forced_cells:
        counter_list = modify_value_in_counter_list(counter_list, dtx_f3_transient_phase[cell]+ues_per_cell, '<=')
        check_pm([cell], counter_list)


def get_measurement_period_from_scf():
    """
    Get the measurement period interval from SCF.
    :return: meas_period (str)
    """
    mrbts_id, _ = get_mrbts_nrbts_ids()
    meas_period = get_parameter_value_from_scf(
        dist_name='MRBTS-{}/MNL-1/MNLENT-1/PMCADM-1'.format(mrbts_id),
        parameter='reportingIntervalPm'
    )
    return meas_period


def wait_for_next_measurement_period(aic=False):
    """
    Wait for the start of a next measurement period.
    :aic: (bool) if running on an AiC setup set this to True
    :return:
    """
    if aic:
        du = vDU()
        meas_period = du.get_meas_period_from_vdu()
    else:
        meas_period = get_measurement_period_from_scf()
    meas_period = int(meas_period.replace('min', '')) * 60
    wait_next_meas_period(meas_period=meas_period)


def check_pm_counters_for_all_cells(counter_list):
    """
    Execute function 'check_pm' for all cells.
    :param counter_list:
    :return:
    """
    forced_cells = get_all_nrcell_ids()
    check_pm(cells=forced_cells, counter_list=counter_list)


def get_pm_counters_file():
    """
    Download PM counters report.
    """
    now = datetime.datetime.now()
    date_time = now.strftime("%Y%m%d-%H%M%S")
    output_dirpath = os.path.join(BuiltIn().get_variable_value('${OUTPUT_DIR}'), date_time)
    pm_file = ta5g_pm_counters().get_next_unpacked_full_pm_counters_file(output_dirpath=output_dirpath)
    return pm_file
