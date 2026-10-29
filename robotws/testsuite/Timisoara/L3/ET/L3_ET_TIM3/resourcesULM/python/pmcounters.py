from robot.libraries.BuiltIn import BuiltIn
from taf.analyzer.pmcounter.pm_log_reader import PMCounterLogReader
import datetime
import glob
import os
import re
import robot.api.logger as logger
import time
import inspect
import functools
import sys
import logging


def python_log(function):
    """
    Function decorator logging entry + exit and parameters of functions.
    Entry and exit as logger.info, parameters as logger.DEBUG.
    """

    @functools.wraps(function)
    def wrapper(*args, **kwargs):
        # Log function entry
        func_name = function.__name__
        logger.info("Enter {}()".format(func_name))

        # Log function params (args and kwargs)
        if hasattr(inspect, "signature"):
            func_args = inspect.signature(function).bind(*args, **kwargs).arguments
        else:
            data = inspect.getargspec(function)
            if data.defaults:
                func_args = dict(zip(reversed(data.args), reversed(data.defaults)))
            else:
                func_args = {}
            func_args.update(kwargs)
            pos_dict = dict(zip(data.args, args))
            func_args.update(pos_dict)

        func_args_str = ', '.join(
            "{} = {}".format(var_name, var_value)
            for var_name, var_value
            in func_args.items()
        )
        logger.debug("{} arguments: {}".format(func_name, func_args_str))

        # Execute wrapped (decorated) function:
        out = function(*args, **kwargs)

        # Log the exit of the function and the result it returns.
        logger.info("Exit {}()! => {}".format(func_name, out))

        return out

    return wrapper


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
        if int(time.time() - int(add_time)) % meas_period == 0:   # wait for additional time
            break
        counter += 1
        if counter % 30 == 0 and with_console_output:
            logger.console(".", newline=False)
    if with_console_output:
        logger.console(".done (%s)" % datetime.datetime.fromtimestamp(int(time.time())))
    logger.debug("wait_next_meas_period: start_time='{}' finished with wait of {} min {} sec".format(
        start_time, counter/60, counter % 60))
    logger.debug("============================== End wait_next_meas_period()")


def wait_certain_meas_period(meas_periods=[10, 25, 40, 55], with_console_output=False):
    """Author: Amr Aboushehata; Abstraction Level is LOW
    :param meas_period -> list of minutes when the measurement can start
    :param with_console_output -> Boolean (default False)"""
    logger.debug("============================== Begin wait_next_meas_period()")
    start_time = time.time()
    logger.debug("wait_next_meas_period: start_time='{}' started".format(start_time))
    delta = 900                     # WAIT FOR MAX 15 MINTS
    if with_console_output:
        logger.console(" Wait next measurement period: ({}) ".format(datetime.datetime.fromtimestamp(
            int(time.time()))), newline=False)
    counter = 0
    while delta > 0:
        time.sleep(1)
        MINUTE = int(datetime.datetime.now().minute)
        if MINUTE in meas_periods:
            break
        counter += 1
        delta -= 1
        if counter % 30 == 0 and with_console_output:
            logger.console(".", newline=False)
    if with_console_output:
        logger.console(".done (%s)" % datetime.datetime.fromtimestamp(int(time.time())))
    logger.debug("wait_next_meas_period: start_time='{}' finished with wait of {} min {} sec".format(
        start_time, counter/60, counter % 60))
    logger.debug("============================== End wait_next_meas_period()")


