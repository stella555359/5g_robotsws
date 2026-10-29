__owner__ = "Wang Deli"
__maintainer__ = "Wang Deli"
__email__ = "deli.wang@nokia-sbell.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, FACOM, APC, HBTE, TopYoung
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import AppServer, IperfDataTransferDetails

_pdu_1 = TopYoung(
    addr="10.108.190.4",
    port_numbers=[5],
    # model="JieXi"
)

_pdu_2 = HBTE(
    addr="10.108.190.2",
    port_numbers=[1, 2, 4],
    # model="JieXi"
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="6Q174907907",
    pdu_port=_pdu_1.pdu_ports[5],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233704784",
    pdu_port=_pdu_1.pdu_ports[5],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1,_fsp_2],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1241210715",
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

_smod_1 = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="AZNA",
    radio_type="AZNA",
    serial_number="6Q190208576",
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_2 = RU(
    ru_hw_group="AZNA",
    radio_type="AZNA",
    serial_number="6Q174625278",
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_3 = RU(
    ru_hw_group="AZHA",
    radio_type="AZHA",
    serial_number="6Q173107053",
    pdu_port=_pdu_2.pdu_ports[2],
)

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3])
# _enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_3, _rmod_4, _rmod_5], master=_enb_sbts_1)
# _enb_sbts_1.slave = _enb_sbts_2

# tl = TestLine(test_pc=_test_pc_1, test_pcs=[_test_pc_1, _test_pc_2], enbs=[_enb_sbts_1, _enb_sbts_2])
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.181.33", username="ute", password="uteUTE!"
    ),
    connections=[
        _enb_sbts_1.system_module.common_units[0],
        NetworkAddress(v4="192.168.255.126"),
    ],
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts_1],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_RF_AIL_B1_B3_1026",
)

__all__ = ["tl"]
