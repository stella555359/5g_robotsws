from temporary_alarms_definition import *


def _build_variable_list():
    var_dict = {}

    var_dict["MASTER_EXPECTED_ALARMS_4742"] = [{"alarmId": "7115", "faultId": "4742"}]

    var_dict["MASTER_EXPECTED_ALARMS_16"] = [{"alarmId": "7116", "faultId": "16"}]

    var_dict["MASTER_IGNORED_ALARMS_DSS_CNI_127210"] = [
        {"alarmId": "7114", "faultId": "7513"},
        {"alarmId": "7114", "faultId": "7511"},
        {"alarmId": "7114", "faultId": "7509"},
        {"alarmId": "7107", "faultId": "62003"},
        {"alarmId": "7115|7112", "faultId": "6129"},
        {"alarmId": "7115|7107", "faultId": "6132"},
        {"alarmId": "7115|7112", "faultId": "6134"},
    ]

    var_dict["MASTER_IGNORED_ALARMS_DSS_NO_CNI_127210"] = [
        {"alarmId": "7114", "faultId": "7513"},
        {"alarmId": "7114", "faultId": "7511"},
        {"alarmId": "7114", "faultId": "7509"},
        {"alarmId": "7115", "faultId": "6129"},
        {"alarmId": "7115", "faultId": "6132"},
        {"alarmId": "7115", "faultId": "6134"},
        {"alarmId": "7107", "faultId": "62003"},
    ]

    var_dict["MASTER_IGNORED_ALARMS_SYNC_CNI_127210"] = [
        {"alarmId": "7108", "faultId": "1898"},
        {"alarmId": "7115", "faultId": "1898"},
        {"alarmId": "7115", "faultId": "4405"},
    ]

    var_dict["MASTER_IGNORED_ALARMS_SYNC_NO_CNI_127210"] = [
        {"alarmId": "7108", "faultId": "1898"},
        {"alarmId": "7115", "faultId": "1898"},
        {"alarmId": "7115", "faultId": "4405"},
    ]

    var_dict["MASTER_IGNORED_ALARMS_CNI_127210"] = [
        {"alarmId": "7222", "faultId": "9000"}
    ] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["MASTER_IGNORED_ALARMS_NO_CNI_127210"] = (
        [{"alarmId": "7222", "faultId": "9000"}]
        + SBTS_TEMP_IGNORED_ALARMS
        + ADMIN_ADDITIONAL_COMMON_IGNORED_ALARMS_NO_CNI_127210
    )

    var_dict["SLAVE_EXPECTED_ALARMS_4742"] = [{"alarmId": "7115", "faultId": "4742"}]

    var_dict["SLAVE_EXPECTED_ALARMS_16"] = [{"alarmId": "7116", "faultId": "16"}]

    var_dict["SLAVE_IGNORED_ALARMS_DSS_CNI_127210"] = [
        {"alarmId": "7114", "faultId": "7513"},
        {"alarmId": "7114", "faultId": "7511"},
        {"alarmId": "7114", "faultId": "7509"},
        {"alarmId": "7107", "faultId": "62003"},
        {"alarmId": "7115|7112", "faultId": "6129"},
        {"alarmId": "7115|7107", "faultId": "6132"},
        {"alarmId": "7115|7112", "faultId": "6134"},
    ]

    var_dict["SLAVE_IGNORED_ALARMS_DSS_NO_CNI_127210"] = [
        {"alarmId": "7114", "faultId": "7513"},
        {"alarmId": "7114", "faultId": "7511"},
        {"alarmId": "7114", "faultId": "7509"},
        {"alarmId": "7115", "faultId": "6129"},
        {"alarmId": "7115", "faultId": "6132"},
        {"alarmId": "7115", "faultId": "6134"},
        {"alarmId": "7107", "faultId": "62003"},
    ]

    var_dict["SLAVE_IGNORED_ALARMS_SYNC_CNI_127210"] = [
        {"alarmId": "7108", "faultId": "1898"},
        {"alarmId": "7115", "faultId": "1898"},
        {"alarmId": "7115", "faultId": "4405"},
    ]

    var_dict["SLAVE_IGNORED_ALARMS_SYNC_NO_CNI_127210"] = [
        {"alarmId": "7108", "faultId": "1898"},
        {"alarmId": "7115", "faultId": "1898"},
        {"alarmId": "7115", "faultId": "4405"},
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
        "MASTER_IGNORED_ALARMS_DSS": "MASTER_IGNORED_ALARMS_DSS_CNI_127210",
        "MASTER_IGNORED_ALARMS_SYNC": "MASTER_IGNORED_ALARMS_SYNC_CNI_127210",
    }

    var_dict["MASTER_ALARMS_NO_CNI_127210"] = {
        "MASTER_IGNORED_ALARMS": "MASTER_IGNORED_ALARMS_NO_CNI_127210",
        "MASTER_IGNORED_ALARMS_DSS": "MASTER_IGNORED_ALARMS_DSS_NO_CNI_127210",
        "MASTER_IGNORED_ALARMS_SYNC": "MASTER_IGNORED_ALARMS_SYNC_NO_CNI_127210",
    }

    var_dict["SLAVE_ALARMS_CNI_127210"] = {
        "SLAVE_IGNORED_ALARMS": "SLAVE_IGNORED_ALARMS_CNI_127210",
        "SLAVE_IGNORED_ALARMS_DSS": "SLAVE_IGNORED_ALARMS_DSS_CNI_127210",
        "SLAVE_IGNORED_ALARMS_SYNC": "SLAVE_IGNORED_ALARMS_SYNC_CNI_127210",
    }

    var_dict["SLAVE_ALARMS_NO_CNI_127210"] = {
        "SLAVE_IGNORED_ALARMS": "SLAVE_IGNORED_ALARMS_NO_CNI_127210",
        "SLAVE_IGNORED_ALARMS_DSS": "SLAVE_IGNORED_ALARMS_DSS_NO_CNI_127210",
        "SLAVE_IGNORED_ALARMS_SYNC": "SLAVE_IGNORED_ALARMS_SYNC_NO_CNI_127210",
    }

    return var_dict


test_alarms_list = _build_variable_list()
