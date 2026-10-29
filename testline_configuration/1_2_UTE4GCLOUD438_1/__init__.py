"""
:author:    Marcin Maciuszek
:contact:   marcin.maciuszek@nokia.com
"""

#from ute_testline_configuration.schema import ConfigComposer
#Below configuration used for Dispatcher execution
# from ute_testline_configuration.ute_config import UTE_CONFIG, Host, FSMr4, Pdu
#
# host = [
#     Host()
# ]
#
# fsm = [FSMr4(hw_type='FSIP', hw_version='A101', pdu=Pdu(addr='10.83.184.17', port=3, device='FPFH'), fbip1=True,fbip2=False,fbip3=False, top_ip='10.83.224.201', trs_ip='10.89.18.2',oam_ip='10.83.185.18')]
#
# tl = UTE_CONFIG(host=host, fsm=fsm)


import os
import sys
import socket
sys.path.append(os.path.join(os.path.dirname(__file__), '../../..'))
from resources.WMP.GVe.Krakow.PubS_SyVe.netact import *
from resources.WMP.GVe.Krakow.PubS_SyVe.utils import *

current_dir = os.path.dirname(os.path.abspath(__file__)) + '/'
abstract_lib_config_env = 'ABSTRACT_LIB_CONFIG'

ue_pc_ip_addr_17 = '10.53.164.240'
VM_1002 = '10.43.54.203'

# ***************************************************
# ******************      RTG     *******************
# ***************************************************

RTG_1 = {
    'executor': {
        'host': VM_1002,
        'port': 1234
    }
}

# ***************************************************
# ******************      IPSL     ******************
# ***************************************************

# UE PC 14 - ipsl 24408
IPSL = {
    #'ip_addr': ue_pc_ip_addr_13,
    'ip_addr': '10.43.90.115',
    'user': 'inbasrnlabuser',
    'password': '5RNl@bus3rl0g1n',
    'script_dir': '/cygdrive/c/IpslTools/automation',
    'ipslc_path': "/cygdrive/c/IpslTools/ipslc.exe",
    'server_path': 'c:/IpslTools/automation/server.ctl',
    'ipscfg_path': 'c:/IpslTools/automation/IPS.CFG',
    'app_server_ip': get_app_server_ip_from_yaml(abstract_lib_config_env),
    'desired_imsi': {'imsi1': '404991100006201',           # MTP8150 UE1 UE13
                     'imsi2': '404991100016479',           # MTP8996 UE2 UE14
                     'imsi3': '404991100000312',          # Bittium PLMN 24408 HPA
                     'imsi5': '404991100006201',          # QC8996  PLMN 24408
                     'RTG_imsi1': '404991100006990',
                     'RTG_imsi2': '404991100006991',
                     'RTG_imsi3': '404991100006992',
                     'RTG_imsi4': '404991100006993',
                     'RTG_imsi5': '404991100006994',
                     'RTG_imsi6': '244087800000285',
                     'RTG_imsi7': '244087800000286'},
}

# UE PC 17 - ipsl 23430
IPSL_2 = {
    'ip_addr': ue_pc_ip_addr_17,
    'user': 'batwings',
    'password': 'Motorola2010',
    'script_dir': '/cygdrive/c/IpslTools/automation',
    'ipslc_path': "/cygdrive/c/IpslTools/ipslc.exe",
    'server_path': 'c:/IpslTools/automation/server.ctl',
    'ipscfg_path': 'c:/IpslTools/automation/IPS.CFG',
    'app_server_ip': get_app_server_ip_from_yaml(abstract_lib_config_env),
    'desired_imsi': {'imsi4': '234305635899675',          # QC8996 PLMN 23430
                     'imsi12': '404991100006201',         # QC8996 UEPC13 PLMN 23430 with HPA
                     'RTG_imsi11' : '234307800000260',
                     'RTG_imsi12' : '234307800000261'},
}

# ***************************************************
# ***************  BACKHAUL_MIRROR_PC  **************
# ***************************************************
BACKHAUL_MIRROR_PC = {
    'remote_ip': '10.53.164.126',
    'remote_user': 'inbabtslabuser',
    'remote_pass': 'BT5l@bus3rl0g1n',
}

# BACKHAUL_MIRROR_PC = {
#     'remote_ip': '10.43.54.203',
#     'remote_user': 'ute',
#     'remote_pass': 'ute',
# }

# ***************************************************
# ***************        UE_PC        ***************
# ***************************************************
UE_PC = {
    'remote_ip': '10.53.164.240',
    'remote_user': 'inbabtslabuser',
    'remote_pass': 'BT5l@bus3rl0g1n',
    'message_stream_port': '6010',
}

UE_PC_Server = {
    'remote_ip': '10.53.164.240',
    'remote_user': 'inbabtslabuser',
    'remote_pass': 'BT5l@bus3rl0g1n',
}
# ***************************************************
# ******************      ENB1     ******************
# ***************************************************
ENB_1 = {
    'bts_id': '799',
    'backhaul_ip': '10.43.197.138',
    'emssim_oam_ip': '10.43.54.203',
    'cell': {  # Dictionary containing all cells present on the eNB
         '1': {
            'pci': 42,  # Physical cell ID of the cell
            'lncel_id': 1,  # LNCEL number for the given cell
            'earfcn': 3100
        },
         '2': {
            'pci': 43,  # Physical cell ID of the cell
            'lncel_id': 2,  # LNCEL number for the given cell
            'earfcn': 1500
        },
    },
}

ENB_2 = {
    'bts_id': '798',
    'backhaul_ip': '10.43.197.135',
    'emssim_oam_ip': '10.43.54.202',
    'cell': {  # Dictionary containing all cells present on the eNB
         '1': {
            'pci': 89,  # Physical cell ID of the cell
            'lncel_id': 1,  # LNCEL number for the given cell
            'earfcn': 3150
        },
    },
}

# ***************************************************
# ******************     NETACT   ******************
# ***************************************************
NETACT = {
    'FL18SP': CLAB263,
    'FL18A': CLAB2067,
    'SBTS18A': CLAB1240,
    'SBTS19A': CLAB3362,
    'FL19': VSP0000,
}

# ***************************************************
# *************       MBMS_CONFIG      **************
# ***************************************************
SAI = {
    '1': '0021',
    '2': '0022',
    '3': '0023',
    '4': '0024',
}

MBSFN_AREA_ID = {
    '1': 55,
    '2': 56,
    '3': 57,
}

MBSFN_SYNC_AREA_ID = {
    '1': 20,
    '2': 21,
}


