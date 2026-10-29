__owner__ = "Wu Nick"
__maintainer__ = "Wu Nick"
__email__ = "nick.1.wu@nokia-sbell.com"

from taf.config.testline.airscale import Airscale
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.appserver import AppServer
from taf.config.testline.connection_details import (
    SshServiceDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import FACOM, HBTE
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc

_pdu_1 = HBTE(
    addr="10.108.151.63", port_numbers=[1], model="hbte"
)  # AAHF1:1
_pdu_2 = HBTE(
    addr="10.108.151.133", port_numbers=[1, 3, 4], model="hbte"
)  # AAHF2:4, AAHF:3, AAHF:1
_pdu_3 = FACOM(
    addr="10.108.151.66", port_numbers=[1, 2], model="facom"
)  # ASIB LEFT:1, ASIB RIGHT:2
#_pdu_4 = FACOM(addr="10.108.151.102", port_numbers=[1], model="facom")  # 3ABIC RIGHT
#_pdu_5 = FACOM(addr="10.108.151.28", port_numbers=[6], model="facom")  # 3ABIC LEFT

# ABIC LEFT
_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIC",
    hardware_version="474723A.102",
    serial_number="6Q194907045",
    pdu_port=_pdu_3.pdu_ports[1],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIC",
    hardware_version="474723A.102",
    serial_number="6Q194504526",
    pdu_port=_pdu_3.pdu_ports[1],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIC",
    hardware_version="474723A.102",
    serial_number="6Q194907046",
    pdu_port=_pdu_3.pdu_ports[1],
)
# ABIC RIGHT
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIC",
    hardware_version="474723A.102",
    serial_number="6Q194300522",
    pdu_port=_pdu_3.pdu_ports[2],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIC",
    hardware_version="474723A.102",
    serial_number="6Q194907051",
    pdu_port=_pdu_3.pdu_ports[2],
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIC",
    hardware_version="474723A.102",
    serial_number="6Q194907057",
    pdu_port=_pdu_3.pdu_ports[2],
)
# ASIB LEFT
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1",
        username="toor4nsn",
        password="oZPS0POrRieRtu",
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_3.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH212971861",
)
# ASIB RIGHT
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1",
        username="toor4nsn",
        password="oZPS0POrRieRtu",
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_3.pdu_ports[2],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH212076873",
)
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="AAHF:CPRI",
    serial_number="6Q183517961",
    pdu_port=_pdu_1.pdu_ports[1],
)  # AAHF1
_rmod_2 = RU(
    ru_hw_group="AAHF:CPRI",
    serial_number="1M194603257",
    pdu_port=_pdu_2.pdu_ports[4],
)  # AAHF2
_rmod_3 = RU(
    ru_hw_group="AAHF:CPRI",
    serial_number="1M203310623",
    pdu_port=_pdu_2.pdu_ports[3],
)  # AAHF
_rmod_4 = RU(
    ru_hw_group="AAHF:CPRI",
    serial_number="1M194201625",
    pdu_port=_pdu_2.pdu_ports[1],
)  # AAHF

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2])
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_3, _rmod_4], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.108.151.227", username="ute", password="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.108.151.228", username="ute", password="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_appserver_ssh = SshServiceDetails(
    addr="10.69.64.196", username="tdlte-tester", password="btstest"
)

_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.64.197",
    iperf_path="iperf",
    port=22,
)

_appserver = AppServer(_iperf_details_on_appserver)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_RF_AILR_B1_B6_ABIC_mMIMO_1124",
)
__all__ = ["tl"]
