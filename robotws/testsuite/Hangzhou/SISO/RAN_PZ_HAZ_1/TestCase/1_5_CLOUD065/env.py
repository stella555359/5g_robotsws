import sys

SW_BUILDS_DIR_PATH = "/home/ute/Downloads/"

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
]

UE_TYPE = "CPE"

GLO_TL_DESCRIPTOR_FILE_PATH = '/home/ute/testline_configuration/1_5_CLOUD065/TLdescriptor.xml'

UE_INFO = [
           {
            "TYPE": "CPE",
            "MODEL": "Gemtek",
            "BAND": "41",
            "IP": "192.168.1.1",
            "LAN_IP": "192.168.1.2",
            "STATUS": "Enabled",
            "NETWORK_TYPE": "4G",
            "DMZ": "no",
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
    'TYPE': 'GG',
    'IP': '10.56.7.147',
    'USERNAME': 'BTS2493',
    'PASSWORD': 'SISO1_test',
    'Model': '180',
    'BBMOD_PORT': '151;152;131',
    'AWHHD_PORT': '151:153;152:154;131:132',
    'BTS2493_FIBERLINKS': ['EB2019R0635_0=151:153', 'EB1947R0024_0=152:154', 'EB1947R0026_0=131:132'],
    }

GGMAP = [
    # GG INFO .....Connected BBU_PORT INFO.....Connected RRU PORT INFO
    {"DEVICE": "GG",
     "IP": "10.56.7.147",
     "BTS2493":
         {"USER": "BTS2493",
          "PSWD": "SISO1_test",
          "productName": "AIRSCALE",  # FSMF/FSIH/AIRSCALE
          "SMOD-1": {'SN': 'L1191004172'},
          "BBMOD-1": {'SN': 'L1171910337'},
          "BBU_GG_PORT_MAPPING":  # BBU_PORT:GG_PORT
          {'BBMOD-1(1)': '151',
           'BBMOD-1(2)': '152',
           'BBMOD-1(2)': '131',
           }
          },
     "AWHHF-1":
         {"productName": "AWHHF",
          "SN": "EB2019R0635",
          "RRU_GG_PORT_MAPPING":  # RRU_PORT:GG_PORT
          {'1': '153',
           },
          },
     "AWHHD-2":
         {"productName": "AWHHD",
          "SN": "EB1947R0024",
          "RRU_GG_PORT_MAPPING":  # RRU_PORT:GG_PORT
          {'1': '154',
           },
          },
     "AWHHD-3":
         {"productName": "AWHHD",
          "SN": "EB1947R0026",
          "RRU_GG_PORT_MAPPING":  # RRU_PORT:GG_PORT
          {'1': '132',
           }
          }
     }
]

RF_FACTORY_SW_STORAGE = {
    "EB2019R0635": {
        "LOGIN": "siso",
        "PASSWORD": "siso",
        "HOST_IP": "10.106.211.194",
        "SW_PATH": "/home/siso/LTE/Factory_SW/",
        'RRUuser': 'root',
        "RRUpassword": "",
        "IMAGE_FILE": "MRM-rfsw-image-install_20201106105212-multi.tar",
        "checksum": "0x1947abab",
        "fileVersion": "20201106105212",
        "BuildName": "MRM60.11.R01",
        "BuildVersion": "MRM60.11.R01",
    },
}

BTS_RELATED_PARAMETER = {
    "ONAIR_TIME":    "15 min"
}

tl_config = sys.modules[__name__]
