import sys


UE_INFO = [
    {
       "TYPE": "Nokia_CPE",
       "MODEL": "NokiaCPE31",
       "UE_ID": "0",
       "BAND": "40,41,78",
       "NETWORK_TYPE": "SA",
       "STATUS": "Enabled",
       "IP": "192.168.1.1",
       "LAN_IP": "192.168.1.126",
       "ROOT_PASSWORD": "8bfa3aa23c8e",
       "ALL_CELL_BARRED": "True",
    },
]
# SUPPORTED_CALL = False
ADDITIONAL_ALLOWED_ALARMS = [
    'Vendor BTS certificate',
    'Synchronization lost',
    'Diagnostic Files collected',
    'BTS booted at .*? due to trs management reset',
    '.*? ToP master service .*? unusable',
    'NTP Server .*? unavailable',
    'SSH enabled',
    'R&D Service Port enabled',
    'LMP access via port.*',
    'Ethernet port security is disabled',
    'Service account root access is enabled',
    'BTS Reset Cause',
    'Beamforming Calibration Detect Continuous Exception',
    'Failure in connection to Real-time PM Collection Entity',
    'Sanity Check Error'
]

SUPPORTED_CALL = False

tl_config = sys.modules[__name__]
