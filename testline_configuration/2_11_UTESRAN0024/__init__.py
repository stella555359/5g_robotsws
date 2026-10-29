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
    addr="100.68.226.168", model="ENICS", port_numbers=[1]).pdu_ports[1]

_gnb_1_ru_1_pdu_port = ENICS(
    addr="100.68.226.23", model="ENICS", port_numbers=[1, 2, 3, 4, 5,
                                                       6]).pdu_ports[3]
_gnb_1_ru_2_pdu_port = ENICS(
    addr="100.68.226.23", model="ENICS", port_numbers=[1, 2, 3, 4, 5,
                                                       6]).pdu_ports[4]
_gnb_1_ru_3_pdu_port = ENICS(
    addr="100.68.226.23", model="ENICS", port_numbers=[1, 2, 3, 4, 5,
                                                       6]).pdu_ports[1]
_gnb_1_ru_4_pdu_port = ENICS(
    addr="100.68.226.23", model="ENICS", port_numbers=[1, 2, 3, 4, 5,
                                                       6]).pdu_ports[2]
_gnb_1_ru_5_pdu_port = ENICS(
    addr="100.68.226.23", model="ENICS", port_numbers=[1, 2, 3, 4, 5,
                                                       6]).pdu_ports[5]
_gnb_1_ru_6_pdu_port = ENICS(
    addr="100.68.226.23", model="ENICS", port_numbers=[1, 2, 3, 4, 5,
                                                       6]).pdu_ports[6]

_gnb_1_ru_1 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AHLBA",
    serial_number="BL2031F1KLO",
    pdu_port=_gnb_1_ru_1_pdu_port,
    product_code="474240A.101")

_gnb_1_ru_2 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AHLBA",
    serial_number="K9182614356",
    pdu_port=_gnb_1_ru_2_pdu_port,
    product_code="474240A.101")

_gnb_1_ru_3 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AHFIC",
    serial_number="K9182045294",
    pdu_port=_gnb_1_ru_3_pdu_port,
    product_code="474239A.101")

_gnb_1_ru_4 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AHFIC",
    serial_number="K9182045348",
    pdu_port=_gnb_1_ru_4_pdu_port,
    product_code="474239A.101")

_gnb_1_ru_5 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AHFIA",
    serial_number="K9183020507",
    pdu_port=_gnb_1_ru_5_pdu_port,
    product_code="473967A.101")

_gnb_1_ru_6 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AHFIA",
    serial_number="K9183020509",
    pdu_port=_gnb_1_ru_6_pdu_port,
    product_code="473967A.101")

_gnb_1_rms = [
    _gnb_1_ru_1, _gnb_1_ru_2, _gnb_1_ru_3, _gnb_1_ru_4, _gnb_1_ru_5, _gnb_1_ru_6
]

_gnb_1_cap_1 = CapacityUnit(
    addr="fsp-1a", hardware_type="ABIL", rus=[_gnb_1_ru_1, _gnb_1_ru_2], serial_number="DH201062204", slot_id=SlotId.B1)

_gnb_1_cap_2 = CapacityUnit(
    addr="fsp-2a", hardware_type="ABIL", rus=[_gnb_1_ru_3, _gnb_1_ru_4], serial_number="L1201405997", slot_id=SlotId.B2)

_gnb_1_cap_3 = CapacityUnit(
    addr="fsp-2a", hardware_type="ABIL", rus=[_gnb_1_ru_5, _gnb_1_ru_6], serial_number="L1192713257", slot_id=SlotId.B3)

_gnb_1_cap_units = [_gnb_1_cap_1, _gnb_1_cap_2, _gnb_1_cap_3]

_gnb_1_common_units = [
    CommonUnit(
        lmp_connection=SshServiceDetails(
            addr="192.168.255.129",
            username="toor4nsn",
            password="oZPS0POrRieRtu"),
        pdu_port=_gnb_1_common_unit_1_pdu_port,
        capacity_units=_gnb_1_cap_units,
        hardware_type="ASIL",
        serial_number="L1235102252",
        slot_id=SlotId.C1)
]

_test_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.194.116", username="ute", password="ute"),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_gnb_1_common_units[0])
    ])
_gnb_2_common_unit_1_pdu_port = ENICS(
    addr="100.68.226.168", model="ENICS", port_numbers=[2]).pdu_ports[2]

_gnb_2_ru_1_pdu_port = ENICS(
    addr="100.68.226.13", model="ENICS", port_numbers=[7]).pdu_ports[7]

_gnb_2_ru_1 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AEHC",
    serial_number="AH231900699",
    pdu_port=_gnb_2_ru_1_pdu_port,
    product_code="475124B.101")

_gnb_2_rms = [_gnb_2_ru_1]

_gnb_2_cap_1 = CapacityUnit(
    addr="fsp-1a", hardware_type="ABIO", rus=[_gnb_2_ru_1], serial_number="DH225049812", slot_id=SlotId.B4)

_gnb_2_cap_units = [_gnb_2_cap_1]

