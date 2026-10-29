__maintainer__ = "anatolie.iacoban@nokia.com"
__owner__ = "anatolie.iacoban@nokia.com"
__email__ = "anatolie.iacoban@nokia.com"
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.nb import NB
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.dcap import DcapRnD
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.183", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.184", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.255.5.114", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude("10.255.5.129", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"


_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQL.value,
    serial_number="L1234905483",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.8.10", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQL.value,
    serial_number="L1234905484",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.8.18", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQL.value,
    serial_number="L1234906612",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.8.2", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)

_abip_1 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="A.102",
    serial_number="L1233203420",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_abip_2 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="A.101",
    serial_number="L1232004049",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)


_asim_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip_1],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1234404780",
    test_pc=_test_pc_1,
)

_asim_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip_2],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1240903570",
    test_pc=_test_pc_2,
)

_dcap_1 = DcapRnD(
    HttpConnectionDetails(
        addr="10.5.19.183", port="9443", username=None, password=None
    )
)

_cu_asim_1 = CU(
    backhaul_site_oam_ip="10.0.65.51",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.65.51", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.65.51", username="Nemuadmin", password="nemuuser"
    ),
)

_du_asim_1 = DU(airscale=Airscale([_asim_1]), rus=[_rmod_1, _rmod_2, _rmod_3])

_classicalBts_1 = ClassicalBts(
    cu=_cu_asim_1, dus=[_du_asim_1], instance_id=621051, dcap=_dcap_1
)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_classicalBts_1.dus[0].airscale.common_units[0],
        interface_type="lmp",
    )
)

_cu_asim_2 = CU(
    backhaul_site_oam_ip="10.0.67.51",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.67.51", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.67.51", username="Nemuadmin", password="nemuuser"
    ),
)

_du_asim_2 = DU(airscale=Airscale([_asim_2]), rus=[_rmod_1, _rmod_2, _rmod_3])

_classicalBts_2 = ClassicalBts(
    cu=_cu_asim_2, dus=[_du_asim_2], instance_id=622051, dcap=_dcap_1
)

_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_classicalBts_2.dus[0].airscale.common_units[0],
        interface_type="lmp",
    )
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_classicalBts_1, _classicalBts_2],
    tl_cloud_topology="CLOUD_10_18_UTESRANRFSMTNRL51",
)

UTE_UE_CONFIG = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL51/ues.yaml"
RSI_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL51/rsi_config.yaml"

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": True,
    "USER_RTWP_CHECK": False,
    "USER_RTWP_CHECK_Master": False,
#   "USER_DCAP_TRACE_COLLECT": False,
#   "USER_DCAP_TRACE_COLLECT_Master": False,
#   "USER_DCAP_TRACE_COLLECT_Slave": False,
#   "USER_SLAVE_TECH": "SBTS",
    "USER_RSI_INFO_COLLECT": False,
}

DCAP_PROFILES_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL51/dcap_profiles.yaml"
)


__all__ = ["tl"]