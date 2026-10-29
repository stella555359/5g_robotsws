__maintainer__ = "adelina.voin@nokia.com"
__owner__ = "adelina.voin@nokia.com"
__email__ = "adelina.voin@nokia.com"
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
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.dcap import DcapRnD, DcapBasic
import os
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt
from taf.config.testline.optical_switch import Calient

_calient = Calient(
    addr="10.255.5.250",
    username="rfshare",
    password="Calient2016!",
    port=80,
    model="S320",
)

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.75", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.76", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_3 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.74", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.255.5.72", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude("10.255.5.73", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"

_pdu_3 = Gude("10.255.5.74", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_3.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="K9183026117",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.133", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[10],
    attenuation_ports=[],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="K9183920819",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.129", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[9],
    attenuation_ports=[],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="K9181816194",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.132", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[12],
    attenuation_ports=[],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2215V012P",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.131", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[8],
    attenuation_ports=[],
)
_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2215V011I",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.130", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[6],
    attenuation_ports=[],
)
_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2215V0155",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.128", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[5],
    attenuation_ports=[],
)

_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEHC.value,
    serial_number="L1202407702",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.14", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[12],
    attenuation_ports=[],
)

_rmod_8 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEHC.value,
    serial_number="L1204110672",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.6", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[11],
    attenuation_ports=[],
)

_rmod_9 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEHC.value,
    serial_number="L1202503075",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.22", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[10],
    attenuation_ports=[],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1240104966",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)
_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1232004053",
    rus=[_rmod_7, _rmod_8, _rmod_9],
)
_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    serial_number="EA193774762",
    rus=[_rmod_1, _rmod_2],
)

_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    serial_number="EA193774785",
    rus=[_rmod_3],
)

_fsp_5 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1191508784",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_2.pdu_ports[9],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="DH251432936",
    test_pc=_test_pc_1,
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4, _fsp_5],
    pdu_port=_pdu_2.pdu_ports[11],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1200905318",
    test_pc=_test_pc_2,
)

_fct_3 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu_2.pdu_ports[10],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="DH251432975",
    test_pc=_test_pc_3,
)

_smod_1 = Airscale([_fct_1, _fct_3])
_smod_2 = Airscale([_fct_2])

_cu_smod = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.0.65.98"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.65.98", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.65.98", username="Nemuadmin", password="nemuuser"
    ),
)

_du_smod = DU(airscale=Airscale([_fct_1, _fct_3]), rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9])

_gnb_nr_1 = ClassicalBts(
    cu=_cu_smod, 
    dus=[_du_smod], 
    instance_id=623093,
)

_enb_lte_1 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    instance_id=621093,
    oam_ip=NetworkAddress(v4="10.0.69.98"),
)

_test_pc_1.connections.append(Connection(interface="eth1", device=_gnb_nr_1.dus[0].airscale.common_units[0], interface_type="lmp"))

_test_pc_2.connections.append(Connection(interface="eth1", device=_enb_lte_1.system_module.common_units[0], interface_type="lmp"))

_test_pc_3.connections.append(Connection(interface="eth1", device=_gnb_nr_1.dus[0].airscale.common_units[1], interface_type="lmp"))


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2, _test_pc_3],
    enbs=[_enb_lte_1],
    gnbs=[_gnb_nr_1],
    tl_cloud_topology="CLOUD_10_18_UTESRANRFSMTNRL93",
    optical_switches=[_calient],
)

OPTICAL_SWITCH_CONFIG = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL93/optical_switch_ports.yaml"
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": False,
    "USER_RTWP_CHECK": False,
}


__all__ = ["tl"]
