import taf
from taf.ul.alarms_watchdog import Alarm

# Allowed Allarms for CRT Tests used with taf.ul.alarms.watchdog library
CRT_ALLOWED_ALARMS = [
    Alarm(fault_name="LMP access via port"),
    Alarm(fault_name="SSH enabled"),
    Alarm(fault_name="User Account has Default Password"),
    Alarm(fault_name="R&D Service Port enabled"),
    Alarm(fault_name="Temp Fault1"),
    Alarm(fault_name="LMP access via port 443"),
    Alarm(fault_name="LMP access via port 3600"),
    Alarm(fault_name="BTS Reset Cause"),
    Alarm(fault_name="Service account root access is enabled"),
    Alarm(fault_name="Ethernet port security is disabled"),
    Alarm(fault_name="Setup of X2 connectivity to gNB failed", fault_id="6327"),
    Alarm(fault_name="No X2 link available", fault_id="7300"),
    Alarm(fault_name="No Xn link available", fault_id="7311"),
    Alarm(fault_name="No X2 link available for a specific LTEENB", fault_id="7319"),
    Alarm(fault_name="Failure in connection to Real-time PM Collection Entity", fault_id="4203"),
    Alarm(fault_name="Serial console activated", fault_id="4334"),
    Alarm(
        fault_name="Sanity Check Error",
        severity="Minor",
        reason="Failed sanity check point results: /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/"
               "APEQM_R-1/CABINET_R-1/SMOD_R-1:{2}",
    ),
    Alarm(
        fault_name="Sanity Check Error",
        severity="Minor",
        reason="Failed sanity check point results: /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/"
               "APEQM_R-1/CABINET_R-1/SMOD_R-1:{1b}",
    ),
    Alarm(
        fault_name="Sanity Check Error",
        severity="Minor",
        reason="Failed sanity check point results: /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/"
               "APEQM_R-1/CABINET_R-1/SMOD_R-1:{1b, 2}",
    ),
    Alarm(
        fault_name="Sanity Check Error",
        severity="Major",
        reason="Failed sanity check point results: /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/"
               "APEQM_R-1/CABINET_R-1/SMOD_R-1:{1a}",
    ),
    Alarm(
        fault_name="Sanity Check Error",
        severity="Major",
        reason="Failed sanity check point results: /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/"
               "APEQM_R-1/CABINET_R-1/SMOD_R-1:{1a, 2}",
    ),
    Alarm(
        fault_name="Sanity Check Error",
        severity="Major",
        reason="Failed sanity check point results: /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/"
               "APEQM_R-1/CABINET_R-1/SMOD_R-1:{1a, 1b}",
    ),
    Alarm(
        fault_name="Sanity Check Error",
        severity="Major",
        reason="Failed sanity check point results: /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/"
               "APEQM_R-1/CABINET_R-1/SMOD_R-1:{1a, 1b, 2}",
    ),
    Alarm(
        fault_name="Sanity Check Error",
        severity="Minor",
        reason="Failed sanity check point results: /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/"
               "APEQM_R-1/CABINET_R-1/SMOD_R-1:{2}",
    ),
    Alarm(
        fault_name="Sanity Check Error",
        severity="Minor",
        reason="Failed sanity check point results: /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/"
               "APEQM_R-1/CABINET_R-1/SMOD_R-1:{1b}",
    ),
    Alarm(
        fault_name="Sanity Check Error",
        severity="Minor",
        reason="Failed sanity check point results: /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/"
               "APEQM_R-1/CABINET_R-1/SMOD_R-1:{1b, 2}",
    ),
    Alarm(
        fault_name="Sanity Check Error",
        severity="Major",
        reason="Failed sanity check point results: /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/"
               "APEQM_R-1/CABINET_R-1/SMOD_R-1:{1a}",
    ),
    Alarm(
        fault_name="Sanity Check Error",
        severity="Major",
        reason="Failed sanity check point results: /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/"
               "APEQM_R-1/CABINET_R-1/SMOD_R-1:{1a, 2}",
    ),
    Alarm(
        fault_name="Sanity Check Error",
        severity="Major",
        reason="Failed sanity check point results: /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/"
               "APEQM_R-1/CABINET_R-1/SMOD_R-1:{1a, 1b}",
    ),
    Alarm(
        fault_name="Sanity Check Error",
        severity="Major",
        reason="Failed sanity check point results: /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/"
               "APEQM_R-1/CABINET_R-1/SMOD_R-1:{1a, 1b, 2}",
    ),
    Alarm(
        fault_name="Sanity Check Error",
        severity="Warning",
        fault_id="4681"),
    Alarm(
        fault_name="Diagnostic Check Error",
        fault_id="4681")
]


def add_crt_allowed_alarms(base_alarms, list_of_allowed_alarms=None):
    if list_of_allowed_alarms:
        for item in list_of_allowed_alarms:
            valid_keys = {"alarm_id", "fault_id", "fault_name", "severity", "reason"}
            alarm_args = {key: str(item[key]) for key in valid_keys if key in item}
            base_alarms.append(taf.ul.alarms_watchdog.alarm.Alarm(**alarm_args))


def del_crt_allowed_alarms(base_alarms, list_of_allowed_alarms=None):
    if list_of_allowed_alarms:
        for item in list_of_allowed_alarms:
            valid_keys = {"alarm_id", "fault_id", "fault_name", "severity", "reason"}
            alarm_args = {key: str(item[key]) for key in valid_keys if key in item}
            base_alarms.remove(taf.ul.alarms_watchdog.alarm.Alarm(**alarm_args))
