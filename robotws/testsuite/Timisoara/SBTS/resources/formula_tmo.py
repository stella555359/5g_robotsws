# from robot.libraries.BuiltIn import BuiltIn
# tl = BuiltIn().get_variable_value("${tl}")
#
# MRBTS_ID = tl.gnbs[0].instance_id
# NRBTS_ID = tl.gnbs[0].global_bts_id
# MRBTS = "MRBTS-" + str(MRBTS_ID)
# NRBTS = "NRBTS-" + str(NRBTS_ID)

import xml.etree.ElementTree as ET
from robot.libraries.BuiltIn import BuiltIn

scf_path = BuiltIn().get_variable_value("${COMMISSIONING_PATH}")
tree = ET.parse(scf_path)
root = tree.getroot()

# definim namespace-ul (din xmlns="raml21.xsd")
ns = {"raml": "raml21.xsd"}

# =========================
# MRBTS
# =========================
mrbts = root.find('.//raml:managedObject[@class="com.nokia.srbts:MRBTS"]', ns)

if mrbts is not None:
    MRBTS = mrbts.attrib["distName"]              # ex: MRBTS-10823
    MRBTS_ID = MRBTS.split("-")[1]                # ex: 10823
else:
    MRBTS = "MRBTS-NOT_FOUND"
    MRBTS_ID = "NOT_FOUND"

# =========================
# NRBTS
# =========================
nrbts = root.find('.//raml:managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]', ns)

if nrbts is not None:
    full_dist = nrbts.attrib["distName"]          # ex: MRBTS-10823/NRBTS-43275
    NRBTS = full_dist.split("/")[-1]              # ex: NRBTS-43275
    NRBTS_ID = NRBTS.split("-")[1]                # ex: 43275
else:
    NRBTS = "NRBTS-NOT_FOUND"
    NRBTS_ID = "NOT_FOUND"

MRBTS = "MRBTS-" + str(MRBTS_ID)
NRBTS = "NRBTS-" + str(NRBTS_ID)


CHECK_COUNTER_LIST = "M40003C0,M40003C1,M40003C2,M40003C3,M40003C4,M40003C5" \
    ",M40004C0,M40004C1,M40004C2,M40004C3,M40004C4,M40004C5" \
    ",M40005C2,M40005C3,M40005C4,M40005C5,M40005C6" \
    ",M40006C2,M40006C3,M40006C4,M40006C5,M40006C6" \
    ",M40008C1" \
    ",M40009C0" \
    ",M40013C0" \
    ",M40014C0" \

SPECIFIC_COUNTER_LIST = "M40030C0,M40030C1,M40030C2"

triggeringFormula_1 = "SM_ENERGY_CONSUMPTION == SM_ENERGY_CONSUMPTION" \
    " AND SM_MIN_PWR_USAGE <= SM_MAX_PWR_USAGE" \
    " OR SM_MIN_PWR_USAGE <= SM_AVG_PWR_USAGE" \
    " AND SM_MAX_PWR_USAGE >= SM_AVG_PWR_USAGE" \
    " OR MAX_INPUT_VOLTAGE_IN_SM >= MIN_INPUT_VOLTAGE_IN_SM"

triggeringFormula_2 = "SBTS_SM_MAX_TEMPERATURE == SBTS_SM_MAX_TEMPERATURE"

triggeringFormula_3 = "SBTS_SFPSM_TEMPERATURE_MIN <= SBTS_SFPSM_TEMPERATURE_MAX" \
    " AND SBTS_SFP_SM_AVG_TEMPERATURE >= SBTS_SFPSM_TEMPERATURE_MIN" \
    " OR SBTS_SFPSM_TEMPERATURE_MAX >= SBTS_SFP_SM_AVG_TEMPERATURE" \
    " AND SBTS_SFPSM_LANE_DURATION == SBTS_SFPSM_LANE_DURATION"

triggeringFormula_4 = "SBTS_SFP_SM_AVG_TEMPERATURE == SBTS_SFP_SM_AVG_TEMPERATURE" \
    " AND SBTS_SM_MAX_TEMPERATURE == SBTS_SM_MAX_TEMPERATURE"

triggeringFormula_5 = "SBTS_RM_MAX_TEMPERATURE == SBTS_RM_MAX_TEMPERATURE" \
    " AND SBTS_SFPRM_TEMPERATURE_MIN <= SBTS_SFPRM_TEMPERATURE_MAX"

triggeringFormula_6 = "MIN_INPUT_VOLTAGE_IN_RF <= MAX_INPUT_VOLTAGE_IN_RF" \
    " OR RU_ENERGY_CONSUMPTION == RU_ENERGY_CONSUMPTION" \
    " AND RU_MAX_PWR_USAGE >= RU_MIN_PWR_USAGE" \
    " OR RU_AVG_PWR_USAGE >= RU_MIN_PWR_USAGE" \
    " AND RU_MAX_PWR_USAGE >= RU_AVG_PWR_USAGE"

triggeringFormula_7 = "SBTS_SFPRM_DURATION == SBTS_SFPRM_DURATION" \
    " AND SBTS_SFPRM_LANE_DURATION == SBTS_SFPRM_LANE_DURATION"

