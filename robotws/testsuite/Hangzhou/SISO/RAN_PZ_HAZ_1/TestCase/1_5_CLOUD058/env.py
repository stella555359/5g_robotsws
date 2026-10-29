import sys

UE_INFO = [
    {
        "TYPE": "SISO_UE",
        "MODEL": "AT_dingli",
        "SUB_MODEL": "dingli",
        "UE_ID": "0",
        "BAND": "1,3,7,28",
        "NETWORK_TYPE": "4G,SA",
        "STATUS": "Enabled",
        "APN": "stdata2",
        "ALL_CELL_BARRED": "True",
        "RESET": False,
    },
]

IPERF_SERVER_INFO = {
    "IP": "10.69.64.197",
    "CTRL_IP": "10.69.64.196",
    "USERNAME": "tdlte-tester",
    "PASSWORD": "btstest",
    "PORT": "22",
    "LOG_PATH": "/home/tdlte-tester/UDP",
}

FW_INFO = {
    "TYPE": "GG",
    "IP": "10.56.7.147",
    "USERNAME": "BTS590",
    "PASSWORD": "SISO1_test",
    "Model": "98",
}

tl_config = sys.modules[__name__]
