__maintainer__ = "Damian Siwa"
__team__ = "TRSSEC"
__email__ = "I_EXT_5G_IV_TRSSEC@internal.nsn.com"
import os
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.enb import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.radio import RU
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF
from taf.config.testline.dcap import DcapBasic

__all__ = ["tl"]
_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.208", username="ute", password="ute"
    )
)
cfg_dir = os.path.dirname(os.path.abspath(__file__))
_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.90.168",
        v6="2a00:8a00:6000:607c::1:be1c",
        vlan_id=488,
        routing_v4=RoutingInformation(gateway="10.44.90.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:be01/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", port=443, username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.90.235",
        v6="2a00:8a00:6000:607c::1:bf1f",
        vlan_id=489,
        routing_v4=RoutingInformation(gateway="10.44.90.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:bf01/120"),
    ),
    x2u=NetworkAddress(
        v4="10.44.91.44",
        v6="2a00:8a00:6000:607c::1:c01e",
        vlan_id=490,
        routing_v4=RoutingInformation(gateway="10.44.91.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:c001/120"),
    ),
    s1u=NetworkAddress(
        v4="10.44.91.109",
        v6="2a00:8a00:6000:607c::1:c11c",
        vlan_id=491,
        routing_v4=RoutingInformation(gateway="10.44.91.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:c101/120"),
    ),
    ngu=NetworkAddress(
        v4="10.44.91.109",
        v6="2a00:8a00:6000:607c::1:c11c",
        vlan_id=491,
        routing_v4=RoutingInformation(gateway="10.44.91.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:c101/120"),
    ),
    ngc=NetworkAddress(
        v4="10.44.91.171",
        v6="2a00:8a00:6000:607c::1:c21b",
        vlan_id=492,
        routing_v4=RoutingInformation(gateway="10.44.91.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:c201/120"),
    ),
    xnc=NetworkAddress(
        v4="10.44.90.235",
        v6="2a00:8a00:6000:607c::1:bf1f",
        vlan_id=489,
        routing_v4=RoutingInformation(gateway="10.44.90.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:bf01/120"),
    ),
    xnu=NetworkAddress(
        v4="10.44.91.44",
        v6="2a00:8a00:6000:607c::1:c01e",
        vlan_id=490,
        routing_v4=RoutingInformation(gateway="10.44.91.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:c001/120"),
    ),
)
_pdu_gnb = ATEN(addr="10.44.205.221", port_numbers=[7])
_pdu_gnb_ru1 = Gude(  # PDU RU TL 330
    addr="10.44.205.222",
    port_numbers=[3],
    model="EPC",
    version="8221-1",
)
_pdu_gnb_ru2 = Gude(  # PDU RU TL 330
    addr="10.44.205.222",
    port_numbers=[4],
    model="EPC",
    version="8221-1",
)

_gnb_ru1 = RU(
    ru_hw_group="AZQO",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.48.2", username="root", password="a2%FgSz3$fHmdusap354xujw7a"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="a2%FgSz3$fHmdusap354xujw7a"
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[3],
)
_gnb_ru2 = RU(
    ru_hw_group="AZQO",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.48.6", username="root", password="a2%FgSz3$fHmdusap354xujw7a"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="a2%FgSz3$fHmdusap354xujw7a"
    ),
    pdu_port=_pdu_gnb_ru2.pdu_ports[4],
)
_abil1_gnb_1_master = CapacityUnit(addr="192.168.253.20")
_abil1_gnb_1_slave = CapacityUnit(addr="192.168.253.21")
_abil1_gnb_1_loner = CapacityUnit(addr="192.168.253.22")
_asib_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_master, _abil1_gnb_1_loner, _abil1_gnb_1_slave],
    pdu_port=_pdu_gnb.pdu_ports[7],
)
_airscale_gnb_1 = Airscale(common_units=[_asib_gnb_1])
_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_abil1_gnb_1_master, label="SFP", port_id=1),
        target=Endpoint(unit=_gnb_ru1, label="SFP", port_id=1),
    )
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
    cu=_cu_gnb_1,
    dus=[_du_1_gnb_1],
    global_bts_id=51051,  # need to fill
    instance_id=51051,
    dcap=_dcap,
)  # need to fill
# _tl_cloud_topology = "CLOUD_5G_CLASSICAL_SA_ASIBL_ABILB1_AHCA"
_tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASIB_ABIL_AHLOA_ENB"
_amf_ssh = SshServiceDetails(
    addr="to_be_updated", username="to_be_updated", password="to_be_updated"
)
_amf_n2_addr = NetworkAddress(
    v4="10.94.232.6", v6="2a00:8a00:4000:65ef:ffff:ffff:ffff:b804", vlan_id=None
)
_amf = AMF(oam_ssh_connection_details=_amf_ssh, n2=_amf_n2_addr)
_core = RealCore(five_g=RealCore5GDetails(amf=_amf), mcc=540, mnc=1)
_cu_gnb_1.m = NetworkAddress(
    v4="10.44.90.168",
    v6="2a00:8a00:6000:607c::1:be1c",
    vlan_id=488,
    routing_v4=RoutingInformation(gateway="10.44.90.129/26"),
    routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:be01/120"),
)
tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    core=_core,
    tl_cloud_topology=_tl_cloud_topology,
    test_pcs=[_lmp_vm_gnb_1],
)
