"""BTS variable file, this file is used in TA run."""
# ************************ BTS ***********************
SW_RELEASE = "SBTS00"
# --> sack file path used for emil <--
BTS_SACK_PATH = ""

BTS_INFO = {
    "ID": "5348",
    "IP": "10.106.170.72",
    "NAME": "3_5_UTE4G225",
    "MRBTS": "MRBTS-5348",
    "LNBTS": "LNBTS-5348",
    "SYSTEM_MODEL_TYPE": "ASIL",
    "LNT_VERSION": "TL17A_1701_07_1701_06",
    "PRODUCT_CODE": "4473764A.102",
    "CORE_PRODUCT_CODE": "089596A.204",
    "CORE_SERIAL_NUMBER": "DH232142005",
    "EIF_PORT": "2",
    "SWITCH_PORT": "0/0",
    "PRIMARY_PB_IP": "10.56.206.184",
    "PRIMARY_PB_Port": "5",
    "SECONDARY_PB_IP": "10.56.206.183",
    "SECONDARY_PB_PORT": "6",
    "SECONDARY_PB_TYPE": "TOPYOUNG"}

# --> External_System_Module_FBBA&FBIH <--
EXT_MODULE1 = {
    "TYPE": "ABIO",
    "NAME": "XXXX",
    "MO_IN_SCF": "XXXXX",
    "PRODUCT_CODE": "XXXXX",
    "SERIAL_NUMBER": "XXXX",
}

EXT_MODULE2 = {
    "TYPE": "ABIN",
    "NAME": "XXXX",
    "MO_IN_SCF": "XXXXX",
    "PRODUCT_CODE": "XXXXX",
    "SERIAL_NUMBER": "XXXX",
}

EXT_MODULE3 = {
    "TYPE": "ABIA",
    "NAME": "XXXX",
    "MO_IN_SCF": "XXXXX",
    "PRODUCT_CODE": "XXXXX",
    "SERIAL_NUMBER": "XXXX",
}

CELL_NUM = 1
CELL1_INFO = {
    "ID": 1,
    "LNCELL": "LNCEL-1",
    "EARFCN": "1900",
    "INTER_EARFCN": "",
    "FREQUENCY": "2595 MHz",
    "EUTRAN_ID": int(BTS_INFO["ID"])*256+1,
    "PCI": "221",
    "GLOBAL_CELL_ID": "",
}

CELL2_INFO = {
    "ID": 2,
    "LNCELL": "LNCEL-2",
    "EARFCN": "1900",
    "INTER_EARFCN": "",
    "FREQUENCY": "2595 MHz",
    "EUTRAN_ID": int(BTS_INFO["ID"])*256+2,
    "PCI": "221",
    "GLOBAL_CELL_ID": "",
}

CELL3_INFO = {
    "ID": 3,
    "LNCELL": "LNCEL-3",
    "EARFCN": "1900",
    "INTER_EARFCN": "",
    "FREQUENCY": "2595 MHz",
    "EUTRAN_ID": int(BTS_INFO["ID"])*256+3,
    "PCI": "221",
    "GLOBAL_CELL_ID": ""
}

PRIMARY_CELL = 1
SECONDARY_CELL = 2

# --> RF_Mode <--
# value can be 'FYRN' or 'AXIS'
RRU1_INFO = {"TYPE": "AZHM",
             "NODE": "",
             "POWERBREAK_PORT": "2",
             "POWERBREAK_IP": "10.56.206.185",
             "POWERBREAK_TYPE": "TOPYOUNG",
             "MO_IN_SCF": "",
             "PRODUCT_CODE": "",
             "CORE_PRODUCT_CODE": "",
             "CORE_SERIAL_NUMBER": ""
             }
RRU7_INFO = {"TYPE": "AKNB",
             "NODE": "",
             "POWERBREAK_PORT": "4",
             "POWERBREAK_IP": "10.56.206.185",
             "POWERBREAK_TYPE": "TOPYOUNG",
             "MO_IN_SCF": "",
             "PRODUCT_CODE": "",
             "CORE_PRODUCT_CODE": "",
             "CORE_SERIAL_NUMBER": ""
             }
