import sys

UE_INFO = [
    {
        "TYPE": "CPE",
        "MODEL": "Gemtek",
        "UE_ID": "NA",
        "BAND": "40",
        "NETWORK_TYPE": "4G",
        "IP": "192.168.1.11",
        "LAN_IP": "192.168.1.2",
        "STATUS": "Enabled",
        "DMZ": "no",
    },
]

FW_INFO = {
    'TYPE': 'GG',
    'IP': '10.56.7.147',
    'USERNAME': 'BTS2371',
    'PASSWORD': 'SISO1_test',
    'BBU_PORT': "98"
}

tl_config = sys.modules[__name__]
