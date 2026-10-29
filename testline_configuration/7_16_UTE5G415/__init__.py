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
from taf.config.testline.enb import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import ATEN, EPC, Gude
from taf.config.testline.radio import RU
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF
from taf.config.testline.dcap import DcapBasic

__all__ = ["tl"]

cfg_dir = os.path.dirname(os.path.abspath(__file__))
_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.249.234",
        v6="2a00:8a00:6000:607c::4a0a",
        vlan_id=923,
        routing_v4=RoutingInformation(gateway="10.42.249.225/27"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4a01/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", port=443, username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.255.21.10",
        v6="2a00:8a00:6000:607c::4b0a",
        vlan_id=924,
        routing_v4=RoutingInformation(gateway="10.255.21.1/27"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4b01/120"),
    ),
    x2u=NetworkAddress(
        v4="10.255.21.42",
        v6="2a00:8a00:6000:607c::4c0a",
        vlan_id=925,
        routing_v4=RoutingInformation(gateway="10.255.21.33/27"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4c01/120"),
    ),
    s1u=NetworkAddress(
        v4="10.255.21.74",
        v6="2a00:8a00:6000:607c::4d0a",
        vlan_id=926,
        routing_v4=RoutingInformation(gateway="10.255.21.65/27"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4d01/120"),
    ),
    ngu=NetworkAddress(
        v4="10.42.140.138",
        v6="2a00:8a00:6000:607c::4e0a",
        vlan_id=927,
        routing_v4=RoutingInformation(gateway="10.42.140.129/27"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4e01/120"),
    ),
    ngc=NetworkAddress(
        v4="10.42.140.170",
        v6="2a00:8a00:6000:607c::4f0a",
        vlan_id=928,
        routing_v4=RoutingInformation(gateway="10.42.140.161/27"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4f01/120"),
    ),
    xnc=NetworkAddress(
        v4="10.255.21.10",
        v6="2a00:8a00:6000:607c::4b0a",
        vlan_id=924,
        routing_v4=RoutingInformation(gateway="10.255.21.1/27"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4b01/120"),
    ),
    xnu=NetworkAddress(
        v4="10.255.21.42",
        v6="2a00:8a00:6000:607c::4c0a",
        vlan_id=925,
        routing_v4=RoutingInformation(gateway="10.255.21.33/27"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4c01/120"),
    ),
)
_pdu_gnb = ATEN(addr="10.42.61.202", port_numbers=[6])
_pdu_gnb_ru = Gude(
    addr="10.44.206.183", port_numbers=[11], model="EPC", version="8221-1"
)

_pdus = [_pdu_gnb, _pdu_gnb_ru]
_gnb_ru = RU(
    ru_hw_group="cMAA_Gen4.0_8T8R",
    radio_type="AHCA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.2", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[11],
)

_abip1_gnb_1_master = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    serial_number="L1232105723",
    hardware_version="A.101",
)
_asim_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip1_gnb_1_master],
    pdu_port=_pdu_gnb.pdu_ports[6],
    hardware_type="ASIM",
    serial_number="L1233503178",
)

_airscale_gnb_1 = Airscale(common_units=[_asim_gnb_1])

_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_abip1_gnb_1_master, label="SFP", port_id=1),
        target=Endpoint(unit=_gnb_ru, label="SFP", port_id=1),
    ),
]

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru], cablinks=_ru_cablinks)
_dcap = DcapBasic(
    connection_details=HttpConnectionDetails(
        "127.0.0.1", port=9443, username="dcapuser", password="dcapadmin!"
    )
)
_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=51070, instance_id=51070, dcap=_dcap
)
_tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASIM_ABIP_AHCA_SEC_SCAN"
_cu_gnb_1.m = (
    NetworkAddress(
        v4="10.42.249.234",
        v6="2a00:8a00:6000:607c::4a0a",
        vlan_id=923,
        routing_v4=RoutingInformation(gateway="10.42.249.225/27"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4a01/120"),
    ),
)
_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.36", username="ute", password="ute"
    ),
    connections=[
        Connection(interface="eth1", device=_asim_gnb_1, interface_type="lmp")
    ],
)
tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    tl_cloud_topology=_tl_cloud_topology,
    test_pcs=[_lmp_vm_gnb_1],
    pdus=_pdus,
)
