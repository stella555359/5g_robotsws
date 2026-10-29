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

_pdu_enb = Gude(addr="10.44.206.45", port_numbers=[1], model="EPC", version="8220-1")

_pdu_enb_ru_1 = ATEN(addr="10.42.61.105", port_numbers=[4])

_enb_ru_1 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="APHA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.133", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password=""
    ),
    pdu_port=_pdu_enb_ru_1.pdu_ports[4],
)

_abia_enb_1_master = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="L1180418271",
    rus=[_enb_ru_1],
)

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_enb_1_master],
    pdu_port=_pdu_enb.pdu_ports[1],
    hardware_type="ASIA",
    serial_number="EA184074852",
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])


_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_abia_enb_1_master, label="OPT", port_id=1),
        target=Endpoint(unit=_enb_ru_1, label="OPT", port_id=1),
    ),
]

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    global_bts_id=40354,
    instance_id=40354,
    x2_link_addr=NetworkAddress(
        v6="2a00:8a00:6000:607c::4a11",
        v4="10.255.21.17",
        vlan_id=924,
        routing_v4=RoutingInformation(gateway="10.255.21.1/27"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4a01/120"),
    ),
)

_dcap = DcapBasic(
    connection_details=HttpConnectionDetails(
        "10.44.180.7", port=9443, username="dcapuser", password="dcapadmin!"
    )
)

_tl_cloud_topology = "CLOUD_4G_CLASSICAL_ASIA_ABIA_APHA_AHFIH_SEC_SCAN_341"

_realcore = RealCore4G(mcc="1", mnc="1")

_enb_1.m_plane = NetworkAddress(
    v6="2a00:8a00:6000:607c::4a11",
    v4="10.42.249.241",
    vlan_id=923,
    routing_v4=RoutingInformation(gateway="10.42.249.225/27"),
    routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::4a01/120"),
)

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.65", username="ute", password="UTE.debian12"
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
