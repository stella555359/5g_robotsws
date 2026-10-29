from temporary_alarms_definition import *


def _build_variable_list():
    var_dict = {}

    var_dict["SBTS_MASTER_EXPECTED_ALARMS_4795"] = [
        {"alarmId": "7115|7116", "faultId": "4795"}
    ]

    var_dict["SBTS_IGNORED_ALARMS_CNI_127210"] = [
        {"alarmId": "7222", "faultId": "9000"}
    ] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["SBTS_IGNORED_ALARMS_NO_CNI_127210"] = (
        [{"alarmId": "7222", "faultId": "9000"}]
        + SBTS_TEMP_IGNORED_ALARMS
        + ADMIN_ADDITIONAL_COMMON_IGNORED_ALARMS_NO_CNI_127210
    )

    var_dict["SBTS_CRITICAL_ALARMS"] = [] + SBTS_TEMP_CRITICAL_ALARMS

    var_dict["SBTS_ALARMS_CNI_127210"] = {
        "SBTS_IGNORED_ALARMS": "SBTS_IGNORED_ALARMS_CNI_127210"
    }

    var_dict["SBTS_ALARMS_NO_CNI_127210"] = {
        "SBTS_IGNORED_ALARMS": "SBTS_IGNORED_ALARMS_NO_CNI_127210"
    }

    return var_dict


test_alarms_list = _build_variable_list()
