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
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.bts2g import Bts2G
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection

_pdu_1 = Gude("10.44.167.168", [5], "EPC", "8221-1")
_pdu_2 = Gude("10.44.167.177", [1, 2, 3, 4], "EPC", "8221-1")
_pdu_3 = Gude("10.44.167.174", [3], "EPC", "8221-1")
_pdu_4 = Gude("10.44.167.176", [11], "EPC", "8221-1")

_rmod_1 = RU(
    ru_hw_group="FRMr6.2a_4T4R",
    radio_type="AHEGHA",
    serial_number="BL2346H659W",
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group="FRMr6.2a_4T4R",
    radio_type="AHEGHA",
    serial_number="BL2345H64W2",
    pdu_port=_pdu_3.pdu_ports[3],
)
_rmod_3 = RU(
    ru_hw_group="FRMr6.2a_4T4R",
    radio_type="AHEGHA",
    serial_number="BL2346H659O",
    pdu_port=_pdu_4.pdu_ports[11],
)
_rmod_4 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHPMDG",
    serial_number="BL2344C66Q0",
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_5 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHPMDG",
    serial_number="BL2344C66OJ",
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_6 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHPMDG",
    serial_number="BL2344C66KW",
    pdu_port=_pdu_2.pdu_ports[3],
)

_fsp_1 = CapacityUnit(
    addr="192.168.254.129",
    hardware_type="ABIO",
    serial_number="L1205102667",
    product_code="475266A.102",
    pdu_port=_pdu_1.pdu_ports[5],
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)
_fsp_2 = CapacityUnit(
    addr="192.168.254.129",
    hardware_type="ABIO",
    serial_number="L1204806033",
    product_code="475266A.102",
    pdu_port=_pdu_1.pdu_ports[5],
    rus=[_rmod_4, _rmod_5, _rmod_6],
)
_fsp_3 = CapacityUnit(
    addr="192.168.254.129",
    hardware_type="ABIA",
    serial_number="L1172904143",
    product_code="473096A.103",
    pdu_port=_pdu_1.pdu_ports[5],
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIB",
    serial_number="L1201102968",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    oam_ip=NetworkAddress("10.42.24.98"),
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
        _rmod_6,
    ],
    instance_id=1235,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.121.110", username="ute"),
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
)

__all__ = ["tl"]
