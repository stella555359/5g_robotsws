import os
from taf.config.testline.info import info
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
mr_bts_id = tl.gnbs[0].instance_id
nr_bts_id = tl.gnbs[0].global_bts_id
_MRBTSname = 'MRBTS-' + str(mr_bts_id)
_NRBTSname = _MRBTSname + '/NRBTS-' + str(nr_bts_id)
_NRBTS_ID = 'NRBTS-' + str(nr_bts_id)


CB007963_TOPMASTER_LIST = [
    {
        'dist_name': _MRBTSname + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        'parameter': 'topMasterList',
        'value': [{
            'localPriority': '67',
            'phaseErrorComp': '0',
            'ruECpriPortNumber': '1',
            'topMasterId': '1'
            },
            {
            'localPriority': '55',
            'phaseErrorComp': '0',
            'ruECpriPortNumber': '2',
            'topMasterId': '2'
            }
        ]
    }
]

CB007963_TOPMASTER_LIST_TRUNK = [
    {
        'dist_name': _MRBTSname + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        'parameter': 'topMasterList',
        'value': [{
            'customizedPriority': '1',
            'localPriority': '67',
            'phaseErrorComp': '0',
            'ruECpriPortNumber': '1',
            'timeErrorThreshold': '1100',
            'topMasterId': '1'
            },
            {
            'customizedPriority': '1',
            'localPriority': '55',
            'phaseErrorComp': '0',
            'ruECpriPortNumber': '2',
            'timeErrorThreshold': '1100',
            'topMasterId': '2'
            }
        ]
    }
]

PARAM_7963_STRUCTURE1 = [
    dict(
        new_value=67,
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        filter_param='Local priority of slave port towards ToP master',
        abbr='localPriority'),
    dict(
        new_value=0,
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        filter_param='Phase error compensation',
        abbr='phaseErrorComp'),
    dict(
        new_value=1,
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        filter_param='RU eCPRI port Number',
        abbr='ruECpriPortNumber'),
    dict(
        new_value=1,
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        filter_param='Top Master identifier',
        abbr='topMasterId'),
]

PARAM_7963_STRUCTURE2 = [
    dict(
        new_value=55,
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        filter_param='Local priority of slave port towards ToP master',
        abbr='localPriority'),
    dict(
        new_value=0,
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        filter_param='Phase error compensation',
        abbr='phaseErrorComp'),
    dict(
        new_value=2,
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        filter_param='RU eCPRI port Number',
        abbr='ruECpriPortNumber'),
    dict(
        new_value=2,
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        filter_param='Top Master identifier',
        abbr='topMasterId'),
]

PARAM_7963_PDL_CHECK = [
    dict(
        new_value=3,
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        filter_param='RU eCPRI port Number',
        abbr='ruECpriPortNumber'),
]

ADD_ELEMENTS_7963 = [
    dict(
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        filter_param='Timing over Packet master properties list',
        abbr='topMasterList')
]

GET_ELEMENTS_7963 = [
    dict(
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1/TOPP_R-1',
        filter_param='Timing over Packet master properties list',
        abbr='topMasterList')
]

GET_PARAMETER_VALUES_7963 = [
    dict(
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1/TOPP_R-1',
        filter_param='Timing over Packet master clock state',
        abbr='topMasterClockState'),
    dict(
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1/TOPP_R-1',
        filter_param='ToP master used',
        abbr='topMasterUsed')
]

GET_PARAMETER_PORTNUMBER = [
    dict(
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1/TOPP_R-1',
        filter_param='Timing over Packet slave port number',
        abbr='topSlavePortNumber'
    )
]

PARAM_7963_LOCALPRIORITY = [
    dict(
        new_value=25,
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        filter_param='Local priority of slave port towards ToP master',
        abbr='localPriority'),
]

ALLOWED_FAULT = [
    {'faultId': 61652},
    {'faultId': 61524},
    {'faultId': 61649},
    {'faultId': 9000},
    {'faultId': 4592},
    {'faultId': 4527},
    {'faultId': 1932},
    {'faultId': 4334},
    {'faultId': 61074},
    {'faultId': 61618},
    {'faultId': 4687},
    {'faultId': 4654},
    {'faultId': 4655},
    {'faultId': 8150},
]

ALLOWED_HISTORY_FAULT = [
    {'faultId': 7319},
    {'faultId': 7300},
    {'faultId': 8150},
    {'faultId': 6327},
    {'faultId': 10},
]

ALLOWED_HISTORY_FAULT.extend(ALLOWED_FAULT)
