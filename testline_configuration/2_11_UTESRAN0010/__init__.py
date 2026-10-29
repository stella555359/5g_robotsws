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
    addr="100.68.226.170", model="ENICS", port_numbers=[5]).pdu_ports[5]

_gnb_1_ru_1_pdu_port = ENICS(
    addr="100.68.226.14", model="ENICS", port_numbers=[1]).pdu_ports[1]

_gnb_1_ru_2_pdu_port = ENICS(
    addr="100.68.226.14", model="ENICS", port_numbers=[2]).pdu_ports[2]

_gnb_1_ru_3_pdu_port = ENICS(
    addr="100.68.226.14", model="ENICS", port_numbers=[3]).pdu_ports[3]

_gnb_1_ru_4_pdu_port = ENICS(
    addr="100.68.226.14", model="ENICS", port_numbers=[4]).pdu_ports[4]

_gnb_1_ru_5_pdu_port =ENICS(
    addr="100.68.226.14", model="ENICS", port_numbers=[5]).pdu_ports[5]

_gnb_1_ru_6_pdu_port = ENICS(
    addr="100.68.226.14", model="ENICS", port_numbers=[6]).pdu_ports[6]

_gnb_1_ru_1 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AHLBA",
    serial_number="BL1920F100X",
    pdu_port=_gnb_1_ru_1_pdu_port,
    product_code="474240A.101",
)

_gnb_1_ru_2 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AHLBA",
    serial_number="K9180844525",
    pdu_port=_gnb_1_ru_2_pdu_port,
    product_code="474240A.101",
)

_gnb_1_ru_3 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AHFIC",
    serial_number="DC19330013M",
    pdu_port=_gnb_1_ru_3_pdu_port,
    product_code="474239A.101",
)

_gnb_1_ru_4 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AHFIC",
    serial_number="DC19330015K",
    pdu_port=_gnb_1_ru_4_pdu_port,
    product_code="474239A.101",
)

_gnb_1_ru_5 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AHFIA",
    serial_number="K9193020771",
    pdu_port=_gnb_1_ru_5_pdu_port,
    product_code="473967A.101",
)

_gnb_1_ru_6 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AHFIA",
    serial_number="K9183010653",
    pdu_port=_gnb_1_ru_6_pdu_port,
    product_code="473967A.101",
)

_gnb_1_rms = [
    _gnb_1_ru_1, _gnb_1_ru_2, _gnb_1_ru_3, _gnb_1_ru_4, _gnb_1_ru_5, _gnb_1_ru_6
]

_gnb_1_cap_1 = CapacityUnit(
    hardware_type="ABIL",
    serial_number="L1192713249",
    product_code="474020A.102",
    addr="fsp-1a",
    slot_id=SlotId.B1,
    rus=[_gnb_1_ru_1, _gnb_1_ru_2])

_gnb_1_cap_2 = CapacityUnit(
    hardware_type="ABIL",
    serial_number="L1201405987",
    product_code="474020B.102",
    addr="fsp-2a",
    slot_id=SlotId.B2,
    rus=[_gnb_1_ru_3, _gnb_1_ru_4])

_gnb_1_cap_3 = CapacityUnit(
    hardware_type="ABIL",
    serial_number="L1201406010",
    product_code="474020B.102",
    addr="fsp-2a",
    slot_id=SlotId.B3,
    rus=[_gnb_1_ru_5, _gnb_1_ru_6])

_gnb_1_cap_units = [_gnb_1_cap_1, _gnb_1_cap_2, _gnb_1_cap_3]

_gnb_1_common_units = [
    CommonUnit(
        hardware_type="ASIL",
        serial_number="L1213506811",
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
        addr="100.68.194.252", username="ute", password="ute"),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_gnb_1_common_units[0])
    ])
_gnb_2_common_unit_1_pdu_port = ENICS(
    addr="100.68.226.170", model="ENICS", port_numbers=[6]).pdu_ports[6]

_gnb_2_ru_1_pdu_port = ENICS(
    addr="100.68.226.13", model="ENICS", port_numbers=[4]).pdu_ports[4]

_gnb_2_ru_1 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AEHC",
    serial_number="AH234800072",
    pdu_port=_gnb_2_ru_1_pdu_port,
    product_code="475124B.102",
)

_gnb_2_rms = [_gnb_2_ru_1]

