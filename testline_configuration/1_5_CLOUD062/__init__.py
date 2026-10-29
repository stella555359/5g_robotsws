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
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.233.210", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = FACOM(
    addr="10.69.66.103",
    port_numbers=[2, 3],
    model="facom",
)

_pdu_2 = FACOM(
    addr="10.56.7.128",
    port_numbers=[4],
    model="facom",
)


_fsp_1 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="AH173607797",
    pdu_port=_pdu_1.pdu_ports[2],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1181010686",
    capacity_units=[_fsp_1],
)

_smod = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="UZFB:CPRI_A_RRH_8T8R",
    serial_number="YP160203499",
    pdu_port=_pdu_1.pdu_ports[3],
)

_rmod_2 = RU(
    ru_hw_group="FZHR:CPRI_N_RRH_8T8R",
    serial_number="6Q163504149",
    pdu_port=_pdu_2.pdu_ports[4],
)

_enb_sbts = RealEnb(system_module=_smod, rms=[_rmod_1, _rmod_2])

_appserver_ssh = SshServiceDetails(
    addr="10.69.64.196", username="tdlte-tester", password="btstest"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.197",
    iperf_path="iperf",
)
_appserver = AppServer(iperf_details=_iperf)


tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_RF_AIL_B1_CRT2_1062",
)

__all__ = ["tl"]
