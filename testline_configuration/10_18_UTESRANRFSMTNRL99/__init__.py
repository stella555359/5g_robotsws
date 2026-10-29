__maintainer__ = "ricardo.maia@nokia.com"
__owner__ = "ricardo.maia@nokia.com"
__email__ = "ricardo.maia@nokia.com"
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
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.bts2g import Bts2G
from taf.config.testline.nb import NB
from taf.config.testline.ran import RNC
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CoreUnit, CommonUnit, CapacityUnit
from taf.config.testline.dcap import DcapRnD, DcapBasic
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.optical_switch import Calient

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.22", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.23", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_dcap_1 = DcapRnD(
    HttpConnectionDetails(addr="10.5.19.22", port="9443", username=None, password=None)
)
_pdu_1 = Gude(
    addr="10.255.5.228",
    port_numbers=[3, 4, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude(
    addr="10.255.5.229",
    port_numbers=[1, 2],
    model="EPC",
    version="8221-1",
)
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"

# RFs
_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPDA.value,
    serial_number="K9202403993",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[10],
    attenuation_ports=[],
)
# RF2s
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPDA.value,
    serial_number="K9202403988",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[11],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPDA.value,
    serial_number="K9202403986",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[12],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHSB.value,
    serial_number="RW234900053",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[9],
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHSB.value,
    serial_number="RW240800030",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[7],
)
_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHSB.value,
    serial_number="RW240800032",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[8],
)
_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHDB.value,
    serial_number="6Q183139263",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[3],
    attenuation_ports=[],
)
_rmod_8 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHDB.value,
    serial_number="EA194552536",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[4],
    attenuation_ports=[],
)

_fct_1 = CoreUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_2.pdu_ports[2],
    hardware_type="ASOG",
    hardware_version="A.102",
    serial_number="L1250203720",
    test_pc=_test_pc_1,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)

_fct_2 = CoreUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_2.pdu_ports[1],
    hardware_type="ASOG",
    hardware_version="A.102",
    serial_number="L1243802131",
    test_pc=_test_pc_2,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8],
)
_smod_1 = Airscale(core_units=[_fct_1])
_smod_2 = Airscale(core_units=[_fct_2])

_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_4, _rmod_5, _rmod_6],
    instance_id=624099,
    oam_ip=NetworkAddress(v4="10.0.65.199"),
    dcap=_dcap_1,
)
_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_1.system_module.core_units[0],
        interface_type="lmp",
    )
)

_enb_lte_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_7, _rmod_8],
    instance_id=623099,
    oam_ip=NetworkAddress(v4="10.0.67.199"),
    dcap=_dcap_1,
)
_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_2.system_module.core_units[0],
        interface_type="lmp",
    )
)


_calient = Calient(
    addr="10.255.5.250",
    username="rfshare",
    password="Calient2016!",
    port=80,
    model="S320",
)

tl = TestLine(
    test_pc=_test_pc_1,
    enbs=[_enb_lte_1, _enb_lte_2],
    test_pcs=[_test_pc_1, _test_pc_2],
    optical_switches=[_calient],
    tl_cloud_topology="CLOUD_HRAN_RFS_ASOG_ASOE_MTNRL99_3xAHPDA_3xAHSB",
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_RTWP_CHECK": False,
    "USER_DCAP_TRACE_COLLECT": True,
    "USER_DCAP_TRACE_COLLECT_Master": True,
    "USER_DCAP_TRACE_COLLECT_Slave": True,
}
OPTICAL_SWITCH_CONFIG = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL99/optical_switch_ports.yaml"
)

DCAP_PROFILES_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL99/dcap_profiles.yaml"
)

__all__ = ["tl"]
