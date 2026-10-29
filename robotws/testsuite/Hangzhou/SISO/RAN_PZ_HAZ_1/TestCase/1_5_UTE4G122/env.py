import sys

SW_BUILDS_DIR_PATH = "/home/ute/Downloads/"
UE_TYPE = "CPE"
REQUIRE_PACKAGES = "Active"

ALLOWED_ALARMS = [
    "Vendor BTS certificate",
    "Synchronization lost",
    "Diagnostic Files collected",
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
    "Nokia MN BTS SFP validation failure",
    "Beamforming calibration failure in RF data path",
]

UE_INFO = [
    {
        "TYPE": "CPE",  # Deming/Gemtek
        "MODEL": "Gemtek",
        "BAND": "3,38,40,41",
        "IP": "192.168.15.2",
        "LAN_IP": "192.168.15.225",
        "STATUS": "Enabled",
        "DMZ": "no",
        "PA_LIST": "10.108.151.62",
        "NETWORK_TYPE": "4G",
    },
    {
        "TYPE": "CPE",  # Deming/Gemtek
        "MODEL": "Gemtek",
        "BAND": "3,38,40,41",
        "IP": "192.168.15.2",
        "LAN_IP": "192.168.15.225",
        "STATUS": "Enabled",
        "DMZ": "no",
        "PA_LIST": "10.106.198.105",
        "NETWORK_TYPE": "4G",
    },
    {
        "TYPE": "CPE",  # Deming/Gemtek
        "MODEL": "Gemtek",
        "BAND": "42,43",
        "IP": "192.168.15.5",
        "LAN_IP": "192.168.15.225",
        "STATUS": "Enabled",
        "DMZ": "no",
        "PA_LIST": "10.108.151.62",
        "NETWORK_TYPE": "4G",
    },
    {
        "TYPE": "UE",
        "MODEL": "samsung",
        "UE_ID": "0",
        "BAND": "41",
        "NETWORK_TYPE": "4G",
        "STATUS": "Enabled",
        "SUB_MODEL": "Samsung S21",
        "PA_LIST": "10.108.151.190",
        "RESET": "TRUE",
    },
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
    'BBU_PORT': '1.1.1;1.1.2;1.1.3;1.1.4;1.1.5;1.1.6;1.1.7;1.1.8;1.2.1;1.2.2;1.2.3;1.2.4;1.2.5;1.2.6;1.2.7;1.2.8',
}

RF_INCOMPATIBLE_SW_STORAGE = {
    '6Q181710303': {
        'LOGIN': 'siso',
        'PASSWORD': 'siso',
        'HOST_IP': '10.106.211.194',
        'SW_PATH': '/home/siso/LTE/Factory_SW/',
        'RRUuser': 'root',
        'RRUpassword': '',
        'IMAGE_FILE_23R2': 'FRM-rfsw-image-install_20230316151252-multi.tar',
        'IMAGE_FILE_23R1': 'FRM-rfsw-image-install_20230104150549-multi.tar',
        'IMAGE_FILE_22R4': 'FRM-rfsw-image-install_20230125164106-multi.tar',
        'checksum_23R2': '0xdaecbc67',
        'checksum_23R1': '0x50e9fc2b',
        'checksum_22R4': '0x219219b1',
        'fileVersion_23R2': 'install_20230316151252-multi',
        'fileVersion_23R1': 'install_20230104150549-multi',
        'fileVersion_22R4': 'install_20230125164106-multi',
        'BuildName_23R2': 'RF.FRM5.23R2.20230316.005',
        'BuildVersion_23R2': 'RF.FRM5.23R2.20230316.005',
        'BuildName_23R1': 'RF.FRM5.23R1.20230104.001',
        'BuildVersion_23R1': 'RF.FRM5.23R1.20230104.001',
        'BuildName_22R4': 'RF.FRM5.22R4.20230125.002',
        'BuildVersion_22R4': 'RF.FRM5.22R4.20230125.002',
    },
}

SUPPORTED_CALL = True
SAS_SIM = False

tl_config = sys.modules[__name__]
