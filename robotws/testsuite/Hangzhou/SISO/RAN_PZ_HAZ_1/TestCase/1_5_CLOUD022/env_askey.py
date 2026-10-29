import sys


UE_INFO = [
    {
        "TYPE": "UE",
        "UE_ID": "0",
        "BAND": "42",
        "NETWORK_TYPE": "4G",
        "STATUS": "Enabled",
        "MODEL": "askey",
    },
    {
        "TYPE": "UE",
        "UE_ID": "0",
        "BAND": "78",
        "NETWORK_TYPE": "SA",
        "STATUS": "Enabled",
        "MODEL": "askey",
    },
]

IPERF_SERVER_INFO = {
    "IP": "10.69.64.197",
    "CTRL_IP": "10.69.64.196",
    "USERNAME": "tdlte-tester",
    "PASSWORD": "btstest",
    "PORT": "22",
    "LOG_PATH": "/home/tdlte-tester/UDP",
}


ALLOWED_ALARMS = [
    "Vendor BTS certificate",
    "Synchronization lost",
    "ToP reference missing",
    "BTS booted at .*? due to trs management reset",
    ".*? ToP master service .*? unusable",
    "NTP Server .*? unavailable",
    "SSH enabled",
    "R&D Service Port enabled",
    "LMP access via port.*",
    "BTS internal SW management problem",
    "Service account root access is enabled",
    "Temp Fault1",
    "BTS Reset Cause",
    "VSWR major alarm",
    "Ethernet port security is disabled",
    "Sanity Check Error",
]

FW_INFO = {
    "TYPE": "GG",
    "IP": "10.56.7.184",
    "USERNAME": "BTS6053",
    "PASSWORD": "password)0",
    "BBU_PORT": "1;2;102;103",
}

tl_config = sys.modules[__name__]
