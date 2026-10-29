__maintainer__ = "Szymon Przybylak"
__team__ = "siso"
__email__ = "szymon.przybylak@nokia.com"
__owner_email__ = "szymon.przybylak@nokia.com"

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import ATEN
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection

_pdu_1 = Gude("10.42.168.107", [1, 2, 5, 6, 8, 9], "EPC", "8221-1")
_pdu_2 = Gude("10.42.169.5", [12], "EPC", "8220-1")


_rmod_1 = RU(
    radio_type=RadioTypes.AHFIB.value,
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="BL1909V001X",
    pdu_port=_pdu_1.pdu_ports[1],
)  # AHFIB_1
_rmod_2 = RU(
    radio_type=RadioTypes.AHFIB.value,
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="BL1909V001M",
    pdu_port=_pdu_1.pdu_ports[2],
)  # AHFIB_2
_rmod_3 = RU(
    radio_type=RadioTypes.AHEGB.value,
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="K9191313477",
    pdu_port=_pdu_1.pdu_ports[5],
)  # AHEGB_1
_rmod_4 = RU(
    radio_type=RadioTypes.AHEGB.value,
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="K9191315108",
    pdu_port=_pdu_1.pdu_ports[6],
)  # AHEGB_2
_rmod_5 = RU(
    radio_type=RadioTypes.AHPMDA.value,
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="K9190542833",
    pdu_port=_pdu_1.pdu_ports[8],
)  # AHPMDA_1
_rmod_6 = RU(
    radio_type=RadioTypes.AHPMDA.value,
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="K9190542832",
    pdu_port=_pdu_1.pdu_ports[9],
)  # AHPMDA_2

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    serial_number="L1164505613",
    pdu_port=_pdu_2.pdu_ports[12],
    rus=[_rmod_6],
)

_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIO",
    serial_number="L1211505185",
    pdu_port=_pdu_2.pdu_ports[12],
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
)
_fsp_3 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIA",
    serial_number="L1164500940",
    pdu_port=_pdu_2.pdu_ports[12],
    rus=[_rmod_5],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_2.pdu_ports[12],
    hardware_type="ASIB",
    serial_number="L1182413255",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
        _rmod_6,
    ],
    oam_ip=NetworkAddress("10.42.174.151"),
    instance_id=1509,
)


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.184.148", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
)

__all__ = ["tl"]
