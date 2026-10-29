__maintainer__ = "Artur Jankowiak"
__team__ = "RRM team"
__email__ = "artur.jankowiak@nokia.com"
__owner_email__ = "artur.jankowiak@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import ATEN, EPC

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.85", username="ute", password="ute"
    )
)

_pdu1 = ATEN(addr="10.42.61.80", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])

_pdus = [_pdu1]

_abil_master = CapacityUnit(addr="192.168.253.20")
_abil_slave = CapacityUnit(addr="192.168.253.21")
_abil_loner = CapacityUnit(addr="192.168.253.22")

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
    pdu_port=_pdu1.pdu_ports[2],
)

_airscale = Airscale([_common_unit])

_cu1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.181.211", vlan_id=53),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    xnc=NetworkAddress(
        v4="10.44.181.211",
        v6=None,
        vlan_id=53,
        routing_v4=RoutingInformation(gateway="10.44.181.1", ip_prefix_length=24),
    ),
    xnu=NetworkAddress(
        v4="10.44.181.211",
        v6=None,
        vlan_id=53,
        routing_v4=RoutingInformation(gateway="10.44.181.1", ip_prefix_length=24),
    ),
    ngc=NetworkAddress(
        v4="10.44.181.211",
        v6=None,
        vlan_id=53,
        routing_v4=RoutingInformation(gateway="10.44.181.1", ip_prefix_length=24),
    ),
    ngu=NetworkAddress(
        v4="10.44.181.211",
        v6=None,
        vlan_id=53,
        routing_v4=RoutingInformation(gateway="10.44.181.1", ip_prefix_length=24),
    ),
)

_cu2 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.65.112", vlan_id=459),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    xnc=NetworkAddress(
        v4="10.44.65.240",
        v6=None,
        vlan_id=461,
        routing_v4=RoutingInformation(gateway="10.44.65.193", ip_prefix_length=26),
    ),
)

_ru = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=None,
    ru_hw_group="",
    radio_type="AHLOA",
)

_du = DU(_airscale, rus=[_ru])

_cbts1 = ClassicalBts(cu=_cu1, dus=[_du], instance_id=51022, global_bts_id=51022)
_cbts2 = ClassicalBts(cu=_cu2, dus=[_du], instance_id=51995, global_bts_id=51995)
_cbts = [_cbts1, _cbts2]

_core = RealCore5G(mcc=540, mnc=1)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=_cbts,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AHLOA",
    core=_core,
    pdus=_pdus,
)


__all__ = ["tl"]
