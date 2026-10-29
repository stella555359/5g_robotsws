import logging
import re
import time
from datetime import datetime, timedelta
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.utilities.robot.parallel_runner import run_parallel_in_robot
from ute_wtssim import ute_wtssim as wtssim

wtssim_instances = {}


class WrongUeThupValue(Exception):
    pass


def setup_default_egate():
    egate = wtssim()
    wtssim_instances['default'] = egate
    egate.setup_egate(20000)


def setup_all_egate_connections(ue_ids, egate_port, directions):
    if isinstance(ue_ids, int):
        ue_ids = [ue_ids]
    directions = ['dl', 'ul'] if directions == 'bidir' else [directions]
    for ue_id in ue_ids:
        for direction in directions:
            egate = wtssim()
            alias = f"EGATE-UE{int(ue_id)}-{direction.upper()}"
            wtssim_instances[alias] = egate
            egate.setup_egate(egate_port, alias=alias)


def create_ue_list(ue_string):
    """
    Converts a string of UE IDs and ranges into a list of integers.

    Args:
        ue_string (str): A string containing UE IDs and ranges, e.g., "1,3-5,8,10-12".

    Returns:
        list: A list of integers representing the UE IDs.

    Raises:
        ValueError: If the input format is invalid.

    Example:
        >>> create_ue_list("1,3-5,8,10-12")
        [1, 3, 4, 5, 8, 10, 11, 12]
    """

    ue_list = []
    ranges = ue_string.split(',')
    for r in ranges:
        range_split = r.split('-')
        try:
            start = int(range_split[0])
        except ValueError:
            raise ValueError(f"Invalid UE ID format: {range_split[0]}")
        if len(range_split) == 1:
            ue_list.append(start)
        elif len(range_split) == 2:
            try:
                end = int(range_split[1])
            except ValueError:
                raise ValueError(f"Invalid UE ID format: {range_split[1]}")
            if start > end:
                raise ValueError(f"Invalid UE range: {start}-{end} (Start ID must be < End ID)")
            ue_list.extend(range(start, end + 1))
        else:
            raise ValueError(f"Invalid UE range format: {r}")
    return ue_list


def capture_bearer_stats(ue_id, direction, pdu_id=None):
    if pdu_id is None:
        pdu_id = ue_id
    cmd = f"bearer_stats ue={ue_id} pdu={pdu_id} qfi=1 dir={direction}"
    alias = f"EGATE-UE{int(ue_id)}-{direction.upper()}"
    egate = wtssim_instances[alias]
    bearer_stats_output = egate.execute_egate_command_and_wait_for_data(
        cmd=cmd,
        pass_regexp="Last data rate",
        alias=alias,
        timeout=60)
    logging.debug(f"bearer_stats_output: {bearer_stats_output}")
    return bearer_stats_output


def get_average_throughput_from_bearer_stats_for_sa(ue_id, direction):
    bearer_stats = capture_bearer_stats(ue_id, direction)
    match = re.search(r"Average data rate +(\d+)", bearer_stats)

    if match:
        logging.debug(f"MATCH: {match}")
        return int(match.group(1))
    return None


def average_throughput_should_be_as_expected(bearer_stats_tput, expected_tput):
    exp_tput_bytes = int(int(expected_tput) * 1000000)
    maks_tput = int(exp_tput_bytes * 1.3)
    min_tput = int(exp_tput_bytes * 0.9)
    logging.debug(f"Check if average throughput {bearer_stats_tput} in range [{min_tput} - {maks_tput}]")
    result_stats = int(exp_tput_bytes * 1.3) > int(bearer_stats_tput) > int(exp_tput_bytes * 0.9)
    return result_stats


def log_iterations_and_fail_for_ue(ue_id, tput_values, direction):
    logging.debug(f"Failure for UE-{ue_id}: Throughput values: {tput_values}")
    raise AssertionError(f"Throughput validation failed for UE-{ue_id}-{direction.upper()}")


