"""
:copyright: Nokia Networks
:author: Mateusz Plinta
:maintainer: Mateusz Plinta
:contact: mateusz.plinta@nokia.com
"""

from robot.libraries.BuiltIn import BuiltIn
import os


def get_builtin_value(param_name, default=None):
    return BuiltIn().get_variable_value('${{{}}}'.format(param_name), default)


tl = get_builtin_value(param_name="tl")

# PDU
PDU_MODEL = tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.__class__.__name__
GNB_PORT = tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port
AP_PORT = tl.ues[0].l1.common_units[0].pdu_port
SWITCH_IP = tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr

# General vars
WEBEM_USERNAME = tl.gnbs[0].cu.oam_http_connection_details.username
WEBEM_PASSWORD = tl.gnbs[0].cu.oam_http_connection_details.password
NOKIA_USERNAME = tl.gnbs[0].cu.oam_ssh_connection_details.username
NOKIA_PASS = tl.gnbs[0].cu.oam_ssh_connection_details.password
GNB_IP = tl.gnbs[0].cu.oam_ssh_connection_details.addr
AP_IP = tl.ues[0].l1.common_units[0].lmp_connection.addr
AP_PASSWD = tl.ues[0].l1.common_units[0].lmp_connection.password
IPHY_DIR_PATH = '/opt/iphy'
EPCSIM_DIR_PATH = '{}/latest'.format(IPHY_DIR_PATH)
WTS_CONFIG_A_FILENAME = 'wts_1085_A.cfg'
WTS_CONFIG_A_FILENAME_TC1 = 'wts_1085_A_CA_TC1.cfg'
WTS_CONFIG_B_FILENAME = 'wts_1085_B_1CELL.cfg'
WTS_CONFIG_B_FILENAME_TC10 = 'wts_1085_B_1CELL_TC10.cfg'
WTS_CONFIG_B_FILENAME_TC11_TC17 = 'wts_1085_B_1CELL_TC11_TC17.cfg'
WTS_CONFIG_B_FILENAME_TC12 = 'wts_1085_B_1CELL_TC12.cfg'
WTS_CONFIG_B_FILENAME_TC26 = 'wts_1085_B_RCA_TC26.cfg'
WTS_CONFIG_C_FILENAME = 'wts_1085_C.cfg'
WTS_CONFIG_7883_FILENAME = 'wts_7883.cfg'
WTS_CONFIG_7883_FILENAME_TC8 = 'wts_7883_TC8.cfg'
WTS_CONFIG_7883_FILENAME_TC10 = 'wts_17883_TC10.cfg'
WTS_CONFIG_7883_FILENAME_TC12 = 'wts_7883_TC12.cfg'
WTS_CONFIG_7883_FILENAME_TC17 = 'wts_7883_TC17.cfg'
WTS_CONFIG_7883_FILENAME_TC18 = 'wts_7883_TC18.cfg'
WTS_CONFIG_7883_FILENAME_TC19 = 'wts_7883_TC19.cfg'
WTS_CONFIG_7883_FILENAME_TC20 = 'wts_7883_TC20.cfg'
WTS_CONFIG_7883_FILENAME_TC21 = 'wts_7883_TC21.cfg'
WTS_CONFIG_7883_FILENAME_TC23 = 'wts_7883_TC23.cfg'
RESOURCES_WTS_CFGS_DIR = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'wts')

FAKE_NRREL_DELTA_FILE = 'deltas/fake_NR_objects.json'
SECOND_ANR_PROFILE_DELTA_FILE = 'deltas/create_second_ANR_profile.json'
DEFAULT_ANR_PROFILE_DELTA_FILE = 'deltas/create_default_ANR_profile.json'

ATTACH_PASS_REGEXP = 'Received REGISTRATION COMPLETE from UE with RAN UE NGAP ID'
INTRA_HO_SUCCESSFUL_EGATE_PRINT = 'UE{}: Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed'
INTRA_HO_SUCCESSFUL_EGATE_PRINT_TC20 = 'UE{}: Intra-eNB handover from EXT_ENB-2.{} to EXT_ENB-2.{} performed'
INTER_HO_SUCCESSFUL_EGATE_PRINT = 'UE{}: Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed'
SYSLOG_ALIAS = "SYSLOG_GNB"
ALIAS_TCPDUMP_GNB = "ALIAS_TCPDUMP_GNB"
ALIAS_TSHARK_WTS = "ALIAS_TSHARK_WTS"
ALIAS_TSHARK_WTS_EARLY = "ALIAS_TSHARK_WTS_EARLY"
PM_PERIOD = "5"
PERIODIC_REMOVAL_CYCLE_DURATION = 5
KNIFE_PATH_IN_PS_LOAD = 'platforms/sm6_snowfish/addons/knife.tzst'

