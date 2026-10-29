__owner__ = "Nie Sue"
__maintainer__ = "Nie Sue"
__email__ = "sue.nie@nokia-sbell.com"

import os
import re
import yaml

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, FACOM
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import ATEN
from taf.config.testline.radio import RU
from taf.config.testline import DU
from taf.config.testline.gnb import CU, ClassicalBts
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.pdu import EPC
from taf.config.testline.pdu import FACOM, HBTE
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)


_pdu_1 = FACOM(addr="10.56.7.186",port_numbers=[1, 3, 4, 5, 6])
_pdu_2 = FACOM(addr="10.56.7.211",port_numbers=[6, 7])
_pdu_3 = FACOM(addr="10.56.7.228",port_numbers=[2, 8])
_pdu_4 = FACOM(addr="10.56.7.238",port_numbers=[3, 4])
_pdu_5 = FACOM(addr="10.69.64.245",port_numbers=[8])

_rmod_1 = RU(
    ru_hw_group="URCB:CPRI_A_RRH_4T4R",
    radio_type="URCB",
    serial_number="TC09AW0333",
    pdu_port=_pdu_1.pdu_ports[4],
)

_rmod_2 = RU(
    ru_hw_group="URCB:CPRI_A_RRH_4T4R",
    radio_type="URCB",
    serial_number="TC09BR1667",
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_3 = RU(
    ru_hw_group="URCB:CPRI_A_RRH_4T4R",
    radio_type="URCB",
    serial_number="TC09CH1081",
    pdu_port=_pdu_3.pdu_ports[2],
)

_rmod_4 = RU(
    ru_hw_group="URCB:CPRI_A_RRH_4T4R",
    radio_type="URCB",
    serial_number="TC09AX0588",
    pdu_port=_pdu_1.pdu_ports[6],
)

_rmod_5 = RU(
    ru_hw_group="URGA:CPRI_A_RRH_4T4R",
    radio_type="URGA",
    serial_number="TC09CM1206",
    pdu_port=_pdu_4.pdu_ports[4],
)

_rmod_6 = RU(
    ru_hw_group="URGA:CPRI_A_RRH_4T4R",
    radio_type="URGA",
    serial_number="TC09CN0273",
    pdu_port=_pdu_4.pdu_ports[3],
)

_rmod_7 = RU(
    ru_hw_group="URCB:CPRI_A_RRH_4T4R",
    radio_type="URCB",
    serial_number="TC09BR1671",
    pdu_port=_pdu_5.pdu_ports[8],
)

_rmod_8 = RU(
    ru_hw_group="URCC:CPRI_A_RRH_4T4R",
    radio_type="URCC",
    serial_number="TC09DB2283",
    pdu_port=_pdu_1.pdu_ports[3],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIA",
    hardware_version="A.102",
    serial_number="K9174042728",
    pdu_port=_pdu_1.pdu_ports[1],
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="A.102",
    serial_number="K9174042729",
    pdu_port=_pdu_1.pdu_ports[5],
    rus=[_rmod_5, _rmod_6, _rmod_7, _rmod_8],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIA",
    hardware_version="A.101",
    serial_number="K9173324136",
    capacity_units=[_fsp_1],
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIA",
    hardware_version="A.101",
    serial_number="L1181010681",
    capacity_units=[_fsp_2],
)

_smod_1 = Airscale([_fct_1])

_smod_2 = Airscale([_fct_2])



_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_5, _rmod_6, _rmod_7, _rmod_8],
)

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.213.89", username="ute", password="ute"
    ),
    connections=[_enb_sbts_1.system_module.common_units[0],NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.213.90", username="ute", password="ute"
    ),
    connections=[_enb_sbts_2.system_module.common_units[0],NetworkAddress(v4="192.168.255.126")],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_RF_AILR_B1_B4_CRT2_1018",
)

__all__ = ["tl"]