def validate_bearer_stats_for_ue(expected_tput, ue_id=None, direction='dl', iterations=1, interval=10):
    logging.debug(f"Validating bearer stats for UEs: {ue_id}")
    all_tput_values = {}

    logging.debug(f"Checking bearer stats for UE-{ue_id}")
    tput_values = []

    for _ in range(iterations):
        tput = get_average_throughput_from_bearer_stats_for_sa(ue_id, direction)
        if tput is not None:
            tput_values.append(tput)
        time.sleep(interval)

    all_tput_values[str(ue_id)] = tput_values
    total_tput = sum(tput_values)
    average_tput = total_tput / iterations
    logging.debug(f"Average {direction.upper()} Throughput for UE-{ue_id}-{direction.upper()}: {average_tput} bps")

    if not average_throughput_should_be_as_expected(average_tput, expected_tput):
        log_iterations_and_fail_for_ue(ue_id, tput_values, direction)

    logging.debug(f"All Throughput Results: {all_tput_values}")


def validate_bearer_stats_for_ues(expected_tput_ul, expected_tput_dl, ue_ids, iterations=1,
                                  interval=10, directions='dl'):
    if isinstance(ue_ids, int):
        ue_ids = [ue_ids]
    directions = ['dl', 'ul'] if directions == 'bidir' else [directions]
    list_of_functions = []
    for ue_id in ue_ids:
        for direction in directions:
            expected_tput = expected_tput_ul if direction == 'ul' else expected_tput_dl
            single_params = {
                'expected_tput': expected_tput,
                'ue_id': int(ue_id),
                'direction': direction,
                'iterations': iterations,
                'interval': interval
            }
            list_of_functions.append({
                'function': validate_bearer_stats_for_ue,
                'function_kwargs': single_params,
                'device_name': f"EGATE-UE-{int(ue_id)}-{direction.upper()}"
            })
    run_parallel_in_robot(list_of_functions)


def validate_ue_stats_for_ues(expected_tput_ul, expected_tput_dl, ue_ids, duration=60, directions='dl'):
    tput_values = get_ues_stats(ue_ids, duration, directions)
    directions = ['dl', 'ul'] if directions == 'bidir' else [directions]
    validation_result = True
    for ue in ue_ids:
        for direction in directions:
            if isinstance(expected_tput_dl, dict) and direction == 'dl':
                expected_tput = float(expected_tput_dl[str(ue)])
            elif isinstance(expected_tput_ul, dict) and direction == 'ul':
                expected_tput = float(expected_tput_ul[str(ue)])
            else:
                expected_tput = float(expected_tput_ul) if direction == 'ul' else float(expected_tput_dl)
            ue_tput = sum(tput_values[ue][direction]) / len(tput_values[ue][direction])
            ue_tput /= 1000000  # convert bps to Mbps
            if 0.8 * expected_tput < ue_tput < 1.2 * expected_tput:
                logging.debug(f"UE-{ue}-{direction}: Validation successful")
            else:
                logging.error(f"UE-{ue}-{direction}: Expected throughput: {expected_tput}, got: {ue_tput}")
                validation_result = False
    assert validation_result, "Validation failed"


def get_ues_stats(ue_ids, duration, directions):
    min_interval = 1
    tput_values = {}
    if isinstance(ue_ids, int) or isinstance(ue_ids, str):
        ue_ids = [str(ue_ids)]
    else:
        ue_ids = [str(ue) for ue in ue_ids]
    directions = ['dl', 'ul'] if directions == 'bidir' else [directions]
    end_time = datetime.now() + timedelta(seconds=int(duration))
    while datetime.now() < end_time:
        iter_start_time = datetime.now()
        for ue in ue_ids:
            if ue not in tput_values:
                tput_values[ue] = {'dl': [], 'ul': []}
            for direction in directions:
                trf_type = 'pdsch' if direction == 'dl' else 'pusch'
                tput_dict = check_ue_thput_stats_and_return_parse_output(ue, scell=0, type=trf_type)
                trf_value = get_tput_in_bytes(tput_dict[0]['Current'])
                tput_values[ue][direction].append(trf_value)
        iter_stop_time = datetime.now()
        logging.debug(iter_start_time, iter_stop_time)
        iter_duration = datetime.now() - iter_start_time
        if iter_duration.seconds < min_interval:
            time.sleep(min_interval - iter_duration.seconds)
    logging.debug(tput_values)
    return tput_values


