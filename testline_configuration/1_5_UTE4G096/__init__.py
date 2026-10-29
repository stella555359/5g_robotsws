__maintainer__ = "qianzhou"
__owner_email__ = "qiang.1.zhou@nokia-sbell.com"
__email__ = "qiang.1.zhou@nokia-sbell.com"

from taf.config.testline.airscale import CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import FACOM
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails


_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.233.232", username="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu = FACOM(addr="10.56.7.169", port_numbers=[6], model="facom")

_fsp_1 = CapacityUnit(
    addr="192.168.253.18",
    hardware_type="FBBA",
    hardware_version="472182A.101",
    serial_number="L6132121344",
    pdu_port=_pdu.pdu_ports[6],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.18",
    hardware_type="FBBA",
    hardware_version="	472182A.101",
    serial_number="L1124700137",
    pdu_port=_pdu.pdu_ports[6],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu.pdu_ports[6],
    hardware_type="FSMF",
    hardware_version="472181A",
    serial_number="L1124508680",
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

_smod = Flexi([_fct_1])

_enb_sbts = RealEnb(system_module=_smod, rms=[])


tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_RF_F_CRT2_1096",
)


__all__ = ["tl"]
