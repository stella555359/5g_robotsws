import sys

UE_INFO = [
    {
        "TYPE": "UE",
        "MODEL": "nokia_cpe",
        "UE_ID": "0",
        "BAND": "40",
        "NETWORK_TYPE": "SA",
        "STATUS": "Enabled",
    },
    {
        "TYPE": "CPE",
        "MODEL": "Gemtek",
        "BAND": "40",
        "IP": "192.168.1.1",
        "LAN_IP": "192.168.1.2",
        "STATUS": "Enabled",
        "NETWORK_TYPE": "4G",
    },
]

tl_config = sys.modules[__name__]
