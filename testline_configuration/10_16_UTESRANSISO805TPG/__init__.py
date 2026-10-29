__maintainer__ = "Piotr Kurzeja"
__team__ = "siso"
__email__ = "piotr.kurzeja@nokia.com"
__owner_email__ = "piotr.kurzeja@nokia.com"

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
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ald import ALD
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.attenuator import TopYoung, JFW
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection


_pdu_1 = Gude("10.44.167.125", [1], "EPC", "")
_pdu_2 = Gude("10.44.167.110", [1, 2], "EPC", "")
_pdu_3 = Gude("10.44.167.111", [11, 12], "EPC", "")
_pdu_4 = Gude("10.44.167.112", [8], "EPC", "")
_pdu_5 = Gude("10.44.167.113", [1, 2, 3, 4, 5, 9, 10, 11], "EPC", "")
_pdu_6 = Gude("10.44.167.114", [11, 12], "EPC", "")
_pdu_7 = Gude("10.44.167.102", [3], "EPC", "")


_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="1M193119539",
    pdu_port=_pdu_2.pdu_ports[2],
    radio_type="AHCA",
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="AS201205506",
    pdu_port=_pdu_3.pdu_ports[12],
    radio_type="AHCA",
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="AS201205510",
    pdu_port=_pdu_2.pdu_ports[1],
    radio_type="AHCA",
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="EA223152863",
    pdu_port=_pdu_4.pdu_ports[8],
    radio_type="AHEGC",
)
_rmod_5 = RU(
    ru_hw_group="cMAAr5.1_16T16R",
    serial_number="EA222658236",
    pdu_port=_pdu_6.pdu_ports[11],
    radio_type="AHEGC",
)
_rmod_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="EA223152992",
    pdu_port=_pdu_5.pdu_ports[9],
    radio_type="AHEGC",
)
_rmod_7 = RU(
    ru_hw_group="cMAAr5.1_16T16R",
    serial_number="EA222658238",
    pdu_port=_pdu_5.pdu_ports[1],
    radio_type="AHEGC",
)
_rmod_8 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="EA200262126",
    pdu_port=_pdu_5.pdu_ports[2],
    radio_type="AHEGC",
)
_rmod_9 = RU(
    ru_hw_group="cMAAr5.1_16T16R",
    serial_number="EA222658235",
    pdu_port=_pdu_5.pdu_ports[4],
    radio_type="AHEGC",
)
_rmod_10 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="K9200910409",
    pdu_port=_pdu_5.pdu_ports[10],
    radio_type="AHPB",
)
_rmod_11 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="K9200910380",
    pdu_port=_pdu_3.pdu_ports[11],
    radio_type="AHPB",
)
_rmod_12 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="K9200910322",
    pdu_port=_pdu_5.pdu_ports[11],
    radio_type="AHPB",
)
_rmod_13 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="1M223207228",
    pdu_port=_pdu_6.pdu_ports[12],
    radio_type="AEQE",
)
_rmod_14 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="1M204448310",
    pdu_port=_pdu_5.pdu_ports[5],
    radio_type="AEQE",
)
_rmod_15 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="1M222345982",
    pdu_port=_pdu_5.pdu_ports[3],
    radio_type="AEQE",
)
_rmod_16 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="EA233050884",
    pdu_port=_pdu_7.pdu_ports[3],
    radio_type="AHPDA",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    serial_number="L1223309884",
    pdu_port=_pdu_1.pdu_ports[1],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    serial_number="L1223309822",
    pdu_port=_pdu_1.pdu_ports[1],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIO",
    serial_number="DH224241428",
    pdu_port=_pdu_1.pdu_ports[1],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    serial_number="L1223400411",
    pdu_port=_pdu_1.pdu_ports[1],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIB",
    serial_number="L1212813565",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIB",
    serial_number="L1213102686",
)

_node_1 = Airscale([_fct_1])
_node_2 = Airscale([_fct_2])


_enb_sbts_1 = RealEnb(
    system_module=_node_1,
    rms=[_rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9, _rmod_16],
    global_bts_id=1104,
    instance_id=1104,
    oam_ip=NetworkAddress("10.44.166.96"),
)

_enb_sbts_2 = RealEnb(
    system_module=_node_2,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_10,
        _rmod_11,
        _rmod_12,
        _rmod_13,
        _rmod_14,
        _rmod_15,
    ],
    master=_enb_sbts_1,
)

_enb_sbts_1.slave = _enb_sbts_2
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.40.100", username="ute"
    ),
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
    SshServiceDetails(addr="10.44.40.101", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.119"),
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
