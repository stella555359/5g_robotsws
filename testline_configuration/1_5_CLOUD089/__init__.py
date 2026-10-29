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
from taf.config.testline.pdu import HBTE, FACOM
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails

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
        addr="10.108.152.87", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = FACOM(
    addr="10.108.151.83",
    port_numbers=[8],
    model="facom",
)

_pdu_2 = HBTE(
    addr="10.108.151.133",
    port_numbers=[1],
    model="hbte",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA184380540",
    pdu_port=_pdu_1.pdu_ports[8],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="AH173607810",
    pdu_port=_pdu_1.pdu_ports[8],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="AH173607811",
    pdu_port=_pdu_1.pdu_ports[8],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIB",
    hardware_version="473764A.101",
    serial_number="L1182811442",
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
)

_smod = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="AENB:CPRI_RP1",
    serial_number="1M212306543",
    pdu_port=_pdu_2.pdu_ports[1],
)

_enb_sbts = RealEnb(system_module=_smod, rms=[_rmod_1])

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_RF_FHB_3xUZHC",
)

__all__ = ["tl"]
