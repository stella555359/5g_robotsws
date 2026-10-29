__maintainer__ = "Michal Kornacki"
__email__ = "michal.kornacki@nokia.com"
__owner_email__ = "michal.kornacki@nokia.com"

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
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.optical_switch import OpticalSwitch, Leoni

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.164.18", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.164.19", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.42.168.97", [10, 11], "EPC", "8220-1")
_pdu_2 = Gude("10.42.168.96", [2, 3, 9], "EPC", "8220-1")
_pdu_3 = Gude("10.42.168.83", [1, 2, 3], "EPC", "8221-1")

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1220710891",
    pdu_port=_pdu_1.pdu_ports[10],
)

_fsp_2 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1163617141",
    pdu_port=_pdu_1.pdu_ports[11],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1202800764",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1202606222",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

# _rmod_1 = RU(
#     ru_hw_group="FRMr4.0a_2T2R",
#     radio_type=RadioTypes.FRGY,
#     serial_number="EA173533365",
#     pdu_port=_pdu_2.pdu_ports[3],
# )

_rmod_2 = RU(
    ru_hw_group="FRMr4.3b_4T4R",
    radio_type=RadioTypes.FRIJ,
    serial_number="EA204855819",
    pdu_port=_pdu_3.pdu_ports[1],
)

_rmod_3 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type=RadioTypes.AREA,
    serial_number="EA192474212",
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_4 = RU(
    ru_hw_group="MDEA",
    serial_number="6Q191131214",
    pdu_port=_pdu_3.pdu_ports[2],
)

# _rmod_5 = RU(
#     ru_hw_group="MDEA",
#     serial_number="6Q192920562",
#     pdu_port=_pdu_3.pdu_ports[3],
# )

_rmod_6 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FXED,
    serial_number="L1180402088",
    pdu_port=_pdu_2.pdu_ports[9],
)

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        # _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        # _rmod_5,
    ],
    oam_ip=NetworkAddress("10.42.175.25"),
    instance_id=1387,
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[
        _rmod_6,
    ],
    oam_ip=NetworkAddress("10.42.175.26"),
    instance_id=1386,
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
)

__all__ = ["tl"]
