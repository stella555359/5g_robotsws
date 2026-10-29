from temporary_alarms_definition import *


def _build_variable_list():
    var_dict = {}

    var_dict["MASTER_EXPECTED_ALARMS_2919"] = [
        {"alarmId": "7100|7115", "faultId": "2919"}
    ]

    var_dict["MASTER_EXPECTED_ALARMS_2920"] = [
        {"alarmId": "7100|7115", "faultId": "2920"}
    ]

    var_dict["MASTER_EXPECTED_ALARMS_4680"] = [
        {"alarmId": "7100|7115", "faultId": "4680"}
    ]

    var_dict["MASTER_IGNORED_ALARMS"] = [
        {"alarmId": "7222", "faultId": "9000"}
    ] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["SLAVE_EXPECTED_ALARMS_2919"] = [
        {"alarmId": "7100|7115", "faultId": "2919"}
    ]

    var_dict["SLAVE_EXPECTED_ALARMS_2920"] = [
        {"alarmId": "7100|7115", "faultId": "2920"}
    ]

    var_dict["SLAVE_EXPECTED_ALARMS_4680"] = [
        {"alarmId": "7100|7115", "faultId": "4680"}
    ]

    var_dict["SLAVE_IGNORED_ALARMS"] = [
        {"alarmId": "7222", "faultId": "9000"}
    ] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["MASTER_CRITICAL_ALARMS"] = [] + SBTS_TEMP_CRITICAL_ALARMS

    var_dict["SLAVE_CRITICAL_ALARMS"] = [] + SBTS_TEMP_CRITICAL_ALARMS

    return var_dict


test_alarms_list = _build_variable_list()