RRU3_INFO = {"TYPE": "AHLOA",
             "NODE": "",
             "POWERBREAK_PORT": "1",
             "POWERBREAK_IP": "10.56.206.185",
             "POWERBREAK_TYPE": "TOPYOUNG",
             "MO_IN_SCF": "",
             "PRODUCT_CODE": "",
             "CORE_PRODUCT_CODE": "",
             "CORE_SERIAL_NUMBER": ""
             }
RRU4_INFO = {"TYPE": "AHDB",
             "NODE": "",
             "POWERBREAK_PORT": "5",
             "POWERBREAK_IP": "10.56.206.185",
             "POWERBREAK_TYPE": "TOPYOUNG",
             "MO_IN_SCF": "",
             "PRODUCT_CODE": "",
             "CORE_PRODUCT_CODE": "",
             "CORE_SERIAL_NUMBER": ""
             }
RRU2_INFO = {"TYPE": "AZHA",
             "NODE": "",
             "POWERBREAK_PORT": "6",
             "POWERBREAK_IP": "10.56.206.185",
             "POWERBREAK_TYPE": "TOPYOUNG",
             "MO_IN_SCF": "",
             "PRODUCT_CODE": "",
             "CORE_PRODUCT_CODE": "",
             "CORE_SERIAL_NUMBER": ""
             }
RRU8_INFO = {"TYPE": "AHCA",
             "NODE": "",
             "POWERBREAK_PORT": "4",
             "POWERBREAK_IP": "10.56.206.186",
             "POWERBREAK_TYPE": "TOPYOUNG",
             "MO_IN_SCF": "",
             "PRODUCT_CODE": "",
             "CORE_PRODUCT_CODE": "",
             "CORE_SERIAL_NUMBER": ""
             }
RRU5_INFO = {"TYPE": "FXCB",
             "NODE": "",
             "POWERBREAK_PORT": "3",
             "POWERBREAK_IP": "10.56.206.185",
             "POWERBREAK_TYPE": "TOPYOUNG",
             "MO_IN_SCF": "",
             "PRODUCT_CODE": "",
             "CORE_PRODUCT_CODE": "",
             "CORE_SERIAL_NUMBER": ""
             }
RRU9_INFO = {"TYPE": "AHCA",
             "NODE": "",
             "POWERBREAK_PORT": "2",
             "POWERBREAK_IP": "10.56.206.186",
             "POWERBREAK_TYPE": "TOPYOUNG",
             "MO_IN_SCF": "",
             "PRODUCT_CODE": "",
             "CORE_PRODUCT_CODE": "",
             "CORE_SERIAL_NUMBER": ""
             }

BTS_INFOMODEL_PORT = 3600

# --> BTS control PC <--
BTS_PC_INFO = {
    "IP": "10.108.229.54",
    "LANIP": "192.168.255.126",
    "GATEWAY": "10.108.161.1",
    "USERNAME": "ute",
    "PASSWORD": "UTE.debian12",
    "IPV6": "",
    "IPV6_GW": "",
}

# ************************ Core Network ***********************

# --> Netact1013<--
# NETACT_SERVER_INFO = {"IP": "10.41.146.72",
# "URL": "srnclab1013lbwas.srnblr.nsn-rdnet.net",
# "USERNAME": "omc",
# "PASSWORD": "omc",
# "PORT": "22",
# "EXTEND_IP": ""},

