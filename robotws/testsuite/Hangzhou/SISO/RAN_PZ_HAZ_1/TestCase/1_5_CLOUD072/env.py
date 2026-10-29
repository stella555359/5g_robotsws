import sys

ADDITIONAL_ADMIN_ALLOWED_ALARMS = [
    "Vendor BTS certificate",
    "Synchronization lost",
    "Diagnostic Files collected",
    "BTS booted at .*? due to trs management reset",
    ".*? ToP master service .*? unusable",
    "NTP Server .*?",
    "BTS time not corrected",
    "SSH enabled",
    "R&D Service Port enabled",
    "LMP access via port .*?",
    "BTS Reset Cause",
    "Service account root access is enabled",
    "Ethernet port security is disabled",
    "Sanity Check Error",
    "Failure in optical interface",
    "Nokia MN BTS SFP validation failure",
]

UE_INFO = [
    {
        "TYPE": "UE",
        "UE_ID": "0",
        "BAND": "38,39,40,41,42",
        "NETWORK_TYPE": "4G",
        "STATUS": "Enabled",
        "MODEL": "Qualcomm",
    },
    {
        "TYPE": "CPE",
        "MODEL": "Gemtek",
        "BAND": "43",
        "IP": "192.168.1.6",
        "LAN_IP": "192.168.1.2",
        "DMZ": "no",
        "STATUS": "Enabled",
        "NETWORK_TYPE": "4G",
        "PA_LIST": "10.68.160.84",
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
    "IP": "10.69.66.66",
    "USERNAME": "cloud072",
    "PASSWORD": "password)0",
    "BBU_PORT": "9;10;11;42;43;44;45;46;47;48;49;50;149;150;179;180;187;188;189;190;191;192",
}
tl_config = sys.modules[__name__]
