import sys

UE_INFO = [
    {
        "TYPE": "UE",
        "MODEL": "askey_order",
        "UE_ID": "1",
        "BAND": "28",
        "NETWORK_TYPE": "SA",
        "STATUS": "Enabled",
        "INDEX": "0",
        "RESET": "TRUE",
        "ALL_CELL_BARRED": "True"
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
        "ALL_CELL_BARRED": "True"
    },
]

SUPPORTED_CALL = False

tl_config = sys.modules[__name__]
