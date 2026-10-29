from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.json_reader import JsonReader
from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.parsers import ScenarioParser, LogsTracesParser
from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.basic_config_modifer import Modifier


PATH_TO_BASIC_CFG = '/opt/iphy/latest/basic_setup.cfg'
PATH_TO_BASIC_CFG_MODIFIED = '/opt/iphy/latest/basic_setup.cfg'


def initialize_test(relative_path_to_json, path_to_basic_cfg=PATH_TO_BASIC_CFG,
                    modified_file_path=PATH_TO_BASIC_CFG_MODIFIED, is_classical=True):
    global scenario_parser
    global logs_traces_parser
    global basic_config_modifier
    global reader_obj
    reader_obj = JsonReader(relative_path_to_json=relative_path_to_json, basic_setup_path=path_to_basic_cfg)
    scenario_parser = ScenarioParser(reader_obj, is_classical)
    logs_traces_parser = LogsTracesParser(reader_obj, is_classical)
    basic_config_modifier = Modifier(path_to_basic_cfg, modified_file_path, scenario_parser)


def get_json_file_path():
    return reader_obj.absolute_path_to_json


def get_attach_list(scenario_name, ue_type='all', with_auto_attach=True):
    return scenario_parser.scenarios[scenario_name].get_ue_attach_list(connection_type=ue_type,
                                                                       with_auto_attach=with_auto_attach)


def get_attach_list_per_cell(scenario_name, ue_type='all', with_auto_attach=True):
    ue_attach_list = scenario_parser.scenarios[scenario_name].get_ue_attach_list(connection_type=ue_type,
                                                                                 with_auto_attach=with_auto_attach)
    ue_attach_list_per_cell = {}
    for key1, value1 in ue_attach_list.items():
        for key2, value2 in value1.items():
            cell = value2['cell']
            if cell not in ue_attach_list_per_cell:
                ue_attach_list_per_cell[cell] = []
            ue_attach_list_per_cell[cell].append(key2)
    return ue_attach_list_per_cell


def get_expected_throughput_per_cell(scenario_name):
    return scenario_parser.scenarios[scenario_name].get_expected_throughput_per_cell()


def get_expected_throughput_per_ue(scenario_name):
    return scenario_parser.scenarios[scenario_name].get_expected_throughput_per_ue()


def get_variable_cell_dict():
    return reader_obj.variable_cell_dict


def get_traffic_commands(scenario_name):
    return scenario_parser.scenarios[scenario_name].get_traffic_commands()


def get_commissioned_object_list(scenario_name, scf_content):
    return scenario_parser.scenarios[scenario_name].get_commissioned_object_list(scf_content)


def get_bearer_stat_params(scenario_name):
    return scenario_parser.scenarios[scenario_name].get_bearer_stat_parameters()


def get_list_of_all_scenarios(test_tags):
    return scenario_parser.get_list_of_scenario_names(test_tags)


def get_required_tests_for_scenario(scenario_name):
    return scenario_parser.get_required_tests_for_scenario(scenario_name)


def get_tags_required_tests_for_scenario(scenario_name):
    return scenario_parser.get_tags_for_required_tests_for_scenario(scenario_name)


def create_collector_dict(test_tags):
    scenario_names = sorted(get_list_of_all_scenarios(test_tags))
    collector_dict = {}
    for name in scenario_names:
        collector_dict.update({name: {}})
    return collector_dict


def get_test_names_from_process():
    return scenario_parser.get_test_names_from_process()


def is_with_pm_counters(scenario_name):
    return scenario_parser.scenarios[scenario_name].with_pm_counters


def pm_counter_start_before_L3(scenario_name):
    return scenario_parser.scenarios[scenario_name].pm_counter_start_before_L3


def is_scenario_modifications_configured(scenario_name):
    if len(scenario_parser.scenarios[scenario_name].scenario_modifications):
        return True, scenario_parser.scenarios[scenario_name].scenario_modifications
    else:
        return False, None


def get_filter_bitmaps_for_current_scenario(scenario_name):
    return scenario_parser.scenarios[scenario_name].filter_bitmaps


def get_special_keywords_for_scenario(scenario_name):
    return scenario_parser.scenarios[scenario_name].special_keywords


