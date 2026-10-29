__maintainer__ = "Kamil Ostrzolek"
__team__ = "SCOUT"
__email__ = "kamil.ostrzolek@nokia.com"

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
from taf.config.testline.pdu import ATEN
from taf.config.testline.radio import RU
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc

_test_pc = TestPc(
    SshServiceDetails(addr="10.42.164.141", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu = Gude(
    addr="10.42.168.188",
    port_numbers=[3, 4, 5, 6],
    model="EPC",
    version="8220-1",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="L1162601102",
    pdu_port=_pdu.pdu_ports[5],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu.pdu_ports[5],
    hardware_type="ASIA",
    serial_number="L1165001808",
)

_smod_1 = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="FRHA",
    serial_number="L9113100377",
    pdu_port=_pdu.pdu_ports[6],
)
_rmod_2 = RU(
    ru_hw_group="LTE_RADIO",
    radio_type="FRHA",
    serial_number="L9112101811",
    pdu_port=_pdu.pdu_ports[4],
)
_rmod_3 = RU(
    ru_hw_group="FRMr3.0_3T6R",
    radio_type="FRGS",
    serial_number="L6152705999",
    pdu_port=_pdu.pdu_ports[3],
)

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3])

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_RF_AIL_B1_2xFRHA_FRGS",
)

__all__ = ["tl"]
