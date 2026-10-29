__maintainer__ = "nicoleta.popescu@nokia.com"
__owner__ = "nicoleta.popescu@nokia.com"
__email__ = "nicoleta.popescu@nokia.com"
from taf.config.testline.airscale import CapacityUnit, CommonUnit, Airscale, CoreUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.optical_switch import Calient

_test_pc_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.167", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_slave = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.168", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_pdu_1 = Gude(
    "10.255.5.213",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude(
    "10.255.5.212",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGA.value,
    serial_number="K9185230491",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.81.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGA.value,
    serial_number="K9182544300",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.81.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGA.value,
    serial_number="K9181425769",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.81.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FHFB.value,
    serial_number="L1145108046",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.15.0", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
)
_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233203432",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[1],
    capacity_units=[],
    hardware_type="ASOG",
    hardware_version="A.102",
    serial_number="L1250203721",
    test_pc=_test_pc_master,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1233402442",
    test_pc=_test_pc_slave,
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

# _cu_smod = CU(backhaul_site_oam_ip=NetworkAddress(v4="10.0.65.7"),
#         oam_ssh_connection_details=SshServiceDetails(addr="10.0.65.7", username='toor4nsn', password='oZPS0POrRieRtu'),
#         oam_http_connection_details=HttpConnectionDetails(addr="10.0.65.7", username='Nemuadmin', password='nemuuser'))
#
# _du_smod = DU(airscale=Airscale([_fct_1]), rus=[_rmod_1, _rmod_2, _rmod_3])
#
# _gnb_nr_1 = ClassicalBts(cu=_cu_smod, dus=[_du_smod], instance_id=623007, dcap=_dcap_1)
#
# _test_pc_1.connections.append(Connection(interface="eth1", device=_gnb_nr_1.dus[0].airscale.common_units[0], interface_type="lmp"))

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
    instance_id=621027,
    oam_ip=NetworkAddress(v4="10.0.65.27"),
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    instance_id=623027,
    oam_ip=NetworkAddress("10.0.67.27"),
)

_test_pc_master.connections.append(
    Connection(
        interface="eth1",
        device=_enb_sbts_1.system_module.common_units[0],
        interface_type="lmp",
    )
)
_test_pc_slave.connections.append(
    Connection(
        interface="eth1",
        device=_enb_sbts_2.system_module.common_units[0],
        interface_type="lmp",
    )
)
# _rnc = RNC(
#   rnc_id=8,
#    oms_ip="10.55.1.178",
#    logging_ssh_connection_details=SshServiceDetails(
#        addr="10.44.44.219", username="root", password="root"
#    ),
# )

OPTICAL_SWITCH_CONFIG = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL27/optical.yaml"
)

_calient = Calient(
    addr="10.255.2.169",
    username="rfshare",
    password="Calient2016!",
    port=80,
    model="S320",
)

tl = TestLine(
    test_pc=_test_pc_master,
    test_pcs=[_test_pc_master, _test_pc_slave],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_10_18_UTESRANRFSMTNRL27",
    optical_switches=[_calient],
)
# UTE_UE_CONFIG = "/home/ute/testline_configuration/10_18_UTESRANMTNRL23/ues.yaml"
# RSI_CONFIG_PATH = (
#    "/home/ute/testline_configuration/10_18_UTESRANMTNRL23/rsi_config.yaml"
# )
RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": True,
    "USER_RTWP_CHECK": False,
    "USER_STOP_AND_FIX": False,
    "USER_SCF_VALIDATION_CHECK": True,
}
__all__ = ["tl"]
