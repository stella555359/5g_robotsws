__maintainer__ = "Marek Lenartowicz"
__team__ = "MN BOAM Pz O&M EIT WRO 1 Vrf"
__email__ = "marek.lenartowicz@nokia.com"

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
from taf.config.testline.pdu import ATEN, PduPort, Gude
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.121.202", username="ute", password="ute"
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

_pdu_asoe = ATEN(addr="10.42.226.9", port_numbers=[4])
_pdu_azqp = Gude(addr="10.42.42.8", port_numbers=[1], model="EPC", version="8220-1")

_asoe_du1 = CommonUnit(
    capacity_units=[],
    pdu_port=_pdu_asoe.pdu_ports[4],
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
    pdu_port=_pdu_azqp.pdu_ports[1],
)

_du1 = DU(Airscale(common_units=[_asoe_du1]), rus=[_rmod1_du1])

_cbts = ClassicalBts(cu=_cu, dus=[_du1])

_pdus = [_pdu_asoe, _pdu_azqp]

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASOE_AZQP",
    pdus=_pdus,
)

__all__ = ["tl"]
