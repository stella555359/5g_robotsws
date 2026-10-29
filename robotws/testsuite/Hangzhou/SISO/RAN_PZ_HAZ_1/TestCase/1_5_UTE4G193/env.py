import sys

UE_INFO = [
    {
        "TYPE": "UE",
        "MODEL": "samsung",
        "UE_ID": "0",
        "BAND": "28,41",
        "NETWORK_TYPE": "4G",
        "STATUS": "Enabled",
        "SUB_MODEL": "Samsung S21",
        "RESET": "TRUE",
    },
    {
        "TYPE": "UE",
        "MODEL": "samsung",
        "UE_ID": "0",
        "BAND": "41",
        "NETWORK_TYPE": "SA",
        "STATUS": "Enabled",
        "SUB_MODEL": "Samsung S21",
        "RESET": "TRUE",
    },
]

FW_INFO = {
    'TYPE': 'CALIENT',
    'IP': '10.108.151.115',
    'USERNAME': 'admin',
    'PASSWORD': 'pxc***',
    'BBU_PORT': "2.3.1;2.3.2;2.3.3;2.3.6",
}

tl_config = sys.modules[__name__]
