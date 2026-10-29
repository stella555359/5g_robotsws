__maintainer__ = "Marta Hendler"
__team__ = "5G_PZ_2_WRO_8_SG"
__email__ = "marta.hendler@nokia.com"
__owner_email__ = "bartosz.plewa@nokia.com"

import os
from yaml import load, SafeLoader
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU, RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline.core import RealCore5G

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.221", username="ute", password="ute"
    )
)
_realcore_appsrv = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.61.65", username="5g", password="2019H@slo"
    )
)
_core = RealCore5G(mcc=540, mnc=1)

_abil_master = CapacityUnit(addr="192.168.253.20")
_abil_slave = CapacityUnit(addr="192.168.253.21")
_abil_loner = CapacityUnit(addr="192.168.253.22")

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
)
_airscale = Airscale([_common_unit])
_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.224.17",
        v6="",
        vlan_id=0,
        routing_v4=RoutingInformation(gateway="10.44.224.1", ip_prefix_length=26),
        routing_v6=RoutingInformation(
            gateway="", ip_prefix_length=120
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.224.81",
        v6="",
        vlan_id=0,
        routing_v4=RoutingInformation(gateway="", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.44.224.145",
        v6="",
        vlan_id=0,
        routing_v4=RoutingInformation(gateway="", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.44.224.209",
        v6="",
        vlan_id=0,
        routing_v4=RoutingInformation(gateway="", ip_prefix_length=26),
    ),
)
_ru1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=None,
    ru_hw_group="",
    radio_type="AHLOA",
)

_ru2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.38", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=None,
    ru_hw_group="",
    radio_type="AHFIC",
)


_du = DU(_airscale, rus=[_ru1, _ru2])
_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=50840, instance_id=50840)
_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)
_common_unit_lte = CommonUnit(_common_unit_lte_ssh, capacity_units=[_abil_loner])
_abil = CapacityUnit(addr="192.168.253.20")
_asik = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil],
)
_lte = RealEnb(
    airscale=Airscale(common_units=[_asik]),
    x2_link_addr=NetworkAddress(
        v4="10.44.255.143",
        v6="",
        vlan_id=0,
        routing_v4=RoutingInformation(gateway="10.44.255.129", ip_prefix_length=26),
    ),
    global_bts_id=40840,
)
_lte_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.194.226", username="ute", password="ute"
    ),
    connections=[_lte],
)
_ue_pc_ssh = SshServiceDetails("10.44.72.40", "wro5grrm", password="5gpass!1")

with open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "ue_config.yaml")) as yaml_file:
    _android_ue = load(yaml_file, Loader=SafeLoader)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="",
    core=_core,
    enbs=[_lte],
    test_pcs=[_lte_test_pc, _realcore_appsrv],
    ues=[_android_ue],
)
__all__ = ["tl"]
