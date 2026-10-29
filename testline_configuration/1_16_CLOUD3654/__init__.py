__maintainer__ = "Jedrzej Grzelak"
__team__ = "siso"
__email__ = "jedrzej.grzelak@nokia.com"
__owner_email__ = "jedrzej.grzelak@nokia.com"

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
    SshServiceDetails(addr="10.42.164.241", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.42.169.6", [3], "EPC", "")
_pdu_2 = Gude("10.42.168.104", [11], "EPC", "")
_pdu_3 = Gude("10.42.168.112", [4, 6], "EPC", "")
_pdu_4 = Gude("10.42.168.148", [1], "EPC", "")

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    serial_number="L1204104979",
    pdu_port=_pdu_2.pdu_ports[11],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="L1164413220",
    pdu_port=_pdu_2.pdu_ports[11],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    serial_number="L1211506476",
    pdu_port=_pdu_2.pdu_ports[11],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIB",
    serial_number="L1192405936",
)

_smod_1 = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="EA200262131",
    pdu_port=_pdu_3.pdu_ports[4],
)  # AHEGC
_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="EA200262091",
    pdu_port=_pdu_3.pdu_ports[6],
)  # AHEGC
_rmod_3 = RU(
    ru_hw_group="cMAAr6.1_8T8R",
    serial_number="1M203440035",
    pdu_port=_pdu_4.pdu_ports[1],
)  # AZQP

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3])

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
)

__all__ = ["tl"]
