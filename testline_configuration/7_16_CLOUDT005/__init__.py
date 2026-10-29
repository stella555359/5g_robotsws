__maintainer__ = "Artur Stepniak"
__team__ = "MN 5G RAN I&V 3 Pz cOAM 12 SG"
__email__ = "I_UTE_CORE_5G@internal.nsn.com"
__owner_email__ = "krzysztof.michalek@nokia.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RealEnb
from taf.config.testline.core import EPCSim
from taf.config.testline.ue import TM500
from taf.compatibility.configuration import TestlineWrapper

_test_pc_ip = "10.42.53.45"
_testp_pc_ssh = SshServiceDetails(addr=_test_pc_ip, username="ute", password="ute")
_test_pc = TestPc(default_ssh_connection_details=_testp_pc_ssh)

_capacity_unit = CapacityUnit(addr="192.168.253.22")
_common_unit_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)
_common_unit = CommonUnit(
    _common_unit_ssh, capacity_units=[_capacity_unit], pdu_port=None
)

_airscale = Airscale([_common_unit])

_http = HttpConnectionDetails(
    addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
)
_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="192.168.255.129", vlan_id=459),
    oam_ssh_connection_details=_common_unit_ssh,
    oam_http_connection_details=_http,
    x2c=NetworkAddress(v4="10.1.1.1", vlan_id=460),
    x2u=NetworkAddress(v4="10.1.1.1", vlan_id=461),
    s1u=NetworkAddress(v4="10.1.1.1", vlan_id=462),
)

_du = DU(_airscale)

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_core = EPCSim(
    mme_ip="10.1.1.100",
    mcc=555,
    mnc=10,
    tac=123,
    default_ssh_connection_details=_testp_pc_ssh,
    dir_path="/opt/core",
    cfg_filename="epcsim.cfg",
)

_ue = TM500(
    SshServiceDetails(addr="10.42.158.113", username="", password=""),
    tma_command_port=5003,
)

_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_lte = CommonUnit(
    _common_unit_lte_ssh, capacity_units=[_capacity_unit], pdu_port=None
)

_lteenb = RealEnb(airscale=_airscale, x2_link_addr="10.1.1.110")

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    enbs=[_lteenb],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIKA101L_ABILA102B1_AEQA_ENB",
    core=_core,
    ues=[_ue],
)

tl = TestlineWrapper(tl)

__all__ = ["tl"]
