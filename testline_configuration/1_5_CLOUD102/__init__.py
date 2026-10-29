__owner__ = "Xu Derek"
__maintainer__ = "Xu Derek"
__email__ = "derek.xu@nokia-sbell.com"

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

_pdu_2 = HBTE(
    addr="10.69.65.231",
    port_numbers=[1, 2, 3, 4],
)

_pdu_1 = FACOM(
    addr="10.69.65.228",
    port_numbers=[1, 2, 3],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIO",
    hardware_version="A.104",
    serial_number="L1214206734",
    pdu_port=_pdu_1.pdu_ports[1],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH212562897",
    capacity_units=[_fsp_1],
)

_smod = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="AZNA:CPRI_A_RRH_4T4R",
    serial_number="6Q172911040",
    pdu_port=_pdu_1.pdu_ports[2],
)

_rmod_2 = RU(
    ru_hw_group="AZNA:CPRI_A_RRH_4T4R",
    serial_number="6Q172714283",
    pdu_port=_pdu_1.pdu_ports[3],
)

_rmod_3 = RU(
    ru_hw_group="AZNA:CPRI_A_RRH_4T4R",
    serial_number="6Q174305567",
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_4 = RU(
    ru_hw_group="AZNA:CPRI_A_RRH_4T4R",
    serial_number="6Q172819557",
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_5 = RU(
    ru_hw_group="AZNA:CPRI_A_RRH_4T4R",
    serial_number="6Q174305554",
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_6 = RU(
    ru_hw_group="AZNA:CPRI_A_RRH_4T4R",
    serial_number="6Q173104567",
    pdu_port=_pdu_2.pdu_ports[3],
)

_enb_sbts = RealEnb(
    system_module=_smod, rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6]
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

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.211.236", username="ute", password="ute"
    ),
    connections=[_smod.common_units[0]],
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_4G_CLASSICAL_ASIBR_ABIOB1_6xAZNA",
)

__all__ = ["tl"]

