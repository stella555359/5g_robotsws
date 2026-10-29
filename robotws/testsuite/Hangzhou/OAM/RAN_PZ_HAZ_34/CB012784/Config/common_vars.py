from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

MRBTS_ID = tl.gnbs[0].instance_id
NRBTS_ID = tl.gnbs[0].global_bts_id
MRBTS = "MRBTS-" + str(MRBTS_ID)
NRBTS = "NRBTS-" + str(NRBTS_ID)

ENABLE_FEATURE_FLAG = [
    {
        "distName": MRBTS + "/MNL-1/MNLENT-1/FEATCADM-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actKpiAlarms",
                "value": "true",
                "operation": "update",
            }
        ]
    }
]

DISABLE_FEATURE_FLAG = [
    {
        "distName": MRBTS + "/MNL-1/MNLENT-1/FEATCADM-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actKpiAlarms",
                "value": "false",
                "operation": "update",
            }
        ]
    }
]

REMOVE_TRIGGERING_FORMULA = [
    {
        "distName": MRBTS + "/MNL-1/MNLENT-1/TRBLCADM-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "kpiAlarmTriggers",
                "value": [],
                "operation": "update",
            }
        ]
    }
]

PM_ENABLE_PARAMETER = [
    {
        "distName": MRBTS + "/MNL-1/MNLENT-1/PMMNL-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "mtSBTSAntennaLine",
                "value": "15min",
                "operation": "update",
            },
            {
                "parameterName": "mtSBTSRfmEnergyMonitoring",
                "value": "5min",
                "operation": "update",
            },
            {
                "parameterName": "mtSBTSSmEnergyMonitoring",
                "value": "5min",
                "operation": "update",
            },
            {
                "parameterName": "mtSBTSSfpRMOD",
                "value": "5min",
                "operation": "update",
            },
            {
                "parameterName": "mtSBTSSfpSMOD",
                "value": "5min",
                "operation": "update",
            },
            {
                "parameterName": "mtSBTSSfpBBMOD",
                "value": "5min",
                "operation": "update",
            },
            {
                "parameterName": "mtSBTSRMODTemperature",
                "value": "5min",
                "operation": "update",
            },
            {
                "parameterName": "mtSBTSSMODTemperature",
                "value": "5min",
                "operation": "update",
            },
            {
                "parameterName": "mtSBTSBBMODTemperature",
                "value": "5min",
                "operation": "update",
            },
            {
                "parameterName": "mtSbtsSfpRmodLane",
                "value": "5min",
                "operation": "update",
            },
            {
                "parameterName": "mtSbtsSfpSmodLane",
                "value": "5min",
                "operation": "update",
            },
            {
                "parameterName": "mtSbtsSfpBbmodLane",
                "value": "5min",
                "operation": "update",
            },
            {
                "parameterName": "mtSBTSCabiTempMonitoring",
                "value": "5min",
                "operation": "update",
            },
            {
                "parameterName": "mtSBTSBBCAPEnergyMonitoring",
                "value": "5min",
                "operation": "update",
            },
            {
                "parameterName": "mtSBTSRMODFan",
                "value": "5min",
                "operation": "update",
            },
            {
                "parameterName": "mtSBTSCabiFan",
                "value": "5min",
                "operation": "update",
            },
        ]
    },
    {
        "distName": MRBTS + "/MNL-1/MNLENT-1/FEATCADM-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actCpriLinkRecovery",
                "value": "true",
                "operation": "update",
            },
            {
                "parameterName": "actPowerMeter",
                "value": "true",
                "operation": "update",
            }
        ]
    },
]
