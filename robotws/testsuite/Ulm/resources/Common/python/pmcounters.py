"""
Module that help to fetch and evaluate PM counters
"""
import datetime
import glob
import os
import re
import time
import sys
import logging
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from taf.analyzer.pmcounter import PMCounterLogReader


def _list_of_interval(interval):
    if interval is None:
        return None
    if isinstance(interval, list):
        return [int(i) for i in interval]
    pm_list = [int(i) for i in interval.split(",")]
    return pm_list


def wait_next_meas_period(meas_period=300, add_time=30, with_console_output=False):
    """Author: Nikolay Shkulepov; Abstraction Level is LOW
    introduced 30s delay time, for writing pm counter files
    :param meas_period -> int
    :param with_console_output -> Boolean (default False)"""
    logger.debug(
        "============================== Begin wait_next_meas_period()")
    logger.debug(
        f"wait_next_meas_period: meas_period = {meas_period} ")
    start_time = time.time()
    logger.debug(
        f"wait_next_meas_period: start_time= {start_time} started")
    delta = meas_period
    if with_console_output:
        logger.console(
            f"Wait next measurement period: ({datetime.datetime.fromtimestamp(int(time.time()))})", newline=False)
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
        logger.console(f".done: {datetime.datetime.fromtimestamp(int(time.time()))}")
    logger.debug("wait_next_meas_period: start_time='{}' finished with wait of {} min {} sec".format(
        start_time, counter/60, counter % 60))
    logger.debug("============================== End wait_next_meas_period()")


def wait_certain_meas_period(meas_periods=None, with_console_output=False):
    """Author: Amr Aboushehata; Abstraction Level is LOW
    :param meas_period -> list of minutes when the measurement can start
    :param with_console_output -> Boolean (default False)"""
    if meas_periods is None:
        meas_periods = [10, 25, 40, 55]
    logger.debug(
        "============================== Begin wait_next_meas_period()")
    start_time = time.time()
    logger.debug(
        f"wait_next_meas_period: start_time='{start_time}' started")
    delta = 900                     # WAIT FOR MAX 15 MINTS
    if with_console_output:
        logger.console(" Wait next measurement period: ({}) ".format(datetime.datetime.fromtimestamp(
            int(time.time()))), newline=False)
    counter = 0
    while delta > 0:
        time.sleep(1)
        minute = int(datetime.datetime.now().minute)
        if minute in meas_periods:
            break
        counter += 1
        delta -= 1
        if counter % 30 == 0 and with_console_output:
            logger.console(".", newline=False)
    if with_console_output:
        logger.console(f".done ({datetime.datetime.fromtimestamp(int(time.time()))})")
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


def get_counter_value(pi_dict, pi, dist_name, index=0, pi_timestamp=None):
    """Author : Srihari Janardhan
    Gets counter value from given dict. Index is calculated from latest sample to previous.
    I.e. index=0 returns the last value, index=1 returns the one before that."""
    if pi_timestamp:
        return int(pi_dict[pi_timestamp][pi][dist_name])
    samples = sorted(pi_dict.keys(), reverse=True)
    if dist_name in pi_dict[samples[int(index)]][pi]:
        return int(pi_dict[samples[int(index)]][pi][dist_name])
    return None


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
        expression_abs = lower_abs_tolerance_value <= int(
            observed) <= higher_abs_tolerance_value
        if not expression_abs:
            logging.info("Absolute Tolerance Check failed for PM Counter")

        lower_rel_tolerance_value = float(
            shall) - (float(rel_tolerance) * float(shall))
        higher_rel_tolerance_value = float(
            shall) + (float(rel_tolerance) * float(shall))
        expression_rel = lower_rel_tolerance_value <= float(
            observed) <= higher_rel_tolerance_value
        if not expression_rel:
            logging.info("Relative Tolerance Check failed for PM Counter")
        expression = expression_rel or expression_abs

    if expression:
        return "Passed"

    return "Failed"


