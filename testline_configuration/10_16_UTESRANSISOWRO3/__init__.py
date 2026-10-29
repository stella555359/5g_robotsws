__maintainer__ = "Piotr Baranowski"
__team__ = "CRT"
__email__ = "piotr.baranowski@nokia.com"

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

_pdu_1 = Gude("10.44.167.151", [6], "EPC", "8220-1")
_pdu_2 = Gude("10.44.167.134", [1, 2, 3, 4], "EPC", "8221-1")
_pdu_3 = Gude("10.44.167.144", [2, 3, 4, 5], "EPC", "8221-1")

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGB",
    serial_number="EA203762015",
    pdu_port=_pdu_2.pdu_ports[1],
)  # AHEGB_1
_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGB",
    serial_number="EA203762116",
    pdu_port=_pdu_2.pdu_ports[2],
)  # AHEGB_2
_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGB",
    serial_number="EA203762227",
    pdu_port=_pdu_2.pdu_ports[3],
)  # AHEGB_3
_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGB",
    serial_number="EA203762229",
    pdu_port=_pdu_2.pdu_ports[4],
)  # AHEGB_4
_rmod_5 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FRGU",
    serial_number="AS174414946",
    pdu_port=_pdu_3.pdu_ports[3],
)  # FRGU_1
_rmod_6 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FRGU",
    serial_number="K9171606840",
    pdu_port=_pdu_3.pdu_ports[4],
)  # FRGU_2
_rmod_7 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FXED",
    serial_number="F17154733698",
    pdu_port=_pdu_3.pdu_ports[5],
)  # FXED
_rmod_8 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="AHEGC",
    serial_number="EA222658234",
    pdu_port=_pdu_3.pdu_ports[2],
)  # AHEGC

_fsp_1 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIQ",
    serial_number="L1232208172",
    pdu_port=_pdu_1.pdu_ports[6],
)
_fsp_2 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIP",
    serial_number="L1234003105",
    pdu_port=_pdu_1.pdu_ports[6],
)
_fsp_3 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIP",
    serial_number="L1231803517",
    pdu_port=_pdu_1.pdu_ports[6],
)
_fsp_4 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    serial_number="L1204008417",
    pdu_port=_pdu_1.pdu_ports[6],
)
_fsp_5 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIL",
    serial_number="L1185109723",
    pdu_port=_pdu_1.pdu_ports[6],
)
_fsp_6 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIA",
    serial_number="L1171611622",
    pdu_port=_pdu_1.pdu_ports[6],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233505224",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASIL",
    hardware_version="474767A.102",
    serial_number="L1213010566",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_3],
    oam_ip=NetworkAddress("10.42.24.69"),
    instance_id=1206,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_2, _rmod_4, _rmod_5, _rmod_6],
    master=_enb_sbts_1,
    oam_ip=NetworkAddress("10.42.24.69"),
    instance_id=1206,
)

_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.121.139", username="ute"),
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
    SshServiceDetails(addr="10.42.17.62", username="ute"),
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
    tl_cloud_topology="CLOUD_10_16_UTESRANSISOWRO3",
    pdus=[_pdu_1, _pdu_2, _pdu_3],
)

__all__ = ["tl"]

# _test_pc_1 = TestPc(
#     SshServiceDetails(addr="10.42.121.139", username="ute"),
#     connections=[NetworkAddress(v4="192.168.255.126")],
# )
#
# _pdu_1 = Gude("10.44.167.151", [1, 2, 7, 8, 9, 11, 12], "EPC", "8221-1")
# #_pdu_3 = ATEN("10.42.169.16", [3, 5], "ATEN", "")
#
# _fsp_1 = CapacityUnit(
#     addr="192.168.254.125",
#     hardware_type="ABIQ",
#     serial_number="L1232208160",
#     pdu_port=_pdu_1.pdu_ports[12],
# )
#
# _fct_1 = CommonUnit(
#     SshServiceDetails(
#         addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
#     ),
#     capacity_units=[_fsp_1],
#     pdu_port=_pdu_1.pdu_ports[12],
#     hardware_type="ASIM",
#     serial_number="L1230613811",
# )
#
# _smod_1 = Airscale([_fct_1])
#
# _rmod_1 = RU(
#     ru_hw_group="FRMr6.2a_4T4R",
#     radio_type="AHEGHA",
#     serial_number="BL2309H6005",
#     pdu_port=_pdu_1.pdu_ports[1],
# )
# _rmod_2 = RU(
#     ru_hw_group="FRMr6.2a_4T4R",
#     radio_type="AHEGHA",
#     serial_number="BL2310H601V",
#     pdu_port=_pdu_1.pdu_ports[2],
# )
# _rmod_3 = RU(
#     ru_hw_group="FRMr6.2_4T4R",
#     radio_type="AHFII",
#     serial_number="BL2221N4056",
#     pdu_port=_pdu_1.pdu_ports[7],
# )
# _rmod_4 = RU(
#     ru_hw_group="FRMr5.1a_4T4R",
#     radio_type="AHEGB",
#     serial_number="	EA203762015",
#     pdu_port=_pdu_1.pdu_ports[8],
# )
# _rmod_5 = RU(
#     ru_hw_group="FRMr5.1a_4T4R",
#     radio_type="AHFIA",
#     serial_number="K9174905879",
#     pdu_port=_pdu_1.pdu_ports[11],
# )
# _rmod_6 = RU(
#     ru_hw_group="FRMr5.1_1_4T4R",
#     radio_type="AHHB",
#     serial_number="	EA221250900",
#     pdu_port=_pdu_1.pdu_ports[9],
# )
#
# _enb_sbts_1 = RealEnb(
#     system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6]
# )
#
# tl = TestLine(
#     test_pc=_test_pc_1,
#     test_pcs=[_test_pc_1],
#     enbs=[_enb_sbts_1],
# )
#
# __all__ = ["tl"]
