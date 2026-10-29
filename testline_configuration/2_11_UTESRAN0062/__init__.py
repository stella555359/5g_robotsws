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
    addr="100.68.226.166", model="ENICS", port_numbers=[5]
).pdu_ports[5]

_gnb_1_ru_1_shared_pdu_port = ENICS(
    addr="100.68.226.33", model="ENICS", port_numbers=[7]
).pdu_ports[7]

_gnb_1_ru_3_shared_pdu_port = ENICS(
    addr="100.68.226.33", model="ENICS", port_numbers=[5]
).pdu_ports[5]

_gnb_1_ru_4_shared_pdu_port = ENICS(
    addr="100.68.226.33", model="ENICS", port_numbers=[6]
).pdu_ports[6]

_gnb_1_ru_5_shared_pdu_port = ENICS(
    addr="100.68.226.33", model="ENICS", port_numbers=[1]
).pdu_ports[1]

_gnb_1_ru_6_shared_pdu_port = ENICS(
    addr="100.68.226.33", model="ENICS", port_numbers=[2]
).pdu_ports[2]

_gnb_1_ru_7_shared_pdu_port = ENICS(
    addr="100.68.226.33", model="ENICS", port_numbers=[3]
).pdu_ports[3]

_gnb_1_ru_1_shared = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHFIB",
    serial_number="BL2238V09QE",
    pdu_port=_gnb_1_ru_1_shared_pdu_port,
    product_code="474216A.101",
)

_gnb_1_ru_3_shared = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHFIB",
    serial_number="BL2238V09OD",
    pdu_port=_gnb_1_ru_3_shared_pdu_port,
    product_code="474216A.101",
)

_gnb_1_ru_4_shared = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHFIB",
    serial_number="BL2238V09NO",
    pdu_port=_gnb_1_ru_4_shared_pdu_port,
    product_code="474216A.101",
)

_gnb_1_ru_5_shared = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHLOA",
    serial_number="BL2034G1HI1",
    pdu_port=_gnb_1_ru_5_shared_pdu_port,
    product_code="474331A.101",
)

_gnb_1_ru_6_shared = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHLOA",
    serial_number="BL2034G1HH2",
    pdu_port=_gnb_1_ru_6_shared_pdu_port,
    product_code="474331A.101",
)

_gnb_1_ru_7_shared = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHLOA",
    serial_number="BL2034G1HHI",
    pdu_port=_gnb_1_ru_7_shared_pdu_port,
    product_code="474331A.101",
)

_gnb_1_rms = [
    _gnb_1_ru_1_shared,
    _gnb_1_ru_3_shared,
    _gnb_1_ru_4_shared,
    _gnb_1_ru_5_shared,
    _gnb_1_ru_6_shared,
    _gnb_1_ru_7_shared,
]

_gnb_1_cap_1 = CapacityUnit(
    hardware_type="ABIL",
    serial_number="L1192713247",
    product_code="474020A.102",
    addr="192.168.253.20",
    slot_id=SlotId.B1,
    rus=[
        _gnb_1_ru_5_shared,
        _gnb_1_ru_6_shared,
        _gnb_1_ru_7_shared,
    ],
)

_gnb_1_cap_2 = CapacityUnit(
    hardware_type="ABIL",
    serial_number="L1190102708",
    product_code="474020A.102",
    addr="192.168.253.20",
    slot_id=SlotId.B2,
    rus=[_gnb_1_ru_3_shared, _gnb_1_ru_4_shared],
)

_gnb_1_cap_3 = CapacityUnit(
    hardware_type="ABIL",
    serial_number="DH201062202",
    product_code="474020A.102",
    addr="192.168.253.20",
    slot_id=SlotId.B3,
    rus=[_gnb_1_ru_1_shared],
)

_gnb_1_cap_units = [_gnb_1_cap_1, _gnb_1_cap_2, _gnb_1_cap_3]