def get_actual_pm_values(pi_dict, pi_list, dist_name, index=0):
    """
    Retrieves actual PM counter values from a given dictionary based on specified PM counters and distribution name.

    Args:
        pi_dict (dict): Dictionary containing PM counter data.
        pi_list (list): List of PM counters to extract values for.
        dist_name (str): The distribution name of the cell whose PM counters are of interest.
        index (int or list, optional): Position(s) of the counter interval to analyze. Defaults to 0,
            indicating the latest interval.
            Can be a single integer/string or a list of integers/strings.

    Returns:
        dict: A dictionary of dictionaries where each key is an index and the value is
        another dictionary containing PM counter names and their values.
    """
    actual_values_dict_index = {}
    index_list = []
    if isinstance(index, list):
        index_list = index
    if isinstance(index, (int, str)):
        index_list = [index]
    for i in index_list:
        actual_values_dict = {}
        for pi in pi_list:
            actual_values_dict[pi] = get_counter_value(
                pi_dict, pi, dist_name, i)
        actual_values_dict_index[i] = actual_values_dict
        if isinstance(index, (int, str)):
            return actual_values_dict
    return actual_values_dict_index


def reference_table_has_description(pm_evaluation_table):
    """
    Receives as parameter a reference table (check validate_pm_counter_reference_table_x)
    In case there is description it returns True. If not returns False
    If the format is not correct it will make the current test to fail

    :param pm_evaluation_table -> for counters
    :return: boolean value
    """
    allowed_operations = ['<', '>', '>=', '<=', '==', '!=', 'in']
    with_description = False

    if all([field in allowed_operations for field in pm_evaluation_table[1::4]]):
        with_description = True
    elif all([field in allowed_operations for field in pm_evaluation_table[1::3]]):
        with_description = False
    else:
        raise AssertionError('Provided evaluation table is in wrong format.'
                             '\n e.g.:Description should be present in all element of the list.'
                             '\n Operators supported: ' + str(allowed_operations))

    return with_description


def remove_description_from_reference_table(reference_table):
    """
    Receives as parameter a reference table (check validate_pm_counter_reference_table_x)
    In case there is description, the description is removed. That operation is done of
    the table that is received as parameter. A reference to that same table is returned
    If there is no description in the table the description list is returned empty

    :param reference_table -> for counters
    :return: reference table without description and description in separate list
    """
    # check if table has description and, if yes, move it to separate structure
    description_list = []
    with_description = reference_table_has_description(reference_table)
    BuiltIn().log('with_description: ' + str(with_description))
    if with_description:
        # move description which is at every 4th position to a separate list
        for i in range(int(len(reference_table) / 4)*4 - 1, 0, -4):
            description_list.insert(0, reference_table.pop(i))
    return reference_table, description_list


def get_pmcounter_ids_in_reference_table(reference_table):
    """
    Receives as parameter a reference table already with the description removed
    Searches for all the counter ids present in the table.
    A counter id is a string which starts with 'M' followed by digits plus
    a 'C' and more digits after. e.g.: M55318C00006
    It looks for 2 types of counters. Counters without distname and counters
    with distnames. The counter with distname has the distname suffix in
    parentisis just before the id of the counter, e.g. (NRCELL-1)M55318C00002
    In case these 2 types of counters are found in the reference table
    the BuiltIn().fail will be called because these 2 types of counter ids
    are not allowed to coexist in the same reference table

    :param reference_table -> for counters
    :return: list of PM counters IDs
    """
    reference_table_str = ' '.join(reference_table)
    pm_counters_list = re.findall(r'(?<!\))M\d+C\d+', reference_table_str)
    pm_counters_list = list(set(pm_counters_list))
    BuiltIn().log('Pm counters without dist name found: ' + str(pm_counters_list))
    pm_counters_list_with_distname = re.findall(r'\([\d\w\-\/]*\)M\d+C\d+', reference_table_str)
    pm_counters_list_with_distname = list(set(pm_counters_list_with_distname))
    BuiltIn().log('Pm counters with dist name found: ' + str(pm_counters_list_with_distname))

    if pm_counters_list and pm_counters_list_with_distname:
        raise AssertionError('Not allowed to have some pm counters with distname and others without')

    return pm_counters_list_with_distname + pm_counters_list


def invert_index(index):
    return -1-index


