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

_pdu_1 = ATEN(addr="10.42.168.33", port_numbers=[3, 4, 5])
_pdu_2 = ATEN(addr="10.42.168.235", port_numbers=[1, 2, 3])

_ru1 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type="ARPA",
    serial_number="AS204710538",
    pdu_port=_pdu_1.pdu_ports[4],
)
_ru2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIA",
    serial_number="K9184331220",
    pdu_port=_pdu_2.pdu_ports[1],
)
_ru3 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type="ARMA",
    serial_number="4H184830000",
    pdu_port=_pdu_1.pdu_ports[5],
)
_ru4 = RU(
    ru_hw_group="FRMr5.1_1_2T0R",
    radio_type="AHSA",
    serial_number="EA203151100",
    pdu_port=_pdu_2.pdu_ports[2],
)
_ru5 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHPD",
    serial_number="1M192300105",
    pdu_port=_pdu_2.pdu_ports[3],
)
_abio = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="A.103",
    serial_number="L1211511280",
    rus=[_ru4, _ru5],
)
_abip = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIP",
    hardware_version="A.102",
    serial_number="L1233802904",
    rus=[_ru1, _ru2, _ru3],
)
_asil = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio, _abip],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1204107378",
)
_airscale = Airscale(common_units=[_asil])
_enb = RealEnb(
    system_module=_airscale,
    rms=[_ru1, _ru2, _ru3, _ru4, _ru5],
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.164.119", username="ute", password="ute"
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
    tl_cloud_topology="CLOUD_R4LA_REALRF_FV1",
)