# --> Netact 1014 <--
# NETACT_SERVER_INFO = {
#    "IP": "10.41.146.105",
#    "URL": "srnclab1014lbwas.srnblr.nsn-rdnet.net",
#    "USERNAME": "omc",
#    "PASSWORD": "Medsql!_1893",
#    "PORT": "22",
#    "EXTEND_IP": "",
# }
# --> Netact HAN <--
# NETACT_SERVER_INFO = {
#     "IP": "10.107.183.26",
#     "URL": "han5lbwas.han5.srnhz.nsn-rdnet.net",
#     "USERNAME": "omc",
#     "PASSWORD": "Nokia126_",
#     "PORT": "22",
#     "EXTEND_IP": "",
# }
#  --> NetAct4-CHEN<--
# NETACT_SERVER_INFO = {"IP": "10.108.248.82",
#                       "URL": "chen4lbwas.chen4.srnhz.nsn-rdnet.net",
#                       "USERNAME": "omc",
#                       "PASSWORD": "Nokia123!",
#                       "PORT": "22",
#                       "MR": "MRC-5GRAN-HZ/MR-5GRAN-HZ",
#                       "EXTEND_IP": ""}

#  --> NetAct7-Jiang<--
# NETACT_SERVER_INFO = {"IP": "10.56.3.18",
#                      "URL": "jiang7lbwas.jiang7.srnhz.nsn-rdnet.net",
#                      "USERNAME": "omc",
#                      "PASSWORD": "Nokia123!",
#                      "MR": "MRC-5G-HZ/MR-5G-HZ",
#                      "PORT": "22",
#                      "EXTEND_IP": ""}
#  --> NetAct-han5<--
NETACT_SERVER_INFO = {"IP": "10.107.183.26",
                      "URL": "han5lbwas.han5.srnhz.nsn-rdnet.net",
                      "USERNAME": "omc",
                      "PASSWORD": "Nokia123!",
                      "MR": "MRC-HZ-5G/MR-5G-Test",
                      "PORT": "22",
                      "EXTEND_IP": ""}

#  --> NetAct-zheng3<--
# NETACT_SERVER_INFO = {"IP": "10.110.188.136",
#                       "URL": "zheng3lbwas.zheng3.srnhz.nsn-rdnet.net",
#                       "USERNAME": "omc",
#                       "PASSWORD": "Nokia123!",
#                       "MR": "MRC-5G/MR-5G-HZ",
#                       "PORT": "22",
#                       "EXTEND_IP": ""}
# # --> Netact1027<--
# NETACT_SERVER_INFO = {
#    "IP": "10.41.148.99",
#    "URL": "srnclab1027lbwas.srnblr.nsn-rdnet.net",
#    "USERNAME": "omc",
#    "PASSWORD": "Medsql!_1893",
#    "PORT": "22",
#    "EXTEND_IP": "",
# }
# --> Netact1025<--
# NETACT_SERVER_INFO = {
#    "IP": "10.41.148.19",
#    "URL": "srnclab1025lbwas.srnblr.nsn-rdnet.net",
#    "USERNAME": "omc",
#    "PASSWORD": "Medsql!_1893",
#    "PORT": "22",
#    "EXTEND_IP": "",
# }
# --> Netact1015<--
# NETACT_SERVER_INFO = {
# "IP": "10.41.146.138",
# "URL": "https://srnclab1015lbwas.srnblr.nsn-rdnet.net",
# "USERNAME": "omc",
# "PASSWORD": "Medsql!_1893",
# "PORT": "22",
# "EXTEND_IP": ""},
# --> Netact1016<--
# NETACT_SERVER_INFO = {
# "IP": "10.41.146.171",
# "URL": "srnclab1016lbwas.srnblr.nsn-rdnet.net",
# "USERNAME": "omc",
# "PASSWORD": "Medsql!_1893",
# "PORT": "22",
# "EXTEND_IP": ""},
# --> OMS258 <--
# OMS1_INFO = {"ID" : "258",
# "NAME" : "OMS-258",
# "SBI_IP" : "10.68.160.250",
# "NBI_IP" : "10.68.160.251",
# "USERNAME" : "Nemuadmin",
# "PASSWORD" : "nemuuser",
# "SUPER_PASSWORD" : "nsn",
# "SBI_HEX_IP" : "EA"
# }
# --> OMS1501 <--

