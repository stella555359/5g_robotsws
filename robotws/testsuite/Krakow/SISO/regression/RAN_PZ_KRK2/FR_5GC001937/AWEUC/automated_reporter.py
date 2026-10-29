"""
Author: Patryk Lamch, patryk.lamch@nokia.com
Maintainer: Patryk Lamch, patryk.lamch@nokia.com
Description: Method for adding TC_execution_id to report file
"""
from taf.sw.reporting_portal.utils.variables import get_json_env_variable_value
from taf.rfrl.common_resources.python.report_to_rep import ReportTestDataWrapper


def add_tc_exec_id_to_test(tc_exec_id):
    params = {'tc_execution_id': tc_exec_id}
    ReportTestDataWrapper().update_test_data_dictionary(params)


def is_cm_execution():
    if get_json_env_variable_value('CM_TEST_INFORMATION', dict()):
        return True
    return False
