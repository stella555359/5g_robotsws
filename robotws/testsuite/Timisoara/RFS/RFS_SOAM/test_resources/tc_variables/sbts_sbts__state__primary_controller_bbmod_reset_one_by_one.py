from temporary_alarms_definition import *


def _build_variable_list():
    var_dict = {}

    var_dict["SBTS_MASTER_EXPECTED_ALARMS_10"] = [{"alarmId": "7116", "faultId": "10"}]

    var_dict["SBTS_MASTER_EXPECTED_ALARMS_10_1815"] = [
        {"alarmId": "7116", "faultId": "10|1815"}
    ]

    var_dict["SBTS_MASTER_EXPECTED_ALARMS_16"] = [{"alarmId": "7116", "faultId": "16"}]

    var_dict["SBTS_MASTER_IGNORED_ALARMS_CNI_127210"] = [
        {"alarmId": "7222", "faultId": "9000"}
    ] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["SBTS_MASTER_IGNORED_ALARMS_NO_CNI_127210"] = (
        [{"alarmId": "7222", "faultId": "9000"}]
        + SBTS_TEMP_IGNORED_ALARMS
        + ADMIN_ADDITIONAL_COMMON_IGNORED_ALARMS_NO_CNI_127210
    )

    var_dict["SBTS_SLAVE_EXPECTED_ALARMS_10"] = [{"alarmId": "7116", "faultId": "10"}]

    var_dict["SBTS_SLAVE_EXPECTED_ALARMS_10_1815"] = [
        {"alarmId": "7116", "faultId": "10|1815"}
    ]

    var_dict["SBTS_SLAVE_EXPECTED_ALARMS_16"] = [{"alarmId": "7116", "faultId": "16"}]

    var_dict["SBTS_SLAVE_IGNORED_ALARMS_CNI_127210"] = [
        {"alarmId": "7222", "faultId": "9000"}
    ] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["SBTS_SLAVE_IGNORED_ALARMS_NO_CNI_127210"] = (
        [{"alarmId": "7222", "faultId": "9000"}]
        + SBTS_TEMP_IGNORED_ALARMS
        + ADMIN_ADDITIONAL_COMMON_IGNORED_ALARMS_NO_CNI_127210
    )

    var_dict["SBTS_MASTER_CRITICAL_ALARMS"] = [] + SBTS_TEMP_CRITICAL_ALARMS

    var_dict["SBTS_SLAVE_CRITICAL_ALARMS"] = [] + SBTS_TEMP_CRITICAL_ALARMS

    var_dict["MASTER_ALARMS_CNI_127210"] = {
        "SBTS_MASTER_IGNORED_ALARMS": "SBTS_MASTER_IGNORED_ALARMS_CNI_127210"
    }

    var_dict["MASTER_ALARMS_NO_CNI_127210"] = {
        "SBTS_MASTER_IGNORED_ALARMS": "SBTS_MASTER_IGNORED_ALARMS_NO_CNI_127210"
    }

    var_dict["SLAVE_ALARMS_CNI_127210"] = {
        "SBTS_SLAVE_IGNORED_ALARMS": "SBTS_SLAVE_IGNORED_ALARMS_CNI_127210"
    }

    var_dict["SLAVE_ALARMS_NO_CNI_127210"] = {
        "SBTS_SLAVE_IGNORED_ALARMS": "SBTS_SLAVE_IGNORED_ALARMS_NO_CNI_127210"
    }

    return var_dict


test_alarms_list = _build_variable_list()
