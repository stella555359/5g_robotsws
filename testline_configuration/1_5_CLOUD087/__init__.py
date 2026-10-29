__owner__ = "Ding Lisa"
__maintainer__ = "Ding Lisa"
__email__ = "lisa.ding@nokia-sbell.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, FACOM, HBTE, FPFH
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


_pdu_1 = FACOM(
    addr="10.108.151.83",
    port_numbers=[7],
)

_pdu_2 = HBTE(
    addr="10.108.151.81",
    port_numbers=[1, 2],
)

_pdu_3 = FPFH(
    addr="10.108.164.133",
    port_numbers=[2],
)

_rmod_1 = RU(
    ru_hw_group="AEHC:ECPRI_RRH_64T64R",
    serial_number="L1213414034",
    radio_type="AEHB",
    pdu_port=_pdu_3.pdu_ports[2],
)

_rmod_2 = RU(
    ru_hw_group="AEHC:ECPRI_RRH_64T64R",
    serial_number="L1210602522",
    radio_type="AEHC",
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_3 = RU(
    ru_hw_group="AEHB:ECPRI_RRH_64T64R",
    serial_number="L1213414036",
    radio_type="AEHB",
    pdu_port=_pdu_2.pdu_ports[2],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIC",
    hardware_version="474723A.102",
    serial_number="6Q194300522",
    pdu_port=_pdu_1.pdu_ports[7],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIC",
    hardware_version="474723A.102",
    serial_number="6Q194504526",
    pdu_port=_pdu_1.pdu_ports[7],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIC",
    hardware_version="474723A.102",
    serial_number="6Q194907057",
    pdu_port=_pdu_1.pdu_ports[7],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH203864245",
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
)

_smod = Airscale([_fct_1])

_enb_sbts = RealEnb(system_module=_smod, rms=[_rmod_1, _rmod_2, _rmod_3])
#_enb_sbts = RealEnb(system_module=_smod, rms=[])

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.152.85", username="ute", password="ute"
    ),
    connections=[_enb_sbts.system_module.common_units[0], NetworkAddress(v4="192.168.255.126")],
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_RF_AIL_B1_B3_3xAEHC_B",
)


__all__ = ["tl"]
