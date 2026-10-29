import sys

UE_INFO = [
    {
        "TYPE": "UE",
        "UE_ID": "0",
        "BAND": "1",
        "NETWORK_TYPE": "NSA",
        "STATUS": "Enabled",
        "MODEL": "samsung",
        "SUB_MODEL": "Samsung S21",
        "RESET": "TRUE",
    },
    {
        "TYPE": "UE",
        "UE_ID": "0",
        "BAND": "3",
        "NETWORK_TYPE": "NSA",
        "STATUS": "Enabled",
        "MODEL": "samsung",
        "SUB_MODEL": "Samsung S21",
        "RESET": "TRUE",
    },
    {
        "TYPE": "UE",
        "UE_ID": "0",
        "BAND": "78",
        "NETWORK_TYPE": "SA",
        "STATUS": "Enabled",
        "MODEL": "samsung",
        "SUB_MODEL": "Samsung S21",
        "RESET": "TRUE",
    },
]

FW_INFO = {
    "TYPE": "GG",
    "IP": "10.56.7.184",
    "USERNAME": "BTS10451",
    "PASSWORD": "password)0",
    "BBU_PORT": "24;25;26;27;28;29",
}


tl_config = sys.modules[__name__]