# OMS2_INFO = {"ID" : "1501",
# "NAME" : "OMS1501",
# "SBI_IP" : "10.68.152.202",
# "NBI_IP" : "10.68.152.203",
# "USERNAME" : "Nemuadmin",
# "PASSWORD" : "nemuuser",
# "SUPER_PASSWORD" : "nsn",
# "SBI_HEX_IP" : "0A4498CA"
# }
# --> OMS256 <--
# OMS1_INFO = {"ID" : "256",
# "NAME" : "OMS-256",
# "SBI_IP" : "10.68.160.244",
# "NBI_IP" : "10.68.160.245",
# "USERNAME" : "Nemuadmin",
# "PASSWORD" : "nemuuser",
# "SUPER_PASSWORD" : "nsn",
# "SBI_HEX_IP" : "0A44A0F2"
# }
# --> OMS250 <--
# OMS1_INFO = {"ID" : "258",
# "NAME" : "OMS-258",
# "SBI_IP" : "10.68.160.250",
# "NBI_IP" : "10.68.160.251",
# "USERNAME" : "Nemuadmin",
# "PASSWORD" : "nemuuser",
# "SUPER_PASSWORD" : "nsn",
# "SBI_HEX_IP" : "0A44A0F2"
# }
# --> OMS254 <--
# OMS1_INFO = {"ID" : "254",
# "NAME" : "OMS-254",
# "SBI_IP" : "10.68.160.240",
# "NBI_IP" : "10.68.160.241",
# "USERNAME" : "Nemuadmin",
# "PASSWORD" : "nemuuser",
# "SUPER_PASSWORD" : "nsn",
# "SBI_HEX_IP" : "0A44A0F2"
# }

# --> IMP266 <--
# OMS1_INFO = {"ID" : "266",
# "NAME" : "OMS-266",
# "SBI_IP" : "10.108.152.36",
# "NBI_IP" : "10.108.152.35",
# "USERNAME" : "Nemuadmin",
# "PASSWORD" : "nemuuser",
# "SUPER_PASSWORD" : "nsn",
# "SBI_HEX_IP" : "0A44A0F2"
# }
# #--> IMP270 <--
# OMS1_INFO = {"ID" : "270",
# "NAME" : "OMS-270",
# "SBI_IP" : "10.108.152.54",
# "NBI_IP" : "10.108.152.55",
# "USERNAME" : "Nemuadmin",
# "PASSWORD" : "nemuuser",
# "SUPER_PASSWORD" : "nsn",
# "SBI_HEX_IP" : "0A44A0F2"
# }
# # --> OMS267 <--
# OMS1_INFO = {"ID" : "267",
# "NAME" : "OMS-254",
# "SBI_IP" : "10.108.152.34",
# "NBI_IP" : "10.108.152.33",
# "USERNAME" : "Nemuadmin",
# "PASSWORD" : "nemuuser",
# "SUPER_PASSWORD" : "nsn",
# "SBI_HEX_IP" : "0A44A0F2"
# }
# --> OMS266 <--
# OMS1_INFO = {"ID" : "266",
# "NAME" : "OMS-266",
# "SBI_IP" : "10.108.152.22",
# "NBI_IP" : "10.108.152.23",
# "USERNAME" : "Nemuadmin",
# "PASSWORD" : "nemuuser",
# "SUPER_PASSWORD" : "nsn",
# "SBI_HEX_IP" : "0A44A0F2"
# }
# --> OMS255 <--
# OMS1_INFO = {"ID" : "255",
# "NAME" : "OMS-255",
# "SBI_IP" : "10.68.160.242",
# "NBI_IP" : "10.68.160.241",
# "USERNAME" : "Nemuadmin",
# "PASSWORD" : "nemuuser",
# "SUPER_PASSWORD" : "nsn",
# "SBI_HEX_IP" : "0A44A0F2"
# }
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

