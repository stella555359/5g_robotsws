import sys

UE_TYPE = 'CPE'

GLO_TL_DESCRIPTOR_FILE_PATH = '/home/ute/testline_configuration/1_5_CLOUD038/TLdescriptor.xml'

CPE_INFO = [
    {
        "TYPE": "Gemtek",
        "BAND": "40,41,38",
        "IP": "192.168.1.11",
        "LAN_IP": "192.168.1.2",
        "DMZ": "no",
        "STATUS": "Enabled"
    }
]

UE_INFO = [
    {
        "TYPE": "CPE",
        "MODEL": "Gemtek",
        "BAND": "40,41,38",
        "IP": "192.168.1.11",
        "LAN_IP": "192.168.1.2",
        "DMZ": "no",
        "STATUS": "Enabled",
        "NETWORK_TYPE": "4G"
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
    'IP': '10.69.67.121',
    'USERNAME': 'BTS2309',
    'PASSWORD': 'SISO1_test',
    'Model': '98',
}

SA_INFO = {"SA_IP": "10.56.7.242",
           "POWER_PASS_LOSS": "70",
           "GATE_DELAY": "2.6",
           "TDD_FRAME_CONF": "2",
           "TDD_SPEC_SUBFCONF": "6",
           "TFRAME_OFFSET": "0.00069766",
           "TEST_MODE": "E-TM3_1__20MHz",
           "ETM": "E_TM3_1",
           "SA_PC_INFO": {"IP": "10.56.6.43",
                          "USERNAME": "tdlte-tester",
                          "PASSWORD": "btstest"},
           "SA_PA_INFO": [
               ["JX:10.56.7.244:1000:4:1"],
               ["JX:10.56.7.244:1000:4:110"]
           ]
           }

UL_TM_INFO = {
    "PC_INFO": {"IP": "10.56.6.43",
                "USERNAME": "tdlte-tester",
                "PASSWORD": "btstest"},
    "SMU200A": "10.69.66.80",
    "PATH": 2,
    "trigger_mode": "ARET",
    "trigger_source": "BEXTernal",
    "NTAoffset": 624,
    "level": -20,
    "external_delay": 0,
    "SA_PA_INFO": [
        ["FC:10.56.7.160:5000:4:10"],
        ["FC:10.56.7.160:5000:4:127"]
    ]
}

UUF_SW_STORAGE = {
    'LOGIN': 'siso',
    'PASSWORD': 'siso',
    'HOST_IP': '10.106.211.194',
    'SW_PATH': '/home/siso/LTE/UUF/'
}

SW_BUILDS_DIR_PATH = "/home/ute/Downloads/"
REQUIRE_PACKAGES = "Active"

ALLOWED_ALARMS = ['Vendor BTS certificate',
                  'Synchronization lost',
                  'Diagnostic Files collected',
                  'BTS booted at .*? due to trs management reset',
                  '.*? ToP master service .*? unusable',
                  'NTP Server .*?',
                  'BTS time not corrected',
                  'SSH enabled',
                  'R&D Service Port enabled',
                  'BTS Reset Cause',
                  'LMP access via port .*?',
                  'Failure in connection to Real-time PM Collection Entity',
                  'Service account root access is enabled',
                  'Ethernet port security is disabled',
                  'Sanity Check Error',
                  'Service account root access is enabled',
                  ]

RF_FACTORY_SW_STORAGE = {
    '6Q184131115':
        {
            'LOGIN': 'siso',
            'PASSWORD': 'siso',
            'HOST_IP': '10.106.211.194',
            'SW_PATH': '/home/siso/LTE/Factory_SW/',
            'RRUuser': 'root',
            'RRUpassword': '',
            'IMAGE_FILE': 'rfsw-image_20180830094706.tar',
            'checksum': '0x26e88959',
            'fileVersion': '20180830094706',
            'BuildName': '3DC58.09.R05',
            'BuildVersion': '3DC58.09.R05'
        }
}

tl_config = sys.modules[__name__]
