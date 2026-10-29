import time
import json
import pathlib
import sys

import testsuite.Ulm.ET.L2.libraries.template_functions as tf
from testsuite.Ulm.ET.L2.compatibility.libraries.helpers import dynamic_import


def get_function_output(func_with_args):
    try:
        function = func_with_args[0]
        args = func_with_args[1:]
    except TypeError:
        return {func_with_args.__name__: func_with_args()}
    result = function(*args)
    return {function.__name__: result}


def get_list_of_functions_to_execute(robotws_parent_dir, scenario=None):
    with open(f'{robotws_parent_dir}/robotws/testsuite/Ulm/ET/L2/compatibility/default_scf.scf', 'r') as scf_content:
        scf_content = scf_content.read()
    function_list = [
        (tf.get_attach_list, scenario),
        (tf.get_traffic_commands, scenario),
        (tf.get_commissioned_object_list, scenario, scf_content),
        (tf.get_bearer_stat_params, scenario),
        (tf.is_with_pm_counters, scenario),
        (tf.is_scenario_modifications_configured, scenario),
        (tf.get_filter_bitmaps_for_current_scenario, scenario),
        (tf.get_special_keywords_for_scenario, scenario),
        (tf.get_csi_report_configured_for_scenario, scenario),
        (tf.get_max_traffic_length, scenario),
        (tf.get_collector_name, scenario),
        (tf.set_rnti_for_ue, scenario, 101, 123121),
        (tf.get_rntis_for_ue_group, scenario),
        (tf.get_max_num_of_ues_configured, scenario),
        (tf.get_ue_ids_configured_for_scenario, scenario),
        (tf.get_total_number_of_ues_configured_per_cell, scenario),
        (tf.get_list_of_ues_for_pdu_modification, scenario, 'sa')]

    function_list_without_scenario = [
        (tf.get_list_of_all_scenarios, ''),
        (tf.create_collector_dict, ''),
        # (tf.get_test_names_from_process),
        (tf.identify_required_nr_cells),
        (tf.get_logs_and_traces_flags),
        (tf.get_extra_options_flags),
        (tf.get_ttitrace_start_point),
        (tf.get_ttitrace_stop_point_and_delay),
        (tf.get_biptrace_start_point),
        (tf.get_biptrace_stop_point_and_delay),
        (tf.get_dcap_start_point),
        (tf.get_dcap_stop_point),
        (tf.get_variable_cell_dict),
        (tf.get_total_number_of_ues_configured_per_cell)
    ]
    if scenario:
        return function_list
    else:
        return function_list_without_scenario


def run_all_functions_for_file(full_file_path, robotws_parent_dir):
    config_file_path = pathlib.Path(full_file_path)
    relative_path_to_ET = config_file_path.relative_to(
        f'{robotws_parent_dir}/robotws/testsuite/Ulm/ET')
    relative_json_path = f'../../{relative_path_to_ET}'
    function_output_dict = {'json_path_used_for_creation': full_file_path}
    before_init = time.perf_counter()
    if '.py' == config_file_path.suffix:
        config_data = config_data = dynamic_import(str(config_file_path)).teal_config
        relative_json_path = None
    else:
        config_data = None
    config_file_path = config_file_path.with_suffix('.cfg')
    tf.initialize_test(relative_path_to_json=relative_json_path,
                       path_to_basic_cfg=f'{robotws_parent_dir}/basic_setup.cfg',
                       modified_file_path=f'{robotws_parent_dir}/generated_output_files/'
                                          f'last_run/{config_file_path.parent.name}'
                                          f'_{config_file_path.name}',
                       data=config_data)
    config_file_path = config_file_path.with_suffix('.json')
    after_init = time.perf_counter()
    print(f'Initialize test took {after_init - before_init}')
    for scenario in tf.get_list_of_all_scenarios(test_tags=''):
        function_output_dict.update({scenario: {}})
        for function in get_list_of_functions_to_execute(robotws_parent_dir, scenario):
            function_output_dict[scenario].update(
                get_function_output(function))
    for non_scenario_function in get_list_of_functions_to_execute(robotws_parent_dir):
        function_output_dict.update(get_function_output(non_scenario_function))

    tf.configure_basic_cfg_file()
    output_file_path = f'{robotws_parent_dir}/generated_output_files/last_run/'
    output_file_name = f'{config_file_path.parent.name}_{config_file_path.name}'
    with open(output_file_path + output_file_name, 'w') as f:
        json.dump(function_output_dict, f, indent=4, sort_keys=True)


if __name__ == '__main__':
    try:
        config_file = sys.argv[1]
        robotws_parent_dir = sys.argv[2]
    except IndexError:
        config_file = '/home/ute/DEVELOPMENT/robotws/testsuite/Ulm/ET/CB011006/CB011006_B06_B07_B08.json'
        robotws_parent_dir = '/home/ute/DEVELOPMENT'
    run_all_functions_for_file(config_file, robotws_parent_dir)
