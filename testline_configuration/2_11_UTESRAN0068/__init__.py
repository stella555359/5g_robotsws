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
    addr="100.68.226.171", model="ENICS", port_numbers=[8]).pdu_ports[8]

_enb_1_ru_1_pdu_port = ENICS(
    addr="100.68.226.97", model="ENICS", port_numbers=[9]).pdu_ports[9]
_enb_1_ru_2_pdu_port = ENICS(
    addr="100.68.226.103", model="ENICS", port_numbers=[8]).pdu_ports[8]
_enb_1_ru_3_pdu_port = ENICS(
    addr="100.68.226.97", model="ENICS", port_numbers=[7]).pdu_ports[7]
_enb_1_ru_4_pdu_port = ENICS(
    addr="100.68.226.103", model="ENICS", port_numbers=[7]).pdu_ports[7]
_enb_1_ru_5_pdu_port = ENICS(
    addr="100.68.226.97", model="ENICS", port_numbers=[10]).pdu_ports[10]
_enb_1_ru_6_pdu_port = ENICS(
    addr="100.68.226.97", model="ENICS", port_numbers=[5]).pdu_ports[5]
_enb_1_ru_7_pdu_port = ENICS(
    addr="100.68.226.97", model="ENICS", port_numbers=[8]).pdu_ports[8]
_enb_1_ru_8_pdu_port = ENICS(
    addr="100.68.226.97", model="ENICS", port_numbers=[6]).pdu_ports[6]
_enb_1_ru_9_pdu_port = ENICS(
    addr="100.68.226.103", model="ENICS", port_numbers=[3]).pdu_ports[3]
_enb_1_ru_10_pdu_port = ENICS(
    addr="100.68.226.103", model="ENICS", port_numbers=[5]).pdu_ports[5]
_enb_1_ru_11_pdu_port = ENICS(
    addr="100.68.226.103", model="ENICS", port_numbers=[4]).pdu_ports[4]
_enb_1_ru_12_pdu_port = ENICS(
    addr="100.68.226.103", model="ENICS", port_numbers=[9]).pdu_ports[9]
_enb_1_ru_13_pdu_port = ENICS(
    addr="100.68.226.103", model="ENICS", port_numbers=[2]).pdu_ports[2]
_enb_1_ru_14_pdu_port = ENICS(
    addr="100.68.226.103", model="ENICS", port_numbers=[10]).pdu_ports[10]
_enb_1_ru_15_pdu_port = ENICS(
    addr="100.68.226.103", model="ENICS", port_numbers=[1]).pdu_ports[1]
_enb_1_ru_16_pdu_port = ENICS(
    addr="100.68.226.103", model="ENICS", port_numbers=[6]).pdu_ports[6]

_enb_1_ru_1 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="FXEF",
    serial_number="EA213610336",
    pdu_port=_enb_1_ru_1_pdu_port,
    product_code="473439A.202")

_enb_1_ru_2 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="FRGT",
    serial_number="L9133800014",
    pdu_port=_enb_1_ru_2_pdu_port,
    product_code="472810A.102")

_enb_1_ru_3 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="FXEF",
    serial_number="EA213610329",
    pdu_port=_enb_1_ru_3_pdu_port,
    product_code="473439A.202")

_enb_1_ru_4 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="FRGT",
    serial_number="L6142358159",
    pdu_port=_enb_1_ru_4_pdu_port,
    product_code="472810A.102")

_enb_1_ru_5 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="FXCA",
    serial_number="L6114923455",
    pdu_port=_enb_1_ru_5_pdu_port,
    product_code="472142A.202")

_enb_1_ru_6 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="FRHG",
    serial_number="K9161460665",
    pdu_port=_enb_1_ru_6_pdu_port,
    product_code="473225A.101")

_enb_1_ru_7 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="FXCA",
    serial_number="L6122438951",
    pdu_port=_enb_1_ru_7_pdu_port,
    product_code="472142A.202")

_enb_1_ru_8 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="FRHG",
    serial_number="K9174417580",
    pdu_port=_enb_1_ru_8_pdu_port,
    product_code="473225A.101")

_enb_1_ru_9 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="FXEF",
    serial_number="EA213610360",
    pdu_port=_enb_1_ru_9_pdu_port,
    product_code="473439A.202")

_enb_1_ru_10 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="FRGT",
    serial_number="F7173700869",
    pdu_port=_enb_1_ru_10_pdu_port,
    product_code="472810A.102")

