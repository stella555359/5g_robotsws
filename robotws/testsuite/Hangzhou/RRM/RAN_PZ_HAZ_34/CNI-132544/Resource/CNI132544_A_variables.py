from robot.libraries.BuiltIn import BuiltIn
import time
from datetime import datetime

tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Li Xiaodan'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'xiaodan.li@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_global_id = str(tl.gnbs[0].global_bts_id)
_MRBTSname = 'MRBTS-' + _global_id
_NRBTSnames = 'NRBTS-' + _gnb_id
_NRBTSname = _MRBTSname + '/NRBTS-' + _gnb_id
_LNBTSname = _MRBTSname + '/LNBTS-' + _gnb_id
_RMOD1 = _MRBTSname + '/EQM-1/APEQM-1/RMOD-9'
_RMOD2 = _MRBTSname + '/EQM-1/APEQM-1/RMOD-2'
_RMOD3 = _MRBTSname + '/EQM-1/APEQM-1/RMOD-3'
_NRCELL21 = _NRBTSname + '/NRCELL-21'
_NRCELL700 = _NRBTSname + '/NRCELL-700'
_NRCELL701 = _NRBTSname + '/NRCELL-701'
_NRCELL400 = _NRBTSname + '/NRCELL-400'
_NRCELL410 = _NRBTSname + '/NRCELL-410'
_NRCELL544 = _NRBTSname + '/NRCELL-544'
_NRCELL644 = _NRBTSname + '/NRCELL-644'
_NRCELL545 = _NRBTSname + '/NRCELL-545'
_NRCELL645 = _NRBTSname + '/NRCELL-645'
_NRCELL303 = _NRBTSname + '/NRCELL-303'
_NRCELL304 = _NRBTSname + '/NRCELL-304'
_NRCELL311 = _NRBTSname + '/NRCELL-311'
_NRCELL312 = _NRBTSname + '/NRCELL-312'
_NRCELL313 = _NRBTSname + '/NRCELL-313'
_NRCELL314 = _NRBTSname + '/NRCELL-314'

Modify_Para_Online_EDSM = [
    dict(value='DEEPSLEEP_EXTREME_SFP', dist_name=_RMOD1, parameter='energySavingMode'),
    dict(value='true', dist_name=_NRBTSname, parameter='actCellSwitchOnForCmUpdate'),
    dict(value='barred', dist_name=_NRCELL400, parameter='cellBarred'),
    dict(value='barred', dist_name=_NRCELL410, parameter='cellBarred'),
    dict(value='barred', dist_name=_NRCELL544, parameter='cellBarred'),
    dict(value='barred', dist_name=_NRCELL644, parameter='cellBarred'),
    dict(value='barred', dist_name=_NRCELL545, parameter='cellBarred'),
    dict(value='barred', dist_name=_NRCELL645, parameter='cellBarred')
]

Modify_Para_Online_132544_15 = [
    dict(value='Locked', dist_name=_NRCELL700, parameter='administrativeState'),
    dict(value='Locked', dist_name=_NRCELL701, parameter='administrativeState')
]

Modify_Para_Online_132544_15_1 = [
    dict(value='false', dist_name=_NRBTSname + '/NRDU-9999', parameter='actUlCaWith3Tx'),
    dict(value='Unlocked', dist_name=_NRCELL700, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_NRCELL701, parameter='administrativeState')
]

Modify_Para_Online_132544_15_2 = [
    dict(value='true', dist_name=_NRBTSname + '/NRDU-9999', parameter='actUlCaWith3Tx')
]

Modify_Para_Online_132544_15_unlock = [
    dict(value='Unlocked', dist_name=_NRCELL700, parameter='administrativeState'),
    dict(value='Unlocked', dist_name=_NRCELL701, parameter='administrativeState'),
    dict(value='true', dist_name=_NRBTSname + '/NRDU-9999', parameter='actUlCaWith3Tx')
]

Modify_Para_Online_132544_06 = [
    dict(value='NORMAL', dist_name=_RMOD1, parameter='energySavingMode'),
]

Modify_Para_Online_132544_06_1 = [
    dict(value='DEEPSLEEP_EXTREME_SFP', dist_name=_RMOD1, parameter='energySavingMode'),
]

PARAMETERS_DSM_JSON_FILE = 'PARAMETERS_DSM_JSON_FILE.json'

