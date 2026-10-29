import sys
UE_INFO = [
    {
            "TYPE": "SISO_UE",
            "MODEL": "AT_simcom",
            "UE_ID":  "0",
            "BAND": "38,40,41,42",
            "NETWORK_TYPE": "4G,SA",
            "STATUS": "Enabled",
    },
]

FW_INFO = {
    "TYPE": "GG",
    "IP": "10.106.198.23",
    "USERNAME": "admin",
    "PASSWORD": "password",
}

tl_config = sys.modules[__name__]
