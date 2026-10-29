from temporary_alarms_definition import *


def _build_variable_list():
    var_dict = {}

    var_dict["MASTER_CU_EXPECTED_ALARMS"] = []

    var_dict["MASTER_CU_IGNORED_ALARMS"] = [] + CBTS_CU_TEMP_IGNORED_ALARMS

    var_dict["MASTER_CU_CRITICAL_ALARMS"] = [] + CBTS_CU_TEMP_CRITICAL_ALARMS

    var_dict["MASTER_VDU1_EXPECTED_ALARMS_10"] = [
        {"alarm_id": "711[5,6]", "fault_id": "10"}
    ]

    var_dict["MASTER_VDU1_EXPECTED_ALARMS_16"] = [
        {"alarm_id": "71[0,1][1,5,6]", "fault_id": "16"}
    ]

    var_dict["MASTER_VDU1_IGNORED_ALARMS"] = [] + CBTS_VDU_TEMP_IGNORED_ALARMS

    var_dict["MASTER_VDU1_CRITICAL_ALARMS"] = [] + CBTS_VDU_TEMP_CRITICAL_ALARMS

    var_dict["SLAVE_EXPECTED_ALARMS_10_1815"] = [
        {"alarmId": "71[0,1][5,6]", "faultId": "10|1815"}
    ]

    var_dict["SLAVE_EXPECTED_ALARMS_16"] = [
        {"alarmId": "71[0,1][1,5,6]", "faultId": "16"}
    ]

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
