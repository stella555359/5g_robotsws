"""BTS variable file, this file is used in TA run."""
# ************************ BTS ***********************
SW_RELEASE = "SBTS00"
# --> sack file path used for emil <--
BTS_SACK_PATH = ""

BTS_INFO = {"ID": "884",
            "IP": "10.97.92.252",
            "NAME": "BTS884",
            "MRBTS": "MRBTS-884",
            "LNBTS": "LNBTS-884",
            "SYSTEM_MODEL_TYPE": "ASIB",
            "LNT_VERSION": "TL18A_1808_03_1806_02",
            "PRODUCT_CODE": "473764A.101",
            "CORE_PRODUCT_CODE": "089596A.102",
            "CORE_SERIAL_NUMBER": "L1190309132",
            "EIF_PORT": "1",
            "SWITCH_PORT": "0/0",
            "PRIMARY_PB_IP": "10.108.191.2",
            "PRIMARY_PB_TYPE": "FPFH",
            "PRIMARY_PB_Port": "3",
            "SECONDARY_PB_IP": "10.108.191.2",
            "SECONDARY_PB_PORT": "1",
            "SECONDARY_PB_TYPE": "FPFH"
            }
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

CELL_NUM = 3
CELL1_INFO = {"ID": 1,
              "LNCELL": "LNCEL-1",
              "EARFCN": "850",
              "INTER_EARFCN": "37900",
              "FREQUENCY": "2455 MHz",
              "EUTRAN_ID": int(BTS_INFO["ID"]) * 256 + 1,
              "PCI": "1",
              "GLOBAL_CELL_ID": "0"}

CELL2_INFO = {"ID": 3,
              "LNCELL": "LNCEL-3",
              "EARFCN": "700",
              "INTER_EARFCN": "37900",
              "EUTRAN_ID": int(BTS_INFO["ID"]) * 256 + 1,
              "PCI": "3",
              "GLOBAL_CELL_ID": ""}

CELL3_INFO = {"ID": 4,
              "LNCELL": "LNCEL-4",
              "EARFCN": "700",
              "INTER_EARFCN": "",
              "EUTRAN_ID": int(BTS_INFO["ID"]) * 256 + 1,
              "PCI": "4",
              "GLOBAL_CELL_ID": ""}

PRIMARY_CELL = 1
SECONDARY_CELL = 2

# --> RF_Mode <--
# value can be 'FYRN' or 'AXIS'
RRU1_INFO = {"TYPE": "AHDB",
             "NODE": "1.1.1.1",
             "POWERBREAK_PORT": "FPFH:10.108.191.2:6",
             "MO_IN_SCF": "MRBTS-6474/EQM-1/APEQM-1/RMOD-2",
             "PRODUCT_CODE": "474257A.101",
             "CORE_PRODUCT_CODE": "474257A.101",
             "CORE_SERIAL_NUMBER": "EA191772253"
             }

RRU2_INFO = {"TYPE": "AHCE",
             "NODE": "1.1.1.1",
             "POWERBREAK_PORT": "FPFH:10.108.191.2:2",
             "MO_IN_SCF": "MRBTS-6474/EQM-1/APEQM-1/RMOD-3",
             "PRODUCT_CODE": "474914A.101",
             "CORE_PRODUCT_CODE": "",
             "CORE_SERIAL_NUMBER": "EB191760214"
             }

RRU3_INFO = {"TYPE": "AHEGB",
             "NODE": "",
             "POWERBREAK_PORT": "FPFH:10.108.191.2:5",
             "MO_IN_SCF": "MRBTS-6474/EQM-1/APEQM-1/RMOD-1",
             "PRODUCT_CODE": "474090A.101",
             "CORE_PRODUCT_CODE": "",
             "CORE_SERIAL_NUMBER": "EA203761430"
             }

BTS_INFOMODEL_PORT = 12345

# --> BTS control PC <--
BTS_PC_INFO = {"IP": "10.97.92.252",
               "LANIP": "10.97.92.252",
               "GATEWAY": "10.97.92.252",
               "USERNAME": "ute",
               "PASSWORD": "uteUTE!",
               "IPV6": "",
               "IPV6_GW": ""}

# ************************ Core Network ***********************
# --> Netact 304<--
# NETACT_SERVER_INFO = {"IP" : "10.91.150.136",
# "URL" : "https://clab304lbwas.netact.nsn-rdnet.net/startpage",
# "USERNAME" : "omc2",
# "PASSWORD" : "zhouhang2",
# "PORT" : "22",
# "EXTEND_IP" : "10.92.97.46"}


