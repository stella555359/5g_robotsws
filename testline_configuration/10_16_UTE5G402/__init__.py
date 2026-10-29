__maintainer__ = "Michal Wlosek"
__team__ = "TRSSEC"
__email__ = "I_EXT_5G_IV_TRSSEC@internal.nsn.com"
import os
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import TafUeAndroid
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
        v4="10.42.84.23",
        v6="2a00:8a00:6000:600c::1b10",
        vlan_id=517,
        routing_v4=RoutingInformation(gateway="10.42.84.1/24"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1b01/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.42.85.23",
        v6="2a00:8a00:6000:600c::1c10",
        vlan_id=518,
        routing_v4=RoutingInformation(gateway="10.42.85.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1c01/120"),
    ),
    x2u=NetworkAddress(
        v4="10.42.85.87",
        v6="2a00:8a00:6000:600c::1d10",
        vlan_id=519,
        routing_v4=RoutingInformation(gateway="10.42.85.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1d01/120"),
    ),
    s1u=NetworkAddress(
        v4="10.42.85.151",
        v6="2a00:8a00:6000:600c::1e10",
        vlan_id=520,
        routing_v4=RoutingInformation(gateway="10.42.85.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1e01/120"),
    ),
    ngu=NetworkAddress(
        v4="10.42.85.151",
        v6="2a00:8a00:6000:600c::1e10",
        vlan_id=520,
        routing_v4=RoutingInformation(gateway="10.42.85.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1e01/120"),
    ),
    ngc=NetworkAddress(
        v4="10.42.86.23",
        v6="2a00:8a00:6000:600c::2010",
        vlan_id=522,
        routing_v4=RoutingInformation(gateway="10.42.86.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::2001/120"),
    ),
    xnc=NetworkAddress(
        v4="10.42.85.23",
        v6="2a00:8a00:6000:600c::1c10",
        vlan_id=518,
        routing_v4=RoutingInformation(gateway="10.42.85.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1c01/120"),
    ),
    xnu=NetworkAddress(
        v4="10.42.85.87",
        v6="2a00:8a00:6000:600c::1d10",
        vlan_id=519,
        routing_v4=RoutingInformation(gateway="10.42.85.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1d01/120"),
    ),
)
_pdu_gnb = Gude(
    addr="10.44.200.107", port_numbers=[9, 10, 11, 12], model="EPC", version="8220-1"
)
_pdu_gnb_ru_1 = Gude(
    addr="10.44.200.96", port_numbers=[3, 5], model="EPC", version="8220-1"
)
_pdu_gnb_ru_2 = Gude(
    addr="10.44.200.95", port_numbers=[3, 4, 5, 6, 7], model="EPC", version="8221-1"
)


_gnb_ru_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AQQK",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.130", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[3],
)

_gnb_ru_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AQQK",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.129", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    pdu_port=_pdu_gnb_ru_2.pdu_ports[4],
)

_gnb_ru_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AQQK",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.128", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    pdu_port=_pdu_gnb_ru_2.pdu_ports[3],
)

_enb_ru_1 = RU(
    ru_hw_group="cMAAr6.1_32T32R",
    radio_type="AHFIC",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.2", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[5],
)

_enb_ru_2 = RU(
    ru_hw_group="cMAAr6.1_32T32R",
    radio_type="AHFIC ",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.10", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    pdu_port=_pdu_gnb.pdu_ports[9],
)

_enb_ru_3 = RU(
    ru_hw_group="cMAAr6.1_32T32R",
    radio_type="AHFIC ",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.18", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    pdu_port=_pdu_gnb.pdu_ports[12],
)

_enb_ru_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHBCC ",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.130", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    pdu_port=_pdu_gnb_ru_2.pdu_ports[5],
)

_enb_ru_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHBCC ",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.129", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    pdu_port=_pdu_gnb_ru_2.pdu_ports[6],
)

_enb_ru_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHBCC ",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.132", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    pdu_port=_pdu_gnb_ru_2.pdu_ports[7],
)


_abio_gnb_1_master = CapacityUnit(
    addr="192.168.253.20", hardware_type="ABIO", serial_number="L1204104744"
)


_abio_gnb_1_master = CapacityUnit(
    addr="192.168.253.20", hardware_type="ABIO", serial_number="EA194457500"
)


