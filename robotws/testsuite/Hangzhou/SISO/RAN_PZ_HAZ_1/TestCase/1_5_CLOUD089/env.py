import sys


UE_INFO = [
    {
        "TYPE": "CPE",
        "MODEL": "Gemtek",
        "BAND": "40",
        "IP": "192.168.1.2",
        "LAN_IP": "192.168.1.3",
        "DMZ": "no",
        "STATUS": "Enabled",
        "NETWORK_TYPE": "4G",
    }
]


RF_FACTORY_SW_STORAGE = {
    "1M212306543": {
        'LOGIN': 'siso',
        'PASSWORD': 'siso',
        'HOST_IP': '10.106.211.194',
        'SW_PATH': '/home/siso/LTE/Factory_SW/',
        'RRUuser': 'root',
        'RRUpassword': 'a2%FgSz3$fHmdusap354xujw7a',
        'IMAGE_FILE': 'LRM-rfsw-image-install-aenb_0xC73973F2.tar',
        'checksum': '0xc73973f2',
        'fileVersion': '0xC73973F2',
        'BuildName': 'RF.LRM6.trunk.20211111.003',
        'BuildVersion': 'RF.LRM6.trunk.20211111.003',
        'LRM': 'True'
    },
}

tl_config = sys.modules[__name__]
