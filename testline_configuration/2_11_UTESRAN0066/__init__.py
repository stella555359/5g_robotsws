__maintainer__ = "DTL Oulu"
__team__ = "MN SRAN Trunk Eng OUL 2 SG"
__email__ = "I_MBB_GLOBAL_LTE_ENODEB_IV_OULU_UTE@internal.nsn.com"

from taf.config.testline import Connection, TestPc, TestLine
from taf.config.testline.enb import RealEnb
from taf.config.testline.airscale import (
    CapacityUnit,
    CommonUnit,
    CoreUnit,
    Airscale,
    SlotId,
    TRSInterfaces,
)
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.pdu import ENICS
from taf.config.testline.gnb.networkaddress import NetworkAddress, RoutingInformation
from taf.config.testline.lab_infrastructure import Velocity
from taf.config.testline.sync_input import ToPServer
from taf.config.testline.radio import RU
from taf.config.testline.ald import ALDEmulator
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.core import (
    RealCore,
    RealCore4GDetails,
    MME,
    RealCore5GDetails,
    AMF,
)
from taf.config.testline.flexi import Flexi


_gnb_1_common_unit_1_pdu_port = ENICS(
    addr="100.68.226.166", model="ENICS", port_numbers=[10]
).pdu_ports[10]

_gnb_1_ru_1_shared_pdu_port = ENICS(
    addr="100.68.226.31", model="ENICS", port_numbers=[1, 2, 3, 4, 5, 6]
).pdu_ports[1]

_gnb_1_ru_2_shared_pdu_port = ENICS(
    addr="100.68.226.31", model="ENICS", port_numbers=[1, 2, 3, 4, 5, 6]
).pdu_ports[2]

_gnb_1_ru_3_shared_pdu_port = ENICS(
    addr="100.68.226.31", model="ENICS", port_numbers=[1, 2, 3, 4, 5, 6]
).pdu_ports[3]

_gnb_1_ru_4_pdu_port = ENICS(
    addr="100.68.226.18", port_numbers=[13, 14, 15]).pdu_ports[13]

_gnb_1_ru_5_pdu_port = ENICS(
    addr="100.68.226.18", port_numbers=[13, 14, 15]).pdu_ports[14]

_gnb_1_ru_6_pdu_port = ENICS(
    addr="100.68.226.18", port_numbers=[13, 14, 15]).pdu_ports[15]

_gnb_1_ru_8_pdu_port = ENICS(
    addr="100.68.226.29", model="ENICS", port_numbers=[1, 2, 3]
).pdu_ports[1]

_gnb_1_ru_9_pdu_port = ENICS(
    addr="100.68.226.29", model="ENICS", port_numbers=[1, 2, 3]
).pdu_ports[2]

_gnb_1_ru_10_pdu_port = ENICS(
    addr="100.68.226.29", model="ENICS", port_numbers=[1, 2, 3]
).pdu_ports[3]

_gnb_1_ru_1_shared = RU(
    ru_hw_group="",
    radio_type="AHFIB",
    serial_number="BL2044V0RIL",
    pdu_port=_gnb_1_ru_1_shared_pdu_port,
    product_code="474216A.101",
)

_gnb_1_ru_2_shared = RU(
    ru_hw_group="",
    radio_type="AHFIB",
    serial_number="BL2044V0R9U",
    pdu_port=_gnb_1_ru_2_shared_pdu_port,
    product_code="474216A.101",
)

_gnb_1_ru_3_shared = RU(
    ru_hw_group="",
    radio_type="AHFIB",
    serial_number="BL2135V0JYX",
    pdu_port=_gnb_1_ru_3_shared_pdu_port,
    product_code="474216A.101",
)

_gnb_1_ru_4 = RU(
    ru_hw_group="",
    radio_type="AHCA",
    serial_number="AS212914912",
    pdu_port=_gnb_1_ru_4_pdu_port,
    product_code="473966A.101",
)

_gnb_1_ru_5 = RU(
    ru_hw_group="",
    radio_type="AHCA",
    serial_number="AS201818031",
    pdu_port=_gnb_1_ru_5_pdu_port,
    product_code="473966A.101",
)

