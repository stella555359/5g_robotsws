
MRBTS_NRBTS = 'MRBTS-{}/NRBTS-{}'
MRBTS_NRBTS_NRCELL11_NRHOIF = f'{MRBTS_NRBTS}/NRCELL-11/NRHOIF-1'
MRBTS_NRBTS_NRCELL20 = f'{MRBTS_NRBTS}/NRCELL-20'
MRBTS_NRBTS_PSCELL = f'{MRBTS_NRBTS}/NRCELL-60'
MRBTS_NRBTS_SCELL1 = f'{MRBTS_NRBTS}/NRCELL-61'
MRBTS_NRBTS_SCELL2 = f'{MRBTS_NRBTS}/NRCELL-62'
MRBTS_NRBTS_SCELL3 = f'{MRBTS_NRBTS}/NRCELL-63'
MRBTS_NRBTS_SCELL4 = f'{MRBTS_NRBTS}/NRCELL-64'
MRBTS_NRBTS_SCELL5 = f'{MRBTS_NRBTS}/NRCELL-65'
MRBTS_NRBTS_SCELL6 = f'{MRBTS_NRBTS}/NRCELL-66'
MRBTS_NRBTS_SCELL7 = f'{MRBTS_NRBTS}/NRCELL-67'
NRCELLS = [MRBTS_NRBTS_PSCELL, MRBTS_NRBTS_SCELL1, MRBTS_NRBTS_SCELL2, MRBTS_NRBTS_SCELL3,
           MRBTS_NRBTS_SCELL4, MRBTS_NRBTS_SCELL5, MRBTS_NRBTS_SCELL6, MRBTS_NRBTS_SCELL7]
SN_MRBTS_NRBTS_NRCELLGRP = f'{MRBTS_NRBTS}/NRCELLGRP-60'

DISABLE_UE_BEAM_FAILURE_RECOVERY_FALSE_PARAM = [{"parameterName": "disableUeBeamFailureRecovery",
                                                 "value": "false",
                                                 "operation": "update"}]

DISABLE_UE_BEAM_FAILURE_RECOVERY_TRUE_PARAM = [{"parameterName": "disableUeBeamFailureRecovery",
                                                "value": "true",
                                                "operation": "update"}]

DISABLE_UE_BEAM_FAILURE_RECOVERY_DEL_PARAM = [{"parameterName": "disableUeBeamFailureRecovery",
                                               "value": "",
                                               "operation": "delete"}]
DISABLE_UE_BEAM_FAILURE_RECOVERY_FALSE = [
    {"distName": cell,
     "operation": "update",
     "parameters": DISABLE_UE_BEAM_FAILURE_RECOVERY_FALSE_PARAM} for cell in NRCELLS
]

DISABLE_UE_BEAM_FAILURE_RECOVERY_TRUE = [
    {"distName": cell,
     "operation": "update",
     "parameters": DISABLE_UE_BEAM_FAILURE_RECOVERY_TRUE_PARAM} for cell in NRCELLS
]

DISABLE_UE_BEAM_FAILURE_RECOVERY_DEL = [
    {"distName": cell,
     "operation": "update",
     "parameters": DISABLE_UE_BEAM_FAILURE_RECOVERY_DEL_PARAM} for cell in NRCELLS
]

ACT_RRC_RECONFIG_AT_BEAM_SWITCH_TRUE_PARAM = [{"parameterName": "actRrcReconfigAtBeamSwitch",
                                               "value": "true",
                                               "operation": "update"}]

ACT_RRC_RECONFIG_AT_BEAM_SWITCH_FALSE_PARAM = [{"parameterName": "actRrcReconfigAtBeamSwitch",
                                                "value": "false",
                                                "operation": "update"}]

ACT_RRC_RECONFIG_AT_BEAM_SWITCH_TRUE = [
    {"distName": cell,
     "operation": "update",
     "parameters": ACT_RRC_RECONFIG_AT_BEAM_SWITCH_TRUE_PARAM} for cell in NRCELLS
]

ACT_RRC_RECONFIG_AT_BEAM_SWITCH_FALSE = [
    {"distName": cell,
     "operation": "update",
     "parameters": ACT_RRC_RECONFIG_AT_BEAM_SWITCH_FALSE_PARAM} for cell in NRCELLS
]

