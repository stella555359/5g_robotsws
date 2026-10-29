from robot.libraries.BuiltIn import BuiltIn
from testsuite.Krakow.OAM.regression.RAN_PZ_KRK4.CB012784.delta.TC_1_Possitive_scenario import *


tl = BuiltIn().get_variable_value('${tl}')
global_bts_id = tl.gnbs[0].dus[0].global_bts_id
none = None

message_mix_1 = "It's not allowed to mix counters from measurements on HW objects that are " \
                "not in a parent - one single direct child relationship in triggeringFormula:"
message_mix_2 = "Mix of cell/BTS counters with HW counters in triggeringFormula:"

expected_alarms_1 = []
expected_not_visible_alarms_1 = []
alarms_sfp_1 = {
    "SFP-1": {
        'faultId': 4570,
        'faultName': f'The following KPI formula {TC_1_alarm_1} has been evaluated to true: '
                     f'{TC_1_alarm_description_1}',
        'hwPath': f'/SFP_R-1/LANE_R-1'
    },
    "SFP-2": {
        'faultId': 4570,
        'faultName': f'The following KPI formula {TC_1_alarm_1} has been evaluated to true: '
                     f'{TC_1_alarm_description_1}',
        'hwPath': f'/SFP_R-2/LANE_R-1'
    }
}

alarms_sfp_2 = {
    "M40015C1": {
        "SFP-1": {
            'faultId': 4571,
            'faultName': f'The following KPI formula {TC_1_alarm_2[1]} has been evaluated to true: '
                         f'{TC_1_alarm_description_2[1]}',
            'hwPath': f'/SFP_R-1'
        },
        "SFP-2": {
            'faultId': 4571,
            'faultName': f'The following KPI formula {TC_1_alarm_2[1]} has been evaluated to true: '
                         f'{TC_1_alarm_description_2[1]}',
            'hwPath': f'/SFP_R-2'
        }
    },
    "M40015C5": {
        "SFP-1": {
            'faultId': 4588,
            'faultName': f'The following KPI formula {TC_1_alarm_2[4]} has been evaluated to true: '
                         f'{TC_1_alarm_description_2[4]}',
            'hwPath': f'/SFP_R-1/LANE_R-1'
        },
        "SFP-2": {
            'faultId': 4588,
            'faultName': f'The following KPI formula {TC_1_alarm_2[4]} has been evaluated to true: '
                         f'{TC_1_alarm_description_2[4]}',
            'hwPath': f'/SFP_R-2/LANE_R-1'
        }
    },
    "M40015C6": {
        "SFP-1": {
            'faultId': 4575,
            'faultName': f'The following KPI formula {TC_1_alarm_2[5]} has been evaluated to true: '
                         f'{TC_1_alarm_description_2[5]}',
            'hwPath': '/SFP_R-1/LANE_R-1'
        },
        "SFP-2": {
            'faultId': 4575,
            'faultName': f'The following KPI formula {TC_1_alarm_2[5]} has been evaluated to true: '
                         f'{TC_1_alarm_description_2[5]}',
            'hwPath': '/SFP_R-2/LANE_R-1'
        }
    }
}
expected_alarms_2 = [
    {
        'faultId': 4586,
        'faultName': f'The following KPI formula {TC_1_alarm_2[2]} has been evaluated to true: '
                     f'{TC_1_alarm_description_2[2]}',
        'hwPath': '/RMOD_R-1/opt_if1/SFP_R-2/LANE_R-1'
    },
    {
        'faultId': 4586,
        'faultName': f'The following KPI formula {TC_1_alarm_2[2]} has been evaluated to true: '
                     f'{TC_1_alarm_description_2[2]}',
        'hwPath': '/RMOD_R-1/opt_if0/SFP_R-1/LANE_R-1'
    },
    {
        'faultId': 4579,
        'faultName': f'The following KPI formula {TC_1_alarm_2[3]} has been evaluated to true: '
                     f'{TC_1_alarm_description_2[3]}',
        'hwPath': '/RMOD_R-1/opt_if0/SFP_R-1/LANE_R-1'
    },
    {
        'faultId': 4579,
        'faultName': f'The following KPI formula {TC_1_alarm_2[3]} has been evaluated to true: '
                     f'{TC_1_alarm_description_2[3]}',
        'hwPath': '/RMOD_R-1/opt_if1/SFP_R-2/LANE_R-1'
    }
]
expected_not_visible_alarms_2 = [
    {
        'faultId': 4570,
        'faultName': f'The following KPI formula {TC_1_alarm_2[0]} has been evaluated to true: '
                     f'{TC_1_alarm_description_2[0]}',
        'notifier': f' MRBTS-{global_bts_id}/EQM_R-1/APEQM_R-1/RMOD_R-1/SFP_R-1/LANE_R-1'
    },
    {
        'faultId': 4570,
        'faultName': f'The following KPI formula {TC_1_alarm_2[0]} has been evaluated to true: '
                     f'{TC_1_alarm_description_2[0]}',
        'notifier': f' MRBTS-{global_bts_id}/EQM_R-1/APEQM_R-1/RMOD_R-1/SFP_R-2/LANE_R-1'
    },
    {
        'faultId': 4576,
        'faultName': f'The following KPI formula {TC_1_alarm_2[6]} has been evaluated to true: '
                     f'{TC_1_alarm_description_2[6]}',
        'notifier': f' MRBTS-{global_bts_id}/EQM_R-1/APEQM_R-1/RMOD_R-1/SFP_R-1/LANE_R-1'
    },
    {
        'faultId': 4576,
        'faultName': f'The following KPI formula {TC_1_alarm_2[6]} has been evaluated to true: '
                     f'{TC_1_alarm_description_2[6]}',
        'notifier': f' MRBTS-{global_bts_id}/EQM_R-1/APEQM_R-1/RMOD_R-1/SFP_R-2/LANE_R-1'
    }
]