_enb_1_ru_11 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="FXCA",
    serial_number="L9112000711",
    pdu_port=_enb_1_ru_11_pdu_port,
    product_code="472142A.202")

_enb_1_ru_12 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="FRHG",
    serial_number="K9161460668",
    pdu_port=_enb_1_ru_12_pdu_port,
    product_code="473225A.101")

_enb_1_ru_13 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="FXCA",
    serial_number="L6114305030",
    pdu_port=_enb_1_ru_13_pdu_port,
    product_code="472142A.202")

_enb_1_ru_14 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="FRHG",
    serial_number="K9161460666",
    pdu_port=_enb_1_ru_14_pdu_port,
    product_code="473225A.101")

_enb_1_ru_15 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="FXEF",
    serial_number="EA213610355",
    pdu_port=_enb_1_ru_15_pdu_port,
    product_code="473439A.202")

_enb_1_ru_16 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="FRGT",
    serial_number="F7173658527",
    pdu_port=_enb_1_ru_16_pdu_port,
    product_code="472810A.102")

_enb_1_rms = [
    _enb_1_ru_1, _enb_1_ru_2, _enb_1_ru_3, _enb_1_ru_4, _enb_1_ru_5,
    _enb_1_ru_6, _enb_1_ru_7, _enb_1_ru_8, _enb_1_ru_9, _enb_1_ru_10,
    _enb_1_ru_11, _enb_1_ru_12, _enb_1_ru_13, _enb_1_ru_14, _enb_1_ru_15,
    _enb_1_ru_16
]

_enb_1_cap_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="L1162615871",
    product_code="473096A.102",
    slot_id=SlotId.B4,
    rus=[
        _enb_1_ru_1, _enb_1_ru_2, _enb_1_ru_3, _enb_1_ru_4, _enb_1_ru_5,
        _enb_1_ru_6
    ])

_enb_1_cap_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="L1163615130",
    product_code="473096A.103",
    slot_id=SlotId.B5,
    rus=[_enb_1_ru_7, _enb_1_ru_8, _enb_1_ru_9, _enb_1_ru_10])

_enb_1_cap_3 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="L1170220389",
    product_code="473096A.103",
    slot_id=SlotId.B6,
    rus=[
        _enb_1_ru_11, _enb_1_ru_12, _enb_1_ru_13, _enb_1_ru_14, _enb_1_ru_15,
        _enb_1_ru_16
    ])

_enb_1_cap_units = [_enb_1_cap_1, _enb_1_cap_2, _enb_1_cap_3]

_enb_1_common_units = [
    CommonUnit(
        lmp_connection=SshServiceDetails(
            addr="192.168.255.129",
            username="toor4nsn",
            password="oZPS0POrRieRtu"),
        pdu_port=_enb_1_common_unit_1_pdu_port,
        capacity_units=_enb_1_cap_units,
        hardware_type="ASIA",
        serial_number="K9173215812",
        slot_id=SlotId.C2,
        sync_input=ToPServer(splane_ip_address="10.33.50.2"),
        trs_connections=TRSInterfaces.EIF1)
]

_test_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.195.62", username="ute", password="None"),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_enb_1_common_units[0])
    ])

_gnbs = []

