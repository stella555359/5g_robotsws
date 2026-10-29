from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.VcuSession import VcuAdminSession
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.VduSession import VduAdminSession


def get_alarms_summary_from_vcu(total=False):
    with VcuAdminSession() as admin:
        if total:
            return sum(admin.get_active_alarms_summary()['severity'].values())
        return admin.get_active_alarms_summary()


def get_alarms_summary_from_vdu(vdu_id=0):
    with VduAdminSession(vdu_id) as admin:
        return admin.vdu_get_active_alarms_summary()
