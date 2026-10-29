import sys
UE_INFO = [
    {
            "TYPE": "UE",
            "MODEL": "askey",
            "UE_ID":  "0",
            "BAND": "41",
            "NETWORK_TYPE": "SA",
            "STATUS": "Enabled",
            "RESET":  "TRUE",
    },
    {
        "TYPE": "CPE",
        "MODEL": "Gemtek",
        "UE_ID": "NA",
        "BAND": "41",
        "NETWORK_TYPE": "4G",
        "IP": "192.168.1.3",
        "LAN_IP": "192.168.1.2",
        "STATUS": "Enabled",
        "DMZ": "no",
    }
]

tl_config = sys.modules[__name__]
