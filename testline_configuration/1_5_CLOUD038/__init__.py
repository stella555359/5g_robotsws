__owner__ = "Sheng Haoyun"
__maintainer__ = "Sheng Haoyun"
__email__ = "haoyun-lyle.sheng@nokia-sbell.com"

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
        addr="10.108.152.69", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = HBTE(
    addr="10.108.151.63",
    port_numbers=[6],
    model="hbte",
)

_pdu_2 = FACOM(
    addr="10.108.151.28",
    port_numbers=[5],
    model="facom",
)


_fsp_1 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIC",
    hardware_version="474723A.101",
    serial_number="6Q191328394",
    pdu_port=_pdu_2.pdu_ports[5],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_2.pdu_ports[5],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH212076845",
    capacity_units=[_fsp_1],
)

_smod = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="AAHF:cMAA_Gen3.14_64T64R",
    serial_number="6Q184131115",
    pdu_port=_pdu_1.pdu_ports[6],
)

_enb_sbts = RealEnb(system_module=_smod, rms=[_rmod_1])

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_RF_AIL_B1-3_CRT1_1038",
)

__all__ = ["tl"]
