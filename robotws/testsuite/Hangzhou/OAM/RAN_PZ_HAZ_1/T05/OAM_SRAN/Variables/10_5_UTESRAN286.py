"""BTS variable file, this file is used in TA run."""
# ************************ BTS ***********************
SW_RELEASE = "SBTS24R1"
# --> sack file path used for emil <--
BTS_SACK_PATH = ""

BTS_INFO = {"ID": "2516",
            "IP": "10.106.245.144",
            "NAME": "SBTS2516",
            "MRBTS": "MRBTS-2516",
            "LNBTS": "LNBTS-37202",
            "SYSTEM_MODEL_TYPE": "ASOF",
            "LNT_VERSION": "TL17A_1701_07_1701_06",
            "PRODUCT_CODE": "476147A.101",
            "CORE_PRODUCT_CODE": "093232C.101",
            "CORE_SERIAL_NUMBER": "AY232701202",
            "EIF_PORT": "1",
            "SWITCH_PORT": "0/0"}

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
CELL1_INFO = {"ID": 3,
              "LNCELL": "NRCEL-3",
              "EARFCN": "643666",
              "INTER_EARFCN": "",
              "FREQUENCY": "3654.990 MHz",
              "EUTRAN_ID": int(BTS_INFO["ID"]) * 256 + 1,
              "PCI": "312",
              "GLOBAL_CELL_ID": "3"}

# CELL2_INFO = {"ID" : 1,
#              "LNCELL" : "LNCEL-1",
#              "EARFCN" : "2600",
#              "INTER_EARFCN" : "889.0 MHz",
#              "EUTRAN_ID" : int(BTS_INFO["ID"])*256+1,
#              "PCI" : "378",
#              "GLOBAL_CELL_ID" : "1"}

PRIMARY_CELL = 1
# SECONDARY_CELL = 2

# --> RF_Mode <--
# value can be 'FYRN' or 'AXIS'
RRU1_INFO = {"TYPE": "AWHQF",
             "POWERBREAK_PORT": "1",
             "POWERBREAK_IP": "10.108.153.122",
             "POWERBREAK_TYPE": "FACOM",
             "NODE": "1.1.1.1",
             "MO_IN_SCF": "/MRBTS-2516/EQM-1/APEQM-1/RMOD-3",
             "PRODUCT_CODE": "474876A.102",
             "CORE_PRODUCT_CODE": "473966A.101",
             "CORE_SERIAL_NUMBER": "EB2120R0117"
             }

BTS_INFOMODEL_PORT = 3600

# --> BTS control PC <--
BTS_PC_INFO = {"IP": "10.108.152.167",
               "LANIP": "192.168.255.126",
               "GATEWAY": "10.108.152.1",
               "USERNAME": "ute",
               "PASSWORD": "uteUTE!",
               "IPV6": "",
               "IPV6_GW": ""}

# ************************ Core Network ***********************
# --> Netact1013<--
# NETACT_SERVER_INFO = {"IP" : "10.41.146.72",
# "URL" : "srnclab1013lbwas.srnblr.nsn-rdnet.net",
# "USERNAME" : "omc",
# "PASSWORD" : "Medsql!_1893",
# "PORT" : "22",
# "EXTEND_IP" : ""}

# --> Netact 1014 <--
# NETACT_SERVER_INFO = {"IP" : "10.41.146.105",
# "URL" : "srnclab1014lbwas.srnblr.nsn-rdnet.net",
# "USERNAME" : "omc",
# "PASSWORD" : "omc",
# "PORT" : "22",
# "EXTEND_IP" : ""}

# --> Netact1027<--
# NETACT_SERVER_INFO = {"IP" : "10.41.148.99",
# "URL" : "srnclab1027lbwas.srnblr.nsn-rdnet.net",
# "USERNAME" : "omc",
# "PASSWORD" : "omc",
# "PORT" : "22",
# "EXTEND_IP" : ""}
# --> Netact1028<--
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
#                      "URL": "chen4lbwas.chen4.srnhz.nsn-rdnet.net",
#                      "USERNAME": "omc",
#                      "PASSWORD": "Nokia123!",
#                      "MR": "MRC-5GRAN-HZ/MR-5GRAN-HZ",
#                      "PORT": "22",
#                      "EXTEND_IP": ""}
NETACT_SERVER_INFO = {"IP": "10.107.245.84",
                      "URL": "https://qin6lbwas.qin6.srnhz.nsn-rdnet.net/",
                      "USERNAME": "omc",
                      "PASSWORD": "Nokia123!",
                      "MR": "MRC-5GRAN-HZ/MR-5GRAN-HZ",
                      "PORT": "22",
                      "EXTEND_IP": ""}
# --> NetAct2-Chen<--
# NETACT_SERVER_INFO = {"IP" : "10.68.84.15",
# "URL" : "chen2lbwas.chen2.srnhz.nsn-rdnet.net",
# "USERNAME" : "omc",
# "PASSWORD" : "Nokia123!",
# "PORT" : "22",
# "EXTEND_IP" : ""}
# --> Netact1025<--
# NETACT_SERVER_INFO = {"IP" : "10.41.148.19",
# "URL" : "srnclab1025lbwas.srnblr.nsn-rdnet.net",
# "USERNAME" : "omc",
# "PASSWORD" : "Medsql!_1893",
# "PORT" : "22",
# "EXTEND_IP" : ""}


# --> Netact1015<--
# NETACT_SERVER_INFO = {"IP" : "10.41.146.138",
#                        "URL" : "https://srnclab1015lbwas.srnblr.nsn-rdnet.net",
#                        "USERNAME" : "omc",
#                        "PASSWORD" : "Medsql!_1893",
#                        "PORT" : "22",
#                        "EXTEND_IP" : ""}
# --> Netact1016<--
# NETACT_SERVER_INFO = {"IP" : "10.41.146.171",
# "URL" : "srnclab1016lbwas.srnblr.nsn-rdnet.net",
# "USERNAME" : "omc",
# "PASSWORD" : "Medsql!_1893",
# "PORT" : "22",
# "EXTEND_IP" : ""}

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
BTS_POWERBREAK_PORT = ["FACOM:10.108.153.122:6"]
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
