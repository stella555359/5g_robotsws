__maintainer__ = "Filip Radwanski"
__team__ = "I_5GSC_5G_PZ1_WRO_5"
__email__ = "I_5GSC_5G_PZ1_WRO_5@internal.nsn.com"
__owner_email__ = "filip.radwanski@nokia.com"

import os
import yaml
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
from taf.config.testline.pdu import ATEN, PduPort, Gude
from taf.config.testline.radio import RU
from taf.config.testline.core import RealCore4G

from taf.config.testline.ue import Android

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.58", username="ute", password="ute"
    )
)

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_nokia_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "askey_ue.yml"
)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.78.25",
        v6="2a00:8a00:6000:607c::3f0f",
        vlan_id=860,
        routing_v4=RoutingInformation(gateway="10.44.78.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::3f01/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.78.89",
        v6="2a00:8a00:6000:607c::400f",
        vlan_id=861,
        routing_v4=RoutingInformation(gateway="10.44.78.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4001/120"),
    ),
    x2u=NetworkAddress(
        v4="10.44.81.217",
        v6="2a00:8a00:6000:607c::410f",
        vlan_id=862,
        routing_v4=RoutingInformation(gateway="10.44.81.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4101/120"),
    ),
    s1u=NetworkAddress(
        v4="10.44.82.25",
        v6="2a00:8a00:6000:607c::420f",
        vlan_id=863,
        routing_v4=RoutingInformation(gateway="10.44.82.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4201/120"),
    ),
)

_pdu_gnb = Gude(addr="10.44.205.169", port_numbers=[1], model="EPC", version="8221-1")
_pdu_gnb_ru1 = Gude(
    addr="10.44.205.171", port_numbers=[11], model="EPC", version="8221-1"
)
_pdu_fanbreaker = ATEN(addr="0.0.0.0", port_numbers=[0])
_pdu_gpsbreaker = ATEN(addr="0.0.0.0", port_numbers=[0])

_pdus = [
    _pdu_gnb,
    _pdu_gnb_ru1,
    _pdu_fanbreaker,
    _pdu_gpsbreaker,
]

_gnb_ru1 = RU(
    ru_hw_group="AZHL",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[11],
)

_abil1_gnb_1_master = CapacityUnit(addr="192.168.253.20")

_abil1_gnb_1_slave = CapacityUnit(addr="192.168.253.21")

_abil1_gnb_1_loner = CapacityUnit(addr="192.168.253.22")

_asik_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_master, _abil1_gnb_1_loner, _abil1_gnb_1_slave],
    pdu_port=_pdu_gnb.pdu_ports[1],
)

_airscale_gnb_1 = Airscale(common_units=[_asik_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru1])

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.169", username="ute", password="ute"
    )
)

_pdu_enb = ATEN(addr="0.0.0.0", port_numbers=[0])

_asik_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_enb.pdu_ports[0],
)

_airscale_enb_1 = Airscale(common_units=[_asik_enb_1])

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    global_bts_id=40390,
    instance_id=40390,
    x2_link_addr=NetworkAddress(v4="10.44.85.111", vlan_id=820),
)

_enb_1.m_plane = NetworkAddress(v4="10.44.85.112", vlan_id=820)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50390, instance_id=50390
)

_ue_pc_ssh = SshServiceDetails(
    addr="10.44.72.167", username="wro5goam", password="Uteadmin1@"
)

with open(
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "askey_ue.yml")
) as f:
    _askey_ue = yaml.load(f, yaml.FullLoader)

_tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASIBL_ABIO_AZQS"

_core = RealCore4G()

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    core=_core,
    tl_cloud_topology=_tl_cloud_topology,
    enbs=[_enb_1],
    test_pcs=[_lmp_vm_enb_1],
    ues=[_nokia_ue],
    pdus=_pdus,
)

__all__ = ["tl"]
