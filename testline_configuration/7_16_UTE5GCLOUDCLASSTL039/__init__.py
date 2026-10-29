__maintainer__ = "Dawid Dzilinski"
__team__ = "MN 5G&SC Pz 5G I&V 7 WRO 7 SG"
__email__ = "I_5G_TLM_WRO@internal.nsn.com"
__owner_email__ = "dawid.dzilinski@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline import RealEnb, Enb
from taf.config.testline.core import RealCore4G
from taf.compatibility.configuration import TestlineWrapper
from taf.config.testline.pdu import PduPort, Gude
from taf.config.testline.gnb.networkaddress import NetworkAddress


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc_ssh = SshServiceDetails(addr="10.42.194.145", username="ute", password="ute")

_test_pc = TestPc(default_ssh_connection_details=_test_pc_ssh)

##GNB
_gnb_pdu = Gude(addr="10.44.206.178", port_numbers=[3], model="EPC", version="8220-1")


_ru = RU(
    ru_hw_group="5Ggen3_LowF_AEWF",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    radio_type="AEWF",
)

_capacity_unit = CapacityUnit(addr="192.168.253.22")

# _common_unit_ssh = SshServiceDetails(addr='10.44.66.196',
_common_unit_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit = CommonUnit(
    _common_unit_ssh, capacity_units=[_capacity_unit], pdu_port=_gnb_pdu.pdu_ports[3]
)

_airscale = Airscale([_common_unit])

# _cu = CU(backhaul_site_oam_ip='10.44.66.196',
_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    # 		  oam_ssh_connection_details=SshServiceDetails(addr='10.44.66.196',
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    #        oam_http_connection_details=HttpConnectionDetails(addr='10.44.66.196',
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
)

_du = DU(airscale=_airscale, rus=[_ru])

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_core = RealCore4G()

_lteenb = RealEnb(airscale=_du, x2_link_addr=NetworkAddress(v4="10.44.66.132"))


tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    enbs=[_lteenb],
    ues=None,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIKA101L_ABILA102B1_AEWF_BRANCH_cOAM",
    core=_core,
    pdus=[_gnb_pdu],
)

tl = TestlineWrapper(tl)

__all__ = ["tl"]
