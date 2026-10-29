__maintainer__ = "Piotr Pawlowski"
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
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import ATEN, Gude, APC
from taf.config.testline.radio import RU
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF
from taf.config.testline.dcap import DcapBasic

__all__ = ["tl"]
_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.21", username="ute", password="ute"
    )
)
cfg_dir = os.path.dirname(os.path.abspath(__file__))
_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.64.30",
        routing_v4=RoutingInformation(gateway="10.44.64.1/26"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", port=443, username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.64.94",
        vlan_id=455,
        routing_v4=RoutingInformation(gateway="10.44.64.65/26"),
    ),
    x2u=NetworkAddress(
        v4="10.44.64.158",
        vlan_id=456,
        routing_v4=RoutingInformation(gateway="10.44.64.129/26"),
    ),
    s1u=NetworkAddress(
        v4="10.44.84.68",
        vlan_id=893,
        routing_v4=RoutingInformation(gateway="10.44.84.65/26"),
    ),
    ngu=NetworkAddress(
        v4="10.44.64.94",
        vlan_id=455,
        routing_v4=RoutingInformation(gateway="10.44.64.65/26"),
    ),
    ngc=NetworkAddress(
        v4="10.44.64.94",
        vlan_id=455,
        routing_v4=RoutingInformation(gateway="10.44.64.65/26"),
    ),
    xnc=NetworkAddress(
        v4="10.44.64.94",
        vlan_id=455,
        routing_v4=RoutingInformation(gateway="10.44.64.65/26"),
    ),
    xnu=NetworkAddress(
        v4="10.44.65.30",
        vlan_id=458,
        routing_v4=RoutingInformation(gateway="10.44.65.1/26"),
    ),
)
_pdu_gnb = Gude(
    addr="10.44.206.160",
    port_numbers=[10],
    model="EPC",
    version="8220-1",
)
_pdu_gnb_ru = Gude(
    addr="10.44.206.161",
    port_numbers=[6],
    model="EPC",
    version="8226-1",
)
_gnb_ru = RU(
    ru_hw_group="AZQG",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="a2%FgSz3$fHmdusap354xujw7a"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="a2%FgSz3$fHmdusap354xujw7a"
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[6],
)
_abil1_gnb_1_master = CapacityUnit(addr="192.168.253.20")
_abil1_gnb_1_slave = CapacityUnit(addr="192.168.253.21")
_abil1_gnb_1_loner = CapacityUnit(addr="192.168.253.22")
_asik_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_master, _abil1_gnb_1_loner, _abil1_gnb_1_slave],
    pdu_port=_pdu_gnb.pdu_ports[10],
)
_airscale_gnb_1 = Airscale(common_units=[_asik_gnb_1])
_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_abil1_gnb_1_master, label="SFP", port_id=1),
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
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50219, instance_id=50219, dcap=_dcap
)
_tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASIK_ABIL_AHCA_ENB"
_amf_ssh = SshServiceDetails(
    addr="to_be_updated", username="to_be_updated", password="to_be_updated"
)
_amf_n2_addr = NetworkAddress(
    v4="10.94.232.6", v6="2a00:8a00:4000:65ef:ffff:ffff:ffff:b804", vlan_id=None
)
_amf = AMF(oam_ssh_connection_details=_amf_ssh, n2=_amf_n2_addr)
_core = RealCore(
    five_g=RealCore5GDetails(amf=_amf, tac=7151),
    mcc=540,
    mnc=1,
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    core=_core,
    tl_cloud_topology=_tl_cloud_topology,
    test_pcs=[_lmp_vm_gnb_1],
)
