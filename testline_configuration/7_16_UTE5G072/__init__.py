__maintainer__ = "Damian Siwa"
__team__ = "TRSSEC"
__email__ = "I_EXT_5G_IV_TRSSEC@internal.nsn.com"

import os
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.enb import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import ATEN
from taf.config.testline.radio import RU
from taf.config.testline.core import RealCore4G
from taf.compatibility.configuration import TestlineWrapper
from taf.config.testline.dcap import DcapBasic

__all__ = ["tl"]

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.26", username="ute", password="ute"
    )
)

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.65.114",
        v6="2A00:8A00:6000:607C::5A2E",
        vlan_id=459,
        routing=RoutingInformation(gateway="10.44.65.65/26"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", port=443, username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.65.178",
        v6="2A00:8A00:6000:607C::5B2E",
        vlan_id=460,
        routing=RoutingInformation(gateway="10.44.65.129/26"),
    ),
    x2u=NetworkAddress(
        v4="10.44.65.242",
        v6="2A00:8A00:6000:607C::5C2E",
        vlan_id=461,
        routing=RoutingInformation(gateway="10.44.65.193/26"),
    ),
    s1u=NetworkAddress(
        v4="10.44.66.50",
        v6="2A00:8A00:6000:607C::5D2E",
        vlan_id=462,
        routing=RoutingInformation(gateway="10.44.66.1/26"),
    ),
)

_pdu_gnb = ATEN(
    addr="none", port_numbers=[8]
)  # <------------------------------------- need to fill

_pdu_gnb_ru = ATEN(
    addr="none", port_numbers=[9]
)  # <------------------------------------- need to fill

_gnb_ru = RU(
    ru_hw_group="none",
    default_ssh_connection_details=SshServiceDetails(
        addr="none",  # <------------------------------------- need to fill
        username="root",
        password="umniedziala",
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[9],
)

_cu_gnb_1.sync = NetworkAddress(
    v6="2A00:8A00:6000:607C::5E2E",
    v4="10.44.66.114",
    vlan_id=463,
    routing=RoutingInformation(gateway="10.44.65.65/26"),
)

_abil1_gnb_1_master = CapacityUnit(addr="192.168.253.20")

_abil1_gnb_1_slave = CapacityUnit(addr="192.168.253.21")

_abil1_gnb_1_loner = CapacityUnit(addr="192.168.253.22")

_asik_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_master, _abil1_gnb_1_loner, _abil1_gnb_1_slave],
    pdu_port=_pdu_gnb.pdu_ports[8],
)

_airscale_gnb_1 = Airscale(common_units=[_asik_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru])

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="none",  # <------------------------------------- need to fill
        username="ute",
        password="ute",
    )
)

_pdu_enb = ATEN(
    addr="none", port_numbers=[6]
)  # <------------------------------------- need to fill

_asik_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_master, _abil1_gnb_1_loner, _abil1_gnb_1_slave],
    pdu_port=_pdu_enb.pdu_ports[6],
)

_airscale_enb_1 = Airscale(common_units=[_asik_enb_1])

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    global_bts_id=40211,
    instance_id=40211,
    x2_link_addr=NetworkAddress(
        v6="2A00:8A00:6000:607C::5B2F",
        v4="10.44.65.179",
        vlan_id=460,
        routing=RoutingInformation(gateway="10.44.65.129/26"),
    ),
)

_enb_1.m_plane = NetworkAddress(
    v6="2A00:8A00:6000:607C::5A2F",
    v4="10.44.65.115",
    vlan_id=459,
    routing=RoutingInformation(gateway="10.44.65.65/26"),
)

_dcap = DcapBasic(
    connection_details=HttpConnectionDetails(
        "127.0.0.1", port=9443, username="dcapuser", password="dcapadmin!"
    )
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50211, instance_id=50211, dcap=_dcap
)

_tl_cloud_topology = "CLOUD_5G_CLASSICAL_LB_ASIKA101_ABILA102B1-B2_SA"

_core = RealCore4G()
# temp _cu_gnb_1.m
_cu_gnb_1.m = (
    NetworkAddress(
        v4="10.44.65.114",
        v6="2A00:8A00:6000:607C::5A2E",
        vlan_id=459,
        routing=RoutingInformation(gateway="10.44.65.65/26"),
    ),
)
# temp _enb_1.m
_enb_1.m = NetworkAddress(
    v6="2A00:8A00:6000:607C::5A2F",
    v4="10.44.65.115",
    vlan_id=459,
    routing=RoutingInformation(gateway="10.44.65.65/26"),
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    core=_core,
    tl_cloud_topology=_tl_cloud_topology,
    enbs=[_enb_1],
    test_pcs=[_lmp_vm_enb_1],
)

tl = TestlineWrapper(tl)
