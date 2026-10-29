__maintainer__ = "Piotr Marciniszyn"
__team__ = "MN_RAN_Pz_3_WRO_02&04"
__email__ = "I_EXT_5G_IV_TRSSEC@internal.nsn.com"

import os
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import ATEN, EPC, Gude
from taf.config.testline.radio import RU
from taf.config.testline.core import RealCore, RealCore5GDetails
from taf.config.testline.dcap import DcapBasic

__all__ = ["tl"]

cfg_dir = os.path.dirname(os.path.abspath(__file__))
_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.68.178",
        v6="2a00:8a00:6000:607c::1:ae27",
        vlan_id=903,
        routing_v4=RoutingInformation(gateway="10.44.68.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:ae01/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", port=443, username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.68.244",
        v6="2a00:8a00:6000:607c::1:af27",
        vlan_id=904,
        routing_v4=RoutingInformation(gateway="10.44.68.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:af01/120"),
    ),
    x2u=NetworkAddress(
        v4="10.44.70.52",
        v6="2a00:8a00:6000:607c::1:b027",
        vlan_id=905,
        routing_v4=RoutingInformation(gateway="10.44.70.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b001/120"),
    ),
    s1u=NetworkAddress(
        v4="10.44.70.114",
        v6="2a00:8a00:6000:607c::1:b127",
        vlan_id=906,
        routing_v4=RoutingInformation(gateway="10.44.70.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b101/120"),
    ),
    ngu=NetworkAddress(
        v4="10.44.70.178",
        v6="2a00:8a00:6000:607c::1:b327",
        vlan_id=907,
        routing_v4=RoutingInformation(gateway="10.44.70.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b301/120"),
    ),
    ngc=NetworkAddress(
        v4="10.44.70.243",
        v6="2a00:8a00:6000:607c::1:b227",
        vlan_id=908,
        routing_v4=RoutingInformation(gateway="10.44.70.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b201/120"),
    ),
    xnc=NetworkAddress(
        v4="10.44.68.244",
        v6="2a00:8a00:6000:607c::1:af27",
        vlan_id=904,
        routing_v4=RoutingInformation(gateway="10.44.68.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:af01/120"),
    ),
    xnu=NetworkAddress(
        v4="10.44.70.52",
        v6="2a00:8a00:6000:607c::1:b027",
        vlan_id=905,
        routing_v4=RoutingInformation(gateway="10.44.70.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b001/120"),
    ),
)
_pdu_gnb = Gude(
    addr="10.44.205.210",
    port_numbers=[4],
    model="EPC",
    version="8221-1",
)
_pdu_gnb_ru = Gude(
    addr="10.44.177.24",
    port_numbers=[1],
    model="EPC",
    version="8221-1",
)
_pdu_gnb_ru2 = Gude(
    addr="10.44.205.209",
    port_numbers=[4],
    model="EPC",
    version="8221-1",
)
_pdus = [_pdu_gnb, _pdu_gnb_ru, _pdu_gnb_ru2]
_gnb_ru1 = RU(
    radio_type="AQQL",
    ru_hw_group="cMAAr6.2_64T64R",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.54",
        username="root",
        password="w@=EIj7P6R0bVy85OjCVa^ho&8",
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1",
        username="root",
        password="w@=EIj7P6R0bVy85OjCVa^ho&8",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[1],
)
_gnb_ru2 = RU(
    radio_type="AEQN",
    ru_hw_group="cMAA_Gen4.0_32T32R",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52",
        username="root",
        password="w@=EIj7P6R0bVy85OjCVa^ho&8",
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1",
        username="root",
        password="w@=EIj7P6R0bVy85OjCVa^ho&8",
    ),
    pdu_port=_pdu_gnb_ru2.pdu_ports[4],
)
_abil1_gnb_2 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIL",
    serial_number="",
    hardware_version="101",
)
_abil1_gnb_1_master = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    serial_number="",
    hardware_version="101",
)
_asik_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_master, _abil1_gnb_2],
    pdu_port=_pdu_gnb.pdu_ports[4],
    hardware_type="ASIK",
    serial_number="",
    hardware_version="101",
)
_airscale_gnb_1 = Airscale(common_units=[_asik_gnb_1])
_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_abil1_gnb_1_master, label="SFP", port_id=1),
        target=Endpoint(unit=_gnb_ru1, label="SFP", port_id=3),
    ),
    Cablink(
        source=Endpoint(unit=_abil1_gnb_1_master, label="SFP", port_id=2),
        target=Endpoint(unit=_gnb_ru2, label="SFP", port_id=2),
    ),
]
_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1, rus=[_gnb_ru1, _gnb_ru2], cablinks=_ru_cablinks
)
_dcap = DcapBasic(
    connection_details=HttpConnectionDetails(
        "127.0.0.1", port=9443, username="dcapuser", password="dcapadmin!"
    )
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=51072, instance_id=51072, dcap=_dcap
)
_tl_cloud_topology = "CLOUD_5G_CLASSICAL_RUDE_ASIKL_ABILB1"
_cu_gnb_1.m = NetworkAddress(
    v4="10.44.68.178",
    v6="2a00:8a00:6000:607c::1:ae27",
    vlan_id=903,
    routing_v4=RoutingInformation(gateway="10.44.68.129/26"),
    routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:ae01/120"),
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.36", username="ute", password="ute"
    ),
    connections=[
        Connection(interface="eth1", device=_asik_gnb_1, interface_type="lmp")
    ],
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    tl_cloud_topology=_tl_cloud_topology,
    test_pcs=[_lmp_vm_gnb_1],
    pdus=_pdus,
)
