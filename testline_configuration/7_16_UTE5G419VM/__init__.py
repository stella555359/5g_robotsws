__maintainer__ = "Monika Walendzik"
__team__ = "MN_RAN_VRF_3_WRO_02"
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
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF
from taf.config.testline.dcap import DcapBasic


cfg_dir = os.path.dirname(os.path.abspath(__file__))


### ------------ Start TL405 - GNB_1 -------------------------- ###

__all__ = ["tl"]

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.249.234",
#        v6="2a00:8a00:6000:607c::1:9732",
        vlan_id=459,
        routing_v4=RoutingInformation(gateway="10.42.249.225/26"),
#        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9701/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", port=443, username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.65.199",
#        v6="2a00:8a00:6000:607c::1:9832",
        vlan_id=461,
        routing_v4=RoutingInformation(gateway="10.44.65.193/26"),
#        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9801/120"),
    ),
    x2u=NetworkAddress(
        v4="10.255.21.10",
#        v6="2a00:8a00:6000:607c::1:9932",
        vlan_id=460,
        routing_v4=RoutingInformation(gateway="10.255.21.1/26"),
#        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9901/120"),
    ),
    s1u=NetworkAddress(
        v4="10.255.21.74",
#        v6="2a00:8a00:6000:607c::1:9a32",
        vlan_id=462,
        routing_v4=RoutingInformation(gateway="10.255.21.65/26"),
#        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9a01/120"),
    ),
    ngu=NetworkAddress(
        v4="10.42.140.138",
#        v6="2a00:8a00:6000:607c::1:9b32",
        vlan_id=463,
        routing_v4=RoutingInformation(gateway="10.42.140.129/26"),
#        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9b01/120"),
    ),
    ngc=NetworkAddress(
        v4="10.42.140.170",
#        v6="2a00:8a00:6000:607c::1:9c32",
        vlan_id=892,
        routing_v4=RoutingInformation(gateway="10.42.140.161/26"),
#        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9c01/120"),
    ),
    xnc=NetworkAddress(
        v4="10.42.140.170",
#        v6="2a00:8a00:6000:607c::1:9832",
        vlan_id=461,
        routing_v4=RoutingInformation(gateway="10.42.140.161/26"),
#        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9801/120"),
    ),
    xnu=NetworkAddress(
        v4="10.42.140.138",
#        v6="2a00:8a00:6000:607c::1:9932",
        vlan_id=460,
        routing_v4=RoutingInformation(gateway="10.42.140.129/26"),
#        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9901/120"),
    ),
)

# ------------------------PDU_GNB_1CONFIGURATION------------------------

_pdu_gnb = ATEN(addr="10.42.61.202", port_numbers=[6])
_pdu_gnb_ru = Gude(addr="10.44.206.183", port_numbers=[11], model="EPC", version="8221-1")

_pdus = [_pdu_gnb, _pdu_gnb_ru]
_gnb_ru = RU(
    ru_hw_group="cMAAr6.1_64T64R",
    radio_type="AHCA",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[11],
)
_abip1_gnb_1_master = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    serial_number="L1224715636",
    hardware_version="101",
)
_abip1_gnb_2_master = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIP",
    serial_number="	L1224715543",
    hardware_version="101",
)
_asim_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip1_gnb_1_master, _abip1_gnb_2_master],
    hardware_type="ASIM",
    serial_number="L1224507029",
    hardware_version="101",
    pdu_port=_pdu_gnb.pdu_ports[6],
)
_airscale_gnb_1 = Airscale(common_units=[_asim_gnb_1])
_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_abip1_gnb_1_master, label="SFP", port_id=1),
        target=Endpoint(unit=_gnb_ru, label="SFP", port_id=2),
    ),    
]
_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1, rus=[_gnb_ru], cablinks=_ru_cablinks
)

_dcap = DcapBasic(
    connection_details=HttpConnectionDetails(
        "127.0.0.1", port=9443, username="dcapuser", password="dcapadmin!"
    )
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=51094, instance_id=51094, dcap=_dcap
)

_cu_gnb_1.m = NetworkAddress(
    v4="10.44.65.74",
#    v6="2a00:8a00:6000:607c::1:9d32",
    vlan_id=459,
    routing_v4=RoutingInformation(gateway="10.44.65.65/26"),
#    routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9d01/120"),
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.36", username="ute", password="ute"
    ),
    connections=[
        Connection(interface="eth1", device=_asim_gnb_1, interface_type="lmp"),
    ],
)

_tl_cloud_topology = "CLOUD_5G_CLASSICAL_TSN_MULTIGNB_WRO_TRS"

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1],
    gnbs=[_cbts],
    tl_cloud_topology=_tl_cloud_topology,
    pdus=[_pdus],
)
