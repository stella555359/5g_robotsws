__maintainer__ = "Tomasz Fojtar"
__team__ = "siso"
__email__ = "tomasz.fojtar@nokia.com"
__owner_email__ = "tomasz.fojtar@nokia.com"

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
from taf.config.testline.radio import RU
from taf.config.testline.pdu import ATEN
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.40.102", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.44.167.125", [3], "EPC", "")
_pdu_2 = Gude("10.44.167.112", [5, 6, 7, 9], "EPC", "")
_pdu_3 = Gude("10.44.167.113", [7, 8], "EPC", "")
_pdu_4 = Gude("10.44.167.114", [6], "EPC", "")


_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIL",
    serial_number="L1201605746",
    pdu_port=_pdu_1.pdu_ports[3],
)
_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIL",
    serial_number="L1201301517",
    pdu_port=_pdu_1.pdu_ports[3],
)
_fsp_3 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIL",
    serial_number="L1213602019",
    pdu_port=_pdu_1.pdu_ports[3],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIB",
    serial_number="L1211509457",
)
_smod_1 = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="cMAAr6_1_64T64R",
    serial_number="1M223207228",
    pdu_port=_pdu_3.pdu_ports[7],
    radio_type="AEQE",
)

_rmod_2 = RU(
    ru_hw_group="cMAAr6_1_64T64R",
    serial_number="1M204448310",
    pdu_port=_pdu_3.pdu_ports[8],
    radio_type="AEQE",
)

_rmod_3 = RU(
    ru_hw_group="cMAAr6_1_64T64R",
    serial_number="1M222345982",
    pdu_port=_pdu_4.pdu_ports[6],
    radio_type="AEQE",
)

_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="K9200218921",
    pdu_port=_pdu_2.pdu_ports[5],
    radio_type="AHPCDB",
)
_rmod_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="K9200218917",
    pdu_port=_pdu_2.pdu_ports[6],
    radio_type="AHPCDB",
)
_rmod_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="K9200218920",
    pdu_port=_pdu_2.pdu_ports[7],
    radio_type="AHPCDB",
)


_enb_sbts_1 = RealEnb(
    system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6]
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_RF_AIBLR_B1-5_UTESRANSISO805TPG-2",
)

__all__ = ["tl"]
