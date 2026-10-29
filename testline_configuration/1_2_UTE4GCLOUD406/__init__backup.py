"""
:author:    Konrad Krakowiak
:contact:   konrad.krakowiak@nokia.com
"""

from ute_testline_configuration.schema import ConfigComposer
import os
import sys
import socket
sys.path.append(os.path.join(os.path.dirname(__file__), '../../..'))
from resources.WMP.GVe.Krakow.PubS_SyVe.netact import *
from resources.WMP.GVe.Krakow.PubS_SyVe.utils import *
from ute_testline_configuration.ute_config import UTE_CONFIG, Host, FSMr4, IPHY, Pdu

current_dir = os.path.dirname(os.path.abspath(__file__)) + '/'
abstract_lib_config_env = 'ABSTRACT_LIB_CONFIG'

ue_pc_ip_addr = '10.53.164.191'
vm_ip_addr = '10.43.54.131'
#vm_ip_addr = '10.83.185.105'

#commenting below part as not sure -sidhant
# host = [
#     Host()
# ]
#
# fsm = [
#     FSMr4(hw_type='FSIP', hw_version='A101', pdu=Pdu(addr='10.83.184.19', port=2, device='FPFH'), fbip1=True,fbip2=False,fbip3=False, top_ip='10.83.224.201', trs_ip='10.89.18.227',oam_ip='10.83.185.105')
# ]
# #	fsm = [FSMr4(hw_type='FSIP', hw_version='A101', pdu=Pdu(addr='127.0.0.1', port=1, device='FPFH'), fbip1=True,fbip2=False,fbip3=False, top_ip='10.83.224.201', trs_ip='10.89.18.101',oam_ip='10.83.184.154')]
#
# #fsm = [
# #    FSMr4(hw_type='ASIA', hw_version='A101', pdu=Pdu(addr='10.83.200.78', port=6, device='ATEN'), fbip1=True,fbip2=False,fbip3=False, top_ip='10.83.224.201', trs_ip='10.89.18.227')
# #]
#
#
# tl = UTE_CONFIG(host=host, fsm=fsm)



# ***************************************************
# ******************      IPSL     ******************
# ***************************************************
IPSL = {
    'ip_addr': ue_pc_ip_addr,
    'user': 'inbabtslabuser',
    'password': 'BT5l@bus3rl0g1n',
    'script_dir': '/cygdrive/c/IpslTools/automation',
    'ipslc_path': "/cygdrive/c/IpslTools/ipslc.exe",
    'server_path': 'c:/IpslTools/automation/server.ctl',
    'ipscfg_path': 'c:/IpslTools/automation/ips.cfg',
    'app_server_ip': get_app_server_ip_from_yaml(abstract_lib_config_env),
    'desired_imsi': {'imsi1':'404991100000268'},
}

# ***************************************************
# ***************  BACKHAUL_MIRROR_PC  **************
# ***************************************************
BACKHAUL_MIRROR_PC = {
    'remote_ip': '10.53.164.125',
    'remote_user': 'inbabtslabuser',
    'remote_pass': 'BT5l@bus3rl0g1n',
}

# ***************************************************
# ***************        UE_PC        ***************
# ***************************************************
#UE_PC = {
#    'remote_ip': '10.83.185.48',
#    'remote_user': 'ute',
#    'remote_pass': 'ute',
#    'message_stream_port': '6010',
#}

# ***************************************************
# ******************      ENB1     ******************
# ***************************************************
ENB_1 = {
    'bts_id': '406',
    'backhaul_ip': '10.53.203.204',
    #'backhaul_ipv6': '2a00:8a02:0060:0026:0000:0000:0000:e3',
    'emssim_oam_ip': '10.43.54.231',
    #'primary_sas_server_ip' : '10.83.184.162:4433',
    'cell': {  # Dictionary containing all cells present on the eNB
        '1': {
            'pci': 221,  # Physical cell ID of the cell
            'lncel_id': 1,  # LNCEL number for the given cell
            'earfcn': 66800,
        },
        '2': {
            'pci': 222,  # Physical cell ID of the cell
            'lncel_id': 2,  # LNCEL number for the given cell
	        'earfcn': 47091,
        },
        '3': {
            'pci': 223,  # Physical cell ID of the cell
            'lncel_id': 3,  # LNCEL number for the given cell
	        'earfcn': 18700,
        },
        '4': {
            'pci': 224,  # Physical cell ID of the cell
            'lncel_id': 4,  # LNCEL number for the given cell
	        'earfcn': 55340
        },
    },
}

# ***************************************************
#enb_id=2    configure_and_wait  (/home/ute/robotlte_trunk/testsuite/WMP/GVe/Krakow/PS_SyVe/resources/common_configuration_deltas/CBRS_SERVER_CONFIGURATIONy ******************      ENB2     ******************
# ***************************************************
# ***************************************************
ENB_2 = {
    'bts_id': '404',
    'backhaul_ip': '10.53.203.206',
    #'backhaul_ipv6': '2a00:8a02:0060:0026:0000:0000:0000:55',
    'emssim_oam_ip': '10.43.54.230',
    #'primary_sas_server_ip' : '10.83.185.193:4433',
    'cell': {  # Dictionary containing all cells present on the eNB
        '1': {
            'pci': 280,  # Physical cell ID of the cell
            'lncel_id': 1,  # LNCEL number for the given cell
            'earfcn': 55340,
        },
        '2': {
            'pci': 281,  # Physical cell ID of the cell
            'lncel_id': 2,  # LNCEL number for the given cell
        'earfcn': 55538,
        },
        '3': {
            'pci': 282,  # Physical cell ID of the cell
            'lncel_id': 3,  # LNCEL number for the given cell
        'earfcn': 55736,
        },
        '4': {
            'pci': 283,  # Physical cell ID of the cell
            'lncel_id': 4,  # LNCEL number for the given cell
        'earfcn': 55934,
        },
    },
}
## ******************     NETACT   ******************
## ***************************************************
#
#NETACT = {
#    'FL17A':    SPRINTLAB368,
#    'FL17ASP1': SPRINTLAB368,
#    'FL18':     SPRINTLAB368,
#    'FL18SP':   SPRINTLAB368,
#    'FL19':     SPRINTLAB085,
#}

# ***************************************************
# *************        SAI_LIST        **************
# ***************************************************

# ***************************************************
# ******************     SCFCs     ******************
# ***************************************************

# ***************************************************
# ***********     Commissioning files     ***********
# ***************************************************
