import sys

UE_INFO = [
    {
        "TYPE": "UE",
        "MODEL": "huawei",
        "SUB_MODEL": "Huawei P40",
        "UE_ID": "0",
        "BAND": "3,78",
        "NETWORK_TYPE": "SA,NSA",
        "STATUS": "Enabled",
    },
    {
        "TYPE": "CPE",
        "MODEL": "Gemtek",
        "UE_ID": "NA",
        "BAND": "42,43",
        "NETWORK_TYPE": "4G",
        "IP": "192.168.1.6",
        "LAN_IP": "192.168.1.2",
        "STATUS": "Enabled",
        "DMZ": "no",
    }
]

tl_config = sys.modules[__name__]
