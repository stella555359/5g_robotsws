"""
:copyright: Nokia Networks
:author: Justyna Balcerzak, Mateusz Adamek
:maintainer: Justyna Balcerzak, Mateusz Adamek
:contact: justyna.balcerzak@nokia.com, mateusz.adamek@nokia.com
"""
from robot.libraries.BuiltIn import BuiltIn
import netifaces
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

CELLS_ENBx1_GNBx1 = {1: [1], 2: [1]}

UE_HEX_MAP_4UE = {"1": "00:00:00:00:00:00:00:00", "2": "00:00:00:00:00:02:00:00",
                  "11": "00:00:00:00:00:00:20:00", "12": "00:00:00:00:00:02:20:00"}

UE_HEX_MAP_2UE = {"1": "00:00:00:00:00:00:00:00", "2": "00:00:00:00:00:02:00:00",
                  "11": "00:00:00:00:00:00:00:00", "12": "00:00:00:00:00:02:00:00"}

UE_UEXU_MAP = {
    "C004": {"1": 1, "2": 12501, "11": 1, "12": 12501},
    "C014": {"1": 1, "2": 12501, "11": 1, "12": 12501},
    "C005": {"1": 1, "2": 12501, "11": 25001, "12": 37501},
    "C006": {"1": 1, "2": 12501, "11": 25001, "12": 37501},
    "D003": {"11": 0, "12": 1},
    "D011": {"1": 0},
    "D004": {"1": 0, "11": 1},
    "D005": {"1": 0, "11": 1}
}

IPHY_DIR_PATH = '/opt/iphy'
EPCSIM_DIR_PATH = '{}/latest'.format(IPHY_DIR_PATH)
RESOURCES_WTS_CFGS_DIR = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'wts')
DEFAULT_WTS_CONFIG_PATH = os.path.join(EPCSIM_DIR_PATH, 'basic_setup.cfg')

vm_iface_eth0 = netifaces.ifaddresses('eth0')
VM_ADDRESS = vm_iface_eth0[netifaces.AF_INET][0]['addr']

DCAP_DETAILS = {'host': VM_ADDRESS, 'port': '9443', 'username': 'dcapuser', 'password': 'dcapadmin!'}
BTS_DETAILS = {'host': '192.168.255.129', 'username': 'Nemuadmin', 'password': 'nemuuser', 'port': '443'}
TARGET_DIRECTORY = 'home/ute/Downloads/'

TRACE_PROFILE_BTS = ['ipCapture']
TRACE_PROFILE_GNB_EMIL = ['cp_5g']
TRACE_PROFILE_GNB_BOTH = ['SCF5g', 'cp_5g']

ALIAS_TCPDUMP_GNB = "ALIAS_TCPDUMP_GNB"
ALIAS_TSHARK = "ALIAS_TSHARK"
ALIAS_TSHARK_VALIDATE = "ALIAS_TSHARK_VALIDATE"

delta_split_C = "testsuite/Wroclaw/RRM/VRF_WRO2_T07/airphone/Krakow_transfer/CB007227/resources/\
deltas/delta_split_C.json"
cleanup_delta_split_C = "testsuite/Wroclaw/RRM/VRF_WRO2_T07/airphone/Krakow_transfer/CB007227/\
resources/deltas/cleanup_delta_split_C.json"

delta_split_D = "testsuite/Wroclaw/RRM/VRF_WRO2_T07/airphone/Krakow_transfer/\
CB007227/resources/deltas/delta_split_D.json"
cleanup_delta_split_D = "testsuite/Wroclaw/RRM/VRF_WRO2_T07/airphone/Krakow_transfer/CB007227/\
resources/deltas/cleanup_delta_split_D.json"

AATRACE_SCRIPT_PATH = '{}/AaTrace/simpleAaTrace.py'.format(os.path.dirname(os.path.realpath(__file__)))
CCS_DECODE_PATH = '{}/AaTrace/ccs_decode.lua'.format(os.path.dirname(os.path.realpath(__file__)))

