import sys


UE_INFO = [
    {
        "TYPE": "CPE",
        "MODEL": "Gemtek",
        "BAND": "3,38,40,41",
        "IP": "192.168.12.4",
        "LAN_IP": "192.168.12.221",
        "DMZ": "no",
        "STATUS": "Enabled",
        "NETWORK_TYPE": "4G",
        "PA_LIST": "10.56.7.162",
    },
    {
        "TYPE": "CPE",
        "MODEL": "Gemtek",
        "BAND": "3,38,40,41",
        "IP": "192.168.12.2",
        "LAN_IP": "192.168.12.221",
        "DMZ": "no",
        "STATUS": "Enabled",
        "NETWORK_TYPE": "4G",
        "PA_LIST": "10.56.7.142",
    },
    {
        "TYPE": "CPE",
        "MODEL": "Gemtek",
        "BAND": "3,38,40,41",
        "IP": "192.168.12.6",
        "LAN_IP": "192.168.12.221",
        "DMZ": "no",
        "STATUS": "Enabled",
        "NETWORK_TYPE": "4G",
        "PA_LIST": "10.56.7.161",
    },
    {
        "TYPE": "CPE",
        "MODEL": "Gemtek",
        "BAND": "42,43",
        "IP": "192.168.12.11",
        "LAN_IP": "192.168.12.221",
        "DMZ": "no",
        "STATUS": "Enabled",
        "NETWORK_TYPE": "4G",
        "PA_LIST": "10.56.7.158",
    },
    {
        "TYPE": "CPE",
        "MODEL": "Gemtek",
        "BAND": "3",
        "IP": "192.168.1.1",
        "LAN_IP": "192.168.1.221",
        "DMZ": "no",
        "STATUS": "Enabled",
        "NETWORK_TYPE": "4G",
        "PA_LIST": "10.56.7.194",
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
    "USERNAME": "AS586",
    "PASSWORD": "password)0",
    "BBU_PORT": "40;41;42;43;44;45;46;47;48;49;50;51;114;115",
}

BTS_RELATED_PARAMETER = {"ONAIR_TIME": "20 min"}

SW_BUILDS_DIR_PATH = "/home/ute/Downloads/"


TESTLINE_TYPE = "FlexibleShare"  # this type is for GG
# REQUIRE_PACKAGES= "Active"

# TESTLINE_TYPE = "Flexible" #this type is for GG

ALLOWED_ALARMS = [
    "Vendor BTS certificate",
    "Synchronization lost",
    "Diagnostic Files collected",
    "BTS booted at .*? due to trs management reset",
    ".*? ToP master service .*? unusable",
    "NTP Server .*? unavailable",
    "SSH enabled",
    "R&D Service Port enabled",
    "LMP access via port.*",
    "No usable time reference available",
    "Service account root access is enabled",
    "Receiving failure in Optical Interface",
    "GPS receiver alarm: position questionable",
    "PPS reference missing",
    "GPS receiver alarm: not tracking satellites",
    "BTS Reset Cause",
    "VSWR major alarm",
    "Ethernet port security is disabled",
    "Sanity Check Error",
]
FR_RESET_ALLOWED_ALARMS = [
    "Vendor BTS certificate",
    "Synchronization lost",
    "Diagnostic Files collected",
    "BTS booted at .*? due to trs management reset",
    ".*? ToP master service .*? unusable",
    "NTP Server .*? unavailable",
    "SSH enabled",
    "R&D Service Port enabled",
    "LMP access via port.*",
    "No usable time reference available",
    "Service account root access is enabled",
    "Receiving failure in Optical Interface",
    "GPS receiver alarm: position questionable",
    "PPS reference missing",
    "GPS receiver alarm: not tracking satellites",
    "BTS Reset Cause",
    "VSWR major alarm",
    "Ethernet port security is disabled",
    "Sanity Check Error",
]

tl_config = sys.modules[__name__]
