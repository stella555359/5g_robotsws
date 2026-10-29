import sys

UE_INFO = [
    {
        "TYPE": "UE",
        "UE_ID": "0",
        "BAND": "1,3,7,28",
        "NETWORK_TYPE": "SA",
        "STATUS": "Enabled",
        "ALL_CELL_BARRED": "True",
        "MODEL": "askey",
        "RESET": "TRUE",
    },
    {
        "TYPE": "CPE",
        "UE_ID": "1",
        "BAND": "3",
        "NETWORK_TYPE": "4G",
        "STATUS": "Enabled",
        "IP": "192.168.1.1",
        "LAN_IP": "192.168.1.159",
        "ALL_CELL_BARRED": "True",
        "MODEL": "Gemtek",
        "DMZ": "no",
    },
]

SUPPORTED_CALL = False

tl_config = sys.modules[__name__]
