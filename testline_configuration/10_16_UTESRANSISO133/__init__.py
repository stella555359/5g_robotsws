__maintainer__ = "Krzysztof Pekala"
__team__ = "siso"
__email__ = "krzysztof.pekala@nokia.com"

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import DU, CU, ClassicalBts
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
from taf.config.testline.testpc import TestPc, Connection

_pdu_1 = Gude("10.44.167.155", [3, 4], "EPC", "8221-1")  # SM - 2xASIM
_pdu_2 = Gude("10.44.167.175", [10], "EPC", "8221-1")  # RM - 1xAHLOA
_pdu_3 = Gude("10.44.167.174", [4, 5, 6, 7, 8], "EPC", "8221-1")  # RM - 2xAHLOA, 3xAHFIB
_pdu_4 = Gude("10.44.167.176", [8, 9, 10], "EPC", "8221-1")  # RM - 1xAHLOA
_pdu_5 = Gude("10.44.167.228", [11], "EPC", "8221-1")  # AEHC
_pdu_6 = Gude("10.44.167.230", [1, 7], "EPC", "8221-1")  # 2xAEHC [1, 7]


_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL2004G104F",
    pdu_port=_pdu_3.pdu_ports[4],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL2004G104G",
    pdu_port=_pdu_3.pdu_ports[5],
)

_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL2004G104N",
    pdu_port=_pdu_2.pdu_ports[10],
)

_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="K9175143400",
    pdu_port=_pdu_4.pdu_ports[10],
)

_rmod_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="K9174419988",
    pdu_port=_pdu_4.pdu_ports[8],
)

_rmod_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="K9175116256",
    pdu_port=_pdu_4.pdu_ports[9],
)

_rmod_7 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="BL1919V00IW",
    pdu_port=_pdu_3.pdu_ports[7],
)

_rmod_8 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="K9183827305",
    pdu_port=_pdu_3.pdu_ports[6],
)

_rmod_9 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="K9174419985",
    pdu_port=_pdu_3.pdu_ports[8],
)

_rmod_10 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type="AEHC",
    serial_number="L1213401839",
    pdu_port=_pdu_6.pdu_ports[1],
)

_rmod_11 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type="AEHC",
    serial_number="L1213514392",
    pdu_port=_pdu_5.pdu_ports[11],
)

_rmod_12 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type="AEHC",
    serial_number="K9214727486",
    pdu_port=_pdu_6.pdu_ports[7],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    serial_number="L1204104982",
    pdu_port=_pdu_1.pdu_ports[3],
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    serial_number="L1172903004",
    pdu_port=_pdu_1.pdu_ports[3],
    rus=[_rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIP",
    serial_number="L1231800019",
    pdu_port=_pdu_1.pdu_ports[4],
    rus=[_rmod_10, _rmod_11, _rmod_12],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIP",
    serial_number="L1231800035",
    pdu_port=_pdu_1.pdu_ports[4],
   rus=[_rmod_5, _rmod_7, _rmod_8],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIP",
    serial_number="L1231800058",
    pdu_port=_pdu_1.pdu_ports[4],
    rus=[_rmod_4, _rmod_6, _rmod_9],
)
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    hardware_type="ASIM",
    serial_number="L1230610712",
    pdu_port=_pdu_1.pdu_ports[3],
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4, _fsp_5],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIM",
    serial_number="L1233406374",
)
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


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
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[
        _rmod_4,
        _rmod_5,
        _rmod_6,
        _rmod_7,
        _rmod_8,
        _rmod_9,
        _rmod_10,
        _rmod_11,
        _rmod_12,
    ],
    master=_enb_sbts_1,
)

_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.121.133", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.121.190", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
)

__all__ = ["tl"]