def do_not_stop_egate_and_daemon():
    ute_wtssim = BuiltIn().get_library_instance('ute_wtssim')
    ute_wtssim.save_egate = True


def run_egate_cmd_and_wait_for_data(cmd, return_output=True, pass_regexp=None, timeout=30, logs='on'):
    """Runs given Egate command and waits for response until pass_regex apears in output.

    :param cmd: command to run
    :param pass_regexp: regexp, which says that command was executed properly
    :param return_output: boolen, set to True returns output
    :param timeout: defaults to 30
    :param logs: if set to 'off', prints are disabled
    """
    if logs == 'on':
        logging.info("Running cmd: {} ...".format(cmd))
    output = wtssim_instances['default'].execute_egate_command_and_wait_for_data(cmd=cmd,
                                                                                 return_output=return_output,
                                                                                 pass_regexp=pass_regexp,
                                                                                 timeout=timeout)
    if logs == 'on':
        logging.debug("Comand {} output:\n".format(cmd, output))
    return output


def check_ue_thput_stats(ues_ids=1, scell=None, type=None, **kwargs):
    CMD = 'ue_stats_nr id='
    if isinstance(ues_ids, list):
        ues_ids = ','.join(ues_ids)
    CMD = '{}{}'.format(CMD, ues_ids)
    if scell:
        CMD = '{} scell={}'.format(CMD, scell)
    if type:
        CMD = '{} type={}'.format(CMD, type)
    return run_egate_cmd_and_wait_for_data(CMD, **kwargs)


def check_ue_thput_stats_and_return_parse_output(ues_ids, scell=None, type=None):
    stats = check_ue_thput_stats(ues_ids, scell, type, pass_regexp='Total', logs='off')
    logging.debug(stats)
    ue_dict = _parse_ue_stats(stats)
    logging.debug(ue_dict)
    return ue_dict


def _parse_ue_stats(data):
    """
    Convert output from ue_stats_nr WTS command into list of throughput statistics per cell

    :param data: (str) ue_stats_nr WTS command output
    :return: list of dicts e.g. [{'CellIndex': 'CellIndex-0', 'Current': '68.6 Mbps',
             'Minimum': '66.1 Mbps', 'Maximum': '72.8 Mbps', 'Average': '69.3 Mbps'}, {...}, ...]
    """

    def validate_output():
        if not ue_stats:
            raise WrongUeThupValue('Could not retrieve UE throughput statistics')
        try:
            for item_dict in ue_stats:
                if not all(keys in ['CellIndex', 'Current', 'Minimum', 'Maximum', 'Average']
                           for keys in item_dict.keys()):
                    raise ValueError('Missing key in ue_stats')
        except ValueError as validation_failue:
            logging.debug(f'Parser output data: {ue_stats}')
            logging.debug(f'Parser input data: {[data]}')
            raise WrongUeThupValue('Failure during parsing UE throughput statistics') from validation_failue

    ue_stats = []
    tput_stats = [line for line in data.split('\r\n') if 'cellindex' in line.lower() and 'inf' not in line.lower()]
    key_tuple = tuple(tput_stats[0].split())
    for line in tput_stats[1:]:
        cell_tput_stats_dict = {}
        value_tuple = tuple([tput_val.strip() for tput_val in line.split('  ') if tput_val != ''])
        for key, value in zip(key_tuple, value_tuple):
            cell_tput_stats_dict.update({key: value})
        ue_stats.append(cell_tput_stats_dict)
    validate_output()
    return ue_stats


def get_tput_in_bytes(trf_string):
    units = {'mbps': 1000000, 'kbps': 1000, 'bps': 1}
    trf_value, trf_unit = trf_string.split(" ")
    return float(trf_value) * units[trf_unit.lower()]