triggeringFormula_8 = "SBTS_RMOD_MIN_FANSPEED <= SBTS_RMOD_MAX_FANSPEED" \
    " AND SBTS_RMOD_AVG_FANSPEED <= SBTS_RMOD_MAX_FANSPEED" \
    " AND SBTS_RMOD_AVG_FANSPEED >= SBTS_RMOD_MIN_FANSPEED" \
    " AND RU_MAX_PWR_USAGE >= RU_MIN_PWR_USAGE" \
    " OR RU_AVG_PWR_USAGE >= RU_MIN_PWR_USAGE" \
    " AND RU_MAX_PWR_USAGE >= RU_AVG_PWR_USAGE"

ALL_TRIGGERINGFORMULA_PARAMETER_LIST_SMOD = [
    {
        "fault_list": [4585, 4586],
        "counter_ids": "M40004C0,M40004C1,M40004C2,M40004C3,M40004C4,M40004C5,M40009C0",
        "triggering_formula": [
            {
                "distName": MRBTS + "/MNL-1/MNLENT-1/TRBLCADM-1",
                "operation": "update",
                "parameters": [
                    {
                        "parameterName": "kpiAlarmTriggers",
                        "value": [
                            {"faultID": "4585", "formulaDescription": "triggeringFormula_1",
                                "timeToTrigger": 0, "triggeringFormula": triggeringFormula_1},
                            {"faultID": "4586", "formulaDescription": "triggeringFormula_2",
                                "timeToTrigger": 0, "triggeringFormula": triggeringFormula_2},
                        ],
                        "operation": "update",
                    }
                ]
            }
        ]
    }, {
        "fault_list": [4587],
        "counter_ids": "M40006C2,M40006C3,M40006C4,M40006C5,M40006C6,M40014C0",
        "triggering_formula": [
            {
                "distName": MRBTS + "/MNL-1/MNLENT-1/TRBLCADM-1",
                "operation": "update",
                "parameters": [
                    {
                        "parameterName": "kpiAlarmTriggers",
                        "value": [
                            {"faultID": "4587", "formulaDescription": "triggeringFormula_3",
                                "timeToTrigger": 0, "triggeringFormula": triggeringFormula_3},
                        ],
                        "operation": "update",
                    }
                ]
            }
        ]
    }, {
        "fault_list": [4588],
        "counter_ids": "M40006C2,M40009C0",
        "triggering_formula": [
            {
                "distName": MRBTS + "/MNL-1/MNLENT-1/TRBLCADM-1",
                "operation": "update",
                "parameters": [
                    {
                        "parameterName": "kpiAlarmTriggers",
                        "value": [
                            {"faultID": "4588", "formulaDescription": "triggeringFormula_4",
                                "timeToTrigger": 0, "triggeringFormula": triggeringFormula_4},
                        ],
                        "operation": "update",
                    }
                ]
            }
        ]
    }
]

ALL_TRIGGERINGFORMULA_PARAMETER_LIST_RMOD = [
    {
        "fault_list": [4573],
        "counter_ids": "M40008C1,M40005C2,M40005C3,M40005C4,M40005C5,M40005C6",
        "triggering_formula": [
            {
                "distName": MRBTS + "/MNL-1/MNLENT-1/TRBLCADM-1",
                "operation": "update",
                "parameters": [
                    {
                        "parameterName": "kpiAlarmTriggers",
                        "value": [
                            {"faultID": "4573", "formulaDescription": "triggeringFormula_5",
                                "timeToTrigger": 0, "triggeringFormula": triggeringFormula_5},
                        ],
                        "operation": "update",
                    }
                ]
            }
        ]
    }, {
        "fault_list": [4574],
        "counter_ids": "M40003C0,M40003C1,M40003C2,M40003C3,M40003C4,M40003C5",
        "triggering_formula": [
            {
                "distName": MRBTS + "/MNL-1/MNLENT-1/TRBLCADM-1",
                "operation": "update",
                "parameters": [
                    {
                        "parameterName": "kpiAlarmTriggers",
                        "value": [
                            {"faultID": "4574", "formulaDescription": "triggeringFormula_6",
                                "timeToTrigger": 0, "triggeringFormula": triggeringFormula_6},
                        ],
                        "operation": "update",
                    }
                ]
            }
        ]
    }, {
        "fault_list": [4575],
        "counter_ids": "M40005C3,M40013C0",
        "triggering_formula": [
            {
                "distName": MRBTS + "/MNL-1/MNLENT-1/TRBLCADM-1",
                "operation": "update",
                "parameters": [
                    {
                        "parameterName": "kpiAlarmTriggers",
                        "value": [
                            {"faultID": "4575", "formulaDescription": "triggeringFormula_7",
                                "timeToTrigger": 0, "triggeringFormula": triggeringFormula_7},
                        ],
                        "operation": "update",
                    }
                ]
            }
        ]
    }, {
        "fault_list": [4576],
        "counter_ids": "M40003C3,M40003C4,M40003C5,M40030C0,M40030C1,M40030C2",
        "triggering_formula": [
            {
                "distName": MRBTS + "/MNL-1/MNLENT-1/TRBLCADM-1",
                "operation": "update",
                "parameters": [
                    {
                        "parameterName": "kpiAlarmTriggers",
                        "value": [
                            {"faultID": "4576", "formulaDescription": "triggeringFormula_8",
                                "timeToTrigger": 0, "triggeringFormula": triggeringFormula_8},
                        ],
                        "operation": "update",
                    }
                ]
            }
        ]
    }
]
