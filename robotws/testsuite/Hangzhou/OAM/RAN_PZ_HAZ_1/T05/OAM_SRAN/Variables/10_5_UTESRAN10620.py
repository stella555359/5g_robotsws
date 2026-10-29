"""BTS variable file, this file is used in TA run."""
# ************************ BTS ***********************
SW_RELEASE = "SBTS00"
# --> sack file path used for emil <--
BTS_SACK_PATH = ""

BTS_INFO = {
    "ID": "10620",
    "IP": "10.68.195.131",
    "NAME": "BTS10620",
    "MRBTS": "MRBTS-10620",
    "LNBTS": "LNBTS-10620",
    "SYSTEM_MODEL_TYPE": "ASOH",
    "LNT_VERSION": "TL17A_1701_07_1701_06",
    "PRODUCT_CODE": "476255A.102",
    "CORE_PRODUCT_CODE": "093802A.103",
    "SERIAL_NUMBER": "L1243307825",
    "CORE_SERIAL_NUMBER": "L1242803884",
    "EIF_PORT": "1",
    "SWITCH_PORT": "0/0"}

# --> External_System_Module_FBBA&FBIH <--
EXT_MODULE1 = {
    "TYPE": "ABIA",
    "NAME": "XXXX",
    "MO_IN_SCF": "XXXXX",
    "PRODUCT_CODE": "XXXXX",
    "SERIAL_NUMBER": "XXXX"}

EXT_MODULE2 = {
    "TYPE": "ABIA",
    "NAME": "XXXX",
    "MO_IN_SCF": "XXXXX",
    "PRODUCT_CODE": "XXXXX",
    "SERIAL_NUMBER": "XXXX"}

EXT_MODULE3 = {
    "TYPE": "ABIA",
    "NAME": "XXXX",
    "MO_IN_SCF": "XXXXX",
    "PRODUCT_CODE": "XXXXX",
    "SERIAL_NUMBER": "XXXX"}

CELL_NUM = 1
CELL1_INFO = {
    "ID": 1,
    "LNCELL": "LNCEL-1",
    "EARFCN": "1900",
    "INTER_EARFCN": "",
    "FREQUENCY": "2595 MHz",
    "EUTRAN_ID": int(BTS_INFO["ID"]) * 256 + 1,
    "PCI": "221",
    "GLOBAL_CELL_ID": ""}

CELL2_INFO = {
    "ID": 2,
    "LNCELL": "LNCEL-2",
    "EARFCN": "1900",
    "INTER_EARFCN": "",
    "FREQUENCY": "2595 MHz",
    "EUTRAN_ID": int(BTS_INFO["ID"]) * 256 + 2,
    "PCI": "221",
    "GLOBAL_CELL_ID": ""}

CELL3_INFO = {
    "ID": 3,
    "LNCELL": "LNCEL-3",
    "EARFCN": "1900",
    "INTER_EARFCN": "",
    "FREQUENCY": "2595 MHz",
    "EUTRAN_ID": int(BTS_INFO["ID"]) * 256 + 3,
    "PCI": "221",
    "GLOBAL_CELL_ID": ""}

PRIMARY_CELL = 1
SECONDARY_CELL = 2

# --> RF_Mode <--
# value can be 'FYRN' or 'AXIS'
RRU1_INFO = {
    "TYPE": "AZQP",
    "POWERBREAK_PORT": "2",
    "POWERBREAK_IP": "10.97.97.151",
    "POWERBREAK_Type": "HBTE",
    "NODE": "1.1.1.1",
    "MO_IN_SCF": "",
    "PRODUCT_CODE": "475198A.102",
    "CORE_PRODUCT_CODE": "RRU5158-fa",
    "CORE_SERIAL_NUMBER": "1M203665233"}

RRU2_INFO = {
    "TYPE": "AVQC",
    "POWERBREAK_PORT": "2",
    "POWERBREAK_IP": "10.97.97.148",
    "POWERBREAK_Type": "FACOM",
    "NODE": "1.1.1.1",
    "MO_IN_SCF": "",
    "PRODUCT_CODE": "476399A.101",
    "CORE_PRODUCT_CODE": "086984A",
    "CORE_SERIAL_NUMBER": "1M242008667"}

BTS_INFOMODEL_PORT = 3600

# --> BTS control PC <--
BTS_PC_INFO = {
    "IP": "10.108.152.145",
    "LANIP": "192.168.255.126",
    "GATEWAY": "10.108.152.129",
    "USERNAME": "ute",
    "PASSWORD": "uteUTE!",
    "IPV6": "",
    "IPV6_GW": ""}

# ************************ Core Network ***********************
# --> Netact 2003 <--
# NETACT_SERVER_INFO = {
#    "IP": "10.82.47.46",
#    "URL": "srnclab2003lbwas.srnblr.nsn-rdnet.net",
#    "USERNAME": "omc",
#    "PASSWORD": "Medsql!_1893",
#    "MR": "MRC-COMMON/MR-COMMON",
#    "PORT": "22",
#    "EXTEND_IP": "a52:2f39"}
# # --> Netact 1014 <--
# NETACT_SERVER_INFO = {
#    "IP": "10.41.146.105",
#    "URL": "srnclab1014lbwas.srnblr.nsn-rdnet.net",
#    "USERNAME": "omc",
#    "PASSWORD": "Medsql!_1893",
#    "PORT": "22",
#    "EXTEND_IP": "0a29:9272",
# }
# --> Netact1027<--
# NETACT_SERVER_INFO = {
#    "IP": "10.41.148.99",
#    "URL": "srnclab1027lbwas.srnblr.nsn-rdnet.net",
#    "USERNAME": "omc",
#    "PASSWORD": "Medsql!_1893",
#    "PORT": "22",
#    "EXTEND_IP": "0a29:946c",
# }
#  --> NetAct4-CHEN<--
# NETACT_SERVER_INFO = {"IP": "10.108.248.82",
#                       "URL": "chen4lbwas.chen4.srnhz.nsn-rdnet.net",
#                       "USERNAME": "omc",
#                       "PASSWORD": "Nokia126_",
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
BTS_POWERBREAK_PORT = ["FACOM:10.108.151.61:7"]
IPHY_POWERBREAK_PORT = ""

# ************************ Other Server ***********************
IPSEC_SERVER_INFO = {"IP": "10.68.143.210", "USERNAME": "root", "PASSWORD": "nokia123"}

IPERF_SERVER_INFO = {"IP": "", "USERNAME": "", "PASSWORD": "", "CONN_TYPE": "TELNET"}

SWITCH_INFO = {
    "IP": "10.69.238.252",
    "PORT": "23",
    "USERNAME": "jing.1.wan@nokia.com",
    "PASSWORD": "6666",
    "ENBPORT": "0/14",
    "DHCPSERVERIP": "10.69.238.252",
}

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
