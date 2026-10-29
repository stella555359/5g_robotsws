__maintainer__ = "Tadeusz Marcinkiewicz"
__email__ = "tadeusz.marcinkiewicz@nokia.com"

import os
from taf.config.testline import CUS
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    HttpConnectionDetails,
    SshServiceDetails,
)
from taf.config.testline import RoutingInformation
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb import CU, DU, ClassicalBts
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import RRB
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.ue import Airphone
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)

_pdu = RRB(addr="10.44.200.107", port_numbers=[1, 2, 3, 4, 5, 6, 7])
_pdus = [_pdu]

_enb_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.20", hardware_type="ABIA"),
    ],
    pdu_port=_pdu.pdu_ports[1],
    hardware_type="ASIA",
)


_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.84.6",
        v6="2a00:8a00:6000:600c::1b06",
        vlan_id=517,
        routing_v4=RoutingInformation(gateway="10.42.84.1/24"),
        routing_v6=RoutingInformation(gateway="GW:2a00:8a00:6000:600c::1b01/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.42.85.6",
        v6="2a00:8a00:6000:600c::1c06",
        vlan_id=518,
        routing_v4=RoutingInformation(gateway="10.42.85.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1c01/120"),
    ),
    x2u=NetworkAddress(
        v4="10.42.85.70",
        v6="2a00:8a00:6000:600c::1d06",
        vlan_id=519,
        routing_v4=RoutingInformation(gateway="10.42.85.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1d01/120"),
    ),
    s1u=NetworkAddress(
        v4="10.42.85.134",
        v6="2a00:8a00:6000:600c::1e06",
        vlan_id=520,
        routing_v4=RoutingInformation(gateway="10.42.85.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1e01/120"),
    ),
    ngu=NetworkAddress(
        v4="10.42.85.134",
        v6="2a00:8a00:6000:600c::1e06",
        vlan_id=520,
        routing_v4=RoutingInformation(gateway="10.42.85.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1e01/120"),
    ),
    ngc=NetworkAddress(
        v4="10.42.86.6",
        v6="2a00:8a00:6000:600c::2006",
        vlan_id=521,
        routing_v4=RoutingInformation(gateway="10.42.86.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::2004"),
    ),
    xnc=NetworkAddress(
        v4="10.42.85.6",
        v6="2a00:8a00:6000:600c::1c06",
        vlan_id=518,
        routing_v4=RoutingInformation(gateway="10.42.85.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1c01/120"),
    ),
    xnu=NetworkAddress(
        v4="10.42.85.68",
        v6="2a00:8a00:6000:600c::1d04",
        vlan_id=519,
        routing_v4=RoutingInformation(gateway="10.42.85.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1d01/120"),
    ),
)

_enb_airscale = Airscale(
    common_units=[_enb_common_unit1],
)
_enb = RealEnb(airscale=_enb_airscale, global_bts_id=5010, instance_id=5010)

_test_pc2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.94", username="ute", password="ute"
    ),
    connections=[
        Connection(
            interface="eth1", device=_enb.airscale.common_units[0], interface_type="lmp"
        ),
    ],
)


tl = TestLine(
    test_pc=_test_pc2,
    test_pcs=[_test_pc2],
    enbs=[_enb],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIA_ASIB_ABIL_ABIO_ARGA_FXED_FHRC",
    pdus=_pdus,
)

__all__ = ["tl"]
