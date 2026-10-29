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


_enb_1_common_unit_1_pdu_port = ENICS(
    addr="100.68.226.171", model="ENICS", port_numbers=[9]).pdu_ports[9]

_enb_1_ru_1_pdu_port = ENICS(
    addr="100.68.226.88", model="ENICS", port_numbers=[8]).pdu_ports[8]

_enb_1_ru_2_pdu_port = ENICS(
    addr="100.68.226.88", model="ENICS", port_numbers=[9]).pdu_ports[9]

_enb_1_ru_3_pdu_port = ENICS(
    addr="100.68.226.88", model="ENICS", port_numbers=[10]).pdu_ports[10]

_enb_1_ru_4_pdu_port = ENICS(
    addr="100.68.226.88", model="ENICS", port_numbers=[11]).pdu_ports[11]

_enb_1_ru_5_pdu_port = ENICS(
    addr="100.68.226.79", model="ENICS", port_numbers=[14]).pdu_ports[14]

_enb_1_ru_6_pdu_port = ENICS(
    addr="100.68.226.79", model="ENICS", port_numbers=[15]).pdu_ports[15]

_enb_1_ru_7_pdu_port = ENICS(
    addr="100.68.226.79", model="ENICS", port_numbers=[16]).pdu_ports[16]

_enb_1_ru_1 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHFII",
    serial_number="BL2323N46OE",
    pdu_port=_enb_1_ru_1_pdu_port,
    product_code="475656A.101")

_enb_1_ru_2 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHFII",
    serial_number="BL2323N46OE",
    pdu_port=_enb_1_ru_2_pdu_port,
    product_code="475656A.101")

_enb_1_ru_3 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHFII",
    serial_number="K9242417516",
    pdu_port=_enb_1_ru_3_pdu_port,
    product_code="475656A.101")

_enb_1_ru_4 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHFII",
    serial_number="BL2323N46O7",
    pdu_port=_enb_1_ru_4_pdu_port,
    product_code="475656A.101")

_enb_1_ru_5 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHLOA",
    serial_number="BL2050G1SHQ",
    pdu_port=_enb_1_ru_5_pdu_port,
    product_code="474331A.101")

_enb_1_ru_6 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHLOA",
    serial_number="BL2050G1SGS",
    pdu_port=_enb_1_ru_6_pdu_port,
    product_code="474331A.101")

_enb_1_ru_7 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHLOA",
    serial_number="BL2050G1SGU",
    pdu_port=_enb_1_ru_7_pdu_port,
    product_code="474331A.101")

_enb_1_rms = [_enb_1_ru_1, _enb_1_ru_2, _enb_1_ru_3, _enb_1_ru_4, _enb_1_ru_5, _enb_1_ru_6, _enb_1_ru_7]

_enb_1_cap_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="DH213495173",
    product_code="473096A.107",
    slot_id=SlotId.B1,
    rus=[_enb_1_ru_1, _enb_1_ru_2])

_enb_1_cap_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="DH202592809",
    product_code="473096A.104",
    slot_id=SlotId.B2,
    rus=[_enb_1_ru_3, _enb_1_ru_4])

_enb_1_cap_3 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="L1173915496",
    product_code="473096A.103",
    slot_id=SlotId.B3,
    rus=[_enb_1_ru_5, _enb_1_ru_6, _enb_1_ru_7])

_enb_1_cap_units = [_enb_1_cap_1, _enb_1_cap_2, _enb_1_cap_3]

_enb_1_common_units = [
    CommonUnit(
        lmp_connection=SshServiceDetails(
            addr="192.168.255.129",
            username="toor4nsn",
            password="oZPS0POrRieRtu"),
        pdu_port=_enb_1_common_unit_1_pdu_port,
        capacity_units=_enb_1_cap_units,
        hardware_type="ASIB",
        serial_number="L1204707643",
        slot_id=SlotId.C1,
        sync_input=ToPServer(splane_ip_address="10.34.142.79"),
        trs_connections=TRSInterfaces.EIF1)
]

_test_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.195.63", username="ute", password=None),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_enb_1_common_units[0])
    ])
_enb_2_common_unit_1_pdu_port = ENICS(
    addr="100.68.226.171", model="ENICS", port_numbers=[11]).pdu_ports[11]


_enb_2_cap_1 = CapacityUnit(
    addr="",
    hardware_type="FSPD",
    serial_number="L1142300173",
    product_code="472181A.103",
    rus=[])