def get_pmcounter_values_from_log(pm_counters_list, pm_dir, distname_suffix, meas_index=0, interval=None):
    """
    Receives as parameter a list with IDs of the PM counters, folder where
    PM counter files are located, and the distname of the object containing
    those counters. Using that information it retrieves the value of the
    PM counters present in the list and returns a dictionary with the values
    found in the logs, in which the keys are the pm counter ids.

    :param pm_counters_list -> list of pm counters id
    :param pm_dir           -> directory containing the pm counter files
    :param distname_suffix  -> unique distname (can be partial match)
    :param meas_index       -> measurement period index. 0 is the last measurement period. 1 is second last.
    :return: dictionary with the values of the pm counters
    """
    interval = _list_of_interval(interval)

    pm_counters_dict = {}
    log_entries = list(PMCounterLogReader.from_dir(
        dir_path=pm_dir,
        interval=interval,
        file_pattern='*xml'))
    try:
        required_log_entry = log_entries[invert_index(meas_index)]
    except IndexError as exc:
        raise AssertionError('No pm counter logs found at: ' + str(pm_dir)) from exc
    for pm_counter in pm_counters_list:
        try:
            # counter with distname
            if ')' in pm_counter:
                # PM counter carrying distname e.g. (NRCELL-1)M55318C00002'
                pm_counter_split = pm_counter.replace('(', '').split(')')
                pi_id = pm_counter_split[1]
                distname_su = '(.+)?' + pm_counter_split[0] + '$'
                if distname_suffix is not None:
                    raise AssertionError('If distname present in table, distname_suffix argument must be empty')
            else:
                # if distname_suffix not given match all distnames
                if distname_suffix is None:
                    distname_suffix = ''
                pi_id = pm_counter
                distname_su = '(.+)?' + distname_suffix + '$'
            pm_counters_dict[pm_counter] = str(required_log_entry.get_pi_value(pi_id=pi_id, dn_re=distname_su))
        except AssertionError as error:
            BuiltIn().log('Error fetching pm counter: ' + str(pm_counter))
            BuiltIn().log(error)
    BuiltIn().log('Pm counters values: ' + str(pm_counters_dict))
    return pm_counters_dict


def resolve_reference_table(reference_table, pm_counters_dict):
    """
    Receives as parameters a reference table and a dictionary with the value of counters in the table.
    It returns a new reference table with the id of each counter replaced by its value.

    :param reference_table  -> reference table
    :param pm_counters_dict -> dictionary of the counters
    :return: new table with the counter ids replaced by its value
    """
    reference_table_resolved = reference_table.copy()
    for index in range(0, len(reference_table_resolved)):
        for pm_counter in pm_counters_dict.keys():
            if pm_counter in reference_table_resolved[index]:
                reference_table_resolved[index] = \
                    reference_table_resolved[index].replace(pm_counter, pm_counters_dict[pm_counter])
    return reference_table_resolved


def log_counters_found_in_table_to_console(pm_counters_dict):
    console_flag = BuiltIn().get_variable_value("${P_console}")
    BuiltIn().log('\nCounters found in reference table:', console=console_flag)
    for counter_id, value in pm_counters_dict.items():
        BuiltIn().log('   ' + str(counter_id) + ' : ' + str(value), console=console_flag)


def validate_reference_table_against_pmcounter_values(reference_table, pm_counters_dict, description_list):
    """
    Receives as parameter a reference table and a dictionary with the value of those counters.
    Checks each condition. Will cause failure of the test if one of the conditions is wrong or
    the syntax of the conditions is not correct

    :param reference_table   -> reference table
    :param pm_counters_dict  -> dictionary of the counters
    :param description_list  -> description taken from the reference table for log purposes
    """
    console_flag = BuiltIn().get_variable_value("${P_console}")
    BuiltIn().log('\nStart validation PM counters reference table:', console=console_flag)
    log_counters_found_in_table_to_console(pm_counters_dict)
    BuiltIn().log('\nReference table verification:', console=console_flag)
    error_messages = list()
    reference_table_resolved = resolve_reference_table(reference_table, pm_counters_dict)
    # iterate over the rows and verify if the conditions are true
    for i in range(0, len(reference_table), 3):
        condition = ' '.join(reference_table_resolved[0+i:3+i])
        try:
            description = description_list[int(i/3)]
        except IndexError:
            description = ""
        try:
            if not eval(condition):
                error_messages.append('\nFAIL: ')
                error_messages.append(' '.join(reference_table[0+i:3+i]))
                error_messages.append('not valid:')
                error_messages.append(condition)
                error_messages.append('<-- wrong; ')
                error_messages.append(description)
            else:
                BuiltIn().log('PASS: ' + description, console=console_flag)
                BuiltIn().log('   ' + ' '.join(reference_table[0+i:3+i]), console=console_flag)
                BuiltIn().log('   ' + condition, console=console_flag)
        except (SyntaxError, NameError):
            error_messages.append('\nFAIL: the following condition has wrong format or counter id not resolved')
            error_messages.append('-> ')
            error_messages.append(' '.join(reference_table[0+i:3+i]))

    assert len(error_messages) == 0, "Validation Error:" + " ".join(error_messages)


