"""
:copyright: Nokia Networks
:author: Karolina Sroczyk <karolina.sroczyk@nokia.com>
:maintainer: Karolina Sroczyk <karolina.sroczyk@nokia.com>, Konrad Krzyzak <konrad.krzyzak@nokia.com>
"""

from robot.libraries.BuiltIn import BuiltIn
from robot.api.deco import keyword


def get_active_alarms_from_bts():
    from ute_admin import ute_admin
    try:
        ute_admin = ute_admin()
        ute_admin.setup_admin(bts_host="192.168.255.1", bts_port=443, use_ssl=True)
        alarms = ute_admin.get_active_alarms()
    finally:
        ute_admin.teardown_admin()
    return alarms


@keyword("Verify that alarm ${faultId} with ${faultName} fault is active for AMF${amf_id}")
def verify_that_alarm_is_active(faultId, faultName, amf_id):
    alarms = get_active_alarms_from_bts()
    for alarm in alarms:
        _faultId = alarm['faultId']
        _faultName = alarm['faultName']
        _faultObject = alarm['configObjectName'][-11:]
        _expectedfaultObject = 'SERVEDAMF-' + amf_id
        BuiltIn().log("ALARM: faultID:{}, faultName:{}, "
                      "faultObject:{}".format(_faultId, _faultName, _faultObject))
        if(_faultId == int(faultId)) and (_faultName == faultName) and (_faultObject == _expectedfaultObject):
            BuiltIn().log("Expected alarm raised!")
            return True
    raise Exception("Expected alarm: faultID:{}, faultName:{}, faultObject:{} "
                    "not raised!".format(faultId, faultName, _expectedfaultObject))
