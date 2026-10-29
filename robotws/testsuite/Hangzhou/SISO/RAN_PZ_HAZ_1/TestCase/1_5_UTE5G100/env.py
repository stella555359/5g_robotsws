import sys

UE_INFO = [
    {
        "TYPE": "UE",
        "UE_ID": "0",
        "BAND": "28",
        "NETWORK_TYPE": "SA",
        "STATUS": "Enabled",
        "MODEL": "askey",
    },
    {
        "TYPE": "UE",
        "UE_ID": "0",
        "BAND": "25",
        "NETWORK_TYPE": "SA",
        "STATUS": "Enabled",
        "MODEL": "askey",
    },
]

FW_INFO = {
    "TYPE": "GG",
    "IP": "10.56.7.184",
    "USERNAME": "ASOE100",
    "PASSWORD": "password)0",
    "BBU_PORT": "78;79;81;82",
}

tl_config = sys.modules[__name__]
