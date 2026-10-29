allowed_alarms = ["4655", "4654", "61524", "61652", "61649"]
UE_ALIAS = "UE_1"
UE_ALIAS_2 = "UE_2"

GSM_BSC_IP = "10.42.28.126"
GSM_BSC_USER = "VRFUSER"
GSM_BSC_PASS = "VRFPASSWORD"

ATTACH_CELL_N25 = "MRBTS-55269/NRBTS-55269/NRCELL-21"
ATTACH_CELL_N25_2 = "MRBTS-55269/NRBTS-55269/NRCELL-41"
ATTACH_CELL_N41_301 = "MRBTS-55269/NRBTS-55269/NRCELL-301"
ATTACH_CELL_N41_311 = "MRBTS-55269/NRBTS-55269/NRCELL-311"
ATTACH_CELL_N41_321 = "MRBTS-55269/NRBTS-55269/NRCELL-321"
ATTACH_CELL_N41_302 = "MRBTS-55269/NRBTS-55269/NRCELL-302"
ATTACH_CELL_N41_312 = "MRBTS-55269/NRBTS-55269/NRCELL-312"
ATTACH_CELL_N41_322 = "MRBTS-55269/NRBTS-55269/NRCELL-322"

ATTACH_CELL_N71_21 = "MRBTS-55269/LNBTS-8814/LNCEL-21"
ATTACH_CELL_N25_11 = "MRBTS-55269/LNBTS-8814/LNCEL-11"
ATTACH_CELL_GSM_1481 = "MRBTS-55269/GNBTS-1/GNBCF-1/GNCEL-1"

ATTACH_CELL = "set_in_test"
ATTACH_CELL_ATTENUATION = 10
ATTACH_CELL_ATTENUATION_MAX = 50
AHLOA_1_PORTS = [1, 2, 3, 4]
AHFIB_1_PORTS = [17, 18, 19, 20]
AEHC_1_PORTS = [9, 10, 11, 12]
AEHC_2_PORTS = [13, 14, 15, 16]

CELL_ATTENUATION_PORTS = {
    "MRBTS-55269/NRBTS-55269/NRCELL-21": AHFIB_1_PORTS,
    "MRBTS-55269/NRBTS-55269/NRCELL-301": AEHC_1_PORTS,
    "MRBTS-55269/NRBTS-55269/NRCELL-311": AEHC_1_PORTS,
    "MRBTS-55269/NRBTS-55269/NRCELL-321": AEHC_1_PORTS,
    "MRBTS-55269/NRBTS-55269/NRCELL-302": AEHC_2_PORTS,
    "MRBTS-55269/NRBTS-55269/NRCELL-312": AEHC_2_PORTS,
    "MRBTS-55269/NRBTS-55269/NRCELL-322": AEHC_2_PORTS,
    "MRBTS-55269/LNBTS-8814/LNCEL-21": AHLOA_1_PORTS,
    "MRBTS-55269/LNBTS-8814/LNCEL-11": AHFIB_1_PORTS,
    "MRBTS-55269/GNBTS-1/GNBCF-1/GNCEL-1": AHFIB_1_PORTS

}

RSRP_THRESHOLD = 60

GRFL_SHUTDOWN_ON_DELTA = [
    {
        "distName": "MRBTS-{}/NRBTS-{}",
        "operation": "update",
        "parameters": [
            {"operation": "update", "parameterName": "actGrflShdn", "value": "true"},
            {"operation": "update", "parameterName": "shutdownWindow", "value": "60"},
            {"operation": "update", "parameterName": "shutdownStepAmount", "value": "10"},
        ],
    }
]

CELL_ADMINISTRATIVE_STATE_DELTA = [
    {
        "distName": ATTACH_CELL,
        "operation": "update",
        "parameters": [{"operation": "update", "parameterName": "administrativeState", "value": "<filled_in_test>"}],
    }
]

CELL_ENERGY_SAVING_STATE_DELTA = [
    {
        "distName": "<filled_in_test>",
        "operation": "update",
        "parameters": [{"operation": "update", "parameterName": "energySavingState", "value": ""}],
    }
]

POWER_SAVING_DELTA = [
    {
        "distName": "MRBTS-{}/NRBTS-{}",
        "operation": "update",
        "parameters": [
            {"operation": "update", "parameterName": "actNrLBPowerSaving", "value": "true"},
            {"operation": "update", "parameterName": "actLbpsCtrlLogicEnh", "value": "true"},
            {"operation": "update", "parameterName": "actNrLBmMimoRTXPowerSaving", "value": "true"},
        ],
    }
]

NRPGRP_DELTA = [
    {
        "distName": "<filled_in_test>",
        "operation": "update",
        "parameters": [
            {"operation": "update", "parameterName": "lbpsLastCellSOEnabled", "value": "false"},
            {"operation": "update", "parameterName": "lbpsMaxLoad", "value": "5"},
            {"operation": "update", "parameterName": "lbpsMinLoad", "value": "5"},
            {"operation": "update", "parameterName": "lbpsRTXMaxLoad", "value": "5"},
            {"operation": "update", "parameterName": "lbpsRTXMinLoad", "value": "5"},
            {"operation": "update", "parameterName": "lbpsRTXSOffTime", "value": "120"},
            {"operation": "update", "parameterName": "lbpsRTXSOnTime", "value": "60"},
            {"operation": "update", "parameterName": "lbpsSOMethod", "value": "cell switch off"},
            {"operation": "update", "parameterName": "lbpsSOffTrRule", "value": "SlidingAverageMethod"},
            {"operation": "update", "parameterName": "lbpsSOnTrRule", "value": "SlidingAverageMethod"},
            {"operation": "update", "parameterName": "lbpsMonWinForCellSOff", "value": "120"},
            {"operation": "update", "parameterName": "lbpsMonWinForCellSOn", "value": "120"},
        ],
    }
]

RETX_8662_DELTA = [
    {
        "distName": ATTACH_CELL,
        "operation": "update",
        "parameters": [
            {"operation": "update", "parameterName": "actAdaptiveReTxResMcs", "value": "true"},
            {"operation": "update", "parameterName": "targetPctResourceReservedMcsDl", "value": "100"},
            {"operation": "update", "parameterName": "minPctResourceReservedMcsDl", "value": "50"},
            {"operation": "update", "parameterName": "lteNrDssMode", "value": "none"},
            {"operation": "update", "parameterName": "pucchModeSelect", "value": "longPucch"},
        ],
    }
]

THROUGHPUT_DURATION_501 = "220s"
SWITCH_OFF_TIMEOUT = "360s"

CELL_SWITCH_OFF_COUNTERS = ["M55601C00501", "M55601C00502"]
TX_SWITCH_OFF_COUNTERS = ["M55601C02001", "M55601C02002"]

RESERVED_MCS_256QAM_DL_COUNTERS = ["M55300C06029", "M55300C06030", "M55300C06031"]
RESERVED_MCS_256QAM_UL_COUNTERS = ["M55302C14029", "M55302C14030", "M55302C14031"]
MCS_COUNTERS_ERROR_MARGIN = 0.05

ATTENUATOR_ALIAS = "ATTEN_1"

VOICE_CALL_DURATION = '120s'
