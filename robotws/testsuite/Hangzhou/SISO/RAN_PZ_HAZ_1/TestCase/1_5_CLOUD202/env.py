import sys

SW_BUILDS_DIR_PATH = "/home/ute/Downloads/"

REQUIRE_PACKAGES = "Active"
SUPPORTED_CALL = False
UE_INFO = [
    {
        "TYPE": "Gemtek",
        "BAND": "40,41",
        "IP": "192.168.1.11",
        "LAN_IP": "192.168.1.2",
        "STATUS": "Enabled",
    }
]

IPERF_SERVER_INFO = {
    "IP": "10.69.64.197",
    "CTRL_IP": "10.69.64.196",
    "USERNAME": "tdlte-tester",
    "PASSWORD": "btstest",
    "PORT": "22",
    "LOG_PATH": "/home/tdlte-tester/UDP",
}


FW_INFO = {
    "TYPE": "GG",
    "IP": "10.56.7.226",
    "USERNAME": "BTS2415",
    "PASSWORD": "SISO1_test",
    "Model": "98",
    "6Q191127117": {"1": "83", "2": "82", "6": "85", "8": "84"},
    "EA184380927": {"1": "87", "2": "86"},
    "17YD07000265": {"1": "74"},
    "K9180709089": {"1": "93"}
}

FHS_INFO = {
    "6Q191127117": {"pdu": {"type": "FACOM", "ip_addr": "10.106.211.88", "port": 5}}
}


RF_FACTORY_SW_STORAGE = {
    'LOGIN': 'siso',
    'PASSWORD': 'siso',
    'HOST_IP': '10.106.211.194',
    'SW_PATH': '/home/siso/LTE/Factory_SW/',
    'CONFIG_PATH': '/home/siso/LTE/Factory_SW/',
    'CONFIG_FILE': 'config.py'
}

SUPPORTED_CALL = False

tl_config = sys.modules[__name__]
