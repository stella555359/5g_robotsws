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


_enb_1_common_unit_1_pdu_port = ENICS(addr="100.68.226.171", model="ENICS", port_numbers=[5]).pdu_ports[5]

_ru_enics_pdu_1 = ENICS(addr="100.68.226.82", model="ENICS", port_numbers=[1, 2, 3])
_ru_enics_pdu_2 = ENICS(addr="100.68.226.15", model="ENICS", port_numbers=[1, 2, 3])
_ru_enics_pdu_3 = ENICS(addr="100.68.226.78", model="ENICS", port_numbers=[8, 9, 10])
_ru_enics_pdu_4 = ENICS(addr="100.68.226.11", model="ENICS", port_numbers=[10])

_ru_1 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AHLOA",
    serial_number="BL2004G100L",
    pdu_port=_ru_enics_pdu_1.pdu_ports[3],
    product_code="474331A.101",
)

_ru_2 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AHLOA",
    serial_number="BL2027G1AV9",
    pdu_port=_ru_enics_pdu_1.pdu_ports[1],
    product_code="474331A.101",
)

_ru_4 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AEHC",
    serial_number="L1204510661",
    pdu_port=_ru_enics_pdu_2.pdu_ports[3],
    product_code="475124B.101",
)

_ru_5 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AEHC",
    serial_number="K9223200761",
    pdu_port=_ru_enics_pdu_2.pdu_ports[2],
    product_code="475124B.101",
)

_ru_6 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AHFIB",
    serial_number="K9184803146",
    pdu_port=_ru_enics_pdu_3.pdu_ports[8],
    product_code="474216A.101",
)

_ru_7 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AHFIB",
    serial_number="BL2049V0VKN",
    pdu_port=_ru_enics_pdu_3.pdu_ports[9],
    product_code="474216A.101",
)

_ru_9 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AHLOA",
    serial_number="BL2027G1AV8",
    pdu_port=_ru_enics_pdu_1.pdu_ports[2],
    product_code="474331A.101",
)

_ru_10 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AEHC",
    serial_number="K9223200758",
    pdu_port=_ru_enics_pdu_2.pdu_ports[1],
    product_code="475124B.101",
)

_ru_11 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AHFIB",
    serial_number="BL2238V09NP",
    pdu_port=_ru_enics_pdu_4.pdu_ports[10],
    product_code="474216A.101",
)

_enb_1_rms = [_ru_6, _ru_7, _ru_11, _ru_1, _ru_2, _ru_9]

_enb_1_cap_1 = CapacityUnit(
    hardware_type="ABIA",
    serial_number="L1164613766",
    product_code="473096A.103",
    addr="192.168.253.20",
    slot_id=SlotId.B1,
    rus=[_ru_6, _ru_7, _ru_11])

_enb_1_cap_2 = CapacityUnit(
    hardware_type="ABIA",
    serial_number="L1171201105",
    product_code="473096A.102",
    addr="192.168.253.20",
    slot_id=SlotId.B2,
    rus=[_ru_1, _ru_2, _ru_9])

_enb_1_cap_units = [_enb_1_cap_1, _enb_1_cap_2]

_enb_1_common_units = [
    CommonUnit(
        hardware_type='ASIB',
        serial_number='DH214340546',
        lmp_connection=SshServiceDetails(
            addr='192.168.255.129',
            username='toor4nsn',
            port=22,
            password='oZPS0POrRieRtu',
            private_key=None,
            proxy=None),
        capacity_units=_enb_1_cap_units,
        pdu_port=_enb_1_common_unit_1_pdu_port,
        slot_id=SlotId.C1,
        sync_input=ToPServer(splane_ip_address='10.33.50.2'),
        trs_connections=TRSInterfaces.EIF1)
]

_test_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.195.59", username="ute", password="None"),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_enb_1_common_units[0])
    ])

_gnb_1_common_unit_1_pdu_port = ENICS(
    addr="100.68.226.171", model="ENICS", port_numbers=[6]).pdu_ports[6]

_gnb_1_rms = [_ru_10, _ru_5, _ru_4, _ru_6, _ru_7, _ru_11]

_gnb_1_cap_1 = CapacityUnit(
    hardware_type="ABIO",
    serial_number="L1223606560",
    product_code="475266A.104",
    addr="192.168.253.20",
    slot_id=SlotId.B4,
    rus=[_ru_10, _ru_5, _ru_4])

_gnb_1_cap_2 = CapacityUnit(
    hardware_type="ABIO",
    serial_number="LR224140020",
    product_code="475266A.104",
    addr="192.168.253.20",
    slot_id=SlotId.B5,
    rus=[_ru_6, _ru_7, _ru_11])

_gnb_1_cap_units = [_gnb_1_cap_1, _gnb_1_cap_2]

_gnb_1_common_units = [
    CommonUnit(
        hardware_type='ASIL',
        serial_number='DH220843078',
        lmp_connection=SshServiceDetails(
            addr='192.168.255.129',
            username='toor4nsn',
            port=22,
            password='oZPS0POrRieRtu',
            private_key=None,
            proxy=None),
        capacity_units=_gnb_1_cap_units,
        pdu_port=_gnb_1_common_unit_1_pdu_port,
        slot_id=SlotId.C2,
        sync_input=None,
        trs_connections=TRSInterfaces.EIF1)
]

