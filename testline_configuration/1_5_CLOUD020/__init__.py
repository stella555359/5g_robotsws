__owner__ = "Wu Xiaotong"
__maintainer__ = "Wu Xiaotong"
__email__ = "xiaotong.wu@nokia-sbell.com"

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
        addr="10.106.213.92", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = FACOM(
    addr="10.56.7.238",
    port_numbers=[5, 7, 8],
    model="facom",
)

_pdu_2 = FACOM(
    addr="10.56.7.232",
    port_numbers=[3, 4, 5, 7, 8],
    model="facom",
)

_pdu_3 = FACOM(
    addr="10.56.7.123",
    port_numbers=[5],
    model="facom",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="FBBC",
    hardware_version="A.103",
    serial_number="EA173524517",
    pdu_port=_pdu_1.pdu_ports[5],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="FSMF",
    hardware_version="A.203",
    serial_number="L1133811610",
    capacity_units=[_fsp_1],
)

_smod = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="FHEH:CPRI_A_RRH_4T4R",
    serial_number="K9162878812",
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_2 = RU(
    ru_hw_group="FHCA:CPRI_A_RRH_4T4R",
    serial_number="MS114202001",
    pdu_port=_pdu_1.pdu_ports[7],
)

_rmod_3 = RU(
    ru_hw_group="FHEH:CPRI_A_RRH_4T4R",
    serial_number="K9162900062",
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_4 = RU(
    ru_hw_group="FHCA:CPRI_A_RRH_4T4R",
    serial_number="MS133520037",
    pdu_port=_pdu_1.pdu_ports[8],
)

_rmod_5 = RU(
    ru_hw_group="FHEH:CPRI_A_RRH_4T4R",
    serial_number="K9162878813",
    pdu_port=_pdu_2.pdu_ports[5],
)

_rmod_6 = RU(
    ru_hw_group="FHCA:CPRI_A_RRH_4T4R",
    serial_number="MS114102009",
    pdu_port=_pdu_3.pdu_ports[5],
)


_enb_sbts = RealEnb(
    system_module=_smod, rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6]
)

tl = TestLine(
    test_pc=[_test_pc],
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_RF_FC_CRT2_1020",
)

__all__ = ["tl"]
