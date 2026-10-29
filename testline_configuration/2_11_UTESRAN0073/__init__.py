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
from taf.config.testline.pdu import ENICS, DELTA
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
    addr="100.68.226.169", model="ENICS", port_numbers=[7]
).pdu_ports[7]

_gnb_1_ru_1_pdu_port = ENICS(
    addr="100.68.226.11", model="ENICS", port_numbers=[16]
).pdu_ports[16]

_gnb_1_ru_2_pdu_port = ENICS(
    addr="100.68.226.11", model="ENICS", port_numbers=[5]
).pdu_ports[5]

_gnb_1_ru_3_pdu_port = ENICS(
    addr="100.68.226.11", model="ENICS", port_numbers=[6]
).pdu_ports[6]

_gnb_1_ru_4_pdu_port = ENICS(
    addr="100.68.226.20", model="ENICS", port_numbers=[1]
).pdu_ports[1]
_gnb_1_ru_5_pdu_port = ENICS(
    addr="100.68.226.20", model="ENICS", port_numbers=[2]
).pdu_ports[2]
_gnb_1_ru_6_pdu_port = ENICS(
    addr="100.68.226.20", model="ENICS", port_numbers=[3]
).pdu_ports[3]

_gnb_1_ru_1 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHLOB",
    serial_number="BL2243D50XG",
    pdu_port=_gnb_1_ru_1_pdu_port,
    product_code="475910A.101",
)

_gnb_1_ru_2 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHLOB",
    serial_number="BL2243D50WP",
    pdu_port=_gnb_1_ru_2_pdu_port,
    product_code="475910A.101",
)

_gnb_1_ru_3 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHLOB",
    serial_number="BL2244D50YD",
    pdu_port=_gnb_1_ru_3_pdu_port,
    product_code="475910A.101",
)

_gnb_1_ru_4 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AVQQA",
    serial_number="L1242304960",
    pdu_port=_gnb_1_ru_4_pdu_port,
    product_code="476596A.101",
)

_gnb_1_ru_5 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AVQQA",
    serial_number="L1242002660",
    pdu_port=_gnb_1_ru_5_pdu_port,
    product_code="476596A.101",
)

_gnb_1_ru_6 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AVQQA",
    serial_number="L1244407227",
    pdu_port=_gnb_1_ru_6_pdu_port,
    product_code="476596A.101",
)

_gnb_1_rms = [
    _gnb_1_ru_1,
    _gnb_1_ru_2,
    _gnb_1_ru_3,
    _gnb_1_ru_4,
    _gnb_1_ru_5,
    _gnb_1_ru_6,
]

_gnb_1_cap_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    serial_number="L1240602969",
    product_code="475792A.102",
    slot_id=SlotId.B1,
    rus=[_gnb_1_ru_1, _gnb_1_ru_2, _gnb_1_ru_3],
)

_gnb_1_cap_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    serial_number="L1240602952",
    product_code="475792A.102",
    slot_id=SlotId.B2,
    rus=[_gnb_1_ru_4, _gnb_1_ru_5, _gnb_1_ru_6],
)

_gnb_1_cap_units = [_gnb_1_cap_1, _gnb_1_cap_2]

_gnb_1_common_units = [
    CommonUnit(
        lmp_connection=SshServiceDetails(
            addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
        ),
        pdu_port=_gnb_1_common_unit_1_pdu_port,
        capacity_units=_gnb_1_cap_units,
        hardware_type="ASIM",
        serial_number="L1233304576",
        slot_id=SlotId.C1,
        trs_connections=TRSInterfaces.EIF1,
    )
]

_test_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.194.169", username="ute", password=None
    ),
    connections=[
        Connection(
            interface="eth1", interface_type="lmp", device=_gnb_1_common_units[0]
        )
    ],
)
_gnb_2_common_unit_1_pdu_port = ENICS(
    addr="100.68.226.169", model="ENICS", port_numbers=[8]
).pdu_ports[8]

