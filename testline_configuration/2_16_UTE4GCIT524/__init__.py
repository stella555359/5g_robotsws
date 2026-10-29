__maintainer__ = "Przemyslaw Krolikowski"
__owner_email__ = "I_MN_RAN_TRUNK_SG_WRO2@internal.nsn.com"
__email__ = "przemyslaw.krolikowski@nokia.com"

from taf.config.testline import Connection
from taf.config.testline.pdu import ATEN
from taf.config.testline.radio import RU
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.enb import RealEnb
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.testpc import TestPc
from taf.config.testline.testline import TestLine

__all__ = ["tl"]

_pdu_enb = ATEN(addr="10.42.51.166", port_numbers=[2])
_pdu_ru1 = ATEN(addr="10.42.51.153", port_numbers=[1, 2, 4])
_pdu_ru2 = ATEN(addr="10.42.169.48", port_numbers=[1, 7])
_pdu_ru3 = ATEN(addr="10.42.169.181", port_numbers=[1, 2, 5])
_pdu_ru4 = ATEN(addr="10.42.168.234", port_numbers=[1])

_ru1 = RU(
    ru_hw_group="FRMTDr5.1_1_4T4R",
    radio_type="AZNA",
    serial_number="6Q190504170",
    pdu_port=_pdu_ru1.pdu_ports[1],
)
_ru2 = RU(
    ru_hw_group="FRMTDr5.1_1_4T4R",
    radio_type="AZHA",
    serial_number="RW200200055",
    pdu_port=_pdu_ru1.pdu_ports[2],
)
_ru3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="K9184821162",
    pdu_port=_pdu_ru1.pdu_ports[4],
)
_ru4 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type="AREA",
    serial_number="EA191872441",
    pdu_port=_pdu_ru2.pdu_ports[1],
)
_ru5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGB",
    serial_number="K9190906224",
    pdu_port=_pdu_ru2.pdu_ports[7],
)
_ru6 = RU(
    ru_hw_group="FRMTDr5.1b_1_2T2R_LP",
    radio_type="AZRB",
    serial_number="1M183023630",
    pdu_port=_pdu_ru3.pdu_ports[1],
)
_ru7 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    radio_type="AHIB",
    serial_number="EA174110393",
    pdu_port=_pdu_ru3.pdu_ports[2],
)
_ru8 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type="AHPMDB",
    serial_number="AS205305261",
    pdu_port=_pdu_ru3.pdu_ports[5],
)
_ru9 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type="ARPA",
    serial_number="F7193108717",
    pdu_port=_pdu_ru4.pdu_ports[1],
)
_abia = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="A.102",
    serial_number="L1163403136",
    rus=[_ru4, _ru6, _ru9],
)
_abio = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="A.103",
    serial_number="L1211511281",
    rus=[_ru1, _ru2, _ru7, _ru8],
)
_abil = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIL",
    hardware_version="A.102",
    serial_number="L1200204088",
    rus=[_ru3, _ru5],
)
_asil = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia, _abio, _abil],
    pdu_port=_pdu_enb.pdu_ports[2],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1214008194",
)
_airscale = Airscale(common_units=[_asil])
_enb = RealEnb(
    system_module=_airscale,
    rms=[_ru1, _ru2, _ru3, _ru4, _ru5, _ru6, _ru7, _ru8, _ru9],
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.163.154", username="ute", password="ute"
    ),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_enb.system_module.common_units[0],
        )
    ],
)

tl = TestLine(
    test_pc=_test_pc,
    enbs=[_enb],
    tl_cloud_topology="CLOUD_R4_REALRF_CA1",
)
