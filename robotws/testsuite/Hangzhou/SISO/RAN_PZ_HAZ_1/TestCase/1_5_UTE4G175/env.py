import sys

UE_INFO = [
    {
        "TYPE": "CPE",
        "MODEL": "Gemtek",
        "BAND": "38,40,41",
        "IP": "192.168.1.6",
        "LAN_IP": "192.168.1.2",
        "DMZ": "no",
        "NETWORK_TYPE": "4G",
        "STATUS": "Enabled",
    }
]

FW_INFO = {
    "TYPE": "GG",
    "IP": "10.68.252.210",
    "USERNAME": "BTS11653",
    "PASSWORD": "SISO1_test",
    'BBU_PORT': "68;79",
}

tl_config = sys.modules[__name__]
