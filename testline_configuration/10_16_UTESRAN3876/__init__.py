__maintainer__ = "Jakub Ozierski"
__email__ = "jakub.ozierski@nokia.com"
# BTS ID: 5076
# Name: Abiolog

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

_pdu_1 = Gude("10.42.80.117", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_2 = Gude("10.42.80.142", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")

_rmod_1 = RU(
    radio_type="FRHC",
    ru_hw_group="FRM32.13.R14",
    serial_number="F7173820992",
    pdu_port=_pdu_2.pdu_ports[11],
)

_rmod_2 = RU(
    radio_type="AHCA",
    ru_hw_group="RF.FRM5.trunk.20220408.017",
    serial_number="L1174604140",
    pdu_port=_pdu_1.pdu_ports[8],
)

_rmod_3 = RU(
    radio_type="AHIB",
    ru_hw_group="RF.FRM5.trunk.20220408.017",
    serial_number="EA174211110",
    pdu_port=_pdu_1.pdu_ports[9],
)

_rmod_4 = RU(
    radio_type="AHEH",
    ru_hw_group="RF.FRM5.trunk.20220408.017",
    serial_number="EA203856875",
    pdu_port=_pdu_1.pdu_ports[10],
)

_rmod_5 = RU(
    radio_type="AHEB",
    ru_hw_group="RF.FRM5.trunk.20220408.017",
    serial_number="EA194450466",
    pdu_port=_pdu_1.pdu_ports[6],
)

_rmod_6 = RU(
    radio_type="AHEB",
    ru_hw_group="RF.FRM5.trunk.20220408.017",
    serial_number="L1181107577",
    pdu_port=_pdu_1.pdu_ports[7],
)

_rmod_7 = RU(
    radio_type="AHLOA",
    ru_hw_group="RF.FRM5.trunk.20220408.017",
    serial_number="BL2027G1AU4",
    pdu_port=_pdu_2.pdu_ports[9],
)

_fsp_1 = CapacityUnit(
    addr="fd5f:4268:2387:a8e::3:123d",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1172903056",
    rus=[_rmod_5],
)
_fsp_2 = CapacityUnit(
    addr="fd5f:4268:2387:a881:0040:43ff:fe80:0201",
    hardware_type="ABIN",
    hardware_version="474824A.102",
    serial_number="L1204906189",
    rus=[_rmod_1, _rmod_7],
)
_fsp_3 = CapacityUnit(
    addr="fd5f:4268:2387:a881:0040:43ff:fe80:0301",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1210804459",
    rus=[_rmod_6],
)
_fsp_4 = CapacityUnit(
    addr="fd5f:4268:2387:a8e::3:223d",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173708025",
    rus=[_rmod_4],
)
_fsp_5 = CapacityUnit(
    addr="fd5f:4268:2387:a8e::3:233d",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9172554272",
    rus=[_rmod_2],
)
_fsp_6 = CapacityUnit(
    addr="fd5f:4268:2387:a8e::3:243d",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9172554346",
    rus=[_rmod_3],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[12],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1201902118",
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1171407024",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_5, _rmod_6, _rmod_7],
    oam_ip=NetworkAddress("10.42.20.131"),
    instance_id=5076,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_2, _rmod_3, _rmod_4],
    master=_enb_sbts_1,
)

_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.62.242", username="ute"),
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
    SshServiceDetails(addr="10.42.133.187", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_NLWG_1ASIB_1ABIA_1ABIN_1ABIO_1ASIA_3ABIA_1AHCA_1AHIB_1AHEH_2AHEB_1AHLOA_1FRHC",
)

__all__ = ["tl"]