_enb_2_cap_2 = CapacityUnit(
    addr="",
    hardware_type="FBBC",
    serial_number="NK154630610",
    product_code="472797A.101")

_enb_2_cap_units = [_enb_2_cap_1, _enb_2_cap_2]


_enb_2_common_units = [
    CommonUnit(
        lmp_connection=SshServiceDetails(
            addr="192.168.255.119",
            username="toor4nsn",
            password="oZPS0POrRieRtu"),
        pdu_port=_enb_2_common_unit_1_pdu_port,
        capacity_units=_enb_2_cap_units,
        hardware_type="FSMF",
        serial_number="L1142300173",
        sync_input=ToPServer(splane_ip_address="10.34.142.79"),
        trs_connections=TRSInterfaces.EIF1)
]

_test_vm_enb_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.195.64", username="ute", password=None),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_enb_2_common_units[0])
    ])

_gnbs = []

_enbs = [
    RealEnb(
        system_module=Airscale(
            common_units=_enb_1_common_units, product_code="473764A.102"),
        instance_id=100820,
        global_bts_id=100820,
        oam_ip=NetworkAddress(
            v4="100.68.99.22/27",
            v6="2a00:8a00:4000:4a43::1816/120",
            routing_v4=RoutingInformation(gateway="100.68.99.1"),
            routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1801")),
        rms=_enb_1_rms,
        cablinks=[
            Cablink(
                source=Endpoint(unit=_enb_1_cap_1, label="RF1", port_id=1),
                target=Endpoint(unit=_enb_1_ru_1, label="OPT1", port_id=1)),
            Cablink(
                source=Endpoint(unit=_enb_1_cap_1, label="RF2", port_id=2),
                target=Endpoint(unit=_enb_1_ru_2, label="OPT1", port_id=1)),
            Cablink(
                source=Endpoint(unit=_enb_1_cap_1, label="RF6", port_id=6),
                target=Endpoint(unit=_enb_2_cap_1, label="EIF2_RF6", port_id=6)),
            Cablink(
                source=Endpoint(unit=_enb_1_cap_2, label="RF1", port_id=1),
                target=Endpoint(unit=_enb_1_ru_3, label="OPT1", port_id=1)),
            Cablink(
                source=Endpoint(unit=_enb_1_cap_2, label="RF2", port_id=2),
                target=Endpoint(unit=_enb_1_ru_4, label="OPT1", port_id=1)),
            Cablink(
                source=Endpoint(unit=_enb_1_cap_3, label="RF1", port_id=1),
                target=Endpoint(unit=_enb_1_ru_5, label="OPT1", port_id=1)),
            Cablink(
                source=Endpoint(unit=_enb_1_cap_3, label="RF2", port_id=2),
                target=Endpoint(unit=_enb_1_ru_6, label="OPT1", port_id=1)),
            Cablink(
                source=Endpoint(unit=_enb_1_cap_3, label="RF3", port_id=3),
                target=Endpoint(unit=_enb_1_ru_7, label="OPT1", port_id=1)),
]),
    RealEnb(
        system_module=Flexi(
            common_units=_enb_2_common_units, product_code="475765A.104"),
        instance_id=100821,
        global_bts_id=100821,
        oam_ip=NetworkAddress(
            v4="100.68.99.23/27",
            v6="2a00:8a00:4000:4a43::1817/120",
            routing_v4=RoutingInformation(gateway="100.68.99.1"),
            routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1801")),
        rms=None,
        cablinks=[]),
]

_core = RealCore(
    mcc="244",
    mnc="09",
    four_g=RealCore4GDetails(
        mme=MME(
            oam_ssh_connection_details=SshServiceDetails(
                addr="1.1.1.1", username="dummy", password=None),
            s1=NetworkAddress(
                v4="10.35.18.8", v6="2a00:8a00:4000:4a22::2:1108")),
        tac=500,
        ntp=NetworkAddress(v4="10.34.142.90", v6="2a00:8a00:4000:1003::44")),
    five_g=None,
)
tl = TestLine(
    test_pc=_test_vm_enb_1,
    test_pcs=[_test_vm_enb_1, _test_vm_enb_2],
    velocity=None,
    gnbs=_gnbs,
    enbs=_enbs,
    core=_core)

__all__ = ["tl"]

sync = {
    "top_server": "10.34.142.79",
    "top_type": "F",
}
