from temporary_alarms_definition import *


def _build_variable_list():
    var_dict = {}

    var_dict["MASTER_CU_EXPECTED_ALARMS"] = []

    var_dict["MASTER_CU_IGNORED_ALARMS"] = [] + CBTS_CU_TEMP_IGNORED_ALARMS

    var_dict["MASTER_CU_CRITICAL_ALARMS"] = [] + CBTS_CU_TEMP_CRITICAL_ALARMS

    var_dict["MASTER_VDU1_EXPECTED_ALARMS_4220"] = [
        {"alarm_id": "7116", "fault_id": "4220"}
    ]

    var_dict["MASTER_VDU1_IGNORED_ALARMS_SYNC"] = [
        {"alarm_id": "7108", "fault_id": "1898"}
    ]

    var_dict["MASTER_VDU1_IGNORED_ALARMS"] = [] + CBTS_VDU_TEMP_IGNORED_ALARMS

    var_dict["MASTER_VDU1_CRITICAL_ALARMS"] = [] + CBTS_VDU_TEMP_CRITICAL_ALARMS

    var_dict["SLAVE_EXPECTED_ALARMS_4220"] = [{"alarmId": "7116", "faultId": "4220"}]

    var_dict["SLAVE_IGNORED_ALARMS_X2"] = [
        {"alarmId": "7114", "faultId": "7107"},
        {"alarmId": "7107", "faultId": "7300"},
        {"alarmId": "7107", "faultId": "7308"},
        {"alarmId": "7107", "faultId": "7319"},
        {"alarmId": "7107", "faultId": "6327"},
    ]

    var_dict["SLAVE_IGNORED_ALARMS_SYNC_NO_CNI_127210"] = [
        {"alarmId": "7115", "faultId": "4405"},
        {"alarmId": "7108", "faultId": "4153"},
        {"alarmId": "7101", "faultId": "4452"},
        {"alarmId": "7108", "faultId": "4452"},
        {"alarmId": "7114", "faultId": "4452"},
    ]

    var_dict["SLAVE_IGNORED_ALARMS_SYNC_CNI_127210"] = [
        {"alarmId": "7108", "faultId": "4153"},
        {"alarmId": "7108", "faultId": "4452"},
        {"alarmId": "7114", "faultId": "4452"},
        {"alarmId": "7115", "faultId": "4405"},
    ]

    var_dict["SLAVE_IGNORED_ALARMS_NO_CNI_127210"] = (
        [{"alarmId": "7222", "faultId": "9000"}]
        + SBTS_TEMP_IGNORED_ALARMS
        + ADMIN_ADDITIONAL_COMMON_IGNORED_ALARMS_NO_CNI_127210
    )

    var_dict["SLAVE_IGNORED_ALARMS_CNI_127210"] = [
        {"alarmId": "7222", "faultId": "9000"}
    ] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["SLAVE_CRITICAL_ALARMS"] = [] + SBTS_TEMP_CRITICAL_ALARMS

    var_dict["SLAVE_ALARMS_CNI_127210"] = {
        "SLAVE_IGNORED_ALARMS": "SLAVE_IGNORED_ALARMS_CNI_127210",
        "SLAVE_IGNORED_ALARMS_SYNC": "SLAVE_IGNORED_ALARMS_SYNC_CNI_127210",
    }

    var_dict["SLAVE_ALARMS_NO_CNI_127210"] = {
        "SLAVE_IGNORED_ALARMS": "SLAVE_IGNORED_ALARMS_NO_CNI_127210",
        "SLAVE_IGNORED_ALARMS_SYNC": "SLAVE_IGNORED_ALARMS_SYNC_NO_CNI_127210",
    }

    return var_dict


test_alarms_list = _build_variable_list()
