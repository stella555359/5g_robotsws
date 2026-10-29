import testsuite.Ulm.ET.L2.libraries.config_file_helper as cfh


def get_scenarios():
    scenario_1 = cfh.Scenario(name='scenario_1')
    scenario_1.cells_ue_mapping = {'tdd_cell_1': {
        'ue_groups': ['ue_group_1', 'ue_group_2']}}
    scenario_1.traffic_profiles = {'ue_group_1': ['traffic_profile_1'],
                                   'ue_group_2': ['traffic_profile_1']}
    scenario_1.with_pm_counters = True
    return [scenario_1]


def get_traffic_profile_list():
    return [
        cfh.TrafficProfile(name='traffic_profile_1', throughput_ul=100, throughput_dl=100, traffic_duration_sec=3),
    ]


def get_ue_groups():
    return [
        cfh.UeGroup(name='ue_group_1', number_of_ues=1, ue_type='nsa'),
        cfh.UeGroup(name='ue_group_2', number_of_ues=1, ue_type='sa'),
    ]


csi_report_profile = {
    'csi_profile_160': {
        'cqi': 10,
        'ri': 1,
        'pmi': 0},
    'csi_profile_320': {
        'cqi': 8,
        'ri': 0,
        'pmi': 1}
}


scenario_configuration = {}


log_and_traces = cfh.LogsAndTraces(
    TTITrace={
        'collection': True,
        'conversion': {
            'excelCSV': True,
            'pickled_df': True
        }}
)

teal_config = cfh.TealConfig(
    test_description=cfh.TestDescription(get_scenarios()),
    ue_profiles=cfh.UeProfiles(get_ue_groups()),
    traffic_profiles=cfh.TrafficProfiles(get_traffic_profile_list()),
    logs_and_traces=log_and_traces
).get_dict()
