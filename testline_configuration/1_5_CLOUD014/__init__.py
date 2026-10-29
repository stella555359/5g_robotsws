__owner__ = "Liu Xiaoyi"
__maintainer__ = "Liu Xiaoyi"
__email__ = "xiaoyi.liu@nokia-sbell.com "

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
        addr="10.106.213.86", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = FACOM(
    addr="10.56.7.223",
    port_numbers=[7],
    model="facom",
)

_pdu_2 = FACOM(
    addr="10.106.211.82",
    port_numbers=[1, 8],
    model="facom",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="K9174042736",
    pdu_port=_pdu_1.pdu_ports[7],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIA",
    hardware_version="A.104",
    serial_number="L1181010704",
    capacity_units=[_fsp_1],
)

_smod = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="FZHJ:FRMTDr3.0_8T8R",
    serial_number="RY143210580",
    pdu_port=_pdu_2.pdu_ports[8],
)

_rmod_2 = RU(
    ru_hw_group="FZNI:FRMTDr2.2_4T4R",
    serial_number="RY130213418",
    pdu_port=_pdu_2.pdu_ports[1],
)
_enb_sbts = RealEnb(system_module=_smod, rms=[_rmod_1, _rmod_2])

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_RF_AIR_B4_CRT1_1014_FZHJ_FZNI",
)

__all__ = ["tl"]