_asil_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_1_master, _abio_gnb_1_master],
    pdu_port=_pdu_gnb.pdu_ports[10],
    hardware_type="ASIL",
    serial_number="L1204110706",
)

_abia_enb_1_master = CapacityUnit(
    addr="192.168.253.20", hardware_type="ABIA", serial_number="EA184674339"
)

_abia_enb_2_master = CapacityUnit(
    addr="192.168.253.20", hardware_type="ABIA", serial_number="L1172911364"
)

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        _abia_enb_1_master,
        _abia_enb_2_master,
    ],
    pdu_port=_pdu_gnb.pdu_ports[11],
    hardware_type="ASIA",
    serial_number="L1162615256",
)


_airscale_gnb_1 = Airscale(common_units=[_asil_gnb_1])
_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])


_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_abia_enb_1_master, label="SFP", port_id=1),
        target=Endpoint(unit=_enb_ru_1, label="SFP", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_abia_enb_1_master, label="SFP", port_id=2),
        target=Endpoint(unit=_enb_ru_2, label="SFP", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_abia_enb_1_master, label="SFP", port_id=3),
        target=Endpoint(unit=_enb_ru_3, label="SFP", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_abia_enb_2_master, label="SFP", port_id=1),
        target=Endpoint(unit=_enb_ru_4, label="SFP", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_abia_enb_2_master, label="SFP", port_id=2),
        target=Endpoint(unit=_enb_ru_5, label="SFP", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_abia_enb_2_master, label="SFP", port_id=3),
        target=Endpoint(unit=_enb_ru_6, label="SFP", port_id=1),
    ),
]

_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1,
    rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3],
    cablinks=_ru_cablinks,
)

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    global_bts_id=40270,
    instance_id=40270,
    x2_link_addr=NetworkAddress(
        v6="2a00:8a00:6000:607c::1:bd3c",
        v4="10.42.86.143",
        vlan_id=487,
        routing_v4=RoutingInformation(gateway="10.44.90.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:bd01/120"),
    ),
)
_enb_1.m_plane = NetworkAddress(
    v6="2a00:8a00:6000:607c::1:b649",
    v4="10.42.86.143",
    vlan_id=486,
    routing_v4=RoutingInformation(gateway=" 10.44.90.1/26"),
    routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b601/120"),
)
_dcap = DcapBasic(
    connection_details=HttpConnectionDetails(
        "127.0.0.1", port=9443, username="dcapuser", password="dcapadmin!"
    )
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=40270, instance_id=40270, dcap=_dcap
)
_tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASIL_ABIO_WRO_TRS_402"
_amf_ssh = SshServiceDetails(
    addr="to_be_updated", username="to_be_updated", password="to_be_updated"
)
_amf_n2_addr = NetworkAddress(
    v4="10.27.28.136", v6="2a00:8a00:4000:65ef:ffff:ffff:ffff:b804", vlan_id=None
)
_amf = AMF(oam_ssh_connection_details=_amf_ssh, n2=_amf_n2_addr)
_core = RealCore(five_g=RealCore5GDetails(amf=_amf, tac=7151), mcc=540, mnc=1)
# temp _cu_gnb_1.m

_cu_gnb_1.m = (
    NetworkAddress(
        v4="10.44.88.136",
        v6="2a00:8a00:6000:607c::1:b649",
        vlan_id=480,
        routing_v4=RoutingInformation(gateway="10.44.88.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b601/120"),
    ),
)
# temp _enb_1.m

_enb_1.m = NetworkAddress(
    v6="2a00:8a00:6000:607c::1:b649",
    v4="10.42.86.143",
    vlan_id=486,
    routing_v4=RoutingInformation(gateway=" 10.44.90.1/26"),
    routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b601/120"),
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.146", username="ute", password="ute"
    ),
    connections=[
        Connection(interface="eth1", device=_asil_gnb_1, interface_type="lmp"),
    ],
)

_ue_pc_ssh = SshServiceDetails(
    "10.44.72.242", "NOKLAB\plwrtrssec", password="tr55ec123"
)

_android_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_conf.yaml"
)


tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    core=_core,
    tl_cloud_topology=_tl_cloud_topology,
    enbs=[_enb_1],
    test_pcs=[_lmp_vm_gnb_1],
)
