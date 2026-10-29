from temporary_alarms_definition import *


def _build_variable_list():
    var_dict = {}

    var_dict["MASTER_EXPECTED_ALARMS_NR_DSS"] = [
        {"alarmId": "7114", "faultId": "75[0,1][1,3,9]"}
    ]

    var_dict["MASTER_IGNORED_ALARMS_DURING_RESET_NO_CNI_127210"] = [
        {"alarmId": "7107", "faultId": "62003"},
        {"alarmId": "7114", "faultId": "7107"},
        {"alarmId": "7115", "faultId": "61[2,3][2,4,9]"},
    ]

    var_dict["MASTER_IGNORED_ALARMS_DURING_RESET_CNI_127210"] = [
        {"alarmId": "7107", "faultId": "62003"},
        {"alarmId": "7114", "faultId": "7107"},
        {"alarmId": "7115|7112", "faultId": "6129"},
        {"alarmId": "7115|7107", "faultId": "6132"},
        {"alarmId": "7115|7112", "faultId": "6134"},
    ]

    var_dict["MASTER_IGNORED_ALARMS_CNI_127210"] = [
        {"alarmId": "7222", "faultId": "9000"}
    ] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["MASTER_IGNORED_ALARMS_NO_CNI_127210"] = (
        [{"alarmId": "7222", "faultId": "9000"}]
        + SBTS_TEMP_IGNORED_ALARMS
        + ADMIN_ADDITIONAL_COMMON_IGNORED_ALARMS_NO_CNI_127210
    )

    var_dict["MASTER_CRITICAL_ALARMS"] = [] + SBTS_TEMP_CRITICAL_ALARMS

    var_dict["MASTER_ALARMS_CNI_127210"] = {
        "MASTER_IGNORED_ALARMS": "MASTER_IGNORED_ALARMS_CNI_127210",
        "MASTER_IGNORED_ALARMS_DURING_RESET": "MASTER_IGNORED_ALARMS_DURING_RESET_CNI_127210",
    }

    var_dict["MASTER_ALARMS_NO_CNI_127210"] = {
        "MASTER_IGNORED_ALARMS": "MASTER_IGNORED_ALARMS_NO_CNI_127210",
        "MASTER_IGNORED_ALARMS_DURING_RESET": "MASTER_IGNORED_ALARMS_DURING_RESET_NO_CNI_127210",
    }

    return var_dict


test_alarms_list = _build_variable_list()
