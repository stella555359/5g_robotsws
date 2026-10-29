__maintainer__ = "Magdalena Gerszewska"
__team__ = "TRSSEC"
__email__ = "I_MN_RAN_RD_VRF_WRO3_2@internal.nsn.com"
import os
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.testline import TestLine
from taf.config.testline.enb import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import ATEN, EPC, Gude
from taf.config.testline.radio import RU
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF, RealCore4G
from taf.config.testline.dcap import DcapBasic

__all__ = ["tl"]
cfg_dir = os.path.dirname(os.path.abspath(__file__))

_pdu_enb = Gude(addr="10.44.205.213", port_numbers=[1], model="EPC", version="8221-1")

_pdu_enb_ru_1 = Gude(
    addr="10.44.205.212", port_numbers=[2, 3, 7, 8, 10], model="EPC", version="8221-1"
)
_pdu_enb_ru_2 = Gude(
    addr="10.44.205.211", port_numbers=[2], model="EPC", version="8221-1"
)
_pdu_enb_ru_3 = Gude(
    addr="10.44.205.222", port_numbers=[1], model="EPC", version="8221-1"
)

_enb_ru_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.133", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password=""
    ),
    pdu_port=_pdu_enb_ru_1.pdu_ports[7],
)

_enb_ru_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.134", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password=""
    ),
    pdu_port=_pdu_enb_ru_1.pdu_ports[10],
)

_enb_ru_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password=""
    ),
    pdu_port=_pdu_enb_ru_3.pdu_ports[1],
)

_enb_ru_4 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHHB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.130", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password=""
    ),
    pdu_port=_pdu_enb_ru_1.pdu_ports[8],
)

_enb_ru_5 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHHB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.132", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password=""
    ),
    pdu_port=_pdu_enb_ru_1.pdu_ports[2],
)

_enb_ru_6 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHHB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.131", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password=""
    ),
    pdu_port=_pdu_enb_ru_1.pdu_ports[3],
)

_enb_ru_7 = RU(
    ru_hw_group="FRMr3.1_6T6R",
    radio_type="FRMC",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.8.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password=""
    ),
    pdu_port=_pdu_enb_ru_2.pdu_ports[2],
)


_abia_enb_1_master = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="L1180418002",
    rus=[_enb_ru_1, _enb_ru_2, _enb_ru_3],
)

_abia_enb_2_master = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="L1180417975",
    rus=[_enb_ru_4, _enb_ru_5, _enb_ru_6, _enb_ru_7],
)

_abia_enb_3_master = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="L1180417988",
)


_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_enb_1_master, _abia_enb_2_master, _abia_enb_3_master],
    pdu_port=_pdu_enb.pdu_ports[1],
    hardware_type="ASIA",
    serial_number="L1173810043",
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_abia_enb_1_master, label="OPT", port_id=1),
        target=Endpoint(unit=_enb_ru_1, label="OPT", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_abia_enb_1_master, label="OPT", port_id=2),
        target=Endpoint(unit=_enb_ru_2, label="OPT", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_abia_enb_1_master, label="OPT", port_id=3),
        target=Endpoint(unit=_enb_ru_3, label="OPT", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_abia_enb_2_master, label="OPT", port_id=1),
        target=Endpoint(unit=_enb_ru_4, label="OPT", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_abia_enb_2_master, label="OPT", port_id=2),
        target=Endpoint(unit=_enb_ru_5, label="OPT", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_abia_enb_2_master, label="OPT", port_id=3),
        target=Endpoint(unit=_enb_ru_6, label="OPT", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_abia_enb_2_master, label="OPT", port_id=4),
        target=Endpoint(unit=_enb_ru_7, label="OPT", port_id=1),
    ),
]

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    global_bts_id=40251,
    instance_id=40251,
    x2_link_addr=NetworkAddress(
        v6="2a00:8a00:6000:607c::1:bd30",
        v4="10.44.90.84",
        vlan_id=487,
        routing_v4=RoutingInformation(gateway="10.44.90.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:bd01/120"),
    ),
)
_enb_1.m_plane = NetworkAddress(
    v6="2a00:8a00:6000:607c::1:bc30",
    v4="10.44.90.20",
    vlan_id=486,
    routing_v4=RoutingInformation(gateway="10.44.90.1/26"),
    routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:bc01/120"),
)
_dcap = DcapBasic(
    connection_details=HttpConnectionDetails(
        "10.44.180.7", port=9443, username="dcapuser", password="dcapadmin!"
    )
)

_tl_cloud_topology = "CLOUD_4G_CLASSICAL_ASIA_ABIA_WRO_TRS_343"


_realcore = RealCore4G(mcc="1", mnc="1")

# temp _enb_1.m
_enb_1.m = NetworkAddress(
    v6="2a00:8a00:6000:607c::1:bc30",
    v4="10.44.90.20",
    vlan_id=486,
    routing_v4=RoutingInformation(gateway=" 10.44.90.1/26"),
    routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:bc01/120"),
)
_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.87", username="ute", password="ute"
    ),
    connections=[
        Connection(interface="eth1", device=_asia_enb_1, interface_type="lmp"),
    ],
)

tl = TestLine(
    test_pc=_lmp_vm_enb_1,
    core=_realcore,
    enbs=[_enb_1],
    tl_cloud_topology=_tl_cloud_topology,
    test_pcs=[_lmp_vm_enb_1],
)
