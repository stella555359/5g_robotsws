__maintainer__ = "Jakub Kokoszka"
__email__ = "jakub.kokoszka@nokia.com"

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

_pdu_1 = Gude("10.42.199.212", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")

_rmod_2 = RU(
    radio_type="AHEH",
    ru_hw_group="RF.FRM5.trunk.20231107.008",
    serial_number="EA225054675",
    pdu_port=_pdu_1.pdu_ports[8],
)
_rmod_3 = RU(
    radio_type="AHEGB",
    ru_hw_group="RF.FRM5.trunk.20231107.008",
    serial_number="EA223661417",
    pdu_port=_pdu_1.pdu_ports[2],
)
_rmod_4 = RU(
    radio_type="AHEGB",
    ru_hw_group="RF.FRM5.trunk.20231107.008",
    serial_number="EA223661240",
    pdu_port=_pdu_1.pdu_ports[1],
)
_rmod_5 = RU(
    radio_type="AHEH",
    ru_hw_group="RF.FRM5.trunk.20231107.008",
    serial_number="EA225054628",
    pdu_port=_pdu_1.pdu_ports[7],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1232004051",
    rus=[_rmod_2],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1224505306",
    rus=[_rmod_5],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1163511586",
    rus=[_rmod_3, _rmod_4],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="DH222244624",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_2, _rmod_3, _rmod_4, _rmod_5],
    oam_ip=NetworkAddress("10.42.182.249"),
    instance_id=8545,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.47", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_NL_ASIL_ABIP_ABIO_ABIA_2AHEH_2AHEGB",
)

__all__ = ["tl"]
