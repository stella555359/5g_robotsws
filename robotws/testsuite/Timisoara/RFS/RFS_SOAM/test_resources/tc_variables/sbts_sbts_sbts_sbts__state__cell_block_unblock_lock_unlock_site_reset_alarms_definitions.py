from temporary_alarms_definition import *


def _build_variable_list():
    var_dict = {}

    var_dict["MASTER_EXPECTED_ALARMS_49"] = [{"alarmId": "7102", "faultId": "49"}]

    var_dict["MASTER_IGNORED_ALARMS_DURING_ACTION_CNI_127210"] = [
        {"alarmId": "7108", "faultId": "1898"},
        {"alarmId": "7108", "faultId": "4385"},
        {"alarmId": "7114", "faultId": "4452"},
        {"alarmId": "7107", "faultId": "7300"},
        {"alarmId": "7107", "faultId": "7308"},
        {"alarmId": "7107", "faultId": "7319"},
        {"alarmId": "7114", "faultId": "7107"},
        {"alarmId": "7114", "faultId": "7100"},
        {"alarmId": "7114", "faultId": "7509|7511|7513"},
        {"alarmId": "7107", "faultId": "62003"},
    ]

    var_dict["MASTER_IGNORED_ALARMS_DURING_ACTION_NO_CNI_127210"] = [
        {"alarmId": "7108", "faultId": "1898"},
        {"alarmId": "7108", "faultId": "4385"},
        {"alarmId": "7114", "faultId": "4452"},
        {"alarmId": "7107", "faultId": "7300"},
        {"alarmId": "7107", "faultId": "7308"},
        {"alarmId": "7107", "faultId": "7319"},
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

    var_dict["SLAVE_EXPECTED_ALARMS_49"] = [{"alarmId": "7102", "faultId": "49"}]

    var_dict["SLAVE_IGNORED_ALARMS_DURING_ACTION_CNI_127210"] = [
        {"alarmId": "7108", "faultId": "1898"},
        {"alarmId": "7108", "faultId": "4385"},
        {"alarmId": "7114", "faultId": "4452"},
        {"alarmId": "7107", "faultId": "7300"},
        {"alarmId": "7107", "faultId": "7308"},
        {"alarmId": "7107", "faultId": "7319"},
        {"alarmId": "7114", "faultId": "7107"},
        {"alarmId": "7114", "faultId": "7100"},
        {"alarmId": "7114", "faultId": "7509|7511|7513"},
        {"alarmId": "7107", "faultId": "62003"},
    ]

    var_dict["SLAVE_IGNORED_ALARMS_DURING_ACTION_NO_CNI_127210"] = [
        {"alarmId": "7108", "faultId": "1898"},
        {"alarmId": "7108", "faultId": "4385"},
        {"alarmId": "7114", "faultId": "4452"},
        {"alarmId": "7107", "faultId": "7300"},
        {"alarmId": "7107", "faultId": "7308"},
        {"alarmId": "7107", "faultId": "7319"},
        {"alarmId": "7114", "faultId": "7107"},
        {"alarmId": "7114", "faultId": "7100"},
        {"alarmId": "7114", "faultId": "7509|7511|7513"},
        {"alarmId": "7112|7115", "faultId": "6129"},
        {"alarmId": "7107|7115", "faultId": "6132"},
        {"alarmId": "7112|7115", "faultId": "6134"},
        {"alarmId": "7107", "faultId": "62003"},
    ]

    var_dict["SLAVE_IGNORED_ALARMS_CNI_127210"] = [
        {"alarmId": "7222", "faultId": "9000"}
    ] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["SLAVE_IGNORED_ALARMS_NO_CNI_127210"] = (
        [{"alarmId": "7222", "faultId": "9000"}]
        + SBTS_TEMP_IGNORED_ALARMS
        + ADMIN_ADDITIONAL_COMMON_IGNORED_ALARMS_NO_CNI_127210
    )

    var_dict["SLAVE1_EXPECTED_ALARMS_49"] = [{"alarmId": "7102", "faultId": "49"}]

    var_dict["SLAVE1_IGNORED_ALARMS_DURING_ACTION_CNI_127210"] = [
        {"alarmId": "7108", "faultId": "1898"},
        {"alarmId": "7108", "faultId": "4385"},
        {"alarmId": "7114", "faultId": "4452"},
        {"alarmId": "7107", "faultId": "7300"},
        {"alarmId": "7107", "faultId": "7308"},
        {"alarmId": "7107", "faultId": "7319"},
        {"alarmId": "7114", "faultId": "7107"},
        {"alarmId": "7114", "faultId": "7100"},
        {"alarmId": "7114", "faultId": "7509|7511|7513"},
        {"alarmId": "7107", "faultId": "62003"},
    ]

    var_dict["SLAVE1_IGNORED_ALARMS_DURING_ACTION_NO_CNI_127210"] = [
        {"alarmId": "7108", "faultId": "1898"},
        {"alarmId": "7108", "faultId": "4385"},
        {"alarmId": "7114", "faultId": "4452"},
        {"alarmId": "7107", "faultId": "7300"},
        {"alarmId": "7107", "faultId": "7308"},
        {"alarmId": "7107", "faultId": "7319"},
        {"alarmId": "7114", "faultId": "7107"},
        {"alarmId": "7114", "faultId": "7100"},
        {"alarmId": "7114", "faultId": "7509|7511|7513"},
        {"alarmId": "7112|7115", "faultId": "6129"},
        {"alarmId": "7107|7115", "faultId": "6132"},
        {"alarmId": "7112|7115", "faultId": "6134"},
        {"alarmId": "7107", "faultId": "62003"},
    ]

    var_dict["SLAVE1_IGNORED_ALARMS_CNI_127210"] = [
        {"alarmId": "7222", "faultId": "9000"}
    ] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["SLAVE1_IGNORED_ALARMS_NO_CNI_127210"] = (
        [{"alarmId": "7222", "faultId": "9000"}]
        + SBTS_TEMP_IGNORED_ALARMS
        + ADMIN_ADDITIONAL_COMMON_IGNORED_ALARMS_NO_CNI_127210
    )

    var_dict["SLAVE2_EXPECTED_ALARMS_49"] = [{"alarmId": "7102", "faultId": "49"}]

    var_dict["SLAVE2_IGNORED_ALARMS_DURING_ACTION_CNI_127210"] = [
        {"alarmId": "7108", "faultId": "1898"},
        {"alarmId": "7108", "faultId": "4385"},
        {"alarmId": "7114", "faultId": "4452"},
        {"alarmId": "7107", "faultId": "7300"},
        {"alarmId": "7107", "faultId": "7308"},
        {"alarmId": "7107", "faultId": "7319"},
        {"alarmId": "7114", "faultId": "7107"},
        {"alarmId": "7114", "faultId": "7100"},
        {"alarmId": "7114", "faultId": "7509|7511|7513"},
        {"alarmId": "7107", "faultId": "62003"},
    ]

    var_dict["SLAVE2_IGNORED_ALARMS_DURING_ACTION_NO_CNI_127210"] = [
        {"alarmId": "7108", "faultId": "1898"},
        {"alarmId": "7108", "faultId": "4385"},
        {"alarmId": "7114", "faultId": "4452"},
        {"alarmId": "7107", "faultId": "7300"},
        {"alarmId": "7107", "faultId": "7308"},
        {"alarmId": "7107", "faultId": "7319"},
        {"alarmId": "7114", "faultId": "7107"},
        {"alarmId": "7114", "faultId": "7100"},
        {"alarmId": "7114", "faultId": "7509|7511|7513"},
        {"alarmId": "7112|7115", "faultId": "6129"},
        {"alarmId": "7107|7115", "faultId": "6132"},
        {"alarmId": "7112|7115", "faultId": "6134"},
        {"alarmId": "7107", "faultId": "62003"},
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
        "MASTER_IGNORED_ALARMS_DURING_ACTION": "MASTER_IGNORED_ALARMS_DURING_ACTION_CNI_127210",
    }

    var_dict["MASTER_ALARMS_NO_CNI_127210"] = {
        "MASTER_IGNORED_ALARMS": "MASTER_IGNORED_ALARMS_NO_CNI_127210",
        "MASTER_IGNORED_ALARMS_DURING_ACTION": "MASTER_IGNORED_ALARMS_DURING_ACTION_NO_CNI_127210",
    }

    var_dict["SLAVE_ALARMS_CNI_127210"] = {
        "SLAVE_IGNORED_ALARMS": "SLAVE_IGNORED_ALARMS_CNI_127210",
        "SLAVE_IGNORED_ALARMS_DURING_ACTION": "SLAVE_IGNORED_ALARMS_DURING_ACTION_CNI_127210",
    }

    var_dict["SLAVE_ALARMS_NO_CNI_127210"] = {
        "SLAVE_IGNORED_ALARMS": "SLAVE_IGNORED_ALARMS_NO_CNI_127210",
        "SLAVE_IGNORED_ALARMS_DURING_ACTION": "SLAVE_IGNORED_ALARMS_DURING_ACTION_NO_CNI_127210",
    }

    var_dict["SLAVE1_ALARMS_CNI_127210"] = {
        "SLAVE1_IGNORED_ALARMS": "SLAVE1_IGNORED_ALARMS_CNI_127210",
        "SLAVE1_IGNORED_ALARMS_DURING_ACTION": "SLAVE1_IGNORED_ALARMS_DURING_ACTION_CNI_127210",
    }

    var_dict["SLAVE1_ALARMS_NO_CNI_127210"] = {
        "SLAVE1_IGNORED_ALARMS": "SLAVE1_IGNORED_ALARMS_NO_CNI_127210",
        "SLAVE1_IGNORED_ALARMS_DURING_ACTION": "SLAVE1_IGNORED_ALARMS_DURING_ACTION_NO_CNI_127210",
    }

    var_dict["SLAVE2_ALARMS_CNI_127210"] = {
        "SLAVE2_IGNORED_ALARMS": "SLAVE2_IGNORED_ALARMS_CNI_127210",
        "SLAVE2_IGNORED_ALARMS_DURING_ACTION": "SLAVE2_IGNORED_ALARMS_DURING_ACTION_CNI_127210",
    }

    var_dict["SLAVE2_ALARMS_NO_CNI_127210"] = {
        "SLAVE2_IGNORED_ALARMS": "SLAVE2_IGNORED_ALARMS_NO_CNI_127210",
        "SLAVE2_IGNORED_ALARMS_DURING_ACTION": "SLAVE2_IGNORED_ALARMS_DURING_ACTION_NO_CNI_127210",
    }

    return var_dict


test_alarms_list = _build_variable_list()
