__maintainer__ = "Piotr Sewerynek"
__team__ = "MN BOAM Pz O&M EIT WRO 1 Vrf"
__email__ = "piotr.sewerynek@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RU, NetworkAddress, RoutingInformation
from taf.config.testline.core import LTEEmuCore
from taf.config.testline.pdu import ATEN, PduPort
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.121.74", username="ute", password="ute"
    )
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="192.168.255.1", v6="0:0:0:0:0:ffff:c0a8:ff01"
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.0.0.11",
        v6="",
        vlan_id=0,
        routing=RoutingInformation(gateway="", ip_prefix_length=0),
    ),
    x2u=NetworkAddress(
        v4="10.0.0.11",
        v6="",
        vlan_id=0,
        routing=RoutingInformation(gateway="", ip_prefix_length=0),
    ),
    s1u=NetworkAddress(
        v4="10.0.0.11",
        v6="",
        vlan_id=0,
        routing=RoutingInformation(gateway="", ip_prefix_length=0),
    ),
)
_pdu_asik = ATEN(addr="10.42.42.62", port_numbers=[5])
_pdu_rmod1 = ATEN(addr="10.42.42.62", port_numbers=[8])

_abil_du1 = CapacityUnit(addr="fsp1_c", hardware_type="ABIL", hardware_version="A102")

_asik_du1 = CommonUnit(
    pdu_port=_pdu_asik.pdu_ports[5],
    capacity_units=[_abil_du1],
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
)
_rmod1_du1 = RU(
    ru_hw_group="Unknown",
    radio_type="Unknown",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_rmod1.pdu_ports[8],
)

_du1 = DU(Airscale(common_units=[_asik_du1]), rus=[_rmod1_du1])

_cbts = ClassicalBts(cu=_cu, dus=[_du1])

_lteemu = LTEEmuCore(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.121.74", username="ute", password="ute"
    ),
    dir_path="/opt/core",
    cfg_filename="basic_cfg_LteEmu.cfg",
    mme_ip="10.1.1.100",
    mcc=555,
    mnc=10,
    tac=7150,
    edaemon_port=22222,
    egate_port=10000,
)

_pdus = [_pdu_asik, _pdu_rmod1]

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIKA101L_ABILA102B1_AEUA",
    core=_lteemu,
    pdus=_pdus,
)

__all__ = ["tl"]
