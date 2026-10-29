import sys

_PT = "/mnt/factory/configs/unit"

REQUIRE_PACKAGES = "Active"
# UE_TYPE = "CPE"


UE_INFO = [
    {
        "TYPE": "CPE",
        "MODEL": "Gemtek",
        "BAND": "38,40,41",
        "IP": "192.168.1.10",
        "LAN_IP": "192.168.1.2",
        "STATUS": "Enabled",
        "DMZ": "no",
        "NETWORK_TYPE": "4G",
    }
]

# IPERF_SERVER_INFO = {
#                      "IP" : "10.108.183.96",
#                      "CTRL_IP" : "10.108.184.23",
#                      "USERNAME" : "ute",
#                      "PASSWORD" : "ute",
#                      "PORT"     : "22",
#                      "LOG_PATH"  : "/home/ute/UDP"
#             }

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

RF_FAULT_INFO = {
    '1901': {
        'trigger': {
            'ssh': {
                'rm -rf {}/calibration_dlpathx.bin;\
                mv {}/calibration_dlpath1.bin {}/calibration_dlpathx.bin'.format(_PT, _PT, _PT),
                'rm -rf {}/calibration_ulpathx.bin;\
                mv {}/calibration_ulpath1.bin {}/calibration_ulpathx.bin'.format(_PT, _PT, _PT)
            }
        },
        'cancel': {
            'ssh': {
                'mv {}/calibration_dlpathx.bin {}/calibration_dlpath1.bin '.format(_PT, _PT),
                'mv {}/calibration_ulpathx.bin {}/calibration_ulpath1.bin '.format(_PT, _PT)
            }
        },
        'serverity': 'Critical',
        'port': 2000
    },

    '1923': {
        'trigger': {
            'ssh': {
                'rm -rf {}/core_assembly_product_code_bak.txt;mv {}/core_assembly_product_code.txt\
                 {}/core_assembly_product_code_bak.txt'.format(_PT, _PT, _PT),
                'rm -rf {}/core_assembly_product_code_bak.txt.md5;mv {}/core_assembly_product_code.txt.md5\
                 {}/core_assembly_product_code_bak.txt.md5'.format(_PT, _PT, _PT),
                'rm -rf {}/core_assembly_serial_number_bak.txt;mv {}/core_assembly_serial_number.txt\
                 {}/core_assembly_serial_number_bak.txt'.format(_PT, _PT, _PT),
                'rm -rf {}/core_assembly_serial_number_bak.txt.md5;mv {}/core_assembly_serial_number.txt.md5\
                 {}/core_assembly_serial_number_bak.txt.md5'.format(_PT, _PT, _PT)
            }
        },
        'cancel': {
            'ssh': {
                'mv {}/core_assembly_product_code_bak.txt {}/core_assembly_product_code.txt'.format(_PT, _PT),
                'mv {}/core_assembly_product_code_bak.txt.md5 {}/core_assembly_product_code.txt.md5'.format(_PT, _PT),
                'mv {}/core_assembly_serial_number_bak.txt {}/core_assembly_serial_number.txt'.format(_PT, _PT),
                'mv {}/core_assembly_serial_number_bak.txt.md5 {}/core_assembly_serial_number.txt.md5'.format(_PT, _PT)
            }
        },
        'serverity': 'Critical',
        'port': 2000
    }
}

ALLOWED_ALARMS = ['Vendor BTS certificate',
                  'Synchronization lost',
                  'Diagnostic Files collected',
                  'BTS booted at .*? due to trs management reset',
                  '.*? ToP master service .*? unusable',
                  'NTP Server .*? unavailable',
                  'SSH enabled',
                  'R&D Service Port enabled',
                  'LMP access via port.*',
                  'BTS internal SW management problem',
                  'Failure in optical interface',
                  'Receiving failure in Optical Interface',
                  'Unsigned software release has been successfully downloaded',
                  'Cell disabled due to unknown problem; logs collected',
                  'Unsigned software release has been successfully downloaded',
                  'Service account root access is enabled',
                  'Ethernet port security is disabled',
                  'Unit power reset',
                  'Sanity Check Error'
                  ]

SW_BUILDS_DIR_PATH = "/home/ute/Downloads/"

TESTLINE_TYPE = "FlexibleShare"  # this type is for GG
# REQUIRE_PACKAGES= "Active"
RF_FACTORY_SW_STORAGE = {
    '6Q190208576': {
        'LOGIN': 'siso',
        'PASSWORD': 'siso',
        'HOST_IP': '10.106.211.194',
        'SW_PATH': '/home/siso/LTE/Factory_SW/',
        'RRUuser': 'root',
        'RRUpassword': '',
        'IMAGE_FILE': 'FRM-rfsw-image-install_20170901151555-multi.tar',
        'checksum': '0xd516d872',
        'fileVersion': 'install_20170901151555-multi',
        'BuildName': 'FRM57.08.R03C',
        'BuildVersion': 'FRM57.08.R03C',
    },
}
tl_config = sys.modules[__name__]
