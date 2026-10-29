"""
:author:    Kacper Szewenko
:contact:   kacper.szewenko@nokia.com
"""

from ute_testline_configuration.schema import ConfigComposer
import os
import sys
import socket
sys.path.append(os.path.join(os.path.dirname(__file__), '../../..'))
from resources.WMP.GVe.Krakow.PubS_SyVe.netact import *
from resources.WMP.GVe.Krakow.PubS_SyVe.utils import *
from ute_testline_configuration.ute_config import UTE_CONFIG, Host, FSMr4, Pdu
current_dir = os.path.dirname(os.path.abspath(__file__)) + '/'

abstract_lib_config_env = 'ABSTRACT_LIB_CONFIG'
#ue_pc_ip_addr = socket.gethostbyname("PLKR-WMP-UE34.intra.noklab.net")

host = [
    Host()
]

fsm = [FSMr4(hw_type='ASIB', hw_version='A101', pdu=Pdu(addr='10.83.184.23', port=3, device='FPFH'), fbip1=True,fbip2=False,fbip3=False, top_ip='10.83.224.201', trs_ip='10.89.18.14',oam_ip='10.83.184.217')]

tl = UTE_CONFIG(host=host, fsm=fsm)


# ***************************************************
# ******************      IPSL     ******************
# ***************************************************
IPSL = {
#   'ip_addr': ue_pc_ip_addr,
    'ip_addr': '10.53.164.188',
    'user': 'inbabtslabuser',
    'password': 'BT5l@bus3rl0g1n',
    'script_dir': '/cygdrive/c/IpslTools/automation',
    'ipslc_path': "/cygdrive/c/IpslTools/ipslc.exe",
    'server_path': 'c:/IpslTools/automation/server.ctl',
    'ipscfg_path': 'c:/IpslTools/automation/ips.cfg',
    'app_server_ip': get_app_server_ip_from_yaml(abstract_lib_config_env),
    'desired_imsi': {'imsi1':'404991100000325'},
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
UE_PC = {
    'remote_ip': '10.53.164.188',
    'remote_user': 'inbabtslabuser',
    'remote_pass': 'BT5l@bus3rl0g1n',
    'message_stream_port': '6010',
}

# ***************************************************
# ******************      ENB1     ******************
# ***************************************************
ENB_1 = {
    'bts_id': '300014',
    'backhaul_ip': '10.53.203.202',
    'emssim_oam_ip': '10.43.54.224',
    'cell': {  # Dictionary containing all cells present on the eNB
        '1': {
            'pci': 14,  # Physical cell ID of the cell
            'lncel_id': 1,  # LNCEL number for the given cell
            'earfcn': 700
        },
        '2': {
            'pci': 15,
            'lncel_id': 2,
            'earfcn': 66600
        },
        '3': {
            'pci': 16,
            'lncel_id': 3,
            'earfcn': 2450
        },
        '4': {
            'pci': 17,
            'lncel_id': 4,
            'earfcn': 47091
        },
        '5': {
            'pci': 5,
            'lncel_id': 5,
            'earfcn': 47289
        },
        '6': {
            'pci': 6,
            'lncel_id': 6,
            'earfcn': 47490
        },
        '7': {
            'pci': 7,
            'lncel_id': 7,
            'earfcn': 47688
        },
        '8': {
            'pci': 8,
            'lncel_id': 8,
            'earfcn': 66798
        },
        '9': {
            'pci': 9,
            'lncel_id': 9,
            'earfcn': 900
        },
    },
}

RADAR = {
    'remote_ip': '10.53.164.188',
}

# ***************************************************
# ******************      ENB2     ******************
# ***************************************************
ENB_2 = {
    'bts_id': '300100',
    'backhaul_ip': '10.43.197.153',
    'emssim_oam_ip': '10.43.54.208',
    'cell': {  # Dictionary containing all cells present on the eNB
        '1': {
            'pci': 100,   # Physical cell ID of the cell
            'lncel_id': 1,  #LNCEL number for the given cell
            'earfcn': 800
        },
        '2': {
            'pci': 2,   # Physical cell ID of the cell
            'lncel_id': 2,  #LNCEL number for the given cell
            'earfcn': 1050
        },
    },
}

# ***************************************************
# ******************     NETACT   ******************
# ***************************************************
NETACT = {
    'FL19':     'SPRINTLAB085',
}

# ***************************************************
# *************       MBMS_CONFIG      **************
# ***************************************************
SAI = {
    '1': '10991',
    '2': '10992',
    '3': '10993'
}

MBSFN_SYNC_AREA_ID = {
    '1': '10991',
    '2': '10992',
    '3': '10993'
}

MBSFN_AREA_ID = {
    '1': '115',
    '2': '116',
    '3': '117',
}

# ***************************************************
# *************       EPCSIM      **************
# ***************************************************
EPCSIM = {
    'M3_ip': '10.89.24.14',
}
