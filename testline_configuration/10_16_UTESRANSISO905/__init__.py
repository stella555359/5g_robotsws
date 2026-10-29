__maintainer__ = "Dawid Bak"
__team__ = "siso"
__email__ = "dawid.bak@nokia.com"
__owner_email__ = "dawid.bak@nokia.com"

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.gnb.networkaddress import NetworkAddress

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.184.22", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.42.169.6", [4], "EPC", "8221-1")
_pdu_2 = Gude("10.42.168.103", [12], "EPC", "8221-1")
_pdu_3 = Gude("10.42.168.104", [1, 5], "EPC", "8221-1")
_pdu_4 = Gude("10.42.169.14", [3], "EPC", "8221-1")
_pdu_5 = Gude("10.42.168.107", [2], "EPC", "8221-1")

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="L1163615565",
    pdu_port=_pdu_1.pdu_ports[4],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    serial_number="L1163618826",
    pdu_port=_pdu_1.pdu_ports[4],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    serial_number="L1163618842",
    pdu_port=_pdu_1.pdu_ports[4],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIB",
    serial_number="L1192405974",
)

_smod_1 = Flexi([_fct_1])

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    serial_number="EA174410446",  # AHIB
    pdu_port=_pdu_2.pdu_ports[12],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="EA174113448",  # AHFB
    pdu_port=_pdu_3.pdu_ports[1],
)

_rmod_3 = RU(
    ru_hw_group="FRMTDr5.1b_1_2T2R_LP",
    serial_number="AH203300862",  # AZRC
    pdu_port=_pdu_3.pdu_ports[5],
)

_rmod_4 = RU(
    ru_hw_group="FRMTDr5.1_1_4T4R",
    serial_number="RW191801761",  # AZHA
    pdu_port=_pdu_4.pdu_ports[3],
)

_rmod_5 = RU(
    ru_hw_group="FRMTDr5.1_1_4T4R",
    serial_number="BL1909V001M",  # AHFIB
    pdu_port=_pdu_5.pdu_ports[2],
)

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
    ],
    oam_ip=NetworkAddress("10.42.174.36"),
    instance_id=1430,
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
)

__all__ = ["tl"]
