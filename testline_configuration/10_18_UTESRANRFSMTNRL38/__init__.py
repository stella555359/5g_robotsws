__maintainer__ = "alexandru.radu@nokia.com"
__owner__ = "cristina.matoschi@nokia.com"
__email__ = "cristina.matoschi@nokia.com"
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
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.dcap import DcapRnD, DcapBasic
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.optical_switch import Calient

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.234", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.235", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.130")],
)

_test_pc_3 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.180", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_dcap_1 = DcapRnD(
    HttpConnectionDetails(addr="10.5.19.234", port="9443", username=None, password=None)
)

_pdu_1 = Gude(
    addr="10.255.5.81",
    port_numbers=[1, 2, 4, 6, 9, 10],
    model="EPC",
    version="8221-1",
)
_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude(
    addr="10.255.5.82",
    port_numbers=[1, 2, 3],
    model="EPC",
    version="8221-1",
)
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRHC.value,
    serial_number="L9134500810",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[1],
    attenuation_ports=[],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRHC.value,
    serial_number="L1140912724",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[2],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRPB.value,
    serial_number="L6150736153",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[4],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FHFB.value,
    serial_number="K9170817460",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[6],
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FHFB.value,
    serial_number="K9213892270",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[9],
)

_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FHFB.value,
    serial_number="K9170550293",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[10],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9174326841",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    serial_number="EA193774772",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="AS180748160",
)

_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="NK162831474",
)

_fsp_5 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223400391",
    rus=[_rmod_1, _rmod_2],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_2.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1201106417",
    test_pc=_test_pc_2,
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4],
    pdu_port=_pdu_2.pdu_ports[3],
    hardware_type="FSMF",
    hardware_version="472181A",
    serial_number="F7154168105",
    test_pc=_test_pc_3,
)

_fct_3 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_5],
    pdu_port=_pdu_2.pdu_ports[2],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1201902167",
    test_pc=_test_pc_1,
)

_smod_1 = Airscale([_fct_1, _fct_2])
_smod_2 = Airscale([_fct_3])


_cu_smod = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.0.65.38"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.65.38", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.65.38", username="Nemuadmin", password="nemuuser"
    ),
)
_du_smod = DU(airscale=_smod_2, rus=[_rmod_1, _rmod_2])
_gnb_nr_1 = ClassicalBts(cu=_cu_smod, dus=[_du_smod], instance_id=623038, dcap=_dcap_1)
_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_gnb_nr_1.dus[0].airscale.common_units[0],
        interface_type="lmp",
    )
)

_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    instance_id=621038,
    oam_ip=NetworkAddress(v4="10.0.69.38"),
    dcap=_dcap_1,
)
_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_1.system_module.common_units[0],
        interface_type="lmp",
    )
)
_test_pc_3.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_1.system_module.common_units[1],
        interface_type="lmp",
    )
)

_rnc = RNC(
    rnc_id=8,
    oms_ip="10.55.1.178",
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.55.0.13", username="_nokadmin", password="_P@ssword123"
    ),
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
    enbs=[_enb_lte_1],
    test_pcs=[_test_pc_1, _test_pc_2, _test_pc_3],
    gnbs=[_gnb_nr_1],
    rncs=[_rnc],
    optical_switches=[_calient],
    tl_cloud_topology="CLOUD_10_18_UTESRANRFSMTNRL38",
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
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL38/optical_switch_ports.yaml"
)

DCAP_PROFILES_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL38/dcap_profiles.yaml"
)

__all__ = ["tl"]
