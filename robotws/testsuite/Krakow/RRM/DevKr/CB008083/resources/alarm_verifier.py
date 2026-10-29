from robot.libraries.BuiltIn import BuiltIn
from taf.sbts.oam.coam.admin import admin
from robot.api.deco import keyword


def get_active_alarms_from_bts():
    api = admin()
    try:
        api.connect_to()
        alarms = api.get_active_alarms()
    finally:
        api.teardown()
    return alarms


@keyword("Verify that fault ${fault_id} is raised for AMF${amf_id}")
def verify_that_alarm_is_active(fault_id, amf_id):
    alarms = get_active_alarms_from_bts()
    expected_fault_object = 'SERVEDAMF-' + amf_id
    for alarm in alarms:
        if alarm['faultId'] == int(fault_id):
            fault_object = alarm['configObjectName'][-11:]
            BuiltIn().log("ALARM: faultID:{}, faultObject:{}".format(fault_id, fault_object))
            if fault_object == expected_fault_object:
                BuiltIn().log("Expected alarm raised!")
                return True
    raise Exception("Alarm: faultID:{} not raised for AMF{}!".format(fault_id, amf_id))
