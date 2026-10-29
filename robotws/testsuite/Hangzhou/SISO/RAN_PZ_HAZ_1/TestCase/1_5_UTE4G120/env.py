import sys
UE_TYPE = 'CPE'

GLO_TL_DESCRIPTOR_FILE_PATH = '/home/ute/testline_configuration/1_5_UTE4G120/TLdescriptor.xml'

CPE_INFO = [
    {
        "TYPE": "Gemtek",
        "BAND": "42",
        "IP": "192.168.1.1",
        "LAN_IP": "192.168.1.2",
        "DMZ": "no",
        "STATUS": "Enabled"
    }
]

UE_INFO = [
    {
        "TYPE": "CPE",
        "MODEL": "Gemtek",
        "BAND": "42",
        "IP": "192.168.1.1",
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

RF_FACTORY_SW_STORAGE = {
    "1M201617783": {
        "LOGIN": "siso",
        "PASSWORD": "siso",
        "HOST_IP": "10.106.211.194",
        "SW_PATH": "/home/siso/LTE/Factory_SW/",
        'RRUuser': 'serviceuser',
        'RRUpassword': 'bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=',
        'rootpassword': 'a2%FgSz3$fHmdusap354xujw7a',
        'IMAGE_FILE': 'SRM-rfsw-image-install-aeqb_0xDB3C0A89.tar',
        'checksum': '0xdb3c0a89',
        'fileVersion': '0xDB3C0A89',
        'BuildName': 'RF.SRM6.trunk.20211031.003',
        'BuildVersion': 'RF.SRM6.trunk.20211031.003',
        'SRM': 'True'
    },
}

tl_config = sys.modules[__name__]
