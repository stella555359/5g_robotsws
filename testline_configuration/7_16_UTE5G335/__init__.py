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
from taf.config.testline import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import ATEN
from taf.config.testline.radio import RU
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.dcap import DcapBasic

__all__ = ["tl"]

cfg_dir = os.path.dirname(os.path.abspath(__file__))
_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.90.154",
        v6="2a00:8a00:6000:607c::1:be10",
        vlan_id=488,
        routing_v4=RoutingInformation(gateway="10.44.90.129/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607C::1:be01/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", port=443, username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.90.220",
        v6="2a00:8a00:6000:607c::5658",
        vlan_id=489,
        routing_v4=RoutingInformation(gateway="10.44.90.193/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607C::5601/120"),
    ),
    x2u=NetworkAddress(
        v4="10.44.91.30",
        v6="2a00:8a00:6000:607c::5743",
        vlan_id=490,
        routing_v4=RoutingInformation(gateway="10.44.91.1/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607C::5701/120"),
    ),
    s1u=NetworkAddress(
        v4="10.44.91.94",
        v6="2a00:8a00:6000:607c::1:c110",
        vlan_id=491,
        routing_v4=RoutingInformation(gateway="10.44.91.65/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607C::1:c101/120"),
    ),
    ngu=NetworkAddress(
        v4="10.44.91.94",
        v6="2a00:8a00:6000:607c::1:c110",
        vlan_id=491,
        routing_v4=RoutingInformation(gateway="10.44.91.65/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607C::1:c101/120"),
    ),
    ngc=NetworkAddress(
        v4="10.44.84.87",
        v6="2a00:8a00:6000:607c::1:660f",
        vlan_id=893,
        routing_v4=RoutingInformation(gateway="10.44.84.65/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607C::1:6601/120"),
    ),
    xnc=NetworkAddress(
        v4="10.44.90.220",
        v6="2a00:8a00:6000:607c::5658",
        vlan_id=489,
        routing_v4=RoutingInformation(gateway="10.44.90.193/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607C::5601/120"),
    ),
    xnu=NetworkAddress(
        v4="10.44.91.30",
        v6="2a00:8a00:6000:607c::5743",
        vlan_id=490,
        routing_v4=RoutingInformation(gateway="10.44.91.1/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607C::5701/120"),
    ),
)
_pdu_gnb = ATEN(addr="10.44.206.126", port_numbers=[3])
_pdu_gnb_ru = ATEN(
    addr="none", port_numbers=[9]
)  # <------------------------------------- need to fill
_gnb_ru = RU(
    ru_hw_group="AEQN",
    radio_type="AEQN",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.10.1", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[9],
)

_gnb_ru_2 = RU(
    ru_hw_group="AHCA",
    radio_type="AHCA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.18.33", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="root"
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[9],
)

_abil1_gnb_1_master = CapacityUnit(addr="192.168.253.20")
_abil1_gnb_1_slave = CapacityUnit(addr="192.168.253.21")
_abil1_gnb_1_loner = CapacityUnit(addr="192.168.253.22")
_asik_gnb_1 = CommonUnit(
    hardware_type="ASIB",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_master, _abil1_gnb_1_loner, _abil1_gnb_1_slave],
    pdu_port=_pdu_gnb.pdu_ports[3],
)
_airscale_gnb_1 = Airscale(common_units=[_asik_gnb_1])
_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_abil1_gnb_1_master, label="SFP", port_id=1),
        target=Endpoint(unit=_gnb_ru, label="SFP", port_id=2),
    )
]
_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru], cablinks=_ru_cablinks)
_pdu_enb = ATEN(
    addr="10.44.206.126", port_numbers=[3]
)  # <------------------------------------- need to fill
_asik_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_master, _abil1_gnb_1_loner, _abil1_gnb_1_slave],
    pdu_port=_pdu_enb.pdu_ports[3],
)
_airscale_enb_1 = Airscale(common_units=[_asik_enb_1])
_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    global_bts_id=40201,
    instance_id=40201,
    x2_link_addr=NetworkAddress(
        v6="",  # No LTE
        v4="",  # No LTE
        vlan_id=455,
        routing_v4=RoutingInformation(gateway="10.44.64.65/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607C::5601/120"),
    ),
)
_enb_1.m_plane = NetworkAddress(
    v6="",  # No LTE
    v4="",  # No LTE
    vlan_id=454,
    routing_v4=RoutingInformation(gateway="10.44.64.1/26"),
    routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607C::5501/120"),
)
_dcap = DcapBasic(
    connection_details=HttpConnectionDetails(
        "127.0.0.1", port=9443, username="dcapuser", password="dcapadmin!"
    )
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50243, instance_id=50243, dcap=_dcap
)
_tl_cloud_topology = "CLOUD_5G_CLASSICAL_SA_ASIB_ABIO_AEQN_AHCA"
_amf_ssh = SshServiceDetails(
    addr="to_be_updated", username="to_be_updated", password="to_be_updated"
)
_amf_n2_addr = NetworkAddress(
    v4="10.27.28.136", v6="2a00:8a00:4000:6000::4c:506", vlan_id=None
)
_amf = AMF(oam_ssh_connection_details=_amf_ssh, n2=_amf_n2_addr)
_core = RealCore(five_g=RealCore5GDetails(amf=_amf, tac=7150), mcc=310, mnc=260)
# temp _cu_gnb_1.m
_cu_gnb_1.m = (
    NetworkAddress(
        v4="10.44.90.154",
        v6="2a00:8a00:6000:607c::1:be10",
        vlan_id=488,
        routing_v4=RoutingInformation(gateway="10.44.90.129/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607C::1:be01/120"),
    ),
)
# temp _enb_1.m
_enb_1.m = NetworkAddress(
    v6="",  # No LTE
    v4="",  # No LTE
    vlan_id=454,
    routing_v4=RoutingInformation(gateway="10.44.64.1/26"),
    routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607C::5501/120"),
)
_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(addr="", username="", password=""),
    connections=[_enb_1],
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.209.200", username="ute", password="ute"
    ),
    connections=[
        Connection(interface="eth1", device=_asik_gnb_1, interface_type="lmp"),
    ],
)

with open(
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "nokia_ue.yaml")
) as ue_config:
    import yaml

    _nokia_ue = yaml.load(ue_config, yaml.SafeLoader)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    core=_core,
    ues=[_nokia_ue],
    tl_cloud_topology=_tl_cloud_topology,
    enbs=[_enb_1],
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_enb_1],
)
