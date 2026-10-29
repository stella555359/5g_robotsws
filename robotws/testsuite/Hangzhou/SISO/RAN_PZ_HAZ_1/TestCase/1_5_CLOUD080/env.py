import sys

SUPPORTED_CALL = False

FHS_INFO = {
        "6Q191509157": {'pdu': {"type": "FACOM", "ip_addr": "10.106.211.92", 'port': 6}}
           }

RF_FACTORY_SW_STORAGE = {
    'LOGIN': 'siso',
    'PASSWORD': 'siso',
    'HOST_IP': '10.106.211.194',
    'SW_PATH': '/home/siso/LTE/Factory_SW/',
    'CONFIG_PATH': '/home/siso/LTE/Factory_SW/',
    'CONFIG_FILE': 'config.py'
}

FW_INFO = {
    "TYPE": "GG",
    "IP": "10.56.7.226",
    "USERNAME": "BTS2169",
    "PASSWORD": "SISO1_test",
    "Model": "98",
    "6Q191509157": {"1": "94", "2": "75", "4": "76", "5": "77"},
    "K9174042690": {"1": "79", "2": "80"},
    "14W352G40042": {"1": "89"},
    "K9173717581": {"1": "88"}
}


tl_config = sys.modules[__name__]
