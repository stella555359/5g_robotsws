"""
:copyright: Nokia Networks
:author: Mateusz Plinta
:maintainer: Mateusz Plinta, Bien Anna
:contact: mateusz.plinta@nokia.com, anna.bien@nokia.com
:description: Small set of functions allowing for PM counters collection and validation
:justification: The file originates from testsuite/RRM/Krakow/resources/pm_counters.py,
                unfortunately I could not reuse it, as the interface to admin api library used here
                was not consistent with the one I was using, and thus resulted in random hangs from admin api side.
"""

from robot.errors import ExecutionFailed
from robot.libraries.BuiltIn import BuiltIn
from ta5g_pm_counters import ta5g_pm_counters
from testsuite.Paris.RRM.ET.resources_KRK.python.common_gnb import (
    handle_admin, get_mrbts_nrbts_ids, get_parameter_value_from_scf, get_values_of_parameters_from_scf
)
from testsuite.Paris.RRM.ET.resources_KRK.python.utilities import (
    logger_console, logger_console_info, logger_warning
)
from collections import OrderedDict
from copy import deepcopy
import robot.api.logger as logger
import datetime
import operator as op
import itertools
import json
import time
import ast
import sys
import csv
import re
import os
import math


OPERATORS = {
    ">": op.gt, ">=": op.ge, "<": op.lt,
    "<=": op.le, "==": op.eq, "!=": op.ne
}


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
    :param expected_value: value that is expected of the counter, defaults to 1
    """
    period, counter_value = get_latest_counter_value(counter_id, nr_cell_id)
    print("Counter value: {} Counter period: {}".format(counter_value, period))
    assert counter_value == expected_value, "Value for period {} is {} but expected is {}".\
        format(period, counter_value, expected_value)


def wait_for_next_pm_period(interval=15, delay=30):
    """Sleeps until interval starts

    :param interval: time of the interval, in minutes
    :param delay: delay in seconds after interval ends
    """
    next_pm_period = int(interval) * 60 - time.time() % (int(interval) * 60)
    logger.debug("Interval is: {}".format(interval))
    logger_console_info("Next PM Period will start after: {}".format(next_pm_period))
    time.sleep(next_pm_period + delay)
    return time.time()


def wait_for_next_pm_period_with_advance(interval=15, advance=30):
    """Sleeps until next_pm_period - advance, so releases at "advance" time before the next pm period.

    :param interval: time of the interval, in minutes
    :param advance: advance in seconds before next interval starts
    """
    if advance >= int(interval) * 60:
        raise ValueError("Advance: {} shouldn't be greater than the pm_period interval time!".format(advance))
    next_pm_period = int(interval) * 60 - time.time() % (int(interval) * 60)
    next_with_advance = next_pm_period - advance
    if next_with_advance <= 0:
        next_with_advance = next_with_advance + (int(interval) * 60)
    logger_console_info("{}s will be to the next PM Period after: {}s".format(advance, next_with_advance))
    time.sleep(next_with_advance)
    return time.time()


def ensure_next_pm_period_started(previous_pm_period_start, no_of_pm_periods=1, interval=5, delay=30):
    periods = (time.time() - previous_pm_period_start) / (int(interval) * 60)
    if periods < no_of_pm_periods:
        wait_for_next_pm_period(interval=interval, delay=delay)
        ensure_next_pm_period_started(previous_pm_period_start, no_of_pm_periods, interval, delay)
    elif no_of_pm_periods <= periods < no_of_pm_periods + 1:
        return
    else:
        raise Exception("PM Period behaved unexpectedly")


@handle_admin
def get_latest_counter_value(counter_id, counters=None, nr_cell_id=None, dist_name='', timeout=120, *args, **kwargs):
    """ Get the latest timestamp and corresponding value for a counter

    :param counter_id: counter id eg: M55117C02003
    :param nr_cell_id: ID of the corresponding NRCELL object in SCF.
                       For counter corresponding to no cell, leave empty
    :param dist_name: eg: BTS/BTS/NRBTS-1/NRDU-1/NF1CD . It's optional parameter.
                      If not defined, it's got automatically.
    :param timeout: timeout in sec
    :return: (latest_timestamp, latest_counter_value)
    """
    counters = kwargs["connection"].get_pm_counters(counter_ids=counter_id, timeout=timeout)
    return _get_latest_counter_value(counters, counter_id, nr_cell_id, dist_name)


@handle_admin
def get_pm_counters_values(counter_ids_list, timeout=120, csv_filepath=None, json_filepath=None, *args, **kwargs):
    """Get counter data from admin api. Returns nested dictionary (mapped from json structure)

    :param counter_ids_list: counter ids eg: ['M55117C02003', 'M55117C02004']
    :param timeout: timeout in sec
    :param csv_filepath: file path of csv - not mandatory; if set, will generate csv with counters data
    :return: dictionary with counters as returned by admin api call
    """
    counters_data = kwargs["connection"].get_pm_counters(counter_ids=",".join(counter_ids_list), timeout=timeout)
    pretty_log_counters_data(counters_data, json_filepath=json_filepath)
    if csv_filepath:
        save_csv_with_counters_data(_flatten(counters_data), csv_filepath)
    return counters_data


def pretty_log_counters_data(counters_data, json_filepath=None):
    try:
        _counters_data = format_counters_data_to_human_readable(counters_data)
        logger.debug(json.dumps(_counters_data, indent=4))
        if json_filepath:
            directory = os.path.dirname(json_filepath)
            os.makedirs(directory, exist_ok=True)
            with open(json_filepath, "w") as json_file:
                json.dump(_counters_data, json_file, indent=4)
    except Exception as e:
        logger_warning("Exception during counters_data formatting: {}".format(e))


def format_counters_data_to_human_readable(counters_data):
    new_counters_data = deepcopy(counters_data)
    new_counters_data = _convert_counters_data_dict_time_from_epoch_to_str(new_counters_data)
    return sort_nested_dict(new_counters_data)


def _convert_counters_data_dict_time_from_epoch_to_str(counters_data):
    if isinstance(counters_data, dict):
        new_dict = {}
        for key, value in counters_data.items():
            if not re.search(r"^M\d+C\d+$", key) and isinstance(key, str) and key.isdigit():
                new_key = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(int(key)))
            else:
                new_key = key
            new_value = _convert_counters_data_dict_time_from_epoch_to_str(value)
            new_dict[new_key] = new_value
        return new_dict
    else:
        return counters_data


def get_latest_values_for_specified_counters(counter_ids_list, path_filters=None, *args, **kwargs):
    """Get latest values for multiple counters from the same cell

    :param counter_ids_list: counter id list eg: ["M55117C02003", ]
    :param counters_data: counters data collected via get_pm_counters_values, consistent with admin api
                          returned format. If not specified, the data is collected automatically
    :param path_filters: path filters can be provided either as a string denoting the path to the counter
                         (without counter ID and counter name) or as a list of strings of elements in the path
                         that the path should match
    :type path_filters: str or list of str
    :param timestamp_offset: offset for the counters values in sorted timestamp array;
                          0 means the newest counter value, 1: previous, 2: the one before the previous etc.
    :return: dictionary with ids of counters as keys and their latest value as values
    """
    timestamp_offset = kwargs.pop('timestamp_offset', 0)
    counters_data = kwargs.pop('counters_data', None)
    if not counters_data:
        counters_data = get_pm_counters_values(counter_ids_list=counter_ids_list)
    logger.info("PM Counters: {}".format(counters_data))
    flattened_counters_data = _flatten(counters_data)
    latest_counter_values = {}
    for counter_id in counter_ids_list:
        latest_value = _get_latest_counter_value_from_flattened_data_dict(
            counter_id=counter_id, counters_dict=flattened_counters_data, path_filters=path_filters,
            timestamp_offset=timestamp_offset
        )
        latest_counter_values[counter_id] = latest_value
    return latest_counter_values


def get_counter_value(counter_id, counters_data=None, path_filters=None, timestamp_offset=0, *args, **kwargs):
    """Get value for particular counter.

    :param counter_id: counter id "M55117C02003"
    :param counters_data: counters data collected via get_pm_counters_values, consistent with admin api
                          returned format. If not specified, the data is collected automatically
    :param path_filters: path filters can be provided either as a string denoting the path to the counter
                         (without counter ID and counter name) or as a list of strings of elements in the path
                         that the path should match
    :type path_filters: str or list of str
    :param timestamp_offset: offset for the counters values in sorted timestamp array;
                          0 means the newest counter value, 1: previous, 2: the one before the previous etc.
    :return: value of counter for the timestamp denoted as by timestamp_offset
    """
    return get_latest_values_for_specified_counters(counter_ids_list=[counter_id],
                                                    path_filters=path_filters,
                                                    timestamp_offset=timestamp_offset,
                                                    counters_data=counters_data
                                                    )[counter_id]


def check_if_latest_counters_values_satisfy_the_expression(comparison_operator, value, counter_ids_list, path_filters):
    """Assert latest counter value with given expression.

    :param comparison_operator: supported operators: ">", ">=", "<", "<=", "==", "!="
    :param value: value to compare to the latest counter value
    :type value: int
    :param counter_ids_list: counter id list eg: ["M55117C02003", ]
    :param path_filters:  path to counter of list of keywords in path to find the counter
    :type path_filters: str or list of str
    :return: None
    """
    counter_values = get_latest_values_for_specified_counters(counter_ids_list=counter_ids_list,
                                                              path_filters=path_filters)
    logger.info("Latest PM Counter values: {}".format(counter_values))
    bool_result = {}
    for counter in counter_ids_list:
        bool_result[counter] = OPERATORS[comparison_operator](counter_values[counter], value)
    assert all(bool_result.values()), "Counters: {} do not satisfy the expression {} {}".format(
        [counter_id for counter_id, result in bool_result.items() if result is False], comparison_operator, value)
    logger_console_info("Counters satisfy the expression: {} {}".format(comparison_operator, value))


def verify_any_counters(*args, **kwargs):
    """Verify any counters, specified in the arguments in such a way:
        counter_id, expresion, path_filters.
        Example:
            "M55138C01503", "== 0", "NRCELL-1/NRPMQAP-2",
            "M55138C02501", "== 1", ["NRCELL-1", "NRPMQAP-2"],
            counters_data=counters_data

    :param counters_data: counters data collected via get_pm_counters_values, consistent with admin api
                          returned format. If not specified, the data is collected automatically
    :param path_filters: path filters can be provided either as a string denoting the path to the counter
                         (without counter ID and counter name) or as a list of strings of elements in the path
                         that the path should match
    :param timestamp_offset: offset for the counters values in sorted timestamp array;
                          0 means the newest counter value, 1: previous, 2: the one before the previous etc.
    :param expresion: expression consists of operator and value; supported operators: ">", ">=", "<", "<=", "==", "!="
    :return: None
    """
    timestamp_offset = kwargs.pop('timestamp_offset', 0)
    counters_data = kwargs.pop('counters_data', None)
    counters_expect_list = __parse_args(args)
    counters_list = [counter_dict["counter_id"] for counter_dict in counters_expect_list]
    if not counters_data:
        counters_data = get_pm_counters_values(counter_ids_list=counters_list)
    flattened_counters_data = _flatten(counters_data)
    results = {}
    all_counters_set = set([expect_dict['counter_id'] for expect_dict in counters_expect_list])
    for expect_dict in counters_expect_list:
        result, latest_value = __verify_counter_conditions(expect_dict, flattened_counters_data, timestamp_offset)
        results[expect_dict['counter_id']] = {"result": result,
                                              "latest_value": latest_value,
                                              "expect_dict": expect_dict}

    results_bools_list = [result_dict["result"] for counter, result_dict in results.items()]
    failed_counters = [counter for counter, result_dict in results.items() if result_dict["result"] is False]
    if not all(results_bools_list):
        error_msgs = []
        for counter in failed_counters:
            comparator = results[counter]["expect_dict"]["comparator"]
            path_filters = results[counter]["expect_dict"]["path_filters"]
            value = results[counter]["expect_dict"]["value"]
            latest_value = results[counter]["latest_value"]
            error_string = "Counter {}(path_filters: {}) value: {} does not satisfy the expression {} {}".format(
                counter, path_filters, latest_value, comparator, value)
            error_msgs.append(error_string)
        raise AssertionError("\n".join(error_msgs))
    logger_console_info("All counters: {} verified successfully".format(list(all_counters_set)))


def verify_any_counters_extended(*args, **kwargs):
    """Verify expression constructed with counter_ids, specified in such a way:
        String expressions where value of a counter is to be substituted by this counter_id. Use counters_data to
        to pass the counters data to this method. This way counters_data can be collected beforehand.
        Counters in the expression can be specified in two ways:
        - ambiguous: e.g. M55138C01511, meaning that if in collected data (counters_data) dict there is more than
          one instances of this counter, the first one will be used. This way of specifying counters is good for
          counters that are sure to be singular in existance in the counters collected data (e.g. BTS counters as
          opposed to NRCELL counters)
        - direct (unambiguous) e.g. {"M55138C01511": "NRCELL-1/NRPMQAP-2"} - which is a dict comprising of key as
          counter_id and value as path_filters specified in a string

          path_filters: path filters can be provided as a string denoting the path to the counter
                         (without counter ID and counter name)
        Example:
            "M55138C01511 > 0",
            '{"M55138C01511": "NRCELL-1/NRPMQAP-2"} > 5 > M55138C01503',
            counters_data=counters_data

    :param counters_data: counters data collected via get_pm_counters_values, consistent with admin api
                          returned format. If not specified, the data is collected automatically
    :param timestamp_offset: offset for the counters values in sorted timestamp array;
                          0 means the newest counter value, 1: previous, 2: the one before the previous etc.
    :param csv_filepath: file path of csv - not mandatory; if set, will generate csv with counters data
    :return: None
    """
    operators = {ast.Add: op.add, ast.Sub: op.sub, ast.Mult: op.mul,
                 ast.Div: op.truediv, ast.Pow: op.pow, ast.BitXor: op.xor,
                 ast.USub: op.neg,
                 ast.Gt: op.gt, ast.GtE: op.ge, ast.Lt: op.lt,
                 ast.LtE: op.le, ast.Eq: op.eq, ast.NotEq: op.ne
                 }

    def merge_two_dicts(x, y):
        z = x.copy()
        z.update(y)
        return z

    def get_counter_data(counter_id, path_filters=None):
        return _get_latest_counter_value_from_flattened_data_dict(
            counter_id=counter_id,
            counters_dict=flattened_counters_data,
            path_filters=path_filters,
            timestamp_offset=timestamp_offset
        )

    def eval_(node, values):
        if isinstance(node, ast.Num):  # <number>
            return node.n, values
        elif isinstance(node, ast.Name):
            counter_value = get_counter_data(counter_id=node.id)
            values[node.id] = counter_value
            return counter_value, values
        elif isinstance(node, ast.Dict):
            if sys.version_info[:3] < (3, 8):
                counter_value = get_counter_data(counter_id=node.keys[0].s, path_filters=node.values[0].s)
                values[str(node.keys[0].s) + "_" + str(node.values[0].s)] = counter_value
            else:
                counter_value = get_counter_data(counter_id=node.keys[0].value, path_filters=node.values[0].value)
                values[str(node.keys[0].value) + "_" + str(node.values[0].value)] = counter_value
            return counter_value, values
        elif isinstance(node, ast.BinOp):  # <left> <operator> <right>
            left, val1 = eval_(node.left, values)
            right, val2 = eval_(node.right, values)
            values = merge_two_dicts(val1, val2)
            return operators[type(node.op)](left, right), values
        elif isinstance(node, ast.UnaryOp):  # <operator> <operand> e.g., -1
            value, values = eval_(node.operand, values)
            return operators[type(node.op)](value), values
        elif isinstance(node, ast.Compare):  # <left> <ops> <comparators>
            if len(node.ops) == 1 and len(node.comparators) == 1:
                left, val1 = eval_(node.left, values)
                comparator, val2 = eval_(node.comparators[0], values)
                values = merge_two_dicts(val1, val2)
                return operators[type(node.ops[0])](left, comparator), values
            elif len(node.ops) == 2 and len(node.comparators) == 2:
                left, val1 = eval_(node.left, values)
                comp1, val2 = eval_(node.comparators[0], values)
                comp2, val3 = eval_(node.comparators[1], values)
                values = merge_two_dicts(val1, merge_two_dicts(val2, val3))
                return operators[type(node.ops[0])](left, comp1) \
                    and operators[type(node.ops[1])](comp1, comp2), values
            else:
                raise TypeError(node)
        else:
            raise TypeError(node)

    timestamp_offset = kwargs.pop('timestamp_offset', 0)
    counters_data = kwargs.pop('counters_data', None)
    csv_filepath = kwargs.pop('csv_filepath', None)
    counters_list = list(set(list(itertools.chain(*[re.findall(r"M\d+C\d+", comp_str) for comp_str in args]))))
    if not counters_data:
        counters_data = get_pm_counters_values(counter_ids_list=list(counters_list), csv_filepath=csv_filepath)
    flattened_counters_data = _flatten(counters_data)
    BuiltIn().set_test_variable("${FLATTENED_COUNTERS_DATA}", flattened_counters_data)
    results = {}
    for idx, expr in enumerate(args):
        evaluation, values = eval_(ast.parse(expr, mode='eval').body, {})
        results[idx] = {"evaluation": evaluation, "expr": expr, "counter_values": values}

    results_bool_list = [dict_value["evaluation"] for dict_value in results.values()]
    failed = [idx for idx, dict_value in results.items() if dict_value["evaluation"] is False]
    if not all(results_bool_list):
        error_msgs = []
        for idx in failed:
            error_msgs.append("Expression: [{}] failed. Counter values: {}".format(results[idx]["expr"],
                                                                                   results[idx]["counter_values"]))
        raise AssertionError("\n".join(error_msgs))
    logger_console_info("All counters relations: {} verified successfully".format(args))


def save_csv_with_counters_data(flattened_counters_data, file_path):
    timestamp = datetime.datetime.now().strftime("%d%m%y_%H_%M_%S")
    if file_path.endswith(".csv"):
        file_path = "{}_{}.csv".format(file_path.split('.csv')[0], timestamp)
    else:
        file_path = "{}_{}.csv".format(file_path, timestamp)
    try:
        timestamp_list = [list(t_dict.keys()) for t_dict in flattened_counters_data.values()]
        timestamp_set = set([item for sublist in timestamp_list for item in sublist])
        timestamps = sorted(timestamp_set)
        with open(file_path, mode='w') as csv_file:
            writer = csv.DictWriter(csv_file, fieldnames=["timestamp"] + list(flattened_counters_data.keys()))
            writer.writeheader()
            for timestamp in timestamps:
                row_dict = {'timestamp': time.strftime("%Y-%m-%d %H:%M:%S", time.gmtime(int(timestamp)))}
                for counter, values in flattened_counters_data.items():
                    row_dict[counter] = values.setdefault(timestamp, "-")
                writer.writerow(row_dict)
    except Exception as e:
        logger_warning("Error generating csv with counters data: {}".format(str(e)))


def compare_counters_with_each_other(*args, **kwargs):
    """Verify any counters, specified in the arguments in such a way:
        counter_id, expresion, path_filters.
        Example:
            "M55138C01511", None, ">=", "M55138C01503", ["NRCELL-2", "NRPMQAP-1"],
            "M55138C01511", ["NRCELL-1", "NRPMQAP-2"], "==", "M55138C01503", ["NRCELL-2", "NRPMQAP-1"],
            counters_data=counters_data

    :param counters_data: counters data collected via get_pm_counters_values, consistent with admin api
                          returned format. If not specified, the data is collected automatically
    :param path_filters: path filters can be provided either as a string denoting the path to the counter
                         (without counter ID and counter name) or as a list of strings of elements in the path
                         that the path should match
    :param timestamp_offset: offset for the counters values in sorted timestamp array;
                          0 means the newest counter value, 1: previous, 2: the one before the previous etc.
    :return: None
    """
    timestamp_offset = kwargs.pop('timestamp_offset', 0)
    counters_data = kwargs.pop('counters_data', None)
    counters_expect_list = __parse_args_compare_counters(args)
    counters_list = set([counter_dict["counter_id"] for counter_dict in counters_expect_list])
    all_relations = []
    if not counters_data:
        counters_data = get_pm_counters_values(counter_ids_list=list(counters_list))
    flattened_counters_data = _flatten(counters_data)
    results = {}
    for idx, expect_dict in enumerate(counters_expect_list):
        print(expect_dict)
        comparator = expect_dict['comparator']
        c1_latest_value = _get_latest_counter_value_from_flattened_data_dict(
            counter_id=expect_dict["counter_id_1"],
            counters_dict=flattened_counters_data,
            path_filters=expect_dict["path_filters_1"],
            timestamp_offset=timestamp_offset
        )
        c2_latest_value = _get_latest_counter_value_from_flattened_data_dict(
            counter_id=expect_dict["counter_id_2"],
            counters_dict=flattened_counters_data,
            path_filters=expect_dict["path_filters_2"],
            timestamp_offset=timestamp_offset
        )
        result = OPERATORS[comparator](c1_latest_value, c2_latest_value)
        all_relations.append("({}):{} {} ({}):{}".format(
            expect_dict["path_filters_1"], expect_dict["counter_id_1"], comparator,
            expect_dict["path_filters_2"], expect_dict["counter_id_2"]))
        results[idx] = {
            "result": result, "expect_dict": expect_dict,
            "c1_value": c1_latest_value, "c2_value": c2_latest_value
        }

    results_bools_list = [result_dict["result"] for counter, result_dict in results.items()]
    failed_comparisons = [idx for idx, result_dict in results.items() if result_dict["result"] is False]
    if not all(results_bools_list):
        error_msgs = []
        for comparison_idx in failed_comparisons:
            comparator = results[comparison_idx]["expect_dict"]["comparator"]
            counter_id_1 = results[comparison_idx]["expect_dict"]["counter_id_1"]
            counter_id_2 = results[comparison_idx]["expect_dict"]["counter_id_2"]
            path_filters_1 = results[comparison_idx]["expect_dict"]["path_filters_1"]
            path_filters_2 = results[comparison_idx]["expect_dict"]["path_filters_2"]
            c1_value = results[comparison_idx]["c1_value"]
            c2_value = results[comparison_idx]["c2_value"]
            error_string = "Comparison ({}) {} value: {} does not satisfy the expression {} ({}) {} value: {}".format(
                path_filters_1, counter_id_1, c1_value, comparator, path_filters_2, counter_id_2, c2_value)
            error_msgs.append(error_string)
        raise AssertionError("\n".join(error_msgs))
    logger_console_info("All counters relations: {} verified successfully".format(all_relations))


def _flatten(d, parent_key='', sep='_'):
    items = []
    for k, v in d.items():
        new_key = parent_key + sep + k if parent_key else k
        if isinstance(v, dict) and not re.search(r"^M\d+C\d+$", k):
            items.extend(_flatten(v, new_key, sep=sep).items())
        else:
            items.append((new_key, v))
    return dict(items)


def _get_latest_counter_value_from_flattened_data_dict(counter_id, counters_dict, path_filters=None,
                                                       timestamp_offset=0, separator="_"):
    def _handle_path_filters(path_filters):
        if isinstance(path_filters, str):
            path_filters = path_filters.split('/')
        elif isinstance(path_filters, list):
            pass
        else:
            raise ValueError("path_filters is neither a string nor a list!")
        return [word.strip() for word in path_filters]

    def _get_latest_value(key):
        sorted_timestamps = sorted(counters_dict[key].keys(), reverse=True)
        latest_timestamp = sorted_timestamps[timestamp_offset]
        latest_counter_value = counters_dict[key][latest_timestamp]
        return latest_counter_value

    for key in counters_dict.keys():
        if counter_id in key:
            if path_filters:
                path_filters = _handle_path_filters(path_filters)
                split_key = key.split(separator)
                matches_all_filters = all([elem in split_key for elem in path_filters])
                if matches_all_filters:
                    return _get_latest_value(key)
            else:
                return _get_latest_value(key)
    raise ValueError("Counter {}: {} could not have been found".format(path_filters, counter_id))


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
    for counter_id, expectations, path_filters in expectations_table:
        match = re.search(r"\d+", expectations)
        if not match:
            raise WrongFormat("Could not parse the number from expectation string")
        value = int(match.group(0))
        comparator = expectations.split(str(value))[0].strip()
        parsed_expectations.append({'counter_id': counter_id, 'comparator': comparator,
                                    "value": value, 'path_filters': path_filters})
    return parsed_expectations


def __parse_args_compare_counters(args):
    parsed_expectations = []
    expectations_table = __args_to_table(args, values=5)
    for counter_id_1, path_filters_1, comparator, counter_id_2, path_filters_2 in expectations_table:
        comparator = comparator.strip()
        if comparator not in OPERATORS.keys():
            raise WrongFormat("Entered operator for comparison unsupported!")
        parsed_expectations.append({
            'counter_id_1': counter_id_1,
            'counter_id_2': counter_id_2,
            'comparator': comparator,
            'path_filters_1': path_filters_1,
            'path_filters_2': path_filters_2
        })
    return parsed_expectations


def __verify_counter_conditions(expect_dict, counters_data, timestamp_offset):
    counter_id = expect_dict['counter_id']
    path_filters = expect_dict['path_filters']
    comparator = expect_dict['comparator']
    value = expect_dict['value']
    latest_value = _get_latest_counter_value_from_flattened_data_dict(
        counter_id=counter_id, counters_dict=counters_data, path_filters=path_filters,
        timestamp_offset=timestamp_offset)
    return OPERATORS[comparator](latest_value, value), latest_value


@handle_admin
def get_latest_counter_value_for_all_cells(counter_id, timeout=120, *args, **kwargs):
    """Get latest counter values for all cells

    :param counter_id: id of the counter
    :param timeout: timeout is sec
    :return: dictionary with nrcell_id as keys and counter value as values
    """
    values = {}
    counters = kwargs["connection"].get_pm_counters(counter_ids=counter_id, timeout=timeout)
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
            if len(counters_dict.keys()) == 1 and not re.search(r"^M\d+C\d+$", key):
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


def sort_nested_dict(dictionary):
    res = OrderedDict()
    for key, value in sorted(dictionary.items()):
        if isinstance(value, dict):
            res[key] = sort_nested_dict(value)
        else:
            res[key] = value
    return res


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
    if all([not re.search(r"^M\d+C\d+$", key) for key in counters.keys()]):
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


def check_pm(cells=[1], counter_list=None, pm_file=None):
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
    if not pm_file:
        pm_file = pm.get_latest_unpacked_full_pm_counters_file(output_dirpath=out_dir, remote_host=None)
    for cell in cells:
        mo_id = "PLMN-PLMN/MRBTS-{}/NRBTS-{}/NRCELL-{}".format(mrbts, nrbts, cell)
        pm.verify_last_counters_in_file(*counter_list, local_moid=mo_id, file_path=pm_file)


def verify_if_counters_from_list_changed(counter_list, previous_file=None, pm_file=None, cells=[1], increment=True):
    """
        Author: Damian Piasecki
        Contact: damian.piasecki@nokia.com
        Creation Date: 28.06.2021
        Modified Date: 06.03.2023 Marcin Trebunia marcin.trebunia@nokia.com
                       merge functions for increment/not increment

        The function verifies if any counter from a given counter list changed its value

        Args:
            counter_list(list): List of counters IDs
            previous_file: (optional) PM counters file got in the first phase of the test (e.g before UE attach)
            pm_file: PM counters file got in the second phase of the test (e.g after e UE attach)
            cells (list): under which cell counters should be checked
            increment (bool): set to True if counters should increment, else False

        Returns:
            None
    """
    pm = get_library_instance("ta5g_pm_counters")
    mrbts, nrbts = get_mrbts_nrbts_ids()
    for cell in cells:
        mo_id = "PLMN-PLMN/MRBTS-{}/NRBTS-{}/NRCELL-{}".format(mrbts, nrbts, cell)
        if previous_file:
            prev_values_list = []
            next_values_list = []
            for counter in counter_list:
                prev_counter_values_list = pm.get_pm_counter_value(counter=counter, localmoid=mo_id,
                                                                   filepath=previous_file)
                prev_counter_value = prev_counter_values_list[-1]
                prev_values_list.append(prev_counter_value)
                next_counter_values_list = pm.get_pm_counter_value(counter=counter, localmoid=mo_id,
                                                                   filepath=pm_file)
                next_counter_value = next_counter_values_list[-1]
                next_values_list.append(next_counter_value)
            prev_sum_values = sum(prev_values_list)
            next_sum_values = sum(next_values_list)
            if increment:
                assert next_sum_values > prev_sum_values, \
                    "Sum of counters values {} is the same as {}. " \
                    "No counter from the list has increased.".format(next_sum_values, prev_sum_values)
            else:
                assert next_sum_values == prev_sum_values, \
                    "Sum of counters values {} is greater than {}. " \
                    "Some counter from the list has increased.".format(next_sum_values, prev_sum_values)
        else:
            values_list = []
            for counter in counter_list:
                next_counter_values_list = pm.get_pm_counter_value(counter=counter, localmoid=mo_id,
                                                                   filepath=pm_file)
                next_counter_value = next_counter_values_list[-1]
                values_list.append(next_counter_value)
            sum_values = sum(values_list)
            if increment:
                assert sum_values > 0, \
                    "Sum of counters values {} is 0. " \
                    "No counter from the list has increased.".format(sum_values)
            else:
                assert sum_values == 0, \
                    "Sum of counters values {} is greater than 0. " \
                    "Some counter from the list has increased.".format(sum_values)


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


def get_latest_counter_values_for_cells(counter_id, cells=[1], pm_file=None):
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
    if not pm_file:
        pm_file = pm.get_latest_unpacked_full_pm_counters_file(output_dirpath=output_dir, remote_host=None)
    counter_values = {}
    for cell in cells:
        mo_id = "PLMN-PLMN/MRBTS-{}/NRBTS-{}/NRCELL-{}".format(mrbts, nrbts, cell)
        counter_values[cell] = pm.get_latest_pm_counter_value(counter_id, mo_id, pm_file)
    return counter_values


def check_pm_counters_for_cells_with_transient_phase(counter_list, forced_cells=[1], num_of_ues=1, counters_per_ue=1,
                                                     pm_file=None):
    """
    Author: Szymon Lange
    Contact: szymon.lange@nokia.com
    Creation Date: 26.08.2021
    Modified Date: 28.12.2021

    Validate PM counters consulting transient phase - allowed DTXs are ignored.

    :param counter_list: List of counters to be validated.
    :param forced_cells: List with cell's ids for which counters will be validated.
    :param num_of_ues: Number of UEs attached in test.
    :param counters_per_ue: Number of counters per UE.
    """
    ues_per_cell = int(num_of_ues)/len(forced_cells)
    pm = BuiltIn().get_library_instance("ta5g_pm_counters")
    output_dir = BuiltIn().get_variable_value("${OUTPUT_DIR}")
    if not pm_file:
        pm_file = pm.get_latest_unpacked_full_pm_counters_file(output_dirpath=output_dir, remote_host=None)
    dtx_f3_transient_phase = get_latest_counter_values_for_cells(counter_id='M55303C28002', cells=forced_cells,
                                                                 pm_file=pm_file)
    for cell in forced_cells:
        counter_list = modify_value_in_counter_list(counter_list, dtx_f3_transient_phase[cell]+(
                int(ues_per_cell) * int(counters_per_ue)), '<=')
        check_pm(cells=[cell], counter_list=counter_list, pm_file=pm_file)


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


def validate_slice_scheduler_counters(
            resource_groups_nsa_sa={'NSA': (1, ), 'SA': (2, )},
            nrresourcegroup_values={'1': (1, 2, 3)}, max_validation_diff=5,
            total_share_threshold=90, cell='1'):
    """
    Author: Szymon Lange
    Maintainer: Damian Zak, Marcin Trebunia
    Contact: damian.zak@nokia.com, marcin.trebunia@nokia.com
    Creation Date: 09.03.2023
    Modified Date: -

    :param resource_groups_nsa_sa: (dict) Dict resource_groups as (architecture: resource groups)
    :param nrresourcegroup_values: (dict) Dict containing NRRESOURCEGROUP values
                                          KEY: NRRESOURCEGROUP_PROFILE_ID
                                          VALUE: tuple with NRRESOURCEGROUP ids
                                          Values here must be in the same order as  resource groups in
                                          resource_groups_nsa_sa
    :param max_validation_diff: (int)     Maximum deviation of PM counters validation
    :param total_share_threshold (int)    Threshold for sum of shares
    :param cell (str)                     Cell on which SaS counters need to be checked
    """

    failed_results = []
    results = _calculate_slice_scheduler_counters(resource_groups_nsa_sa, nrresourcegroup_values,
                                                  max_validation_diff, total_share_threshold, cell)
    for result in results:
        logger_console_info(result['msg'])
        if not result['status']:
            failed_results.append(result['msg'])

    if len(failed_results) >= 1:
        raise ExecutionFailed(message='\n'.join(failed_results))


def manage_resource_groups_with_counters_collection(resource_groups_nsa_sa, cell):
    counter_values_list = []
    joined_resource_groups = []
    for net_arch, resource_groups in resource_groups_nsa_sa.items():
        counter_values, prbs_avail_cell = _get_slice_scheduler_resource_group_counters(resource_groups=resource_groups,
                                                                                       cell=cell)
        counter_values_list.append(counter_values)
        joined_resource_groups += [(resource_group, net_arch) for resource_group in resource_groups]
    return counter_values_list, joined_resource_groups, prbs_avail_cell


def _calculate_slice_scheduler_counters(resource_groups_nsa_sa, nrresourcegroup_values, max_validation_diff,
                                        total_share_threshold, cell):
    rg_id_index = 0
    net_arch_index = 1
    counter_values, joined_resource_groups, prbs_avail_cell = manage_resource_groups_with_counters_collection(
                                                              resource_groups_nsa_sa, cell
                                                              )
    resource_groups_quotas = _get_slice_scheduler_param_values_from_scf(nrresourcegroup_values)
    percents = _calculate_target_slice_ratio(resource_groups_quotas)
    log_msgs = []
    joined_counter_values = list(itertools.chain.from_iterable(counter_values))
    ratio_sum = float(0)
    for counter_values_prb, resource_group_quotas, percent, resource_group in zip(
            joined_counter_values, resource_groups_quotas, percents, joined_resource_groups):
        ratio = round(float(counter_values_prb[0]) / float(prbs_avail_cell) * 100.0)
        ratio_status = round(percent) - int(max_validation_diff) <= ratio <= round(percent) + int(max_validation_diff)
        log_msgs.append(
            {'status': ratio_status,
             'msg': f'Slice-{resource_group[rg_id_index]} {resource_group[net_arch_index]} ratio validation '
                    f'status: {ratio_status} {ratio}% while {round(percent)}% +-{max_validation_diff} expected.'}
        )
        max_quota_status = resource_group_quotas[1] <= counter_values_prb[1] <= resource_group_quotas[0] + 1
        log_msgs.append(
            {'status': max_quota_status,
             'msg': f'Slice-{resource_group[rg_id_index]} {resource_group[net_arch_index]} max quota validation '
                    f'status: {max_quota_status} {counter_values_prb[1]} while should be in '
                    f'range [{resource_group_quotas[1]}, {resource_group_quotas[0] + 1}].'}
        )
        ratio_sum += ratio
    if total_share_threshold:
        if ratio_sum < float(total_share_threshold):
            logger_console_info(log_msgs)
            raise ExecutionFailed(message=f'\nSum of shares is less than {total_share_threshold}%')
        else:
            logger_console_info(f'\nSum of shares is greater than {total_share_threshold}')

    return log_msgs


def _get_slice_scheduler_resource_group_counters(resource_groups, cell):
    dat = get_pm_counters_values(['M55308C10013', 'M55910C00001', 'M55910C00002'])
    counter_values = []
    prbs_avail_cell = get_latest_values_for_specified_counters(
        ['M55308C10013'],
        path_filters=f'NRCELL-{cell}/NCELA',
        counters_data=dat
    )
    for resource_group in resource_groups:
        prbs_used = get_latest_values_for_specified_counters(
                    ['M55910C00001'],
                    path_filters=f'NRCELL-{cell}/NRRESOURCEGROUP-{resource_group}',
                    counters_data=dat
        )
        max_util_prbs = get_latest_values_for_specified_counters(
                        ['M55910C00002'],
                        path_filters=f'NRCELL-{cell}/NRRESOURCEGROUP-{resource_group}/NCUPNRG', counters_data=dat
        )
        counter_values.append((prbs_used['M55910C00001'], max_util_prbs['M55910C00002']))

    return counter_values, prbs_avail_cell['M55308C10013']


def _get_slice_scheduler_param_values_from_scf(nrresourcegroup_values):
    params = []
    for rg_profile_id in nrresourcegroup_values.keys():
        for rg_id in nrresourcegroup_values[rg_profile_id]:
            params.extend(get_values_of_parameters_from_scf(
                f'MRBTS-1/NRBTS-1/NRRESOURCEGROUP_PROFILE-{rg_profile_id}/NRRESOURCEGROUP-{rg_id}',
                [{'parameter': 'maxQuota', 'list_name': 'schedulerParams'},
                 {'parameter': 'minQuota', 'list_name': 'schedulerParams'}]
            ))
    ret = [(int(p1['value']), int(p2['value'])) for p1, p2 in zip(params[0::2], params[1::2])]

    return ret


def _calculate_target_slice_ratio(slices_quotas):
    slices_target_shares = []
    s_maxq_sum = sum(s_maxq for s_maxq, _ in slices_quotas)
    s_minq_sum = sum(s_minq for _, s_minq in slices_quotas)
    for s_maxq, s_minq in slices_quotas:
        share = min(s_minq + ((s_maxq - s_minq) * (100 - s_minq_sum) / (s_maxq_sum - s_minq_sum)), s_maxq)
        slices_target_shares.append(share)
    return slices_target_shares


def get_scell_addition_counter():
    """
    Gets M55114C00028 counter value of successful radio admission for 1 Scell additions.
    """
    pm_counters_data = get_pm_counters_values(['M55114C00028'])
    flattened_counters_data = _flatten(pm_counters_data)
    counter_values = []
    values = flattened_counters_data['BTS_MRBTS-1_NRBTS-1_NRCELL-1_RACCU_M55114C00028']
    for key in values.keys():
        counter_values.append(values[key])
    return counter_values


def check_pm_period_fill_factor(
        actual_time=None, pm_period=1, min_time_to_start=10, delay_sec=10, offset_pm_period_start=0):
    """
    Check how mnay time left to the end of period, check that the left time is greater than min_time_to_start.
    If left time is greater that min_time_to_start, return the time to send traffic after the PM period ends,
    and allow execution of the next commnad(command below). If left time is less than min_time_to_start,
    wait for the next PM period. Return time to the send traffic is time left plus time of pm period plus delay time.

    Other explanation: Function check that the time which left is enough to executed command below after the PM period
    ends. If not wait for next pm period.

    Args:
        actual_time (int, optional): The actual time in seconds since the epoch.
            If not provided, the current time will be used.
        pm_period (int, optional): The duration of the PM period in minutes. Default is 1 minute.
        min_time_to_start (int, optional): The minimum time required to start sending traffic after the PM period ends.
            Default is 10 seconds.
        delay_sec (int, optional): The delay in seconds before sending traffic after the minimum time to start.
            Default is 10 seconds.
        offset_pm_period_start (int, optional): The offset in seconds to start the PM period. Default is 0 seconds.

    Returns:
        int: The time in seconds to send traffic after the PM period ends.

    """
    if actual_time is None:
        actual_time = int(time.time())
    else:
        actual_time = int(actual_time)
    pm_period = int(pm_period)
    min_time_to_start = int(min_time_to_start)
    delay_sec = int(delay_sec)
    offset_pm_period_start = int(offset_pm_period_start)
    print('Actual_time: {} Fomrat: {}'.format(actual_time, datetime.datetime.fromtimestamp(actual_time).isoformat()))
    pm_period_to_sec = pm_period*60
    first_value = int(actual_time/pm_period_to_sec)
    start_pm_period = first_value * pm_period_to_sec
    end_pm_period = start_pm_period + pm_period_to_sec

    time_ceil = math.ceil(actual_time)
    time_left = end_pm_period - time_ceil
    if actual_time >= start_pm_period + offset_pm_period_start:
        if time_left < min_time_to_start:
            wait_for_next_pm_period(interval=pm_period, delay=0)
            return check_pm_period_fill_factor(time.time(), pm_period, min_time_to_start, delay_sec)
        else:
            time_to_send_traffic = time_left + pm_period_to_sec + delay_sec
            return time_to_send_traffic
    else:
        sleep_until_the_offset_condition_is_passed = (start_pm_period + offset_pm_period_start) - (actual_time)
        time.sleep(sleep_until_the_offset_condition_is_passed+1)
        return check_pm_period_fill_factor(time.time(), pm_period, min_time_to_start, delay_sec)
