from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

MRBTS_ID = tl.gnbs[0].instance_id
NRBTS_ID = tl.gnbs[0].global_bts_id
MRBTS = "MRBTS-" + str(MRBTS_ID)
NRBTS = "NRBTS-" + str(NRBTS_ID)


Error_triggeringFormula_1 = "1 == 1"
Error_triggeringFormula_2 = "MIN_INPUT_VOLTAGE_IN_RF == SM_ENERGY_CONSUMPTION"
Error_triggeringFormula_3 = "VSWR_AVG = 1"
Error_triggeringFormula_4 = "SBTS_CAB_AVG_TEMPERATURE == SBTS_SM_MAX_TEMPERATURE OR 1 == 1"
Error_triggeringFormula_5 = "SBTS_CAB_AVG_TEMPERATURE == SBTS_BM_MAX_TEMPERATURE OR 1 == 1"
Error_triggeringFormula_6 = "SBTS_CAB_AVG_TEMPERATURE == SBTS_RM_MAX_TEMPERATURE OR 1 == 1"
Error_triggeringFormula_7 = "SBTS_SM_MAX_TEMPERATURE == SBTS_BM_MAX_TEMPERATURE OR 1 == 1"
Error_triggeringFormula_8 = "SBTS_SM_MAX_TEMPERATURE == X2_SHUTDOWN_NO_TRAFFIC OR 1 == 1"
Error_triggeringFormula_9 = "SBTS_SM_MAX_TEMPERATURE ==  SAMPLES_CELL_AVAIL OR 1 == 1"
Error_triggeringFormula_10 = "RU_EthIfInFrames == SAMPLES_CELL_AVAIL OR 1 == 1"

ALL_ERROR_TRIGGERINGFORMULA_LIST = [
    Error_triggeringFormula_1,
    Error_triggeringFormula_2,
    Error_triggeringFormula_3,
    Error_triggeringFormula_4,
    Error_triggeringFormula_5,
    Error_triggeringFormula_6,
    Error_triggeringFormula_7,
    Error_triggeringFormula_8,
    Error_triggeringFormula_9,
    Error_triggeringFormula_10,
]

ALL_ERROR_TRIGGERING_FORMULA_PARAMETER = [
    {
        "distName": MRBTS + "/MNL-1/MNLENT-1/TRBLCADM-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "kpiAlarmTriggers",
                "value": [
                    {"faultID": "4569", "formulaDescription": "Error_triggeringFormula_1",
                        "timeToTrigger": 0, "triggeringFormula": Error_triggeringFormula_1},
                    {"faultID": "4570", "formulaDescription": "Error_triggeringFormula_2",
                        "timeToTrigger": 0, "triggeringFormula": Error_triggeringFormula_2},
                    {"faultID": "4571", "formulaDescription": "Error_triggeringFormula_3",
                        "timeToTrigger": 0, "triggeringFormula": Error_triggeringFormula_3},
                    {"faultID": "4572", "formulaDescription": "Error_triggeringFormula_4",
                        "timeToTrigger": 0, "triggeringFormula": Error_triggeringFormula_4},
                    {"faultID": "4573", "formulaDescription": "Error_triggeringFormula_5",
                        "timeToTrigger": 0, "triggeringFormula": Error_triggeringFormula_5},
                    {"faultID": "4574", "formulaDescription": "Error_triggeringFormula_6",
                        "timeToTrigger": 0, "triggeringFormula": Error_triggeringFormula_6},
                    {"faultID": "4575", "formulaDescription": "Error_triggeringFormula_7",
                        "timeToTrigger": 0, "triggeringFormula": Error_triggeringFormula_7},
                    {"faultID": "4576", "formulaDescription": "Error_triggeringFormula_8",
                        "timeToTrigger": 0, "triggeringFormula": Error_triggeringFormula_8},
                    {"faultID": "4577", "formulaDescription": "Error_triggeringFormula_9",
                        "timeToTrigger": 0, "triggeringFormula": Error_triggeringFormula_9},
                    {"faultID": "4578", "formulaDescription": "Error_triggeringFormula_10",
                        "timeToTrigger": 0, "triggeringFormula": Error_triggeringFormula_10},
                ],
                "operation": "update",
            }
        ]
    }
]