_gnb_1_ru_6_shared = RU(
    ru_hw_group="",
    radio_type="AHCA",
    serial_number="AS201400010",
    pdu_port=_gnb_1_ru_6_pdu_port,
    product_code="473966A.101",
)

_gnb_1_ru_8 = RU(
    ru_hw_group="",
    radio_type="AEQK",
    serial_number="DH214100733",
    pdu_port=_gnb_1_ru_8_pdu_port,
    product_code="475589A.101",
)

_gnb_1_ru_9 = RU(
    ru_hw_group="",
    radio_type="AEQK",
    serial_number="DH214200014",
    pdu_port=_gnb_1_ru_9_pdu_port,
    product_code="475589A.101",
)

_gnb_1_ru_10 = RU(
    ru_hw_group="",
    radio_type="AEQK",
    serial_number="DH214100756",
    pdu_port=_gnb_1_ru_10_pdu_port,
    product_code="475589A.101",
)

_gnb_1_rms = [
    _gnb_1_ru_1_shared,
    _gnb_1_ru_2_shared,
    _gnb_1_ru_3_shared,
    _gnb_1_ru_4,
    _gnb_1_ru_5,
    _gnb_1_ru_6_shared,
    _gnb_1_ru_6_shared,
    _gnb_1_ru_8,
    _gnb_1_ru_9,
    _gnb_1_ru_10,
]

_gnb_1_cap_1 = CapacityUnit(
    hardware_type="ABIO",
    serial_number="L1214307832",
    product_code="475266A.103",
    addr="192.168.253.20",
    slot_id=SlotId.B4,
    rus=[
        _gnb_1_ru_1_shared,
        _gnb_1_ru_2_shared,
        _gnb_1_ru_3_shared,
        _gnb_1_ru_6_shared,
        _gnb_1_ru_4,
        _gnb_1_ru_5,
        _gnb_1_ru_8,
        _gnb_1_ru_9,
        _gnb_1_ru_10,
    ],
)

_gnb_1_cap_2 = CapacityUnit(
    hardware_type="ABIO",
    serial_number="DH214746823",
    product_code="475266A.103",
    addr="192.168.253.20",
    slot_id=SlotId.B5,
    rus=[
        _gnb_1_ru_1_shared,
        _gnb_1_ru_2_shared,
        _gnb_1_ru_3_shared,
        _gnb_1_ru_6_shared,
        _gnb_1_ru_4,
        _gnb_1_ru_5,
        _gnb_1_ru_8,
        _gnb_1_ru_9,
        _gnb_1_ru_10,
    ],
)

_gnb_1_cap_units = [_gnb_1_cap_1, _gnb_1_cap_2]

_gnb_1_common_units = [
    CommonUnit(
        hardware_type="ASIL",
        serial_number="L1214014237",
        lmp_connection=SshServiceDetails(
            addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
        ),
        capacity_units=_gnb_1_cap_units,
        pdu_port=_gnb_1_common_unit_1_pdu_port,
        slot_id=SlotId.C2,
        sync_input=None,
        trs_connections=TRSInterfaces.EIF1,
    )
]

_test_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.192.228", username="ute", password="ute"
    ),
    connections=[
        Connection(
            interface="eth1", interface_type="lmp", device=_gnb_1_common_units[0]
        )
    ],
)
_enb_1_common_unit_1_pdu_port = ENICS(
    addr="100.68.226.166", model="ENICS", port_numbers=[9]
).pdu_ports[9]

_enb_1_rms = [_gnb_1_ru_1_shared, _gnb_1_ru_2_shared, _gnb_1_ru_3_shared]

_enb_1_cap_1 = CapacityUnit(
    hardware_type="ABIA",
    serial_number="L1172801168",
    product_code="473096A.103",
    addr="192.168.253.20",
    slot_id=SlotId.B1,
    rus=[_gnb_1_ru_1_shared, _gnb_1_ru_2_shared, _gnb_1_ru_3_shared],
)

_enb_1_cap_units = [_enb_1_cap_1]

