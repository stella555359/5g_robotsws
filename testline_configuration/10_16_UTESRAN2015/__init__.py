__maintainer__ = "Jakub Ozierski"
__email__ = "jakub.ozierski@nokia.com"

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


_pdu_1 = Gude("10.42.80.216", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")

_rmod_1 = RU(
    radio_type="FRHF",
    ru_hw_group="FRM33.32.R11D",
    serial_number="F7153638205",
    pdu_port=_pdu_1.pdu_ports[2],
)
_rmod_2 = RU(
    radio_type="FRGU",
    ru_hw_group="FRM33.32.R11D",
    serial_number="K9170432310",
    pdu_port=_pdu_1.pdu_ports[1],
)
_rmod_3 = RU(
    radio_type="FXEB",
    ru_hw_group="VEG23.23.R04D",
    serial_number="K9153061381",
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_4 = RU(
    radio_type="FXEB",
    ru_hw_group="VEG23.23.R04D",
    serial_number="K9153061350",
    pdu_port=_pdu_1.pdu_ports[4],
)

_fsp_1 = CapacityUnit(
    addr="fd5f:4268:2387:a881:0040:43ff:fe80:0101",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171213726",
    rus=[_rmod_1, _rmod_2],
)
_fsp_2 = CapacityUnit(
    addr="fd5f:4268:2387:a881:0040:43ff:fe80:0201",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9172557710",
    rus=[_rmod_3, _rmod_4],
)
_fsp_3 = CapacityUnit(
    addr="fd5f:4268:2387:a881:0040:43ff:fe80:0300",
    hardware_type="ABIN",
    hardware_version="474824B.101",
    serial_number="L1224006502",
    rus=[],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="DH222244646",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_2, _rmod_1, _rmod_3, _rmod_4],
    oam_ip=NetworkAddress("10.42.182.121"),
    instance_id=5013,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.250.134", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_LWG_1ASIL_2ABIA_1ABINgit _1FRGU_1FRHF_2FXEB",
)

__all__ = ["tl"]
