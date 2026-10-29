import sys

UE_INFO = [
    {
        "TYPE": "CPE",  # Deming/Gemtek
        "MODEL": "Gemtek",
        "BAND": "38,40,41",
        "IP": "192.168.1.5",
        "LAN_IP": "192.168.1.2",
        "DMZ": "no",
        "NETWORK_TYPE": "4G",
        "STATUS": "Enabled"
    },
    {
        "TYPE": "CPE",  # Deming/Gemtek
        "MODEL": "Gemtek",
        "BAND": "42",
        "IP": "192.168.1.6",
        "LAN_IP": "192.168.1.221",
        "DMZ": "no",
        "NETWORK_TYPE": "4G",
        "STATUS": "Enabled"
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

BTS_RELATED_PARAMETER = {
    "ONAIR_TIME": "15 min"
}

SW_BUILDS_DIR_PATH = "/home/ute/Downloads/"

TESTLINE_TYPE = "FlexibleShare"
REQUIRE_PACKAGES = "Active"

ALLOWED_ALARMS = ['Vendor BTS certificate',
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

tl_config = sys.modules[__name__]
