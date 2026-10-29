import sys

SW_BUILDS_DIR_PATH = "/home/ute/Downloads/"

REQUIRE_PACKAGES = "Active"

UE_INFO = [
    {
        "TYPE": "CPE",
        "UE_ID": "0",
        "BAND": "3,38,40,41",
        "NETWORK_TYPE": "4G",
        "STATUS": "Enabled",
        "MODEL": "Gemtek",
        "IP": "192.168.15.4",
        "LAN_IP": "192.168.15.87",
        "DMZ": "no",
        "PA_LIST": '10.108.151.144',
    },
]

BTS_RELATED_PARAMETER = {"ONAIR_TIME": "20 min"}

UUF_SW_STORAGE = {
    "LOGIN": "siso",
    "PASSWORD": "siso",
    "HOST_IP": "10.106.211.194",
    "SW_PATH": "/home/siso/LTE/UUF/",
}

tl_config = sys.modules[__name__]
