__maintainer__ = "Roksana Spychala-Malolepsza"
__team__ = "siso"
__email__ = "roksana.spychala-malolepsza@nokia.com"

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


_pdu_1 = Gude("10.44.167.147", [1, 2], "EPC", "8221-1")
_pdu_2 = Gude("10.44.167.73", [2, 3, 4], "EPC", "8221-1")
_pdu_3 = Gude("10.44.167.74", [6, 7, 8], "EPC", "8221-1")
_pdu_4 = Gude("10.44.167.75", [2, 3, 4], "EPC", "8221-1")


_rmod_1 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    serial_number="K9250816058",
    pdu_port=_pdu_3.pdu_ports[6],
    product_code="476122A.101",
    radio_type="AHPMDG",
)

_rmod_2 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    serial_number="K9250809795",
    pdu_port=_pdu_3.pdu_ports[7],
    product_code="476122A.101",
    radio_type="AHPMDG",
)

_rmod_3 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    serial_number="K9250803807",
    pdu_port=_pdu_3.pdu_ports[8],
    product_code="476122A.101",
    radio_type="AHPMDG",
)

_rmod_4 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    serial_number="K9242211473",
    pdu_port=_pdu_4.pdu_ports[3],
    product_code="476122A.101",
    radio_type="AHEGG",
)

_rmod_5 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    serial_number="K9242201129",
    pdu_port=_pdu_4.pdu_ports[4],
    product_code="476122A.101",
    radio_type="AHEGG",
)

_rmod_6 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    serial_number="K9242211470",
    pdu_port=_pdu_4.pdu_ports[2],
    product_code="476122A.101",
    radio_type="AHEGG",
)

_rmod_7 = RU(
    ru_hw_group="cMAAr7.1_32T32R",
    serial_number="1M250200253",
    pdu_port=_pdu_2.pdu_ports[3],
    product_code="476598A.101",
    radio_type="AVHQA",
)

_rmod_8 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    serial_number="1M250200265",
    pdu_port=_pdu_2.pdu_ports[2],
    product_code="476598A.101",
    radio_type="AVHQA",
)

_rmod_9 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    serial_number="1M250200256",
    pdu_port=_pdu_2.pdu_ports[4],
    product_code="476598A.101",
    radio_type="AVHQA",
)

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIP",
    serial_number="L1234003115",
    pdu_port=_pdu_1.pdu_ports[2],
    rus=[_rmod_7, _rmod_8, _rmod_9],
)

_fsp_2 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    serial_number="L1215008531",
    pdu_port=_pdu_1.pdu_ports[2],
    rus=[_rmod_7, _rmod_8, _rmod_9],
)

_fsp_3 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIQ",
    serial_number="L1233105837",
    pdu_port=_pdu_1.pdu_ports[1],
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)

_fsp_4 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIA",
    serial_number="L1173405498",
    pdu_port=_pdu_1.pdu_ports[1],
)

_fsp_5 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIA",
    serial_number="L1173313373",
    pdu_port=_pdu_1.pdu_ports[1],
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233505228",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4, _fsp_5],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1202900206",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    oam_ip=NetworkAddress("10.42.24.108"),
    rms=[_rmod_7, _rmod_8, _rmod_9],
    instance_id=1245,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
        _rmod_6,
    ],
    master=_enb_sbts_1,
)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.121.8", username="ute"),
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
    SshServiceDetails(addr="10.42.121.9", username="ute"),
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
