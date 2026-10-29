from temporary_alarms_definition import *


def _build_variable_list():
    var_dict = {}

    var_dict["DSS_IGNORED_ALARMS_CNI_127210"] = [
        {"alarmId": "7114", "faultId": "75[0,1][1,3,9]"},
        {"alarmId": "7115|7112", "faultId": "6129"},
        {"alarmId": "7115|7107", "faultId": "6132"},
        {"alarmId": "7115|7112", "faultId": "6134"},
    ]

    var_dict["DSS_IGNORED_ALARMS_NO_CNI_127210"] = [
        {"alarmId": "7114", "faultId": "75[0,1][1,3,9]"},
        {"alarmId": "7115", "faultId": "61[2,3][2,4,9]"},
    ]

    var_dict["MASTER_EXPECTED_ALARMS_10_1815_4773"] = [
        {"alarmId": "7116", "faultId": "10|1815|4773"}
    ]

    var_dict["MASTER_EXPECTED_ALARMS_16"] = [{"alarmId": "7116", "faultId": "16"}]

    var_dict["MASTER_EXPECTED_ALARMS_4220"] = [{"alarmId": "7116", "faultId": "4220"}]

    var_dict["MASTER_IGNORED_ALARMS_X2"] = [
        {"alarmId": "7107", "faultId": "7319"},
        {"alarmId": "7107", "faultId": "7300"},
        {"alarmId": "7107", "faultId": "6327"},
        {"alarmId": "7107", "faultId": "7308"},
        {"alarmId": "7114", "faultId": "7107"},
    ]

    var_dict["MASTER_IGNORED_ALARMS_CNI_127210"] = [
        {"alarmId": "7222", "faultId": "9000"}
    ] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["MASTER_IGNORED_ALARMS_NO_CNI_127210"] = (
        [{"alarmId": "7222", "faultId": "9000"}]
        + SBTS_TEMP_IGNORED_ALARMS
        + ADMIN_ADDITIONAL_COMMON_IGNORED_ALARMS_NO_CNI_127210
    )

    var_dict["SLAVE_EXPECTED_ALARMS_10_1815_4773"] = [
        {"alarmId": "7116", "faultId": "10|1815|4773"}
    ]

    var_dict["SLAVE_EXPECTED_ALARMS_16"] = [{"alarmId": "7116", "faultId": "16"}]

    var_dict["SLAVE_EXPECTED_ALARMS_4220"] = [{"alarmId": "7116", "faultId": "4220"}]

    var_dict["SLAVE_IGNORED_ALARMS_X2"] = [
        {"alarmId": "7107", "faultId": "7319"},
        {"alarmId": "7107", "faultId": "7300"},
        {"alarmId": "7107", "faultId": "6327"},
        {"alarmId": "7107", "faultId": "7308"},
        {"alarmId": "7114", "faultId": "7107"},
    ]

    var_dict["SLAVE_IGNORED_ALARMS_CNI_127210"] = [
        {"alarmId": "7222", "faultId": "9000"}
    ] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["SLAVE_IGNORED_ALARMS_NO_CNI_127210"] = (
        [{"alarmId": "7222", "faultId": "9000"}]
        + SBTS_TEMP_IGNORED_ALARMS
        + ADMIN_ADDITIONAL_COMMON_IGNORED_ALARMS_NO_CNI_127210
    )

    var_dict["MASTER_CRITICAL_ALARMS"] = [] + SBTS_TEMP_CRITICAL_ALARMS

    var_dict["SLAVE_CRITICAL_ALARMS"] = [] + SBTS_TEMP_CRITICAL_ALARMS

    var_dict["MASTER_ALARMS_CNI_127210"] = {
        "MASTER_IGNORED_ALARMS": "MASTER_IGNORED_ALARMS_CNI_127210",
        "DSS_IGNORED_ALARMS": "DSS_IGNORED_ALARMS_CNI_127210",
    }

    var_dict["MASTER_ALARMS_NO_CNI_127210"] = {
        "MASTER_IGNORED_ALARMS": "MASTER_IGNORED_ALARMS_NO_CNI_127210",
        "DSS_IGNORED_ALARMS": "DSS_IGNORED_ALARMS_NO_CNI_127210",
    }

    var_dict["SLAVE_ALARMS_CNI_127210"] = {
        "SLAVE_IGNORED_ALARMS": "SLAVE_IGNORED_ALARMS_CNI_127210",
        "DSS_IGNORED_ALARMS": "DSS_IGNORED_ALARMS_CNI_127210",
    }

    var_dict["SLAVE_ALARMS_NO_CNI_127210"] = {
        "SLAVE_IGNORED_ALARMS": "SLAVE_IGNORED_ALARMS_NO_CNI_127210",
        "DSS_IGNORED_ALARMS": "DSS_IGNORED_ALARMS_NO_CNI_127210",
    }

    return var_dict


test_alarms_list = _build_variable_list()
