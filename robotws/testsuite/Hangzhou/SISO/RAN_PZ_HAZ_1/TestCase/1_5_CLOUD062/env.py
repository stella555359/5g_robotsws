import sys

UE_INFO = [
    {
        "TYPE": "CPE",
        "MODEL": "Deming2",
        "BAND": "39",
        "IP": "192.168.1.3",
        "LAN_IP": "192.168.1.2",
        "STATUS": "Enabled",
        "NETWORK_TYPE": "4G",
    },
    {
        "TYPE": "CPE",
        "MODEL": "Gemtek",
        "BAND": "38,41",
        "IP": "192.168.1.1",
        "LAN_IP": "192.168.1.2",
        "STATUS": "Enabled",
        "NETWORK_TYPE": "4G",
    },

]

SAS_SIM = True

tl_config = sys.modules[__name__]