def get_pi_dict(pi_dir, pi_list, pi_file_pattern="PM.BTS-*"):
    """Author : Srihari Janardhan
    Creates a dictionary with following structure:
    {b'2019-04-29 11:15:00+00:00':
        {'M55308C00001':
            {b'MRBTS-1900/NRBTS-1/NRCELL-1':
                b'5670605',
            b'MRBTS-1900/NRBTS-1/NRCELL-2':
                b'5670605'},
        'M55308C00002':
            {b'MRBTS-1900/NRBTS-1/NRCELL-1':
                b'1080114',
            b'MRBTS-1900/NRBTS-1/NRCELL-2':
                b'1080114'},
        'M55308C00003':
            {b'MRBTS-1900/NRBTS-1/NRCELL-1':
                b'90009',
            b'MRBTS-1900/NRBTS-1/NRCELL-2':
                b'90009'}},
    """
    if "[" or "]" in pi_dir:
        square_bracket_regex_pattern = r"[\[|\]]"
        pi_dir = re.sub(square_bracket_regex_pattern, r"[\g<0>]", pi_dir)

    file_obj_iterator = (
        open(file_name, 'rb')
        for file_name in glob.glob(os.path.join(pi_dir, pi_file_pattern)))

    counter_results = {}
    for pm_log_entry in PMCounterLogReader(file_obj_iterator=file_obj_iterator):
        ts = str(pm_log_entry.timestamp)
        sample = {}
        for pi in pi_list:
            sample[pi] = pm_log_entry.pm_setup.pi_dict(pi)[pi]
        counter_results[ts] = sample

    return counter_results


def get_counter_value(pi_dict, pi, dist_name, index=0):
    """Author : Srihari Janardhan
    Gets counter value from given dict. Index is calculated from latest sample to previous.
    I.e. index=0 returns the last value, index=1 returns the one before that."""
    samples = sorted(pi_dict.keys(), reverse=True)
    if dist_name in pi_dict[samples[int(index)]][pi]:
        return int(pi_dict[samples[int(index)]][pi][dist_name])


def get_timestamp(pi_dict, index=0):
    """Author : Srihari Janardhan
    Gets timestamp from given dict. Index is calculated from latest sample to previous.
    I.e. index=0 returns the last value, index=1 returns the one before that."""
    samples = sorted(pi_dict.keys(), reverse=True)
    return samples[int(index)]


def compare_values(observed, shall, rel_tolerance=0.0, abs_tolerance=0):
    """Author : Srihari Janardhan
    Compares two values. Returns 'Failed' if difference is more than tolerance*shall. Otherwise returns 'Passed'"""
    shall = str(shall)
    if ">" in shall and "=" not in shall:
        minimum = shall.replace(">", "")
        expression = int(observed) > int(minimum)
    elif ">=" in shall:
        minimum_equality = shall.replace(">=", "")
        expression = int(observed) >= int(minimum_equality)
    elif "<" in shall and "=" not in shall:
        maximum = shall.replace("<", "")
        expression = int(observed) < int(maximum)
    elif "<=" in shall:
        maximum_equality = shall.replace("<=", "")
        expression = int(observed) <= int(maximum_equality)
    elif "=" in shall and "<" not in shall and ">" not in shall:
        equality = shall.replace("=", "")
        expression = int(observed) == int(equality)
    else:
        lower_abs_tolerance_value = int(shall) - int(abs_tolerance)
        higher_abs_tolerance_value = int(shall) + int(abs_tolerance)
        expression_abs = lower_abs_tolerance_value <= int(observed) <= higher_abs_tolerance_value
        if not expression_abs:
            logging.info("Absolute Tolerance Check failed for PM Counter")

        lower_rel_tolerance_value = float(shall) - (float(rel_tolerance) * float(shall))
        higher_rel_tolerance_value = float(shall) + (float(rel_tolerance) * float(shall))
        expression_rel = lower_rel_tolerance_value <= float(observed) <= higher_rel_tolerance_value
        if not expression_rel:
            logging.info("Relative Tolerance Check failed for PM Counter")
        expression = expression_rel or expression_abs

    if expression:
        return "Passed"
    else:
        return "Failed"


