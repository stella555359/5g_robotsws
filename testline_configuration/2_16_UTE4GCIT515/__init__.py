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

_pdu_enb = ATEN(addr="10.42.51.166", port_numbers=[8])
_pdu_ru1 = ATEN(addr="10.42.51.153", port_numbers=[8])
_pdu_ru2 = ATEN(addr="10.42.51.152", port_numbers=[5])
_pdu_ru3 = ATEN(addr="10.42.168.234", port_numbers=[3])

_ru1 = RU(
    ru_hw_group="FRMr4.0b_4T4R_Corona",
    radio_type="FHFB",
    serial_number="L1151404923",
    pdu_port=_pdu_ru1.pdu_ports[8],
)
_ru2 = RU(
    ru_hw_group="FRMr2.3_2T2R_Reno",
    radio_type="FHDB",
    serial_number="1M155022012",
    pdu_port=_pdu_ru2.pdu_ports[5],
)
_ru3 = RU(
    ru_hw_group="FRMr3.1_6T6R",
    radio_type="FRHC",
    serial_number="L1143915831",
    pdu_port=_pdu_ru3.pdu_ports[3],
)
_abia = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="AH172300722",
    rus=[_ru1, _ru2, _ru3],
)
_asia = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia],
    pdu_port=_pdu_enb.pdu_ports[8],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1172712844",
)
_airscale = Airscale(common_units=[_asia])
_enb = RealEnb(
    system_module=_airscale,
    rms=[_ru1, _ru2, _ru3],
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.164.115", username="ute", password="ute"
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
    tl_cloud_topology="CLOUD_R4_REALRF_TESTABILITY",
)
