temperature_counters = {
    # SBTS BM MAX TEMPERATURE COUNTER mtSBTSBBMODTemperature
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
                "offset": -11
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
                "offset": -11
            },
        ],
    },
    # SBTS SFP BB AVG TEMPERATURE counter mtSBTSSfpBBMOD
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
