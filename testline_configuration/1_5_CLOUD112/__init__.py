__owner__ = "Hu Shenghong"
__maintainer__ = "Hu Shenghong"
__email__ = "shenghong.hu@nokia-sbell.com"

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
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import CU, ClassicalBts


_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.233.241", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = FACOM(
    addr="10.56.7.169",
    port_numbers=[1],
    model="facom",
)


_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="L1173811670",
    pdu_port=_pdu_1.pdu_ports[1],
)


_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="A.102",
    serial_number="L1164017777",
    pdu_port=_pdu_1.pdu_ports[1],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH203864233",
    capacity_units=[_fsp_1, _fsp_2],
)

_smod = Airscale([_fct_1])

_enb_sbts = RealEnb(system_module=_smod, rms=[])

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
    tl_cloud_topology="CLOUD_RF_AIL_B1_CRT2_1112",
)

__all__ = ["tl"]