# OMS1_INFO = {"ID" : "258",
# "NAME" : "OMS-258",
# "SBI_IP" : "10.68.160.250",
# "NBI_IP" : "10.68.160.251",
# "USERNAME" : "Nemuadmin",
# "PASSWORD" : "nemuuser",
# "SUPER_PASSWORD" : "nsn",
# "SBI_HEX_IP" : "0a44a0FA"
# }

# OMS1_INFO = {"ID" : "263",
# "NAME" : "OMS-263",
# "SBI_IP" : "10.108.152.11",
# "NBI_IP" : "10.108.152.10",
# "USERNAME" : "Nemuadmin",
# "PASSWORD" : "nemuuser",
# "SUPER_PASSWORD" : "nsn",
# "SBI_HEX_IP" : "0a44a0FA"
# }

# real MME information, need collect all mme infomation. ????
MME1_INFO = {"IP": "10.69.207.10"}

MME2_INFO = {"IP": "10.56.3.147"}

# ************************ UE ***********************
# --> UE <--
# CPE type can be: DEMING_CPE, ALTAIR_CPE, ALTAIR_DONGLE, HUAWEI_DONGLE
# address is the cpe's ip address or dongle's COM port num
UE1_INFO = {
    "TYPE": "",
    "ADDRESS": "",
    "FREQUENCY": "38050",
    "SWITCHPORT": "",
    "IPVER": "ipv4",
}

# ************************ UE Simulator***********************
# can be one of IPHY TM500 DONGLE CPEa
UE_TYPE = "DONGLE"

# Please consult MME/HLR expert if you have no idea about IMSI info
IMSI1_INFO = {
    "NUM": "",  # IMSI number
    "AUTH_METHOD": "",  # authentication method, "test" or "milenage"
    "OP": "",  # empty if "test", not empty if "milenage"
    "KI": "",
}  # not empty
IMSI2_INFO = {"NUM": "", "AUTH_METHOD": "", "OP": "", "KI": ""}
IMSI3_INFO = {"NUM": "", "AUTH_METHOD": "", "OP": "", "KI": ""}

# ************************ PA ***********************
# --> Attenuator  <--
# Attenuators address must be given as format: vendor:ip:port
# till now we support HaoJing(type as HJ) and JieXi(JX) attenuators
ATT_ALL_INFO = {"ATT1": "", "ATT2": ""}

CELL1_ATT_INFO = {
    "ADDRESS": "",
    "MAIN_CH": "",
    "AUX_CH": "",
    "MAIN_ATTACH_VALUE": "0",
    "MAIN_HO_VALUE": "20",
    "AUX_ATTACH_VALUE": "",
    "AUX_HO_VALUE": "",
}

CELL2_ATT_INFO = {
    "ADDRESS": "",
    "MAIN_CH": "",
    "AUX_CH": "",
    "MAIN_ATTACH_VALUE": "0",
    "MAIN_HO_VALUE": "20",
    "AUX_ATTACH_VALUE": "",
    "AUX_HO_VALUE": "",
}

CELL3_ATT_INFO = {
    "ADDRESS": "",
    "MAIN_CH": "",
    "AUX_CH": "",
    "MAIN_ATTACH_VALUE": "0",
    "MAIN_HO_VALUE": "20",
    "AUX_ATTACH_VALUE": "",
    "AUX_HO_VALUE": "",
}


# ************************ PB ***********************
# --> Power Breaker <--
# format: VENDOR:IP:PORT , if have muliti port, can be a list.
# Vendor can be: FACOM, APC, XCYCLER, NSN, if NSN selected format is: NSN:COMPORT
BTS_POWERBREAK_PORT = ["FACOM:10.68.170.183:4"]
IPHY_POWERBREAK_PORT = ""


# ************************ Other Server ***********************
IPSEC_SERVER_INFO = {"IP": "10.68.143.210", "USERNAME": "root", "PASSWORD": "nokia123"}

IPERF_SERVER_INFO = {"IP": "", "USERNAME": "", "PASSWORD": "", "CONN_TYPE": "TELNET"}

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
