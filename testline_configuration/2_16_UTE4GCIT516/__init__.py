__maintainer__ = "Przemyslaw Krolikowski"
__owner_email__ = "I_MN_RAN_TRUNK_SG_WRO2@internal.nsn.com"
__email__ = "przemyslaw.krolikowski@nokia.com"

from taf.config.testline import Connection
from taf.config.testline.pdu import ATEN
from taf.config.testline.radio import RU
from taf.config.testline.airscale import Airscale, CoreUnit
from taf.config.testline.enb import RealEnb
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.testpc import TestPc
from taf.config.testline.testline import TestLine

__all__ = ["tl"]

_pdu_1 = ATEN(addr="10.42.169.48", port_numbers=[1, 2, 3, 5, 8])
_pdu_2 = ATEN(addr="10.42.169.181", port_numbers=[1])

_ru1 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type="AREA",
    serial_number="EA191872441",
    pdu_port=_pdu_1.pdu_ports[1],
)
_ru2 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type="AHLJA",
    serial_number="K9192601254",
    pdu_port=_pdu_1.pdu_ports[2],
)
_ru3 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHCA",
    serial_number="AS204801899",
    pdu_port=_pdu_1.pdu_ports[3],
)
_ru4 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHHB",
    serial_number="EA192778932",
    pdu_port=_pdu_1.pdu_ports[8],
)
_ru5 = RU(
    ru_hw_group="FRMTDr5.1b_1_2T2R_LP",
    radio_type="AZRB",
    serial_number="1M183023630",
    pdu_port=_pdu_2.pdu_ports[1],
)

_asoe = CoreUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASOE",
    hardware_version="A.101",
    serial_number="EA212356652",
    rus=[_ru1, _ru2, _ru3, _ru4, _ru5],
)
_airscale = Airscale(core_units=[_asoe])
_enb = RealEnb(
    system_module=_airscale,
    rms=[_ru1, _ru2, _ru3, _ru4, _ru5],
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.164.116", username="ute", password="ute"
    ),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_enb.system_module.core_units[0],
        )
    ],
)

tl = TestLine(
    test_pc=_test_pc,
    enbs=[_enb],
    tl_cloud_topology="CLOUD_R4E_REALRF_TL01",
)
