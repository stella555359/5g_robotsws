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
    addr="100.68.226.170", model="ENICS", port_numbers=[1]).pdu_ports[1]

_gnb_1_ru_1_shared_pdu_port = ENICS(
    addr="100.68.226.12", model="ENICS", port_numbers=[4]).pdu_ports[4]

_gnb_1_ru_2_shared_pdu_port = ENICS(
    addr="100.68.226.12", model="ENICS", port_numbers=[3]).pdu_ports[3]

_gnb_1_ru_4_shared_pdu_port = ENICS(
    addr="100.68.226.12", model="ENICS", port_numbers=[1]).pdu_ports[1]

_gnb_1_ru_5_shared_pdu_port = ENICS(
    addr="100.68.226.11", model="ENICS", port_numbers=[9]).pdu_ports[9]

_gnb_1_ru_7_shared_pdu_port = ENICS(
    addr="100.68.226.11", model="ENICS", port_numbers=[7]).pdu_ports[7]

_gnb_1_ru_8_shared_pdu_port = ENICS(
    addr="100.68.226.11", model="ENICS", port_numbers=[8]).pdu_ports[8]

_gnb_1_ru_1_shared = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHLOA",
    serial_number="BL2051G1TP1",
    pdu_port=_gnb_1_ru_1_shared_pdu_port,
    product_code="474331A.101",
)

_gnb_1_ru_2_shared = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHLOA",
    serial_number="BL2051G1TON",
    pdu_port=_gnb_1_ru_2_shared_pdu_port,
    product_code="474331A.101",
)
_gnb_1_ru_4_shared = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHLOA",
    serial_number="BL2051G1TP4",
    pdu_port=_gnb_1_ru_4_shared_pdu_port,
    product_code="474331A.101",
)

_gnb_1_ru_5_shared = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHFIB",
    serial_number="BL2238V09HN",
    pdu_port=_gnb_1_ru_5_shared_pdu_port,
    product_code="474216A.101",
)

_gnb_1_ru_7_shared = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHFIB",
    serial_number="BL2238V09RT",
    pdu_port=_gnb_1_ru_7_shared_pdu_port,
    product_code="474216A.101",
)

_gnb_1_ru_8_shared = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHFIB",
    serial_number="BL2238V09FZ",
    pdu_port=_gnb_1_ru_8_shared_pdu_port,
    product_code="474216A.101",
)

_gnb_1_rms = [
    _gnb_1_ru_1_shared, _gnb_1_ru_2_shared,
    _gnb_1_ru_4_shared, _gnb_1_ru_5_shared,
    _gnb_1_ru_7_shared, _gnb_1_ru_8_shared
]

_gnb_1_cap_1 = CapacityUnit(
    hardware_type="ABIL",
    serial_number="L1190810735",
    product_code="474020A.102",
    addr="192.168.253.20",
    slot_id=SlotId.B1,
    rus=[
        _gnb_1_ru_4_shared, _gnb_1_ru_2_shared,
        _gnb_1_ru_1_shared
    ])

_gnb_1_cap_2 = CapacityUnit(
    hardware_type="ABIL",
    serial_number="L1192713255",
    product_code="474020A.102",
    addr="192.168.253.20",
    slot_id=SlotId.B2,
    rus=[_gnb_1_ru_7_shared, _gnb_1_ru_8_shared])

_gnb_1_cap_3 = CapacityUnit(
    hardware_type="ABIL",
    serial_number="L1192713251",
    product_code="474020A.102",
    addr="192.168.253.20",
    slot_id=SlotId.B3,
    rus=[_gnb_1_ru_5_shared])

_gnb_1_cap_units = [_gnb_1_cap_1, _gnb_1_cap_2, _gnb_1_cap_3]

_gnb_1_common_units = [
    CommonUnit(
        hardware_type="ASIL",
        serial_number="DH220940503",
        lmp_connection=SshServiceDetails(
            addr="192.168.255.129",
            username="toor4nsn",
            password="oZPS0POrRieRtu"),
        capacity_units=_gnb_1_cap_units,
        pdu_port=_gnb_1_common_unit_1_pdu_port,
        slot_id=SlotId.C1,
        sync_input=None,
        trs_connections=TRSInterfaces.EIF1)
]

