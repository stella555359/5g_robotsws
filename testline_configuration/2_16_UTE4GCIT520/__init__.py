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

_pdu_enb = ATEN(addr="10.42.168.33", port_numbers=[6])
_pdu_ru = ATEN(addr="10.42.168.160", port_numbers=[1, 2, 3, 4, 5])

_ru1 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHCA",
    serial_number="L1172801896",
    pdu_port=_pdu_ru.pdu_ports[3],
)
_ru2 = RU(
    ru_hw_group="FRMr5.1_2T4R",
    radio_type="AHEGA",
    serial_number="K9184924381",
    pdu_port=_pdu_ru.pdu_ports[4],
)
_ru3 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    radio_type="AHFB",
    serial_number="EA191210372",
    pdu_port=_pdu_ru.pdu_ports[5],
)
_ru4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHBOA",
    serial_number="BL2036X112M",
    pdu_port=_pdu_ru.pdu_ports[1],
)
_ru5 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHPE",
    serial_number="1M204604199",
    pdu_port=_pdu_ru.pdu_ports[2],
)
_abio = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="A.103",
    serial_number="L1211508104",
    rus=[_ru4, _ru5],
)
_abiq = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIQ",
    hardware_version="A.101",
    serial_number="L1232208149",
    rus=[_ru1, _ru2, _ru3],
)
_asil = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio, _abiq],
    pdu_port=_pdu_enb.pdu_ports[6],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1204107354",
)
_airscale = Airscale(common_units=[_asil])
_enb = RealEnb(
    system_module=_airscale,
    rms=[_ru1, _ru2, _ru3, _ru4, _ru5],
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.164.120", username="ute", password="ute"
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
    tl_cloud_topology="CLOUD_R4LA_REALRF_FV2",
)
