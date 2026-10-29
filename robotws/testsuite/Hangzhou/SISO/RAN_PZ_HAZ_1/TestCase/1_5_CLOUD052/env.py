import sys

UE_INFO = [
    {
        "TYPE": "CPE",
        "MODEL": "ZMTEL",
        "BAND": "42,48",
        "IP": "192.168.1.1",
        "LAN_IP": "192.168.1.2",
        "STATUS": "Enabled",
        "NETWORK_TYPE": "4G",
    }
]

SAS_SIM = True

tl_config = sys.modules[__name__]
