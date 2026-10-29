__owner__ = "Wu Amy"
__maintainer__ = "Wu Amy"
__email__ = "amy.wu@nokia-sbell.com"

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


_pdu_1 = FACOM(
    addr="10.56.7.211",
    port_numbers=[1, 2],
)

_rmod_1 = RU(
    ru_hw_group="CPRI_A_RRH_4T4R",
    radio_type="AZQC",
    serial_number="AH220901320",
    pdu_port=_pdu_1.pdu_ports[2],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="A.102",
    serial_number="L1204706784",
    pdu_port=_pdu_1.pdu_ports[1],
    rus=[_rmod_1],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="A.101",
    serial_number="L1182413287",
    capacity_units=[_fsp_1],
)

_smod = Airscale([_fct_1])

_enb_sbts = RealEnb(system_module=_smod, rms=[_rmod_1])

_appserver_ssh = SshServiceDetails(
    addr="10.69.64.196", username="tdlte-tester", password="btstest"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.197",
    iperf_path="iperf",
)
_appserver = AppServer(iperf_details=_iperf)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.233.212", username="ute", password="ute"
    ),
    connections=[_enb_sbts.system_module.common_units[0], NetworkAddress(v4="192.168.255.126")],
)


tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_RF_AIR_B4_CRT_1064",
)

__all__ = ["tl"]
