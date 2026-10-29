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

_pdu_1 = Gude("10.44.167.139", [7], "EPC", "8221-1")  # SMOD
_pdu_2 = Gude("10.44.167.133", [4], "EPC", "8221-1")	#RMOD

_rmod_1 = RU(
    ru_hw_group="RU_FDr8_4T4R",
    serial_number="L1253802750",
    pdu_port=_pdu_2.pdu_ports[4],
    radio_type="AXEGHA",
)  # AXEGHA

_fsp_1 = CapacityUnit(
    addr="192.168.255.129",
    hardware_type="ABIP",
    serial_number="L1231800113",
    product_code="475792A.101",
    pdu_port=_pdu_1.pdu_ports[7],
    rus=[_rmod_1],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIM",
    serial_number="L1233505238",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    oam_ip=NetworkAddress("10.42.24.63"),
    rms=[
        _rmod_1,
    ],
    instance_id=1200,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.239.175", username="ute"),
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
