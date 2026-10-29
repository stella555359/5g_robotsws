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
        addr="10.5.19.13", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.14", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_dcap_1 = DcapRnD(
    HttpConnectionDetails(addr="10.5.19.13", port="9443", username=None, password=None)
)
_pdu_1 = Gude(
    addr="10.255.5.80",
    port_numbers=[2, 3],
    model="EPC",
    version="8221-1",
)
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"


_pdu_2 = Gude(
    addr="10.255.5.79",
    port_numbers=[10, 11],
    model="EPC",
    version="8221-1",
)
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"

# RFs
_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.ARDA.value,
    serial_number="L1252800851",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[2],
    attenuation_ports=[],
)
#  RF2s
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.ARDA.value,
    serial_number="L1252800850",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_1.pdu_ports[3],
)

_ABIA_1 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="A.103",  # ?
    serial_number="L1181415939",
    rus=[_rmod_1],
)

_ABIA_2 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="A.104",  # ?
    serial_number="EA193774846",
    rus=[_rmod_1],
)

_ABIA_3 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="A.104",  # ?
    serial_number="EA193774854",
    rus=[_rmod_2],
)

_ABIO_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.101",  # ?
    serial_number="L1223400371",
    rus=[_rmod_1, _rmod_2],
)
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_ABIA_1, _ABIA_2],
    pdu_port=_pdu_2.pdu_ports[10],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="EA190777793",
    test_pc=_test_pc_1,
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_ABIA_3, _ABIO_1],
    pdu_port=_pdu_2.pdu_ports[11],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1211905210",
    test_pc=_test_pc_2,
)
_smod_1 = Airscale(core_units=[_fct_1])
_smod_2 = Airscale(core_units=[_fct_2])

_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],
    instance_id=621096,
    oam_ip=NetworkAddress(v4="10.0.71.196"),
    dcap=_dcap_1,
)

_enb_lte_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_2],
    instance_id=623096,
    oam_ip=NetworkAddress(v4="10.0.65.196"),
    dcap=_dcap_1,
)
_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_1.system_module.core_units[0],
        interface_type="lmp",
    )
)

_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_2.system_module.core_units[0],
        interface_type="lmp",
    )
)


# _calient = Calient(
#    addr="10.255.5.250",
#    username="rfshare",
#    password="Calient2016!",
#    port=80,
#    model="S320",
# )
#
tl = TestLine(
    test_pc=_test_pc_1,
    enbs=[_enb_lte_1, _enb_lte_2],
    test_pcs=[_test_pc_1, _test_pc_2],
    #    optical_switches=[_calient],
    tl_cloud_topology="CLOUD_10_18_UTESRANRFSMTNRL96",
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_RTWP_CHECK": False,
    "USER_DCAP_TRACE_COLLECT": True,
    "USER_DCAP_TRACE_COLLECT_Master": True,
    "USER_DCAP_TRACE_COLLECT_Slave": True,
}
# OPTICAL_SWITCH_CONFIG = (
#    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL96/optical_switch_ports.yaml"
# )

DCAP_PROFILES_CONFIG_PATH = "/home/ute/taf_config/testline_configuration/10_18_UTESRANRFSMTNRL96/dcap_profiles.yaml"

__all__ = ["tl"]
