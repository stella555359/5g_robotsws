"""Module to parse the out.log file of a test case and get the relevant pm files for executed scenarios
"""
from testsuite.Ulm.ET.L2.libraries import template_functions
import logging
import pathlib
import re
from datetime import datetime, timedelta
import time
import itertools

logger = logging.getLogger(__name__)


def configure_logger(log_dir):
    logger.setLevel(logging.DEBUG)
    file_handler = logging.FileHandler(f'{log_dir}/out_log_parser.log')
    file_handler.setLevel(logging.DEBUG)  # Set level for this handler
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)


def _read_file(file_path):
    logger.info('reading log file: %s', file_path)
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    return lines


def _get_kw_starts_and_ends(lines, kw_name):
    kw_starts = []
    kw_ends = []
    for line in lines:
        if f'START KEYWORD: {kw_name}' in line:
            kw_starts.append(line)
        if f'END KEYWORD: {kw_name}' in line:
            kw_ends.append(line)
    return kw_starts, kw_ends


def _extract_timestamp_from_out_log(line, timezone_correction):
    return (datetime.strptime(line.split('-')[0].strip(), r'%Y%m%d %H:%M:%S.%f') + timezone_correction)


def _map_to_scenarios(kw_starts, kw_ends, scenario_list):
    scenario_dict = {}
    offset_seconds = time.timezone if time.localtime().tm_isdst == 0 else time.altzone
    timezone_correction = timedelta(hours=(offset_seconds // 3600))
    for index, kw_start_time in enumerate(kw_starts):
        scenario = {
            'start': _extract_timestamp_from_out_log(kw_start_time, timezone_correction),
            'end': _extract_timestamp_from_out_log(kw_ends[index], timezone_correction)
        }
        scenario_dict.update({scenario_list[index]: scenario})
    return scenario_dict


def _get_pm_file_ranges(pm_file_dir):
    pm_files_time_coverage = {}
    date_pattern_start = re.compile(r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}')
    date_pattern_end = re.compile(r'\d{8}\.\d{6}')
    # PM.BTS-1.20241212.145500.ANY.xml
    for file in pathlib.Path(pm_file_dir).iterdir():
        # file_name is the ending of the pm interval. Beginning of the pm_interval can be read from the file.
        if '.raw' in file.name:
            continue
        try:
            with open(file, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            for line in lines:
                if 'startTime' in line:
                    timestring = re.search(date_pattern_start, line).group()
                    start = datetime.strptime(timestring, r'%Y-%m-%dT%H:%M:%S')
                    break
            match = re.search(date_pattern_end, file.name).group()
            end = datetime.strptime(match, r'%Y%m%d.%H%M%S')
            pm_files_time_coverage.update({str(file): {'start': start,
                                                       'end': end}})
        except AttributeError:
            pass
    logger.debug('pm_files_time_coverage: %s', pm_files_time_coverage)
    last_pm_file = sorted(pm_files_time_coverage.keys())[-1]
    pm_interval = int(((pm_files_time_coverage[last_pm_file]['end'] -
                        pm_files_time_coverage[last_pm_file]['start']).seconds / 60))
    logger.info('identified the pm interval, it is %s minutes', pm_interval)
    return pm_files_time_coverage, pm_interval


def _assign_pm_files_to_scenarios(scenario_dict, pm_file_ranges, pm_interval=5):
    for scenario, time_dict in scenario_dict.items():
        all_relevant_files = _get_multiple_files_for_scenario(time_dict['start'],
                                                              time_dict['end'],
                                                              pm_file_ranges,
                                                              pm_interval)
        timestamps = []
        for file in all_relevant_files:
            with open(file, 'r', encoding='utf-8') as f:
                match = re.search(r'(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}:\d{2})(:?.\d{3})(\+\d{2}:\d{2})(:?:\d{2})',
                                  f.read())
                timestamp = ' '.join(match.groups()[:2])
                timestamp = timestamp + match.group(4)
            timestamps.append(timestamp)
        scenario_dict[scenario].update({'timestamps': timestamps})
        scenario_dict[scenario].update({'pm_file': all_relevant_files})
    logger.debug('scenario_dict with pm files: %s', scenario_dict)
    return scenario_dict


def _get_multiple_files_for_scenario(scenario_start, scenario_end, pm_file_ranges, pm_interval):
    first_pm_file = _find_pm_file_starting_just_before_scenario(scenario_start, pm_file_ranges, pm_interval)
    last_pm_file = _find_pm_file_ending_just_after_scenario(scenario_end, pm_file_ranges)
    all_relevant_files = _get_pm_files_in_between(first_pm_file, last_pm_file, pm_file_ranges)
    logger.info('all relevant pm files for scenario %s', all_relevant_files)
    return all_relevant_files


def _find_pm_file_starting_just_before_scenario(scenario_start, pm_file_ranges, pm_interval):
    first_in_scenario = ''
    for file_name, time_range in pm_file_ranges.items():
        if timedelta(0) < (scenario_start - time_range['start']) < timedelta(minutes=pm_interval):
            first_in_scenario = file_name
            break
    logger.info('first pm file for scenario: %s', first_in_scenario)
    return first_in_scenario


def _find_pm_file_ending_just_after_scenario(scenario_end, pm_file_ranges):
    files_ending_after_scenario = []
    for file_name, time_range in pm_file_ranges.items():
        if (time_range['end'] - scenario_end) > timedelta(minutes=0):
            files_ending_after_scenario.append(file_name)
    try:
        last_file = sorted(files_ending_after_scenario)[0]
    except IndexError:
        logger.error('No pm files found for the scenario')
        last_file = ''
    logger.info('last pm file in scenario: %s', last_file)
    last_file = None if last_file == '' else last_file
    return last_file


def _get_pm_files_in_between(first_pm_file, last_pm_file, pm_file_ranges):
    pm_files = sorted(file for file in pm_file_ranges.keys())
    logger.info('first pm file: %s\t last pm file: %s', first_pm_file, last_pm_file)
    try:
        first_index = pm_files.index(first_pm_file)
        last_index = pm_files.index(last_pm_file)
    except ValueError as e:
        first_index = 0 if not first_pm_file else first_index
        logger.error('there was no pm file found for the scenario, the error is %s', e)
        if not last_pm_file:
            logger.warning('did not find the last pm_file in the scenario,'
                           ' using all files from the first onward.')
            return pm_files[first_index:]
    return pm_files[first_index: last_index + 1]


def get_relevant_pm_files(ts_log_dir, scenario_list, kw_name='5G_L3_call.5G L3 Call with traffic',
                          pm_location='/PMC/gnb_pm_counters') -> list[str]:
    """Get a list of all relevant pm files for the executed teal test case.

    Args:
        ts_log_dir (str): log directory of the test case
        scenario_list (str): list of all scenarios, can be provided by 'get_list_of_all_scenarios'
                             from template_functions.

    Returns:
        list[str]: list of all relevant pm files for the executed teal test case
    """
    scenario_dict = get_pm_file_scenario_dict(ts_log_dir, scenario_list,
                                              kw_name=kw_name,
                                              pm_location=pm_location)
    try:
        relevant_pm_files = [scenario_data['pm_file'] for scenario_data in scenario_dict.values()]
        relevant_pm_files = list(itertools.chain.from_iterable(relevant_pm_files))
    except KeyError:
        logger.error('No pm files found for the scenarios, the data in the scenario_dict is %s.', scenario_dict)
        relevant_pm_files = []
    return relevant_pm_files


def get_pm_file_scenario_dict(ts_log_dir, scenario_list: list[str], kw_name='5G_L3_call.5G L3 Call with traffic',
                              pm_location='/PMC/gnb_pm_counters') -> dict[str, str]:
    """Get a dictionary with the scenarios as keys and the pm files as values.

    Args:
        ts_log_dir (str): log directory of the test case
        scenario_list (list[str]): list of all scenarios, can be provided by 'get_list_of_all_scenarios'

    Returns:
        dict[str, str]: dictionary with the scenarios as keys and the pm files as values
    """
    configure_logger(ts_log_dir)
    ts_log_path = pathlib.Path(ts_log_dir).parent.parent.parent.parent
    debug_log_path = None
    if ts_log_path == pathlib.Path('.'):
        raise FileNotFoundError('No test log path found. Check the path to the test log directory.')
    log_files = [path for path in ts_log_path.iterdir() if path.suffix == '.log']
    for log_file in log_files:
        if log_file.name in ['debug.log', 'out.log']:
            debug_log_path = log_file
    if not debug_log_path:
        raise FileNotFoundError('No test log path found. Check the path to the test log directory.')
    scenario_dict = _get_scenario_dict_from_out_log(debug_log_path, scenario_list, kw_name=kw_name)
    pm_file_ranges, pm_interval = _get_pm_file_ranges(pm_file_dir=ts_log_dir + pm_location)
    scenario_dict = _assign_pm_files_to_scenarios(scenario_dict,
                                                  pm_file_ranges, pm_interval=pm_interval)
    return scenario_dict


def _get_scenario_dict_from_out_log(log_path, scenario_list, kw_name='5G_L3_call.5G L3 Call with traffic'):
    file_content = _read_file(log_path)
    kw_starts, kw_end = _get_kw_starts_and_ends(lines=file_content,
                                                kw_name=kw_name)
    return _map_to_scenarios(kw_starts, kw_end, scenario_list)


def _main():
    from testsuite.Ulm.resources.Common.ResourceCI.TEAL_resources.fully_loaded import teal_config
    template_functions.initialize_test(data=teal_config)
    scenario_list = template_functions.get_list_of_all_scenarios('test')
    print(get_relevant_pm_files('path/to/ts_log_dir', scenario_list))


if __name__ == '__main__':
    _main()
