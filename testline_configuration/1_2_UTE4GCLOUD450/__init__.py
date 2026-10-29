#"""
#:author:    Mikolaj Suliga
#:contact:   mikolaj.suliga@nokia.com
#"""

from ute_testline_configuration.schema import ConfigComposer
import os
import sys
sys.path.append(os.path.join(os.path.dirname(__file__), '../../..'))
from resources.WMP.GVe.Krakow.PubS_SyVe.netact import *
from resources.WMP.GVe.Krakow.PubS_SyVe.utils import *
import socket
from ute_testline_configuration.ute_config import UTE_CONFIG, Host, FSMr4, Pdu

current_dir = os.path.dirname(os.path.abspath(__file__)) + '/'
abstract_lib_config_env = 'ABSTRACT_LIB_CONFIG'

host = [
    Host()
]

fsm = [FSMr4(hw_type='FSIP', hw_version='A101', pdu=Pdu(addr='10.83.184.18', port=1, device='FPFH'), fbip1=True,fbip2=False,fbip3=False, top_ip='10.83.224.201', trs_ip='10.89.18.79',oam_ip='10.83.185.208')]

tl = UTE_CONFIG(host=host, fsm=fsm)


RADAR = get_variable_from_yaml(abstract_lib_config_env, 'RADAR')

# ***************************************************
# ******************      ENB1     ******************
# ***************************************************
pci_pool = list(range(261, 265))
ENB_1 = {
    'bts_id': '450',
    'backhaul_ip': '10.53.203.200',
    'emssim_oam_ip': '10.43.54.214',
    'cell': create_cell_config_based_on_yaml(abstract_lib_config_env, pci_pool)
    }
#emssim_oam_ip = '10.43.54.214'

NETACT = {
   'FL00':    SPRINTLAB085,
   'FL19':    CLAB1335,
}

### ========= OLD STUFF =========

# ***************************************************
# ***************  BACKHAUL_MIRROR_PC  **************
# ***************************************************
#BACKHAUL_MIRROR_PC = {
#    'remote_ip': '10.83.206.89',
#    'remote_user': 'ute',
#    'remote_pass': 'emssim4Nokia#',
#}

# ***************************************************
# ***************        UE_PC        ***************
# ***************************************************
#UE_PC = {
#    'remote_ip': ue_pc_ip_addr,
#    'remote_user': 'ute',
#    'remote_pass': 'ute',
#    'message_stream_port': '6010',
#}
#RADAR = {
#    'remote_ip': ue_pc_ip_addr,
#}

# ***************************************************
# *************       MBMS_CONFIG      **************
# ***************************************************

# ***************************************************
# ******************     NETA
# CT   ******************
# ***************************************************

# 'cell': {
#      '1': {
#         'pci': 261,  # Physical cell ID of the cell
#         'lncel_id': 1,  # LNCEL number for the given cell
#         'earfcn': 700,
#     },
#      '2': {
#         'pci': 262,  # Physical cell ID of the cell
#         'lncel_id': 2,  # LNCEL number for the given cell
#         'earfcn': 66600
#     },
#      '3': {
#         'pci': 264,  # Physical cell ID of the cell
#         'lncel_id': 3,  # LNCEL number for the given cell
#         'earfcn': 47091
#     },
#      '4': {
#         'pci': 334,  # Physical cell ID of the cell
#         'lncel_id': 4,  # LNCEL number for the given cell
#         'earfcn': 50291
#     },
IPSL = {
    #'ip_addr': ue_pc_ip_addr_13,
    'ip_addr': '10.53.164.245',
    'user': 'inbabtslabuser',
    'password': 'BT5l@bus3rl0g1n',
    'script_dir': '/cygdrive/c/IpslTools/automation',
    'ipslc_path': "/cygdrive/c/IpslTools/ipslc.exe",
    'server_path': 'c:/IpslTools/automation/server.ctl',
    'ipscfg_path': 'c:/IpslTools/automation/IPS.CFG',
    #'app_server_ip': get_app_server_ip_from_yaml(abstract_lib_config_env),
    'app_server_ip': '10.58.190.172',
    'desired_imsi': {'imsi1': '262010000009998'},           # QC8996 PLMN 24408
                     #'imsi2': '404991100000262',           # Bittium PLMN 24408
                     # 'RTG_imsi7': '4049811110000147'},
}