PARAMETERS_DSM = [
    {
        "distName": _RMOD1,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "energySavingMode",
                "value": "DEEPSLEEP_EXTREME_SFP",
                "operation": "update"
            }
        ]
    },
    {
        "distName": _NRBTSname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actCellSwitchOnForCmUpdate",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actNrLBRTXPowerSaving",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actNrLBmMimoRTXPowerSaving",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actLbpsCtrlLogicEnh",
                "value": "true",
                "operation": "update"
            },
        ]
    },
    {
        "distName": _NRBTSname + '/NRPGRP-0',
        "operation": "update",
        "parameters": [
            {
                "parameterName": "lbpsLastCellSOEnabled",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "lbpsLastCellRTXMinLoad",
                "operation": "update",
                "value": "25"
            },
            {
                "parameterName": "lbpsMonWinForCellSOff",
                "operation": "update",
                "value": "60"
            },
            {
                "parameterName": "lbpsRTXSOffTime",
                "operation": "update",
                "value": "30"
            }, {
                "parameterName": "lbpsRTXSOnTime",
                "operation": "update",
                "value": "30"
            },
            {
                "parameterName": "lbpsSOnTrRule",
                "operation": "update",
                "value": "MinValueMethod"
            },
            {
                "parameterName": "lbpsCellList",
                "operation": "update",
                "value": [
                    dict(lbpsCellSOOrder='30', lbpsUseExtConfig='true', nrCellId='700'),
                    dict(lbpsCellSOOrder='40', lbpsUseExtConfig='true', nrCellId='701'),
                    dict(lbpsCellSOOrder='50', lbpsUseExtConfig='true', nrCellId='400')
                ]
            },
            {
                "parameterName": "lbpsPeriodList",
                "operation": "update",
                "value": [
                    dict(lbpsDayOfWeek='Tue', lbpsDuration='60',
                         lbpsStartTimeHour='8', lbpsStartTimeMinute='0', lbpsSuspended='notSuspended'),
                ]
            },
            {
                "parameterName": "lbpsCellPeriodList",
                "operation": "update",
                "value": [
                    dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
                         lbpsCellStartTimeHour='8', lbpsCellStartTimeMinute='0', nrCellId='700'),
                    dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
                         lbpsCellStartTimeHour='8', lbpsCellStartTimeMinute='0', nrCellId='701'),
                    dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
                         lbpsCellStartTimeHour='8', lbpsCellStartTimeMinute='0', nrCellId='400'),
                ]
            },
        ]
    },
    {
        "distName": _NRCELL700,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "beamSet",
                "operation": "update",
                "value": [
                    dict(tiltOffset='0', basicBeamSet='beamSet_3_1', leftEdgeAngle='45', nrBtsBeamRefinementP2='false',
                         rightEdgeAngle='45'),
                ],
            },
            {
                "parameterName": "actPriorityAccess",
                "value": "false",
                "operation": "update"
            },
        ]
    },
    {
        "distName": _NRCELL701,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "beamSet",
                "operation": "update",
                "value": [
                    dict(tiltOffset='0', basicBeamSet='beamSet_3_1', leftEdgeAngle='45', nrBtsBeamRefinementP2='false',
                         rightEdgeAngle='45'),
                ],
            },
            {
                "parameterName": "actPriorityAccess",
                "value": "false",
                "operation": "update"
            },
        ]
    },
]

