"""
:author:    Konrad Krakowiak
:contact:   konrad.krakowiak@nokia.com
"""

##__init__.py for RF-set PUBS_KRA_RF_AHIB_AHFB_02

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
vm_ip_addr = socket.gethostbyname("pubs-kra-tl227.pubs.krk-lab.nsn-rdnet.net")


host = [
    Host()
]
fsm = [
    FSMr4(hw_type='FSIP', hw_version='A101', pdu=Pdu(addr='10.83.184.19', port=2, device='FPFH'), fbip1=True,fbip2=False,fbip3=False, top_ip='10.83.224.201', trs_ip='10.89.18.227',oam_ip='10.83.185.105')
]
tl = UTE_CONFIG(host=host, fsm=fsm)




# ***************************************************
# **********************  RTG  **********************
# ***************************************************
RTG_1 = get_variable_from_yaml(abstract_lib_config_env, 'RTG_1')


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
pci_pool = list(range(441, 445))
ENB_1 = {
    'bts_id': '300227',
    'backhaul_ip': '10.89.18.227',
    'backhaul_ipv6': '2a00:8a02:0060:0026:0000:0000:0000:e3',
    'emssim_oam_ip': socket.gethostbyname(vm_ip_addr),
    'cell': create_cell_config_based_on_yaml(abstract_lib_config_env, pci_pool)
}
