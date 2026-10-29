from temporary_alarms_definition import *


def _build_variable_list():
    var_dict = {}

    var_dict["MASTER_EXPECTED_ALARMS_7300"] = [{"alarmId": "7107", "faultId": "7300"}]

    var_dict["MASTER_EXPECTED_ALARMS_7319"] = [{"alarmId": "7107", "faultId": "7319"}]

    var_dict["MASTER_IGNORED_ALARMS_NO_CNI_127210"] = (
        [{"alarmId": "7222", "faultId": "9000"}]
        + SBTS_TEMP_IGNORED_ALARMS
        + ADMIN_ADDITIONAL_COMMON_IGNORED_ALARMS_NO_CNI_127210
    )

    var_dict["MASTER_IGNORED_ALARMS_CNI_127210"] = [
        {"alarmId": "7222", "faultId": "9000"}
    ] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["MASTER_EXPECTED_ALARMS_10_1815"] = [
        {"alarmId": "7116", "faultId": "10|1815"}
    ]

    var_dict["SLAVE_IGNORED_ALARMS_DSS_NO_CNI_127210"] = [
        {"alarmId": "7115", "faultId": "61[2,3][2,4,9]"}
    ]

    var_dict["SLAVE_IGNORED_ALARMS_DSS_CNI_127210"] = [
        {"alarmId": "7115|7112", "faultId": "6129"},
        {"alarmId": "7115|7107", "faultId": "6132"},
        {"alarmId": "7115|7112", "faultId": "6134"},
    ]

    var_dict["SLAVE_EXPECTED_ALARMS_16"] = [{"alarmId": "7116", "faultId": "16"}]

    var_dict["SLAVE_EXPECTED_ALARMS_10_1815"] = [
        {"alarmId": "7116", "faultId": "(10|1815)"}
    ]

    var_dict["SLAVE_IGNORED_ALARMS_NO_CNI_127210"] = (
        [{"alarmId": "7222", "faultId": "9000"}]
        + SBTS_TEMP_IGNORED_ALARMS
        + ADMIN_ADDITIONAL_COMMON_IGNORED_ALARMS_NO_CNI_127210
    )

    var_dict["SLAVE_IGNORED_ALARMS_CNI_127210"] = [
        {"alarmId": "7222", "faultId": "9000"}
    ] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["MASTER_CRITICAL_ALARMS"] = [
        {"alarmId": "7101", "faultId": "52"},
        {"alarmId": "7101", "faultId": "4590"},
        {"alarmId": "7101", "faultId": "4341"},
        {"alarmId": "7101", "faultId": "6709"},
        {"alarmId": "7101", "faultId": "1806"},
    ] + SBTS_TEMP_CRITICAL_ALARMS

    var_dict["SLAVE_CRITICAL_ALARMS"] = [
        {"alarmId": "7101", "faultId": "52"},
        {"alarmId": "7101", "faultId": "4590"},
        {"alarmId": "7101", "faultId": "4341"},
        {"alarmId": "7101", "faultId": "6709"},
        {"alarmId": "7101", "faultId": "1806"},
    ] + SBTS_TEMP_CRITICAL_ALARMS

    var_dict["MASTER_ALARMS_CNI_127210"] = {
        "MASTER_IGNORED_ALARMS": "MASTER_IGNORED_ALARMS_CNI_127210"
    }

    var_dict["MASTER_ALARMS_NO_CNI_127210"] = {
        "MASTER_IGNORED_ALARMS": "MASTER_IGNORED_ALARMS_NO_CNI_127210"
    }

    var_dict["SLAVE_ALARMS_CNI_127210"] = {
        "SLAVE_IGNORED_ALARMS": "SLAVE_IGNORED_ALARMS_CNI_127210",
        "SLAVE_IGNORED_ALARMS_DSS": "SLAVE_IGNORED_ALARMS_DSS_CNI_127210",
    }

    var_dict["SLAVE_ALARMS_NO_CNI_127210"] = {
        "SLAVE_IGNORED_ALARMS": "SLAVE_IGNORED_ALARMS_NO_CNI_127210",
        "SLAVE_IGNORED_ALARMS_DSS": "SLAVE_IGNORED_ALARMS_DSS_NO_CNI_127210",
    }

    return var_dict


test_alarms_list = _build_variable_list()
