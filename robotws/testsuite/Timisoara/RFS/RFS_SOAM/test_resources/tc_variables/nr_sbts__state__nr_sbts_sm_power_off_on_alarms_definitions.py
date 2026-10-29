from temporary_alarms_definition import *


def _build_variable_list():
    var_dict = {}

    var_dict["MASTER_EXPECTED_ALARMS"] = []

    var_dict["MASTER_EXPECTED_ALARMS_BEFORE_SBTS_SM_POWER_ON"] = [
        {"alarmId": "7107", "faultId": "7300"},
        {"alarmId": "7107", "faultId": "7319"},
    ]

    var_dict[
        "MASTER_EXPECTED_ALARMS_REFERENCE_CLOCK_MISSING_MORE_THAN_FIVE_MINUTES"
    ] = [{"alarmId": "7108", "faultId": "4153"}]

    var_dict["MASTER_EXPECTED_ALARMS_RESET_REQUIRED"] = [
        {"alarmId": "7116", "faultId": "4001"}
    ]

    var_dict["SLAVE_EXPECTED_ALARMS"] = [{"alarmId": "7107", "faultId": "6327"}]

    var_dict["SLAVE_EXPECTED_ALARMS_TEMP_RADIO_MASTER_RMOD"] = [
        {"alarmId": "7116", "faultId": "4220"}
    ]

    var_dict["MASTER_IGNORED_ALARMS_4405_NO_CNI_127210"] = [
        {"alarmId": "7115", "faultId": "4405"}
    ]

    var_dict["MASTER_IGNORED_ALARMS_4405_CNI_127210"] = [
        {"alarmId": "7115", "faultId": "4405"}
    ]

    var_dict["MASTER_IGNORED_ALARMS_NO_CNI_127210"] = (
        [{"alarmId": "7222", "faultId": "9000"}]
        + SBTS_TEMP_IGNORED_ALARMS
        + ADMIN_ADDITIONAL_COMMON_IGNORED_ALARMS_NO_CNI_127210
    )

    var_dict["MASTER_IGNORED_ALARMS_CNI_127210"] = [
        {"alarmId": "7222", "faultId": "9000"}
    ] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["SLAVE_IGNORED_ALARMS_NO_CNI_127210"] = (
        [{"alarmId": "7222", "faultId": "9000"}]
        + SBTS_TEMP_IGNORED_ALARMS
        + ADMIN_ADDITIONAL_COMMON_IGNORED_ALARMS_NO_CNI_127210
    )

    var_dict["SLAVE_IGNORED_ALARMS_CNI_127210"] = [
        {"alarmId": "7222", "faultId": "9000"}
    ] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["MASTER_ALARMS_CNI_127210"] = {
        "MASTER_IGNORED_ALARMS": "MASTER_IGNORED_ALARMS_CNI_127210",
        "MASTER_IGNORED_ALARMS_4405": "MASTER_IGNORED_ALARMS_4405_CNI_127210",
    }

    var_dict["MASTER_ALARMS_NO_CNI_127210"] = {
        "MASTER_IGNORED_ALARMS": "MASTER_IGNORED_ALARMS_NO_CNI_127210",
        "MASTER_IGNORED_ALARMS_4405": "MASTER_IGNORED_ALARMS_4405_NO_CNI_127210",
    }

    var_dict["SLAVE_ALARMS_CNI_127210"] = {
        "SLAVE_IGNORED_ALARMS": "SLAVE_IGNORED_ALARMS_CNI_127210"
    }

    var_dict["SLAVE_ALARMS_NO_CNI_127210"] = {
        "SLAVE_IGNORED_ALARMS": "SLAVE_IGNORED_ALARMS_NO_CNI_127210"
    }

    var_dict["MASTER_HISTORICAL_IGNORED_ALARMS"] = [
        {"faultId": "4590", "faultSignature": {"category": "POWER_OFF"}}
    ] + ADMIN_COMMON_IGNORED_ALARMS

    var_dict["SLAVE_HISTORICAL_IGNORED_ALARMS"] = [
        {"faultId": "4590", "faultSignature": {"category": "POWER_OFF"}}
    ] + ADMIN_COMMON_IGNORED_ALARMS

    var_dict["MASTER_CRITICAL_ALARMS"] = [] + SBTS_TEMP_CRITICAL_ALARMS

    var_dict["SLAVE_CRITICAL_ALARMS"] = [] + SBTS_TEMP_CRITICAL_ALARMS

    return var_dict


test_alarms_list = _build_variable_list()