_gnb_2_ru_1_pdu_port = ENICS(
    addr="100.68.226.37", model="ENICS", port_numbers=[14]
).pdu_ports[14]
_gnb_2_ru_2_pdu_port = ENICS(
    addr="100.68.226.37", model="ENICS", port_numbers=[15]
).pdu_ports[15]
_gnb_2_ru_3_pdu_port = ENICS(
    addr="100.68.226.37", model="ENICS", port_numbers=[16]
).pdu_ports[16]
_gnb_2_ru_4_pdu_port = ENICS(
    addr="100.68.226.11", model="ENICS", port_numbers=[13]
).pdu_ports[13]
_gnb_2_ru_5_pdu_port = ENICS(
    addr="100.68.226.11", model="ENICS", port_numbers=[14]
).pdu_ports[14]
_gnb_2_ru_6_pdu_port = ENICS(
    addr="100.68.226.11", model="ENICS", port_numbers=[15]
).pdu_ports[15]

_gnb_2_ru_1 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AEHC",
    serial_number="L1213401838",
    pdu_port=_gnb_2_ru_1_pdu_port,
    product_code="475124B.M01",
)

_gnb_2_ru_2 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AEHC",
    serial_number="L1213401840",
    pdu_port=_gnb_2_ru_2_pdu_port,
    product_code="475124A.101",
)

_gnb_2_ru_3 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AEHC",
    serial_number="K9223210648",
    pdu_port=_gnb_2_ru_3_pdu_port,
    product_code="475124B.M01",
)

_gnb_2_ru_4 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHFII",
    serial_number="K9242417311",
    pdu_port=_gnb_2_ru_4_pdu_port,
    product_code="475656A.103",
)

_gnb_2_ru_5 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHFII",
    serial_number="K9242417322",
    pdu_port=_gnb_2_ru_5_pdu_port,
    product_code="475656A.103",
)

_gnb_2_ru_6 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHFII",
    serial_number="K9242417334",
    pdu_port=_gnb_2_ru_6_pdu_port,
    product_code="475656A.101",
)

_gnb_2_rms = [
    _gnb_2_ru_1,
    _gnb_2_ru_2,
    _gnb_2_ru_3,
    _gnb_2_ru_4,
    _gnb_2_ru_5,
    _gnb_2_ru_6,
]

_gnb_2_cap_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    serial_number="L1240602964",
    product_code="475792A.102",
    slot_id=SlotId.B4,
    rus=[_gnb_2_ru_1, _gnb_2_ru_2, _gnb_2_ru_3],
)

_gnb_2_cap_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    serial_number="L1240602965",
    product_code="475792A.102",
    slot_id=SlotId.B5,
    rus=[_gnb_2_ru_4, _gnb_2_ru_5, _gnb_2_ru_6],
)

_gnb_2_cap_units = [_gnb_2_cap_1, _gnb_2_cap_2]

_gnb_2_common_units = [
    CommonUnit(
        lmp_connection=SshServiceDetails(
            addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
        ),
        pdu_port=_gnb_2_common_unit_1_pdu_port,
        capacity_units=_gnb_2_cap_units,
        hardware_type="ASIM",
        serial_number="L1234305427",
        slot_id=SlotId.C2,
        trs_connections=TRSInterfaces.EIF1,
    )
]

_test_vm_gnb_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.192.97", username="ute", password=None
    ),
    connections=[
        Connection(
            interface="eth1", interface_type="lmp", device=_gnb_2_common_units[0]
        )
    ],
)

