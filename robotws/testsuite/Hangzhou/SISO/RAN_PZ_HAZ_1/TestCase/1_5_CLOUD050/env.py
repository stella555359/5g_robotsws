import sys

UE_INFO = [
    {
        "TYPE": "CPE",
        "MODEL": "Gemtek",
        "BAND": "40",
        "IP": "192.168.1.1",
        "LAN_IP": "192.168.1.2",
        "STATUS": "Enabled",
        "NETWORK_TYPE": "4G",
    }
]

IPERF_SERVER_INFO = {
                     "IP": "10.69.67.197",
                     "CTRL_IP": "10.69.64.196",
                     "USERNAME": "tdlte-tester",
                     "PASSWORD": "btstest",
                     "PORT": "22",
                     "LOG_PATH": "/home/tdlte-tester/UDP"
            }

tl_config = sys.modules[__name__]
