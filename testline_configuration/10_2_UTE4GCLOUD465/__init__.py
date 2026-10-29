__maintainer__ = "Arunkumar A"
__team__ = "MN_RAN_PZ_BLR_SG02"
__email__ = "arunkumar.a@nokia.com"


from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude
from taf.config.testline.pdu import ATEN
from taf.config.testline.radio import RU
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.testpc import TestPc

__Modules__ = """[ASIL_1, ABIA_1, AREA_2, AMIA_1, LNMME, PDU_2]"""

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.43.54.217", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.129")],
)
_IP_PDU_1 = Gude("10.41.155.139", [7], "EPC")
_IP_PDU_2 = Gude("10.41.155.173", [1, 4], "EPC")

_bbmod_1 = CapacityUnit(
    addr="192.168.253.190",
    hardware_type="ABIA AirScale Capacity",
    serial_number="EA191378113",
    pdu_port=_IP_PDU_1.pdu_ports[7],
)

_ASIL_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_1],
    pdu_port=_IP_PDU_1.pdu_ports[7],
    hardware_type="ASIL AirScale Common",
    serial_number="L1203506216",
)
_smod_1 = Airscale([_ASIL_1])

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type="AREA",
    serial_number="EA213650574 ",
    pdu_port=_IP_PDU_2.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type="AREA",
    serial_number="EA213650568",
    pdu_port=_IP_PDU_2.pdu_ports[4],
)

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2])

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_LWG_1ASIL_1ABIA_2AREA",
)

__all__ = ["tl"]
