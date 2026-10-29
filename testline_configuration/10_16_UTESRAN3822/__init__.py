__maintainer__ = "Jakub Ozierski"
__email__ = "jakub.ozierski@nokia.com"
# BTS ID: 8048
# BTS name: Sowa

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CoreUnit
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
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc


_pdu_1 = Gude("10.42.80.145", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")
_pdu_2 = Gude("10.42.80.195", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")
_pdus = [_pdu_1, _pdu_2]

_rmod_1 = RU(
    ru_hw_group="RF.ERM6.23R2.20230530.005",
    serial_number="1M203509826",
    radio_type="AZQO",
    pdu_port=_pdu_1.pdu_ports[12],
)

_rmod_2 = RU(
    ru_hw_group="RF.5GE4.23R2.20230602.004",
    serial_number="CV193700106",
    radio_type="AEQN",
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_3 = RU(
    ru_hw_group="RF.FRM5.23R2.20230531.002",
    serial_number="L1172402496",
    radio_type="AHCA",
    pdu_port=_pdu_1.pdu_ports[3],
)

_fct_1 = CoreUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASOE",
    hardware_version="475587A.102",
    serial_number="EA213153986",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_smod_1 = Airscale(core_units=[_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.42.20.228"),
    instance_id=8048,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.17", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.core_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_SRAN_NL_ASOE_AZQO_AEQN_AHCA",
)

__all__ = ["tl"]