_gnb_1_common_units = [
    CommonUnit(
        hardware_type="ASIL",
        serial_number="L1235102176",
        lmp_connection=SshServiceDetails(
            addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
        ),
        capacity_units=_gnb_1_cap_units,
        pdu_port=_gnb_1_common_unit_1_pdu_port,
        slot_id=SlotId.C1,
        sync_input=ToPServer(splane_ip_address="10.33.50.2"),
        trs_connections=TRSInterfaces.EIF1,
    )
]

_test_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.192.222", username="ute", password="None"
    ),
    connections=[
        Connection(
            interface="eth1", interface_type="lmp", device=_gnb_1_common_units[0]
        )
    ],
)
_gnb_2_common_unit_1_pdu_port = ENICS(
    addr="100.68.226.166", model="ENICS", port_numbers=[6]
).pdu_ports[6]

_gnb_2_ru_1_pdu_port = ENICS(
    addr="100.68.226.35", model="ENICS", port_numbers=[2]
).pdu_ports[2]

_gnb_2_ru_2_pdu_port = ENICS(
    addr="100.68.226.35", model="ENICS", port_numbers=[6]
).pdu_ports[6]

_gnb_2_ru_3_pdu_port = ENICS(
    addr="100.68.226.35", model="ENICS", port_numbers=[4]
).pdu_ports[4]

_gnb_2_ru_1 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AEHC",
    serial_number="K9220312574",
    pdu_port=_gnb_2_ru_1_pdu_port,
    product_code="475124B.M01",
)
_gnb_2_ru_2 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AEHC",
    serial_number="L1213401835",
    pdu_port=_gnb_2_ru_2_pdu_port,
    product_code="475124B.M01",
)
_gnb_2_ru_3 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AEHC",
    serial_number="K9222600531",
    pdu_port=_gnb_2_ru_3_pdu_port,
    product_code="475124B.101",
)

_gnb_2_rms = [_gnb_2_ru_1, _gnb_2_ru_2, _gnb_2_ru_3]

_gnb_2_cap_1 = CapacityUnit(
    hardware_type="ABIO",
    serial_number="L1221800712",
    product_code="475266A.104",
    addr="192.168.253.20",
    slot_id=SlotId.B4,
    rus=[_gnb_2_ru_1, _gnb_2_ru_2, _gnb_2_ru_3],
)

_gnb_2_cap_units = [_gnb_2_cap_1]

_gnb_2_common_units = [
    CommonUnit(
        hardware_type="ASIL",
        serial_number="L1235105136",
        lmp_connection=SshServiceDetails(
            addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
        ),
        capacity_units=_gnb_2_cap_units,
        pdu_port=_gnb_2_common_unit_1_pdu_port,
        slot_id=SlotId.C2,
        sync_input=ToPServer(splane_ip_address="10.33.50.2"),
        trs_connections=TRSInterfaces.EIF1,
    )
]

_test_vm_gnb_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.192.223", username="ute", password="None"
    ),
    connections=[
        Connection(
            interface="eth1", interface_type="lmp", device=_gnb_2_common_units[0]
        )
    ],
)
_enb_1_common_unit_1_pdu_port = ENICS(
    addr="100.68.226.166", model="ENICS", port_numbers=[7]
).pdu_ports[7]

_enb_1_rms = [
    _gnb_1_ru_1_shared,
    _gnb_1_ru_3_shared,
    _gnb_1_ru_4_shared,
    _gnb_1_ru_5_shared,
    _gnb_1_ru_6_shared,
    _gnb_1_ru_7_shared,
]

_enb_1_cap_1 = CapacityUnit(
    hardware_type="ABIA",
    serial_number="DH213591223",
    product_code="473096A.107",
    addr="192.168.253.20",
    slot_id=SlotId.B1,
    rus=[
        _gnb_1_ru_3_shared,
        _gnb_1_ru_4_shared,
        _gnb_1_ru_1_shared,
    ],
)

_enb_1_cap_2 = CapacityUnit(
    hardware_type="ABIA",
    serial_number="DH213495042",
    product_code="473096A.107",
    addr="192.168.253.20",
    slot_id=SlotId.B2,
    rus=[
        _gnb_1_ru_5_shared,
        _gnb_1_ru_6_shared,
        _gnb_1_ru_7_shared,
    ],
)