_test_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.194.248", username="ute", password="None"),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_gnb_1_common_units[0])
    ])
_gnb_2_common_unit_1_pdu_port = ENICS(
    addr="100.68.226.170", model="ENICS", port_numbers=[2]).pdu_ports[2]

_gnb_2_ru_1_pdu_port = ENICS(
    addr="100.68.226.13", model="ENICS", port_numbers=[1]).pdu_ports[1]

_gnb_2_ru_2_pdu_port = ENICS(
    addr="100.68.226.13", model="ENICS", port_numbers=[2]).pdu_ports[2]

_gnb_2_ru_3_pdu_port = ENICS(
    addr="100.68.226.13", model="ENICS", port_numbers=[3]).pdu_ports[3]

_gnb_2_ru_1 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AEHC",
    serial_number="L1204110676",
    pdu_port=_gnb_2_ru_1_pdu_port,
    product_code="475124B.M01",
)

_gnb_2_ru_2 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AEHC",
    serial_number="L1204110674",
    pdu_port=_gnb_2_ru_2_pdu_port,
    product_code="475124B.M01",
)

_gnb_2_ru_3 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AEHC",
    serial_number="L1204110675",
    pdu_port=_gnb_2_ru_3_pdu_port,
    product_code="475124B.M01",
)

_gnb_2_rms = [_gnb_2_ru_1, _gnb_2_ru_2, _gnb_2_ru_3]

_gnb_2_cap_1 = CapacityUnit(
    hardware_type="ABIO",
    serial_number="L1210302238",
    product_code="475266A.102",
    addr="192.168.253.20",
    slot_id=SlotId.B4,
    rus=[_gnb_2_ru_1, _gnb_2_ru_2, _gnb_2_ru_3])

_gnb_2_cap_units = [_gnb_2_cap_1]

_gnb_2_common_units = [
    CommonUnit(
        hardware_type="ASIL",
        serial_number="DH220540144",
        lmp_connection=SshServiceDetails(
            addr="192.168.255.119",
            username="toor4nsn",
            password="oZPS0POrRieRtu"),
        capacity_units=_gnb_2_cap_units,
        pdu_port=_gnb_2_common_unit_1_pdu_port,
        slot_id=SlotId.C2,
        sync_input=None,
        trs_connections=TRSInterfaces.EIF1)
]

_test_vm_gnb_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.194.249", username="ute", password="None"),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_gnb_2_common_units[0])
    ])
_enb_1_common_unit_1_pdu_port = ENICS(
    addr="100.68.226.170", model="ENICS", port_numbers=[3]).pdu_ports[3]

_enb_1_rms = [
    _gnb_1_ru_1_shared, _gnb_1_ru_2_shared,
    _gnb_1_ru_4_shared, _gnb_1_ru_5_shared,
    _gnb_1_ru_7_shared, _gnb_1_ru_8_shared
]

_enb_1_cap_1 = CapacityUnit(
    hardware_type="ABIA",
    serial_number="L1172604906",
    product_code="473096A.103",
    addr="192.168.253.20",
    slot_id=SlotId.B1,
    rus=[
        _gnb_1_ru_5_shared, _gnb_1_ru_7_shared,
        _gnb_1_ru_8_shared
    ])

_enb_1_cap_2 = CapacityUnit(
    hardware_type="ABIA",
    serial_number="L1171607569",
    product_code="473096A.103",
    addr="192.168.253.20",
    slot_id=SlotId.B2,
    rus=[
        _gnb_1_ru_2_shared, _gnb_1_ru_1_shared, _gnb_1_ru_4_shared,
    ])

_enb_1_cap_units = [_enb_1_cap_1, _enb_1_cap_2]

