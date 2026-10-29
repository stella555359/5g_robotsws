__maintainer__ = "Jakub Ozierski"
__email__ = "jakub.ozierski@nokia.com"
# BTS ID: 9003
# BTS name: Kokosz2

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


_pdu_1 = Gude("10.42.80.235", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")
_pdu_2 = Gude("10.42.80.31", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")

_rmod_1 = RU(
    ru_hw_group="RF.CHB0.trunk.20230510.045",
    radio_type="AEHC",
    serial_number="L1210604533",
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_2 = RU(
    ru_hw_group="RF.CHB0.trunk.20230510.045",
    radio_type="AEHC",
    serial_number="L1210604536",
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_3 = RU(
    ru_hw_group="RF.CHB0.trunk.20230510.045",
    radio_type="AEHC",
    serial_number="L1210604529",
    pdu_port=_pdu_2.pdu_ports[1],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="L1201605740",
    rus=[_rmod_1],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="L1203802118",
    rus=[_rmod_2],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="L1201207207",
    rus=[_rmod_3],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASIK",
    hardware_version="474021A.102",
    serial_number="EA202251914",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.42.20.208"),
    instance_id=9003,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.250.219", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_N_ASIK_3ABIL_3AEHC",
)

__all__ = ["tl"]

