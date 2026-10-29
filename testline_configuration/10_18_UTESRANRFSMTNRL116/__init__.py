__owner__ = "sergiu.silaghi@nokia.com"
__maintainer__ = "sergiu.silaghi@nokia.com"
__email__ = "sergiu.silaghi@nokia.com"

from taf.config.testline.airscale import Airscale
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.connection_details import (
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection
from taf.config.testline.testpc import TestPc

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.19.220", username="ute", password="UTE.debian12"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.19.221", username="ute", password="UTE.debian12"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.255.5.18", [3, 4], "EPC", "8221-1")
_pdu_2 = Gude("10.255.5.17", [3, 4, 6], "EPC", "8221-1")

_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZHM.value,
    serial_number="4H211630002",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.131", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEH.value,
    serial_number="EA213152244",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.132", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEH.value,
    serial_number="4H244560026",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="K9193961044", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204008402",
    rus=[_rmod_1, _rmod_3],
)
_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1232004062",
    rus=[_rmod_2],
)
_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1224207723",
    rus=[_rmod_1, _rmod_3],
)
_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233203433",
    rus=[_rmod_2],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1234206607",
    test_pc=_test_pc_1,
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233402616",
    test_pc=_test_pc_2,
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_smod_1 = Airscale(common_units=[_fct_1])
_smod_2 = Airscale(common_units=[_fct_2])

_enb_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    instance_id=621116,
    oam_ip=NetworkAddress("10.0.65.116"),
)
_enb_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    instance_id=622116,
    oam_ip=NetworkAddress("10.0.67.116"),
)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_1.system_module.common_units[0],
        interface_type="lmp",
    )
)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_2.system_module.common_units[0],
        interface_type="lmp",
    )
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_1, _enb_2],
    tl_cloud_topology="None",
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": False,
    "fail_if_wrn_threshold": True,
    "USER_RSI_INFO_COLLECT": False,
    "USER_RTWP_CHECK": False,
    "USER_DCAP_TRACE_COLLECT": False,
    "USER_DCAP_TRACE_COLLECT_Master": False,
    "USER_DCAP_TRACE_COLLECT_Slave": False,
}

__all__ = ["tl"]