# --> Netact 362 <--
# NETACT_SERVER_INFO = {"IP" : "10.92.97.113",
# "URL" : "clab362lbwas.netact.nsn-rdnet.net",
# "USERNAME" : "omc2",
# "PASSWORD" : "zhouhang2",
# "PORT" : "22",
# "EXTEND_IP" : ""}

# --> Netact 2519 <--
# NETACT_SERVER_INFO = {"IP" : "10.91.146.210",
# "URL" : "clab2519lbwas.netact.nsn-rdnet.net",
# "USERNAME" : "omc2",
# "PASSWORD" : "zhouhang2",
# "PORT" : "22",
# "EXTEND_IP" : ""}

# --> Netact 1025 <--
# NETACT_SERVER_INFO = {"IP" : "10.41.148.19",
# "URL" : "https://srnclab1025lbwas.srnblr.nsn-rdnet.net/startpage/",
# "USERNAME" : "omc",
# "PASSWORD" : "omc",
# "PORT" : "22",
# "EXTEND_IP" : "0a29:941c"}

# --> Netact 2227 <--
# NETACT_SERVER_INFO = {"IP" : "10.32.179.232",
#                      "URL" : "chttps://clab2227lbwas.netact.nsn-rdnet.net/startpage/",
#                      "USERNAME" : "omc",
#                      "PASSWORD" : "omc",
#                      "PORT" : "22",
#                      "EXTEND_IP" : ""}

# --> Netact 1016 <--
# NETACT_SERVER_INFO = {"IP" : "10.41.146.171",
#                        "URL" : "https://srnclab1016lbwas.srnblr.nsn-rdnet.net/startpage/",
#                        "USERNAME" : "omc",
#                        "PASSWORD" : "omc",
#                         "PORT" : "22",
#                        "EXTEND_IP" : "0a29:92b4"}

# --> Netact 1027 <--
# NETACT_SERVER_INFO = {"IP" : "10.41.148.99",
#                     "URL" : "https://srnclab1027lbwas.srnblr.nsn-rdnet.net/startpage/",
#                     "USERNAME" : "omc",
#                     "PASSWORD" : "omc",
#                     "PORT" : "22",
#                     "EXTEND_IP" : "0a29:946c"}

# --> Netact 1013 <--
# NETACT_SERVER_INFO = {"IP" : "10.41.146.72",
# "URL" : "https://srnclab1013lbwas.srnblr.nsn-rdnet.net/startpage/",
# "USERNAME" : "omc",
# "PASSWORD" : "Medsql!_1893",
# "PORT" : "22",
# "EXTEND_IP" : "0a29:9251"}

# --> Netact1028<--
# NETACT_SERVER_INFO = {"IP" : "10.41.148.139",
#                       "URL" : "srnclab1028lbwas.srnblr.nsn-rdnet.net",
#                       "USERNAME" : "omc",
#                       "PASSWORD" : "Medsql!_1893",
#                       "PORT" : "22",
#                       "EXTEND_IP" : ""}

#  --> NetAct6-sui<--
# NETACT_SERVER_INFO = {"IP" : "10.110.144.154",
#                       "URL" : "sui6lbwas.sui6.srnhz.nsn-rdnet.net",
#                       "USERNAME" : "omc",
#                       "PASSWORD" : "Nokia126_",
#                       "PORT" : "22",
#                       "EXTEND_IP" : ""}

#  --> NetAct5-han<--
# NETACT_SERVER_INFO = {"IP" : "10.107.183.26",
#                       "URL" : "han5lbwas.han5.srnhz.nsn-rdnet.net",
#                       "USERNAME" : "omc",
#                       "PASSWORD" : "Nokia126_",
#                       "PORT" : "22",
#                       "EXTEND_IP" : ""}
#  --> NetAct3-zheng<--
# NETACT_SERVER_INFO = {"IP" : "10.110.188.146",
#                       "URL" : "zheng3lbwas.zheng3.srnhz.nsn-rdnet.net",
#                       "USERNAME" : "omc",
#                       "PASSWORD" : "Nokia126_",
#                       "PORT" : "22",
#                       "EXTEND_IP" : ""}
#  --> Jiang7-CHEN<--
NETACT_SERVER_INFO = {"IP": "10.56.3.19",
                      "URL": "https://jiang7lbwas.jiang7.srnhz.nsn-rdnet.net/",
                      "USERNAME": "omc",
                      "PASSWORD": "Nokia123!",
                      "MR": "MRC-5GRAN-HZ/MR-5GRAN-HZ",
                      "PORT": "22",
                      "EXTEND_IP": ""}
