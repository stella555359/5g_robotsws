import sys


UE_INFO = [
    {
        "TYPE": "CPE",
        "MODEL": "Gemtek",
        "BAND": "3,38,40,41",
        "IP": "192.168.12.4",
        "LAN_IP": "192.168.12.220",
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
        "LAN_IP": "192.168.12.220",
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
        "LAN_IP": "192.168.12.220",
        "DMZ": "no",
        "STATUS": "Enabled",
        "NETWORK_TYPE": "4G",
        "PA_LIST": "10.56.7.161",
    },
    {
        "TYPE": "CPE",
        "MODEL": "Deming",
        "BAND": "38,39",
        "IP": "192.168.14.109",
        "LAN_IP": "192.168.14.220",
        "DMZ": "no",
        "STATUS": "Enabled",
        "NETWORK_TYPE": "4G",
        "PA_LIST": "10.56.7.154",
    },
    {
        "TYPE": "CPE",
        "MODEL": "Gemtek",
        "BAND": "42,43",
        "IP": "192.168.12.11",
        "LAN_IP": "192.168.12.220",
        "DMZ": "no",
        "STATUS": "Enabled",
        "NETWORK_TYPE": "4G",
        "PA_LIST": "10.56.7.158",
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

BTS_RELATED_PARAMETER = {"ONAIR_TIME": "20 min"}

SW_BUILDS_DIR_PATH = "/home/ute/Downloads/"

TESTLINE_TYPE = "FlexibleShare"  # this type is for GG
# REQUIRE_PACKAGES= "Active"

# TESTLINE_TYPE = "Flexible" #this type is for GG

ALLOWED_ALARMS = [
    "Vendor BTS certificate",
    "Synchronization lost",
    "ALD Port power failure",
    "BTS booted at .*? due to trs management reset",
    ".*? ToP master service .*? unusable",
    "NTP Server .*? unavailable",
    "SSH enabled",
    "R&D Service Port enabled",
    "LMP access via port.*",
    "BTS internal SW management problem",
    "Service account root access is enabled",
    "FR not critical functionality not supported",
    "Incompatible SW version detected",
    "Temp Fault1",
    "ToP reference missing",
    "BTS Reset Cause",
    "VSWR major alarm",
    "Ethernet port security is disabled",
    "Sanity Check Error",
]

FW_INFO = {
    "TYPE": "GG",
    "IP": "10.56.7.184",
    "USERNAME": "FSMF142",
    "PASSWORD": "password)0",
    "BBU_PORT": "13;14;15;16;17;18",
}

tl_config = sys.modules[__name__]