PARAMETERS_TO_DELETE_NRPGRP = [
    # dict(dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsPeriodList'),
    dict(dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsCellPeriodList'),
    # dict(dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsCellList'),
]

Modify_Para_Online_AVHA_DSM = [
    dict(value='DEEPSLEEP_EXTREME_SFP', dist_name=_RMOD1, parameter='energySavingMode'),
    dict(value='true', dist_name=_NRBTSname, parameter='actCellSwitchOnForCmUpdate'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrLBRTXPowerSaving'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrLBmMimoRTXPowerSaving'),
    dict(value='true', dist_name=_NRBTSname, parameter='actLbpsCtrlLogicEnh'),
    dict(value='false', dist_name=_NRCELL700, parameter='actPriorityAccess'),
    dict(value='true', dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsLastCellSOEnabled'),
    dict(value='25', dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsLastCellRTXMinLoad'),
    dict(value='60', dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsMonWinForCellSOff'),
    dict(value='30', dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsRTXSOffTime'),
    dict(value='30', dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsRTXSOnTime'),
    dict(value='MinValueMethod', dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsSOnTrRule'),
    dict(value=[
        dict(tiltOffset='0'),
    ],
        dist_name=_NRCELL700, parameter='beamSet'),
    dict(value=[
        dict(tiltOffset='0'),
    ],
        dist_name=_NRCELL701, parameter='beamSet'),
    # dict(value='true', dist_name=_NRBTSname, parameter='actNrLBmMimoRTXPowerSaving'),
    dict(value=[
        dict(lbpsCellSOOrder='30', lbpsUseExtConfig='true', nrCellId='700'),
        dict(lbpsCellSOOrder='40', lbpsUseExtConfig='true', nrCellId='701'),
        dict(lbpsCellSOOrder='50', lbpsUseExtConfig='true', nrCellId='400')
    ],
        dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsCellList'),
    dict(value=[
        dict(lbpsDayOfWeek='Tue', lbpsDuration='60',
             lbpsStartTimeHour='8', lbpsStartTimeMinute='0', lbpsSuspended='notSuspended'),
    ],
        dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsPeriodList'),
]

ADD_Para_Online_AVHA_DSM = [
    # dict(value='true', dist_name=_NRBTSname, parameter='actNrLBmMimoRTXPowerSaving'),
    # dict(value=[
    #     dict(lbpsCellSOOrder='30', lbpsUseExtConfig='true', nrCellId='700'),
    #     dict(lbpsCellSOOrder='40', lbpsUseExtConfig='true', nrCellId='701'),
    #     dict(lbpsCellSOOrder='50', lbpsUseExtConfig='true', nrCellId='400')
    # ],
    #     dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsCellList'),
    # dict(value=[
    #     dict(lbpsDayOfWeek='Tue', lbpsDuration='60',
    #          lbpsStartTimeHour='8', lbpsStartTimeMinute='0', lbpsSuspended='notSuspended'),
    # ],
    #     dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsPeriodList'),
    dict(value=[
        dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='8', lbpsCellStartTimeMinute='0', nrCellId='700'),
        dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='8', lbpsCellStartTimeMinute='0', nrCellId='701'),
        dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='8', lbpsCellStartTimeMinute='0', nrCellId='400'),
    ],
        dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsCellPeriodList'),
]

ADD_Para_Online_AVHA_DSM_again = [
    dict(value='true', dist_name=_NRBTSname, parameter='actNrLBmMimoRTXPowerSaving'),
    dict(value=[
        dict(lbpsCellSOOrder='30', lbpsUseExtConfig='true', nrCellId='700'),
        dict(lbpsCellSOOrder='40', lbpsUseExtConfig='true', nrCellId='701'),
        dict(lbpsCellSOOrder='50', lbpsUseExtConfig='true', nrCellId='400')
    ],
        dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsCellList'),
    dict(value=[
        dict(lbpsDayOfWeek='Tue', lbpsDuration='60',
             lbpsStartTimeHour='8', lbpsStartTimeMinute='0', lbpsSuspended='notSuspended'),
    ],
        dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsPeriodList'),
    dict(value=[
        dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='8', lbpsCellStartTimeMinute='0', nrCellId='700'),
        dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='8', lbpsCellStartTimeMinute='0', nrCellId='701'),
        dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='8', lbpsCellStartTimeMinute='0', nrCellId='400'),
    ],
        dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsCellPeriodList'),
]

PARAMETERS_DSM_RECOVER_JSON_FILE = 'PARAMETERS_DSM_RECOVER_JSON_FILE.json'

PARAMETERS_DSM_RECOVER = [
    {
        "distName": _RMOD1,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "energySavingMode",
                "value": "DEEPSLEEP",
                "operation": "update"
            }
        ]
    },
    {
        "distName": _NRBTSname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actCellSwitchOnForCmUpdate",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actNrLBRTXPowerSaving",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actNrLBmMimoRTXPowerSaving",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "actLbpsCtrlLogicEnh",
                "value": "false",
                "operation": "update"
            },
        ]
    },
    {
        "distName": _NRBTSname + '/NRPGRP-0',
        "operation": "update",
        "parameters": [
            {
                "parameterName": "lbpsLastCellSOEnabled",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "lbpsLastCellRTXMinLoad",
                "operation": "delete",
                "value": "25"
            },
            {
                "parameterName": "lbpsMonWinForCellSOff",
                "operation": "delete",
                "value": "60"
            },
            {
                "parameterName": "lbpsRTXSOffTime",
                "operation": "update",
                "value": "300"
            }, {
                "parameterName": "lbpsRTXSOnTime",
                "operation": "update",
                "value": "120"
            },
            {
                "parameterName": "lbpsSOnTrRule",
                "operation": "delete",
                "value": "MinValueMethod"
            },
            {
                "parameterName": "lbpsCellList",
                "operation": "delete",
                "value": [
                    dict(lbpsCellSOOrder='30', lbpsUseExtConfig='true', nrCellId='700'),
                    dict(lbpsCellSOOrder='40', lbpsUseExtConfig='true', nrCellId='701'),
                ]
            },
            {
                "parameterName": "lbpsCellList",
                "operation": "update",
                "value": [
                    dict(lbpsCellSOOrder='100', lbpsUseExtConfig='true', nrCellId='400'),
                ]
            },
            {
                "parameterName": "lbpsPeriodList",
                "operation": "update",
                "value": [
                    dict(lbpsDayOfWeek='Mon', lbpsDuration='1',
                         lbpsStartTimeHour='1', lbpsStartTimeMinute='1', lbpsSuspended='notSuspended'),
                ]
            },
            {
                "parameterName": "lbpsCellPeriodList",
                "operation": "delete",
                "value": [
                    dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
                         lbpsCellStartTimeHour='8', lbpsCellStartTimeMinute='0', nrCellId='700'),
                    dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
                         lbpsCellStartTimeHour='8', lbpsCellStartTimeMinute='0', nrCellId='701'),
                ]
            },
            {
                "parameterName": "lbpsCellPeriodList",
                "operation": "update",
                "value": [
                    dict(lbpsCellDayOfWeek='Mon', lbpsCellDuration='1', lbpsCellSOMethod='mixed switch off',
                         lbpsCellStartTimeHour='1', lbpsCellStartTimeMinute='1', nrCellId='400'),
                ]
            },
        ]
    },
    {
        "distName": _NRCELL700,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "beamSet",
                "operation": "update",
                "value": [
                    dict(tiltOffset='-6', basicBeamSet='beamSet_3_1', leftEdgeAngle='45', nrBtsBeamRefinementP2='false',
                         rightEdgeAngle='45'),
                ],
            },
            {
                "parameterName": "actPriorityAccess",
                "value": "true",
                "operation": "update"
            },
        ]
    },
    {
        "distName": _NRCELL701,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "beamSet",
                "operation": "update",
                "value": [
                    dict(tiltOffset='-6', basicBeamSet='beamSet_3_1', leftEdgeAngle='45', nrBtsBeamRefinementP2='false',
                         rightEdgeAngle='45'),
                ],
            },
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": 'Unlocked',
            },
            {
                "parameterName": "actPriorityAccess",
                "value": "true",
                "operation": "update"
            },
        ]
    },
]

