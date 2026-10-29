import sys

UE_INFO = [
    {
        "TYPE": "Nokia_CPE",
        "MODEL": "NokiaCPE31",
        "UE_ID": "0",
        "BAND": "40,78",
        "NETWORK_TYPE": "SA",
        "STATUS": "Enabled",
        "IP": "192.168.1.1",
        "LAN_IP": "192.168.1.126",
        "ROOT_PASSWORD": "e97a4982f2d6",
        "ALL_CELL_BARRED": "True",
    },
    {
        "TYPE": "Nokia_CPE",
        "MODEL": "NokiaCPE31",
        "UE_ID": "0",
        "BAND": "40,42,43",
        "NETWORK_TYPE": "4G",
        "STATUS": "Enabled",
        "IP": "192.168.1.1",
        "LAN_IP": "192.168.1.126",
        "ROOT_PASSWORD": "e97a4982f2d6",
        "ALL_CELL_BARRED": "True",
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

SUPPORTED_CALL = False

tl_config = sys.modules[__name__]
