from robot.libraries.BuiltIn import BuiltIn

bts_id = BuiltIn().get_variable_value('${tl.gnbs[0].dus[0].global_bts_id}')

tc_24_preconditions_delta = [
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "nrTxPwrSlCellDetHChFrq", "value": "120", "operation": "update"},
         {"parameterName": "nrTxPwrSlCellRecPh1Tmr", "value": "130", "operation": "update"},
         {"parameterName": "nrTxPwrSlCellRecPh2Tmr", "value": "130", "operation": "update"},
         {"parameterName": "nrTxPwrSlCellRecPh3Tmr", "value": "260", "operation": "update"},
         {"parameterName": "nrTxPwrSlCellDetThr", "value": "50", "operation": "update"},
         {"parameterName": "nrTxPwrSlCellRecPhAct", "value": "Phases 1, 2 and 3", "operation": "update"},
         {"parameterName": "maxNumSlCellRecActForBbuPerDay", "value": "1", "operation": "update"},
         {"parameterName": "maxNumSlCellRecActForBtsPerDay", "value": "48", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/FEATCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "actNrAutTxPwrSlCellDetRec", "value": "false", "operation": "update"},
     ]},
]


tc_26_preconditions_delta = [
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "nrTxPwrSlCellDetHChFrq", "value": "120", "operation": "update"},
         {"parameterName": "nrTxPwrSlCellRecPh1Tmr", "value": "130", "operation": "update"},
         {"parameterName": "nrTxPwrSlCellRecPh2Tmr", "value": "160", "operation": "update"},
         {"parameterName": "nrTxPwrSlCellRecPh3Tmr", "value": "480", "operation": "update"},
         {"parameterName": "nrTxPwrSlCellDetThr", "value": "150", "operation": "update"},
         {"parameterName": "nrTxPwrSlCellRecPhAct", "value": "Phases 1, 2 and 3", "operation": "update"},
         {"parameterName": "maxNumSlCellRecActForBbuPerDay", "value": "1", "operation": "update"},
         {"parameterName": "maxNumSlCellRecActForBtsPerDay", "value": "48", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/FEATCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "actNrAutTxPwrSlCellDetRec", "value": "false", "operation": "update"},
     ]},
]

tc_27_preconditions_delta = [
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "nrTxPwrSlCellDetHChFrq", "value": "120", "operation": "update"},
         {"parameterName": "nrTxPwrSlCellRecPh1Tmr", "value": "130", "operation": "update"},
         {"parameterName": "nrTxPwrSlCellRecPh2Tmr", "value": "130", "operation": "update"},
         {"parameterName": "nrTxPwrSlCellRecPh3Tmr", "value": "130", "operation": "update"},
         {"parameterName": "nrTxPwrSlCellDetThr", "value": "150", "operation": "update"},
         {"parameterName": "nrTxPwrSlCellRecPhAct", "value": "Phases 1, 2 and 3", "operation": "update"},
         {"parameterName": "maxNumSlCellRecActForBbuPerDay", "value": "48", "operation": "update"},
         {"parameterName": "maxNumSlCellRecActForBtsPerDay", "value": "48", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/FEATCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "actNrAutTxPwrSlCellDetRec", "value": "false", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/NRBTS-{0}/NRCELL-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "ssPbchBlockPower", "value": "10", "operation": "update"},
         {"parameterName": "pMax", "value": "340", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/NRBTS-{0}/NRCELL-2".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "ssPbchBlockPower", "value": "-10", "operation": "update"},
         {"parameterName": "pMax", "value": "200", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/FMCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "actForceUnitAutoReset", "value": "true", "operation": "update"},
         {"parameterName": "actForceAutoReset", "value": "true", "operation": "update"},
     ]},
]

tc_23_preconditions_delta = [
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "nrTxPwrSlCellDetHChFrq", "value": "120", "operation": "update"},
         {"parameterName": "nrTxPwrSlCellRecPh3Tmr", "value": "130", "operation": "update"},
         {"parameterName": "nrTxPwrSlCellDetThr", "value": "150", "operation": "update"},
         {"parameterName": "nrRxPwrSlCellRecPhAct", "value": "Phase 3", "operation": "update"},
         {"parameterName": "maxNumSlCellRecActForBbuPerDay", "value": "48", "operation": "update"},
         {"parameterName": "maxNumSlCellRecActForBtsPerDay", "value": "48", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/FEATCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "actNrAutTxPwrSlCellDetRec", "value": "false", "operation": "update"},
     ]},
]

tc_25_preconditions_delta = [
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/TRBLCADM-1/SLCELLDRCONF-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "nrTxPwrSlCellDetHChFrq", "value": "120", "operation": "update"},
         {"parameterName": "nrTxPwrSlCellRecPh1Tmr", "value": "130", "operation": "update"},
         {"parameterName": "nrTxPwrSlCellRecPh3Tmr", "value": "130", "operation": "update"},
         {"parameterName": "nrTxPwrSlCellDetThr", "value": "150", "operation": "update"},
         {"parameterName": "nrTxPwrSlCellRecPhAct", "value": "Phases 1 and 3", "operation": "update"},
         {"parameterName": "maxNumSlCellRecActForBbuPerDay", "value": "48", "operation": "update"},
         {"parameterName": "maxNumSlCellRecActForBtsPerDay", "value": "48", "operation": "update"},
     ]},
    {"distName": "MRBTS-{0}/MNL-1/MNLENT-1/FEATCADM-1".format(bts_id), "operation": "update",
     "parameters": [
         {"parameterName": "actNrAutTxPwrSlCellDetRec", "value": "false", "operation": "update"},
     ]},
]
