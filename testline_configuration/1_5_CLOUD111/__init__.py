__owner__ = "Hu Shenghong"
__maintainer__ = "Hu Shenghong"
__email__ = "shenghong.hu@nokia-sbell.com"

from taf.config.testline.airscale import CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.flexi import Flexi
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, FACOM, FPFH, HBTE
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)

from taf.config.testline.gnb import CU, ClassicalBts

_pdu_1 = FACOM(
    addr="10.56.7.169",
    port_numbers=[3],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="FBIH",
    hardware_version="A.101",
    serial_number="L6145015119",
    pdu_port=_pdu_1.pdu_ports[3],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="FBIH",
    hardware_version="A.101",
    serial_number="EA174511972",
    pdu_port=_pdu_1.pdu_ports[3],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="FSIH",
    hardware_version="A.102",
    serial_number="EA170136211",
    capacity_units=[_fsp_1, _fsp_2],
)

_smod = Flexi([_fct_1])


_enb_sbts = RealEnb(system_module=_smod, rms=[])

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.233.240", username="ute", password="ute"
    ),
    connections=[
        _enb_sbts.system_module.common_units[0],
        NetworkAddress(v4="192.168.255.126"),
    ],
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

_appserver_ssh = SshServiceDetails(
    addr="10.69.64.197",
    username="tdlte-tester",
    password="btstest",
)
_android_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.196",
    iperf_path="iperf",
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_4G_CLASSICAL_FSIH_FBIH_AZND_AZNE",
)

__all__ = ["tl"]