def get_actual_pm_values(pi_dict, pi_list, dist_name, index=0):
    actual_values_dict_index = {}
    if isinstance(index, list):
        index_list = index
    if sys.version_info.major == 2:
        if isinstance(index, (int, unicode)):
            index_list = [index]
    if sys.version_info.major == 3:
        if isinstance(index, (int, str)):
            index_list = [index]
    for i in index_list:
        actual_values_dict = {}
        for pi in pi_list:
            actual_values_dict[pi] = get_counter_value(pi_dict, pi, dist_name, i)
        actual_values_dict_index[i] = actual_values_dict
        if sys.version_info.major == 2:
            if isinstance(index, (int, unicode)):
                return actual_values_dict
        if sys.version_info.major == 3:
            if isinstance(index, (int, str)):
                return actual_values_dict
    return actual_values_dict_index


@python_log
def reference_table_has_description(pm_evaluation_table):
    allowed_operations = ['<', '>', '>=', '<=', '==', '!=']
    with_description = False

    if all([field in allowed_operations for field in pm_evaluation_table[1::4]]):
        with_description = True
    elif all([field in allowed_operations for field in pm_evaluation_table[1::3]]):
        with_description = False
    else:
        BuiltIn().fail('Provided evalutation table is in wrong format!')

    return with_description


@python_log
def list_to_dict(pm_evaluation_table):

    with_description = reference_table_has_description(pm_evaluation_table)

    column_names = 'pm_id', 'operation', 'expected', 'description'

    column_count = 4 if with_description else 3
    table_rows = [pm_evaluation_table[i:i+column_count] for i in range(0, len(pm_evaluation_table), column_count)]

    if with_description:
        table_data = [dict(zip(column_names, table_row)) for table_row in table_rows]
    else:
        table_data = [dict(zip(column_names, table_row + [''])) for table_row in table_rows]

    return table_data


@python_log
def validate_pm_counter_reference_table(reference_table, pm_dir, distname_suffix=None):

    pm_counters = [entry for entry in PMCounterLogReader.from_dir(dir_path=pm_dir, file_pattern="*xml")]
    last_pm_report = pm_counters[-1].pm_setup

    validation_data = list_to_dict(reference_table)

    error_messages = list()
    for item in validation_data:
        expected = int(item['expected'])

        if distname_suffix is None:
            pm_entries_per_dist_names = last_pm_report.pi_dict(item['pm_id'])[item['pm_id']]
            if len(pm_entries_per_dist_names) > 1:
                BuiltIn().fail(msg='PM Counter {} is listed several times. You need to specify the dist_name!'
                               .format(item['pm_id']))

        if distname_suffix is not None:
            pm_entries_per_dist_names = last_pm_report.pi_dict(item['pm_id'])[item['pm_id']]
            fitting_dist_names = [x for x in pm_entries_per_dist_names if x.endswith(str(distname_suffix))]
            if len(fitting_dist_names) == 1:
                measured = int(pm_entries_per_dist_names[fitting_dist_names[0]])
            else:
                BuiltIn().fail(msg='The dist_name could not be found or does not lead to a single/unique pm counter')
        else:
            measured = int(last_pm_report[item['pm_id']])

        BuiltIn().log('{} value: [{}] {}'.format(item['pm_id'], str(measured), item['description']), console=True)

        result = {'==': measured == expected,
                  '!=': measured != expected,
                  '>=': measured >= expected,
                  '<=': measured <= expected,
                  '>':  measured > expected,
                  '<':  measured < expected}[item['operation']]

        if not result:
            error_messages.append("Pm Counter {} should be {} {} but is {}!".
                                  format(item['pm_id'], item['operation'], expected, measured))

    BuiltIn().should_be_empty(error_messages, "Validation Error: " + " ".join(error_messages))


@python_log
def get_nidd_file_name_path():
    """Author : Nikolay Shkulepov
    Returns the full path to the NIDD file of PM Counters stored in the Repository.
    """
    nidd_file_name_path = "/tmp/NIDD.xml"
    try:  # to construct NIDD file and save it to /tmp
        nidd_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'NIDD'))
        os.chdir(nidd_dir)
        os.system("cat Counters*.xml > %s" % nidd_file_name_path)
    except Exception as e:
        pass
    return nidd_file_name_path
