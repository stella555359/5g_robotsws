"""
:copyright: Nokia Networks
:author: Karolina Sroczyk <karolina.sroczyk@nokia.com>; Mateusz Matusik <mateusz.matusik@nokia.com>
"""

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


@keyword("Verify that alarm ${faultId} with ${faultName} fault is active")
def verify_that_alarm_is_active(faultId, faultName):
    alarms = get_active_alarms_from_bts()
    for alarm in alarms:
        _faultId = alarm['faultId']
        _faultName = alarm['faultName']
        if (_faultId == int(faultId)) and (_faultName == faultName):
            return True
    return False


@keyword("Verify that alarm ${faultId} with ${faultName} fault is not active")
def verify_that_alarm_is_not_active(faultId, faultName):
    alarms = get_active_alarms_from_bts()
    for alarm in alarms:
        _faultId = alarm['faultId']
        _faultName = alarm['faultName']
        if (_faultId == int(faultId)) and (_faultName == faultName):
            return False
    return True
