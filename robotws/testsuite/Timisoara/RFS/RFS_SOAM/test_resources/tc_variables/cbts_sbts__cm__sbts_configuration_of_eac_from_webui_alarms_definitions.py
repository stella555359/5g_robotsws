from temporary_alarms_definition import *


def _build_variable_list():
    var_dict = {}

    var_dict["MASTER_CU_EXPECTED_ALARMS"] = []

    var_dict["MASTER_CU_IGNORED_ALARMS"] = [] + CBTS_CU_TEMP_IGNORED_ALARMS

    var_dict["MASTER_CU_CRITICAL_ALARMS"] = [] + CBTS_CU_TEMP_CRITICAL_ALARMS

    var_dict["MASTER_VDU1_EXPECTED_ALARMS_1400"] = [
        {"alarm_id": "7103", "fault_id": "1400", "severity": "minor"}
    ]

    var_dict["MASTER_VDU1_EXPECTED_ALARMS_1401"] = [
        {"alarm_id": "7103", "fault_id": "1401", "severity": "major"}
    ]

    var_dict["MASTER_VDU1_EXPECTED_ALARMS_1402"] = [
        {"alarm_id": "7103", "fault_id": "1402", "severity": "critical"}
    ]

    var_dict["MASTER_VDU1_EXPECTED_ALARMS_1403"] = [
        {"alarm_id": "7103", "fault_id": "1403", "severity": "minor"}
    ]

    var_dict["MASTER_VDU1_EXPECTED_ALARMS_1404"] = [
        {"alarm_id": "7103", "fault_id": "1404", "severity": "major"}
    ]

    var_dict["MASTER_VDU1_EXPECTED_ALARMS_1405"] = [
        {"alarm_id": "7103", "fault_id": "1405", "severity": "critical"}
    ]

    var_dict["MASTER_VDU1_EXPECTED_ALARMS_1406"] = [
        {"alarm_id": "7103", "fault_id": "1406", "severity": "minor"}
    ]

    var_dict["MASTER_VDU1_EXPECTED_ALARMS_1407"] = [
        {"alarm_id": "7103", "fault_id": "1407", "severity": "major"}
    ]

    var_dict["MASTER_VDU1_IGNORED_ALARMS"] = [] + CBTS_VDU_TEMP_IGNORED_ALARMS

    var_dict["MASTER_VDU1_CRITICAL_ALARMS"] = [] + CBTS_VDU_TEMP_CRITICAL_ALARMS

    var_dict["SLAVE_IGNORED_ALARMS_NO_CNI_127210"] = (
        [{"alarmId": "7222", "faultId": "9000"}]
        + SBTS_TEMP_IGNORED_ALARMS
        + ADMIN_ADDITIONAL_COMMON_IGNORED_ALARMS_NO_CNI_127210
    )

    var_dict["SLAVE_IGNORED_ALARMS_CNI_127210"] = [
        {"alarmId": "7222", "faultId": "9000"}
    ] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["SLAVE_CRITICAL_ALARMS"] = [] + SBTS_TEMP_CRITICAL_ALARMS

    var_dict["SLAVE_ALARMS_CNI_127210"] = {
        "SLAVE_IGNORED_ALARMS": "SLAVE_IGNORED_ALARMS_CNI_127210"
    }

    var_dict["SLAVE_ALARMS_NO_CNI_127210"] = {
        "SLAVE_IGNORED_ALARMS": "SLAVE_IGNORED_ALARMS_NO_CNI_127210"
    }

    return var_dict


test_alarms_list = _build_variable_list()
