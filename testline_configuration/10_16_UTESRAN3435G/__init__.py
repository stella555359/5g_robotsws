__maintainer__ = "Maciej Musial"
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
        v4="10.44.88.149",
        v6="2a00:8a00:6000:607c::1:b63d",
        vlan_id=480,
        routing_v4=RoutingInformation(gateway="10.44.88.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b601/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.88.213",
        v6="2a00:8a00:6000:607c::1:b73d",
        vlan_id=481,
        routing_v4=RoutingInformation(gateway="10.44.88.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b701/120"),
    ),
    x2u=NetworkAddress(
        v4="10.44.89.23",
        v6="2a00:8a00:6000:607c::1:b841",
        vlan_id=482,
        routing_v4=RoutingInformation(gateway="10.44.89.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b801/120"),
    ),
    s1u=NetworkAddress(
        v4="10.44.89.90",
        v6="2a00:8a00:6000:607c::1:b944",
        vlan_id=483,
        routing_v4=RoutingInformation(gateway="10.44.89.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b901/120"),
    ),
    ngu=NetworkAddress(
        v4="10.44.89.90",
        v6="2a00:8a00:6000:607c::1:b944",
        vlan_id=483,
        routing_v4=RoutingInformation(gateway="10.44.89.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b901/120"),
    ),
    ngc=NetworkAddress(
        v4="10.44.89.212",
        v6="2a00:8a00:6000:607c::1:ba3f",
        vlan_id=484,
        routing_v4=RoutingInformation(gateway="10.44.89.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:ba01/120"),
    ),
    xnc=NetworkAddress(
        v4="10.44.88.213",
        v6="2a00:8a00:6000:607c::1:b73d",
        vlan_id=481,
        routing_v4=RoutingInformation(gateway="10.44.88.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b701/120"),
    ),
    xnu=NetworkAddress(
        v4="10.44.89.23",
        v6="2a00:8a00:6000:607c::1:b841	",
        vlan_id=482,
        routing_v4=RoutingInformation(gateway="10.44.89.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b801/120"),
    ),
)
_pdu_gnb = Gude(addr="10.44.205.213", port_numbers=[1], model="EPC", version="8221-1")

_pdu_gnb_ru_1 = Gude(
    addr="10.44.205.212", port_numbers=[4, 5, 6, 7, 10], model="EPC", version="8221-1"
)
_pdu_gnb_ru_2 = Gude(
    addr="10.44.205.211", port_numbers=[1], model="EPC", version="8221-1"
)

_gnb_ru_1 = RU(
    ru_hw_group="cMAAr6.1_64T64R",
    radio_type="AEQE",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.57.162",
        username="rfsw",
        password="gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY=",
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1",
        username="rfsw",
        password="gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY=",
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[4],
)

_gnb_ru_2 = RU(
    ru_hw_group="cMAAr6.1_64T64R",
    radio_type="AEQE",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.57.166",
        username="rfsw",
        password="gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY=",
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1",
        username="rfsw",
        password="gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY=",
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[5],
)

_gnb_ru_3 = RU(
    ru_hw_group="cMAAr6.1_64T64R",
    radio_type="AEQE",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.58.162",
        username="rfsw",
        password="gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY=",
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1",
        username="rfsw",
        password="gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY=",
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[6],
)

_gnb_ru_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.77.130", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password=""
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[7],
)

_gnb_ru_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.77.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password=""
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[10],
)

_gnb_ru_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.77.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password=""
    ),
    pdu_port=_pdu_gnb_ru_2.pdu_ports[1],
)


_abil_gnb_1_master = CapacityUnit(
    addr="192.168.253.20", hardware_type="ABIL", serial_number="L1203900882"
)


_abil_gnb_2_master = CapacityUnit(
    addr="192.168.253.20", hardware_type="ABIL", serial_number="L1203900874"
)

_abil_gnb_3_master = CapacityUnit(
    addr="192.168.253.20", hardware_type="ABIL", serial_number="L1203900890"
)

_asib_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_gnb_1_master, _abil_gnb_2_master, _abil_gnb_3_master],
    pdu_port=_pdu_gnb.pdu_ports[1],
    hardware_type="ASIB",
    serial_number="L1192100825",
)


_airscale_gnb_1 = Airscale(common_units=[_asib_gnb_1])


_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_abil_gnb_2_master, label="SFP", port_id=2),
        target=Endpoint(unit=_gnb_ru_2, label="SFP", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_abil_gnb_3_master, label="SFP", port_id=1),
        target=Endpoint(unit=_gnb_ru_3, label="SFP", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_abil_gnb_2_master, label="SFP", port_id=1),
        target=Endpoint(unit=_gnb_ru_1, label="SFP", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_abil_gnb_1_master, label="SFP", port_id=1),
        target=Endpoint(unit=_gnb_ru_4, label="SFP", port_id=2),
    ),
    Cablink(
        source=Endpoint(unit=_abil_gnb_1_master, label="SFP", port_id=2),
        target=Endpoint(unit=_gnb_ru_5, label="SFP", port_id=2),
    ),
    Cablink(
        source=Endpoint(unit=_abil_gnb_1_master, label="QSFP", port_id=2),
        target=Endpoint(unit=_gnb_ru_6, label="SFP", port_id=2),
    ),
]

_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1,
    rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3, _gnb_ru_4, _gnb_ru_5, _gnb_ru_6],
    cablinks=_ru_cablinks,
)


_dcap = DcapBasic(
    connection_details=HttpConnectionDetails(
        "10.44.180.7", port=9443, username="dcapuser", password="dcapadmin!"
    )
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=51060, instance_id=51060, dcap=_dcap
)

_tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASIB_ABIL_WRO_TRS_343"
_amf_ssh = SshServiceDetails(
    addr="to_be_updated", username="to_be_updated", password="to_be_updated"
)
_amf_n2_addr = NetworkAddress(
    v4="10.27.28.136", v6="2a00:8a00:4000:65ef:ffff:ffff:ffff:b804", vlan_id=None
)
_amf = AMF(oam_ssh_connection_details=_amf_ssh, n2=_amf_n2_addr)
_core = RealCore(five_g=RealCore5GDetails(amf=_amf, tac=7150), mcc=1, mnc=1)
# temp _cu_gnb_1.m
_cu_gnb_1.m = (
    NetworkAddress(
        v4="10.44.88.149",
        v6="2a00:8a00:6000:607c::1:b63d",
        vlan_id=480,
        routing_v4=RoutingInformation(gateway="10.44.88.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b601/120"),
    ),
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.88", username="ute", password="ute"
    ),
    connections=[
        Connection(interface="eth1", device=_asib_gnb_1, interface_type="lmp"),
    ],
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    core=_core,
    tl_cloud_topology=_tl_cloud_topology,
    test_pcs=[_lmp_vm_gnb_1],
)
