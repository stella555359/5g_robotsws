"""BTS variable file, this file is used in TA run."""
# ************************ BTS ***********************
SW_RELEASE = "SBTS00"
# --> sack file path used for emil <--
BTS_SACK_PATH = ""

BTS_INFO = {"ID": "5345",
            "IP": "10.97.124.3",
            "NAME": "VTK",
            "MRBTS": "MRBTS-5345",
            "LNBTS": "LNBTS-5345",
            "SYSTEM_MODEL_TYPE": "ASIA",
            "LNT_VERSION": "",
            "PRODUCT_CODE": "472181A",
            "CORE_PRODUCT_CODE": "089596A.203",
            "CORE_SERIAL_NUMBER": "L1190206763",
            "EIF_PORT": "",
            "SWITCH_PORT": ""}

# --> External_System_Module_FBBA&FBIH <--
EXT_MODULE1 = {"TYPE": "FBBAA",
               "NAME": "XXXX",
               "MO_IN_SCF": "XXXXX",
               "PRODUCT_CODE": "XXXXX",
               "SERIAL_NUMBER": "XXXX"
               }

EXT_MODULE2 = {"TYPE": "FBBAA",
               "NAME": "XXXX",
               "MO_IN_SCF": "XXXXX",
               "PRODUCT_CODE": "XXXXX",
               "SERIAL_NUMBER": "XXXX"
               }

EXT_MODULE3 = {"TYPE": "FBBAA",
               "NAME": "XXXX",
               "MO_IN_SCF": "XXXXX",
               "PRODUCT_CODE": "XXXXX",
               "SERIAL_NUMBER": "XXXX"
               }

CELL_NUM = 1
CELL1_INFO = {"ID": 1,
              "LNCELL": "LNCEL-1",
              "EARFCN": "37900",
              "INTER_EARFCN": "37900",
              "FREQUENCY": "2585.0 MHz",
              "EUTRAN_ID": int(BTS_INFO["ID"]) * 256 + 1,
              "PCI": "418",
              "GLOBAL_CELL_ID": ""}

CELL2_INFO = {"ID": 2,
              "LNCELL": "LNCEL-2",
              "EARFCN": "",
              "INTER_EARFCN": "",
              "EUTRAN_ID": int(BTS_INFO["ID"]) * 256 + 2,
              "PCI": "",
              "GLOBAL_CELL_ID": ""}

CELL3_INFO = {"ID": 3,
              "LNCELL": "LNCEL-3",
              "EARFCN": "",
              "INTER_EARFCN": "",
              "EUTRAN_ID": int(BTS_INFO["ID"]) * 256 + 3,
              "PCI": "",
              "GLOBAL_CELL_ID": ""}

PRIMARY_CELL = 1
SECONDARY_CELL = 2

# --> RF_Mode <--
# value can be 'FYRN' or 'AXIS'
RRU1_INFO = {"TYPE": "FXDB",
             "NODE": "",
             "POWERBREAK_PORT": "7",
             "POWERBREAK_IP": "10.108.166.198",
             "POWERBREAK_Type": "FACOM",
             "MO_IN_SCF": "",
             "PRODUCT_CODE": "",
             "CORE_PRODUCT_CODE": "",
             "CORE_SERIAL_NUMBER": ""
             }

RRU2_INFO = {"TYPE": "",
             "NODE": "",
             "MO_IN_SCF": "",
             "PRODUCT_CODE": "",
             "CORE_PRODUCT_CODE": "",
             "CORE_SERIAL_NUMBER": ""
             }

RRU3_INFO = {"TYPE": "",
             "NODE": "",
             "MO_IN_SCF": "",
             "PRODUCT_CODE": "",
             "CORE_PRODUCT_CODE": "",
             "CORE_SERIAL_NUMBER": ""
             }

BTS_INFOMODEL_PORT = 12345

# --> BTS control PC <--
BTS_PC_INFO = {"IP": "10.108.229.2",
               "LANIP": "192.168.255.126",
               "GATEWAY": "10.97.124.1",
               "USERNAME": "ute",
               "PASSWORD": "uteUTE!",
               "IPV6": "",
               "IPV6_GW": ""}

