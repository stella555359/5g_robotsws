__owner__ = "Di Zheng"
__maintainer__ = "Di Zheng"
__email__ = "zheng.di@nokia-sbell.com"

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
        addr="10.106.233.221", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = FACOM(
    addr="10.56.7.223",
    port_numbers=[2, 3],
    model="facom",
)

_pdu_2 = FACOM(
    addr="10.56.7.224",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="facom",
)

_pdu_4 = FACOM(
    addr="10.56.7.241",
    port_numbers=[6],
    model="facom",
)

_pdu_5 = FACOM(
    addr="10.56.7.230",
    port_numbers=[2, 4, 5, 6],
    model="facom",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1165205630",
    pdu_port=_pdu_2.pdu_ports[1],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1165205607",
    pdu_port=_pdu_2.pdu_ports[1],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="AH173607762",
    pdu_port=_pdu_2.pdu_ports[1],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_2.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="473764A.101",
    serial_number="L1182811210",
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
)

_smod = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="AZHA:T111111-M-47-4TX-4RX",
    serial_number="6Q173802804",
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_2 = RU(
    ru_hw_group="AZNA:T111111-M-47-4TX-4RX",
    serial_number="6Q173104574",
    pdu_port=_pdu_2.pdu_ports[7],
)

_rmod_3 = RU(
    ru_hw_group="AZNA:T111111-M-47-4TX-4RX",
    serial_number="6Q172911045",
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_4 = RU(
    ru_hw_group="FZHN:T111-L-765-8TX-8RX",
    serial_number="6Q183612560",
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_5 = RU(
    ru_hw_group="FZHN:T111-L-765-8TX-8RX",
    serial_number="6Q173304760",
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_6 = RU(
    ru_hw_group="FZHN:T111-L-765-8TX-8RX",
    serial_number="RY161703914",
    pdu_port=_pdu_2.pdu_ports[5],
)

_rmod_7 = RU(
    ru_hw_group="AZNC:T222-M-44-4TX-4RX",
    serial_number="6Q180811686",
    pdu_port=_pdu_1.pdu_ports[2],
)

_rmod_8 = RU(
    ru_hw_group="AZNC:T222-M-44-4TX-4RX",
    serial_number="6Q180602860",
    pdu_port=_pdu_1.pdu_ports[3],
)

_rmod_9 = RU(
    ru_hw_group="AZQE:8TX-8RX",
    serial_number="6Q190108273",
    pdu_port=_pdu_2.pdu_ports[8],
)

_rmod_11 = RU(
    ru_hw_group="AZQF:8TX-8RX",
    serial_number="6Q182328544",
    pdu_port=_pdu_4.pdu_ports[6],
)

_rmod_12 = RU(
    ru_hw_group="FZNJ:T111111-M-47-4TX-4RX",
    serial_number="RY163500063",
    pdu_port=_pdu_5.pdu_ports[6],
)

_rmod_13 = RU(
    ru_hw_group="FZNI:T111111-M-47-4TX-4RX",
    serial_number="RY130914712",
    pdu_port=_pdu_5.pdu_ports[4],
)

_rmod_14 = RU(
    ru_hw_group="FZNJ:T111111-M-47-4TX-4RX",
    serial_number="RY163500057",
    pdu_port=_pdu_5.pdu_ports[5],
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
        _rmod_11,
        _rmod_12,
        _rmod_13,
        _rmod_14,
    ],
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_RF_AIBR_B4_B6_1078",
)

__all__ = ["tl"]
