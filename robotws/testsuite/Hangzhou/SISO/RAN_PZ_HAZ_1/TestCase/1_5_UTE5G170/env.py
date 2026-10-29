import sys

UE_INFO = [
    {
        "TYPE": "Nokia_CPE",
        "MODEL": "NokiaCPE31",
        "UE_ID": "0",
        "BAND": "28,78",
        "NETWORK_TYPE": "SA",
        "STATUS": "Enabled",
        "IP": "192.168.1.1",
        "LAN_IP": "192.168.1.126",
        "ROOT_PASSWORD": "985ae662bedd",
        "ALL_CELL_BARRED": "True",
    },
    {
        "TYPE": "UE",
        "MODEL": "samsung",
        "UE_ID": "0",
        "BAND": "2,66",
        "NETWORK_TYPE": "SA",
        "STATUS": "Enabled",
        "SUB_MODEL": "Samsung S21",
        "RESET": "TRUE",
    },
]

FW_INFO = {
    "TYPE": "GG",
    "IP": "10.68.252.210",
    "USERNAME": "admin",
    "PASSWORD": "password",
}

tl_config = sys.modules[__name__]