# --> Netact 1014 <--
# NETACT_SERVER_INFO = {"IP" : "10.41.146.105",
#                       "URL" : "https://srnclab1014lbwas.srnblr.nsn-rdnet.net/startpage/",
#                       "USERNAME" : "omc",
#                       "PASSWORD" : "Medsql!_1893",
#                       "PORT" : "22",
#                       "EXTEND_IP" : "0a29.9272"}

# --> Netact 1015 <--
# NETACT_SERVER_INFO = {"IP" : "10.41.146.138",
#                        "URL" : "https://srnclab1015lbwas.srnblr.nsn-rdnet.net/startpage/",
#                        "USERNAME" : "omc",
#                        "PASSWORD" : "Medsql!_1893",
#                        "PORT" : "22",
#                        "EXTEND_IP" : "0a29:9293"}

# --> Netact 1051 <--
# NETACT_SERVER_INFO = {"IP" : "10.63.2.129",
# "URL" : "https://srnclab1051lbwas.srnblr.nsn-rdnet.net/startpage/",
# "USERNAME" : "omc",
# "PASSWORD" : "Medsql!_1893",
# "PORT" : "22",
# "EXTEND_IP" : ""}

# --> Netact 876 <--
# NETACT_SERVER_INFO = {"IP" : "10.92.97.113",
# "URL" : "clab876lbwas.netact.nsn-rdnet.net",
# "USERNAME" : "omc2",
# "PASSWORD" : "zhouhang2",
# "PORT" : "22",
# "EXTEND_IP" : ""}

# --> Netact 1832<--
# NETACT_SERVER_INFO = {"IP" : "10.91.152.250",
#                    "URL" : "https://clab1832lbwas.netact.nsn-rdnet.net/startpage",
#                    "USERNAME" : "omc2",
#                    "PASSWORD" : "zhouhang2",
#                    "PORT" : "22",
#                    "EXTEND_IP" : "10.92.97.46"}

# --> Netact 1223 <--
# NETACT_SERVER_INFO = {"IP" : "10.91.146.214",
# "URL" : "https://clab1223lbwas.netact.nsn-rdnet.net/authentication/Login",
# "USERNAME" : "omc2",
# "PASSWORD" : "zhouhang2",
# "PORT" : "22",
# "EXTEND_IP" : "10.91.144.228"}

# --> Netact 1700 <--
# NETACT_SERVER_INFO = {"IP" : "10.92.99.20",
#                     "URL" : "https://clab1700lbwas.netact.nsn-rdnet.net/authentication/Login",
#                     "USERNAME" : "omc",
#                     "PASSWORD" : "Admin1700--User",
#                     "PORT" : "22",
#                      "EXTEND_IP" : "10.92.99.19"}
#  --> NetAct-dhcp<--
NETACT_SERVER_INFO_PNP = {
    "IP": "10.82.47.46",
    "URL": "srnclab2003lbwas.srnblr.nsn-rdnet.net",
    "USERNAME": "omc",
    "PASSWORD": "Medsql!_1893",
    "PORT": "22",
    "MR": "MRC-COMMON/MR-COMMON",
    "EXTEND_IP": "0a52.2f39"}
# --> Netact 1597 <--
# NETACT_SERVER_INFO = {"IP" : "10.92.99.87",
# "URL" : "https://clab1597lbwas.netact.nsn-rdnet.net/authentication/Login",
# "USERNAME" : "omc2",
# "PASSWORD" : "zhouhang2",
# "PORT" : "22",
#  "EXTEND_IP" : ""}

# --> OMS254 <--
# OMS1_INFO = {"ID" : "254",
# "NAME" : "OMS-254",
# "SBI_IP" : "10.68.160.240",
# "NBI_IP" : "10.68.160.239",
# "USERNAME" : "Nemuadmin",
# "PASSWORD" : "nemuuser",
# "SUPER_PASSWORD" : "nsn",
# "SBI_HEX_IP" : "0a44a0f4"
# }

# # --> OMS258 <--
# # OMS1_INFO = {"ID" : "258",
# # "NAME" : "OMS-258",
# # "SBI_IP" : "10.68.160.250",
# # "NBI_IP" : "10.68.160.251",
# # "USERNAME" : "Nemuadmin",
# # "PASSWORD" : "nemuuser",
# # "SUPER_PASSWORD" : "nsn",
# # "SBI_HEX_IP" : ""
# # }

