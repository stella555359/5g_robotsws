"""
:author:    Konrad Krakowiak
:contact:   konrad.krakowiak@nokia.com
"""
##__init__.py for RF-set PUBS_KRA_RF_AHFB_AHIB_AZQC_AZRB_01 

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

ue_pc_ip_addr = socket.gethostbyname("plkr-wmp-ue51.pubs.krk-lab.nsn-rdnet.net")
vm_ip_addr = socket.gethostbyname("pubs-kra-tl227.pubs.krk-lab.nsn-rdnet.net")


host = [
    Host()
]
fsm = [
    FSMr4(hw_type='FSIP', hw_version='A101', pdu=Pdu(addr='10.83.184.19', port=2, device='FPFH'), fbip1=True,fbip2=False,fbip3=False, top_ip='10.83.224.201', trs_ip='10.89.18.227',oam_ip='10.83.185.105')
]
tl = UTE_CONFIG(host=host, fsm=fsm)



# ***************************************************
# ******************      IPSL     ******************
# ***************************************************
IPSL = {
    'ip_addr': ue_pc_ip_addr,
    'user': 'ute',
    'password': 'ute',
    'script_dir': '/cygdrive/c/IpslTools/automation',
    'ipslc_path': "/cygdrive/c/IpslTools/ipslc.exe",
    'server_path': 'c:/IpslTools/automation/server.ctl',
    'ipscfg_path': 'c:/IpslTools/automation/ips.cfg',
    'app_server_ip': get_app_server_ip_from_yaml(abstract_lib_config_env),
    'desired_imsi': {'imsi1':'244087800000178'},
}

# ***************************************************
# ***************  BACKHAUL_MIRROR_PC  **************
# ***************************************************
BACKHAUL_MIRROR_PC = {
    'remote_ip': '10.89.24.50',
    'remote_user': 'pubs',
    'remote_pass': 'emssim4Nokia#',
}


# ***************************************************
# ******************      ENB1     ******************
# ***************************************************
ENB_1 = {
    'bts_id': '300227',
    'backhaul_ip': '10.89.18.227',
    'backhaul_ipv6': '2a00:8a02:0060:0026:0000:0000:0000:e3',
    'emssim_oam_ip': socket.gethostbyname(vm_ip_addr),
    'primary_sas_server_ip' : '10.83.184.162:4433',
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
            'pci': 232,  # Physical cell ID of the cell
            'lncel_id': 3,  # LNCEL number for the given cell
	        'earfcn': 18700,
        },
        '4': {
            'pci': 233,  # Physical cell ID of the cell
            'lncel_id': 4,  # LNCEL number for the given cell
	        'earfcn': 55340
        },
    },
}

# ***************************************************
# ******************      ENB2     ******************
# ***************************************************
# ***************************************************
ENB_2 = {
    'bts_id': '300085',
    'backhaul_ip': '10.89.18.85',
    'backhaul_ipv6': '2a00:8a02:0060:0026:0000:0000:0000:55',
    'emssim_oam_ip': '10.83.185.193',
    'primary_sas_server_ip' : '10.83.185.193:4433',
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
