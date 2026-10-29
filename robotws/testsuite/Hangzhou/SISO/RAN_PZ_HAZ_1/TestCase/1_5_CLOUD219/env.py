import sys

UE_INFO = [
    {
        "TYPE": "UE",
        "MODEL": "askey_order",
        "UE_ID": "0",
        "BAND": "1",
        "NETWORK_TYPE": "SA",
        "STATUS": "Enabled",
        "ALL_CELL_BARRED": "True",
        "RESET": "TRUE",
    },
    {
        "TYPE": "UE",
        "MODEL": "askey_order",
        "UE_ID": "0",
        "BAND": "3",
        "NETWORK_TYPE": "SA",
        "STATUS": "Enabled",
        "ALL_CELL_BARRED": "True",
        "RESET": "TRUE",
    }
]

tl_config = sys.modules[__name__]
