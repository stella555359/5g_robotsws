__maintainer__ = "Damian Siwa"
__team__ = "TRSSEC"
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
from taf.config.testline.pdu import ATEN, APC
from taf.config.testline.radio import RU
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.dcap import DcapBasic

__all__ = ["tl"]
cfg_dir = os.path.dirname(os.path.abspath(__file__))
_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.90.181",
        v6="2a00:8a00:6000:607c::1:be26",
        vlan_id=488,
        routing_v4=RoutingInformation(gateway="10.44.91.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:be01/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", port=443, username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.90.248",
        v6="2a00:8a00:6000:607c::1:bf29",
        vlan_id=489,
        routing_v4=RoutingInformation(gateway="10.44.90.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:bf01/120"),
    ),
    x2u=NetworkAddress(
        v4="10.44.91.57",
        v6="2a00:8a00:6000:607c::1:c028",
        vlan_id=490,
        routing_v4=RoutingInformation(gateway="10.44.91.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:c001/120"),
    ),
    s1u=NetworkAddress(
        v4="10.44.91.122",
        v6="2a00:8a00:6000:607c::1:c126",
        vlan_id=491,
        routing_v4=RoutingInformation(gateway="10.44.91.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:c101/120"),
    ),
    ngu=NetworkAddress(
        v4="10.44.91.184",
        v6="2a00:8a00:6000:607c::1:c225",
        vlan_id=492,
        routing_v4=RoutingInformation(gateway="10.44.91.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:c201/120"),
    ),
    ngc=NetworkAddress(
        v4="10.44.91.251",
        v6="2a00:8a00:6000:607c::1:c325",
        vlan_id=493,
        routing_v4=RoutingInformation(gateway="10.44.91.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:c301/120"),
    ),
    xnc=NetworkAddress(
        v4="10.44.90.248",
        v6="2a00:8a00:6000:607c::1:bf29",
        vlan_id=489,
        routing_v4=RoutingInformation(gateway="10.44.90.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:bf01/120"),
    ),
    xnu=NetworkAddress(
        v4="10.44.91.57",
        v6="2a00:8a00:6000:607c::1:c028",
        vlan_id=490,
        routing_v4=RoutingInformation(gateway="10.44.91.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:c001/120"),
    ),
)
_pdu_gnb = ATEN(addr="10.44.206.126", port_numbers=[5])
_pdu_gnb_ru = ATEN(addr="10.44.206.176", port_numbers=[1])
_gnb_ru = RU(
    ru_hw_group="AHLOA",
    radio_type="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[1],
)
_abil1_gnb_1_master = CapacityUnit(
    addr="192.168.253.20", 
    hardware_type="ABIL", 
    hardware_version="101", 
    rus=[_gnb_ru],
)

_abil1_gnb_1_slave = CapacityUnit(
    addr="192.168.253.21", 
    hardware_type="ABIL", 
    hardware_version="101",
    rus=[_gnb_ru],
)
    
_abil1_gnb_1_loner = CapacityUnit(
    addr="192.168.253.22", 
    hardware_type="ABIL", 
    hardware_version="101",
    rus=[_gnb_ru],
)
    
_asik_gnb_1 = CommonUnit(
    hardware_type="ASIK",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_master, _abil1_gnb_1_loner, _abil1_gnb_1_slave],
    pdu_port=_pdu_gnb.pdu_ports[5],
)
_airscale_gnb_1 = Airscale(common_units=[_asik_gnb_1])
_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_abil1_gnb_1_master, label="SFP", port_id=1),
        target=Endpoint(unit=_gnb_ru, label="SFP", port_id=2),
    )
]
_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru], cablinks=_ru_cablinks)
_pdu_enb = ATEN(addr="10.44.206.126", port_numbers=[5])
_asik_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_master, _abil1_gnb_1_loner, _abil1_gnb_1_slave],
    pdu_port=_pdu_enb.pdu_ports[5],
    hardware_type="ASIK",
)
_airscale_enb_1 = Airscale(common_units=[_asik_enb_1])
_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    global_bts_id=40275,
    instance_id=40275,
    x2_link_addr=NetworkAddress(
        v4="",  # No LTE
        v6="",  # No LTE
        vlan_id=910,
        routing_v4=RoutingInformation(gateway="10.44.79.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b501/120"),
    ),
)
_enb_1.m_plane = NetworkAddress(
    v4="",  # No LTE
    v6="",  # No LTE
    vlan_id=909,
    routing_v4=RoutingInformation(gateway="10.44.78.193/26"),
    routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b401/120"),
)
_dcap = DcapBasic(
    connection_details=HttpConnectionDetails(
        "127.0.0.1", port=9443, username="dcapuser", password="dcapadmin!"
    )
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50277, instance_id=50277, dcap=_dcap
)
# _tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASIKL_ABILB1"
_tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASIK_ABIL_AHLOA_ENB"
_amf_ssh = SshServiceDetails(
    addr="to_be_updated", username="to_be_updated", password="to_be_updated"
)
_amf_n2_addr = NetworkAddress(
    v4="10.94.232.6", v6="2a00:8a00:4000:65ef:ffff:ffff:ffff:b804", vlan_id=None
)
_amf = AMF(oam_ssh_connection_details=_amf_ssh, n2=_amf_n2_addr)
_core = RealCore(five_g=RealCore5GDetails(amf=_amf, tac=7151), mcc=540, mnc=1)

# temp _enb_1.m
_enb_1.m = NetworkAddress(
    v4="",  # No LTE
    v6="",  # No LTE
    vlan_id=459,
    routing_v4=RoutingInformation(gateway="10.44.80.1/26"),
    routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5a01/120"),
)
_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.182", username="ute", password="ute"
    ),
    connections=[_enb_1],
)

_attenuator = TopYoung(
    ip_addr="10.42.221.131",
    port=3001,
    attenuation_port_numbers=[1, 2],
    model="TAS24T24_0_2G6_90_1S_EJS",
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.182", username="ute", password="ute"
    ),
    connections=[
        Connection(interface="eth1", device=_asik_gnb_1, interface_type="lmp"),
    ],
)

_pdu_ue_3 = APC(addr="10.44.205.67", port_numbers=[3])
_pdu_ue_5 = APC(addr="10.44.205.67", port_numbers=[5])

with open(
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "askey_ue.yaml")
) as ue_config:
    import yaml

    _askey_ue = yaml.load(ue_config, yaml.SafeLoader)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    core=_core,
    ues=[_askey_ue],
    pdus=[_pdu_ue_3, _pdu_ue_5],
    tl_cloud_topology=_tl_cloud_topology,
    enbs=[_enb_1],
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_enb_1],
    attenuator=_attenuator,
)
