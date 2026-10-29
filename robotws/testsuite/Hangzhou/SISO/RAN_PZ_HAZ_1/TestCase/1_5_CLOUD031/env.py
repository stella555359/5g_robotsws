import sys

UE_INFO = [
    {
        "TYPE": "CPE",
        "MODEL": "Gemtek",
        "UE_ID": "NA",
        "BAND": "40,3",
        "NETWORK_TYPE": "4G",
        "IP": "192.168.1.10",
        "LAN_IP": "192.168.1.2",
        "DMZ": "no",
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

RF_FACTORY_SW_STORAGE = \
    {
        "L1202407675":
            {
                'LOGIN': 'siso',
                'PASSWORD': 'siso',
                'HOST_IP': '10.106.211.194',
                'SW_PATH': '/home/siso/LTE/Factory_SW/',
                'RRUpassword': 'bdS%ztWG3v7%SjreCVA79wTPb',
                'IMAGE_FILE': 'rfsw-package-aehb_0x93A24039.tar',
                'checksum': '0x93A24039',
                'fileVersion': 'CHB01.02.R03',
                'BuildName': 'rfsw-package-aehb_0x93A24039.tar',
                'BuildVersion': 'CHB01.02.R03'
            }
    }

SUPPORTED_CALL = False

ADDITIONAL_ADMIN_ALLOWED_ALARMS = \
    [
        'Vendor BTS certificate',
        'Synchronization lost',
        'Diagnostic Files collected',
        'BTS booted at .*? due to trs management reset',
        '.*? ToP master service .*? unusable',
        'NTP Server .*?',
        'BTS time not corrected',
        'SSH enabled',
        'R&D Service Port enabled',
        'LMP access via port .*?',
        'BTS Reset Cause',
        'Beamforming Calibration Detect Continuous Exception',
        'Service account root access is enabled',
        'Ethernet port security is disabled',
        'Sanity Check Error',
        'Increased BER detected on the optical connection to Radio Module'
    ]
REQUIRE_PACKAGES = "Active"

SW_BUILDS_DIR_PATH = "/home/ute/Downloads/"

tl_config = sys.modules[__name__]
