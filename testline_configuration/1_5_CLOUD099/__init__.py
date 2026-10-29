__owner__ = "vera he"
__maintainer__ = "vera he"
__email__ = "vera.he@nokia-sbell.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, FACOM, HBTE, TopYoung
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails

_pdu_1 = FACOM(
    addr="10.68.94.33",
    port_numbers=[5],
)

_pdu_2 = TopYoung(
    addr="10.68.94.28",
    port_numbers=[1],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1233402619",
    product_code="475765A.104",
    pdu_port=_pdu_1.pdu_ports[5],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1233402619",
    capacity_units=[_fsp_1],
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

_smod = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="AKHD:eCPRI_RRH_8T8R",
    radio_type="AKHD",
    serial_number="4H240360132",
    pdu_port=_pdu_2.pdu_ports[1],
)

_enb_sbts = RealEnb(system_module=_smod, rms=[_rmod_1])

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.233.235", username="ute", password="ute"
    ),
    connections=[
        _enb_sbts.system_module.common_units[0],
        NetworkAddress(v4="192.168.255.126"),
    ],
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIB_ABIO_AEHB_CLOUD099",
)

__all__ = ["tl"]
