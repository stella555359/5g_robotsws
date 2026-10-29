import os
import re
import time
from ta_emss import ta_emss
from taf.sbts.oam.coam.admin import admin
from contextlib import contextmanager


emss = ta_emss(host='10.0.1.1', port=4001)


@contextmanager
def admin_connection():
    try:
        admin_api = admin()
        adminconnection = admin_api.connect_to()
        yield adminconnection
    finally:
        admin_api.teardown_admin(connection=adminconnection)


# USage example from upper master python
# --------------------------------------
# try:
#     alarms_handler.almw.allow_alarm(alarm_id="7116", fault_id="10", fault_name="No connection to unit")
#     alarms_handler.almw.wait_for_active_alarm(alarm_id="7116", fault_id="10", fault_name="No connection to unit",
#                                           timeout="10min")
# except AlarmInactive:
#    pass
# else:
#    with admin_connection() as adminconn:
#         alarms_handler.almw.allow_alarm(alarm_id="7115", fault_id="4592", fault_name="BTS Reset Cause")
#         alarms_handler.adminconn.reset(reset_coverage="Site", wait_for_reconnection=False, timeout=600)
#
# alarms_handler.almw.check_detected_alarms()
#
# emss_handler.emss.wait_for_object_attribute_value(object_name="RMOD_R-4-1-1", attribute_name="operationalState",
#                                                  value="enabled", timeout=600)
# emss_handler.emss.wait_for_object_attribute_value(object_name="RMOD_R-4-1-2", attribute_name="operationalState",
#                                                  value="enabled", timeout=600)
# emss_handler.emss.wait_for_object_attribute_value(object_name="RMOD_R-4-1-3", attribute_name="operationalState",
#                                                  value="enabled", timeout=600)
# emss_handler.emss.wait_for_object_attribute_value(object_name="RMOD_R-4-1-4", attribute_name="operationalState",
#                                                  value="enabled", timeout=600)
# emss_handler.emss.wait_for_enb_on_air()
# alarms_handler.almw.check_detected_alarms()
