import sys


UE_INFO = [
    {
        "TYPE": "SISO_UE",
        "MODEL": "andriod_phone",
        "SUB_MODEL": "Huawei P40",
        "UE_ID": "0",
        "BAND": "34,39",
        "NETWORK_TYPE": "4G",
        "STATUS": "Enabled",
        "APN": "stdata2",
        "RESET": False,
    },

    {
            "TYPE": "CPE",
            "MODEL": "Gemtek",
            "BAND": "38,40,41",
            "IP": "192.168.1.1",
            "LAN_IP": "192.168.1.2",
            "DMZ": "no",
            "NETWORK_TYPE": "4G",
            "STATUS": "Enabled",
            "PA_LIST": "10.69.238.68"
    },

    {
            "TYPE": "CPE",
            "MODEL": "Gemtek",
            "BAND": "38,40,41",
            "IP": "192.168.1.7",
            "LAN_IP": "192.168.1.2",
            "DMZ": "no",
            "NETWORK_TYPE": "4G",
            "STATUS": "Enabled",
            "PA_LIST": "10.69.68.98"
    },
    # {
    #         "TYPE": "CPE",
    #         "MODEL": "Deming",
    #         "BAND": "39",
    #         "IP": "192.168.1.8",
    #         "LAN_IP": "192.168.1.2",
    #         "DMZ": "no",
    #         "NETWORK_TYPE": "4G",
    #         "STATUS": "Enabled",
    #         "PA_LIST": "10.69.68.98"
    # },
    {
            "TYPE": "CPE",
            "MODEL": "Gemtek",
            "BAND": "42,43",
            "IP": "192.168.1.9",
            "LAN_IP": "192.168.1.2",
            "DMZ": "no",
            "NETWORK_TYPE": "4G",
            "STATUS": "Enabled",
            "PA_LIST": "10.69.68.98"
    },
    {
            "TYPE": "CPE",
            "MODEL": "ZMTEL",
            "BAND": "48",
            "IP": "192.168.1.15",
            "LAN_IP": "192.168.1.2",
            "DMZ": "no",
            "NETWORK_TYPE": "4G",
            "STATUS": "Enabled",
            "PA_LIST": "10.69.68.98"
    }
   ]

IPERF_SERVER_INFO = {
                     "IP": "10.69.64.197",
                     "CTRL_IP": "10.69.64.196",
                     "USERNAME": "tdlte-tester",
                     "PASSWORD": "btstest",
                     "PORT": "22",
                     "LOG_PATH": "/home/tdlte-tester/UDP"
            }


FW_INFO = {
    'TYPE': 'GG',
    'IP': '10.69.238.69',
    'USERNAME': 'BTS2512_2274_Share',
    'PASSWORD': 'SISO2_test',
    'BBU_PORT': "7;8;9;10;11;12;46",
    'Model': '192',
    }


SHARE_RRU_INFO = {
     "BBU": {
         "OPTICAL_SWITCH_PORTS": "7:8:9:10:11:12:46:47:48"
     },
     "10.69.238.69_AZND": {
         "OPTICAL_SWITCH_PORTS": "13:14:15:16:17:18:19:20:21:22:23:24"
     },
     "10.69.238.69_FZFH": {
         "OPTICAL_SWITCH_PORTS": "31:32:33:34:35:36"
     }

 }

BTS_RELATED_PARAMETER = {
    "ONAIR_TIME":    "20 min",
    "SAS_SIM":    "True"
}

ALLOWED_ALARMS = ['Vendor BTS certificate',
                  'Synchronization lost',
                  'Diagnostic Files collected',
                  'BTS booted at .*? due to trs management reset',
                  '.*? ToP master service .*? unusable',
                  'NTP Server .*? unavailable',
                  'SSH enabled',
                  'R&D Service Port enabled',
                  'LMP access via port.*',
                  'BTS internal SW management problem',
                  'Failure in optical interface',
                  'Receiving failure in Optical Interface',
                  'Unsigned software release has been successfully downloaded',
                  'Cell disabled due to unknown problem; logs collected',
                  'Unsigned software release has been successfully downloaded',
                  'BTS Reset Cause',
                  'Service account root access is enabled',
                  'Ethernet port security is disabled',
                  'Sanity Check Error',
                  'SAS Heartbeat Failure'
                  ]


SW_BUILDS_DIR_PATH = "/home/ute/Downloads/"


TESTLINE_TYPE = "FlexibleShare"   # this type is for GG

tl_config = sys.modules[__name__]