_test_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.195.60", username="ute", password="None"),
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
                v4="100.68.99.51/27",
                v6="2a00:8a00:4000:4a43::1913/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway='100.68.99.33',
                    ip_prefix_length=None,
                    destIpAddr=None),
                routing_v6=RoutingInformation(
                    gateway='2a00:8a00:4000:4a43::1901',
                    ip_prefix_length=None,
                    destIpAddr=None),
            ),
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
                v4="100.68.99.83/27",
                v6="2a00:8a00:4000:4a43::a13/120",
                vlan_id=22,
                routing_v4=RoutingInformation(
                    gateway='100.68.99.65',
                    ip_prefix_length=None,
                    destIpAddr=None),
                routing_v6=RoutingInformation(
                    gateway='2a00:8a00:4000:4a43::a01',
                    ip_prefix_length=None,
                    destIpAddr=None),
            ),
            x2u=NetworkAddress(
                v4="100.68.99.51/27",
                v6="2a00:8a00:4000:4a43::1913/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway='100.68.99.33',
                    ip_prefix_length=None,
                    destIpAddr=None),
                routing_v6=RoutingInformation(
                    gateway='2a00:8a00:4000:4a43::1901',
                    ip_prefix_length=None,
                    destIpAddr=None),
            ),
            s1u=NetworkAddress(
                v4="100.68.99.51/27",
                v6="2a00:8a00:4000:4a43::1913/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway='100.68.99.33',
                    ip_prefix_length=None,
                    destIpAddr=None),
                routing_v6=RoutingInformation(
                    gateway='2a00:8a00:4000:4a43::1901',
                    ip_prefix_length=None,
                    destIpAddr=None),
            ),
            ngu=NetworkAddress(
                v4="100.68.99.51/27",
                v6="2a00:8a00:4000:4a43::1913/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway='100.68.99.33',
                    ip_prefix_length=None,
                    destIpAddr=None),
                routing_v6=RoutingInformation(
                    gateway='2a00:8a00:4000:4a43::1901',
                    ip_prefix_length=None,
                    destIpAddr=None),
            ),
            ngc=NetworkAddress(
                v4="100.68.99.83/27",
                v6="2a00:8a00:4000:4a43::a13/120",
                vlan_id=22,
                routing_v4=RoutingInformation(
                    gateway='100.68.99.65',
                    ip_prefix_length=None,
                    destIpAddr=None),
                routing_v6=RoutingInformation(
                    gateway='2a00:8a00:4000:4a43::a01',
                    ip_prefix_length=None,
                    destIpAddr=None),
            ),
            xnc=NetworkAddress(
                v4="100.68.99.83/27",
                v6="2a00:8a00:4000:4a43::a13/120",
                vlan_id=22,
                routing_v4=RoutingInformation(
                    gateway='100.68.99.65',
                    ip_prefix_length=None,
                    destIpAddr=None),
                routing_v6=RoutingInformation(
                    gateway='2a00:8a00:4000:4a43::a01',
                    ip_prefix_length=None,
                    destIpAddr=None),
            ),
            xnu=NetworkAddress(
                v4="100.68.99.51/27",
                v6="2a00:8a00:4000:4a43::1913/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway='100.68.99.33',
                    ip_prefix_length=None,
                    destIpAddr=None),
                routing_v6=RoutingInformation(
                    gateway='2a00:8a00:4000:4a43::1901',
                    ip_prefix_length=None,
                    destIpAddr=None),
            ),
        ),
        dus=[
            DU(airscale=Airscale(
                common_units=_gnb_1_common_units, product_code='474767A.101'),
               rus=_gnb_1_rms,
               cablinks=[])
        ],
        instance_id=100817,
        global_bts_id=100817),
]

_enbs = [
    RealEnb(
        system_module=Airscale(
            common_units=_enb_1_common_units, product_code='473764A.102'),
        instance_id=100816,
        global_bts_id=100816,
        oam_ip=NetworkAddress(
            v4="100.68.99.18/27",
            v6="2a00:8a00:4000:4a43::1812/120",
            vlan_id=None,
            routing_v4=RoutingInformation(
                gateway='100.68.99.1', ip_prefix_length=None, destIpAddr=None),
            routing_v6=RoutingInformation(
                gateway='2a00:8a00:4000:4a43::1801',
                ip_prefix_length=None,
                destIpAddr=None),
        ),
        rms=_enb_1_rms,
        cablinks=[]),
]

_core = RealCore(
    mcc="244",
    mnc="09",
    four_g=RealCore4GDetails(
        mme=MME(
            oam_ssh_connection_details=SshServiceDetails(
                addr='1.1.1.1',
                username='dummy',
                port=22,
                password=None,
                private_key=None,
                proxy=None),
            s1=NetworkAddress(
                v4="10.35.18.8",
                v6="2a00:8a00:4000:4a22::2:1108",
                vlan_id=None,
                routing_v4=None,
                routing_v6=None,
            )),
        tac=123,
        ntp=NetworkAddress(
            v4="100.68.254.130",
            v6=None,
            vlan_id=None,
            routing_v4=None,
            routing_v6=None,
        )),
    five_g=RealCore5GDetails(
        amf=AMF(
            oam_ssh_connection_details=None,
            n2=NetworkAddress(
                v4="10.35.18.70",
                v6="2a00:8a00:4000:4a22::2:1146",
                vlan_id=None,
                routing_v4=None,
                routing_v6=None,
            )),
        tac=7926),
)
tl = TestLine(
    test_pc=_test_vm_gnb_1,
    test_pcs=[_test_vm_gnb_1, _test_vm_enb_1],
    velocity=None,
    gnbs=_gnbs,
    enbs=_enbs,
    core=_core)

__all__ = ["tl"]

sync = None
