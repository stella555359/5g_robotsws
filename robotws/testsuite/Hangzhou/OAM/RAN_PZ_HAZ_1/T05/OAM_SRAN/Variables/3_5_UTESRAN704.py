"""BTS variable file, this file is used in TA run."""
# ************************ BTS ***********************
SW_RELEASE = "SBTS00"
# --> sack file path used for emil <--
BTS_SACK_PATH = ""

BTS_INFO = {"ID": "2458",
            "IP": "10.106.170.69",
            "NAME": "SBTS2458",
            "MRBTS": "MRBTS-2458",
            "LNBTS": "LNBTS-2458",
            "SYSTEM_MODEL_TYPE": "ASIM",
            "LNT_VERSION": "TL18A_1808_03_1806_02",
            "PRODUCT_CODE": "475765A.104",
            "CORE_PRODUCT_CODE": "092865A.104",
            "CORE_SERIAL_NUMBER": "L1233402436",
            "EIF_PORT": "1",
            "SWITCH_PORT": "0/8",
            "PRIMARY_PB_TYPE": "TopYoung",
            "PRIMARY_PB_IP": "10.56.206.182",
            "PRIMARY_PB_PORT": "5",
            "SECONDARY_PB_TYPE": "TopYoung",
            "SECONDARY_PB_IP": "10.56.206.182",
            "SECONDARY_PB_PORT": "6"}

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

CELL_NUM = 5
CELL1_INFO = {"ID": 0,
              "LNCELL": "LNCEL-0",
              "EARFCN": "18200",
              "INTER_EARFCN": "",
              "FREQUENCY": "2130 MHz",
              "EUTRAN_ID": int(BTS_INFO["ID"]) * 256 + 1,
              "PCI": "377",
              "GLOBAL_CELL_ID": ""}

CELL2_INFO = {"ID": 3,
              "LNCELL": "LNCEL-5",
              "EARFCN": "5060",
              "INTER_EARFCN": "",
              "FREQUENCY": "734 MHz",
              "EUTRAN_ID": int(BTS_INFO["ID"]) * 256 + 1,
              "PCI": "4",
              "GLOBAL_CELL_ID": ""}

CELL3_INFO = {"ID": 5,
              "LNCELL": "LNCEL-7",
              "EARFCN": "5800",
              "INTER_EARFCN": "",
              "FREQUENCY": "741 MHz",
              "EUTRAN_ID": int(BTS_INFO["ID"]) * 256 + 1,
              "PCI": "5",
              "GLOBAL_CELL_ID": ""}

CELL4_INFO = {"ID": 24581,
              "LNCELL": "LNCEL-1",
              "EARFCN": "38750",
              "INTER_EARFCN": "",
              "FREQUENCY": "2310 MHz",
              "EUTRAN_ID": int(BTS_INFO["ID"]) * 256 + 1,
              "PCI": "130",
              "GLOBAL_CELL_ID": ""}

CELL5_INFO = {"ID": 24582,
              "LNCELL": "LNCEL-2",
              "EARFCN": "39000",
              "INTER_EARFCN": "",
              "FREQUENCY": "2335 MHz",
              "EUTRAN_ID": int(BTS_INFO["ID"]) * 256 + 1,
              "PCI": "132",
              "GLOBAL_CELL_ID": ""}
PRIMARY_CELL = 1
SECONDARY_CELL = 2

# --> RF_Mode <--
# value can be 'FYRN' or 'AXIS'
RRU1_INFO = {"TYPE": "AZQP",
             "POWERBREAK_PORT": "4",
             "POWERBREAK_IP": "10.56.206.179",
             "POWERBREAK_TYPE": "HBTE",
             "NODE": "172.16.37.128",
             "MO_IN_SCF": "",
             "PRODUCT_CODE": "475198A.102",
             "CORE_PRODUCT_CODE": "",
             "CORE_SERIAL_NUMBER": "1M204456938"
             }

RRU2_INFO = {"TYPE": "AEQE",
             "POWERBREAK_PORT": "1",
             "POWERBREAK_IP": "10.56.206.181",
             "POWERBREAK_TYPE": "TopYoung",
             "NODE": "172.16.33.128",
             "MO_IN_SCF": "",
             "PRODUCT_CODE": "474750A.102",
             "CORE_PRODUCT_CODE": "",
             "CORE_SERIAL_NUMBER": "1M211807080"
             }

RRU3_INFO = {"TYPE": "AHLOA",
             "POWERBREAK_PORT": "2",
             "POWERBREAK_IP": "10.56.206.180",
             "POWERBREAK_TYPE": "HBTE",
             "NODE": "172.16.37.129",
             "MO_IN_SCF": "",
             "PRODUCT_CODE": "	474331A.101",
             "CORE_PRODUCT_CODE": "",
             "CORE_SERIAL_NUMBER": "BL2051G1TP2"
             }

RRU4_INFO = {"TYPE": "AHPD",
             "POWERBREAK_PORT": "6",
             "POWERBREAK_IP": "10.56.206.179",
             "POWERBREAK_TYPE": "HBTE",
             "NODE": "172.22.9.2",
             "MO_IN_SCF": "",
             "PRODUCT_CODE": "474712A.101",
             "CORE_PRODUCT_CODE": "",
             "CORE_SERIAL_NUMBER": "RW222900576"
             }
