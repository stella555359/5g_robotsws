"""BTS variable file, this file is used in TA run."""
# ************************ BTS ***********************
from robot.libraries.BuiltIn import BuiltIn

BTS_INFO = {"ID": "1",
            "IP": "10.0.1.2",
            "NAME": "cloudtest",
            "MRBTS": "MRBTS-1",
            "LNBTS": "LNBTS-1"}

CELL1_INFO = {"ID": 1,
              "LNCELL": "LNCEL-1",
              "EARFCN": "38000",
              "INTER_EARFCN": "38100",
              "FREQUENCY": "",
              "EUTRAN_ID": int(BTS_INFO["ID"]) * 256 + 1,
              "PCI": "1"}

CELL2_INFO = {"ID": 2,
              "LNCELL": "LNCEL-2",
              "EARFCN": "38000",
              "INTER_EARFCN": "38100",
              "EUTRAN_ID": int(BTS_INFO["ID"]) * 256 + 2,
              "PCI": "2"}

CELL3_INFO = {"ID": 3,
              "LNCELL": "LNCEL-3",
              "EARFCN": "38000",
              "INTER_EARFCN": "38100",
              "EUTRAN_ID": int(BTS_INFO["ID"]) * 256 + 3,
              "PCI": "3"}

CELL4_INFO = {"ID": 4,
              "LNCELL": "LNCEL-4",
              "EARFCN": "38000",
              "INTER_EARFCN": "38100",
              "EUTRAN_ID": int(BTS_INFO["ID"]) * 256 + 4,
              "PCI": "4"}

CELL5_INFO = {"ID": 5,
              "LNCELL": "LNCEL-5",
              "EARFCN": "38000",
              "INTER_EARFCN": "38100",
              "EUTRAN_ID": int(BTS_INFO["ID"]) * 256 + 5,
              "PCI": "5"}

CELL6_INFO = {"ID": 6,
              "LNCELL": "LNCEL-6",
              "EARFCN": "38000",
              "INTER_EARFCN": "38100",
              "EUTRAN_ID": int(BTS_INFO["ID"]) * 256 + 6,
              "PCI": "6"}

CELL7_INFO = {"ID": 7,
              "LNCELL": "LNCEL-7",
              "EARFCN": "38000",
              "INTER_EARFCN": "38100",
              "EUTRAN_ID": int(BTS_INFO["ID"]) * 256 + 7,
              "PCI": "7"}

CELL8_INFO = {"ID": 8,
              "LNCELL": "LNCEL-8",
              "EARFCN": "38000",
              "INTER_EARFCN": "38100",
              "EUTRAN_ID": int(BTS_INFO["ID"]) * 256 + 8,
              "PCI": "8"}

CELL9_INFO = {"ID": 9,
              "LNCELL": "LNCEL-9",
              "EARFCN": "38000",
              "INTER_EARFCN": "38100",
              "EUTRAN_ID": int(BTS_INFO["ID"]) * 256 + 9,
              "PCI": "9"}

# --> BTS control PC <--
pc_password = BuiltIn().get_variable_value("${tl.host[1].password}")
BTS_PC_INFO = {"IP": "127.0.0.1",
               "LANIP": "",
               "GATEWAY": "",
               "USERNAME": "ute",
               "PASSWORD": pc_password}

MME1_INFO = {"IP": "10.0.1.1"}

# ************************ UE Simulator***********************
# only for removing ERROR log when importing resource
TM500_INFO = {"SCHEDULE_PRIORITY": "1"}

# ***************** PB **********************

vendor = BuiltIn().get_variable_value("${tl.fsm[1].pdu.device}")
host = BuiltIn().get_variable_value("${tl.fsm[1].pdu.addr}")
port = BuiltIn().get_variable_value("${tl.fsm[1].pdu.port}")
vendor_iphy = BuiltIn().get_variable_value("${tl.iphy[1].pdu.device}")
host_iphy = BuiltIn().get_variable_value("${tl.iphy[1].pdu.addr}")
port_iphy = BuiltIn().get_variable_value("${tl.iphy[1].pdu.port}")
BTS_POWERBREAK_PORT = "%s:%s:%s" % (vendor, host, port)
IPHY_POWERBREAK_PORT = "%s:%s:%s" % (vendor_iphy, host_iphy, port_iphy)


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
