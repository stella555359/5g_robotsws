__maintainer__ = "Krzysztof Pekala"
__team__ = "siso"
__email__ = "krzysztof.pekala@nokia.com"


from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
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
from taf.config.testline.testpc import TestPc, Connection



_pdu_1 = Gude("10.42.169.239", [5], "EPC", "8220-1")   # AHLOB_477
_pdu_2 = Gude("10.42.169.245", [9], "EPC", "8220-1")   # AHLOB_480
_pdu_3 = Gude("10.42.169.249", [8], "EPC", "8220-1")   # AHFII_902
_pdu_4 = Gude("10.42.169.251", [2], "EPC", "8220-1")   # AHFII_935
_pdu_5 = Gude("10.42.169.252", [3, 10], "EPC", "8220-1")   # AHLOB_479 #AVHA_181
_pdu_6 = Gude("10.42.169.247", [5, 6], "EPC", "8220-1")   # AHFII_905 #AVHA_180
_pdu_7 = Gude("10.42.169.248", [8], "EPC", "8220-1")   # AVHA_179
_pdu_8 = Gude("10.42.169.246", [3, 5], "EPC", "8220-1")   # SM ASIM p3(L) -- ASIM p5(R)

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOB",
    serial_number="AH250400480",
    pdu_port=_pdu_2.pdu_ports[9],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOB",
    serial_number="AH250400477",
    pdu_port=_pdu_1.pdu_ports[5],
)

_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOB",
    serial_number="AH250400479",
    pdu_port=_pdu_5.pdu_ports[10],
)

_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFII",
    serial_number="K9245128902",
    pdu_port=_pdu_3.pdu_ports[8],
)

_rmod_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFII",
    serial_number="K9245120905",
    pdu_port=_pdu_6.pdu_ports[5],
)

_rmod_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFII",
    serial_number="K9245128935",
    pdu_port=_pdu_4.pdu_ports[2],
)

_rmod_7 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AVHA",
    serial_number="L1251205179",
    pdu_port=_pdu_7.pdu_ports[8],
)

_rmod_8 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AVHA",
    serial_number="L1251205180",
    pdu_port=_pdu_6.pdu_ports[6],
)

_rmod_9 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AVHA",
    serial_number="L1251205181",
    pdu_port=_pdu_5.pdu_ports[3],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    serial_number="L1215008505",
    pdu_port=_pdu_8.pdu_ports[3],
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    serial_number="L1173003801",
    pdu_port=_pdu_8.pdu_ports[3],
    rus=[_rmod_4, _rmod_5, _rmod_6],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIP",
    serial_number="L1244806853",
    pdu_port=_pdu_8.pdu_ports[5],
    rus=[_rmod_7, _rmod_8, _rmod_9],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIP",
    serial_number="L1244806826",
    pdu_port=_pdu_8.pdu_ports[5],
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    hardware_type="ASIM",
    serial_number="L1230613856",
    pdu_port=_pdu_8.pdu_ports[3],
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4],
    pdu_port=_pdu_8.pdu_ports[5],
    hardware_type="ASIM",
    serial_number="L1233406329",
)
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6]
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9],
    master=_enb_sbts_1,
)

_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.184.31", username="ute"),
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
    SshServiceDetails(addr="10.42.184.32", username="ute"),
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
)

__all__ = ["tl"]
