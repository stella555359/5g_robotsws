import sys

UE_INFO = [
    {
        "TYPE": "UE",
        "MODEL": "askey",
        "UE_ID": "0",
        "BAND": "66",
        "NETWORK_TYPE": "SA,NSA",
        "STATUS": "Enabled",
        "RESET": "TRUE",
        "WAIT_UE": "120s",
    },
    {
        "TYPE": "UE",
        "MODEL": "askey",
        "UE_ID": "0",
        "BAND": "5",
        "NETWORK_TYPE": "SA,NSA",
        "STATUS": "Enabled",
        "RESET": "TRUE",
        "WAIT_UE": "120s",
    },
    {
        "TYPE": "UE",
        "MODEL": "askey",
        "UE_ID": "0",
        "BAND": "25",
        "NETWORK_TYPE": "SA,NSA",
        "STATUS": "Enabled",
        "RESET": "TRUE",
        "WAIT_UE": "120s",
    }
]

tl_config = sys.modules[__name__]
