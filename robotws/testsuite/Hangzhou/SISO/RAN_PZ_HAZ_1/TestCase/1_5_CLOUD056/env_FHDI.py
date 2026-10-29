import sys

UE_INFO = [
    {
        "TYPE": "CPE",
        "MODEL": "Gemtek",
        "BAND": "38,41",
        "IP": "192.168.1.1",
        "LAN_IP": "192.168.1.2",
        "STATUS": "Enabled",
        "NETWORK_TYPE": "4G",
    }
]

FW_INFO = {
    "TYPE": "GG",
    "IP": "10.56.7.147",
    "USERNAME": "BTS1784",
    "PASSWORD": "SISO1_test",
    'BBU_PORT': "7;39",
}

RF_FAULT_INFO = {'1927': {'serverity': 'Major'}}

SAS_SIM = True

SUPPORTED_CALL = False

tl_config = sys.modules[__name__]