AATRACE_NODE_LIST = ['0x2730', '0x2731', '0x2732', '0x2733']
AATRACE_MSG_LIST = ['0xd900', '0xd901', '0xd902', '0xDA81', '0xDA82']

NRCELL_ID = 16385
MAXIMUM_PACKET_LENGTH = 63000  # 63000 means that sic.length must be less than 63kB
SUCCESS_RATE = 0.9
PM_INTERVAL = 5
TRAFFIC_SEND_DURATION = 1

PDCP_SDU_DATA_VOL_DL_SLICE = 'M55328C00003'     # SA
PDCP_SDU_DATA_VOL_UL_SLICE = 'M55328C00005'     # SA
DL_PDCP_VOL_RCV_F1_QoS_GRP_09 = 'M55314C03009'      # NSA
UL_PDCP_VOL_SNT_F1_QoS_GRP_09 = 'M55314C05009'      # NSA

C005_C006_DL_MBPS_SA = 35
C005_C006_DL_MBPS_NSA = 55
C005_C006_TARGET_KB_TRANSFERRED_DL_SA = C005_C006_DL_MBPS_SA/8*1000*TRAFFIC_SEND_DURATION*60     # SA TRAFFIC DL
C005_C006_TARGET_KB_TRANSFERRED_DL_NSA = C005_C006_DL_MBPS_NSA/8*1000*TRAFFIC_SEND_DURATION*60   # NSA TRAFFIC DL

C014_DL_MBPS_SA = 60
C014_UL_MBPS_SA = 20
C014_TARGET_KB_TRANSFERRED_DL_SA_FDD = C014_DL_MBPS_SA/8*1000*TRAFFIC_SEND_DURATION*60     # SA TRAFFIC DL
C014_TARGET_KB_TRANSFERRED_UL_SA_FDD = C014_UL_MBPS_SA/8*1000*TRAFFIC_SEND_DURATION*60     # SA TRAFFIC UL

C004_DL_MBPS_NSA = 20
C004_UL_MBPS_NSA = 6
C004_TARGET_KB_TRANSFERRED_DL_NSA_TDD = C004_DL_MBPS_NSA/8*1000*TRAFFIC_SEND_DURATION*60     # NSA TRAFFIC DL
C004_TARGET_KB_TRANSFERRED_UL_NSA_TDD = C004_UL_MBPS_NSA/8*1000*TRAFFIC_SEND_DURATION*60     # NSA TRAFFIC UL

D011_DL_MBPS_SA = 30
D011_UL_MBPS_SA = 10
D011_TARGET_KB_TRANSFERRED_DL_SA_FDD = D011_DL_MBPS_SA/8*1000*TRAFFIC_SEND_DURATION*60
D011_TARGET_KB_TRANSFERRED_UL_SA_FDD = D011_UL_MBPS_SA/8*1000*TRAFFIC_SEND_DURATION*60

D004_D005_DL_MBPS_SA = 15
D004_D005_UL_MBPS_SA = 5
D004_D005_DL_MBPS_NSA = 20
D004_D005_UL_MBPS_NSA = 10
D004_D005_TARGET_KB_TRANSFERRED_DL_SA = D004_D005_DL_MBPS_SA/8*1000*TRAFFIC_SEND_DURATION*60
D004_D005_TARGET_KB_TRANSFERRED_UL_SA = D004_D005_UL_MBPS_SA/8*1000*TRAFFIC_SEND_DURATION*60
D004_D005_TARGET_KB_TRANSFERRED_DL_NSA = D004_D005_DL_MBPS_NSA/8*1000*TRAFFIC_SEND_DURATION*60
D004_D005_TARGET_KB_TRANSFERRED_UL_NSA = D004_D005_UL_MBPS_NSA/8*1000*TRAFFIC_SEND_DURATION*60

DCAP_RESULTS_COLLECTED = None
