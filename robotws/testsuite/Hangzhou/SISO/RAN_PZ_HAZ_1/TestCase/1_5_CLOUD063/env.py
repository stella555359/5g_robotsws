import sys

# ALLOWED_ALARMS = ['Vendor BTS certificate',
#                   'Synchronization lost',
#                   'Diagnostic Files collected',
#                   'BTS booted at .*? due to trs management reset',
#                   '.*? ToP master service .*? unusable',
#                   'NTP Server .*?',
#                   'BTS time not corrected',
#                   'SSH enabled',
#                   'BTS Reset Cause',
#                   'R&D Service Port enabled',
#                   'LMP access via port .*?',
#                   'Ethernet port security is disabled',
#                   'Sanity Check Error',
#                   'Service account root access is enabled']
UE_INFO = [
    {
        "TYPE": "CPE",
        "MODEL": "Gemtek",
        "BAND": "42",
        "IP": "192.168.1.1",
        "LAN_IP": "192.168.1.2",
        "STATUS": "Enabled",
        "NETWORK_TYPE": "4G",
    }
]

IPERF_SERVER_INFO = {
                     "IP": "10.69.64.197",
                     "CTRL_IP": "10.69.64.196",
                     "USERNAME": "tdlte-tester",
                     "PASSWORD": "btstest",
                     "PORT": "22",
                     "LOG_PATH": "/home/tdlte-tester/UDP"
            }

FW_INFO = {
    'TYPE': 'GG',
    'IP': '10.56.7.147',
    'USERNAME': 'BTS1304',
    'PASSWORD': 'SISO1_test',
    'Model': '98',
    'BTS2160_FIBERLINKS': ['EA181213014_0=175:164'],
    }


tl_config = sys.modules[__name__]
