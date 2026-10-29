__maintainer__ = "Cookie"
__team__ = "CRAN_1 03 SG"
__email__ = "hefeng-cookie.qu@nokia-sbell.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.pdu import FACOM
from taf.config.testline import DU
from taf.config.testline.airscale import Airscale, CommonUnit

from taf.config.testline import Enb, SimEnb, RealEnb, LTEEmuEnb, PrismaEnb, DocomoEnb
from taf.config.testline.legacy import SCF


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_cu = CU(
    backhaul_site_oam_ip="10.108.227.130",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.108.227.130", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.108.227.130", username="Nemuadmin", password="nemuuser"
    ),
)

_gnb_pdu = FACOM(addr="10.57.242.30", port_numbers=[5])

_common_unit_0 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.108.227.130", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=None,
    pdu_port=_gnb_pdu.pdu_ports[5],
)

_airscale = Airscale(common_units=[_common_unit_0])

# RealEnb
_common_unit_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.108.227.3", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=None,
)
_real_enb = Airscale(common_units=[_common_unit_1])
_lte_real_enb = RealEnb(airscale=_real_enb, rms=None)

_du = DU(airscale=_airscale, rus=None)

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_tools_repository = {
    "ip": "10.108.227.14",
    "username": "root",
    "password": "rootroot",
    "repo_tool_folder": "/opt/tools/trans_test/",
    "repo_data_folder": "/opt/tools/trans_data/",
}

_simulator4DU = {
    "ip": "10.108.227.14",
    "username": "root",
    "password": "rootroot",
    "service_ip": "10.108.227.133",
    "service_ipv6": "2a00:8a00:8000:117:0:8:0:10",
}

_switch1 = {
    "du_switch_ip": "10.0.87.146",
    "username": "nokia",
    "password": "nokia123",
    "en_password": "",
    "switch_interface": "1/1",
    "simu4DU_interface": "1/4",
    "du_vlan_id": "20",
    "du_vlan_masklen": "27",
    "du_vlan_gateway": "10.108.227.129",
    "du_vlan_mtu": "1500",
    "du_2nd_vlan_id": "100",
    "du_2nd_vlan_masklen": "27",
    "du_2nd_vlan_gateway": "10.108.227.192",
    "du_2nd_vlan_mtu": "1500",
    "du_2nd_vlan_ip": "10.108.227.220",
}

_switch = {"switch1": _switch1}

_trans_para = {
    "tools_repository": _tools_repository,
    "simulator4DU": _simulator4DU,
    "du_switch": _switch,
}

#########Testpc##########
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.209.188", username="ute", password="ute"
    )
)

# Testline
tl = TestLine(
    test_pc=_test_pc, gnbs=[_cbts], enbs=[_lte_real_enb], tl_cloud_topology=""
)

# it's a WA, please see https://jira3.int.net.nokia.com/browse/TALIB-846,
# this jira has blocked a few transport TA cases design and debug
# one of other WA is declare a global python variable, 'TRANS_PARA = _trans_para'
# i don't know which WA is better, please give me suggestion if you like to change WA.
tl._trans_para = _trans_para


__all__ = ["tl"]
