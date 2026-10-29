__owner__ = "Xu Derek"
__maintainer__ = "Xu Derek"
__email__ = "derek.xu@nokia-sbell.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, FACOM, HBTE
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails
from taf.config.testline import DU
from taf.config.testline.gnb import CU, ClassicalBts

_pdu_1 = FACOM(
    addr="10.108.190.66",
    port_numbers=[3],
)

_pdu_2 = HBTE(
    addr="10.108.190.67",
    port_numbers=[2],
)


_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIC",
    hardware_version="A.101",
    serial_number="6Q191328438",
    pdu_port=_pdu_1.pdu_ports[3],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIC",
    hardware_version="A.102",
    serial_number="6Q194907049",
    pdu_port=_pdu_1.pdu_ports[3],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIC",
    hardware_version="A.102",
    serial_number="6Q194907048",
    pdu_port=_pdu_1.pdu_ports[3],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1190608730",
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
)

_smod = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="AAHF:CPRI_A_RRH_64T64R",
    serial_number="6Q184603086",
    pdu_port=_pdu_2.pdu_ports[2],
    radio_type="AAHF",
)

_enb_sbts = RealEnb(system_module=_smod, rms=[_rmod_1])

_appserver_ssh = SshServiceDetails(
    addr="10.69.64.196", username="tdlte-tester", password="btstest"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.197",
    iperf_path="iperf",
)
_appserver = AppServer(iperf_details=_iperf)

_du= DU(
    airscale=_smod, rus=[_rmod_1], f1_m_ip_addr="192.168.255.1"
)

_cu = CU(
    backhaul_site_oam_ip="192.168.255.1",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
)

_classical_bts = ClassicalBts(
    dus=[_du], cu=_cu, instance_id=6077, global_bts_id=6077
)


_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.181.96", username="ute", password="ute"
    ),
    connections=[_classical_bts.dus[0].airscale.common_units[0]],
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ASIB_ABIC_AAHF_1_5_UTE4G116",
)

__all__ = ["tl"]