LD_201_PRECONDITIONS = [
    {"distName": SN_MRBTS_NRBTS_NRCELLGRP,
     "operation": "update",
     "parameters": [{"parameterName": "actHighNumberOfUEs",
                     "value": "true",
                     "operation": "update"},
                    {"parameterName": "pucchF2MaxCodeRate",
                     "value": "zeroDot35",
                     "operation": "update"}]
     }
]
LD_201_ROLLBACK = [
    {"distName": SN_MRBTS_NRBTS_NRCELLGRP,
     "operation": "update",
     "parameters": [{"parameterName": "actHighNumberOfUEs",
                     "value": "false",
                     "operation": "update"},
                    {"parameterName": "pucchF2MaxCodeRate",
                     "value": "zeroDot25",
                     "operation": "update"}]
     }
]
DD_200_INACTIVITY_TIMERS_MN = [
    {"distName": MRBTS_NRBTS,
     "operation": "update",
     "parameters": [{"parameterName": "srbInactivityTimerSA",
                     "value": "150",
                     "operation": "update"},
                    {"parameterName": "drbInactivityTimerSA",
                     "value": "10",
                     "operation": "update"}
                    ]
     }
]
DD_200_INACTIVITY_TIMERS_SN = [
    {"distName": MRBTS_NRBTS,
     "operation": "update",
     "parameters": [{"parameterName": "srbInactivityTimerSA",
                     "value": "300",
                     "operation": "update"},
                    {"parameterName": "drbInactivityTimerSA",
                     "value": "30",
                     "operation": "update"}
                    ]
     }
]
DEFAULT_INACTIVITY_TIMERS_MN = [
    {"distName": MRBTS_NRBTS,
     "operation": "update",
     "parameters": [{"parameterName": "srbInactivityTimerSA",
                     "value": "60",
                     "operation": "update"},
                    {"parameterName": "drbInactivityTimerSA",
                     "value": "60",
                     "operation": "update"}
                    ]
     }
]
DEFAULT_INACTIVITY_TIMERS_SN = [
    {"distName": MRBTS_NRBTS,
     "operation": "update",
     "parameters": [{"parameterName": "srbInactivityTimerSA",
                     "value": "60",
                     "operation": "update"},
                    {"parameterName": "drbInactivityTimerSA",
                     "value": "60",
                     "operation": "update"}
                    ]
     }
]
DD_200_FR2_CELL_LOW_POWER = [
    {"distName": MRBTS_NRBTS_PSCELL,
     "operation": "update",
     "parameters": [{"parameterName": "ssPbchBlockPower",
                     "value": "-27",
                     "operation": "update"}
                    ]
     }
]
DD_200_FR2_CELL_NORMAL_POWER = [
    {"distName": MRBTS_NRBTS_PSCELL,
     "operation": "update",
     "parameters": [{"parameterName": "ssPbchBlockPower",
                     "value": "-11",
                     "operation": "update"}
                    ]
     }
]
DD_200_NRHOIF_A4_THRESHOLD = [
    {"distName": MRBTS_NRBTS_NRCELL11_NRHOIF,
     "operation": "update",
     "parameters": [{"parameterName": "a4MeasNrDcSsbRsrp",
                     "value": [{"a4HysteresisNrDcSsbRsrp": "0",
                                "a4ThresholdNrDcSsbRsrp": "96",
                                "a4TimeToTriggerNrDcSsbRsrp": "ms100"}],
                     "operation": "update"}
                    ]
     }
]
DEFAULT_NRHOIF_A4_THRESHOLD = [
    {"distName": MRBTS_NRBTS_NRCELL11_NRHOIF,
     "operation": "update",
     "parameters": [{"parameterName": "a4MeasNrDcSsbRsrp",
                     "value": [{"a4HysteresisNrDcSsbRsrp": "0",
                                "a4ThresholdNrDcSsbRsrp": "43",
                                "a4TimeToTriggerNrDcSsbRsrp": "ms100"}],
                     "operation": "update"}
                    ]
     }
]
MN_DD_200_ROLLBACK = DEFAULT_NRHOIF_A4_THRESHOLD + DEFAULT_INACTIVITY_TIMERS_MN
SN_DD_200_ROLLBACK = DD_200_FR2_CELL_NORMAL_POWER + DEFAULT_INACTIVITY_TIMERS_SN
