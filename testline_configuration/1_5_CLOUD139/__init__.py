__owner__ = "Wu Nick"
__maintainer__ = "Wu Nick"
__email__ = "nick.1.wu@nokia-sbell.com"

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import FACOM, HBTE
from taf.config.testline.radio import RU
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc

_pdu_1 = FACOM(
    addr="10.106.208.202", port_numbers=[1, 3, 5, 7], model="facom"
)  # ASIB LEFT:1, ASIB RIGHT:3 AZQD:5 AZHA:7
_pdu_2 = FACOM(addr="10.106.208.152", port_numbers=[6], model="facom")  # AZQF
_pdu_3 = FACOM(
    addr="10.106.211.145", port_numbers=[1, 4, 5], model="facom"
)  # AZQP2:1 AZQP3:4 AZHL:5
_pdu_4 = FACOM(addr="10.106.208.153", port_numbers=[8], model="facom")  # ARMA2

# ABIN+ABIO LEFT
_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIN",
    hardware_version="474824A.101",
    serial_number="L1204212514",
    pdu_port=_pdu_1.pdu_ports[1],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204101586",
    pdu_port=_pdu_1.pdu_ports[1],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204101567",
    pdu_port=_pdu_1.pdu_ports[1],
)
# ABIN+ABIO RIGHT
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIN",
    hardware_version="474824A.101",
    serial_number="L1204212518",
    pdu_port=_pdu_1.pdu_ports[3],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204101561",
    pdu_port=_pdu_1.pdu_ports[3],
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204101560",
    pdu_port=_pdu_1.pdu_ports[3],
)
# ASIB LEFT
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1",
        username="toor4nsn",
        password="oZPS0POrRieRtu",
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="473764A.101",
    serial_number="L1182811436",
)
# ASIB RIGHT
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1",
        username="toor4nsn",
        password="oZPS0POrRieRtu",
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="473764A.101",
    serial_number="L1183314275",
)
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="AZQF:CPRI",
    serial_number="6Q181710312",
    pdu_port=_pdu_2.pdu_ports[6],
)  # AZQF
_rmod_2 = RU(
    ru_hw_group="AZQD:CPRI",
    serial_number="EB191060014",
    pdu_port=_pdu_1.pdu_ports[5],
)  # AZQD
_rmod_3 = RU(
    ru_hw_group="AZHL:CPRI",
    serial_number="YK203400047",
    pdu_port=_pdu_3.pdu_ports[5],
)  # AZHL
_rmod_4 = RU(
    ru_hw_group="AZHA:CPRI",
    serial_number="6Q173706875",
    pdu_port=_pdu_1.pdu_ports[7],
)  # AZHA
_rmod_5 = RU(
    ru_hw_group="ARMA2:CPRI",
    serial_number="4H192230006",
    pdu_port=_pdu_4.pdu_ports[8],
)  # ARMA2
_rmod_6 = RU(
    ru_hw_group="AZQP-e2:eCPRI",
    serial_number="1M203225543",
    pdu_port=_pdu_3.pdu_ports[1],
)  # AZQP-2
_rmod_7 = RU(
    ru_hw_group="AZQP-e3:eCPRI",
    serial_number="1M203844865",
    pdu_port=_pdu_3.pdu_ports[4],
)  # AZQP-3

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3])
_enb_sbts_2 = RealEnb(
    system_module=_smod_2, rms=[_rmod_4, _rmod_5, _rmod_6, _rmod_7], master=_enb_sbts_1
)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.106.211.225", username="ute", password="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.106.211.226", username="ute", password="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

tl = TestLine(
    test_pc=[_test_pc_1],
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_RF_AIR_FullRack_2786",
)
__all__ = ["tl"]