RRU5_INFO = {"TYPE": "AHCA",
             "POWERBREAK_PORT": "3",
             "POWERBREAK_IP": "10.56.206.179",
             "POWERBREAK_TYPE": "HBTE",
             "NODE": "172.22.9.2",
             "MO_IN_SCF": "",
             "PRODUCT_CODE": "473966A.101",
             "CORE_PRODUCT_CODE": "",
             "CORE_SERIAL_NUMBER": "AS202612759"
             }
RRU6_INFO = {"TYPE": "AHEGB",
             "POWERBREAK_PORT": "3",
             "POWERBREAK_IP": "10.56.206.180",
             "POWERBREAK_TYPE": "HBTE",
             "NODE": "172.22.9.2",
             "MO_IN_SCF": "",
             "PRODUCT_CODE": "474090A.101",
             "CORE_PRODUCT_CODE": "",
             "CORE_SERIAL_NUMBER": "EA221152097"
             }

BTS_INFOMODEL_PORT = 3600

# --> BTS control PC <--
BTS_PC_INFO = {"IP": "10.108.229.40",
               "LANIP": "192.168.255.126",
               "GATEWAY": "10.108.152.1",
               "USERNAME": "ute",
               "PASSWORD": "UTE.debian12!",
               "IPV6": "",
               "IPV6_GW": ""}

# ************************ Core Network ***********************
# --> NetAct6-Jiang<--
NETACT_SERVER_INFO = {"IP": "10.107.183.26",
                      "URL": "han5lbwas.han5.srnhz.nsn-rdnet.net",
                      "USERNAME": "omc",
                      "PASSWORD": "Nokia123!",
                      "PORT": "22",
                      "EXTEND_IP": ""}
# --> Netact1027<--
# NETACT_SERVER_INFO = {"IP" : "10.41.148.99",
# "URL" : "srnclab1027lbwas.srnblr.nsn-rdnet.net",
# "USERNAME" : "omc",
# "PASSWORD" : "Medsql!_1893",
# "PORT" : "22",
# "EXTEND_IP" : ""}
# --> Netact 1028 <--
# NETACT_SERVER_INFO = {"IP" : "10.41.148.139",
# "URL" : "srnclab1028lbwas.srnblr.nsn-rdnet.net",
# "USERNAME" : "omc",
# "PASSWORD" : "Medsql!_1893",
# "PORT" : "22",
# "EXTEND_IP" : ""}
# --> NetAct6-Sui<--
# NETACT_SERVER_INFO = {"IP" : "10.110.144.154",
# "URL" : "sui6lbwas.sui6.srnhz.nsn-rdnet.net",
# "USERNAME" : "omc",
# "PASSWORD" : "Nokia126_",
# "PORT" : "22",
# "EXTEND_IP" : ""}
#  --> NetAct4-CHEN<--
# NETACT_SERVER_INFO = {"IP": "10.108.248.82",
#                       "URL": "chen4lbwas.chen4.srnhz.nsn-rdnet.net",
#                       "USERNAME": "omc",
#                       "PASSWORD": "Nokia123!",
#                       "PORT": "22",
#                       "EXTEND_IP": ""}
# --> NetAct2-Chen<--
# NETACT_SERVER_INFO = {"IP" : "10.68.84.15",
# "URL" : "chen2lbwas.chen2.srnhz.nsn-rdnet.net",
# "USERNAME" : "omc",
# "PASSWORD" : "Nokia123!",
# "PORT" : "22",
# "EXTEND_IP" : ""}
# --> Netact 1045 <--
# NETACT_SERVER_INFO = {"IP" : "10.43.48.114",
# "URL" : "srnclab1045lbwas.srnblr.nsn-rdnet.net",
# "USERNAME" : "omc",
# "PASSWORD" : "Medsql!_1893",
# "PORT" : "22",
# "EXTEND_IP" : ""}
#  --> NetAct-dhcp<--
# NETACT_SERVER_INFO_PNP = {
#     "IP": "10.82.47.46",
#     "URL": "srnclab2003lbwas.srnblr.nsn-rdnet.net",
#     "USERNAME": "omc",
#     "PASSWORD": "Medsql!_1893",
#     "PORT": "22",
#     "MR": "MRC-COMMON/MR-COMMON",
#     "EXTEND_IP": "0a52.2f39"}

# # --> OMS256 <--
# OMS1_INFO = {"ID" : "256",
# "NAME" : "OMS-256",
# "SBI_IP" : "10.68.160.244",
# "NBI_IP" : "10.68.160.243",
# "USERNAME" : "Nemuadmin",
# "PASSWORD" : "nemuuser",
# "SUPER_PASSWORD" : "nsn",
# "SBI_HEX_IP" : "0a44a0F4"
# }

# real MME information, need collect all mme infomation. ????
MME1_INFO = {"IP": "10.70.112.39"}

MME2_INFO = {"IP": "10.108.225.167"}

# ************************ UE ***********************
# --> UE <--
# CPE type can be: DEMING_CPE, ALTAIR_CPE, ALTAIR_DONGLE, HUAWEI_DONGLE
# address is the cpe's ip address or dongle's COM port num
UE1_INFO = {"TYPE": "",
            "ADDRESS": "",
            "FREQUENCY": "38050",
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
BTS_POWERBREAK_PORT = ["FACOM:10.108.151.78:7"]
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