_enb_1_common_units = [
    CommonUnit(
        hardware_type="ASIB",
        serial_number="L1190817428",
        lmp_connection=SshServiceDetails(
            addr="192.168.255.129",
            username="toor4nsn",
            password="oZPS0POrRieRtu"),
        capacity_units=_enb_1_cap_units,
        pdu_port=_enb_1_common_unit_1_pdu_port,
        slot_id=SlotId.C1,
        sync_input=ToPServer(splane_ip_address="10.33.50.2"),
        trs_connections=TRSInterfaces.EIF1)
]

_test_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.194.250", username="ute", password="None"),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_enb_1_common_units[0])
    ])

_gnbs = [
    ClassicalBts(
        cu=CU(
            backhaul_site_oam_ip=NetworkAddress(
                v4="100.68.99.34/27",
                v6="2a00:8a00:4000:4a43::1902/120",
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
                v4="100.68.99.66/27",
                v6="2a00:8a00:4000:4a43::a02/120",
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
                v4="100.68.99.34/27",
                v6="2a00:8a00:4000:4a43::1902/120",
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
                v4="100.68.99.34/27",
                v6="2a00:8a00:4000:4a43::1902/120",
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
                v4="100.68.99.34/27",
                v6="2a00:8a00:4000:4a43::1902/120",
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
                v4="100.68.99.66/27",
                v6="2a00:8a00:4000:4a43::a02/120",
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
                v4="100.68.99.66/27",
                v6="2a00:8a00:4000:4a43::a02/120",
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
                v4="100.68.99.34/27",
                v6="2a00:8a00:4000:4a43::1902/120",
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
                common_units=_gnb_1_common_units, product_code="474767A.101"),
               rus=_gnb_1_rms,
               cablinks=[
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_1_cap_1, label="S-RF1", port_id=1),
                       target=Endpoint(
                           unit=_gnb_1_ru_4_shared, label="OPT2", port_id=2)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_1_cap_1, label="Q-RF1", port_id=1),
                       target=Endpoint(
                           unit=_gnb_1_ru_2_shared, label="OPT2", port_id=2)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_1_cap_1, label="Q-RF2", port_id=2),
                       target=Endpoint(
                           unit=_gnb_1_ru_1_shared, label="OPT2", port_id=2)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_1_cap_2, label="S-RF1", port_id=1),
                       target=Endpoint(
                           unit=_gnb_1_ru_7_shared, label="OPT2", port_id=2)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_1_cap_2, label="S-RF2", port_id=2),
                       target=Endpoint(
                           unit=_gnb_1_ru_8_shared, label="OPT2", port_id=2)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_1_cap_3, label="S-RF1", port_id=1),
                       target=Endpoint(
                           unit=_gnb_1_ru_5_shared, label="OPT2", port_id=2)),
               ])
        ],
        instance_id=100800,
        global_bts_id=100800),
    ClassicalBts(
        cu=CU(
            backhaul_site_oam_ip=NetworkAddress(
                v4="100.68.99.35/27",
                v6="2a00:8a00:4000:4a43::1903/120",
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
                v4="100.68.99.67/27",
                v6="2a00:8a00:4000:4a43::a03/120",
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
                v4="100.68.99.35/27",
                v6="2a00:8a00:4000:4a43::1903/120",
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
                v4="100.68.99.35/27",
                v6="2a00:8a00:4000:4a43::1903/120",
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
                v4="100.68.99.35/27",
                v6="2a00:8a00:4000:4a43::1903/120",
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
                v4="100.68.99.67/27",
                v6="2a00:8a00:4000:4a43::a03/120",
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
                v4="100.68.99.67/27",
                v6="2a00:8a00:4000:4a43::a03/120",
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
                v4="100.68.99.35/27",
                v6="2a00:8a00:4000:4a43::1903/120",
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
                           unit=_gnb_2_ru_1, label="OPT3", port_id=3)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_2_cap_1, label="RF2", port_id=2),
                       target=Endpoint(
                           unit=_gnb_2_ru_2, label="OPT3", port_id=3)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_2_cap_1, label="RF3", port_id=3),
                       target=Endpoint(
                           unit=_gnb_2_ru_3, label="OPT3", port_id=3)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_2_cap_1, label="RF7", port_id=7),
                       target=Endpoint(
                           unit=_gnb_2_ru_1, label="OPT2", port_id=2)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_2_cap_1, label="RF8", port_id=8),
                       target=Endpoint(
                           unit=_gnb_2_ru_2, label="OPT2", port_id=2)),
                   Cablink(
                       source=Endpoint(
                           unit=_gnb_2_cap_1, label="RF9", port_id=9),
                       target=Endpoint(
                           unit=_gnb_2_ru_3, label="OPT2", port_id=2))
               ])
        ],
        instance_id=100801,
        global_bts_id=100801),
]