# ************************ Core Network ***********************
# --> Netact 2519 <--
# NETACT_SERVER_INFO = {"IP" : "10.91.146.210",
# "URL" : "clab2519lbwas.netact.nsn-rdnet.net",
# "USERNAME" : "omc2",
# "PASSWORD" : "zhouhang2",
# "PORT" : "22",
# "EXTEND_IP" : ""}
# --> Netact 2311 <--
# NETACT_SERVER_INFO = {"IP" : "10.91.114.158",
# "URL" : "clab2311lbwas.netact.nsn-rdnet.net",
# "USERNAME" : "omc2",
# "PASSWORD" : "zhouhang2",
# "PORT" : "22",
# "EXTEND_IP" : ""}
# --> NetAct6-Sui<--
# NETACT_SERVER_INFO = {"IP" : "10.110.144.154",
#                       "URL" : " sui6lbwas.sui6.srnhz.nsn-rdnet.net",
#                       "USERNAME" : "omc",
#                       "PASSWORD" : "Nokia126_",
#                       "PORT" : "22",
#                       "EXTEND_IP" : ""}


#  --> NetAct3-zheng<--
# NETACT_SERVER_INFO = {"IP": "10.110.188.146",
#                      "URL": "zheng3lbwas.zheng3.srnhz.nsn-rdnet.net",
#                      "USERNAME": "omc",
#                      "PASSWORD": "Nokia126_",
#                      "PORT": "22",
#                      "EXTEND_IP": ""}
# --> Netact 1014 <--
# NETACT_SERVER_INFO = {"IP" : "10.41.146.105",
#                       "URL" : "srnclab1014lbwas.srnblr.nsn-rdnet.net",
#                       "USERNAME" : "omc",
#                       "PASSWORD" : "Medsql!_1893",
#                       "PORT" : "22",
#                       "EXTEND_IP" : ""}

#  --> NetAct4-CHEN<--
NETACT_SERVER_INFO = {"IP": "10.108.248.82",
                      "URL": "chen4lbwas.chen4.srnhz.nsn-rdnet.net",
                      "USERNAME": "omc",
                      "PASSWORD": "Nokia126_",
                      "PORT": "22",
                      "EXTEND_IP": ""}
# --> Netact 1013 <--
# NETACT_SERVER_INFO = {"IP" : "10.41.146.72",
# "URL" : "srnclab1013lbwas.srnblr.nsn-rdnet.net",
# "USERNAME" : "omc",
# "PASSWORD" : "omc",
# "PORT" : "22",
# "EXTEND_IP" : ""}

# --> Netact 1025 <--
# NETACT_SERVER_INFO = {"IP" : "10.41.148.19",
#                       "URL" : "srnclab1025lbwas.srnblr.nsn-rdnet.net",
#                       "USERNAME" : "omc",
#                       "PASSWORD" : "omc",
#                       "PORT" : "22",
#                       "EXTEND_IP" : ""}

# --> Netact 1027 <--
# NETACT_SERVER_INFO = {"IP" : "10.41.148.99",
#                      "URL" : "srnclab1027lbwas.srnblr.nsn-rdnet.net",
#                      "USERNAME" : "omc",
#                      "PASSWORD" : "Medsql!_1893",
#                      "PORT" : "22",
#                      "EXTEND_IP" : ""}

# --> Netact 1028 <--
# NETACT_SERVER_INFO = {"IP" : "10.41.148.139",
#                      "URL" : "srnclab1028lbwas.srnblr.nsn-rdnet.net",
#                      "USERNAME" : "omc",
#                      "PASSWORD" : "Medsql!_1893",
#                      "PORT" : "22",
#                      "EXTEND_IP" : ""}

# --> Netact 1015 <--
# NETACT_SERVER_INFO = {"IP" : "10.41.146.138",
# "URL" : "srnclab1013lbwas.srnblr.nsn-rdnet.net",
# "USERNAME" : "omc",
# "PASSWORD" : "omc",
# "PORT" : "22",
# "EXTEND_IP" : ""}

OMS1_INFO = {"ID": "265",
             "NAME": "IMP-265",
             "SBI_IP": "10.108.152.16",
             "NBI_IP": "10.108.152.17",
             "USERNAME": "Nemuadmin",
             "PASSWORD": "nemuuser",
             "SUPER_PASSWORD": "nsn",
             "SBI_HEX_IP": ""
             }

# OMS2_INFO = {"ID" : "",
#            "NAME" : "",
#            "SBI_IP" : "",
#            "NBI_IP" : "",
#            "USERNAME" : "",
#            "PASSWORD" : "",
#            "SUPER_PASSWORD" : "",
#            "SBI_HEX_IP" : ""
#             }

# real MME information, need collect all mme infomation. ????
MME1_INFO = {"IP": "10.68.151.202"}

MME2_INFO = {"IP": "10.69.71.138"}

# ************************ UE ***********************
# --> UE <--
# CPE type can be: DEMING_CPE, ALTAIR_CPE, ALTAIR_DONGLE, HUAWEI_DONGLE
# address is the cpe's ip address or dongle's COM port num
UE1_INFO = {"TYPE": "",
            "ADDRESS": "",
            "FREQUENCY": "37900",
            "SWITCHPORT": "",
            "IPVER": "ipv4"}