_gnbs = [
    ClassicalBts(
        cu=CU(
            backhaul_site_oam_ip=NetworkAddress(
                v4="100.68.98.180/27",
                v6="2a00:8a00:4000:4a43::1514/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.98.161"),
                routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1501"),
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
                v4="100.68.98.180/27",
                v6="2a00:8a00:4000:4a43::1514/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.98.161"),
                routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1501"),
            ),
            x2u=NetworkAddress(
                v4="100.68.98.180/27",
                v6="2a00:8a00:4000:4a43::1514/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.98.161"),
                routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1501"),
            ),
            s1u=NetworkAddress(
                v4="100.68.98.180/27",
                v6="2a00:8a00:4000:4a43::1514/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.98.161"),
                routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1501"),
            ),
            ngu=NetworkAddress(
                v4="100.68.98.180/27",
                v6="2a00:8a00:4000:4a43::1514/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.98.161"),
                routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1501"),
            ),
            ngc=NetworkAddress(
                v4="100.68.98.180/27",
                v6="2a00:8a00:4000:4a43::1514/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.98.161"),
                routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1501"),
            ),
            xnc=NetworkAddress(
                v4="100.68.98.180/27",
                v6="2a00:8a00:4000:4a43::1514/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.98.161"),
                routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1501"),
            ),
            xnu=NetworkAddress(
                v4="100.68.98.180/27",
                v6="2a00:8a00:4000:4a43::1514/120",
                vlan_id=21,
                routing_v4=RoutingInformation(gateway="100.68.98.161"),
                routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1501"),
            ),
        ),
        dus=[
            DU(
                airscale=Airscale(
                    common_units=_gnb_1_common_units, product_code="475765A.104"
                ),
                rus=_gnb_1_rms,
                cablinks=[
                    Cablink(
                        source=Endpoint(unit=_gnb_1_cap_1, label="RF1", port_id=1),
                        target=Endpoint(unit=_gnb_1_ru_1, label="OPT1", port_id=1),
                    ),
                    Cablink(
                        source=Endpoint(unit=_gnb_1_cap_1, label="RF2", port_id=2),
                        target=Endpoint(unit=_gnb_1_ru_2, label="OPT1", port_id=1),
                    ),
                    Cablink(
                        source=Endpoint(unit=_gnb_1_cap_1, label="RF3", port_id=3),
                        target=Endpoint(unit=_gnb_1_ru_3, label="OPT1", port_id=1),
                    ),
                    Cablink(
                        source=Endpoint(unit=_gnb_1_cap_1, label="RF4", port_id=4),
                        target=Endpoint(unit=_gnb_1_ru_1, label="OPT2", port_id=2),
                    ),
                    Cablink(
                        source=Endpoint(unit=_gnb_1_cap_1, label="RF5", port_id=5),
                        target=Endpoint(unit=_gnb_1_ru_2, label="OPT2", port_id=2),
                    ),
                    Cablink(
                        source=Endpoint(unit=_gnb_1_cap_1, label="RF6", port_id=6),
                        target=Endpoint(unit=_gnb_1_ru_3, label="OPT2", port_id=2),
                    ),
                    Cablink(
                        source=Endpoint(unit=_gnb_1_cap_2, label="RF1", port_id=1),
                        target=Endpoint(unit=_gnb_1_ru_4, label="OPT1", port_id=1),
                    ),
                    Cablink(
                        source=Endpoint(unit=_gnb_1_cap_2, label="RF2", port_id=2),
                        target=Endpoint(unit=_gnb_1_ru_5, label="OPT1", port_id=1),
                    ),
                    Cablink(
                        source=Endpoint(unit=_gnb_1_cap_2, label="RF3", port_id=3),
                        target=Endpoint(unit=_gnb_1_ru_6, label="OPT1", port_id=1),
                    ),
                    Cablink(
                        source=Endpoint(unit=_gnb_1_cap_2, label="RF4", port_id=4),
                        target=Endpoint(unit=_gnb_1_ru_4, label="OPT2", port_id=2),
                    ),
                    Cablink(
                        source=Endpoint(unit=_gnb_1_cap_2, label="RF5", port_id=5),
                        target=Endpoint(unit=_gnb_1_ru_5, label="OPT2", port_id=2),
                    ),
                    Cablink(
                        source=Endpoint(unit=_gnb_1_cap_2, label="RF6", port_id=6),
                        target=Endpoint(unit=_gnb_1_ru_6, label="OPT2", port_id=2),
                    ),
                ],
            )
        ],
        instance_id=101618,
        global_bts_id=101618,
    ),
    ClassicalBts(
        cu=CU(
            backhaul_site_oam_ip=NetworkAddress(
                v4="100.68.98.149/27",
                v6="2a00:8a00:4000:4a43::1415/120",
                vlan_id=None,
                routing_v4=RoutingInformation(gateway="100.68.98.129"),
                routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1401"),
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
        ),
        dus=[
            DU(
                airscale=Airscale(
                    common_units=_gnb_2_common_units, product_code="475765A.104"
                ),
                rus=_gnb_2_rms,
                cablinks=[
                    Cablink(
                        source=Endpoint(unit=_gnb_2_cap_1, label="RF1", port_id=1),
                        target=Endpoint(unit=_gnb_2_ru_1, label="OPT1", port_id=1),
                    ),
                    Cablink(
                        source=Endpoint(unit=_gnb_2_cap_1, label="RF10", port_id=10),
                        target=Endpoint(unit=_gnb_2_ru_1, label="OPT4", port_id=4),
                    ),
                    Cablink(
                        source=Endpoint(unit=_gnb_2_cap_1, label="RF11", port_id=11),
                        target=Endpoint(unit=_gnb_2_ru_2, label="OPT4", port_id=4),
                    ),
                    Cablink(
                        source=Endpoint(unit=_gnb_2_cap_1, label="RF12", port_id=12),
                        target=Endpoint(unit=_gnb_2_ru_3, label="OPT4", port_id=4),
                    ),
                    Cablink(
                        source=Endpoint(unit=_gnb_2_cap_1, label="RF2", port_id=2),
                        target=Endpoint(unit=_gnb_2_ru_2, label="OPT1", port_id=1),
                    ),
                    Cablink(
                        source=Endpoint(unit=_gnb_2_cap_1, label="RF3", port_id=3),
                        target=Endpoint(unit=_gnb_2_ru_3, label="OPT1", port_id=1),
                    ),
                    Cablink(
                        source=Endpoint(unit=_gnb_2_cap_1, label="RF4", port_id=4),
                        target=Endpoint(unit=_gnb_2_ru_1, label="OPT2", port_id=2),
                    ),
                    Cablink(
                        source=Endpoint(unit=_gnb_2_cap_1, label="RF5", port_id=5),
                        target=Endpoint(unit=_gnb_2_ru_2, label="OPT2", port_id=2),
                    ),
                    Cablink(
                        source=Endpoint(unit=_gnb_2_cap_1, label="RF6", port_id=6),
                        target=Endpoint(unit=_gnb_2_ru_3, label="OPT2", port_id=2),
                    ),
                    Cablink(
                        source=Endpoint(unit=_gnb_2_cap_1, label="RF7", port_id=7),
                        target=Endpoint(unit=_gnb_2_ru_1, label="OPT3", port_id=3),
                    ),
                    Cablink(
                        source=Endpoint(unit=_gnb_2_cap_1, label="RF8", port_id=8),
                        target=Endpoint(unit=_gnb_2_ru_2, label="OPT3", port_id=3),
                    ),
                    Cablink(
                        source=Endpoint(unit=_gnb_2_cap_1, label="RF9", port_id=9),
                        target=Endpoint(unit=_gnb_2_ru_3, label="OPT3", port_id=3),
                    ),
                    Cablink(
                        source=Endpoint(unit=_gnb_2_cap_2, label="RF1", port_id=1),
                        target=Endpoint(unit=_gnb_2_ru_4, label="OPT1", port_id=1),
                    ),
                    Cablink(
                        source=Endpoint(unit=_gnb_2_cap_2, label="RF2", port_id=2),
                        target=Endpoint(unit=_gnb_2_ru_5, label="OPT1", port_id=1),
                    ),
                    Cablink(
                        source=Endpoint(unit=_gnb_2_cap_2, label="RF3", port_id=3),
                        target=Endpoint(unit=_gnb_2_ru_6, label="OPT1", port_id=1),
                    ),
                    Cablink(
                        source=Endpoint(unit=_gnb_2_cap_2, label="RF4", port_id=4),
                        target=Endpoint(unit=_gnb_2_ru_4, label="OPT2", port_id=2),
                    ),
                    Cablink(
                        source=Endpoint(unit=_gnb_2_cap_2, label="RF5", port_id=5),
                        target=Endpoint(unit=_gnb_2_ru_5, label="OPT2", port_id=2),
                    ),
                    Cablink(
                        source=Endpoint(unit=_gnb_2_cap_2, label="RF6", port_id=6),
                        target=Endpoint(unit=_gnb_2_ru_6, label="OPT2", port_id=2),
                    ),
                ],
            )
        ],
        instance_id=101619,
        global_bts_id=101619,
    ),
]

_enbs = []

_core = RealCore(
    mcc="244",
    mnc="09",
    four_g=None,
    five_g=RealCore5GDetails(
        amf=AMF(
            oam_ssh_connection_details=None,
            n2=NetworkAddress(v4="10.35.18.70", v6="2a00:8a00:4000:4a22::2:1146"),
        ),
        tac=8000,
    ),
)
tl = TestLine(
    test_pc=_test_vm_gnb_1,
    test_pcs=[_test_vm_gnb_1, _test_vm_gnb_2],
    gnbs=_gnbs,
    enbs=_enbs,
    core=_core,
)

__all__ = ["tl"]

sync = {
    "top_server": "10.33.50.2",
    "top_type": "F",
}
