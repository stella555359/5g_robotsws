__owner__ = "Zhu Chen"
__maintainer__ = "Zhu Chen"
__email__ = "chen.2.zhu@nokia-sbell.com"

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

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.213.68", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = FACOM(
    addr="10.69.66.100",
    port_numbers=[1],
    model="facom",
)

_pdu_2 = FACOM(
    addr="10.69.67.120",
    port_numbers=[4],
    model="facom",
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="FSMF",
    hardware_version="472181A",
    serial_number="EA173262596",
    capacity_units=[],
)

_smod = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="FHDI:CPRI_A_RRH_2T2R",
    serial_number="YK170500066",
    pdu_port=_pdu_2.pdu_ports[4],
)

_enb_sbts = RealEnb(system_module=_smod, rms=[_rmod_1])

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_RF_F_CRT1_1002",
)

__all__ = ["tl"]
