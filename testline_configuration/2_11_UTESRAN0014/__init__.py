__maintainer__ = "DTL Oulu"
__team__ = "MN SRAN Trunk Eng OUL 2 SG"
__email__ = "I_MBB_GLOBAL_LTE_ENODEB_IV_OULU_UTE@internal.nsn.com"

from taf.config.testline import Connection, TestPc, TestLine
from taf.config.testline.enb import RealEnb
from taf.config.testline.airscale import CapacityUnit, CommonUnit, CoreUnit, Airscale, SlotId, TRSInterfaces
from taf.config.testline.connection_details import SshServiceDetails, HttpConnectionDetails
from taf.config.testline.pdu import ENICS, DELTA
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
    addr="100.68.226.171", model="ENICS", port_numbers=[1]).pdu_ports[1]

_gnb_1_ru_1_pdu_port = ENICS(
    addr="100.68.226.11", model="ENICS", port_numbers=[11]).pdu_ports[11]

_gnb_1_ru_2_pdu_port = ENICS(
    addr="100.68.226.33", model="ENICS", port_numbers=[4]).pdu_ports[4]

_gnb_1_ru_3_pdu_port = ENICS(
    addr="100.68.226.13", model="ENICS", port_numbers=[6]).pdu_ports[6]

_gnb_1_ru_1 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AHFIB",
    serial_number="BL2044V0RJY",
    pdu_port=_gnb_1_ru_1_pdu_port,
    product_code="474216A.101",
)

_gnb_1_ru_2 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AHLOA",
    serial_number="BL2145G1Q72",
    pdu_port=_gnb_1_ru_2_pdu_port,
    product_code="474331A.101",
)

_gnb_1_ru_3 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AEHC",
    serial_number="K9222600552",
    pdu_port=_gnb_1_ru_3_pdu_port,
    product_code="475124B.101",
)

_gnb_1_rms = [_gnb_1_ru_1, _gnb_1_ru_2, _gnb_1_ru_3]

_gnb_1_cap_1 = CapacityUnit(
    hardware_type="ABIO",
    serial_number="L1240803996",
    product_code="475266A.107",
    addr="fsp-1a",
    slot_id=SlotId.B1,
    rus=[_gnb_1_ru_1, _gnb_1_ru_2])

_gnb_1_cap_2 = CapacityUnit(
    hardware_type="ABIO",
    serial_number="DH222851232",
    product_code="475266A.104",
    addr="fsp-2a",
    slot_id=SlotId.B2,
    rus=[_gnb_1_ru_3])

_gnb_1_cap_units = [_gnb_1_cap_1, _gnb_1_cap_2]

_gnb_1_common_units = [
    CommonUnit(
        hardware_type="ASIL",
        serial_number="L1213507504",
        lmp_connection=SshServiceDetails(
            addr="192.168.255.129",
            username="toor4nsn",
            password="oZPS0POrRieRtu"),
        capacity_units=_gnb_1_cap_units,
        pdu_port=_gnb_1_common_unit_1_pdu_port,
        slot_id=SlotId.C1,
        sync_input=None,
        trs_connections=None)
]

_test_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.195.55", username="ute", password="ute"),
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
                v4="100.68.99.46/27",
                v6="2a00:8a00:4000:4a43::190e/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.99.33",
                    ip_prefix_length=None,
                    destIpAddr=None),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1901",
                    ip_prefix_length=None,
                    destIpAddr=None)),
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
                v4="100.68.99.78/27",
                v6="2a00:8a00:4000:4a43::a0e/120",
                vlan_id=22,
                routing_v4=RoutingInformation(
                    gateway="100.68.99.65",
                    ip_prefix_length=None,
                    destIpAddr=None),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::a01",
                    ip_prefix_length=None,
                    destIpAddr=None)),
            x2u=NetworkAddress(
                v4="100.68.99.46/27",
                v6="2a00:8a00:4000:4a43::190e/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.99.33",
                    ip_prefix_length=None,
                    destIpAddr=None),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1901",
                    ip_prefix_length=None,
                    destIpAddr=None)),
            s1u=NetworkAddress(
                v4="100.68.99.46/27",
                v6="2a00:8a00:4000:4a43::190e/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.99.33",
                    ip_prefix_length=None,
                    destIpAddr=None),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1901",
                    ip_prefix_length=None,
                    destIpAddr=None)),
            ngu=NetworkAddress(
                v4="100.68.99.46/27",
                v6="2a00:8a00:4000:4a43::190e/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.99.33",
                    ip_prefix_length=None,
                    destIpAddr=None),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1901",
                    ip_prefix_length=None,
                    destIpAddr=None)),
            ngc=NetworkAddress(
                v4="100.68.99.78/27",
                v6="2a00:8a00:4000:4a43::a0e/120",
                vlan_id=22,
                routing_v4=RoutingInformation(
                    gateway="100.68.99.65",
                    ip_prefix_length=None,
                    destIpAddr=None),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::a01",
                    ip_prefix_length=None,
                    destIpAddr=None)),
            xnc=NetworkAddress(
                v4="100.68.99.78/27",
                v6="2a00:8a00:4000:4a43::a0e/120",
                vlan_id=22,
                routing_v4=RoutingInformation(
                    gateway="100.68.99.65",
                    ip_prefix_length=None,
                    destIpAddr=None),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::a01",
                    ip_prefix_length=None,
                    destIpAddr=None)),
            xnu=NetworkAddress(
                v4="100.68.99.46/27",
                v6="2a00:8a00:4000:4a43::190e/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.99.33",
                    ip_prefix_length=None,
                    destIpAddr=None),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1901",
                    ip_prefix_length=None,
                    destIpAddr=None)),
        ),
        dus=[
            DU(airscale=Airscale(
                common_units=_gnb_1_common_units, product_code="474767A.102"),
               rus=_gnb_1_rms,
               cablinks=[
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_1_cap_1, label="SFP", port_id=1),
                       target=Endpoint(
                           unit=_gnb_1_ru_1, label="SFP", port_id=2)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_1_cap_1, label="SFP", port_id=7),
                       target=Endpoint(
                           unit=_gnb_1_ru_2, label="SFP", port_id=2)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_1_cap_2, label="SFP", port_id=1),
                       target=Endpoint(
                           unit=_gnb_1_ru_3, label="SFP", port_id=1)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_1_cap_2, label="SFP", port_id=7),
                       target=Endpoint(
                           unit=_gnb_1_ru_3, label="SFP", port_id=2))
               ])
        ],
        instance_id=100812,
        global_bts_id=100812),
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
                v4="10.35.18.70",
                v6="2a00:8a00:4000:4a22::2:1146",
                vlan_id=None,
                routing_v4=None,
                routing_v6=None)),
        tac=8000),
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
