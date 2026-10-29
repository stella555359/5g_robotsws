temperature_counters = {
    "M40008C1": {
        "distName": "MRBTS-{}/MNL-1/MNLENT-1/PMMNL-1",
        "abbreviation": "mtSBTSRMODTemperature",
        "operation_type": "get_max",
        "sensors": [
            {
                "object_path": r"/MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/RMOD_L-1/RU_L-1",
                "sensor_type": "MODULE",
                "offset": 0
            },
        ],
    },
    "M40008C0": {
        "distName": "MRBTS-{}/MNL-1/MNLENT-1/PMMNL-1",
        "abbreviation": "mtSBTSRMODTemperature",
        "operation_type": "get_max",
        "sensors": [
            {
                "object_path": r"/MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/RMOD_L-1/RU_L-1",
                "sensor_type": "AMBIENT",
                "offset": 0
            },
        ],
    },
    "M40009C0": {
        "distName": "MRBTS-{}/MNL-1/MNLENT-1/PMMNL-1",
        "abbreviation": "mtSBTSSMODTemperature",
        "operation_type": "get_max",
        "sensors": [
            {
                "object_path": r"/MRBTS-1/EQM-1/SMOD-8209/CCU-1/TEMP_SENSOR-2",
                "offset": -12
            },
            {
                "object_path": r"/MRBTS-1/EQM-1/SMOD-8209/CCU-1/TEMP_SENSOR-3",
                "offset": -10
            },
            {
                "object_path": r"/MRBTS-1/EQM-1/SMOD-8209/CCU-1/TEMP_SENSOR-5",
                "offset": -12
            },
        ],
    },
    "M40010C0": {
        "distName": "MRBTS-{}/MNL-1/MNLENT-1/PMMNL-1",
        "abbreviation": "mtSBTSBBMODTemperature",
        "operation_type": "get_max",
        "sensors": [
            {
                "object_path": r"/MRBTS-1/EQM-1/BBMOD-34/BBU-1/TEMP_SENSOR-3",
                "offset": -15
            },
            {
                "object_path": r"/MRBTS-1/EQM-1/BBMOD-34/BBU-1/TEMP_SENSOR-5",
                "offset": -15
            },
            {
                "object_path": r"/MRBTS-1/EQM-1/BBMOD-34/BBU-1/TEMP_SENSOR-6",
                "offset": -15
            },
            {
                "object_path": r"/MRBTS-1/EQM-1/BBMOD-34/BBU-1/TEMP_SENSOR-7",
                "offset": -15
            },
            {
                "object_path": r"/MRBTS-1/EQM-1/BBMOD-34/BBU-1/TEMP_SENSOR-8",
                "offset": -15
            },
        ],
    },
    "M40005C2": {
        "distName": "MRBTS-{}/MNL-1/MNLENT-1/PMMNL-1",
        "abbreviation": "mtSBTSSfpRMOD",
        "operation_type": "get_avg",
        "sensors": [
            {
                "object_path": r"/MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/RMOD_L-1/CONNECTOR_L-1/SFP_L-1/SFP_PARAMS_L-1",
                "offset": 0
            },
        ],
    },

    "M40007C2": {
        "distName": "MRBTS-{}/MNL-1/MNLENT-1/PMMNL-1",
        "abbreviation": "mtSBTSSfpBBMOD",
        "operation_type": "get_avg",
        "sensors": [
            {
                "object_path": r"/MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/CABINET_L-1/BBMOD_L-1/"
                               + r"CONNECTOR_L-1/SFP_L-1/SFP_PARAMS_L-1",
                "offset": 0
            },
        ],
        "validate_statuses": [
            {
                "distName": "/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/"
                            + "APEQM_R-1/CABINET_R-1/BBMOD_R-1/SFP_R-1/LANE_R-1",
                "proper_statuses": {
                    "operationalState": "enabled"
                },
            },
        ],
    },
}
