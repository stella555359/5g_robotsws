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


_enb_1_core_unit_1_pdu_port = ENICS(
    addr="100.68.226.168", model="ENICS", port_numbers=[5]
).pdu_ports[5]

_enb_ru_pdu = ENICS(addr="100.68.226.21", port_numbers=[1, 3])

_enb_1_ru_1_pdu_port = _enb_ru_pdu.pdu_ports[1]

_enb_1_ru_2_pdu_port = _enb_ru_pdu.pdu_ports[3]

_enb_1_ru_1 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHEH",
    serial_number="EA224157078",
    pdu_port=_enb_1_ru_1_pdu_port,
    product_code="474253A.101",
)

_enb_1_ru_2 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="AHEH",
    serial_number="EA224157079",
    pdu_port=_enb_1_ru_2_pdu_port,
    product_code="474253A.101",
)

_enb_1_rms = [_enb_1_ru_1, _enb_1_ru_2]

_enb_1_core_unit = CoreUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_enb_1_core_unit_1_pdu_port,
    hardware_type="ASOH",
    serial_number="L1243706149",
    sync_input=ToPServer(splane_ip_address="10.33.50.2"),
    trs_connections=TRSInterfaces.EIF1,
    rus=[_enb_1_ru_1, _enb_1_ru_2],
)

_enb_1_core_units = [_enb_1_core_unit]

_test_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="100.68.194.120", username="ute", password="None"
    ),
    connections=[
        Connection(interface="eth1", interface_type="lmp", device=_enb_1_core_units[0])
    ],
)

_gnbs = []

_enbs = [
    RealEnb(
        system_module=Airscale(
            core_units=_enb_1_core_units, product_code="476255A.101"
        ),
        instance_id=101604,
        global_bts_id=101604,
        oam_ip=NetworkAddress(
            v4="100.68.98.134/27",
            v6="2a00:8a00:4000:4a43::1406/120",
            routing_v4=RoutingInformation(gateway="100.68.98.129"),
            routing_v6=RoutingInformation(gateway="2a00:8a00:4000:4a43::1401"),
        ),
        rms=_enb_1_rms,
        cablinks=[
            Cablink(
                source=Endpoint(unit=_enb_1_core_unit, label="SFP", port_id=1),
                target=Endpoint(unit=_enb_1_ru_1, label="SFP", port_id=1),
            ),
            Cablink(
                source=Endpoint(unit=_enb_1_core_unit, label="SFP", port_id=2),
                target=Endpoint(unit=_enb_1_ru_1, label="SFP", port_id=2),
            ),
            Cablink(
                source=Endpoint(unit=_enb_1_core_unit, label="SFP", port_id=7),
                target=Endpoint(unit=_enb_1_ru_2, label="SFP", port_id=1),
            ),
            Cablink(
                source=Endpoint(unit=_enb_1_core_unit, label="SFP", port_id=8),
                target=Endpoint(unit=_enb_1_ru_2, label="SFP", port_id=2),
            ),
        ],
    ),
]

_core = RealCore(
    mcc="244",
    mnc="09",
    four_g=RealCore4GDetails(
        mme=MME(
            oam_ssh_connection_details=SshServiceDetails(
                addr="1.1.1.1", username="dummy", password=None
            ),
            s1=NetworkAddress(v4="10.35.18.8", v6="2a00:8a00:4000:4a22::2:1108"),
        ),
        tac=123,
        ntp=NetworkAddress(v4="100.68.254.130", v6="None"),
    ),
    five_g=None,
)
tl = TestLine(
    test_pc=_test_vm_enb_1,
    test_pcs=[_test_vm_enb_1],
    velocity=None,
    gnbs=_gnbs,
    enbs=_enbs,
    core=_core,
)

__all__ = ["tl"]

sync = None
