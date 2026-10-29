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
    SshServiceDetails(addr="10.43.54.114", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude("10.41.155.253", [3], "MYCOMP", "8221-1")
_pdu_2 = Gude("10.41.155.235", [1, 2, 6], "MYCOMP", "8221-1")

# _pdu_3 = Gude("10.42.169.166", [2, 3, 4, 5, 10], "MYCOMP", "8221-1")

_fsp_1 = CapacityUnit(
    addr="192.168.255.1",
    hardware_type="ASOE AirScale Core",
    serial_number="EA212356641",
    product_code="475587A.101",
    pdu_port=_pdu_1.pdu_ports[3],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASOE AirScale Core",
    hardware_version="EA212356641",
    serial_number="475587A.101",
)

_smod_1 = Airscale([_fct_1])
# _smod_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="RF.FRM5.trunk.20230507.001",
    serial_number="6Q202002518",
    pdu_port=_pdu_2.pdu_ports[2],
    product_code="474052A.101",
    radio_type="AZNC",
)
_rmod_2 = RU(
    ru_hw_group="RF.FRM5.trunk.20230507.001",
    serial_number="BL2108V05DK",
    pdu_port=_pdu_2.pdu_ports[6],
    product_code="474216A.101",
    radio_type="AHFIB",
)
_rmod_3 = RU(
    ru_hw_group="RF.URM6.LT22.20230504.005",
    serial_number="AH222601879",
    pdu_port=_pdu_2.pdu_ports[1],
    product_code=" 475432A.101",
    radio_type="AZHL",
)

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3])

tl = TestLine(
    test_pc=_test_pc_1,
    # test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1],
)

__all__ = ["tl"]
