import sys
from taf.ul.alarms_watchdog import Alarm
UE_INFO = [
    {
        "TYPE": "SISO_UE",
        "MODEL": "andriod_phone",
        "SUB_MODEL": "Huawei P40",
        "UE_ID": "0",
        "BAND": "8,3,1",
        "NETWORK_TYPE": "4G",
        "STATUS": "Enabled",
        "APN": "stdata1",
        "RESET": False,
    },
]
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
]

FW_INFO = {
    'TYPE': 'GG',
    'IP': '10.69.64.240',
    'USERNAME': 'admin',
    'PASSWORD': 'password',
    'BBU_PORT': "5:15;6:17;7:14;8:16"
}

tl_config = sys.modules[__name__]