Modify_Para_Online_Recovey = [
    dict(value='DEEPSLEEP', dist_name=_RMOD1, parameter='energySavingMode'),
    dict(value='Unlocked', dist_name=_NRCELL701, parameter='administrativeState'),
]

ADD_Para_Online_AVHA_DSM_Recovey = [
    dict(value=[
        dict(lbpsCellSOOrder='30', lbpsUseExtConfig='true', nrCellId='700'),
        dict(lbpsCellSOOrder='40', lbpsUseExtConfig='true', nrCellId='701'),
        dict(lbpsCellSOOrder='50', lbpsUseExtConfig='true', nrCellId='400')
    ],
        dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsCellList'),
    dict(value=[
        dict(lbpsDayOfWeek='Tue', lbpsDuration='60',
             lbpsStartTimeHour='8', lbpsStartTimeMinute='0', lbpsSuspended='notSuspended'),
    ],
        dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsPeriodList'),
    dict(value=[
        dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='1', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='1', lbpsCellStartTimeMinute='0', nrCellId='700'),
        dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='1', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='1', lbpsCellStartTimeMinute='0', nrCellId='701'),
        dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='1', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='1', lbpsCellStartTimeMinute='0', nrCellId='400'),
    ],
        dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsCellPeriodList'),
]

ADD_Para_Online_AVHA_DSM_Recovey_again = [
    dict(value=[
        dict(lbpsCellSOOrder='30', lbpsUseExtConfig='true', nrCellId='700'),
        dict(lbpsCellSOOrder='40', lbpsUseExtConfig='true', nrCellId='701'),
        dict(lbpsCellSOOrder='50', lbpsUseExtConfig='true', nrCellId='400')
    ],
        dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsCellList'),
    dict(value=[
        dict(lbpsDayOfWeek='Tue', lbpsDuration='60',
             lbpsStartTimeHour='8', lbpsStartTimeMinute='0', lbpsSuspended='notSuspended'),
    ],
        dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsPeriodList'),
    dict(value=[
        dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='1', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='1', lbpsCellStartTimeMinute='0', nrCellId='700'),
        dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='1', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='1', lbpsCellStartTimeMinute='0', nrCellId='701'),
        dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='1', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='1', lbpsCellStartTimeMinute='0', nrCellId='400'),
    ],
        dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsCellPeriodList'),
]

