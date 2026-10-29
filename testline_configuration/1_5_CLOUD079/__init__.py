__owner__ = "Di Zheng"
__maintainer__ = "Di Zheng"
__email__ = "zheng.di@nokia-sbell.com"

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
        addr="10.106.233.222", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = FACOM(
    addr="10.56.7.139",
    port_numbers=[6],
    model="facom",
)

_pdu_2 = FACOM(
    addr="10.56.7.141",
    port_numbers=[4, 5, 6],
    model="facom",
)

_pdu_3 = FACOM(
    addr="10.56.7.224",
    port_numbers=[3, 4, 5],
    model="facom",
)

_pdu_4 = FACOM(
    addr="10.56.7.241",
    port_numbers=[4, 5, 7],
    model="facom",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.18",
    hardware_type="FBIH",
    hardware_version="472568A.101",
    serial_number="EA160721262",
    pdu_port=_pdu_1.pdu_ports[6],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.19",
    hardware_type="FBIH",
    hardware_version="472568A.101",
    serial_number="EA160721259",
    pdu_port=_pdu_1.pdu_ports[6],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="FSIH",
    hardware_version="472567A",
    serial_number="EA173902555",
    capacity_units=[_fsp_1, _fsp_2],
)

_smod = Flexi([_fct_1])

_rmod_1 = RU(
    ru_hw_group="FZHJ:T222_L_91_8TX_8RX",
    serial_number="RY143727301",
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_2 = RU(
    ru_hw_group="FZHJ:T222_L_91_8TX_8RX",
    serial_number="RY142030659",
    pdu_port=_pdu_2.pdu_ports[5],
)

_rmod_3 = RU(
    ru_hw_group="FZHJ:T222_L_91_8TX_8RX",
    serial_number="RY142006825",
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_8 = RU(
    ru_hw_group="FZHN:T222_L_91_8TX_8RX",
    serial_number="6Q173304760",
    pdu_port=_pdu_3.pdu_ports[4],
)

_rmod_9 = RU(
    ru_hw_group="FZHN:T222_L_91_8TX_8RX",
    serial_number="RY161703914",
    pdu_port=_pdu_3.pdu_ports[5],
)

_rmod_4 = RU(
    ru_hw_group="FZHN:1e3_D_F",
    serial_number="6Q183612560",
    pdu_port=_pdu_3.pdu_ports[3],
)

_rmod_5 = RU(
    ru_hw_group="FZFF-e:701",
    serial_number="11BYU10F4000034",
    pdu_port=_pdu_4.pdu_ports[7],
)

_rmod_6 = RU(
    ru_hw_group="FZFF-e:701",
    serial_number="11BYU6TH9402351",
    pdu_port=_pdu_4.pdu_ports[5],
)

_rmod_7 = RU(
    ru_hw_group="FZFF-e:701",
    serial_number="11BYU6TEC400436",
    pdu_port=_pdu_4.pdu_ports[4],
)

_enb_sbts = RealEnb(
    system_module=_smod,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
        _rmod_6,
        _rmod_7,
        _rmod_8,
        _rmod_9,
    ],
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_RF_FHBB_CRT1_1079",
)

__all__ = ["tl"]