COLLECT_SNAPSHOT = 'False'
SUPPORTED_HARDWARES = ["ASIM", "ASIL", "ASOE"]

MAX_IDLETIMEFORNRNBREMOVAL = 72
CELLS_3XSIM_2XREAL = {3: [1, 2, 3], 2: [1, 2]}
CELLS_1XSIM_2XREAL = {3: [1], 2: [1, 2]}
CELLS_1XSIM_1XREAL = {3: [1], 2: [1]}
CELLS_2XREAL = {2: [1, 2]}

NRADJNRCELL_DIST_NAME = "MRBTS-1/NRBTS-1/NRADJNRCELL-{}"
FIRST_NRADJNRCELL_DIST_NAME = NRADJNRCELL_DIST_NAME.format(1)
LAST_NRADJNRCELL_DIST_NAME = NRADJNRCELL_DIST_NAME.format(12288)

MAX_NRRELS_ID = 256
CELL_DEP_TYPE_BOTH = 'SA+NSA'
NRREL_DIST_NAME = "MRBTS-1/NRBTS-1/NRCELL-1/NRREL-{}"
LAST_NRREL_DIST_NAME = NRREL_DIST_NAME.format(MAX_NRRELS_ID)
FIRST_NRREL_DIST_NAME = NRREL_DIST_NAME.format(1)

NRADJGNB_DIST_NAME = "MRBTS-1/NRBTS-1/NRADJGNB-{}"
# FIRST_NRADJGNB_DIST_NAME = NRADJGNB_DIST_NAME.format(0)

XNLINK_DIST_NAME = "MRBTS-1/NRBTS-1/XNLINK-{}"
# FIRST_XNLINK_DIST_NAME = XNLINK_DIST_NAME.format(0)

GNB_ID_LENGTH_CONFIG_1ST_STRUCTURE = {
    "gNbIdLength": "30",
    "nciEnd": "100001",
    "nciStart": "100000",
    "priorityIndex": "1"
}
GNB_ID_LENGTH_CONFIG_DEFAULT = [GNB_ID_LENGTH_CONFIG_1ST_STRUCTURE, {"gNbIdLength": "25", "priorityIndex": "2"}]
GNB_ID_LENGTH_CONFIG_TC_B003 = [
    {"gNbIdLength": "30", "nciEnd": "100001", "nciStart": "100000", "priorityIndex": "1"},
    {"gNbIdLength": "25", "priorityIndex": "2"},
    {"gNbIdLength": "29", "nciEnd": "10000", "nciStart": "2000", "priorityIndex": "3"},
    {"gNbIdLength": "28", "nrPlmnDN": "MRBTS-1/NRBTS-1/NRPLMN-1", "priorityIndex": "4"},
    {"gNbIdLength": "27", "nciEnd": "10000", "nciStart": "0", "nrPlmnDN": "MRBTS-1/NRBTS-1/NRPLMN-1",
     "priorityIndex": "5"},
    {"gNbIdLength": "26", "priorityIndex": "6"},
]
GNB_ID_LENGTH_CONFIG_2ST_STRUCTURE_TC_B004 = {
    "gNbIdLength": "25",
    "nciEnd": "6000",
    "nciStart": "5000",
    "priorityIndex": "2"
}
GNB_ID_LENGTH_CONFIG_2ST_STRUCTURE_TC_B005 = {
    "gNbIdLength": "25",
    "nciEnd": "5000",
    "nciStart": "4000",
    "priorityIndex": "2"
}
GNB_ID_LENGTH_CONFIG_2ST_STRUCTURE_TC_B006 = {
    "gNbIdLength": "25",
    "nrPlmnDN": "MRBTS-1/NRBTS-1/NRPLMN-2",
    "priorityIndex": "2"
}
GNB_ID_LENGTH_CONFIG_2ST_STRUCTURE_TC_B007 = {
    "gNbIdLength": "25",
    "nrPlmnDN": "MRBTS-1/NRBTS-1/NRPLMN-1",
    "priorityIndex": "2"
}
GNB_ID_LENGTH_CONFIG_2ST_STRUCTURE_TC_B008 = {
    "gNbIdLength": "25",
    "nciEnd": "6000",
    "nciStart": "5000",
    "nrPlmnDN": "MRBTS-1/NRBTS-1/NRPLMN-2",
    "priorityIndex": "2"
}
GNB_ID_LENGTH_CONFIG_2ST_STRUCTURE_TC_B009 = {
    "gNbIdLength": "25",
    "nciEnd": "5000",
    "nciStart": "4000",
    "nrPlmnDN": "MRBTS-1/NRBTS-1/NRPLMN-1",
    "priorityIndex": "2"
}
