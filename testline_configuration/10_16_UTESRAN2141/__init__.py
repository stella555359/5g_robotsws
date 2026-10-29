__maintainer__ = "Jakub Ozierski"
__email__ = "jakub.ozierski@nokia.com"
# BTS ID: 5081
# BTS name: MonaLisa

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


_pdu_1 = Gude("10.42.80.131", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")
_pdu_2 = Gude("10.42.80.128", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")
_pdu_3 = Gude("10.42.80.117", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")
_pdus = [_pdu_1, _pdu_2, _pdu_3]

_rmod_1 = RU(
    radio_type="FXDB",
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    product_code="472573A.104",
    serial_number="F7172125130",
    pdu_port=_pdu_1.pdu_ports[9],
)
_rmod_2 = RU(
    radio_type="AHEGB",
    ru_hw_group="FRMr5.1a_4T4R",
    product_code="474090A.101",
    serial_number="K9203800458",
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_3 = RU(
    radio_type="AZHL",
    ru_hw_group="cMAAr6.1_8T8R",
    product_code="475432A.101",
    serial_number="YK203400005",
    pdu_port=_pdu_3.pdu_ports[3],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1232105763",
    rus=[_rmod_2],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204206296",
    rus=[_rmod_2],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173006871",
    rus=[_rmod_1],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.32",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1232004124",
    rus=[_rmod_3],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[12],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233503556",
)
_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233503555",
)
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],
    oam_ip=NetworkAddress("10.42.182.6"),
    instance_id=5081,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_2, _rmod_3],
    master=_enb_sbts_1,
)

_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.4", username="ute"),
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
    SshServiceDetails(addr="10.42.133.108", username="ute"),
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
    pdus=_pdus,
    tl_cloud_topology="CLOUD_SRAN_NLWG_ASIM_ABIO_ABIP_ASIM_ABIA_ABIP_FXDB_AHEGB_AZHL",
)

__all__ = ["tl"]
