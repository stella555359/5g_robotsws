import testsuite.Ulm.ET.L2.libraries.config_file_helper as cfh


ue_groups = [
    cfh.UeGroup(name='ue_group_1', number_of_ues=2, ue_type='nsa'),
    cfh.UeGroup(name='ue_group_2', number_of_ues=1, ue_type='sa'),
    cfh.UeGroup(name='ue_group_3', number_of_ues=3, ue_type='nsa'),
    cfh.UeGroup(name='ue_group_4', number_of_ues=3, ue_type='sa')
]


def get_scenarios():
    scenario_1 = cfh.Scenario(name='scenario_1')
    scenario_1.cells_ue_mapping = {'tdd_cell_1': {
        'ue_groups': ['ue_group_1']}}
    scenario_1.traffic_profiles = {'ue_group_1': ['traffic_profile_1']}
    scenario_1.with_pm_counters = True
    scenario_2 = cfh.Scenario('scenario_2')
    scenario_2.cells_ue_mapping = {
        'tdd_cell_1': {'ue_groups': ['ue_group_1', 'ue_group_4']},
        'tdd_cell_2': {'ue_groups': ['ue_group_2', 'ue_group_3']}}
    scenario_2.traffic_profiles = {
        "ue_group_1": ["traffic_profile_1"],
        "ue_group_2": ["traffic_profile_1", "traffic_profile_2"],
        "ue_group_3": ["traffic_profile_3", "traffic_profile_4"]}
    scenario_2.with_pm_counters = True
    scenario_3 = cfh.Scenario('scenario_3')
    scenario_3.cells_ue_mapping = {
        "tdd_cell_1": {
            "ue_groups": ["ue_group_1"]},
        "tdd_cell_2": {
            "ue_groups": ["ue_group_2", "ue_group_3"]}}
    scenario_3.traffic_profiles = {
        "ue_group_1": ["traffic_profile_2"],
        "ue_group_2": ["traffic_profile_2"],
        "ue_group_3": ["traffic_profile_3"]}
    scenario_3.with_pm_counters = True
    return [scenario_1, scenario_2, scenario_3]


def get_traffic_profile_list():
    return [
        cfh.TrafficProfile(name='traffic_profile_1', throughput_ul=100, throughput_dl=100, traffic_duration_sec=3),
        cfh.TrafficProfile(name='traffic_profile_2', throughput_ul=69, throughput_dl=69, traffic_duration_sec=60),
        cfh.SpecialTrafficProfile(
            name='traffic_profile_3', rtp_codec='amr_wb_23_85',
            rtp_voice_silence='1:0', direction='dl', traffic_duration_sec=10),
        cfh.TrafficProfile('traffic_profile_4', throughput_ul=20, throughput_dl=10, traffic_duration_sec=3)
    ]


def get_ue_groups():
    return [
        cfh.UeGroup(name='ue_group_1', number_of_ues=2, ue_type='nsa'),
        cfh.UeGroup(name='ue_group_2', number_of_ues=1, ue_type='sa'),
        cfh.UeGroup(name='ue_group_3', number_of_ues=3, ue_type='nsa'),
        cfh.UeGroup(name='ue_group_4', number_of_ues=3, ue_type='sa')
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


scenario_configuration = {
    'csi_report_priodicity_160': {
        'nidd_param_change_1': {
            'regex': 'MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+',
            'list_name': 'periodicCsiAcquisition',
            'p_name': 'csiReportPeriodicity',
            'value': 'slots160'}
    },
    'modified_reqMinNumPuschPrb': {
        'nidd_param_change_1': {
            'regex': 'MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+',
            'p_name': 'reqMinNumPuschPrb',
            'value': '30'}
    },
    'modified_reqMinNumPuschPrb_orig': {
        'nidd_param_change_1': {
            'regex': 'MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+',
            'p_name': 'reqMinNumPuschPrb',
            'value': '13'}
    }
}


log_and_traces = cfh.LogsAndTraces(KPI={
    'calculation': 'True',
    'pm_options': {},
    'runtime_options': {}
})

teal_config = cfh.TealConfig(
    test_description=cfh.TestDescription(get_scenarios()),
    ue_profiles=cfh.UeProfiles(get_ue_groups()),
    traffic_profiles=cfh.TrafficProfiles(get_traffic_profile_list()),
    logs_and_traces=log_and_traces
).get_dict()
