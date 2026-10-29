__maintainer__ = "Szymon Romanowski"
__email__ = "szymon.romanowski@nokia.com"

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
from taf.config.testline import Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc


_pdu_1 = Gude("10.44.200.229", [1, 9], "EPC", "8220-1")
_pdu_2 = Gude("10.44.200.226", [5], "EPC", "8220-1")
_pdu_3 = Gude("10.44.200.146", [6], "EPC", "8220-1")
_pdu_4 = Gude("10.44.200.147", [6], "EPC", "8220-1")
_pdu_5 = Gude("10.44.177.145", [7, 8], "EPC", "8041-1")
_pdu_6 = Gude("10.44.177.195", [1, 2, 3, 4, 7, 8], "EPC", "8041-1")

_pdus = [_pdu_1, _pdu_2, _pdu_3, _pdu_4, _pdu_5, _pdu_6]

_rmod_1 = RU(
    radio_type="AHFIB",
    ru_hw_group="RF.FRM5",
    serial_number="BL2031V0F3N",
    pdu_port=_pdu_6.pdu_ports[2],
)
_rmod_2 = RU(
    radio_type="AHFIB",
    ru_hw_group="RF.FRM5",
    serial_number="K9183224636",
    pdu_port=_pdu_6.pdu_ports[7],
)
_rmod_3 = RU(
    radio_type="AHFIB",
    ru_hw_group="RF.FRM5",
    serial_number="BL1911V00BX",
    pdu_port=_pdu_5.pdu_ports[7],
)
_rmod_4 = RU(
    radio_type="AEHC",
    ru_hw_group="RF.CHB0",
    serial_number="AH234900470",
    pdu_port=_pdu_1.pdu_ports[9],
)
_rmod_5 = RU(
    radio_type="AEHC",
    ru_hw_group="RF.CHB0",
    serial_number="K9221730198",
    pdu_port=_pdu_1.pdu_ports[1],
)
_rmod_6 = RU(
    radio_type="AEHC",
    ru_hw_group="RF.CHB0",
    serial_number="L1210604533",
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_7 = RU(
    radio_type="AHLOA",
    ru_hw_group="RF.FRM5",
    serial_number="BL1930G11OF",
    pdu_port=_pdu_5.pdu_ports[8],
)
_rmod_8 = RU(
    radio_type="AHLOA",
    ru_hw_group="RF.FRM5",
    serial_number="BL1930G11NM",
    pdu_port=_pdu_6.pdu_ports[1],
)
_rmod_9 = RU(
    radio_type="AHLOA",
    ru_hw_group="RF.FRM5",
    serial_number="BL1934G10TP",
    pdu_port=_pdu_6.pdu_ports[8],
)
_rmod_10 = RU(
    radio_type="AHFIB",
    ru_hw_group="RF.FRM5",
    serial_number="BL2241V0CSR",
    pdu_port=_pdu_6.pdu_ports[4],
)
_rmod_11 = RU(
    radio_type="AHLOA",
    ru_hw_group="RF.FRM5",
    serial_number="K9190907512",
    pdu_port=_pdu_6.pdu_ports[3],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.105",
    serial_number="L1225111793",
    rus=[_rmod_7, _rmod_8],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214608179",
    rus=[_rmod_9, _rmod_11],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171212641",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_10],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.32",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233803089",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1234205694",
    rus=[_rmod_1, _rmod_2],
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233803088",
    rus=[_rmod_3, _rmod_10],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_4.pdu_ports[6],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1234901974",
)
_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_3.pdu_ports[6],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1234901994",
)
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_7, _rmod_8, _rmod_9, _rmod_10, _rmod_11],
    oam_ip=NetworkAddress("10.42.87.27"),
    instance_id=100795,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9, _rmod_10, _rmod_11],
    master=_enb_sbts_1,
)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.156.54", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(interface="eth1",
                   device=_enb_sbts_1.system_module.common_units[0],
                   interface_type="lmp",
                   ),
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.44.156.55", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(interface="eth1",
                   device=_enb_sbts_2.system_module.common_units[0],
                   interface_type="lmp",
                   ),
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NLG_ASIL_2ABIO_ABIA_ASIL_3ABIP_4AHFIB_2AEHC_4AHLOA",
)

__all__ = ["tl"]
