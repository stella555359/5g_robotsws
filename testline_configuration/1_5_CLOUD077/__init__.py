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

_pdu_1 = FACOM(
    addr="10.56.7.139",
    port_numbers=[7],
    #    model="facom",
)

_pdu_2 = FACOM(
    addr="10.56.7.224",
    port_numbers=[2, 3, 4, 5, 6, 7],
    #    model="facom",
)

_pdu_3 = FACOM(
    addr="10.56.7.230",
    port_numbers=[4, 5, 6],
    #    model="facom",
)

_pdu_4 = FACOM(
    addr="10.56.7.223",
    port_numbers=[2],
    #    model="facom",
)

_rmod_1 = RU(
    ru_hw_group="FZHN:T111-L-765-8TX-8RX",
    radio_type="FZHN",
    serial_number="6Q183612560",
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_2 = RU(
    ru_hw_group="FZHN:T111-L-765-8TX-8RX",
    radio_type="FZHN",
    serial_number="6Q173304760",
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_3 = RU(
    ru_hw_group="FZHN:T111-L-765-8TX-8RX",
    radio_type="FZHN",
    serial_number="RY161703914",
    pdu_port=_pdu_2.pdu_ports[5],
)

_rmod_4 = RU(
    ru_hw_group="AZHA:T111111-M-47-4TX-4RX",
    radio_type="AZHA",
    serial_number="6Q173802804",
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_5 = RU(
    ru_hw_group="AZNA:T111111-M-47-4TX-4RX",
    radio_type="AZAN",
    serial_number="6Q173104574",
    pdu_port=_pdu_2.pdu_ports[7],
)

_rmod_6 = RU(
    ru_hw_group="AZNA:T111111-M-47-4TX-4RX",
    radio_type="AZNA",
    serial_number="6Q172911045",
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_7 = RU(
    ru_hw_group="FZNJ:T111111-M-47-4TX-4RX",
    radio_type="FZNJ",
    serial_number="RY163500063",
    pdu_port=_pdu_3.pdu_ports[6],
)

_rmod_8 = RU(
    ru_hw_group="FZNI:T111111-M-47-4TX-4RX",
    radio_type="FZNI",
    serial_number="RY130914712",
    pdu_port=_pdu_3.pdu_ports[4],
)

_rmod_9 = RU(
    ru_hw_group="FZNJ:T111111-M-47-4TX-4RX",
    radio_type="FZNJ",
    serial_number="RY163500057",
    pdu_port=_pdu_3.pdu_ports[5],
)

_rmod_10 = RU(
    ru_hw_group="AZNC:T222-M-44-4TX-4RX",
    radio_type="AZNC",
    serial_number="6Q180811686",
    pdu_port=_pdu_4.pdu_ports[2],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.18",
    hardware_type="FBBA",
    hardware_version="472182A.102",
    serial_number="L9130900625",
    pdu_port=_pdu_1.pdu_ports[7],
    rus=[_rmod_2],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.19",
    hardware_type="FBBA",
    hardware_version="472182A.101",
    serial_number="L9123101675",
    pdu_port=_pdu_1.pdu_ports[7],
    rus=[_rmod_3],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[7],
    rus=[_rmod_1, _rmod_2, _rmod_3],
    hardware_type="FSMF",
    hardware_version="472181A",
    serial_number="L1131508826",
    capacity_units=[_fsp_1, _fsp_2],
)

_smod = Flexi([_fct_1])

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
        _rmod_10,
    ],
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.233.220", username="ute", password="ute"
    ),
    connections=[_enb_sbts.system_module.common_units[0], NetworkAddress(v4="192.168.255.126")],
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_RF_FAA_FZHN_AZNA_FZNI",
)

__all__ = ["tl"]
