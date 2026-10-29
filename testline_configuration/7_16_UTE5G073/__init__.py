__maintainer__ = "Monika Walendzik"
__team__ = "MN 5G RAN I&V 3 Pz TRS 5 SG"
__email__ = "I_EXT_5G_IV_WRO_TRS@internal.nsn.com"
__owner_email__ = "monika.walendzik@nokia.com"
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
from taf.config.testline.pdu import ATEN, Gude, EPC
from taf.config.testline.radio import RU
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF
from taf.config.testline.dcap import DcapBasic


__all__ = ["tl"]

cfg_dir = os.path.dirname(os.path.abspath(__file__))
_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.249.235",
        v6="2a00:8a00:6000:607c::4a0b",
        vlan_id=923,
        routing_v4=RoutingInformation(gateway="10.42.249.225", ip_prefix_length=27),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::4a01", ip_prefix_length=120
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.255.21.11",
        v6="2a00:8a00:6000:607c::4b0b",
        vlan_id=924,
        routing_v4=RoutingInformation(gateway="10.255.21.1", ip_prefix_length=27),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::4b01", ip_prefix_length=120
        ),
    ),
    x2u=NetworkAddress(
        v4="10.255.21.43",
        v6="2a00:8a00:6000:607c::4c0b",
        vlan_id=925,
        routing_v4=RoutingInformation(gateway="10.255.21.33", ip_prefix_length=27),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::4c01", ip_prefix_length=120
        ),
    ),
    s1u=NetworkAddress(
        v4="10.255.21.75",
        v6="2a00:8a00:6000:607c::4d0b",
        vlan_id=926,
        routing_v4=RoutingInformation(gateway="10.255.21.65", ip_prefix_length=27),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::4d01", ip_prefix_length=120
        ),
    ),
    ngu=NetworkAddress(
        v4="10.42.140.139",
        v6="2a00:8a00:6000:607c::4e0b",
        vlan_id=927,
        routing_v4=RoutingInformation(gateway="10.42.140.129", ip_prefix_length=27),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::4e01", ip_prefix_length=120
        ),
    ),
    ngc=NetworkAddress(
        v4="10.42.140.171",
        v6="2a00:8a00:6000:607c::4f0b",
        vlan_id=928,
        routing_v4=RoutingInformation(gateway="10.42.140.161", ip_prefix_length=27),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::4f01", ip_prefix_length=120
        ),
    ),
    xnc=NetworkAddress(
        v4="10.255.21.11",
        v6="2a00:8a00:6000:607c::4b0b",
        vlan_id=924,
        routing_v4=RoutingInformation(gateway="10.255.21.1", ip_prefix_length=27),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::4b01", ip_prefix_length=120
        ),
    ),
    xnu=NetworkAddress(
        v4="10.255.21.43",
        v6="2a00:8a00:6000:607c::4c0b",
        vlan_id=925,
        routing_v4=RoutingInformation(gateway="10.255.21.33", ip_prefix_length=27),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::4c01", ip_prefix_length=120
        ),
    ),
)
_pdu_gnb = ATEN(addr="10.44.205.49", port_numbers=[2])
_pdu_ru = Gude(
    addr="10.44.206.182",
    port_numbers=[12],
    model="EPC",
    version="8220-1",
)
_gnb_ru = RU(
    ru_hw_group="AHCA",
    radio_type="AHCA",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_ru.pdu_ports[12],
)

_abil1_gnb_1_master = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    hardware_version="101",
    rus=[_gnb_ru],
)
_asil_gnb_1 = CommonUnit(
    pdu_port=_pdu_gnb.pdu_ports[2],
    hardware_type="ASIL",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_master],
)
_airscale_gnb_1 = Airscale(common_units=[_asil_gnb_1])
_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_abil1_gnb_1_master, label="SFP", port_id=1),
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
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50212, instance_id=50212, dcap=_dcap
)
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
_tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASIM_ABIL_AHCA_SEC_SCAN"
_cu_gnb_1.m = (
    NetworkAddress(
        v4="10.42.249.235",
        v6="2a00:8a00:6000:607c::4a0b",
        vlan_id=923,
        routing_v4=RoutingInformation(gateway="10.42.249.225", ip_prefix_length=27),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::4a01", ip_prefix_length=120
        ),
    ),
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.75", username="ute", password="ute"
    ),
    connections=[
        Connection(interface="eth1", device=_asil_gnb_1, interface_type="lmp"),
    ],
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    core=_core,
    tl_cloud_topology=_tl_cloud_topology,
    test_pcs=[_lmp_vm_gnb_1],
)