_enb_1_common_units = [
    CommonUnit(
        hardware_type="ASIA",
        serial_number="L1184710130",
        lmp_connection=SshServiceDetails(
            addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
        ),
        capacity_units=_enb_1_cap_units,
        pdu_port=_enb_1_common_unit_1_pdu_port,
        slot_id=SlotId.C1,
        sync_input=None,
        trs_connections=TRSInterfaces.EIF1,
    )
]

_test_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.192.227", username="ute", password="None"
    ),
    connections=[
        Connection(
            interface="eth1", interface_type="lmp", device=_enb_1_common_units[0]
        )
    ],
)

_gnbs = [
    ClassicalBts(
        cu=CU(
            backhaul_site_oam_ip=NetworkAddress(
                v4="100.68.98.43/27",
                v6="2a00:8a00:4000:4a43::110b/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.98.33", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1101",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            oam_ssh_connection_details=SshServiceDetails(
                addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
            ),
            oam_http_connection_details=HttpConnectionDetails(
                addr="192.168.255.129",
                username="Nemuadmin",
                password="nemuuser",
                port=443,
            ),
            x2c=NetworkAddress(
                v4="100.68.98.75/27",
                v6="2a00:8a00:4000:4a43::120b/120",
                vlan_id=22,
                routing_v4=RoutingInformation(
                    gateway="100.68.98.65", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1201",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            x2u=NetworkAddress(
                v4="100.68.98.43/27",
                v6="2a00:8a00:4000:4a43::110b/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.98.33", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1101",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            s1u=NetworkAddress(
                v4="100.68.98.43/27",
                v6="2a00:8a00:4000:4a43::110b/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.98.33", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1101",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            ngu=NetworkAddress(
                v4="100.68.98.43/27",
                v6="2a00:8a00:4000:4a43::110b/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.98.33", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1101",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            ngc=NetworkAddress(
                v4="100.68.98.75/27",
                v6="2a00:8a00:4000:4a43::120b/120",
                vlan_id=22,
                routing_v4=RoutingInformation(
                    gateway="100.68.98.65", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1201",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            xnc=NetworkAddress(
                v4="100.68.98.75/27",
                v6="2a00:8a00:4000:4a43::120b/120",
                vlan_id=22,
                routing_v4=RoutingInformation(
                    gateway="100.68.98.65", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1201",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
            xnu=NetworkAddress(
                v4="100.68.98.43/27",
                v6="2a00:8a00:4000:4a43::110b/120",
                vlan_id=21,
                routing_v4=RoutingInformation(
                    gateway="100.68.98.33", ip_prefix_length=None, destIpAddr=None
                ),
                routing_v6=RoutingInformation(
                    gateway="2a00:8a00:4000:4a43::1101",
                    ip_prefix_length=None,
                    destIpAddr=None,
                ),
            ),
        ),
        dus=[
            DU(
                airscale=Airscale(
                    common_units=_gnb_1_common_units, product_code="474767A.101"
                ),
                rus=_gnb_1_rms,
            )
        ],
        instance_id=101809,
        global_bts_id=101809,
    ),
]

_enbs = [
    RealEnb(
        system_module=Airscale(common_units=_enb_1_common_units, product_code="None"),
        instance_id=101808,
        global_bts_id=101808,
        oam_ip=NetworkAddress(
            v4="100.68.98.10/27",
            v6="2a00:8a00:4000:4a43::100a/120",
            vlan_id=None,
            routing_v4=RoutingInformation(
                gateway="100.68.98.1", ip_prefix_length=None, destIpAddr=None
            ),
            routing_v6=RoutingInformation(
                gateway="2a00:8a00:4000:4a43::1001",
                ip_prefix_length=None,
                destIpAddr=None,
            ),
        ),
        rms=_enb_1_rms,
    ),
]

tl = TestLine(
    test_pc=_test_vm_gnb_1,
    test_pcs=[_test_vm_gnb_1, _test_vm_enb_1],
    velocity=None,
    gnbs=_gnbs,
    enbs=_enbs,
)

__all__ = ["tl"]

sync = None
