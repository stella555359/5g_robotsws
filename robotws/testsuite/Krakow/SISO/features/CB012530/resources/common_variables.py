import os

ADDITIONAL_ALARMS_FOR_TESTS = {
    'Ru_runtime_chain': ['No connection to unit', 'Setup of X2 connectivity to gNB failed'],
    'Ru_reset_user': ['No connection to unit', 'Setup of X2 connectivity to gNB failed',
                      'Receiving failure in Optical Interface', 'Incompatible SW version detected'],
}

RU_Runtime_vars = {
    "configObjectName": "MRBTS-76003/EQM-1/APEQM-1/ASIRMOD-2",
    "faultId": 10,
    "fault_name": "No connection to unit",
    "supplAlarmInfo": "RU connection was lost in runtime"
}

RU_Reset_User = {
    "configObjectName": "MRBTS-76003/EQM-1/APEQM-1/ASIRMOD-3",  # NH225300609
    "faultId": 10,
    "fault_name": "No connection to unit",
    "supplAlarmInfo": "RU not detected after reset. The suspected failure reason(s): Reset reason: user request. "
                      "None of the DU ports for connecting to the RU have available connections. "
                      "SFP type is SFP_SFP_PLUS_SFP28_AND_LATER, Protocol is eCPRI."
}

Asir_Commisioning = {
    "configObjectName": "MRBTS-76003/EQM-1/APEQM-1/ASIRMOD-3",  # NH225300609
    "faultId": 10,
    "fault_name": "No connection to unit",
    "supplAlarmInfo": "RU not detected after reset. The suspected failure reason(s): Reset reason: commissioning "
                      "change. None of the DU ports for connecting to the RU have available connections. "
                      "SFP type is SFP_SFP_PLUS_SFP28_AND_LATER, Protocol is eCPRI."
}

Software_update = {
    "configObjectName": "MRBTS-76003/EQM-1/APEQM-1/ASIRMOD-3",  # NH225300609
    "faultId": 10,
    "fault_name": "No connection to unit",
    "supplAlarmInfo": "RU not detected after reset. The suspected failure reason(s): Reset reason: software update. "
                      "None of the DU ports for connecting to the RU have available connections. "
                      "SFP type is SFP_SFP_PLUS_SFP28_AND_LATER, Protocol is eCPRI."
}

statuses_after_asir_commisioning = {
    'softwareState': 'notDetected'
}

dir_ute = "/home/ute/testline_configuration"
if os.path.isdir(dir_ute):
    path_testline_configuration = "/home/ute"
else:
    path_testline_configuration = "/home/ute/auto"
