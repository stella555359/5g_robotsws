__maintainer__ = "Mariusz B\u0105k"
__owner_email__ = "mariusz.bak@nokia.com"
__email__ = "mariusz.bak@nokia.com"

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import ATEN
from taf.config.testline.radio import RU
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.pdu import EPC
from taf.config.testline.pdu import Gude
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.fhs import FHS, FhsType
from taf.config.testline.optical_switch import OpticalSwitch, Leoni

_pdu_1 = Gude("10.42.169.12", [10, 11, 12], "EPC", "8220-1")
_pdu_2 = Gude("10.42.168.246", [10], "EPC", "8220-1")
_pdu_4 = Gude(
    "10.42.169.178",
    [
    	3,
        7,
        8,
        9,
    ],
    "EPC",
    "8220-1",
)


_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="EA203762035",
    pdu_port=_pdu_4.pdu_ports[8],
    radio_type=RadioTypes.AHEGB.value,
)
_rmod_2 = RU(
    ru_hw_group="cMAAr6.1_64T64R_eCPRI",
    serial_number="1M221313269",
    pdu_port=_pdu_4.pdu_ports[3],
    radio_type=RadioTypes.AEQE.value,
) 
_rmod_6 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    serial_number="EA201259219",
    pdu_port=_pdu_1.pdu_ports[12],
    radio_type=RadioTypes.AREA.value,
)
_rmod_8 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="EA214454240",
    pdu_port=_pdu_4.pdu_ports[9],
    radio_type=RadioTypes.AHEGC.value,
)
_rmod_10 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    serial_number="L1184911218",
    pdu_port=_pdu_1.pdu_ports[11],
    radio_type=RadioTypes.AREA.value,
)

_fhs_3 = FHS(
    fhs_type=FhsType.MDCD.value,
    pdu_port=_pdu_4.pdu_ports[7],
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.132", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.255.124", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    optical_switch_channels=None,
    serial_number="6Q192920552",
    product_code="473922A.102",
    rus=[
        _rmod_8,
        _rmod_1,
    ],
)

_fhs_4 = FHS(
    fhs_type=FhsType.MDCD.value,
    pdu_port=_pdu_1.pdu_ports[10],
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.133", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.255.124", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    optical_switch_channels=None,
    serial_number="YY220910775",
    product_code="473922A.102",
    rus=[_rmod_10, _rmod_6],
)


_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1172712950",
    pdu_port=_pdu_2.pdu_ports[10],
    rus=[_rmod_8, _rmod_1, _rmod_10, _rmod_6],
)
_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1233105838",
    pdu_port=_pdu_2.pdu_ports[10],
    fhs=[_fhs_3],
    rus=[_rmod_2],
)
_fsp_3 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1231800063",
    pdu_port=_pdu_2.pdu_ports[10],
    fhs=[_fhs_4],
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_2.pdu_ports[10],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1233406373",
)

_smod_1 = Airscale([_fct_1])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_6,
        _rmod_8,
        _rmod_10,
    ],
    oam_ip=NetworkAddress("10.44.137.159"),
    instance_id=1372,
)


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.184.35", username="ute"),
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
    tl_cloud_topology="CLOUD_10_16_UTESRANSISO125",
)


__all__ = ["tl"]
