import sys

SW_BUILDS_DIR_PATH = "/home/ute/Downloads/"

REQUIRE_PACKAGES = "Active"

ALLOWED_ALARMS = ['Vendor BTS certificate',
                  'Synchronization lost',
                  'Incompatible SW version detected',
                  'Diagnostic Files collected',
                  'BTS booted at .*? due to trs management reset',
                  '.*? ToP master service .*? unusable',
                  'NTP Server .*?',
                  'BTS time not corrected',
                  'SSH enabled',
                  'R&D Service Port enabled',
                  'LMP access via port .*?',
                  'Service account root access is enabled']


UE_INFO = [
    {
        "TYPE": "CPE",
        "MODEL": "Gemtek",
        "BAND": "40,41",
        "IP": "192.168.1.10",
        "LAN_IP": "192.168.1.2",
        "STATUS": "Enabled",
        "NETWORK_TYPE": "4G",
    }
]

IPERF_SERVER_INFO = {
                     "IP": "10.108.183.96",
                     "CTRL_IP": "10.108.184.23",
                     "USERNAME": "ute",
                     "PASSWORD": "ute",
                     "PORT": "22",
                     "LOG_PATH": "/home/ute/UDP"
            }

FW_INFO = {
    "TYPE": "GG",
    "IP": "10.56.7.147",
    "USERNAME": "BTS2482",
    "PASSWORD": "SISO1_test",
    'BBU_PORT': "24;27;45",
}

tl_config = sys.modules[__name__]