# ************************ UE Simulator***********************
# can be one of IPHY TM500 DONGLE CPEa
UE_TYPE = "DONGLE"

# Please consult MME/HLR expert if you have no idea about IMSI info
IMSI1_INFO = {"NUM": "",  # IMSI number
              "AUTH_METHOD": "",  # authentication method, "test" or "milenage"
              "OP": "",  # empty if "test", not empty if "milenage"
              "KI": ""}  # not empty
IMSI2_INFO = {"NUM": "",
              "AUTH_METHOD": "",
              "OP": "",
              "KI": ""}
IMSI3_INFO = {"NUM": "",
              "AUTH_METHOD": "",
              "OP": "",
              "KI": ""}

# ************************ PA ***********************
# --> Attenuator  <--
# Attenuators address must be given as format: vendor:ip:port
# till now we support HaoJing(type as HJ) and JieXi(JX) attenuators
ATT_ALL_INFO = {"ATT1": "",
                "ATT2": ""}

CELL1_ATT_INFO = {"ADDRESS": "",
                  "MAIN_CH": "",
                  "AUX_CH": "",
                  "MAIN_ATTACH_VALUE": "0",
                  "MAIN_HO_VALUE": "20",
                  "AUX_ATTACH_VALUE": "",
                  "AUX_HO_VALUE": ""}

CELL2_ATT_INFO = {"ADDRESS": "",
                  "MAIN_CH": "",
                  "AUX_CH": "",
                  "MAIN_ATTACH_VALUE": "0",
                  "MAIN_HO_VALUE": "20",
                  "AUX_ATTACH_VALUE": "",
                  "AUX_HO_VALUE": ""}

CELL3_ATT_INFO = {"ADDRESS": "",
                  "MAIN_CH": "",
                  "AUX_CH": "",
                  "MAIN_ATTACH_VALUE": "0",
                  "MAIN_HO_VALUE": "20",
                  "AUX_ATTACH_VALUE": "",
                  "AUX_HO_VALUE": ""}

# ************************ PB ***********************
# --> Power Breaker <--
# format: VENDOR:IP:PORT , if have muliti port, can be a list.
# Vendor can be: FACOM, APC, XCYCLER, NSN, if NSN selected format is: NSN:COMPORT
BTS_POWERBREAK_PORT = ["FACOM:10.108.151.106:6"]
IPHY_POWERBREAK_PORT = ""

# ************************ Other Server ***********************
IPSEC_SERVER_INFO = {"IP": "10.68.143.210",
                     "USERNAME": "root",
                     "PASSWORD": "nokia123"}

IPERF_SERVER_INFO = {"IP": "",
                     "USERNAME": "",
                     "PASSWORD": "",
                     "CONN_TYPE": "TELNET"}

# ************************ FLAG ***********************

AUTO_SNAPSHOT_FLAG = True
COUNTER_REFRESH_PERIOD = "15min"
ONAIR_MAX_DURATION = "10min"
BTS_ONAIR_MAX_TRIAL_TIMES = 1
ONAIR_CHECK_MSG = ["PBCH"]
ONAIR_CHECK_MODE = "INFOMODEL"
ONE_KEY_CAPTURE_LOGS_OPTION = ""
ONE_KEY_CAPTURE_LOGS_FLAG = False

