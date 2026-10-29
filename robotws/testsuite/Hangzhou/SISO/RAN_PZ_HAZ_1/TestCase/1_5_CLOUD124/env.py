import sys

SW_BUILDS_DIR_PATH = "/home/ute/Downloads/"
UE_TYPE = "CPE"
REQUIRE_PACKAGES = "Active"

ADDITIONAL_ADMIN_ALLOWED_ALARMS = [
    "Vendor BTS certificate",
    "Synchronization lost",
    "BTS booted at .*? due to trs management reset",
    ".*? ToP master service .*? unusable",
    "NTP Server .*?",
    "BTS time not corrected",
    "SSH enabled",
    "R&D Service Port enabled",
    "LMP access via port .*?",
    "BTS Reset Cause",
    "Service account root access is enabled",
    "Ethernet port security is disabled",
    "Sanity Check Error",
    "Diagnostic Check Error",
]

UE_INFO = [
    {
        "MODEL": "Gemtek",  # Deming/Gemtek
        "BAND": "3,38,40,41",
        "IP": "192.168.15.2",
        "LAN_IP": "192.168.15.227",
        "NETWORK_TYPE": "4G",
        "STATUS": "Enabled",
        "DMZ": "192.168.15.227",
        "PA_LIST": "10.108.151.62",
        "TYPE": "CPE",
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
    'TYPE': 'CALIENT',
    'IP': '10.108.151.115',
    'USERNAME': 'admin',
    'PASSWORD': 'pxc***',
    'BBU_PORT': '1.6.1;1.6.2;1.6.3;1.6.4;1.6.5;1.6.6;1.6.7;1.6.8;1.7.1;1.7.2;1.7.3;1.7.4;'
                '1.7.5;1.7.6;1.7.7;1.7.8;1.8.1;1.8.2;1.8.3;1.8.4;1.8.5;1.8.6;1.8.7;1.8.8',
}

UUF_SW_STORAGE = {
    'LOGIN': 'siso',
    'PASSWORD': 'siso',
    'HOST_IP': '10.106.211.194',
    'SW_PATH': '/home/siso/LTE/UUF/'
}

SUPPORTED_CALL = True
SAS_SIM = False

tl_config = sys.modules[__name__]
