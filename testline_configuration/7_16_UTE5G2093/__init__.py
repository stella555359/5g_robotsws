__maintainer__ = "Sylwia Swiatkiewicz"
__team__ = "I_MN_5GSC_PZ_5G_IV7_WRO_5"
__email__ = "I_MN_5GSC_PZ_5G_IV7_WRO_5@internal.nsn.com"
__owner_email__ = "sylwia.swiatkiewicz@nokia.com"

import os
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.enb import RealEnb
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.radio import RU
from taf.config.testline.core import RealCore4G


# 5G section
_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.250.170", username="ute", password="ute"
    )
)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.19.179",
        vlan_id="286",
        routing_v4=RoutingInformation(gateway="10.42.19.179", ip_prefix_length=24),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.42.19.179",
        vlan_id="286",
        routing_v4=RoutingInformation(gateway="10.42.19.179", ip_prefix_length=24),
    ),
    x2u=NetworkAddress(
        v4="10.42.18.179",
        vlan_id="285",
        routing_v4=RoutingInformation(gateway="10.42.18.179", ip_prefix_length=24),
    ),
    s1u=NetworkAddress(
        v4="10.42.21.179",
        vlan_id="288",
        routing_v4=RoutingInformation(gateway="10.42.21.179", ip_prefix_length=24),
    ),
)

_pdu_gnb = Gude(addr="10.42.199.233", port_numbers=[12], model="EPC", version="8221-1")

# RU's PDU
_pdu_gnb_ru1 = ATEN(addr="10.42.80.237", port_numbers=[5])
_pdu_gnb_ru2 = ATEN(addr="10.42.80.237", port_numbers=[3])
_pdu_gnb_ru3 = ATEN(addr="10.42.80.237", port_numbers=[7])

_pdus = [_pdu_gnb, _pdu_gnb_ru1, _pdu_gnb_ru2, _pdu_gnb_ru3]

_gnb_ru1 = RU(
    ru_hw_group="Unknown",
    radio_type="AHFIB",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[5],
)

_gnb_ru2 = RU(
    ru_hw_group="Unknown",
    radio_type="AHFIB",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.53", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_gnb_ru2.pdu_ports[3],
)

_gnb_ru3 = RU(
    ru_hw_group="Unknown",
    radio_type="AHFIB",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.54", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_gnb_ru3.pdu_ports[7],
)


_abil1_gnb_1_loner = CapacityUnit(addr="192.168.253.22")

_asik_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_loner],
    pdu_port=_pdu_gnb.pdu_ports[12],
)

_airscale_gnb_1 = Airscale(common_units=[_asik_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru1, _gnb_ru2, _gnb_ru3])

# LTE section
_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.250.180", username="ute", password="ute"
    )
)

_pdu_enb = ATEN(addr="10.42.199.233", port_numbers=[10])

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_enb.pdu_ports[10],
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_enb_1 = RealEnb(
    system_module=Airscale(_airscale_enb_1),
    global_bts_id=100891,
    instance_id=100891,
    x2_link_addr=NetworkAddress(v4="10.42.19.169", vlan_id=286),
)

_enb_1.m_plane = NetworkAddress(v4="10.42.20.169", vlan_id=287)

# Common section
_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=3601, instance_id=3601
)

_tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASIK_ABIL_3xAHCA_RFS_UUF"

_core = RealCore4G()

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    core=_core,
    tl_cloud_topology=_tl_cloud_topology,
    enbs=[_enb_1],
    test_pcs=[_lmp_vm_enb_1],
    pdus=_pdus,
)

tl_config_dir = os.path.dirname(os.path.abspath(__file__))
__all__ = ["tl"]
