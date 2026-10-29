"""BTS variable file, this file is used in TA run."""
# ************************ BTS ***********************
SW_RELEASE = "SBTS00"
# --> sack file path used for emil <--
BTS_SACK_PATH = ""

BTS_INFO = {"ID": "10875",
            "IP": "10.106.205.204",
            "NAME": "SBTS10875",
            "MRBTS": "MRBTS-10875",
            "LNBTS": "LNBTS-10875",
            "SYSTEM_MODEL_TYPE": "ASIM",
            "LNT_VERSION": "TL17A_1701_07_1701_06",
            "PRODUCT_CODE": "475765A.104",
            "CORE_PRODUCT_CODE": "092865A.104",
            "CORE_SERIAL_NUMBER": "L1233304608",
            "EIF_PORT": "4",
            "SWITCH_PORT": "0/0",
            "PRIMARY_PB_TYPE": "FACOM",
            "PRIMARY_PB_IP": "10.108.151.208",
            "PRIMARY_PB_PORT": "8"}

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

CELL_NUM = 2
CELL1_INFO = {"ID": 0,
              "LNCELL": "LNCEL-0",
              "EARFCN": "2500",
              "INTER_EARFCN": "",
              "FREQUENCY": "879.0 MHz",
              "EUTRAN_ID": int(BTS_INFO["ID"]) * 256 + 1,
              "PCI": "377",
              "GLOBAL_CELL_ID": "0"}

CELL2_INFO = {"ID": 1,
              "LNCELL": "LNCEL-1",
              "EARFCN": "2600",
              "INTER_EARFCN": "889.0 MHz",
              "EUTRAN_ID": int(BTS_INFO["ID"]) * 256 + 1,
              "PCI": "378",
              "GLOBAL_CELL_ID": "1"}

PRIMARY_CELL = 1
# SECONDARY_CELL = 2

# --> RF_Mode <--
# value can be 'FYRN' or 'AXIS'
RRU1_INFO = {"TYPE": "AHCA",
             "POWERBREAK_PORT": "1",
             "POWERBREAK_IP": "10.108.166.195",
             "POWERBREAK_TYPE": "FACOM",
             "NODE": "1.1.1.1",
             "MO_IN_SCF": "/MRBTS-10875/EQM-1/APEQM-1/RMOD-1",
             "PRODUCT_CODE": "473966A.101",
             "CORE_PRODUCT_CODE": "473966A.101",
             "CORE_SERIAL_NUMBER": "AS203806230"
             }

BTS_INFOMODEL_PORT = 3600

# --> BTS control PC <--
BTS_PC_INFO = {"IP": "10.108.151.197",
               "LANIP": "192.168.255.126",
               "GATEWAY": "10.108.151.1",
               "USERNAME": "ute",
               "PASSWORD": "uteUTE!",
               "IPV6": "",
               "IPV6_GW": ""}

# ************************ Core Network ***********************
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
# --> NetAct5-Han<--
# NETACT_SERVER_INFO = {"IP" : "10.107.183.26",
# "URL" : "han5lbwas.han5.srnhz.nsn-rdnet.net",
# "USERNAME" : "omc",
# "PASSWORD" : "Nokia126_",
# "PORT" : "22",
# "EXTEND_IP" : ""}
#  --> NetAct3-zheng<--
# NETACT_SERVER_INFO = {"IP" : "10.110.188.146",
# "URL" : "zheng3lbwas.zheng3.srnhz.nsn-rdnet.net",
# "USERNAME" : "omc",
# "PASSWORD" : "Nokia126_",
# "PORT" : "22",
# "EXTEND_IP" : ""}
#  --> NetAct4-CHEN<--
# NETACT_SERVER_INFO = {"IP": "10.108.248.82",
#                      "URL": "chen4lbwas.chen4.srnhz.nsn-rdnet.net",
#                      "USERNAME": "omc",
#                      "PASSWORD": "Nokia126_",
#                      "PORT": "22",
#                      "EXTEND_IP": ""}
# --> NetAct7-jiang<--
NETACT_SERVER_INFO = {"IP": "10.56.3.18",
                      "URL": "jiang7lbwas.jiang7.srnhz.nsn-rdnet.net",
                      "USERNAME": "omc",
                      "PASSWORD": "Nokia123!",
                      "PORT": "22",
                      "EXTEND_IP": ""}
# --> NetAct2-Chen<--
# NETACT_SERVER_INFO = {"IP" : "10.68.84.15",
# "URL" : "chen2lbwas.chen2.srnhz.nsn-rdnet.net",
# "USERNAME" : "omc",
# "PASSWORD" : "Nokia123!",
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
BTS_POWERBREAK_PORT = ["FACOM:10.108.151.208:8"]
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
