__maintainer__ = "DTL Oulu"
__team__ = "MN SRAN Trunk Eng OUL 2 SG"
__email__ = "I_MBB_GLOBAL_LTE_ENODEB_IV_OULU_UTE@internal.nsn.com"

from taf.config.testline import Connection, TestPc, TestLine
from taf.config.testline.enb import RealEnb
from taf.config.testline.airscale import CapacityUnit, CommonUnit, CoreUnit, Airscale, SlotId, TRSInterfaces
from taf.config.testline.connection_details import SshServiceDetails, HttpConnectionDetails
from taf.config.testline.pdu import ENICS
from taf.config.testline.gnb.networkaddress import NetworkAddress, RoutingInformation
from taf.config.testline.lab_infrastructure import Velocity
from taf.config.testline.sync_input import ToPServer
from taf.config.testline.radio import RU
from taf.config.testline.ald import ALDEmulator
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.core import RealCore, RealCore4GDetails, MME, RealCore5GDetails, AMF
from taf.config.testline.flexi import Flexi

_gnb_1_common_unit_1_pdu_port = ENICS(
    addr="100.68.226.172", model="ENICS", port_numbers=[10]).pdu_ports[10]

_gnb_1_ru_1_pdu_port = ENICS(
    addr="100.68.226.113", port_numbers=[6]).pdu_ports[6]

_gnb_1_ru_1 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AWHQN",
    serial_number="EB2244R1928",
    pdu_port=_gnb_1_ru_1_pdu_port)

_gnb_1_rms = [_gnb_1_ru_1]

_gnb_1_cap_1 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIP",
    serial_number="L1240602935",
    product_code="475792A.102",
    slot_id=SlotId.B4,
    rus=[_gnb_1_ru_1])

_gnb_1_cap_units = [_gnb_1_cap_1]

_gnb_1_common_units = [
    CommonUnit(
        lmp_connection=SshServiceDetails(
            addr="192.168.255.129",
            username="toor4nsn",
            password="oZPS0POrRieRtu"),
        pdu_port=_gnb_1_common_unit_1_pdu_port,
        capacity_units=_gnb_1_cap_units,
        hardware_type="ASIM",
        serial_number="L1233302566",
        slot_id=SlotId.C2)
]

_test_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.193.18", username="ute", password="ute"),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_gnb_1_common_units[0])
    ])

_gnbs = [
    ClassicalBts(
        cu=CU(
            backhaul_site_oam_ip=NetworkAddress(
                v4="100.68.99.171/27",
                v6="2a00:8a00:4000:4a43::1d0b/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.99.161"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1d01")),
            oam_ssh_connection_details=SshServiceDetails(
                addr="192.168.255.129",
                username="toor4nsn",
                password="oZPS0POrRieRtu"),
            oam_http_connection_details=HttpConnectionDetails(
                addr="192.168.255.129",
                username="Nemuadmin",
                password="nemuuser",
                port=443),
            x2c=NetworkAddress(
                v4="100.68.99.203/27",
                v6="2a00:8a00:4000:4a43::1e0b/120",
                vlan_id=22,
                routing_v4=RoutingInformation(gateway="100.68.99.193"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1e01")),
            x2u=NetworkAddress(
                v4="100.68.99.171/27",
                v6="2a00:8a00:4000:4a43::1d0b/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.99.161"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1d01")),
            s1u=NetworkAddress(
                v4="100.68.99.171/27",
                v6="2a00:8a00:4000:4a43::1d0b/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.99.161"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1d01")),
            ngu=NetworkAddress(
                v4="100.68.99.171/27",
                v6="2a00:8a00:4000:4a43::1d0b/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.99.161"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1d01")),
            ngc=NetworkAddress(
                v4="100.68.99.203/27",
                v6="2a00:8a00:4000:4a43::1e0b/120",
                vlan_id=22,
                routing_v4=RoutingInformation(gateway="100.68.99.193"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1e01")),
            xnc=NetworkAddress(
                v4="100.68.99.203/27",
                v6="2a00:8a00:4000:4a43::1e0b/120",
                vlan_id=22,
                routing_v4=RoutingInformation(gateway="100.68.99.193"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1e01")),
            xnu=NetworkAddress(
                v4="100.68.99.171/27",
                v6="2a00:8a00:4000:4a43::1d0b/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.99.161"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1d01")),
        ),
        dus=[
            DU(airscale=Airscale(
                common_units=_gnb_1_common_units, product_code="475765A.104"),
               rus=_gnb_1_rms,
               cablinks=[
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_1_cap_1, label="SFP", port_id=1),
                       target=Endpoint(
                           unit=_gnb_1_ru_1, label="SFP", port_id=1)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_1_cap_1, label="SFP", port_id=2),
                       target=Endpoint(
                           unit=_gnb_1_ru_1, label="SFP", port_id=2))
               ])
        ],
        instance_id=101509,
        global_bts_id=101509),
]

_enbs = []

_core = RealCore(
    mcc="244",
    mnc="9",
    four_g=None,
    five_g=RealCore5GDetails(
        amf=AMF(
            oam_ssh_connection_details=None,
            n2=NetworkAddress(
                v4="10.35.18.70", v6="2a00:8a00:4000:4a22::2:1146")),
        tac=7926),
)
tl = TestLine(
    test_pc=_test_vm_gnb_1,
    test_pcs=[_test_vm_gnb_1],
    velocity=None,
    gnbs=_gnbs,
    enbs=_enbs,
    core=_core)

__all__ = ["tl"]

sync = None