def validate_pm_counter_reference_table(reference_table, pm_dir, distname_suffix=None, meas_index=0, interval=None):
    """
    Receives as parameter a reference table, directory containing the pm counter files
    and the distname of the object containing those pm counters.
    The reference table should have the following format:
    The table is a a list.
    Each condition is in a logical row and consists in 4 or 3 elements (3 if there is no description)
    If the table is without description, no row can have description.
    Or all logical rows have description or no row has description.
    The description is irrelevant for this function and serves only to document and provide context to
    each condition.
    The second item in each logical row is the operator.
    This function goes row by row and checks the result of each condition (True/False)
    Example of reference tables with and without description:
    reference_table = \
        [
            'M55318C00002', '==', 'M55318C00006',                      'Description of the first condition',
            'M55318C00008', '>=', 'M55318C00001 - (4 + M55318C00005)', 'This is another condition',
            'M55318C00012', '==', '40',                                'the last condition'
        ]

    The table can be also provided without description.
    reference_table_without_description = \
        [
            'M55318C00002', '==', 'M55318C00006',
            'M55318C00008', '>=', 'M55318C00001 - (4 + M55318C00005)',
            'M55318C00012', '==', '40',
        ]
    Another possibility is to include the distname suffix in the table.
    In this case the distaname suffix is given in parentisis just before the counter ID:
    reference_table_with_distname = \
        [
            '(NRCELL-1)M55318C00002', '==', '(NRCELL-2)M55318C00006',      'Description of the first condition',
            '(NRCELL-1)M55318C00008', '>=', '4 + (NRCELL-2)M55318C00005',  'This is another condition',
            '(NRCELL-3)M55318C00012', '==', '40',                          'the last condition'
        ]
    This opens the possibility for comparing counters between different managed objects aka distnames.
    In case this last option is chosen, distname suffix CANNOT BE GIVEN IN THE ARGUMENTS.
    Having distname suffix in the table and in the keyword arguments will cause the test to FAIL.
    In case of at least one of the conditions is not True the function will cause the test which called it to fail.
    The function will also cause the test to fail if any other problem occours (e.g. wrong table format,
    invalid syntax, operator not suported)

    Operators supported:  ['<', '>', '>=', '<=', '==', '!=']

    :param reference_table  -> reference table
    :param pm_dir           -> directory containing the pm counter files
    :param distname_suffix  -> unique distname (can be partial match)
    :param meas_index       -> index to measurement period. -1 is the last -2 the second last...
    :param interval         -> list of allowed intervals or comma-separated allowed interval values e.g. 5,15
    """
    interval = _list_of_interval(interval)
    # convert all elements in table to string
    reference_table = [str(ele) for ele in reference_table]

    reference_table, description_list = remove_description_from_reference_table(reference_table)

    pm_counters_list = get_pmcounter_ids_in_reference_table(reference_table)

    pm_counters_dict = get_pmcounter_values_from_log(pm_counters_list,
                                                     pm_dir,
                                                     distname_suffix,
                                                     meas_index,
                                                     interval=interval)

    validate_reference_table_against_pmcounter_values(reference_table, pm_counters_dict, description_list)


def get_nidd_file_name_path():
    """Author : Nikolay Shkulepov
    Returns the full path to the NIDD file of PM Counters stored in the Repository.
    """
    nidd_file_name_path = "/tmp/NIDD.xml"
    try:  # to construct NIDD file and save it to /tmp
        nidd_dir = os.path.abspath(os.path.join(
            os.path.dirname(__file__), '..', 'NIDD'))
        os.chdir(nidd_dir)
        os.system(f"cat Counters*.xml > {nidd_file_name_path}")
    except Exception:
        pass
    return nidd_file_name_path
