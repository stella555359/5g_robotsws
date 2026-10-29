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

_velocity = Velocity(
    addr=NetworkAddress(v4="velocity.linnanmaa.dyn.nesc.nokia.net", v6="None"))

_gnb_1_common_unit_1_pdu_port = ENICS(
    addr="100.68.226.145", model="ENICS", port_numbers=[11]).pdu_ports[11]

_gnb_1_rms = []

_gnb_1_cap_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    serial_number="L1240602974",
    product_code="475792A.102",
    slot_id=SlotId.B1)

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
        serial_number="L1233304558",
        slot_id=SlotId.C1,
        trs_connections=TRSInterfaces.EIF3)
]

_test_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.193.177", username="ute", password="None"),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_gnb_1_common_units[0])
    ])
_gnb_2_common_unit_1_pdu_port = ENICS(
    addr="100.68.226.145", model="ENICS", port_numbers=[12]).pdu_ports[12]

_gnb_2_rms = []

_gnb_2_cap_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    serial_number="L1240602942",
    product_code="475792A.102",
    slot_id=SlotId.B4)

_gnb_2_cap_units = [_gnb_2_cap_1]

_gnb_2_common_units = [
    CommonUnit(
        lmp_connection=SshServiceDetails(
            addr="192.168.255.119",
            username="toor4nsn",
            password="oZPS0POrRieRtu"),
        pdu_port=_gnb_2_common_unit_1_pdu_port,
        capacity_units=_gnb_2_cap_units,
        hardware_type="ASIM",
        serial_number="L1233304602",
        slot_id=SlotId.C2,
        trs_connections=TRSInterfaces.EIF3)
]

_test_vm_gnb_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.193.179", username="ute", password="None"),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_gnb_2_common_units[0])
    ])

_gnbs = [
    ClassicalBts(
        cu=CU(
            backhaul_site_oam_ip=NetworkAddress(
                v4="100.68.101.56/27",
                v6="2a00:8a00:4000:4a43::2918/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.101.33"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::2901")),
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
                v4="100.68.101.88/27",
                v6="2a00:8a00:4000:4a43::2a18/120",
                vlan_id=22,
                routing_v4=RoutingInformation(gateway="100.68.101.65"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::2a01")),
            x2u=NetworkAddress(
                v4="100.68.101.56/27",
                v6="2a00:8a00:4000:4a43::2918/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.101.33"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::2901")),
            s1u=NetworkAddress(
                v4="100.68.101.56/27",
                v6="2a00:8a00:4000:4a43::2918/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.101.33"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::2901")),
            ngu=NetworkAddress(
                v4="100.68.101.56/27",
                v6="2a00:8a00:4000:4a43::2918/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.101.33"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::2901")),
            ngc=NetworkAddress(
                v4="100.68.101.88/27",
                v6="2a00:8a00:4000:4a43::2a18/120",
                vlan_id=22,
                routing_v4=RoutingInformation(gateway="100.68.101.65"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::2a01")),
            xnc=NetworkAddress(
                v4="100.68.101.88/27",
                v6="2a00:8a00:4000:4a43::2a18/120",
                vlan_id=22,
                routing_v4=RoutingInformation(gateway="100.68.101.65"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::2a01")),
            xnu=NetworkAddress(
                v4="100.68.101.56/27",
                v6="2a00:8a00:4000:4a43::2918/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.101.33"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::2901")),
        ),
        dus=[
            DU(airscale=Airscale(
                common_units=_gnb_1_common_units, product_code="475765A.104"),
               rus=_gnb_1_rms,
               cablinks=[])
        ],
        instance_id=102122,
        global_bts_id=102122),
    ClassicalBts(
        cu=CU(
            backhaul_site_oam_ip=NetworkAddress(
                v4="100.68.101.57/27",
                v6="2a00:8a00:4000:4a43::2919/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.101.33"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::2901")),
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
                v4="100.68.101.89/27",
                v6="2a00:8a00:4000:4a43::2a19/120",
                vlan_id=22,
                routing_v4=RoutingInformation(gateway="100.68.101.65"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::2a01")),
            x2u=NetworkAddress(
                v4="100.68.101.57/27",
                v6="2a00:8a00:4000:4a43::2919/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.101.33"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::2901")),
            s1u=NetworkAddress(
                v4="100.68.101.57/27",
                v6="2a00:8a00:4000:4a43::2919/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.101.33"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::2901")),
            ngu=NetworkAddress(
                v4="100.68.101.57/27",
                v6="2a00:8a00:4000:4a43::2919/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.101.33"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::2901")),
            ngc=NetworkAddress(
                v4="100.68.101.89/27",
                v6="2a00:8a00:4000:4a43::2a19/120",
                vlan_id=22,
                routing_v4=RoutingInformation(gateway="100.68.101.65"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::2a01")),
            xnc=NetworkAddress(
                v4="100.68.101.89/27",
                v6="2a00:8a00:4000:4a43::2a19/120",
                vlan_id=22,
                routing_v4=RoutingInformation(gateway="100.68.101.65"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::2a01")),
            xnu=NetworkAddress(
                v4="100.68.101.57/27",
                v6="2a00:8a00:4000:4a43::2919/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.101.33"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::2901")),
        ),
        dus=[
            DU(airscale=Airscale(
                common_units=_gnb_2_common_units, product_code="475765A.104"),
               rus=_gnb_2_rms,
               cablinks=[])
        ],
        instance_id=102123,
        global_bts_id=102123),
]

_enbs = []

_core = RealCore(
    mcc="244",
    mnc="09",
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
    test_pcs=[_test_vm_gnb_1, _test_vm_gnb_2],
    velocity=_velocity,
    gnbs=_gnbs,
    enbs=_enbs,
    core=_core)

__all__ = ["tl"]

sync = None
