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

_pdu_enb = ATEN(addr="10.42.168.33", port_numbers=[1])
_pdu_ru = ATEN(addr="10.42.168.233", port_numbers=[2, 3, 6, 7, 8])

_ru1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLBA",
    serial_number="BL1920F100M",
    pdu_port=_pdu_ru.pdu_ports[8],
)
_ru2 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type="AHPMDA",
    serial_number="K9184331220",
    pdu_port=_pdu_ru.pdu_ports[7],
)
_ru3 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHGC",
    serial_number="4H184830000",
    pdu_port=_pdu_ru.pdu_ports[6],
)
_ru4 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHEH",
    serial_number="EA203151100",
    pdu_port=_pdu_ru.pdu_ports[3],
)
_ru5 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHNA",
    serial_number="1M192300105",
    pdu_port=_pdu_ru.pdu_ports[2],
)
_abio = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="A.103",
    serial_number="L1211508104",
    rus=[_ru1, _ru2, _ru3, _ru4, _ru5],
)
_asim = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio],
    pdu_port=_pdu_enb.pdu_ports[1],
    hardware_type="ASIM",
    hardware_version="A.101",
    serial_number="L1224503609",
)
_airscale = Airscale(common_units=[_asim])
_enb = RealEnb(
    system_module=_airscale,
    rms=[_ru1, _ru2, _ru3, _ru4, _ru5],
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.164.114", username="ute", password="ute"
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
    tl_cloud_topology="CLOUD_R4MO_REALRF_TL01",
)
