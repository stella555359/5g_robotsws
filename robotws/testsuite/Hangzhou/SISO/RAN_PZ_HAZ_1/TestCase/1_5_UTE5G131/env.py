import sys

UE_INFO = [
    {
        "TYPE": "UE",
        "MODEL": "askey",
        "UE_ID": "0",
        "BAND": "41",
        "NETWORK_TYPE": "SA",
        "STATUS": "Enabled",
    },
    {
        "TYPE": "UE",
        "MODEL": "askey",
        "UE_ID": "0",
        "BAND": "5",
        "NETWORK_TYPE": "4G",
        "STATUS": "Enabled",
    },
]

FW_INFO = {
    "TYPE": "CALIENT",
    "IP": "10.108.151.115",
    "USERNAME": "admin",
    "PASSWORD": "pxc***",
    'BBU_PORT': "3.1.1;3.1.2;3.1.7;3.1.8"
}

tl_config = sys.modules[__name__]
