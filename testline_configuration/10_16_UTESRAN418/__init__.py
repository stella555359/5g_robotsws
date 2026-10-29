__maintainer__ = "Monika Walendzik"
__team__ = "MN_VRF_WRO32"
__email__ = "i_mn_ran_rd_vrf_wro3_2@internal.nsn.com"
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
        v4="10.42.143.55",
        v6="2a00:8a00:6000:607c::4a23",
        vlan_id=923,
        routing_v4=RoutingInformation(gateway="10.42.143.49/28"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4a01/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", port=443, username="Nemuadmin", password="nemuuser"
    ),
    x2u=NetworkAddress(
        v4="10.255.35.183",
        v6="2a00:8a00:6000:607c::4c23",
        vlan_id=925,
        routing_v4=RoutingInformation(gateway="10.255.35.177/28"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4c01/120"),
    ),
    x2c=NetworkAddress(
        v4="10.255.35.167",
        v6="2a00:8a00:6000:607c::4b23",
        vlan_id=924,
        routing_v4=RoutingInformation(gateway="10.255.35.161/28"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4b01/120"),
    ),
    s1u=NetworkAddress(
        v4="10.255.35.199",
        v6="2a00:8a00:6000:607c::4d23",
        vlan_id=926,
        routing_v4=RoutingInformation(gateway="10.255.35.193/28"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4d01/120"),
    ),
    ngu=NetworkAddress(
        v4="10.42.141.39",
        v6="2a00:8a00:6000:607c::4e23",
        vlan_id=927,
        routing_v4=RoutingInformation(gateway="10.42.141.133/28"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4e01/120"),
    ),
    ngc=NetworkAddress(
        v4="10.42.141.55",
        v6="2a00:8a00:6000:607c::4f23",
        vlan_id=928,
        routing_v4=RoutingInformation(gateway="10.42.141.49/28"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4f01/120"),
    ),
    xnc=NetworkAddress(
        v4="10.255.35.167",
        v6="2a00:8a00:6000:607c::4b23",
        vlan_id=924,
        routing_v4=RoutingInformation(gateway="10.255.35.161/28"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4b01/120"),
    ),
    xnu=NetworkAddress(
        v4="10.255.35.183",
        v6="2a00:8a00:6000:607c::4c23",
        vlan_id=925,
        routing_v4=RoutingInformation(gateway="10.255.35.177/28"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4c01/120"),
    ),
)
_pdu_gnb = Gude(addr="10.44.206.34", port_numbers=[2], model="EPC", version="8220-1")
_pdu_gnb_ru = Gude(
    addr="10.44.206.183", port_numbers=[3], model="EPC", version="8221-1"
)

_pdus = [_pdu_gnb, _pdu_gnb_ru]
_gnb_ru = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128",
        username="root",
        password="umnieniedziala",
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1",
        username="root",
        password="umnieniedzia\u0142a",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[3],
)

_asoh_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_gnb.pdu_ports[2],
    hardware_type="ASOH",
    rus=[_gnb_ru],
)
_airscale_gnb_1 = Airscale(common_units=[_asoh_gnb_1])
_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_asoh_gnb_1, label="SFP", port_id=1),
        target=Endpoint(unit=_gnb_ru, label="SFP", port_id=1),
    )
]
_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru], cablinks=_ru_cablinks)

_dcap = DcapBasic(
    connection_details=HttpConnectionDetails(
        "127.0.0.1", port=9443, username="dcapuser", password="dcapadmin!"
    )
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=51142, instance_id=51142, dcap=_dcap
)
_tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASOH_AHLOA_WRO_TRS"

_cu_gnb_1.m = NetworkAddress(
    v4="10.42.143.55",
    v6="2a00:8a00:6000:607c::4a23",
    vlan_id=923,
    routing_v4=RoutingInformation(gateway="10.42.143.49/28"),
    routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4a01/120"),
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.232", username="ute", password="UTE.debian12"
    ),
    connections=[
        Connection(interface="eth1", device=_asoh_gnb_1, interface_type="lmp")
    ],
)
tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    tl_cloud_topology=_tl_cloud_topology,
    test_pcs=[_lmp_vm_gnb_1],
)