_enbs = [
    RealEnb(
        system_module=Airscale(
            common_units=_enb_1_common_units, product_code="473764A.102"),
        instance_id=100802,
        global_bts_id=100802,
        oam_ip=NetworkAddress(
            v4="100.68.99.4/24",
            v6="2a00:8a00:4000:4a43::1804/120",
            vlan_id=None,
            routing_v4=RoutingInformation(
                gateway="100.68.99.1", ip_prefix_length=None, destIpAddr=None),
            routing_v6=RoutingInformation(
                gateway="2a00:8a00:4000:4a43::1801",
                ip_prefix_length=None,
                destIpAddr=None)),
        rms=_enb_1_rms,
        cablinks=[
            Cablink(
                source=Endpoint(unit=_enb_1_cap_1, label="RF1", port_id=1),
                target=Endpoint(
                    unit=_gnb_1_ru_5_shared, label="OPT1", port_id=1)),
            Cablink(
                source=Endpoint(unit=_enb_1_cap_1, label="RF3", port_id=3),
                target=Endpoint(
                    unit=_gnb_1_ru_7_shared, label="OPT1", port_id=1)),
            Cablink(
                source=Endpoint(unit=_enb_1_cap_1, label="RF4", port_id=4),
                target=Endpoint(
                    unit=_gnb_1_ru_8_shared, label="OPT1", port_id=1)),
            Cablink(
                source=Endpoint(unit=_enb_1_cap_2, label="RF1", port_id=1),
                target=Endpoint(
                    unit=_gnb_1_ru_2_shared, label="OPT1", port_id=1)),
            Cablink(
                source=Endpoint(unit=_enb_1_cap_2, label="RF2", port_id=2),
                target=Endpoint(
                    unit=_gnb_1_ru_1_shared, label="OPT1", port_id=1)),
            Cablink(
                source=Endpoint(unit=_enb_1_cap_2, label="RF3", port_id=3),
                target=Endpoint(
                    unit=_gnb_1_ru_4_shared, label="OPT1", port_id=1)),
        ]),
]

_core = RealCore(
    mcc="244",
    mnc="09",
    four_g=RealCore4GDetails(
        mme=MME(
            oam_ssh_connection_details=SshServiceDetails(
                addr="1.1.1.1", username="dummy", password="None"),
            s1=NetworkAddress(
                v4="10.35.18.8",
                v6="2a00:8a00:4000:4a22::2:1108",
                vlan_id=None,
                routing_v4=None,
                routing_v6=None)),
        tac=123,
        ntp=NetworkAddress(
            v4="100.68.254.130",
            v6=None,
            vlan_id=None,
            routing_v4=None,
            routing_v6=None)),
    five_g=RealCore5GDetails(
        amf=AMF(
            oam_ssh_connection_details=None,
            n2=NetworkAddress(
                v4="10.35.18.70",
                v6="2a00:8a00:4000:4a22::2:1146",
                vlan_id=None,
                routing_v4=None,
                routing_v6=None)),
        tac=123),
)
tl = TestLine(
    test_pc=_test_vm_gnb_1,
    test_pcs=[_test_vm_gnb_1, _test_vm_gnb_2, _test_vm_enb_1],
    velocity=None,
    gnbs=_gnbs,
    enbs=_enbs,
    core=_core)

__all__ = ["tl"]

sync = {
    "top_server": "10.33.50.2",
    "top_type": "F",
}