_enbs = [
    RealEnb(
        system_module=Airscale(
            common_units=_enb_1_common_units, product_code="473095A.203"),
        instance_id=100819,
        global_bts_id=100819,
        oam_ip=NetworkAddress(
            v4="100.68.99.21/27",
            v6="2a00:8a00:4000:4a43::1815/120",
            routing_v4=RoutingInformation(gateway="100.68.99.1"),
            routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1801")),
        rms=_enb_1_rms,
        cablinks=[
            Cablink(
                source=Endpoint(unit=_enb_1_cap_1, label="SFP", port_id=1),
                target=Endpoint(unit=_enb_1_ru_1, label="SFP", port_id=1)),
            Cablink(
                source=Endpoint(unit=_enb_1_cap_1, label="SFP", port_id=2),
                target=Endpoint(unit=_enb_1_ru_1, label="SFP", port_id=2)),
            Cablink(
                source=Endpoint(unit=_enb_1_cap_1, label="SFP", port_id=3),
                target=Endpoint(unit=_enb_1_ru_3, label="SFP", port_id=1)),
            Cablink(
                source=Endpoint(unit=_enb_1_cap_1, label="SFP", port_id=4),
                target=Endpoint(unit=_enb_1_ru_3, label="SFP", port_id=2)),
            Cablink(
                source=Endpoint(unit=_enb_1_cap_1, label="SFP", port_id=5),
                target=Endpoint(unit=_enb_1_ru_5, label="SFP", port_id=1)),
            Cablink(
                source=Endpoint(unit=_enb_1_cap_1, label="SFP", port_id=6),
                target=Endpoint(unit=_enb_1_ru_5, label="SFP", port_id=2)),
            Cablink(
                source=Endpoint(unit=_enb_1_cap_2, label="SFP", port_id=1),
                target=Endpoint(unit=_enb_1_ru_7, label="SFP", port_id=1)),
            Cablink(
                source=Endpoint(unit=_enb_1_cap_2, label="SFP", port_id=2),
                target=Endpoint(unit=_enb_1_ru_7, label="SFP", port_id=2)),
            Cablink(
                source=Endpoint(unit=_enb_1_cap_2, label="SFP", port_id=3),
                target=Endpoint(unit=_enb_1_ru_9, label="SFP", port_id=1)),
            Cablink(
                source=Endpoint(unit=_enb_1_cap_2, label="SFP", port_id=4),
                target=Endpoint(unit=_enb_1_ru_9, label="SFP", port_id=2)),
            Cablink(
                source=Endpoint(unit=_enb_1_cap_3, label="SFP", port_id=1),
                target=Endpoint(unit=_enb_1_ru_11, label="SFP", port_id=1)),
            Cablink(
                source=Endpoint(unit=_enb_1_cap_3, label="SFP", port_id=2),
                target=Endpoint(unit=_enb_1_ru_11, label="SFP", port_id=2)),
            Cablink(
                source=Endpoint(unit=_enb_1_cap_3, label="SFP", port_id=3),
                target=Endpoint(unit=_enb_1_ru_13, label="SFP", port_id=1)),
            Cablink(
                source=Endpoint(unit=_enb_1_cap_3, label="SFP", port_id=4),
                target=Endpoint(unit=_enb_1_ru_13, label="SFP", port_id=2)),
            Cablink(
                source=Endpoint(unit=_enb_1_cap_3, label="SFP", port_id=5),
                target=Endpoint(unit=_enb_1_ru_15, label="SFP", port_id=1)),
            Cablink(
                source=Endpoint(unit=_enb_1_cap_3, label="SFP", port_id=6),
                target=Endpoint(unit=_enb_1_ru_15, label="SFP", port_id=2)),
            Cablink(
                source=Endpoint(unit=_enb_1_ru_1, label="SFP", port_id=3),
                target=Endpoint(unit=_enb_1_ru_2, label="SFP", port_id=1)),
            Cablink(
                source=Endpoint(unit=_enb_1_ru_3, label="SFP", port_id=3),
                target=Endpoint(unit=_enb_1_ru_4, label="SFP", port_id=1)),
            Cablink(
                source=Endpoint(unit=_enb_1_ru_5, label="SFP", port_id=3),
                target=Endpoint(unit=_enb_1_ru_6, label="SFP", port_id=1)),
            Cablink(
                source=Endpoint(unit=_enb_1_ru_7, label="SFP", port_id=3),
                target=Endpoint(unit=_enb_1_ru_8, label="SFP", port_id=1)),
            Cablink(
                source=Endpoint(unit=_enb_1_ru_9, label="SFP", port_id=3),
                target=Endpoint(unit=_enb_1_ru_10, label="SFP", port_id=1)),
            Cablink(
                source=Endpoint(unit=_enb_1_ru_11, label="SFP", port_id=3),
                target=Endpoint(unit=_enb_1_ru_12, label="SFP", port_id=1)),
            Cablink(
                source=Endpoint(unit=_enb_1_ru_13, label="SFP", port_id=3),
                target=Endpoint(unit=_enb_1_ru_14, label="SFP", port_id=1)),
            Cablink(
                source=Endpoint(unit=_enb_1_ru_15, label="SFP", port_id=3),
                target=Endpoint(unit=_enb_1_ru_16, label="SFP", port_id=1))
        ]),
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
        tac=123,
        ntp=NetworkAddress(v4="100.68.254.130", v6="2a00:8a00:4000:1003::44")),
    five_g=None,
)
tl = TestLine(
    test_pc=_test_vm_enb_1,
    test_pcs=[_test_vm_enb_1],
    velocity=None,
    gnbs=_gnbs,
    enbs=_enbs,
    core=_core)

__all__ = ["tl"]

sync = {
    "top_server": "10.33.50.2",
    "top_type": "P",
}
