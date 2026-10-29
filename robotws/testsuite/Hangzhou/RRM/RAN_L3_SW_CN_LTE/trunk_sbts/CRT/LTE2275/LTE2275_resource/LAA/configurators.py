from ta_egate_cmd_parser import ta_egate_cmd_parser
from ta_emil_parser import ta_emil_parser
from testsuite.Hangzhou.RRM.RAN_L3_SW_CN_LTE.trunk_sbts.CRT.LTE2275.LTE2275_resource.\
    common.robot_managment import *
from testsuite.Hangzhou.RRM.RAN_L3_SW_CN_LTE.trunk_sbts.CRT.LTE2275.LTE2275_resource.\
    common.Logger import TestLogger

try:
    FREQ_CHANGE_VERIFICATION_TOOL = robot_get_variable(
        "check_freq_with", default="emil"
    )
except RobotNotRunningError:
    FREQ_CHANGE_VERIFICATION_TOOL = "emil"

EGATE_PARSER = ta_egate_cmd_parser()
EMIL_PARSER = ta_emil_parser(load_definition_at_init=False)

try:
    UEXGATE = BuiltIn().get_library_instance("ta_uexgate")
except RobotNotRunningError:
    UEXGATE = None

LOGGER = TestLogger()
