# from ta_emss import ta_emss    # DTN250225 : COMMENTED FOR DEBUG
import os
import re
# from zipfile import ZipFile    # DTN250225 : COMMENTED FOR DEBUG
import time
# from taf.sbts.oam.coam.admin import admin   # DTN250225 : COMMENTED FOR DEBUG
from robot.libraries.BuiltIn import BuiltIn
from contextlib import contextmanager
from taf.ul.alarms_watchdog.exceptions import AlarmInactive
from taf.ul.alarms_watchdog import alarms_watchdog

# emss = ta_emss(host='10.0.1.1', port=4001)  # DTN250225 : COMMENTED FOR DEBUG
almw = BuiltIn().get_library_instance("alarms_watchdog")
# alarms_watchdog = BuiltIn().get_library_instance("alarms_watchdog")


@contextmanager
def admin_connection():
    try:
        admin_api = admin()
        adminconnection = admin_api.connect_to()
        yield adminconnection
    finally:
        admin_api.teardown_admin(connection=adminconnection)


def allowed_alarms_before_precondition():
    # To be allow anytime
    almw.allow_alarm(alarm_id="7220", fault_id="61524", fault_name="SSH enabled")
    almw.allow_alarm(alarm_id="7220", fault_id="61649", fault_name="LMP access via port 443")
    almw.allow_alarm(alarm_id="7220", fault_id="61652", fault_name="R&D Service Port enabled")
    almw.allow_alarm(alarm_id="7220", fault_id="4654", fault_name="Ethernet port security is disabled")
    almw.allow_alarm(alarm_id="7220", fault_id="4655", fault_name="Service account root access is enabled")
    almw.allow_alarm(alarm_id="61641", fault_id="61641")
    almw.allow_alarm(alarm_id="7115", fault_id="4681", fault_name="Diagnostic Check Error")
    almw.allow_alarm(alarm_id="7115", fault_id="6450", fault_name="Diagnostic files collected")
    almw.allow_alarm(alarm_id="7107", fault_id="7319",
                     fault_name="No X2 link available for a specific LTEENB")
    almw.allow_alarm(alarm_id="7107", fault_id="7300", fault_name="No X2 link available")

    # BHR begin 02/03/2025: DEBUG PURPOSE New alarms filtered detection added, but to be investigated
    almw.allow_alarm(alarm_id="7220", fault_id="4459", fault_name="User Account has Default Password")
    almw.allow_alarm(alarm_id="7220", fault_id="61510",
                     fault_name="Automatic BTS Operator Certificate retrieval unsuccessful")
    almw.allow_alarm(alarm_id="7115", fault_id="8000",
                     fault_name="Failure in connection between BTS and 3rd party tool")

    # To be disallow after precondition
    almw.allow_alarm(alarm_id="7115", fault_id="4592", fault_name="BTS Reset Cause")
    almw.allow_alarm(alarm_id="7115", fault_id="7523", fault_name="Cell Activation timeout at gNB-DU")
    almw.allow_alarm(alarm_id="7107", fault_id="7305", fault_name="NG SCTP setup fail")
    almw.allow_alarm(alarm_id="7107", fault_id="7308",
                     fault_name="Transport layer connection failure in X2 interface")
    almw.allow_alarm(alarm_id="7114", fault_id="7107", fault_name="Cell problem due to associated X2 links "
                     "and/or NG links and/or E1 link unavailability")
    almw.allow_alarm(alarm_id="7115", fault_id="4590", fault_name="Fault signature for crash or failure")


def disallow_alarms_after_precondition():
    almw.disallow_alarm(alarm_id="7115", fault_id="4592", fault_name="BTS Reset Cause")
    almw.disallow_alarm(alarm_id="7115", fault_id="7523", fault_name="Cell Activation timeout at gNB-DU")
    almw.disallow_alarm(alarm_id="7107", fault_id="7305", fault_name="NG SCTP setup fail")
    almw.disallow_alarm(alarm_id="7107", fault_id="7308",
                        fault_name="Transport layer connection failure in X2 interface")
    almw.disallow_alarm(alarm_id="7114", fault_id="7107",
                        fault_name="Cell problem due to associated X2 links")
    # almw.disallow_alarm(alarm_id="7115", fault_id="4590",
    #                     fault_name="Fault signature for crash or failure")
    almw.check_detected_alarms()
