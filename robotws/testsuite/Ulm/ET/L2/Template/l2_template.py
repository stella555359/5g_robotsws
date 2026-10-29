import testsuite.Ulm.ET.L2.libraries.config_file_helper as cfh

PYTHON_RESOURCE = True

scenario_1 = cfh.Scenario(name='scenario_1')
scenario_2 = cfh.Scenario(name='scenario_2')

cells_ue_mapping = {'fdd_cell_1': {'ue_groups': ['ue_group_1', 'ue_group_2']}}
traffic_profiles = {'ue_group_1': ['profile_1']}


ue_group = cfh.UeGroup(name='ue_group_1', number_of_ues=5, ue_type='nsa')
ue_group_2 = ue_group.clone(new_name='ue_group_2')

traffic_profile = cfh.TrafficProfile('profile_1', traffic_duration_sec=5, throughput_dl=10, throughput_ul=20)


scenario_1.cells_ue_mapping = cells_ue_mapping
scenario_1.traffic_profiles = traffic_profiles
scenario_1.with_pm_counters = False
scenario_2.cells_ue_mapping = cells_ue_mapping
scenario_2.traffic_profiles = traffic_profiles
scenario_1.special_keywords = []


scenario_3 = scenario_1.clone('scenario_3')


teal_config = cfh.TealConfig(
    test_description=cfh.TestDescription([scenario_1, scenario_2, scenario_3]),
    logs_and_traces=cfh.LogsAndTraces(),
    ue_profiles=cfh.UeProfiles([ue_group, ue_group_2]),
    traffic_profiles=cfh.TrafficProfiles([traffic_profile])).get_dict()
