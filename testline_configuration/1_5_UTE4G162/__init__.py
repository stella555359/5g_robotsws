__owner__ = "Lou Xingxin"
__maintainer__ = "Lou Xingxin"
__email__ = "xingxin.lou@nokia-sbell.com"

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

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.198.190", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.198.193", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = HBTE(
    addr="10.106.198.47",
    port_numbers=[1, 2, 3, 4, 5],
    model="hbte",
)

_pdu_2 = HBTE(
    addr="10.106.198.48",
    port_numbers=[2, 3, 5],
    model="hbte",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="A.101",
    serial_number="L1204101505",
    pdu_port=_pdu_1.pdu_ports[3],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIN",
    hardware_version="A.101",
    serial_number="L1204212517",
    pdu_port=_pdu_1.pdu_ports[5],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1203700845",
    capacity_units=[_fsp_1],
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1203700862",
    capacity_units=[_fsp_2],
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

# AZQF
_rmod_1 = RU(
    ru_hw_group="FRMTDr5.1a_1_8T8R",
    serial_number="K9212813825",
    pdu_port=_pdu_2.pdu_ports[5],
)

# AZNA
_rmod_2 = RU(
    ru_hw_group="FRMTDr5.1_1_4T4R",
    serial_number="L1162105358",
    pdu_port=_pdu_2.pdu_ports[3],
)

# AZHA
_rmod_3 = RU(
    ru_hw_group="ScRMTDr6.1_4T4R",
    serial_number="6Q184821654",
    pdu_port=_pdu_2.pdu_ports[2],
)

# AZHL
_rmod_4 = RU(
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    serial_number="AH211900775",
    pdu_port=_pdu_1.pdu_ports[4],
)

# AZHL
_rmod_5 = RU(
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    serial_number="AH211600356",
    pdu_port=_pdu_1.pdu_ports[1],
)

# AZHL
_rmod_6 = RU(
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    serial_number="AH211900777",
    pdu_port=_pdu_1.pdu_ports[2],
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

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_6, _rmod_5])
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_3])
tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_RF_AILR_B1_B4_CRT2_1162",
)

__all__ = ["tl"]
