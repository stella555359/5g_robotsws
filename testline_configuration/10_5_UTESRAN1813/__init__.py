__maintainer__ = "Yuyan Xu"
__email__ = "yuyan.xu@nokia-sbell.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import FACOM, PduPort, Pdu, EPC, RRB, APC, Gude, FPFH
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.gnb.networkaddress import NetworkAddress


_pdu_1 = FACOM(addr="10.106.253.44", port_numbers=[1, 2, 3, 4, 5, 6])
_pdu_2 = FACOM(addr="10.106.253.43", port_numbers=[1, 2, 3, 4, 5, 6])
_pdu_3 = FACOM(addr="10.106.253.39", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    radio_type=RadioTypes.AHGB.value,
    serial_number="EB204260890",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[8],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    radio_type=RadioTypes.AHEJ.value,
    serial_number="EB192460155",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_3 = RU(
    ru_hw_group="ScRMTDr6.2_4T4R",
    radio_type=RadioTypes.AWHQU.value,
    serial_number="EB2313R0194",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.17.1.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASOF",
    hardware_version="A.101",
    serial_number="EA232850564",
    capacity_units=[],
)


_smod_1 = Flexi([_fct_1])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_2],
    oam_ip=NetworkAddress("10.68.190.71"),
    instance_id=1813,
)

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.68.161.92", username="ute"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=[_test_pc_1],
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_NL_1813_1ASOF_1AHGB_1AHEJ_1AWHQU",
)

__all__ = ["tl"]