_gnb_2_common_units = [
    CommonUnit(
        lmp_connection=SshServiceDetails(
            addr="192.168.255.119",
            username="toor4nsn",
            password="oZPS0POrRieRtu"),
        pdu_port=_gnb_2_common_unit_1_pdu_port,
        capacity_units=_gnb_2_cap_units,
        hardware_type="ASIL",
        serial_number="L1233608845",
        slot_id=SlotId.C2)
]

_test_vm_gnb_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.194.117", username="ute", password="ute"),
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
                v4="100.68.98.162/27",
                v6="2a00:8a00:4000:4a43::1502/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.98.161"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1501")),
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
                v4="100.68.98.194/27",
                v6="2a00:8a00:4000:4a43::1602/120",
                vlan_id=22,
                routing_v4=RoutingInformation(gateway="100.68.98.193"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1601")),
            x2u=NetworkAddress(
                v4="100.68.98.162/27",
                v6="2a00:8a00:4000:4a43::1502/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.98.161"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1501")),
            s1u=NetworkAddress(
                v4="100.68.98.162/27",
                v6="2a00:8a00:4000:4a43::1502/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.98.161"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1501")),
            ngu=NetworkAddress(
                v4="100.68.98.162/27",
                v6="2a00:8a00:4000:4a43::1502/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.98.161"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1501")),
            ngc=NetworkAddress(
                v4="100.68.98.194/27",
                v6="2a00:8a00:4000:4a43::1602/120",
                vlan_id=22,
                routing_v4=RoutingInformation(gateway="100.68.98.193"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1601")),
            xnc=NetworkAddress(
                v4="100.68.98.194/27",
                v6="2a00:8a00:4000:4a43::1602/120",
                vlan_id=22,
                routing_v4=RoutingInformation(gateway="100.68.98.193"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1601")),
            xnu=NetworkAddress(
                v4="100.68.98.162/27",
                v6="2a00:8a00:4000:4a43::1502/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.98.161"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1501")),
        ),
        dus=[
            DU(airscale=Airscale(common_units=_gnb_1_common_units),
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
                           unit=_gnb_1_ru_2, label="SFP", port_id=1)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_1_cap_2, label="SFP", port_id=1),
                       target=Endpoint(
                           unit=_gnb_1_ru_3, label="SFP", port_id=1)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_1_cap_2, label="SFP", port_id=2),
                       target=Endpoint(
                           unit=_gnb_1_ru_4, label="SFP", port_id=1)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_1_cap_3, label="SFP", port_id=1),
                       target=Endpoint(
                           unit=_gnb_1_ru_5, label="SFP", port_id=1)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_1_cap_3, label="SFP", port_id=2),
                       target=Endpoint(
                           unit=_gnb_1_ru_6, label="SFP", port_id=1))
               ])
        ],
        instance_id=101600,
        global_bts_id=101600),
    ClassicalBts(
        cu=CU(
            backhaul_site_oam_ip=NetworkAddress(
                v4="100.68.98.163/27",
                v6="2a00:8a00:4000:4a43::1503/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.98.161"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1501")),
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
                v4="100.68.98.195/27",
                v6="2a00:8a00:4000:4a43::1603/120",
                vlan_id=22,
                routing_v4=RoutingInformation(gateway="100.68.98.193"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1601")),
            x2u=NetworkAddress(
                v4="100.68.98.163/27",
                v6="2a00:8a00:4000:4a43::1503/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.98.161"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1501")),
            s1u=NetworkAddress(
                v4="100.68.98.163/27",
                v6="2a00:8a00:4000:4a43::1503/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.98.161"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1501")),
            ngu=NetworkAddress(
                v4="100.68.98.163/27",
                v6="2a00:8a00:4000:4a43::1503/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.98.161"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1501")),
            ngc=NetworkAddress(
                v4="100.68.98.195/27",
                v6="2a00:8a00:4000:4a43::1603/120",
                vlan_id=22,
                routing_v4=RoutingInformation(gateway="100.68.98.193"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1601")),
            xnc=NetworkAddress(
                v4="100.68.98.195/27",
                v6="2a00:8a00:4000:4a43::1603/120",
                vlan_id=22,
                routing_v4=RoutingInformation(gateway="100.68.98.193"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1601")),
            xnu=NetworkAddress(
                v4="100.68.98.163/27",
                v6="2a00:8a00:4000:4a43::1503/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.98.161"),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1501")),
        ),
        dus=[
            DU(airscale=Airscale(common_units=_gnb_2_common_units),
               rus=_gnb_2_rms,
               cablinks=[
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_2_cap_1, label="SFP", port_id=1),
                       target=Endpoint(
                           unit=_gnb_2_ru_1, label="SFP", port_id=1)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_2_cap_1, label="SFP", port_id=7),
                       target=Endpoint(
                           unit=_gnb_2_ru_1, label="SFP", port_id=4))
               ])
        ],
        instance_id=101601,
        global_bts_id=101601),
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
                v4="10.35.22.232", v6="2a00:8a00:4000:4a22::2:1308")),
        tac=7000),
)
tl = TestLine(
    test_pc=_test_vm_gnb_1,
    test_pcs=[_test_vm_gnb_1, _test_vm_gnb_2],
    velocity=None,
    gnbs=_gnbs,
    enbs=_enbs,
    core=_core)

__all__ = ["tl"]

sync = None
