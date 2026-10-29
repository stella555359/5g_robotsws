__maintainer__ = "Michal Kornacki"
__team__ = "siso"
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
from taf.config.testline.pdu import ATEN
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.fhs import FHS, FhsType

_pdu_2 = Gude("10.42.168.113", [1, 3, 4, 5, 8, 10, 11, 12], "EPC", "8221-1")
_pdu_3 = Gude("10.42.168.112", [3, 4, 7, 8, 9, 10, 11], "EPC", "8221-1")
_pdu_4 = Gude("10.42.169.5", [6], "EPC", "8220-1")
_pdu_6 = Gude("10.42.169.7", [9], "EPC", "8220-1")
_pdu_7 = Gude("10.42.168.111", [11, 12], "EPC", "8221-1")
_pdu_9 = Gude("10.42.169.201", [1, 2, 3, 4, 6, 7, 8, 9, 10], "EPC", "8221-1")
_pdu_10 = Gude("10.42.169.220", [10], "EPC", "8220-1")

_rmod_7 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="UHBA",
    serial_number="LBALLU-Z11728000JJ",
    pdu_port=_pdu_2.pdu_ports[1],
)  # UHBA_2
_rmod_9 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="AHFIC",
    serial_number="K9192414089",
    pdu_port=_pdu_2.pdu_ports[11],
)  # AHFIC_1
_rmod_10 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="AHFIC",
    serial_number="K9192414088",
    pdu_port=_pdu_2.pdu_ports[10],
)  # AHFIC_2
_rmod_11 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="AHFIC",
    serial_number="K9192414023",
    pdu_port=_pdu_2.pdu_ports[4],
)  # AHFIC_3
_rmod_12 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="AHHB",
    serial_number="EA192470287",
    pdu_port=_pdu_7.pdu_ports[11],
)  # AHHB_1
_rmod_13 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="AHHB",
    serial_number="EA192470274",
    pdu_port=_pdu_3.pdu_ports[8],
)  # AHHB_2
_rmod_14 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="AHHB",
    serial_number="EA192470227",
    pdu_port=_pdu_3.pdu_ports[9],
)  # AHHB_3
_rmod_15 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FHED",
    serial_number="K9154042845",
    pdu_port=_pdu_2.pdu_ports[12],
)  # FHED
_rmod_16 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FRHD",
    serial_number="RY151005687",
    pdu_port=_pdu_2.pdu_ports[8],
)  # FRHD
_rmod_17 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FXED",
    serial_number="L1174512394",
    pdu_port=_pdu_4.pdu_ports[6],
)  # FXED_3
_rmod_18 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="AHEC",
    serial_number="6Q190516639",
    pdu_port=_pdu_3.pdu_ports[7],
)  # AHEC_1
_rmod_19 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="AHEC",
    serial_number="6Q190510024",
    pdu_port=_pdu_2.pdu_ports[5],
)  # AHEC_2
_rmod_22 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="AREA",
    serial_number="EA191575386",
    pdu_port=_pdu_6.pdu_ports[9],
)  # AREA
_rmod_23 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="UHFA",
    serial_number="LBALLU-YD18040QX64",
    pdu_port=_pdu_9.pdu_ports[8],
)  # UHFA #
_rmod_24 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="AHNA",
    serial_number="1M193703388",
    pdu_port=_pdu_3.pdu_ports[3],
)  # AHNA #
_rmod_25 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="AHLBBA",
    serial_number="K9193853213",
    pdu_port=_pdu_3.pdu_ports[4],
)  # AHLBBA #
_rmod_26 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="AZRB",
    serial_number="AH191500140",
    pdu_port=_pdu_9.pdu_ports[9],
)  # AZRB #
_rmod_28 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FRBI",
    serial_number="K9170421633",
    pdu_port=_pdu_7.pdu_ports[12],
)  # FRBI #
_rmod_29 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="ARGA",
    serial_number="F7194105855",
    pdu_port=_pdu_9.pdu_ports[6],
)  # ARGA #
_rmod_30 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FXED",
    serial_number="F7173045757",
    pdu_port=_pdu_10.pdu_ports[10],
)  # FXED #
_rmod_31 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FRGU",
    serial_number="K9172046521",
    pdu_port=_pdu_9.pdu_ports[10],
)  # FRGU #


