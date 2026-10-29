# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Paulina Trela"
__email__ = "paulina.trela@nokia.com"


from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)

from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude, APC
from taf.config.testline.radio import RU
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline import Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)

from taf.config.testline.testpc import TestPc



_pdu_1 = APC(
    addr="10.44.206.194",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_2 = APC(
    addr="10.44.206.193",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_3 = Gude(
    addr="10.44.177.19",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8041-1",
)

_pdu_4 = Gude(
    addr="10.44.205.121",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8041-1",
)

_pdu_5 = APC(
    addr="10.44.206.68",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_rmod_1 = RU(
    ru_hw_group="",
    radio_type="AHFIB",
    serial_number="K9181046170",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[6],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type="AHFIB",
    serial_number="BL1907V005V",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[4],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=" AHFIB",
    serial_number="K9182821162",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[1],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=" AVHA",
    serial_number="L1251205200",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.8.2", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type="AVHA",
    serial_number="L1251205171",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.8.18", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
)

_rmod_6 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="AVHA",
    serial_number="L1251205204",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.8.10", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[10],
)

_rmod_7 = RU(
    ru_hw_group="",
    radio_type="AHLOA",
    serial_number="BL2040G1M57",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.133", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[9],
)

_rmod_8 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="AHLOA",
    serial_number="BL2048G1RC8",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.132", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[7],
)

_rmod_9 = RU(
    ru_hw_group="",
    radio_type="AHLOA",
    serial_number="BL1930G11SA",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.135", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[8],
)

_rmod_10 = RU(
    ru_hw_group="",
    radio_type="AHFIB",
    serial_number="K9182845204",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.131", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[2],
)

_rmod_11 = RU(
    ru_hw_group="",
    radio_type="AHLOA",
    serial_number="BL2040G1M6V",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.134", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[10],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.25",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223400438",
    rus=[_rmod_7, _rmod_8],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1210903913",
    rus=[_rmod_9, _rmod_11],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.29",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173643739",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1234008460",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.29",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1234003109",
    rus=[_rmod_1, _rmod_2],
)

_fsp_6 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1232105704",
    rus=[_rmod_3, _rmod_10],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2,_fsp_3],
    pdu_port=_pdu_5.pdu_ports[9],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1233503530",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_5.pdu_ports[10],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1234305460",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_7, _rmod_8, _rmod_9, _rmod_11],
    oam_ip=NetworkAddress("10.42.86.160"),
    instance_id=5005,
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2,_rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_10],
    master=_enb_sbts_1,
)

_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.149.83", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.44.149.84", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_pdus = [_pdu_1, _pdu_2, _pdu_3, _pdu_4, _pdu_5]


_bsc = BSC(
    name="BSC-25",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.42.245.38", username="SYSTEM", password="SYSTEM"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NLG_1ASIM_2ABIO_1ABIA_1ASIM_3ABIP_4AHFIB_4AHLOA_3AVHA_UTECA",
    pdus=_pdus,
    bscs=[_bsc],
)

__all__ = ["tl"]
