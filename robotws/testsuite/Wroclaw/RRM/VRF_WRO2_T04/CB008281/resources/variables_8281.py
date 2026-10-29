from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.color_log import write_mixed_line
from robot.api import logger

FIRST_CELL = 2
SECOND_CELL = 1

COUNTER_LIST = ['M55139C04505', 'M55139C04506', 'M55139C04507', 'M55139C04508', 'M55139C04002']

ECID_COUNTER = ['M55113C00013', 'M55113C00014', 'M55113C00015', 'M55113C00016', 'M55113C00017', 'M55113C00018',
                'M55125C00024', 'M55125C00025', 'M55125C00026']


def counter_desc():
    desc = """
    M55113C00013 (Num of E-CID MEASUREMENT INITIATION REQUEST msgs)
    M55113C00014 (Num of E-CID MEASUREMENT INITIATION RESPONSE msgs)
    M55113C00015 (Num of E-CID MEASUREMENT INITIATION FAILURE msgs due to protocol error )
    M55113C00016 (Num of E-CID MEASUREMENT INITIATION FAILURE msgs "RNL: Measurement Temporarily not Available ")
    M55113C00017 (Num of E-CID MEASUREMENT INITIATION FAILURE "RNL: Measurement not Supported For The Object")
    M55113C00018 (Num of TimerF1UeProcGuard timeouts in gNB-CU due to no response)
    """
    write_mixed_line("Counters Check: [", " ECID ", "]")
    logger.console(desc)
