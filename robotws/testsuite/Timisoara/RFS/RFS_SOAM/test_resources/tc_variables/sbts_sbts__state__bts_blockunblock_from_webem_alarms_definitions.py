from temporary_alarms_definition import *


def _build_variable_list():
    var_dict = {}

    var_dict["MASTER_EXPECTED_ALARMS_50"] = [{"alarmId": "7102", "faultId": "50"}]

    var_dict["MASTER_EXPECTED_ALARMS_10_1815"] = [
        {"alarmId": "7116", "faultId": "10|1815"}
    ]

    var_dict["MASTER_EXPECTED_ALARMS_16"] = [{"alarmId": "7116", "faultId": "16"}]

    var_dict["MASTER_ALARMS_NR_DSS"] = [
        {"alarmId": "7114", "faultId": "7513|7511|7509"}
    ]

    var_dict["MASTER_ALARMS_LTE_DSS_CNI_127210"] = [
        {"alarmId": "7115|7107|7112", "faultId": "6134|6132|6129"}
    ]

    var_dict["MASTER_ALARMS_LTE_DSS_NO_CNI_127210"] = [
        {"alarmId": "7115", "faultId": "6134|6132|6129"}
    ]

    var_dict["MASTER_IGNORED_ALARMS_CNI_127210"] = [
        {"alarmId": "7222", "faultId": "9000"},
        {"alarmId": "7108", "faultId": "1898"},
        {"alarmId": "7114", "faultId": "4452"},
    ] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["MASTER_IGNORED_ALARMS_NO_CNI_127210"] = (
        [
            {"alarmId": "7222", "faultId": "9000"},
            {"alarmId": "7108", "faultId": "1898"},
            {"alarmId": "7114", "faultId": "4452"},
        ]
        + SBTS_TEMP_IGNORED_ALARMS
        + ADMIN_ADDITIONAL_COMMON_IGNORED_ALARMS_NO_CNI_127210
    )

    var_dict["MASTER_IGNORED_ALARMS_DURING_ACTION"] = [
        {"alarmId": "7116", "faultId": "4220"},
        {"alarmId": "7107", "faultId": "7300"},
        {"alarmId": "7107", "faultId": "7319"},
        {"alarmId": "7107", "faultId": "7308"},
        {"alarmId": "7107", "faultId": "6327"},
        {"alarmId": "7107", "faultId": "6328"},
        {"alarmId": "7114", "faultId": "7107"},
        {"alarmId": "7114", "faultId": "7100"},
        {"alarmId": "7107", "faultId": "62003"},
    ]

    var_dict["SLAVE_EXPECTED_ALARMS_50"] = [{"alarmId": "7102", "faultId": "50"}]

    var_dict["SLAVE_EXPECTED_ALARMS_10_1815"] = [
        {"alarmId": "7116", "faultId": "10|1815"}
    ]

    var_dict["SLAVE_EXPECTED_ALARMS_16"] = [{"alarmId": "7116", "faultId": "16"}]

    var_dict["SLAVE_ALARMS_NR_DSS"] = [{"alarmId": "7114", "faultId": "7513|7511|7509"}]

    var_dict["SLAVE_ALARMS_LTE_DSS_CNI_127210"] = [
        {"alarmId": "7115|7107|7112", "faultId": "6134|6132|6129"}
    ]

    var_dict["SLAVE_ALARMS_LTE_DSS_NO_CNI_127210"] = [
        {"alarmId": "7115", "faultId": "6134|6132|6129"}
    ]

    var_dict["SLAVE_IGNORED_ALARMS_CNI_127210"] = [
        {"alarmId": "7222", "faultId": "9000"},
        {"alarmId": "7108", "faultId": "1898"},
        {"alarmId": "7114", "faultId": "4452"},
    ] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["SLAVE_IGNORED_ALARMS_NO_CNI_127210"] = (
        [
            {"alarmId": "7222", "faultId": "9000"},
            {"alarmId": "7108", "faultId": "1898"},
            {"alarmId": "7114", "faultId": "4452"},
        ]
        + SBTS_TEMP_IGNORED_ALARMS
        + ADMIN_ADDITIONAL_COMMON_IGNORED_ALARMS_NO_CNI_127210
    )

    var_dict["SLAVE_IGNORED_ALARMS_DURING_ACTION"] = [
        {"alarmId": "7116", "faultId": "4220"},
        {"alarmId": "7107", "faultId": "7300"},
        {"alarmId": "7107", "faultId": "7319"},
        {"alarmId": "7107", "faultId": "7308"},
        {"alarmId": "7107", "faultId": "6327"},
        {"alarmId": "7107", "faultId": "6328"},
        {"alarmId": "7114", "faultId": "7107"},
        {"alarmId": "7114", "faultId": "7100"},
        {"alarmId": "7107", "faultId": "62003"},
    ]

    var_dict["MASTER_CRITICAL_ALARMS"] = [] + SBTS_TEMP_CRITICAL_ALARMS

    var_dict["SLAVE_CRITICAL_ALARMS"] = [] + SBTS_TEMP_CRITICAL_ALARMS

    var_dict["MASTER_ALARMS_CNI_127210"] = {
        "MASTER_IGNORED_ALARMS": "MASTER_IGNORED_ALARMS_CNI_127210",
        "MASTER_ALARMS_LTE_DSS": "MASTER_ALARMS_LTE_DSS_CNI_127210",
    }

    var_dict["MASTER_ALARMS_NO_CNI_127210"] = {
        "MASTER_IGNORED_ALARMS": "MASTER_IGNORED_ALARMS_NO_CNI_127210",
        "MASTER_ALARMS_LTE_DSS": "MASTER_ALARMS_LTE_DSS_NO_CNI_127210",
    }

    var_dict["SLAVE_ALARMS_CNI_127210"] = {
        "SLAVE_IGNORED_ALARMS": "SLAVE_IGNORED_ALARMS_CNI_127210",
        "SLAVE_ALARMS_LTE_DSS": "SLAVE_ALARMS_LTE_DSS_CNI_127210",
    }

    var_dict["SLAVE_ALARMS_NO_CNI_127210"] = {
        "SLAVE_IGNORED_ALARMS": "SLAVE_IGNORED_ALARMS_NO_CNI_127210",
        "SLAVE_ALARMS_LTE_DSS": "SLAVE_ALARMS_LTE_DSS_NO_CNI_127210",
    }

    return var_dict


test_alarms_list = _build_variable_list()
