"""
:copyright: Nokia Networks
:author: Damian Zak, Mateusz Iwankiewicz, Aleksander Gospodarczyk
:maintainer: Damian Zak
:contact: damian.zak@nokia.com,  mateusz.iwankiewicz@nokia.com, aleksander.gospodarczyk@nokia.com
:team: MN_RAN_RD_VRF_KRK_11, MN_RAN_RD_VRF_KRK_8
"""
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.bts.devices.du.du_operations import GenericDuOperations

from testsuite.Krakow.OAM.regression.RAN_PZ_KRK8.OAM_KPI.resources.variables import *


class SuccesRateValidationFail(Exception):
    pass


def set_hw_release_target_kpi():
    generic_du_operations = GenericDuOperations(bts_type="GNB")
    bts_info = generic_du_operations.get_bts_info()
    sw_release = generic_du_operations.get_bts_sw_release_name()

    hw_type = bts_info["basebandModules"][0]["productName"].split()[0]
    test_sw_release = "SBTS00" if sw_release == "SBTS26R3" else sw_release

    config_type_map = {
        "ABIL": "CNF_5G_3_TARGETS",
        "ABIO": "CNF_5G_18b_TARGETS",
        "ABIP": "CNF_5G_32_TARGETS"
    }

    config_type = config_type_map.get(hw_type)

    if config_type:
        BuiltIn().set_suite_variable("${TEST_TARGETS}", TARGETS[config_type][test_sw_release])


def success_ratio_validation():
    test_name = BuiltIn().get_variable_value("${TEST NAME}")

    test_variable_mapping = {
        "Gen5_OAM_KPI_61a_Site_Reset_Startup_Success_Rate":
            "${Gen5_OAM_KPI_1a_Site_Reset_Outage_Duration_Single_Core_TEST_STATUS}",
        "Gen5_OAM_KPI_63_Power_Reset_Startup_Success_Rate":
            "${Gen5_OAM_KPI_3_Power_Reset_Outage_Duration_Single_Core_TEST_STATUS}",
        "Gen5_OAM_KPI_651_RU_Reset_Startup_Success_Rate":
            "${Gen5_OAM_KPI_51a_RU_Reset_Time_TEST_STATUS}",
        "Gen7_OAM_KPI_61a_Site_Reset_Startup_Success_Rate":
            "${Gen7_OAM_KPI_1a_Site_Reset_Outage_Duration_Single_Core_TEST_STATUS}",
        "Gen7_OAM_KPI_63_Power_Reset_Startup_Success_Rate":
            "${Gen7_OAM_KPI_3_Power_Reset_Outage_Duration_Single_Core_TEST_STATUS}",
        "Gen7_OAM_KPI_651_RU_Reset_Startup_Success_Rate":
            "${Gen7_OAM_KPI_51a_RU_Reset_Time_TEST_STATUS}"
    }

    try:
        test_status_variable = test_variable_mapping[test_name]
    except KeyError:
        raise SuccesRateValidationFail("Success ratio validation function used in wrong testcase")

    test_status = BuiltIn().get_variable_value(test_status_variable)

    if test_status == "PASS":
        BuiltIn().log_to_console("Success Rate validation success")
    else:
        raise SuccesRateValidationFail()