TraceConfiguration = {
    "TraceReference": -1,
    "TraceTarget": "MRBTS-22210/LNBTS-5065/LNCEL-0",
    "CellTrace": {
        "CellTraceBasic": {
            "Job_type": "Trace only",
            "Trace_type": "Cell Trace",
            "Activation_profile": "System profile",
            "Description": "systemTest: Cell Trace",
            "START_DATE": "2000-12-12",
            "START_TIME": "23:59",
            "STOP_DATE": "2025-12-12",
            "STOP_TIME": "23:59"
        },
        "CellTraceAdvanced": {
            "TA": False,
            "UE_Throughput": False,
            "PCMD": False,
            "IP_of_TCE": "",
            "Port_of_TCE": "",
            "Limit_of_active_UEs": "100",
            "Maximum_buffering_time": "250",
            "Force_UE_IDs_repetition": "No",
            "Interface_selection": "NSNTI"
        },
        "CellTraceMDT": {
            "Report_interval": "5120 ms",
            "Report_amount": "4",
            "Data_anoymization": "No identity",
            "GNSS_positioning": False,
            "Obtain_location": False,
            "Fore_UE_consent": False,
            "Select_only_GNSS_UEs": False,
            "TA_synch": False,
            "PHR": False,
            "UE_RANK": False,
            "UL_SINR": False,
            "RIP": False,
            "PDSCH_PRB": False,
            "UE_BSR": False,
            "AoA": False,
            "PUSCH_PRB": False,
            "Limit_of_active_MDT_UEs": "100",
            "RIP_type": "Subframe and slot",
            "RIP_report_interval": "5 sec"
        }
    },
    "LoggedMDT": {
        "CELL_WORKING_MODE": "Configure and retrieve",
        "ANONYMIZATION_MDT_DATA": "IMEI-TAC",
        "TCE_ID": "0",
        "SELECT_ONLY_STANDALONE_GNSS_UES": False,
        "FORCE_UE_CONSTENT": True,
        "ENABLE_LOGGED_MDT_TRS_START": False,
        "LOGGING_DURATION": "10 min",
        "LOGGING_INTERVAL": "1280 ms",
        "COLLECTION_AREA": "PLMN ID",
        "Description": "systemTest: Logged MDT",
        "STOP_DATE": "2025-12-12",
        "STOP_TIME": "23:59"
    },
    "SubscriberTrace": {
        "Target": "IMSI",
        "NE": "FLEXINS-1 MME",
        "Traced number": "262033031521111",
        "Trace_type": "Subscriber",
        "Trace_level": "Maximum",
        "IP_of_TCE": "10.97.92.236",
        "MCC": "262",
        "MNC": "03",
        "Trigger event": {
            "Attach_TAU_Detach": True,
            "Handover": True,
            "Service_Request": True,
            "Bear_Act_Mod_Deat": True
        },
        "Interface": {
            "S1_MME": True,
            "X2": True,
            "Uu": True
        },
        "Description": "systemTest: Subscriber Trace",
        "START_DATE": "2000-12-12",
        "START_TIME": "23:59",
        "STOP_DATE": "2025-12-12",
        "STOP_TIME": "23:59"
    },
    "LTE_Activation_Profile": [
        "RRCEarlyDataRequest",
        "RRCConnectionReject"
    ]
}

ctrlts = [
    {
        "parameterName": "certTypeForTlsAuth", "operation": "update", "value": "RSA",
    },
    {
        "parameterName": "ctrlTsId", "operation": "update", "value": 1,
    },
    {
        "parameterName": "extTraceReporting", "operation": "update", "value":
        [
            {
                "extCellTraceRep": True,
                "extUeTraceRep": True,
            }
        ],
    },
    {
        "parameterName": "maxUeTraceSessions", "operation": "update", "value": "60",
    },
    {
        "parameterName": "netActIpAddr", "operation": "update", "value": "127.0.0.1",
    },
    {
        "parameterName": "omsTracePortNum", "operation": "update", "value": 49392,
    },
    {
        "parameterName": "subscriberMDTObtainLocation", "operation": "update", "value": False,
    },
    {
        "parameterName": "tceIdLogMdtIpMap", "operation": "update", "value":
        [
            {
                "loggedPortNum": 49392,
                "loggedTCEId": 0,
                "loggedTCEIP": "127.0.0.1",
                # "loggedTCEIP": "192.168.0.1",
                "loggedTCEmcc": 262,
                "loggedTCEmnc": 3,
                "loggedTCEmncLen": 2,
            },
        ]
    },
    {
        "parameterName": "tceTlsEnabled", "operation": "update", "value": False,
    },
    {
        "parameterName": "tceTracePortNum", "operation": "update", "value": 49151,
    },
    {
        "parameterName": "traceRepMode", "operation": "update", "value":
        [
            {
                "cellTraceRepMode": "Offline",
                "ueTraceRepMode": "Offline"
            },
        ],
    },
    {
        # ueTraceInterfaceSelection was introduced in CB006542 in 23R3
        "parameterName": "ueTraceInterfaceSelection", "operation": "update", "value": "NSNTI",
    },
    {
        "parameterName": "vendorSpecTracing", "operation": "update", "value":
        [
            {
                "taTracing": False,
            }
        ],
    },
]


# *********************** !!! DO NOT change below code !!! *********************
def get_variables(target=""):
    """get variables that will be used in robot, in TA also will validate these
    variable to make every team have a uniform environment.
    @param target: is target or not, can be TGT1,TGT2,TGT3 or leave it empty
    @raise ValidationError: if not match template"""
    import sys
    import os
    sys.path.append(os.path.dirname(__file__))
    from convert_variables import convert_variables
    variable_list = convert_variables(globals(), target)
    return variable_list
