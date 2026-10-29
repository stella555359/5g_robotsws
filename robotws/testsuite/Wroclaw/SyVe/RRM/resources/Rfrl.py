from robot.libraries.BuiltIn import BuiltIn
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.Troubleshooting import Troubleshooting

RFRL_RESOURCE = 'taf/rfrl/common_resources/common_step/interface.robot'
COMMON_KEYWORD = "interface.Common step trigger"


class Rfrl(object):

    @staticmethod
    def common_step_trigger():
        Troubleshooting().freeze_test_line_for_task_force_if_forbidden_faults_or_connectivity_problems_detected()
        if not Env().is_trunk_sw_under_test():
            return
        try:
            Logger.info("Executing RFRL common step: {}".format(COMMON_KEYWORD))
            BuiltIn().import_resource(RFRL_RESOURCE)
            BuiltIn().run_keyword(COMMON_KEYWORD)
        except Exception as rfrl_error:
            Logger.warning("Something went wrong with {} library and {} keyword.\n"
                           "The resource fails with error:{}".format(RFRL_RESOURCE, COMMON_KEYWORD, rfrl_error))
