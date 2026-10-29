__maintainer__ = "felician.ghitoaica@nokia.com"
__owner__ = "felician.ghitoaica@nokia.com"
__email__ = "felician.ghitoaica@nokia.com"
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
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.dcap import DcapRnD
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)

_test_pc_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.244", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_slave = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.245", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.130")],
)
_pdu_1 = Gude(addr="10.255.5.40", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8220-1")
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude(addr="10.255.5.41", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8220-1")
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_fsp_abio = CapacityUnit(
    addr="", hardware_type="ABIO", hardware_version="A.104", serial_number="L1213010433"
)
_fsp_abin = CapacityUnit(
    addr="", hardware_type="ABIN", hardware_version="A.101", serial_number="L1204214773"
)
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_abio],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1211905242",
    test_pc=_test_pc_master,
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_abin],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH213146847",
    test_pc=_test_pc_slave,
)
_smod_1 = Airscale(common_units=[_fct_1])
_smod_2 = Airscale(common_units=[_fct_2])


_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRGU,
    serial_number="K9171322282",
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.15.0", port=2323),
    pdu_port=_pdu_2.pdu_ports[6],
    attenuation_ports=[],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.ARMA,
    serial_number="1M202618895",
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.77.129", port=2323),
    pdu_port=_pdu_2.pdu_ports[7],
    attenuation_ports=[],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.ARMA,
    serial_number="1M202513598",
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.77.128", port=2323),
    pdu_port=_pdu_2.pdu_ports[8],
    attenuation_ports=[],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEH,
    serial_number="EA221150640",
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.77.134", port=2323),
    pdu_port=_pdu_2.pdu_ports[9],
    attenuation_ports=[],
)
_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEH,
    serial_number="EA221150659",
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.77.131", port=2323),
    pdu_port=_pdu_2.pdu_ports[10],
    attenuation_ports=[],
)
_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEH,
    serial_number="EA221150633",
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.77.133", port=2323),
    pdu_port=_pdu_2.pdu_ports[12],
    attenuation_ports=[],
)
_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEH,
    serial_number="EA221150677",
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.77.132", port=2323),
    pdu_port=_pdu_2.pdu_ports[11],
    attenuation_ports=[],
)
_rmod_8 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHCA,
    serial_number="1M192827902",
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.77.135", port=2323),
    pdu_port=_pdu_2.pdu_ports[4],
    attenuation_ports=[],
)
_rmod_9 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRGP,
    serial_number="RY121829070",
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.15.0", port=2323),
    pdu_port=_pdu_2.pdu_ports[2],
    attenuation_ports=[],
)
_rmod_10 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGA,
    serial_number="K9192320894",
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.15.0", port=2323),
    pdu_port=_pdu_2.pdu_ports[3],
    attenuation_ports=[],
)

_cu_smod = CU(
    backhaul_site_oam_ip="10.0.68.121",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.68.121", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.68.121", username="Nemuadmin", password="nemuuser"
    ),
)

_du_smod = DU(airscale=Airscale([_fct_1]), rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8])

_dcap_1 = DcapRnD(
    HttpConnectionDetails(
        addr="10.5.19.244", port="9443", username=None, password=None
    )
)

_classicalBts = ClassicalBts(cu=_cu_smod, dus=[_du_smod], instance_id=623121, dcap=_dcap_1)

_test_pc_master.connections.append(Connection(interface="eth1", device=_classicalBts.dus[0].airscale.common_units[0], interface_type="lmp"))

_enb_lte = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9, _rmod_10],
    master=_classicalBts,
    instance_id=621121,
    dcap=_dcap_1,
)

_classicalBts.slave = _enb_lte

_test_pc_slave.connections.append(Connection(interface="eth1", device=_enb_lte.system_module.common_units[0], interface_type="lmp"))

tl = TestLine(
    test_pc=_test_pc_master,
    test_pcs=[_test_pc_master, _test_pc_slave],
    enbs=[_enb_lte],
    gnbs=[_classicalBts],
    tl_cloud_topology="CLOUD_HRAN_RFS_AIR_B1_MTNRL121_1FRGP_2ARMA_4AHEH_1AHCA_1AHEGA_1FRGU",
)
UTE_UE_CONFIG = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL121/ues.yaml"
TARGET_LOGICAL_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL121/logical_config.yaml"
)

DCAP_PROFILES_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL121/dcap_profiles.yaml"

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True, 
    "fail_if_wrn_threshold": True, 
    "USER_RTWP_CHECK":  False,
    "USER_DCAP_TRACE_COLLECT": True,
    "USER_DCAP_TRACE_COLLECT_Master": True,
    "USER_DCAP_TRACE_COLLECT_Slave": True,
    }

__all__ = ["tl"]
