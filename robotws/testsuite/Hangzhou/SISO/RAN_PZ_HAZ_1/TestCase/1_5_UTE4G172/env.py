import sys

UE_INFO = [
    {
        "TYPE": "SISO_UE",
        "MODEL": "9206",
        "SUB_MODEL": "BG96",
        "UE_ID": "0",
        "BAND": "3,5,26",
        "NETWORK_TYPE": "4G",
        "TECHNOLOGY": "NB-IoT-FDD",
        "STATUS": "Enabled",
        "APN": "NBIOT",
        "ALL_CELL_BARRED": "True",
        "RESET": False,
    },
    {
        "TYPE": "SISO_UE",
        "MODEL": "AT_dingli",
        "SUB_MODEL": "dingli",
        "UE_ID": "0",
        "BAND": "3,5",
        "NETWORK_TYPE": "4G,SA",
        "STATUS": "Enabled",
        "APN": "stdata2",
        "ALL_CELL_BARRED": "True",
        "RESET": False,
    },
]

FW_INFO = {
    "TYPE": "GG",
    "IP": "10.68.252.210",
    "USERNAME": "BTS10769",
    "PASSWORD": "SISO1_test",
    "Model": "180",
    "BBU_PORT": "1;2;3"
}


tl_config = sys.modules[__name__]
