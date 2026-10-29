__maintainer__ = "Jakub Ozierski"
__email__ = "jakub.ozierski@nokia.com"
# BTS ID: 8087
# BTS Name: Paracopter

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

_pdu_1 = Gude("10.42.80.142", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")

_rmod_1 = RU(
    ru_hw_group="RF.FRM5.trunk.20230813.003",
    serial_number="F7173332440",
    radio_type="FRHC",
    pdu_port=_pdu_1.pdu_ports[10],
)
_rmod_2 = RU(
    ru_hw_group="RF.FRM5.trunk.20230813.003",
    serial_number="EA174211112",
    radio_type="AHIB",
    pdu_port=_pdu_1.pdu_ports[7],
)
_rmod_7 = RU(
    ru_hw_group="FRM33.32.R05D",
    serial_number="BL2048G1RE2",
    radio_type="AHLOA",
    pdu_port=_pdu_1.pdu_ports[6],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1233006454",
    rus=[_rmod_2],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIN",
    hardware_version="474824A.103",
    serial_number="L1213615760",
    rus=[_rmod_1],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIN",
    hardware_version="4474824A.102",
    serial_number="L1204906163",
    rus=[_rmod_7],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[12],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1224102504",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_7],
    oam_ip=NetworkAddress("10.42.20.92"),
    instance_id=8087,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.35", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_NL_ASIL_ABIQ_2ABIN_FRHC_AHIB_AHLOA",
)

__all__ = ["tl"]
