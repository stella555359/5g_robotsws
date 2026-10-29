import sys

UE_INFO = [
    {
        "TYPE": "Nokia_CPE",
        "MODEL": "NokiaCPE31",
        "UE_ID": "0",
        "BAND": "3,66",
        "NETWORK_TYPE": "SA",
        "STATUS": "Enabled",
        "IP": "192.168.1.1",
        "LAN_IP": "192.168.1.126",
        "ROOT_PASSWORD": "3baa4782c95c",
        "ALL_CELL_BARRED": "True",
    },
    {
        "TYPE": "Nokia_CPE",
        "MODEL": "NokiaCPE31",
        "UE_ID": "0",
        "BAND": "3,2",
        "NETWORK_TYPE": "4G",
        "STATUS": "Enabled",
        "IP": "192.168.1.1",
        "LAN_IP": "192.168.1.126",
        "ROOT_PASSWORD": "3baa4782c95c",
        "ALL_CELL_BARRED": "True",
    },
]

tl_config = sys.modules[__name__]
