import sys

UE_INFO = [
    {
        "TYPE": "SISO_UE",
        "MODEL": "AT_dingli",
        "SUB_MODEL": "dingli",
        "UE_ID": "0",
        "BAND": "3,1",
        "NETWORK_TYPE": "4G",
        "STATUS": "Enabled",
        "APN": "stdata1",
        "ALL_CELL_BARRED": "True",
        "RESET": False,
    },
    {
        "TYPE": "SISO_UE",
        "MODEL": "AT_dingli",
        "SUB_MODEL": "dingli",
        "UE_ID": "0",
        "BAND": "41",
        "NETWORK_TYPE": "SA",
        "STATUS": "Enabled",
        "APN": "stdata1",
        "ALL_CELL_BARRED": "True",
        "RESET": False,
    },
]

FW_INFO = {
    "TYPE": "GG",
    "IP": "10.68.180.17",
    "USERNAME": "admin",
    "PASSWORD": "admin",
    "Model": "180",
    "BBU_PORT": "1;2;3"
}


tl_config = sys.modules[__name__]
