from temporary_alarms_definition import *


def _build_variable_list():
    var_dict = {}

    var_dict["MASTER_IGNORED_ALARMS"] = [] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["SLAVE_IGNORED_ALARMS"] = [] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["SLAVE1_IGNORED_ALARMS"] = [] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["SLAVE2_IGNORED_ALARMS"] = [] + SBTS_TEMP_IGNORED_ALARMS

    var_dict["MASTER_CRITICAL_ALARMS"] = [] + SBTS_TEMP_CRITICAL_ALARMS

    var_dict["SLAVE_CRITICAL_ALARMS"] = [] + SBTS_TEMP_CRITICAL_ALARMS

    var_dict["SLAVE1_CRITICAL_ALARMS"] = [] + SBTS_TEMP_CRITICAL_ALARMS

    var_dict["SLAVE2_CRITICAL_ALARMS"] = [] + SBTS_TEMP_CRITICAL_ALARMS

    return var_dict


test_alarms_list = _build_variable_list()
