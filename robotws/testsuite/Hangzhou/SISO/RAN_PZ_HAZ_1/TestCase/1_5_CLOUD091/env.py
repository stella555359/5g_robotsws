import sys


UE_INFO = [
    {
        "TYPE": "CPE",
        "MODEL": "ZMTEL",
        "BAND": "48",
        "IP": "192.168.1.1",
        "LAN_IP": "192.168.1.2",
        "STATUS": "Enabled",
        "NETWORK_TYPE": "4G",
    }
]


FW_INFO = {
    "TYPE": "CALIENT",
    "IP": "10.108.151.115",
    "USERNAME": "admin",
    "PASSWORD": "pxc***",
}

tl_config = sys.modules[__name__]
