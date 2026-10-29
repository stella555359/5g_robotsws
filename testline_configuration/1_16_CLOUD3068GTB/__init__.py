__maintainer__ = "Piotr Baranowski"
__team__ = "siso"
__email__ = "piotr.baranowski@nokia.com"
__owner_email__ = "piotr.baranowski@nokia.com"

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
from taf.config.testline.radio import RU
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.165.85", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.42.168.107", [1, 2, 3, 4, 5, 6, 7, 8, 9], "EPC", "8221-1")
_pdu_2 = Gude("10.42.169.6", [7], "EPC", "8220-1")

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    serial_number="L1164505613",
    pdu_port=_pdu_2.pdu_ports[7],
)
_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIA",
    serial_number="L1164408974",
    pdu_port=_pdu_2.pdu_ports[7],
)
_fsp_3 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIA",
    serial_number="L1164500940",
    pdu_port=_pdu_2.pdu_ports[7],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_2.pdu_ports[7],
    hardware_type="ASIB",
    serial_number="L1182413255",
)

_smod_1 = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="BL1909V001X",
    pdu_port=_pdu_1.pdu_ports[1],
)  # AHFIB_1
_rmod_2 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="BL1909V001M",
    pdu_port=_pdu_1.pdu_ports[2],
)  # AHFIB_2
_rmod_3 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="BL1909V001Y",
    pdu_port=_pdu_1.pdu_ports[3],
)  # AHFIB_3
_rmod_4 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="K9191313965",
    pdu_port=_pdu_1.pdu_ports[4],
)  # AHEGB_1
_rmod_5 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="K9191313477",
    pdu_port=_pdu_1.pdu_ports[5],
)  # AHEGB_2
_rmod_6 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="K9191315108",
    pdu_port=_pdu_1.pdu_ports[6],
)  # AHEGB_3
_rmod_7 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="K9190542925",
    pdu_port=_pdu_1.pdu_ports[7],
)  # AHPMDA_1
_rmod_8 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="K9190542833",
    pdu_port=_pdu_1.pdu_ports[8],
)  # AHPMDA_2
_rmod_9 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="K9190542832",
    pdu_port=_pdu_1.pdu_ports[9],
)  # AHPMDA_3

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
        _rmod_6,
        _rmod_7,
        _rmod_8,
        _rmod_9,
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
)

__all__ = ["tl"]