_fhs_1 = FHS(
    fhs_type=FhsType.MDEA.value,
    pdu_port=_pdu_3.pdu_ports[11],
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.131", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.255.124", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    optical_switch_channels=None,
    serial_number="6Q184126756",
    product_code="473922A.101",
    rus=[_rmod_7],
)
_fhs_2 = FHS(
    fhs_type=FhsType.MDCD.value,
    pdu_port=_pdu_3.pdu_ports[10],
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.255.124", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    optical_switch_channels=None,
    serial_number="6Q184126775",
    product_code="473922A.101",
    rus=[_rmod_9, _rmod_10, _rmod_11, _rmod_17],
)
_fhs_3 = FHS(
    fhs_type=FhsType.MDCD.value,
    pdu_port=_pdu_9.pdu_ports[3],
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.130", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.255.124", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    optical_switch_channels=None,
    serial_number="6Q185039413",
    product_code="473922A.101",
    rus=[_rmod_12, _rmod_13, _rmod_14],
)
_fhs_4 = FHS(
    fhs_type=FhsType.MDCD.value,
    pdu_port=_pdu_2.pdu_ports[3],
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.136", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.255.124", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    optical_switch_channels=None,
    serial_number="6Q185039409",
    product_code="473922A.101",
    rus=[_rmod_15, _rmod_16],
)
_fhs_5 = FHS(
    fhs_type=FhsType.MDEA.value,
    pdu_port=_pdu_9.pdu_ports[4],
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.12.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.255.124", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    optical_switch_channels=None,
    serial_number="6Q193802626",
    product_code="473922A.102",
    rus=[_rmod_22, _rmod_30, _rmod_23, _rmod_25, _rmod_24],
)
_fhs_7 = FHS(
    fhs_type=FhsType.MDCD.value,
    pdu_port=_pdu_9.pdu_ports[7],
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.12.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.255.124", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    optical_switch_channels=None,
    serial_number="6Q202207370",
    product_code="475700A.101",
    rus=[_rmod_31, _rmod_29, _rmod_28, _rmod_26],
)

_fsp_1 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIA",
    serial_number="L1172806107",
    pdu_port=_pdu_9.pdu_ports[1],
    fhs=[_fhs_3],
)
_fsp_2 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIA",
    serial_number="EA183943119",
    pdu_port=_pdu_9.pdu_ports[1],
    rus=[_rmod_19, _rmod_18],
    fhs=[_fhs_4],
)
_fsp_3 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    serial_number="L1173706693",
    pdu_port=_pdu_9.pdu_ports[1],
    fhs=[_fhs_1, _fhs_2],
)
_fsp_4 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    serial_number="L1173313392",
    pdu_port=_pdu_9.pdu_ports[2],
    fhs=[_fhs_7],
)
_fsp_5 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIA",
    serial_number="L1162604070",
    pdu_port=_pdu_9.pdu_ports[2],
    fhs=[_fhs_5],
)
_fsp_6 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIA",
    serial_number="L1170304516",
    pdu_port=_pdu_9.pdu_ports[2],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_9.pdu_ports[1],
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="L1164705755",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_9.pdu_ports[2],
    hardware_type="ASIA",
    hardware_version="473095A.101",
    serial_number="L1173422573",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_12,
        _rmod_13,
        _rmod_14,
        _rmod_15,
        _rmod_16,
        _rmod_7,
        _rmod_9,
        _rmod_10,
        _rmod_11,
        _rmod_17,
        _rmod_18,
        _rmod_19,
    ],
    oam_ip=NetworkAddress("10.42.174.213"),
    instance_id=1449,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[
        _rmod_31,
        _rmod_29,
        _rmod_28,
        _rmod_22,
        _rmod_30,
        _rmod_23,
        _rmod_25,
        _rmod_24,
        _rmod_26,
    ],
    master=_enb_sbts_1,
    oam_ip=NetworkAddress("10.42.174.213"),
    instance_id=1449,
)

_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.184.124", username="ute"),
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
    SshServiceDetails(addr="10.42.184.126", username="ute"),
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
    tl_cloud_topology="CLOUD_10_16_UTESRANSISO093",
    pdus=[_pdu_2, _pdu_3, _pdu_4, _pdu_6, _pdu_7, _pdu_9, _pdu_10],
)

__all__ = ["tl"]
