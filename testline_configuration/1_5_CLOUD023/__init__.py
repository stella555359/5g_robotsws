__owner__ = "Lou Xingxin"
__maintainer__ = "Lou Xingxin"
__email__ = "xingxin.lou@nokia-sbell.com"

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

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.213.124", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = FACOM(
    addr="10.56.7.125",
    port_numbers=[3],
    model="facom",
)

_pdu_2 = FACOM(
    addr="10.56.7.187",
    port_numbers=[2],
    model="facom",
)


_fsp_1 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="A.101",
    serial_number="L1162411979",
    pdu_port=_pdu_2.pdu_ports[2],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.25",
    hardware_type="ABIA",
    hardware_version="A.101",
    serial_number="L1162411986",
    pdu_port=_pdu_2.pdu_ports[2],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_2.pdu_ports[2],
    hardware_type="ASIA",
    hardware_version="A.101",
    serial_number="L1162013351",
    capacity_units=[_fsp_1, _fsp_2],
)

_smod = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="FRMTDr5.1_1_4T4R",
    serial_number="6Q185142184",
    pdu_port=_pdu_1.pdu_ports[3],
)

_appserver_ssh = SshServiceDetails(
    addr="10.69.64.196", username="tdlte-tester", password="btstest"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.197",
    iperf_path="iperf",
)
_appserver = AppServer(iperf_details=_iperf)

_enb_sbts = RealEnb(system_module=_smod, rms=[_rmod_1])

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_RF_AIR_B1-B2_CRT1_1023",
)

__all__ = ["tl"]