def get_csi_report_configured_for_scenario(scenario_name):
    """Returns the CSI report settings for each ue_group for the selected scenario.

    Args:
        scenario_name (str): the name of the scenario

    Returns:
        dict: A dictionary containing the ue_group, the settings and the ue_ids, example:
        {'ue_group_1':
            {'profile_id': 2,
             'cqi_params':
                {'cqi': 8, 'ri': 0, 'pmi': 1},
             'ue_ids': '101,102,103,104'}}
    """
    return scenario_parser.scenarios[scenario_name].get_csi_report_profile_dict()


def get_max_traffic_length(scenario_name):
    return scenario_parser.scenarios[scenario_name].get_max_traffic_length()


def get_collector_name(scenario_name):
    return scenario_parser.scenarios[scenario_name].collector_name


def set_rnti_for_ue(scenario_name, ue_id, rnti):
    scenario_parser.scenarios[scenario_name].save_rnti_for_ue_id(rnti, ue_id)


def set_rnti_lte_for_ue(scenario_name, ue_id, rnti_lte):
    scenario_parser.scenarios[scenario_name].save_rnti_lte_for_ue_id(rnti_lte, ue_id)


def get_rntis_for_ue_group(scenario_name, ue_group_name=None):
    return scenario_parser.scenarios[scenario_name].get_rntis_for_ue_group(ue_group_name)


def get_rntis_lte_for_ue_group(scenario_name, ue_group_name=None):
    return scenario_parser.scenarios[scenario_name].get_rntis_lte_for_ue_group(ue_group_name)


def get_max_num_of_ues_configured(scenario_name=None):
    if get_max_num_of_ues_configured:
        return scenario_parser.scenarios[scenario_name].get_max_num_of_ues()
    else:
        """TO DO : Return sum of all SA / NSA UEs configured in JSON"""
        return 0, 0


def get_ue_ids_configured_for_scenario(scenario_name):
    return scenario_parser.scenarios[scenario_name].get_ue_ids_configured_for_scenario()


def identify_required_nr_cells():
    return scenario_parser.identify_required_cells()


def get_total_number_of_ues_configured_per_cell(scenario_name=None):
    if not scenario_name:
        return scenario_parser.num_ues_per_cell
    else:
        return scenario_parser.scenarios[scenario_name].num_ues_per_cell_in_scenario


def get_logs_and_traces_flags():
    return logs_traces_parser.logs_and_traces_flags


def get_extra_options_flags():
    return logs_traces_parser.extra_options


def get_ttitrace_start_point():
    return logs_traces_parser.tti_trace_start


def get_ttitrace_stop_point_and_delay():
    return logs_traces_parser.tti_trace_stop, logs_traces_parser.tti_trace_stop_delay


def get_biptrace_start_point():
    return logs_traces_parser.bip_trace_start


def get_biptrace_stop_point_and_delay():
    return logs_traces_parser.bip_trace_stop, logs_traces_parser.bip_trace_stop_delay


def get_dcap_start_point():
    return logs_traces_parser.dcap_trace_start


def get_dcap_stop_point():
    return logs_traces_parser.dcap_trace_stop


def get_backhaul_start_point():
    return logs_traces_parser.backhaul_trace_start


def get_backhaul_stop_point():
    return logs_traces_parser.backhaul_trace_stop


def configure_basic_cfg_file():
    basic_config_modifier.load_basic_cfg()
    basic_config_modifier.initialize_basic_config_file()
    basic_config_modifier.configure_new_cells()
    basic_config_modifier.configure_ues()
    basic_config_modifier.save_modified_basic_cfg()


def get_list_of_ues_for_pdu_modification(scenario_name, ue_type):
    ue_id_qos_flow_config = {}
    list_of_ues_configured_for_scenario =\
        get_attach_list(scenario_name, ue_type=ue_type, with_auto_attach=True)
    for ue_id, ue_config in list_of_ues_configured_for_scenario.items():
        ue_id_qos_flow_config[ue_id] = {'qos_flows': ue_config['qos_flows'], 'pdu': str(ue_config['pdu'])}
    return ue_id_qos_flow_config


def test_main():
    file_path = '../resourcesTests/fully_loaded.json'
    initialize_test(file_path)
    print(get_traffic_commands('scenario_1'))
    print(get_attach_list('scenario_1'))
    print(get_extra_options_flags())
    print(get_logs_and_traces_flags())
    print(get_attach_list_per_cell('scenario_1'))

    attach_list_per_cell = get_attach_list_per_cell('scenario_1')
    print(f"attach_list_per_cell1={attach_list_per_cell['tdd_cell_1']}")
    print(f"attach_list_per_cell={attach_list_per_cell}")


if __name__ == "__main__":
    test_main()
