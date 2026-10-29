"""
:copyright: Nokia Networks
:author: Paulina Jedras <paulina.jedras@nokia.com>
:maintainer: Paulina Jedras <paulina.jedras@nokia.com>
"""

from robot.libraries.BuiltIn import BuiltIn
from robot.api.deco import keyword
from testsuite.Krakow.RRM.resources.Python.admin_cli import setup_and_teardown_admin_connection_if_needed, api


@keyword("Verify that fault ${fault_id} is raised for ${expected_object}")
@setup_and_teardown_admin_connection_if_needed
@api.lookup_handler.implicit_lookup
def verify_that_alarm_is_active(fault_id, expected_object, connection=None):
    alarms = connection.get_active_alarms()
    BuiltIn().log("Received alarms: {}".format(alarms))
    for alarm in alarms:
        if alarm['faultId'] == int(fault_id):
            fault_object = alarm['configObjectName']
            BuiltIn().log("ALARM: faultID:{}, faultObject:{}".format(fault_id, fault_object))
            if expected_object in fault_object:
                BuiltIn().log("Expected alarm raised!")
                return True
    raise Exception("Alarm: faultID:{}, faultObject:{} not raised!".format(fault_id, expected_object))