_enb_1_cap_units = [_enb_1_cap_1, _enb_1_cap_2]

_enb_1_common_units = [
    CommonUnit(
        hardware_type="ASIB",
        serial_number="L1192105206",
        lmp_connection=SshServiceDetails(
            addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
        ),
        capacity_units=_enb_1_cap_units,
        pdu_port=_enb_1_common_unit_1_pdu_port,
        slot_id=SlotId.C1,
        sync_input=ToPServer(splane_ip_address="10.33.50.2"),
        trs_connections=TRSInterfaces.EIF1,
    )
]

_test_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.192.224", username="ute", password="None"
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
                v4="100.68.98.38/27",
                v6="2a00:8a00:4000:4a43::1106/120",
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
                v4="100.68.98.70/27",
                v6="2a00:8a00:4000:4a43::1206/120",
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
                v4="100.68.98.38/27",
                v6="2a00:8a00:4000:4a43::1106/120",
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
                v4="100.68.98.38/27",
                v6="2a00:8a00:4000:4a43::1106/120",
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
                v4="100.68.98.38/27",
                v6="2a00:8a00:4000:4a43::1106/120",
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
                v4="100.68.98.70/27",
                v6="2a00:8a00:4000:4a43::1206/120",
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
                v4="100.68.98.70/27",
                v6="2a00:8a00:4000:4a43::1206/120",
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
                v4="100.68.98.38/27",
                v6="2a00:8a00:4000:4a43::1106/120",
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
                cablinks=[],
            )
        ],
        instance_id=101804,
        global_bts_id=101804,
    ),
    ClassicalBts(
        cu=CU(
            backhaul_site_oam_ip=NetworkAddress(
                v4="100.68.98.39/27",
                v6="2a00:8a00:4000:4a43::1107/120",
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
                v4="100.68.98.71/27",
                v6="2a00:8a00:4000:4a43::1207/120",
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
                v4="100.68.98.39/27",
                v6="2a00:8a00:4000:4a43::1107/120",
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
                v4="100.68.98.39/27",
                v6="2a00:8a00:4000:4a43::1107/120",
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
                    common_units=_gnb_2_common_units, product_code="474767A.101"
                ),
                rus=_gnb_2_rms,
                cablinks=[],
            )
        ],
        instance_id=101805,
        global_bts_id=101805,
    ),
]

_enbs = [
    RealEnb(
        system_module=Airscale(
            common_units=_enb_1_common_units, product_code="473764A.102"
        ),
        instance_id=101806,
        global_bts_id=101806,
        oam_ip=NetworkAddress(
            v4="100.68.98.8/27",
            v6="2a00:8a00:4000:4a43::1008/120",
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
        cablinks=[],
    )
]

_core = RealCore(
    mcc="244",
    mnc="09",
    four_g=RealCore4GDetails(
        mme=MME(
            oam_ssh_connection_details=SshServiceDetails(
                addr="1.1.1.1", username="dummy", password=None
            ),
            s1=NetworkAddress(
                v4="10.35.18.8",
                v6="2a00:8a00:4000:4a22::2:1108",
                vlan_id=None,
                routing_v4=None,
                routing_v6=None,
            ),
        ),
        tac=123,
        ntp=NetworkAddress(
            v4="100.68.254.130",
            v6=None,
            vlan_id=None,
            routing_v4=None,
            routing_v6=None,
        ),
    ),
    five_g=RealCore5GDetails(
        amf=AMF(
            oam_ssh_connection_details=None,
            n2=NetworkAddress(
                v4="10.35.18.70",
                v6="2a00:8a00:4000:4a22::2:1146",
                vlan_id=None,
                routing_v4=None,
                routing_v6=None,
            ),
        ),
        tac=123,
    ),
)
tl = TestLine(
    test_pc=_test_vm_gnb_1,
    test_pcs=[_test_vm_gnb_1, _test_vm_gnb_2, _test_vm_enb_1],
    velocity=None,
    gnbs=_gnbs,
    enbs=_enbs,
    core=_core,
)

__all__ = ["tl"]

sync = None
