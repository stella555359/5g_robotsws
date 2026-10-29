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

_pdu_1 = HBTE(
    addr="10.97.92.21",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
)
_pdu_2 = HBTE(
    addr="10.97.92.29",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
)
_pdu_3 = HBTE(
    addr="10.97.97.170",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
)
_pdu_4 = FPFH(
    addr="10.97.97.155",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    login="admin",
    password="admin",
    model="FPFH",
)

_rmod_1 = RU(
    ru_hw_group="RRH5.1",
    serial_number="BL2004G10Z7",
    radio_type=RadioTypes.AHLOA,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.18", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_2 = RU(
    ru_hw_group="RRH5.1",
    serial_number="BL1934G10VJ",
    radio_type=RadioTypes.AHLOA,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.18", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_3 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    serial_number="BL2049V0VKV",
    radio_type=RadioTypes.AHFIB,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    serial_number="BL2032V0I54",
    radio_type=RadioTypes.AHFIB,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[4],
)

_rmod_5 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    serial_number="L1210602523",
    radio_type=RadioTypes.AEHC,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[1],
)
_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="474824A.103",
    serial_number="L1204214699",
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA183241557",
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIP",
    hardware_version="473096A.103",
    serial_number="L1174603748",
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIP",
    hardware_version="474824A.103",
    serial_number="L1214311469",
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1233304522",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4],
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASIM",
    hardware_version="A.102",
    serial_number="DH203864171",
)
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
    ],
    oam_ip=NetworkAddress("10.97.91.15"),
    instance_id=22206,
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_3, _rmod_4,_rmod_5], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.97.92.248", username="ute"),
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
    SshServiceDetails(addr="10.97.92.249", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_NL_2ASIM_2ABIO_1ABIA_2ABIP_2AHLOA_2AHFIB_1AEHC_22206",
)

__all__ = ["tl"]
