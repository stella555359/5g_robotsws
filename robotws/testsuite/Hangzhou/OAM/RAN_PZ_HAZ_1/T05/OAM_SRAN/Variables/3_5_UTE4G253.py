"""BTS variable file, this file is used in TA run."""
# ************************ BTS ***********************
SW_RELEASE = "SBTS00"
# --> sack file path used for emil <--
BTS_SACK_PATH = ""

BTS_INFO = {"ID": "5339",
            "IP": "10.106.243.13",
            "NAME": "BTS5339",
            "MRBTS": "MRBTS-5339",
            "LNBTS": "LNBTS-5339",
            "NRBTS": "LNBTS-10640",
            "SYSTEM_MODEL_TYPE": "ASIL",
            "LNT_VERSION": "",
            "PRODUCT_CODE": "474767A",
            "CORE_PRODUCT_CODE": "090815A.102",
            "CORE_SERIAL_NUMBER": "L1213502309",
            "EIF_PORT": "1",
            "SWITCH_PORT": "0/0",
            "PRIMARY_PB_IP": "10.106.243.48",
            "PRIMARY_PB_Port": "1",
            "SECONDARY_PB_IP": "10.106.243.47",
            "SECONDARY_PB_PORT": "2",
            "SECONDARY_PB_TYPE": "FACOM"}

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
CELL1_INFO = {"ID": 0,
              "LNCELL": "LNCEL-0",
              "EARFCN": "39800",
              "INTER_EARFCN": "39800",
              "FREQUENCY": "2511.0 MHz",
              "EUTRAN_ID": int(BTS_INFO["ID"]) * 256 + 1,
              "PCI": "418",
              "GLOBAL_CELL_ID": ""}

CELL2_INFO = {"ID": 1,
              "LNCELL": "LNCEL-1",
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
RRU1_INFO = {"TYPE": "AHDB",
             "NODE": "",
             "POWERBREAK_PORT": "5",
             "POWERBREAK_IP": "10.106.243.43",
             "POWERBREAK_Type": "HBTE",
             "MO_IN_SCF": "",
             "PRODUCT_CODE": "",
             "CORE_PRODUCT_CODE": "",
             "CORE_SERIAL_NUMBER": ""
             }
RRU2_INFO = {"TYPE": "AHLOA",
             "NODE": "",
             "POWERBREAK_PORT": "4",
             "POWERBREAK_IP": "10.106.243.43",
             "POWERBREAK_Type": "HBTE",
             "MO_IN_SCF": "",
             "PRODUCT_CODE": "",
             "CORE_PRODUCT_CODE": "",
             "CORE_SERIAL_NUMBER": ""
             }
RRU3_INFO = {"TYPE": "AHEGB",
             "NODE": "",
             "POWERBREAK_PORT": "5",
             "POWERBREAK_IP": "10.106.243.44",
             "POWERBREAK_Type": "HBTE",
             "MO_IN_SCF": "",
             "PRODUCT_CODE": "",
             "CORE_PRODUCT_CODE": "",
             "CORE_SERIAL_NUMBER": ""
             }

BTS_INFOMODEL_PORT = 12345

# --> BTS control PC <--
BTS_PC_INFO = {"IP": "10.108.152.143",
               "LANIP": "192.168.255.126",
               "GATEWAY": "10.108.152.190",
               "USERNAME": "ute",
               "PASSWORD": "N0kia@dmin56",
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

# --> Netact 1014 <--
# NETACT_SERVER_INFO = {"IP" : "10.41.146.105",
#                       "URL" : "srnclab1014lbwas.srnblr.nsn-rdnet.net",
#                       "USERNAME" : "omc",
#                       "PASSWORD" : "Medsql!_1893",
#                       "PORT" : "22",
#                       "EXTEND_IP" : ""}
# --> NetAct6-Sui<--
# NETACT_SERVER_INFO = {"IP" : "10.110.144.154",
#                       "URL" : " sui6lbwas.sui6.srnhz.nsn-rdnet.net",
#                       "USERNAME" : "omc",
#                       "PASSWORD" : "Nokia126_",
#                       "PORT" : "22",
#                       "EXTEND_IP" : ""}
#  --> NetAct4-CHEN<--
NETACT_SERVER_INFO = {"IP": "10.108.248.82",
                      "URL": "chen4lbwas.chen4.srnhz.nsn-rdnet.net",
                      "USERNAME": "omc",
                      "PASSWORD": "Nokia123!",
                      "PORT": "22",
                      "EXTEND_IP": ""}


# --> NetAct3-zheng<--
# NETACT_SERVER_INFO = {"IP" : "10.110.188.146",
#                       "URL" : "zheng3lbwas.zheng3.srnhz.nsn-rdnet.net",
#                       "USERNAME" : "omc",
#                       "PASSWORD" : "Nokia126_",
#                       "PORT" : "22",
#                       "EXTEND_IP" : ""}
# --> Netact 2003 <--
# NETACT_SERVER_INFO = {"IP": "10.82.47.46",
#                       "URL": "srnclab2003lbwas.srnblr.nsn-rdnet.net",
#                       "USERNAME": "omc",
#                       "PASSWORD": "Medsql!_1893",
#                       "PORT": "22",
#                       "EXTEND_IP": ""}
#  --> NetAct7-jiang<--
# NETACT_SERVER_INFO = {"IP" : "10.56.3.18",
#                       "URL" : "jiang7lbwas.jiang7.srnhz.nsn-rdnet.net",
#                       "USERNAME" : "omc",
#                       "PASSWORD" : "Nokia126_",
#                       "PORT" : "22",
#                       "EXTEND_IP" : ""}
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
#                     "EXTEND_IP" : ""}

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


# --> ONAP-HZ<--
ONAP_SERVER_INFO = {"IP": "10.110.73.138",
                    "USERNAME": "ute",
                    "PASSWORD": "Ut3pa5s#84b6",
                    "PORT": "22",
                    "EXTEND_IP": ""}

# OMS1_INFO = {"ID" : "265",
#            "NAME" : "IMP-265",
#            "SBI_IP" : "10.108.152.16",
#            "NBI_IP" : "10.108.152.17",
#            "USERNAME" : "Nemuadmin",
#            "PASSWORD" : "nemuuser",
#            "SUPER_PASSWORD" : "nsn",
#            "SBI_HEX_IP" : ""
#            }

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
