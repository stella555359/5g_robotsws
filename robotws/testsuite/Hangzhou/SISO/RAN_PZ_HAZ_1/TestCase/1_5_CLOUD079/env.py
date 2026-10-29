import sys


UE_INFO = [
    {
        "TYPE": "CPE",
        "MODEL": "Deming",
        "BAND": "38,39,40",
        "IP": "192.168.12.3",
        "LAN_IP": "192.168.12.222",
        "STATUS": "Enabled",
        "NETWORK_TYPE": "4G",
        "PA_LIST": "10.56.7.155",
    },
    {
        "TYPE": "CPE",
        "MODEL": "Gemtek",
        "BAND": "3,38,40,41",
        "IP": "192.168.12.4",
        "LAN_IP": "192.168.12.222",
        "STATUS": "Enabled",
        "NETWORK_TYPE": "4G",
        "PA_LIST": "10.56.7.162",
    },
    {
        "TYPE": "CPE",
        "MODEL": "Gemtek",
        "BAND": "3,38,40,41",
        "IP": "192.168.12.2",
        "LAN_IP": "192.168.12.222",
        "STATUS": "Enabled",
        "NETWORK_TYPE": "4G",
        "PA_LIST": "10.56.7.142",
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

FW_INFO = {
    "TYPE": "GG",
    "IP": "10.56.7.184",
    "USERNAME": "FISH1395",
    "PASSWORD": "password)0",
    "BBU_PORT": "52;53;54;55;56;57;58;59;60;61;62;63;64;65;66;67;68;69",
}


ALLOWED_ALARMS = [
    "Vendor BTS certificate",
    "Synchronization lost",
    "Temp Fault1",
    "BTS booted at .*? due to trs management reset",
    ".*? ToP master service .*? unusable",
    "NTP Server .*? unavailable",
    "SSH enabled",
    "R&D Service Port enabled",
    "LMP access via port.*",
    "BTS internal SW management problem",
    "Service account root access is enabled",
    "BTS Reset Cause",
    "VSWR major alarm",
    "Ethernet port security is disabled",
    "Sanity Check Error",
]


tl_config = sys.modules[__name__]
