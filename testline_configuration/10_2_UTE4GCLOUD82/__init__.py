__maintainer__ = "Durga Kant Yadav"
__owner_email__ = "durga.yadav@nokia.com"
__team__ = "RANPzBLRSG03CPKPI"
__email__ = "durga.yadav@nokia.com"

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.pdu import ATEN
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
    SshServiceDetails(addr="10.41.209.49", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude("10.41.155.233", [7], "MYCOMP", "8221-1")
_pdu_2 = Gude("10.41.155.250", [1], "MYCOMP", "8221-1")
# _pdu_3 = Gude("10.42.169.166", [2, 3, 4, 5, 10], "MYCOMP", "8221-1")

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIC",
    serial_number="6Q191131762",
    product_code="474723A.101",
    pdu_port=_pdu_1.pdu_ports[7],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIBA",
    hardware_version="474408A.102",
    serial_number="L1194603935",
)

_smod_1 = Airscale([_fct_1])
# _smod_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="1M192906932",
    pdu_port=_pdu_2.pdu_ports[1],
    product_code="474715A.101",
    radio_type="AAHF",
)



_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1])


tl = TestLine(
    test_pc=_test_pc_1,
    # test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1],
)

__all__ = ["tl"]
