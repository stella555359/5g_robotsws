from temporary_alarms_definition import *


def _build_variable_list():
    var_dict = {}

    var_dict["IGNORED_ALARMS_DURING_UNBLOCK_CNI_127210"] = [
        {"alarmId": "7115", "faultId": "4110"},
        {"alarmId": "7108", "faultId": "1898"},
        {"alarmId": "7107", "faultId": "7319"},
        {"alarmId": "7107", "faultId": "7300"},
        {"alarmId": "7107", "faultId": "6327"},
        {"alarmId": "7114", "faultId": "7107"},
        {"alarmId": "7107", "faultId": "62003"},
        {"alarmId": "7115", "faultId": "4401"},
        {"alarmId": "7115|7112", "faultId": "6129"},
        {"alarmId": "7115|7107", "faultId": "6132"},
        {"alarmId": "7115|7112", "faultId": "6134"},
        {"alarmId": "7114", "faultId": "7513"},
        {"alarmId": "7114", "faultId": "7511"},
        {"alarmId": "7114", "faultId": "7509"},
    ]

    var_dict["IGNORED_ALARMS_DURING_UNBLOCK_NO_CNI_127210"] = [
        {"alarmId": "7115", "faultId": "4401"},
        {"alarmId": "7115", "faultId": "4110"},
        {"alarmId": "7115", "faultId": "6129"},
        {"alarmId": "7115", "faultId": "6132"},
        {"alarmId": "7115", "faultId": "6134"},
        {"alarmId": "7108", "faultId": "1898"},
        {"alarmId": "7107", "faultId": "7319"},
        {"alarmId": "7107", "faultId": "7300"},
        {"alarmId": "7107", "faultId": "6327"},
        {"alarmId": "7114", "faultId": "7107"},
        {"alarmId": "7107", "faultId": "62003"},
        {"alarmId": "7114", "faultId": "7513"},
        {"alarmId": "7114", "faultId": "7511"},
        {"alarmId": "7114", "faultId": "7509"},
    ]

    var_dict["MASTER_EXPECTED_ALARMS_50"] = [{"alarmId": "7102", "faultId": "50"}]

    var_dict["MASTER_EXPECTED_ALARMS_10"] = [{"alarmId": "7116", "faultId": "10"}]

    var_dict["MASTER_EXPECTED_ALARMS_10_1815"] = [
        {"alarmId": "7116", "faultId": "10|1815"}
    ]

    var_dict["MASTER_EXPECTED_ALARMS_16"] = [{"alarmId": "7116", "faultId": "16"}]

    var_dict["MASTER_EXPECTED_ALARMS_NR_DSS"] = [
        {"alarmId": "7114", "faultId": "7513|7511|7509"}
    ]

    var_dict["MASTER_EXPECTED_ALARMS_LTE_DSS_CNI_127210"] = [
        {"alarmId": "7115|7112|7107", "faultId": "6129|6132|6134"}
    ]

    var_dict["MASTER_EXPECTED_ALARMS_LTE_DSS_NO_CNI_127210"] = [
        {"alarmId": "7115", "faultId": "6129|6132|6134"}
    ]

    var_dict["MASTER_IGNORED_ALARMS_CNI_127210"] = [
        {"alarmId": "7222", "faultId": "9000"}
    ] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["MASTER_IGNORED_ALARMS_NO_CNI_127210"] = (
        [{"alarmId": "7222", "faultId": "9000"}]
        + SBTS_TEMP_IGNORED_ALARMS
        + ADMIN_ADDITIONAL_COMMON_IGNORED_ALARMS_NO_CNI_127210
    )

    var_dict["SLAVE_EXPECTED_ALARMS_50"] = [{"alarmId": "7102", "faultId": "50"}]

    var_dict["SLAVE_EXPECTED_ALARMS_10"] = [{"alarmId": "7116", "faultId": "10"}]

    var_dict["SLAVE_EXPECTED_ALARMS_10_1815"] = [
        {"alarmId": "7116", "faultId": "10|1815"}
    ]

    var_dict["SLAVE_EXPECTED_ALARMS_16"] = [{"alarmId": "7116", "faultId": "16"}]

    var_dict["SLAVE_EXPECTED_ALARMS_NR_DSS"] = [
        {"alarmId": "7114", "faultId": "7513|7511|7509"}
    ]

    var_dict["SLAVE_EXPECTED_ALARMS_LTE_DSS_CNI_127210"] = [
        {"alarmId": "7115|7112|7107", "faultId": "6129|6132|6134"}
    ]

    var_dict["SLAVE_EXPECTED_ALARMS_LTE_DSS_NO_CNI_127210"] = [
        {"alarmId": "7115", "faultId": "6129|6132|6134"}
    ]

    var_dict["SLAVE_IGNORED_ALARMS_CNI_127210"] = [
        {"alarmId": "7222", "faultId": "9000"}
    ] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["SLAVE_IGNORED_ALARMS_NO_CNI_127210"] = (
        [{"alarmId": "7222", "faultId": "9000"}]
        + SBTS_TEMP_IGNORED_ALARMS
        + ADMIN_ADDITIONAL_COMMON_IGNORED_ALARMS_NO_CNI_127210
    )

    var_dict["SLAVE1_EXPECTED_ALARMS_50"] = [{"alarmId": "7102", "faultId": "50"}]

    var_dict["SLAVE1_EXPECTED_ALARMS_10"] = [{"alarmId": "7116", "faultId": "10"}]

    var_dict["SLAVE1_EXPECTED_ALARMS_10_1815"] = [
        {"alarmId": "7116", "faultId": "10|1815"}
    ]

    var_dict["SLAVE1_EXPECTED_ALARMS_16"] = [{"alarmId": "7116", "faultId": "16"}]

    var_dict["SLAVE1_EXPECTED_ALARMS_NR_DSS"] = [
        {"alarmId": "7114", "faultId": "7513|7511|7509"}
    ]

    var_dict["SLAVE1_EXPECTED_ALARMS_LTE_DSS_CNI_127210"] = [
        {"alarmId": "7115|7112|7107", "faultId": "6129|6132|6134"}
    ]

    var_dict["SLAVE1_EXPECTED_ALARMS_LTE_DSS_NO_CNI_127210"] = [
        {"alarmId": "7115", "faultId": "6129|6132|6134"}
    ]

    var_dict["SLAVE1_IGNORED_ALARMS_CNI_127210"] = [
        {"alarmId": "7222", "faultId": "9000"}
    ] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["SLAVE1_IGNORED_ALARMS_NO_CNI_127210"] = (
        [{"alarmId": "7222", "faultId": "9000"}]
        + SBTS_TEMP_IGNORED_ALARMS
        + ADMIN_ADDITIONAL_COMMON_IGNORED_ALARMS_NO_CNI_127210
    )

    var_dict["SLAVE2_EXPECTED_ALARMS_50"] = [{"alarmId": "7102", "faultId": "50"}]

    var_dict["SLAVE2_EXPECTED_ALARMS_10"] = [{"alarmId": "7116", "faultId": "10"}]

    var_dict["SLAVE2_EXPECTED_ALARMS_10_1815"] = [
        {"alarmId": "7116", "faultId": "10|1815"}
    ]

    var_dict["SLAVE2_EXPECTED_ALARMS_16"] = [{"alarmId": "7116", "faultId": "16"}]

    var_dict["SLAVE2_EXPECTED_ALARMS_NR_DSS"] = [
        {"alarmId": "7114", "faultId": "7513|7511|7509"}
    ]

    var_dict["SLAVE2_EXPECTED_ALARMS_LTE_DSS_CNI_127210"] = [
        {"alarmId": "7115|7112|7107", "faultId": "6129|6132|6134"}
    ]

    var_dict["SLAVE2_EXPECTED_ALARMS_LTE_DSS_NO_CNI_127210"] = [
        {"alarmId": "7115", "faultId": "6129|6132|6134"}
    ]

    var_dict["SLAVE2_IGNORED_ALARMS_CNI_127210"] = [
        {"alarmId": "7222", "faultId": "9000"}
    ] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["SLAVE2_IGNORED_ALARMS_NO_CNI_127210"] = (
        [{"alarmId": "7222", "faultId": "9000"}]
        + SBTS_TEMP_IGNORED_ALARMS
        + ADMIN_ADDITIONAL_COMMON_IGNORED_ALARMS_NO_CNI_127210
    )

    var_dict["MASTER_CRITICAL_ALARMS"] = [] + SBTS_TEMP_CRITICAL_ALARMS

    var_dict["SLAVE_CRITICAL_ALARMS"] = [] + SBTS_TEMP_CRITICAL_ALARMS

    var_dict["SLAVE1_CRITICAL_ALARMS"] = [] + SBTS_TEMP_CRITICAL_ALARMS

    var_dict["SLAVE2_CRITICAL_ALARMS"] = [] + SBTS_TEMP_CRITICAL_ALARMS

    var_dict["MASTER_ALARMS_CNI_127210"] = {
        "MASTER_IGNORED_ALARMS": "MASTER_IGNORED_ALARMS_CNI_127210",
        "IGNORED_ALARMS_DURING_UNBLOCK": "IGNORED_ALARMS_DURING_UNBLOCK_CNI_127210",
        "MASTER_EXPECTED_ALARMS_LTE_DSS_": "MASTER_EXPECTED_ALARMS_LTE_DSS_CNI_127210",
    }

    var_dict["MASTER_ALARMS_NO_CNI_127210"] = {
        "MASTER_IGNORED_ALARMS": "MASTER_IGNORED_ALARMS_NO_CNI_127210",
        "IGNORED_ALARMS_DURING_UNBLOCK": "IGNORED_ALARMS_DURING_UNBLOCK_NO_CNI_127210",
        "MASTER_EXPECTED_ALARMS_LTE_DSS_": "MASTER_EXPECTED_ALARMS_LTE_DSS_NO_CNI_127210",
    }

    var_dict["SLAVE_ALARMS_CNI_127210"] = {
        "SLAVE_IGNORED_ALARMS": "SLAVE_IGNORED_ALARMS_CNI_127210",
        "IGNORED_ALARMS_DURING_UNBLOCK": "IGNORED_ALARMS_DURING_UNBLOCK_CNI_127210",
        "SLAVE_EXPECTED_ALARMS_LTE_DSS_": "SLAVE_EXPECTED_ALARMS_LTE_DSS_CNI_127210",
    }

    var_dict["SLAVE_ALARMS_NO_CNI_127210"] = {
        "SLAVE_IGNORED_ALARMS": "SLAVE_IGNORED_ALARMS_NO_CNI_127210",
        "IGNORED_ALARMS_DURING_UNBLOCK": "IGNORED_ALARMS_DURING_UNBLOCK_NO_CNI_127210",
        "SLAVE_EXPECTED_ALARMS_LTE_DSS_": "SLAVE_EXPECTED_ALARMS_LTE_DSS_NO_CNI_127210",
    }

    var_dict["SLAVE1_ALARMS_CNI_127210"] = {
        "SLAVE1_IGNORED_ALARMS": "SLAVE1_IGNORED_ALARMS_CNI_127210",
        "IGNORED_ALARMS_DURING_UNBLOCK": "IGNORED_ALARMS_DURING_UNBLOCK_CNI_127210",
        "SLAVE1_EXPECTED_ALARMS_LTE_DSS_": "SLAVE1_EXPECTED_ALARMS_LTE_DSS_CNI_127210",
    }

    var_dict["SLAVE1_ALARMS_NO_CNI_127210"] = {
        "SLAVE1_IGNORED_ALARMS": "SLAVE1_IGNORED_ALARMS_NO_CNI_127210",
        "IGNORED_ALARMS_DURING_UNBLOCK": "IGNORED_ALARMS_DURING_UNBLOCK_NO_CNI_127210",
        "SLAVE1_EXPECTED_ALARMS_LTE_DSS_": "SLAVE1_EXPECTED_ALARMS_LTE_DSS_NO_CNI_127210",
    }

    var_dict["SLAVE2_ALARMS_CNI_127210"] = {
        "SLAVE2_IGNORED_ALARMS": "SLAVE2_IGNORED_ALARMS_CNI_127210",
        "IGNORED_ALARMS_DURING_UNBLOCK": "IGNORED_ALARMS_DURING_UNBLOCK_CNI_127210",
        "SLAVE2_EXPECTED_ALARMS_LTE_DSS_": "SLAVE2_EXPECTED_ALARMS_LTE_DSS_CNI_127210",
    }

    var_dict["SLAVE2_ALARMS_NO_CNI_127210"] = {
        "SLAVE2_IGNORED_ALARMS": "SLAVE2_IGNORED_ALARMS_NO_CNI_127210",
        "IGNORED_ALARMS_DURING_UNBLOCK": "IGNORED_ALARMS_DURING_UNBLOCK_NO_CNI_127210",
        "SLAVE2_EXPECTED_ALARMS_LTE_DSS_": "SLAVE2_EXPECTED_ALARMS_LTE_NO_DSS_CNI_127210",
    }

    return var_dict


test_alarms_list = _build_variable_list()
