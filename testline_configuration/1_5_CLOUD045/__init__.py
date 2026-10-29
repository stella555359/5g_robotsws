__owner__ = "Nie Sue"
__maintainer__ = "Nie Sue"
__email__ = "sue.nie@nokia-sbell.com"

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

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.152.76", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.152.78", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = FACOM(
    addr="10.108.151.85",
    port_numbers=[4, 5],
    model="facom",
)

_pdu_2 = FACOM(
    addr="10.108.151.50",
    port_numbers=[1, 8],
    model="facom",
)

_pdu_3 = FACOM(
    addr="10.108.151.4",
    port_numbers=[6],
    model="facom",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="A.101",
    serial_number="6Q174907918",
    pdu_port=_pdu_1.pdu_ports[4],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.25",
    hardware_type="ABIA",
    hardware_version="A.101",
    serial_number="6Q174907982",
    pdu_port=_pdu_1.pdu_ports[4],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIA",
    hardware_version="A.101",
    serial_number="AH173607749",
    pdu_port=_pdu_1.pdu_ports[4],
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.27",
    hardware_type="ABIA",
    hardware_version="A.101",
    serial_number="K9174042760",
    pdu_port=_pdu_1.pdu_ports[5],
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="A.101",
    serial_number="6Q174908006",
    pdu_port=_pdu_1.pdu_ports[5],
)

_fsp_6 = CapacityUnit(
    addr="192.168.253.29",
    hardware_type="ABIA",
    hardware_version="A.101",
    serial_number="K9173814639",
    pdu_port=_pdu_1.pdu_ports[5],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIA",
    hardware_version="A.101",
    serial_number="L1185009184",
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
)

_smod_1 = Airscale([_fct_1])

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIA",
    hardware_version="A.101",
    serial_number="L1165015341",
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
)

_smod_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="AENB:CPRI_A_RRH_4T4R",
    serial_number="1M210806758",
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="AENB:CPRI_A_RRH_4T4R",
    serial_number="1M210806762",
    pdu_port=_pdu_3.pdu_ports[6],
)

_rmod_3 = RU(
    ru_hw_group="AENB:CPRI_A_RRH_4T4R",
    serial_number="1M210806759",
    pdu_port=_pdu_2.pdu_ports[8],
)

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2])

_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_1, _rmod_3])

tl = TestLine(
    test_pc=[_test_pc_1, _test_pc_2],
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_RF_AILR_B1-B6_CRT2_1045",
)

__all__ = ["tl"]
