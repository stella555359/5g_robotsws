from tc_specific_alarms import *
from robot.libraries.BuiltIn import BuiltIn


class ClassicalBts:
    def __init__(self):
        self.cu = CU()


class CU:
    def __init__(self):
        self.oam_http_connection_details = OAM()


class OAM:
    def __init__(self):
        self.addr = '192.168.255.129'
        self.port = 443
        self.username = 'Nemuadmin'
        self.password = 'nemuuser'


def set_tc_specific_alarms(tc_name):
    for key in tc_specific_alarms[tc_name]:
        BuiltIn().set_test_variable('${var_name}'.format(var_name=key),
                                    tc_specific_alarms[tc_name][key])
    BuiltIn().set_test_variable('${var_name}'.format(var_name='TC_SPECIFIC_ALARMS'),
                                tc_specific_alarms[tc_name])


def set_connection_parameters_for_alarm_watchdog():
    conn_param_alarm_watchdog = ClassicalBts()
    BuiltIn().set_test_variable('${var_name}'.format(var_name='conn_param_alarm_watchdog'), conn_param_alarm_watchdog)
