import sys

UE_INFO = [
    {
        "TYPE": "UE",
        "MODEL": "askey",
        "UE_ID": "0",
        "BAND": "1,7",
        "NETWORK_TYPE": "SA",
        "STATUS": "Enabled",
        "RESET": "TRUE",
        "ALL_CELL_BARRED": "True",
    },
    {
        "TYPE": "UE",
        "MODEL": "askey",
        "UE_ID": "0",
        "BAND": "66,1,7",
        "NETWORK_TYPE": "4G",
        "STATUS": "Enabled",
        "RESET": "TRUE",
        "ALL_CELL_BARRED": "True",
    },
]

SUPPORTED_CALL = False

tl_config = sys.modules[__name__]
