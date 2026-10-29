__maintainer__ = "Jakub Ozierski"
__email__ = "jakub.ozierski@nokia.com"
# BTS ID: 5007
# Name: Kopytko

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude, ATEN
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


_pdu_1 = Gude("10.42.199.225", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")
_pdu_2 = Gude("10.42.80.33", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")

_rmod_1 = RU(
    radio_type="AREA",
    ru_hw_group="RF.FRM5.23R4.20231114.002",
    serial_number="EA191771361",
    pdu_port=_pdu_1.pdu_ports[11],
)
_rmod_2 = RU(
    radio_type="FXED",
    ru_hw_group="FRM33.32.R10D",
    serial_number="F7154733693",
    pdu_port=_pdu_1.pdu_ports[12],
)
_rmod_3 = RU(
    radio_type="FXDB",
    ru_hw_group="VEG23.23.R01D",
    serial_number="F7161110121",
    pdu_port=_pdu_1.pdu_ports[10],
)
_rmod_4 = RU(
    radio_type="FXDB",
    ru_hw_group="VEG23.23.R01D",
    serial_number="F7163707409",
    pdu_port=_pdu_1.pdu_ports[9],
)
_rmod_5 = RU(
    radio_type="AWHHD",
    ru_hw_group="RF.MRM6.19T23R4.20231103.004",
    serial_number="EB2237R0304",
    pdu_port=_pdu_2.pdu_ports[6],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171716664",
    rus=[_rmod_5],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173406377",
    rus=[_rmod_2],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173313340",
    rus=[_rmod_2, _rmod_1],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173602160",
    rus=[_rmod_3, _rmod_4],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173602116",
    rus=[_rmod_3],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIA",
    hardware_version="473095A.202",
    serial_number="K9180507704",
)
_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIA",
    hardware_version="473095A.101",
    serial_number="L1162214172",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_5],
    oam_ip=NetworkAddress("10.42.182.115"),
    instance_id=5007,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_3, _rmod_4],
    master=_enb_sbts_1
)

_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.62.243", username="ute"),
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
    SshServiceDetails(addr="10.42.62.235", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_LWG_1ASIA_3ABIA_1ASIA_2ABIA_1AREA_1FXED_2FXDB_1AWHHD",
)

__all__ = ["tl"]