Modify_Para_Online_AVHA_DSM_NRPGRP0 = [
    dict(value=[
        dict(lbpsDayOfWeek='Tue', lbpsDuration='60',
             lbpsStartTimeHour='8', lbpsStartTimeMinute='0', lbpsSuspended='notSuspended'),
        dict(lbpsDayOfWeek='Mon', lbpsDuration='345',
             lbpsStartTimeHour='0', lbpsStartTimeMinute='0', lbpsSuspended='suspended'),
        dict(lbpsDayOfWeek='Wed', lbpsDuration='345',
             lbpsStartTimeHour='0', lbpsStartTimeMinute='0', lbpsSuspended='suspended'),
        dict(lbpsDayOfWeek='Thu', lbpsDuration='345',
             lbpsStartTimeHour='0', lbpsStartTimeMinute='0', lbpsSuspended='notSuspended'),
        dict(lbpsDayOfWeek='Fri', lbpsDuration='345',
             lbpsStartTimeHour='0', lbpsStartTimeMinute='0', lbpsSuspended='notSuspended'),
        dict(lbpsDayOfWeek='Sat', lbpsDuration='345',
             lbpsStartTimeHour='0', lbpsStartTimeMinute='0', lbpsSuspended='suspended'),
        dict(lbpsDayOfWeek='Sun', lbpsDuration='345',
             lbpsStartTimeHour='0', lbpsStartTimeMinute='0', lbpsSuspended='suspended')
    ],
        dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsPeriodList'),
    dict(value=[
        dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='60', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='8', lbpsCellStartTimeMinute='0', nrCellId='301'),
        dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='60', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='8', lbpsCellStartTimeMinute='0', nrCellId='311'),
        dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='60', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='8', lbpsCellStartTimeMinute='0', nrCellId='21'),
        dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='60', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='8', lbpsCellStartTimeMinute='0', nrCellId='1'),
        dict(lbpsCellDayOfWeek='Mon', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='301'),
        dict(lbpsCellDayOfWeek='Mon', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='311'),
        dict(lbpsCellDayOfWeek='Mon', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='21'),
        dict(lbpsCellDayOfWeek='Mon', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='1'),
        dict(lbpsCellDayOfWeek='Tue', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='301'),
        dict(lbpsCellDayOfWeek='Tue', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='311'),
        dict(lbpsCellDayOfWeek='Tue', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='21'),
        dict(lbpsCellDayOfWeek='Tue', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='1'),
        dict(lbpsCellDayOfWeek='Wed', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='301'),
        dict(lbpsCellDayOfWeek='Wed', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='311'),
        dict(lbpsCellDayOfWeek='Wed', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='21'),
        dict(lbpsCellDayOfWeek='Wed', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='1'),
        dict(lbpsCellDayOfWeek='Thu', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='301'),
        dict(lbpsCellDayOfWeek='Thu', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='311'),
        dict(lbpsCellDayOfWeek='Thu', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='21'),
        dict(lbpsCellDayOfWeek='Thu', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='1'),
        dict(lbpsCellDayOfWeek='Fri', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='301'),
        dict(lbpsCellDayOfWeek='Fri', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='311'),
        dict(lbpsCellDayOfWeek='Fri', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='21'),
        dict(lbpsCellDayOfWeek='Fri', lbpsCellDuration='60', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='1'),
        dict(lbpsCellDayOfWeek='Sat', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='301'),
        dict(lbpsCellDayOfWeek='Sat', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='311'),
        dict(lbpsCellDayOfWeek='Sat', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='21'),
        dict(lbpsCellDayOfWeek='Sat', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='1'),
    ],
        dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsCellPeriodList'),
]

Modify_Para_Online_132544_17 = [
    dict(value='Locked', dist_name=_NRCELL701, parameter='administrativeState'),
    dict(value='notBarred', dist_name=_NRCELL700, parameter='cellBarred'),
    dict(value='40', dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsMaxLoad'),
    dict(value='40', dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsRTXMaxLoad'),
]

Modify_Para_Online_132544_17_1 = [
    dict(value='one', dist_name=_NRCELL701, parameter='nbrOfSsbPerRachOccasion'),
]

Modify_Para_Online_132544_17_2 = [
    dict(value='two', dist_name=_NRCELL701, parameter='nbrOfSsbPerRachOccasion'),
]

Modify_Para_Online_132544_17_3 = [
    dict(value='Unlocked', dist_name=_NRCELL701, parameter='administrativeState'),
]

Modify_Para_Online_RU_NORMAL = [
    dict(value='NORMAL', dist_name=_RMOD1, parameter='energySavingMode'),
    dict(value='NORMAL', dist_name=_RMOD2, parameter='energySavingMode'),
    dict(value='NORMAL', dist_name=_RMOD3, parameter='energySavingMode'),
]
