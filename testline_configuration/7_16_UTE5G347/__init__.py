__maintainer__ = "Jakub Sikora"
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
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import ATEN, EPC, Gude
from taf.config.testline.radio import RU
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF
from taf.config.testline.dcap import DcapBasic

__all__ = ["tl"]

cfg_dir = os.path.dirname(os.path.abspath(__file__))
_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.90.158",
        v6="2a00:8a00:6000:607c::1:be0c",
        vlan_id=488,
        routing_v4=RoutingInformation(gateway="10.44.90.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:be01/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(
        v4="10.44.90.225",
        v6="2a00:8a00:6000:607c::1:bf0f",
        vlan_id=489,
        routing_v4=RoutingInformation(gateway="10.44.90.193/26"),
        routing_v6=RoutingInformation(gateway="	2a00:8a00:6000:607c::1:bf01/120"),
    ),
    x2u=NetworkAddress(
        v4="10.44.91.17",
        v6="2a00:8a00:6000:607c::1:c00f",
        vlan_id=490,
        routing_v4=RoutingInformation(gateway="10.44.91.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:c001/120"),
    ),
    s1u=NetworkAddress(
        v4="10.44.91.99",
        v6="2a00:8a00:6000:607c::1:c10c",
        vlan_id=491,
        routing_v4=RoutingInformation(gateway="10.44.91.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:c101/120"),
    ),
    ngu=NetworkAddress(
        v4="10.44.91.99",
        v6="2a00:8a00:6000:607c::1:c10c",
        vlan_id=491,
        routing_v4=RoutingInformation(gateway="10.44.91.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:c101/120"),
    ),
    ngc=NetworkAddress(
        v4="10.44.91.160",
        v6="2a00:8a00:6000:607c::1:c20c",
        vlan_id=492,
        routing_v4=RoutingInformation(gateway="10.44.91.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:c201/120"),
    ),
    xnc=NetworkAddress(
        v4="10.44.90.225",
        v6="2a00:8a00:6000:607c::1:bf0f",
        vlan_id=489,
        routing_v4=RoutingInformation(gateway="10.44.90.193/26"),
        routing_v6=RoutingInformation(gateway="	2a00:8a00:6000:607c::1:bf01/120"),
    ),
    xnu=NetworkAddress(
        v4="10.44.91.17",
        v6="2a00:8a00:6000:607c::1:c00f",
        vlan_id=490,
        routing_v4=RoutingInformation(gateway="10.44.91.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:c001/120"),
    ),
)
_pdu_gnb = Gude(addr="10.44.206.161", port_numbers=[8], model="EPC", version="8226-1")
_pdu_gnb_ru1 = Gude(
    addr="10.44.206.183", port_numbers=[1], model="EPC", version="8221-1"
)

_gnb_ru1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[1],
)

_abil1_gnb_1_master = CapacityUnit(
    addr="192.168.253.20", hardware_type="ABIL", serial_number="EA194457473"
)
_asik_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_master],
    pdu_port=_pdu_gnb.pdu_ports[8],
    hardware_type="ASIK",
    serial_number="L1190315361",
)
_airscale_gnb_1 = Airscale(common_units=[_asik_gnb_1])
_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_abil1_gnb_1_master, label="SFP", port_id=1),
        target=Endpoint(unit=_gnb_ru1, label="SFP", port_id=1),
    )
]
_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru1], cablinks=_ru_cablinks)

_dcap = DcapBasic(
    connection_details=HttpConnectionDetails(
        "127.0.0.1", port=9443, username="dcapuser", password="dcapadmin!"
    )
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50267, instance_id=50267, dcap=_dcap
)

_tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASIK_ABIL_AHLOA_WRO_TRS"
_amf_ssh = SshServiceDetails(
    addr="to_be_updated", username="to_be_updated", password="to_be_updated"
)
_amf_n2_addr = NetworkAddress(
    v4="10.94.232.6", v6="2a00:8a00:4000:65ef:ffff:ffff:ffff:b804", vlan_id=None
)
_amf = AMF(oam_ssh_connection_details=_amf_ssh, n2=_amf_n2_addr)
_core = RealCore(five_g=RealCore5GDetails(amf=_amf, tac=7151), mcc=540, mnc=1)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.16", username="ute", password="ute"
    ),
    connections=[
        Connection(interface="eth1", device=_asik_gnb_1, interface_type="lmp")
    ],
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    core=_core,
    tl_cloud_topology=_tl_cloud_topology,
    test_pcs=[_lmp_vm_gnb_1],
)
