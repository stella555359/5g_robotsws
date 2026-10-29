import os
from taf.config.testline.info import info
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
mr_bts_id = tl.gnbs[0].instance_id
nr_bts_id = tl.gnbs[0].global_bts_id
_MRBTSname = 'MRBTS-' + str(mr_bts_id)
_NRBTSname = _MRBTSname + '/NRBTS-' + str(nr_bts_id)
_NRBTS_ID = 'NRBTS-' + str(nr_bts_id)


PARAM_7963_STRUCTURE1 = [
    dict(
        new_value=20,
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
        new_value=25,
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

ADD_ELEMENTS_7963 = [
    dict(
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
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

PARAM_7963_LOCALPRIOPROTY = [
              {'dist_name': 'MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1', 'parameter': 'topMasterList',
               'value': [{'localPriority': '20'}, {'localPriority': '15'}]},
              ]

PARAM_7963_LOCALPRIOPROTY_1 = [
              {'dist_name': 'MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1', 'parameter': 'topMasterList',
               'value': [{'localPriority': '10'}, {'localPriority': '15'}]},
              ]

DELETE_CABLINK = [{'dist_name': _MRBTSname + '/EQM-1/HWTOP-1/CABLINK-3'}]
ADD_CABLINK = [
              {'dist_name': _MRBTSname + '/EQM-1/HWTOP-1/CABLINK-3',
               'parameter': 'firstEndpointDN',
               'value': _MRBTSname + '/EQM-1/APEQM-1/CABINET-1/BBMOD-1'},
              {'dist_name': _MRBTSname + '/EQM-1/HWTOP-1/CABLINK-3',
               'parameter': 'firstEndpointLabel',
               'value': 'SFP'},
              {'dist_name': _MRBTSname + '/EQM-1/HWTOP-1/CABLINK-3',
               'parameter': 'firstEndpointPortId',
               'value': '2'},
              {'dist_name': _MRBTSname + '/EQM-1/HWTOP-1/CABLINK-3',
               'parameter': 'iqCompression',
               'value': 'eCPRI IQ9_E7'},
              {'dist_name': _MRBTSname + '/EQM-1/HWTOP-1/CABLINK-3',
               'parameter': 'linkSpeed',
               'value': 'eCpri25'},
              {'dist_name': _MRBTSname + '/EQM-1/HWTOP-1/CABLINK-3',
               'parameter': 'radioProtocolType',
               'value': 'eCPRI'},
              {'dist_name': _MRBTSname + '/EQM-1/HWTOP-1/CABLINK-3',
               'parameter': 'secondEndpointDN',
               'value': _MRBTSname + '/EQM-1/APEQM-1/RMOD-1'},
              {'dist_name': _MRBTSname + '/EQM-1/HWTOP-1/CABLINK-3',
               'parameter': 'secondEndpointLabel',
               'value': 'SFP'},
              {'dist_name': _MRBTSname + '/EQM-1/HWTOP-1/CABLINK-3',
               'parameter': 'secondEndpointPortId',
               'value': '2'},
              ]
PARAM_7963_LOCKSTATE = [
    dict(
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1/TOPP_R-1',
        filter_param='ToP slave lock state',
        abbr='lockState'
    )
]

PARAM_7963_SYNCSTATUS = [
    dict(
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/CLOCK_R-1',
        filter_param='Clock synchronization status',
        abbr='syncStatus'
    )
]

GET_PARAMETER_PORTNUMBER = [
    dict(
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1/TOPP_R-1',
        filter_param='Timing over Packet slave port number',
        abbr='topSlavePortNumber'
    )
]

GET_PARAMETER_TOPSTEPSREMOVED = [
    dict(
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1/TOPP_R-1',
        filter_param='Timing over Packet steps removed',
        abbr='topStepsRemoved'
    )
]

GET_PARAMETER_TOPMASTERCLOCKIDENTITY = [
    dict(
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1/TOPP_R-1',
        filter_param='ToP master clock identity',
        abbr='topMasterClockIdentity'
    )
]

PARAM_7963_SYNCIN_EXTERNAL = [
    dict(
        value=[{'syncInputPrio': '1', 'syncInputType': '1pps/ToD from external GNSS receiver'}],
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-1/CLOCK-1',
        parameter='syncInputList')
]

PARAM_7963_ACCEPTEDCLOCKCLASS = [
    dict(
        value=['6', '7'],
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        parameter='acceptedClockClass')
]

PARAM_7963_ACCEPTEDCLOCKCLASS_6 = [
    dict(
        value=['6'],
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        parameter='acceptedClockClass')
]

GET_PARAMETER_TOPGMASTERCLOCKCLASS = [
    dict(
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1/TOPP_R-1',
        filter_param='Grandmaster clock class',
        abbr='topGMasterClockClass'
    )
]

GET_PARAMETER_SYNCINPUTYPE = [
    dict(
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-1/CLOCK-1',
        filter_param='Sync input type',
        abbr='syncInputType'
    )
]
