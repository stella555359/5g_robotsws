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
