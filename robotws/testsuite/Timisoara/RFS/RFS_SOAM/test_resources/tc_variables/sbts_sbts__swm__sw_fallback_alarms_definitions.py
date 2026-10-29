from temporary_alarms_definition import *


def _build_variable_list():
    var_dict = {}

    var_dict["MASTER_EXPECTED_ALARMS_4085"] = [{"alarmId": "7111", "faultId": "4085"}]

    var_dict["MASTER_EXPECTED_ALARMS_4220"] = [{"alarmId": "7116", "faultId": "4220"}]

    var_dict["MASTER_IGNORED_ALARMS_DURING_FALLBACK"] = [
        {"alarmId": "7116", "faultId": "10|1815|4773|16"},
        {"alarmId": "7108", "faultId": "1898"}
    ]

    var_dict["MASTER_IGNORED_ALARMS_AFTER_FALLBACK"] = [
        {"alarmId": "7111", "faultId": "23"},
        {"alarmId": "7250", "faultId": "4753"},
        {'alarmId': '7107', 'faultId': '7319'},
        {'alarmId': '7107', 'faultId': '7300'},
    ]

    var_dict["MASTER_IGNORED_ALARMS_4420"] = [
        {'alarmId': '7115', 'faultId': '4420'}
    ]

    var_dict["MASTER_IGNORED_ALARMS_CNI_127210"] = [
        {"alarmId": "7222", "faultId": "9000"}
    ] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["MASTER_IGNORED_ALARMS_NO_CNI_127210"] = (
        [{"alarmId": "7222", "faultId": "9000"}]
        + SBTS_TEMP_IGNORED_ALARMS
        + ADMIN_ADDITIONAL_COMMON_IGNORED_ALARMS_NO_CNI_127210
    )

    var_dict["SLAVE_EXPECTED_ALARMS_4085"] = [{"alarmId": "7111", "faultId": "4085"}]

    var_dict["SLAVE_EXPECTED_ALARMS_4220"] = [{"alarmId": "7116", "faultId": "4220"}]

    var_dict["SLAVE_IGNORED_ALARMS_DURING_FALLBACK"] = [
        {"alarmId": "7116", "faultId": "10|1815|4773|16"},
        {"alarmId": "7108", "faultId": "1898"}
    ]

    var_dict["SLAVE_IGNORED_ALARMS_AFTER_FALLBACK"] = [
        {"alarmId": "7111", "faultId": "23"},
        {"alarmId": "7250", "faultId": "4753"},
        {'alarmId': '7107', 'faultId': '7319'},
        {'alarmId': '7107', 'faultId': '7300'},
    ]

    var_dict["SLAVE_IGNORED_ALARMS_4420"] = [
        {'alarmId': '7115', 'faultId': '4420'}
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
        "MASTER_IGNORED_ALARMS": "MASTER_IGNORED_ALARMS_CNI_127210"
    }

    var_dict["MASTER_ALARMS_NO_CNI_127210"] = {
        "MASTER_IGNORED_ALARMS": "MASTER_IGNORED_ALARMS_NO_CNI_127210"
    }

    var_dict["SLAVE_ALARMS_CNI_127210"] = {
        "SLAVE_IGNORED_ALARMS": "SLAVE_IGNORED_ALARMS_CNI_127210"
    }

    var_dict["SLAVE_ALARMS_NO_CNI_127210"] = {
        "SLAVE_IGNORED_ALARMS": "SLAVE_IGNORED_ALARMS_NO_CNI_127210"
    }

    return var_dict


test_alarms_list = _build_variable_list()
