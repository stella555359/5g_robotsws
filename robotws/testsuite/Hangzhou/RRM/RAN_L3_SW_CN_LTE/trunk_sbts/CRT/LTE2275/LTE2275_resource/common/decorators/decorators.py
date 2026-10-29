from testsuite.Hangzhou.RRM.RAN_L3_SW_CN_LTE.trunk_sbts.CRT.LTE2275.LTE2275_resource.\
    common.robot_managment import *
from robot.api import logger


def ue_enabled(func):
    def wrapped(*args, **kwargs):
        use_ue = robot_get_variable('enable_ue', default='True')
        use_ue = True if use_ue == 'True' else False
        if use_ue is True:
            return func(*args, **kwargs)
        else:
            return
    return wrapped


def dpc_implemented(func):
    def wrapped(*args, **kwargs):
        use = robot_get_variable('enable_dpc', default='True')
        use = True if use == 'True' else False
        if use is True:
            return func(*args, **kwargs)
        else:
            try:
                return func(*args, **kwargs)
            except Exception as e:
                logger.warn(e.message)

    return wrapped