# OMS1_INFO = {"ID" : "253",
#                       "NAME" : "OMS-253",
#                       "SBI_IP" : "10.68.160.238",
#                       "NBI_IP" : "10.68.160.237",
#                       "USERNAME" : "Nemuadmin",
#                       "PASSWORD" : "nemuuser",
#                       "SUPER_PASSWORD" : "nsn",
#                       "SBI_HEX_IP" : "0a44a0EE"
#             }

# --> OMS255<--
# OMS1_INFO = {"ID" : "255",
# "NAME" : "OMS255",
# "SBI_IP" : "10.68.160.242",
# "NBI_IP" : "10.68.160.241",
# "USERNAME" : "Nemuadmin",
# "PASSWORD" : "nemuuser",
# "SUPER_PASSWORD" : "nsn",
# "SBI_HEX_IP" : "0A44A0FA"
# }

# --> OMS256<--
# OMS1_INFO = {"ID" : "256",
# "NAME" : "OMS-256",
# "SBI_IP" : "10.68.160.244",
# "NBI_IP" : "10.68.160.243",
# "USERNAME" : "Nemuadmin",
# "PASSWORD" : "nemuuser",
# "SUPER_PASSWORD" : "nsn",
# "SBI_HEX_IP" : "0a44a0F4"
# }

# --> OMS1501 <--
# OMS1_INFO = {"ID" : "1501",
# "NAME" : "OMS-1501",
# "SBI_IP" : "10.68.152.202",
# "NBI_IP" : "10.68.152.203",
# "USERNAME" : "Nemuadmin",
# "PASSWORD" : "nemuuser",
# "SUPER_PASSWORD" : "nsn",
# "SBI_HEX_IP" : "0a4498CA"
# }

# --> OMS260 <--
# OMS1_INFO = {"ID" : "260",
# "NAME" : "OMS-260",
# "SBI_IP" : "10.108.152.2",
# "NBI_IP" : "10.108.152.1",
# "USERNAME" : "Nemuadmin",
# "PASSWORD" : "nemuuser",
# "SUPER_PASSWORD" : "nsn",
# "SBI_HEX_IP" : ""
# }

# --> OMS262 <--
OMS1_INFO = {"ID": "262",
             "NAME": "OMS-262",
             "SBI_IP": "10.108.152.8",
             "NBI_IP": "10.108.152.7",
             "USERNAME": "Nemuadmin",
             "PASSWORD": "nemuuser",
             "SUPER_PASSWORD": "nsn",
             "SBI_HEX_IP": ""
             }

# --> OMS261 <--
# OMS1_INFO = {"ID" : "261",
# "NAME" : "OMS-261",
# "SBI_IP" : "10.108.152.6",
# "NBI_IP" : "10.108.152.5",
# "USERNAME" : "Nemuadmin",
# "PASSWORD" : "nemuuser",
# "SUPER_PASSWORD" : "nsn",
# "SBI_HEX_IP" : ""
# }


# OMS2_INFO = {"ID" : "262",
# "NAME" : "OMS-262",
# "SBI_IP" : "10.108.152.8",
# "NBI_IP" : "10.108.152.7",
# "USERNAME" : "Nemuadmin",
# "PASSWORD" : "nemuuser",
# "SUPER_PASSWORD" : "nsn",
# "SBI_HEX_IP" : ""
# }

# --> OMS258<--
OMS2_INFO = {"ID": "258",
             "NAME": "OMS-258",
             "SBI_IP": "10.68.160.250",
             "NBI_IP": "10.68.160.251",
             "USERNAME": "Nemuadmin",
             "PASSWORD": "nemuuser",
             "SUPER_PASSWORD": "nsn",
             "SBI_HEX_IP": "0a44a0F4"
             }

# real MME information, need collect all mme infomation. ????
MME1_INFO = {"IP": "10.108.225.167"}

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
BTS_POWERBREAK_PORT = {"FACOM:10.68.170.179:3"}

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

AUTO_SNAPSHOT_FLAG = False
COUNTER_REFRESH_PERIOD = "15min"
AUTO_SNAPSHOT_FLAG = False
COUNTER_REFRESH_PERIOD = "15min"
ONAIR_MAX_DURATION = "10min"
BTS_ONAIR_MAX_TRIAL_TIMES = 1
ONAIR_CHECK_MSG = ["PBCH"]
ONAIR_CHECK_MODE = "INFOMODEL"
ONE_KEY_CAPTURE_LOGS_OPTION = ""
ONE_KEY_CAPTURE_LOGS_FLAG = False


# for EI configuration move from RobotWS.html to here
# CONFIGURATION = 'evcommon'


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
