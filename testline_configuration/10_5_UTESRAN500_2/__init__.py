# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "xiaochen"
__team__ = "MN_RAN_PZ_1_HAZ_12"
__email__ = "xiaofei.chen@nokia-sbell.com"
__owner_email__ = "xiaofei.chen@nokia-sbell.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, TopYoung, FACOM, FPFH, HBTE
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc

_pdu_1 = FPFH(
    addr="10.68.179.198",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    login="admin",
    password="admin",
)
_pdu_2 = HBTE(
    addr="10.68.170.184",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
)
_pdu_3 = HBTE(
    addr="10.68.179.243",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
)
_pdu_4 = HBTE(
    addr="10.68.179.244",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
)
_pdu_5 = FACOM(
    addr="10.68.170.178",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
)


_rmod_1 = RU(
    ru_hw_group="FRMr3.2_8T8R",
    serial_number="6Q163303544",
    radio_type=RadioTypes.FZHN,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.12.2", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)


_rmod_2 = RU(
    ru_hw_group="cMAA_Gen4.0_8T8R_eCPRI",
    serial_number="EA194560004",
    radio_type=RadioTypes.AZQL,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.1.166", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[5],
)

_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="BL2003G10V9",
    radio_type=RadioTypes.AHLOA,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.12.1", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[1],
)


_fsp_1 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="EA200950277",
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="K9172230598",
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="K9172148288",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_5.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH203864241",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIA",
    hardware_version="A.102",
    serial_number="K9173058498",
)
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_2,
    ],
    oam_ip=NetworkAddress("10.68.179.210"),
    instance_id=817,
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_1, _rmod_3], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.56.127.2", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.56.127.14", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NL_1ASIB_1ABIL_1ASIA_2ABIA_1FZHN_1AZQL_1AHLOA_817",
)

__all__ = ["tl"]
