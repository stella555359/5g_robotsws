import sys

UE_INFO = [
    {
        "TYPE": "UE",
        "UE_ID": "0",
        "BAND": "25",
        "NETWORK_TYPE": "SA",
        "STATUS": "Enabled",
        "MODEL": "askey",
        "ALL_CELL_BARRED": "True",
        "RESET": "TRUE",
    },
]

FW_INFO = {
    "TYPE": "GG",
    "IP": "10.56.7.184",
    "USERNAME": "ASIB011",
    "PASSWORD": "password)0",
    "BBU_PORT": "22;23",
}

tl_config = sys.modules[__name__]
