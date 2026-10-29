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
from taf.config.testline.pdu import Gude, FACOM, HBTE
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc


_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.152.79", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = FACOM(
    addr="10.108.151.101",
    port_numbers=[2],
    model="facom",
)

_pdu_2 = HBTE(
    addr="10.106.198.107",
    port_numbers=[4],
    model="hbte",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIC",
    hardware_version="A.101",
    serial_number="6Q191215153",
    pdu_port=_pdu_1.pdu_ports[2],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIC",
    hardware_version="A.101",
    serial_number="6Q191215426",
    pdu_port=_pdu_1.pdu_ports[2],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIC",
    hardware_version="A.101",
    serial_number="6Q191215223",
    pdu_port=_pdu_1.pdu_ports[2],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIB",
    hardware_version="A.101",
    serial_number="L1185009186",
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
)

_smod = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="AEQA:CPRI_A_RRH_4T4R",
    serial_number="6Q190316354",
    pdu_port=_pdu_2.pdu_ports[4],
)

_enb_sbts = RealEnb(system_module=_smod, rms=[_rmod_1])

tl = TestLine(
    test_pc=[_test_pc],
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_RF_AIL_B1-3_CRT1_1048",
)

__all__ = ["tl"]
