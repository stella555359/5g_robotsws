__maintainer__ = "Agata Skorasinska"
__team__ = "siso"
__email__ = "agata.skorasinska@nokia.com"

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

_pdu_1 = Gude("10.42.168.99", [1, 2], "EPC", "8221-1")
_pdu_2 = Gude("10.42.169.187", [1, 7, 9, 10], "EPC", "8221-1")
_pdu_3 = Gude("10.42.168.25", [3], "EPC", "8221-1")
_pdu_4 = Gude("10.42.168.17", [1, 4], "EPC", "8220-1")
_pdu_5 = Gude("10.42.169.188", [4, 12], "EPC", "8221-1")
_pdus = [_pdu_1, _pdu_2, _pdu_3, _pdu_4, _pdu_5]

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL2235G14IZ",
    pdu_port=_pdu_4.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL2116G1CGS",
    pdu_port=_pdu_4.pdu_ports[4],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL2106G10IZ",
    pdu_port=_pdu_5.pdu_ports[12],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="BL2032V0HMI",
    pdu_port=_pdu_5.pdu_ports[4],
)
_rmod_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="K9181046163",
    pdu_port=_pdu_3.pdu_ports[3],
)
_rmod_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="K9180218186",
    pdu_port=_pdu_2.pdu_ports[7],
)
_rmod_16 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVHA",
    serial_number="L1250103453",
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_17 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVHA",
    serial_number="L1250103455",
    pdu_port=_pdu_2.pdu_ports[10],
)
_rmod_18 = RU(
    ru_hw_group="cMAAr7.1_64T64R",
    radio_type="AVHA",
    serial_number="L1250103454",
    pdu_port=_pdu_2.pdu_ports[9],
)
_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    serial_number="DH222246695",
    pdu_port=_pdu_1.pdu_ports[1],
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_fsp_2 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIA",
    serial_number="L1173007005",
    pdu_port=_pdu_1.pdu_ports[1],
    rus=[_rmod_4, _rmod_5, _rmod_6],
)
_fsp_3 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIP",
    serial_number="L1232807088",
    pdu_port=_pdu_1.pdu_ports[2],
    rus=[_rmod_16, _rmod_17, _rmod_18],
)
_fsp_4 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIP",
    serial_number="L1234008459",
    pdu_port=_pdu_1.pdu_ports[2],
    rus=[_rmod_4, _rmod_5, _rmod_6],
)
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIM",
    serial_number="L1234206319",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIM",
    serial_number="L1234204985",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.42.175.38"),
    instance_id=1383,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_4, _rmod_5, _rmod_6],
    master=_enb_sbts_1,
)
_enb_sbts_1.slave = _enb_sbts_2

_bsc = BSC(
    name="asBSC24",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.42.91.107", username="SYSTEM", password="SYSTEM"
    ),
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.184.114", username="ute"),
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
    SshServiceDetails(addr="10.42.184.102", username="ute"),
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
    bscs=[_bsc],
    pdus=_pdus,
)

__all__ = ["tl"]
