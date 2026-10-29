__owner__ = "linlen"
__maintainer__ = "linlen"
__email__ = "len.lin@nokia-sbell.com"

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
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails

_pdu_1 = FACOM(
    addr="10.108.151.66",
    port_numbers=[7, 8],
)

_pdu_2 = HBTE(
    addr="10.108.151.63",
    port_numbers=[1],
)

_rmod_1 = RU(
    ru_hw_group="AAHF:cMAA_Gen3.14_64T64R",
    serial_number="1M194201625",
    radio_type="AAHF",
    pdu_port=_pdu_2.pdu_ports[1],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA184380785",
    pdu_port=_pdu_1.pdu_ports[7],
    rus=[_rmod_1],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1165205611",
    pdu_port=_pdu_1.pdu_ports[7],
    rus=[_rmod_1],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="AH173607770",
    pdu_port=_pdu_1.pdu_ports[7],
    rus=[_rmod_1],
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="AH173607768",
    pdu_port=_pdu_1.pdu_ports[8],
    rus=[_rmod_1],
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="6Q184331204",
    pdu_port=_pdu_1.pdu_ports[8],
    rus=[_rmod_1],
)

_fsp_6 = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="AH173607771",
    pdu_port=_pdu_1.pdu_ports[8],
    rus=[_rmod_1],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIA",
    hardware_version="473095A.202",
    serial_number="K9173324125",
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIA",
    hardware_version="473095A.202",
    serial_number="L1165103824",
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
)

_smod1 = Airscale([_fct_1])
_smod2 = Airscale([_fct_2])

_enb_sbts1 = RealEnb(system_module=_smod1, rms=[_rmod_1])
_enb_sbts2 = RealEnb(system_module=_smod2, rms=[_rmod_1])


_appserver_ssh = SshServiceDetails(
    addr="10.69.64.196", username="tdlte-tester", password="btstest"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.197",
    iperf_path="iperf",
)
_appserver = AppServer(iperf_details=_iperf)

_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.152.68", username="ute", password="ute"
    ),
    connections=[_enb_sbts1.system_module.common_units[0], NetworkAddress(v4="192.168.255.126")],
)

_test_pc2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.152.71", username="ute", password="ute"
    ),
    connections=[_enb_sbts2.system_module.common_units[0], NetworkAddress(v4="192.168.255.126")],
)


tl = TestLine(
    test_pc=_test_pc1,
    test_pcs=[_test_pc1, _test_pc2],
    enbs=[_enb_sbts1, _enb_sbts2],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_RF_AILR_B1_B6_AAHC_CA",
)

__all__ = ["tl"]
