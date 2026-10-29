__maintainer__ = "Szymon Kramczynski"
__team__ = "uuf"
__email__ = "szymon.kramczynski@nokia.com"
__owner_email__ = "szymon.kramczynski@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import EPCSim
from taf.config.testline import RealEnb
from taf.config.testline.pdu import ATEN, APC


_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.83.208", username="ute", password="ute"
    )
)
_pdu1 = APC(addr="10.42.80.236", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])
_pdu2 = APC(addr="10.42.80.237", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])
_pdus = [_pdu1, _pdu2]
_abil_master = CapacityUnit(addr="192.168.253.20")
# _abil_slave = CapacityUnit(addr='192.168.253.21')
_abil_loner = CapacityUnit(addr="192.168.253.22")
_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_loner],
    pdu_port=_pdu2.pdu_ports[4],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.1.1.3"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(
        v4="10.1.1.3",
        v6=None,
        vlan_id=None,
        routing=RoutingInformation(gateway="10.1.1.1", ip_prefix_length=24),
    ),
    x2u=NetworkAddress(
        v4="10.1.1.3",
        v6=None,
        vlan_id=None,
        routing=RoutingInformation(gateway="10.1.1.1", ip_prefix_length=24),
    ),
    s1c=NetworkAddress(
        v4="10.1.1.3",
        v6=None,
        vlan_id=None,
        routing=RoutingInformation(gateway="10.1.1.1", ip_prefix_length=24),
    ),
    s1u=NetworkAddress(
        v4="10.1.1.3",
        v6=None,
        vlan_id=None,
        routing=RoutingInformation(gateway="10.1.1.1", ip_prefix_length=24),
    ),
    tracing=None,
)


_ru1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[6],
    ru_hw_group="",
    radio_type="AHLOA",
)


_du = DU(_airscale, rus=[_ru1])

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=1)

_core = EPCSim(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.81", username="ute", password="ute"
    ),
    dir_path="/home/ute/epcsim",
    cfg_filename="config_new.cfg",
    mme_ip="10.1.1.100",
    mcc=311,
    mnc=489,
    tac=788,
    edaemon_port=10000,
    egate_port=20000,
)

_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_lte = CommonUnit(
    _common_unit_lte_ssh, capacity_units=[_abil_loner], pdu_port=None
)

_abia = CapacityUnit(addr="192.168.253.36")

_asia = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia],
)

_lte = RealEnb(
    airscale=Airscale(common_units=[_asia]),
    x2_link_addr=NetworkAddress(
        v4="10.1.1.5",
        v6=None,
        vlan_id=None,
        routing=RoutingInformation(gateway="10.1.1.1", ip_prefix_length=24),
    ),
    global_bts_id=1,
)


tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIK101L_ABIL102B1_AHLOA_SHARED_4G_ASIA_ABIA",
    core=_core,
    pdus=_pdus,
    enbs=[_lte],
)

__all__ = ["tl"]