_gnb_2_cap_1 = CapacityUnit(
    hardware_type="ABIO",
    serial_number="DH225050100",
    product_code="475266A.105",
    addr="fsp-1a",
    slot_id=SlotId.B4,
    rus=[_gnb_2_ru_1])

_gnb_2_cap_units = [_gnb_2_cap_1]

_gnb_2_common_units = [
    CommonUnit(
        hardware_type="ASIL",
        serial_number="L1203803773",
        lmp_connection=SshServiceDetails(
            addr="192.168.255.119",
            username="toor4nsn",
            password="oZPS0POrRieRtu"),
        capacity_units=_gnb_2_cap_units,
        pdu_port=_gnb_2_common_unit_1_pdu_port,
        slot_id=SlotId.C2,
        sync_input=None,
        trs_connections=None)
]

_test_vm_gnb_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.194.253", username="ute", password="ute"),
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
                v4="100.68.99.38/27",
                v6="2a00:8a00:4000:4a43::1906/120",
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
                v4="100.68.99.70/27",
                v6="2a00:8a00:4000:4a43::a06/120",
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
                v4="100.68.99.38/27",
                v6="2a00:8a00:4000:4a43::1906/120",
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
                v4="100.68.99.38/27",
                v6="2a00:8a00:4000:4a43::1906/120",
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
                v4="100.68.99.38/27",
                v6="2a00:8a00:4000:4a43::1906/120",
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
                v4="100.68.99.70/27",
                v6="2a00:8a00:4000:4a43::a06/120",
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
                v4="100.68.99.70/27",
                v6="2a00:8a00:4000:4a43::a06/120",
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
                v4="100.68.99.38/27",
                v6="2a00:8a00:4000:4a43::1906/120",
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
                           unit=_gnb_1_cap_1, label="S-RF1", port_id=1),
                       target=Endpoint(
                           unit=_gnb_1_ru_1, label="OPT1", port_id=1)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_1_cap_1, label="S-RF1", port_id=2),
                       target=Endpoint(
                           unit=_gnb_1_ru_2, label="OPT1", port_id=1)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_1_cap_2, label="S-RF1", port_id=1),
                       target=Endpoint(
                           unit=_gnb_1_ru_3, label="OPT1", port_id=1)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_1_cap_2, label="S-RF1", port_id=2),
                       target=Endpoint(
                           unit=_gnb_1_ru_4, label="OPT1", port_id=1)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_1_cap_3, label="S-RF1", port_id=1),
                       target=Endpoint(
                           unit=_gnb_1_ru_5, label="OPT1", port_id=1)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_1_cap_3, label="S-RF1", port_id=2),
                       target=Endpoint(
                           unit=_gnb_1_ru_6, label="OPT1", port_id=1))
               ])
        ],
        instance_id=100804,
        global_bts_id=100804),
    ClassicalBts(
        cu=CU(
            backhaul_site_oam_ip=NetworkAddress(
                v4="100.68.99.39/27",
                v6="2a00:8a00:4000:4a43::1907/120",
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
                v4="100.68.99.71/27",
                v6="2a00:8a00:4000:4a43::a07/120",
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
                v4="100.68.99.39/27",
                v6="2a00:8a00:4000:4a43::1907/120",
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
                v4="100.68.99.39/27",
                v6="2a00:8a00:4000:4a43::1907/120",
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
                v4="100.68.99.39/27",
                v6="2a00:8a00:4000:4a43::1907/120",
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
                v4="100.68.99.71/27",
                v6="2a00:8a00:4000:4a43::a07/120",
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
                v4="100.68.99.71/27",
                v6="2a00:8a00:4000:4a43::a07/120",
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
                v4="100.68.99.39/27",
                v6="2a00:8a00:4000:4a43::1907/120",
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
                common_units=_gnb_2_common_units, product_code="474767A.101"),
               rus=_gnb_2_rms,
               cablinks=[
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_2_cap_1, label="RF1", port_id=1),
                       target=Endpoint(
                           unit=_gnb_2_ru_1, label="OPT1", port_id=1)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_2_cap_1, label="RF7", port_id=7),
                       target=Endpoint(
                           unit=_gnb_2_ru_1, label="OPT4", port_id=4))
               ])
        ],
        instance_id=100805,
        global_bts_id=100805),
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
    test_pcs=[_test_vm_gnb_1, _test_vm_gnb_2],
    velocity=None,
    gnbs=_gnbs,
    enbs=_enbs,
    core=_core)

__all__ = ["tl"]

sync = None
