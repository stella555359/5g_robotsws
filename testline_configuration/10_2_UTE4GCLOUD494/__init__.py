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

__Modules__ = """[ASIA_1, ABIA_1, ABIA_2, FRMF_1, FRMF_2, AMIA_1, LNMME, PDU_2]"""

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.43.54.229", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.129")],
)
_IP_PDU_1 = Gude("10.41.155.176", [2, 3, 4], "EPC")

_bbmod_1 = CapacityUnit(
    addr="192.168.253.190",
    hardware_type="ABIA AirScale Capacity",
    serial_number="K9174336798",
    pdu_port=_IP_PDU_1.pdu_ports[2],
)

_bbmod_2 = CapacityUnit(
    addr="192.168.253.190",
    hardware_type="ABIA AirScale Capacity",
    serial_number="K9172928176",
    pdu_port=_IP_PDU_1.pdu_ports[2],
)

_ASIA_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_1, _bbmod_2],
    pdu_port=_IP_PDU_1.pdu_ports[2],
    hardware_type="ASIL AirScale Common",
    serial_number="L1203506216",
)
_smod_1 = Airscale([_ASIA_1])

_rmod_1 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FRMF",
    serial_number="AS175102203 ",
    pdu_port=_IP_PDU_1.pdu_ports[3],
)

_rmod_2 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FRMF",
    serial_number="AS175102222",
    pdu_port=_IP_PDU_1.pdu_ports[4],
)

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2])

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_LWG_1ASIA_2ABIA_2FRMF",
)

__all__ = ["tl"]
