from taf.collectors.pmcounters import pmcounters
from taf.analyzer.pmcounter.interface import pmcounter

from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.robot_globals import robot_globals
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
import os

"""
Usage:          ${pi_dir}=    collect_counters    log_name=pm_counters   target_dir=example
                ${pm_counters}=     Create List    M55320C19001    M55320C19003
                get_relevant_pm_counters    ${pi_dir}    ${pm_counters}

Description:    output file structure follows this pattern:
                "target_dir/log_name/*.xml" or "target_dir/log_name/*.raw"
"""


@logged_keyword
def collect_counters(log_name='pm_counters', target_dir=None, host=None, user=None, password=None):
    outputdir = robot_globals.outputdir()
    testname = robot_globals.testname()
    target_dir = os.path.join(outputdir, testname) if target_dir is None else target_dir

    host = tl.gnbs[0].cu.oam_http_connection_details.addr if host is None else host
    user = tl.gnbs[0].cu.oam_http_connection_details.username if user is None else user
    password = tl.gnbs[0].cu.oam_http_connection_details.password if password is None else password
    webservice = {'host': host, 'user': user, 'password': password, 'port': 443}

    pm_collector = pmcounters()
    pm_collector.create_pm_collector(name=log_name, webservice=webservice)
    pm_collector.setup_collectors(names=log_name)
    pm_collector.collect_collectors(names=log_name, target_dir=target_dir)
    pm_collector.teardown_collectors(names=log_name)

    return os.path.join(target_dir, log_name)


@logged_keyword
def extract_values_from_pi_dict(pi_dict):
    result_dict = {}
    pi_dict = [entry for entry in pi_dict if list(list(entry.values())[0].values())[0]]
    for date_entry in pi_dict:
        counter_id_dict = list(date_entry.values())[0]
        counter_id = list(counter_id_dict.keys())[0]
        mrbts_dict = list(counter_id_dict.values())[0]
        for cell_id, counter_val in mrbts_dict.items():
            cell_id = cell_id.split('-')[-1]
            if counter_id in result_dict.keys() and cell_id in result_dict[counter_id].keys():
                result_dict[counter_id][cell_id].append(int(counter_val))
            else:
                result_dict[counter_id] = {k.split('-')[-1]: [int(v)]
                                           for (k, v)
                                           in mrbts_dict.items()}
    return result_dict


@logged_keyword
def get_relevant_pm_counters(pi_dir, counter_ids):
    analyzer = pmcounter()
    pi_dict = analyzer.get_pi_value(pi_list=counter_ids, pi_dir=pi_dir, pi_file_pattern='PM*.[rx][am][wl]')
    value_dict = extract_values_from_pi_dict(pi_dict)
    blog('Returned counter values dict: {}'.format(value_dict))

    return value_dict


@logged_keyword
def remove_counter_files_except_for_last(pi_dir, n_last):
    files = os.listdir(pi_dir)
    for f in files[:-1 * n_last]:
        if f.endswith(('*.xml', '*.raw')):
            os.remove(f)


@logged_keyword
def check_counter_equals_x(pi_dir, counter_name, object_id, x, error_margin=0, n_last_values=1):
    compare_counters(pi_dir, counter_name, object_id, assert_equals_x, x,
                     error_margin=error_margin, n_last_values=n_last_values)


@logged_keyword
def check_counter_less_than_x(pi_dir, counter_name, object_id, x, error_margin=0, n_last_values=1):
    compare_counters(pi_dir, counter_name, object_id, assert_less_than_x, x,
                     error_margin=error_margin, n_last_values=n_last_values)


@logged_keyword
def check_counter_greater_than_x(pi_dir, counter_name, object_id, x, error_margin=0, n_last_values=1):
    compare_counters(pi_dir, counter_name, object_id, assert_greater_than_x, x,
                     error_margin=error_margin, n_last_values=n_last_values)


@logged_keyword
def compare_counters(pi_dir, counter_name, object_id, comparison_function, x, error_margin=0, n_last_values=1):
    processed_counter_values = get_processed_counters(pi_dir, counter_name, object_id, n_last_values)
    comparison_function(processed_counter_values, counter_name, x, error_margin)


@logged_keyword
def get_processed_counters(pi_dir, counter_name, object_id, n_last_values=1):
    counter_ids = [counter_name]
    value_dict = get_relevant_pm_counters(pi_dir, counter_ids)
    gathered_values = []

    for idx, counter_values in value_dict[counter_name].items():
        if idx in object_id:
            blog('counter: {}. object_id: {}. value: {}'.format(counter_name, idx, counter_values[-n_last_values:]))
            gathered_values += counter_values[-n_last_values:]

    assert gathered_values, 'No relevant PM counters were found in the collected logs.'
    return gathered_values


def assert_equals_x(processed_counter_values, counter_name, x, error_margin):
    assert any(abs(int(el) - int(x)) <= int(error_margin) for el in processed_counter_values), \
        'Value of counter {} is invalid. Expected:{}. Current:{}.'.format(
            counter_name, x, str(processed_counter_values))


def assert_less_than_x(processed_counter_values, counter_name, x, error_margin):
    assert any(int(el) < int(x) + int(error_margin) for el in processed_counter_values), \
        'Value of counter {} is invalid. Expected < {}. Current: {}.'.format(
            counter_name, x, processed_counter_values)


def assert_greater_than_x(processed_counter_values, counter_name, x, error_margin):
    assert any(int(el) > int(x) - int(error_margin) for el in processed_counter_values), \
        'Value of counter {} is invalid. Expected > {}. Current: {}.'.format(
            counter_name, x, processed_counter_values)
