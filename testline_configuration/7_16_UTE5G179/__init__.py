__maintainer__ = "Anna Gibała-Wojtal"
__team__ = "MN_VRF34"
__email__ = "I_EXT_5G_IV_TRSSEC@internal.nsn.com"

import os
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import ATEN, EPC, Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.dcap import DcapBasic
from taf.config.testline import RoutingInformation
from taf.config.testline.gnb import ClassicalBts, CU, DU

from taf.config.testline.gnb.du import Cablink, Endpoint


from taf.config.testline.core import RealCore, RealCore5GDetails, AMF

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_cu_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.68.188",
        v6="2a00:8a00:6000:607c::1:ae30",
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
        v4="10.44.68.254",
        v6="2a00:8a00:6000:607c::1:af30",
        vlan_id=904,
        routing_v4=RoutingInformation(gateway="10.44.68.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:af01/120"),
    ),
    x2u=NetworkAddress(
        v4="10.44.70.62",
        v6="2a00:8a00:6000:607c::1:b030",
        vlan_id=905,
        routing_v4=RoutingInformation(gateway="10.44.70.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b001/120"),
    ),
    s1u=NetworkAddress(
        v4="10.44.70.124",
        v6="2a00:8a00:6000:607c::1:b130",
        vlan_id=906,
        routing_v4=RoutingInformation(gateway="10.44.70.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b101/120"),
    ),
    ngu=NetworkAddress(
        v6="2a00:8a00:6000:607c::1:b330",
        v4="10.44.70.188",
        vlan_id=908,
        routing_v4=RoutingInformation(gateway="10.44.70.185/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b301/120"),
    ),
    ngc=NetworkAddress(
        v6="2a00:8a00:6000:607c::1:b230",
        v4="10.44.70.253",
        vlan_id=907,
        routing_v4=RoutingInformation(gateway="10.44.70.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b201/120"),
    ),
    xnc=NetworkAddress(
        v4="10.44.68.254",
        v6="2a00:8a00:6000:607c::1:af30",
        vlan_id=904,
        routing_v4=RoutingInformation(gateway="10.44.68.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:af01/120"),
    ),
    xnu=NetworkAddress(
        v4="10.44.70.62",
        v6="2a00:8a00:6000:607c::1:b030",
        vlan_id=905,
        routing_v4=RoutingInformation(gateway="10.44.70.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b001/120"),
    ),
)

_pdu_sm = Gude(addr="10.44.206.157", port_numbers=[8], model="EPC", version="8221-1")
_pdu_rm = Gude(addr="10.44.177.24", port_numbers=[5], model="EPC", version="8221-1")

_rmod_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="umniedziala"
    ),
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVQL",
    serial_number="L1232909583",
    product_code="476204A.101",
    pdu_port=_pdu_rm.pdu_ports[5],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204108996",
    rus=[_rmod_1],
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_sm.pdu_ports[8],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH203062287",
)
_smod_1 = Airscale([_fct_1])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],
    instance_id=40227,
    oam_ip=NetworkAddress(
        v4="10.44.68.188",
        v6="2a00:8a00:6000:607c::1:ae30",
        vlan_id=910,
        routing_v4=RoutingInformation(gateway="10.44.79.1", ip_prefix_length=26),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::1:b501", ip_prefix_length=120
        ),
    ),
)


_du_1_gnb_1 = DU(airscale=_smod_1, rus=[_rmod_1])

_dcap = DcapBasic(
    connection_details=HttpConnectionDetails(
        "127.0.0.1", port=9443, username="dcapuser", password="dcapadmin!"
    )
)

_cbts = ClassicalBts(
    cu=_cu_gnb, dus=[_du_1_gnb_1], global_bts_id=50229, instance_id=50229, dcap=_dcap
)

_test_pc_1 = TestPc(
    SshServiceDetails(
        addr="10.44.156.47",
        username="ute",
        password="uteUTE!",
    ),
    connections=[
        NetworkAddress(v4="192.168.255.129"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_pdus = [_pdu_sm, _pdu_rm]

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_SRAN_TL179",
    pdus=_pdus,
)

__all__ = ["tl"]
