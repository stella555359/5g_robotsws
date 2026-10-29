from temporary_alarms_definition import *


def _build_variable_list():
    var_dict = {}

    var_dict["MASTER_EXPECTED_ALARMS_10"] = [{"alarmId": "7116", "faultId": "10"}]

    var_dict["MASTER_EXPECTED_ALARMS_10_1815"] = [
        {"alarmId": "7116", "faultId": "1815|10"}
    ]

    var_dict["MASTER_EXPECTED_ALARMS_16"] = [{"alarmId": "7116", "faultId": "16"}]

    var_dict["MASTER_EXPECTED_ALARMS_4220"] = [{"alarmId": "7116", "faultId": "4220"}]

    var_dict["SLAVE_EXPECTED_ALARMS_10"] = [{"alarmId": "7116", "faultId": "10"}]

    var_dict["SLAVE_EXPECTED_ALARMS_10_1815"] = [
        {"alarmId": "7116", "faultId": "1815|10"}
    ]

    var_dict["SLAVE_EXPECTED_ALARMS_16"] = [{"alarmId": "7116", "faultId": "16"}]

    var_dict["SLAVE_EXPECTED_ALARMS_4220"] = [{"alarmId": "7116", "faultId": "4220"}]

    var_dict["MASTER_IGNORED_ALARMS_DURING_POWER_OFF_CNI_127210"] = [
        {"alarmId": "7108", "faultId": "1898"},
        {"alarmId": "7115", "faultId": "4405"},
        {"alarmId": "7115", "faultId": "6280"},
        {"alarmId": "7108", "faultId": "4385"},
        {"alarmId": "7114", "faultId": "4452"},
        {"alarmId": "7107", "faultId": "7300"},
        {"alarmId": "7107", "faultId": "7308"},
        {"alarmId": "7107", "faultId": "7319"},
        {"alarmId": "7107", "faultId": "6327"},
        {"alarmId": "7107", "faultId": "6328"},
        {"alarmId": "7114", "faultId": "7107"},
        {"alarmId": "7114", "faultId": "7100"},
        {"alarmId": "7114", "faultId": "7509|7511|7513"},
        {"alarmId": "7107", "faultId": "62003"},
    ]

    var_dict["MASTER_IGNORED_ALARMS_DURING_POWER_OFF_NO_CNI_127210"] = [
        {"alarmId": "7108", "faultId": "1898"},
        {"alarmId": "7115", "faultId": "4405"},
        {"alarmId": "7115", "faultId": "6280"},
        {"alarmId": "7108", "faultId": "4385"},
        {"alarmId": "7114", "faultId": "4452"},
        {"alarmId": "7107", "faultId": "7300"},
        {"alarmId": "7107", "faultId": "7308"},
        {"alarmId": "7107", "faultId": "7319"},
        {"alarmId": "7107", "faultId": "6327"},
        {"alarmId": "7107", "faultId": "6328"},
        {"alarmId": "7114", "faultId": "7107"},
        {"alarmId": "7114", "faultId": "7100"},
        {"alarmId": "7114", "faultId": "7509|7511|7513"},
        {"alarmId": "7112|7115", "faultId": "6129"},
        {"alarmId": "7107|7115", "faultId": "6132"},
        {"alarmId": "7112|7115", "faultId": "6134"},
        {"alarmId": "7107", "faultId": "62003"},
    ]

    var_dict["MASTER_IGNORED_ALARMS_CNI_127210"] = [
        {"alarmId": "7222", "faultId": "9000"}
    ] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["MASTER_IGNORED_ALARMS_NO_CNI_127210"] = (
        [{"alarmId": "7222", "faultId": "9000"}]
        + SBTS_TEMP_IGNORED_ALARMS
        + ADMIN_ADDITIONAL_COMMON_IGNORED_ALARMS_NO_CNI_127210
    )

    var_dict["SLAVE_IGNORED_ALARMS_DURING_POWER_OFF_CNI_127210"] = [
        {"alarmId": "7108", "faultId": "1898"},
        {"alarmId": "7115", "faultId": "4405"},
        {"alarmId": "7115", "faultId": "6280"},
        {"alarmId": "7108", "faultId": "4385"},
        {"alarmId": "7114", "faultId": "4452"},
        {"alarmId": "7107", "faultId": "7300"},
        {"alarmId": "7107", "faultId": "7308"},
        {"alarmId": "7107", "faultId": "7319"},
        {"alarmId": "7107", "faultId": "6327"},
        {"alarmId": "7107", "faultId": "6328"},
        {"alarmId": "7114", "faultId": "7107"},
        {"alarmId": "7114", "faultId": "7100"},
        {"alarmId": "7114", "faultId": "7509|7511|7513"},
        {"alarmId": "7107", "faultId": "62003"},
    ]

    var_dict["SLAVE_IGNORED_ALARMS_DURING_POWER_OFF_NO_CNI_127210"] = [
        {"alarmId": "7108", "faultId": "1898"},
        {"alarmId": "7115", "faultId": "4405"},
        {"alarmId": "7115", "faultId": "6280"},
        {"alarmId": "7108", "faultId": "4385"},
        {"alarmId": "7114", "faultId": "4452"},
        {"alarmId": "7107", "faultId": "7300"},
        {"alarmId": "7107", "faultId": "7308"},
        {"alarmId": "7107", "faultId": "7319"},
        {"alarmId": "7107", "faultId": "6327"},
        {"alarmId": "7107", "faultId": "6328"},
        {"alarmId": "7114", "faultId": "7107"},
        {"alarmId": "7114", "faultId": "7100"},
        {"alarmId": "7114", "faultId": "7509|7511|7513"},
        {"alarmId": "7115", "faultId": "6129|6132|6134"},
        {"alarmId": "7107", "faultId": "62003"},
    ]

    var_dict["MASTER_HISTORICAL_IGNORED_ALARMS"] = [
                                                     {"faultId": "4590", "faultSignature": {"category": "POWER_OFF"}}
                                                   ] + ADMIN_COMMON_IGNORED_ALARMS

    var_dict["SLAVE_HISTORICAL_IGNORED_ALARMS"] = [
                                                    {"faultId": "4590", "faultSignature": {"category": "POWER_OFF"}}
                                                  ] + ADMIN_COMMON_IGNORED_ALARMS

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
        "MASTER_IGNORED_ALARMS_DURING_POWER_OFF": "MASTER_IGNORED_ALARMS_DURING_POWER_OFF_CNI_127210",
    }

    var_dict["MASTER_ALARMS_NO_CNI_127210"] = {
        "MASTER_IGNORED_ALARMS": "MASTER_IGNORED_ALARMS_NO_CNI_127210",
        "MASTER_IGNORED_ALARMS_DURING_POWER_OFF": "MASTER_IGNORED_ALARMS_DURING_POWER_OFF_NO_CNI_127210",
    }

    var_dict["SLAVE_ALARMS_CNI_127210"] = {
        "SLAVE_IGNORED_ALARMS": "SLAVE_IGNORED_ALARMS_CNI_127210",
        "SLAVE_IGNORED_ALARMS_DURING_POWER_OFF": "SLAVE_IGNORED_ALARMS_DURING_POWER_OFF_CNI_127210",
    }

    var_dict["SLAVE_ALARMS_NO_CNI_127210"] = {
        "SLAVE_IGNORED_ALARMS": "SLAVE_IGNORED_ALARMS_NO_CNI_127210",
        "SLAVE_IGNORED_ALARMS_DURING_POWER_OFF": "SLAVE_IGNORED_ALARMS_DURING_POWER_OFF_NO_CNI_127210",
    }

    return var_dict


test_alarms_list = _build_variable_list()
