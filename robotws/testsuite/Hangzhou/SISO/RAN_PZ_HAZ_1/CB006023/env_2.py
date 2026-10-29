import sys
from taf.ul.alarms_watchdog import Alarm
UE_INFO = [
    {
        "TYPE": "UE",
        "MODEL": "askey",
        "UE_ID":  "0",
        "BAND": "41",
        "NETWORK_TYPE": "SA,NSA",
        "STATUS": "Enabled",
        "ALL_CELL_BARRED": True,
    },
    {
        "TYPE": "CPE",
        "MODEL": "Gemtek",
        "UE_ID": "NA",
        "BAND": "41",
        "NETWORK_TYPE": "4G",
        "IP": "192.168.1.11",
        "LAN_IP": "192.168.1.2",
        "STATUS": "Enabled",
        "DMZ": "no",
    },
]

FW_INFO = {
    "TYPE": "CALIENT",
    "IP": "10.108.151.115",
    "USERNAME": "admin",
    "PASSWORD": "pxc***",
    "BBU_PORT": "3.6.1,3.6.3,3.7.1,3.3.1",
}

ADDITIONAL_ALLOWED_ALARMS = [
    Alarm(
        fault_name="Sanity Check Error",
        severity="Minor",
        reason="Failed sanity check point results:/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/"
               "APEQM_R-1/CABINET_R-1/SMOD_R-1:{1b,4,5a,5b}",
    ),
    Alarm(
        fault_name="Sanity Check Error",
        severity="Minor",
        reason="Failed sanity check point results:/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/"
               "APEQM_R-1/CABINET_R-1/SMOD_R-1:{1b,4,5a}",
    ),
    Alarm(
        fault_name="Sanity Check Error",
        severity="Minor",
        reason="Failed sanity check point results:/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/"
               "APEQM_R-1/CABINET_R-1/SMOD_R-1:{1b,4,5b}",
    ),
    Alarm(
        fault_name="Sanity Check Error",
        severity="Minor",
        fault_id="4681",
    ),
    Alarm(
        fault_name="Transmission path failure",
        severity="Minor",
        reason="Affected Antenna line: MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-5/ANTL_R-3",
    ),
    Alarm(
        fault_name="Transmission path failure",
        severity="Minor",
        reason="Affected Antenna line: MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-5/ANTL_R-1",
    ),
    Alarm(
        fault_name="Transmission path failure",
        severity="Minor",
        reason="Affected Antenna line: MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-5/ANTL_R-5",
    ),
    Alarm(
        fault_name="Unstable eCPRI Link Detected",
        severity="Minor",
        fault_id="4741",
    ),
]
DEFAULT_ADDITIONAL_ALLOWED_ALARMS = [
    Alarm(
        fault_name="Sanity Check Error",
        severity="Minor",
        reason="Failed sanity check point results:/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/"
               "APEQM_R-1/CABINET_R-1/SMOD_R-1:{1b,4,5a,5b}",
    ),
    Alarm(
        fault_name="Sanity Check Error",
        severity="Minor",
        reason="Failed sanity check point results:/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/"
               "APEQM_R-1/CABINET_R-1/SMOD_R-1:{1b,4,5a}",
    ),
    Alarm(
        fault_name="Sanity Check Error",
        severity="Minor",
        reason="Failed sanity check point results:/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/"
               "APEQM_R-1/CABINET_R-1/SMOD_R-1:{1b,4,5b}",
    ),
    Alarm(
        fault_name="Sanity Check Error",
        severity="Minor",
        fault_id="4681",
    ),
    Alarm(
        fault_name="Unstable eCPRI Link Detected",
        severity="Minor",
        fault_id="4741",
    ),
]
SUPPORTED_CALL = False

tl_config = sys.modules[__name__]
