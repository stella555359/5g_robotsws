__maintainer__ = "emanuela.petcu@nokia.com"
__owner__ = "emanuela.petcu@nokia.com"
__email__ = "emanuela.petcu@nokia.com"
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
from taf.config.testline.testpc import TestPc
from taf.config.testline.bts2g import Bts2G
from taf.config.testline.nb import NB
from taf.config.testline.ran import RNC
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.optical_switch import Calient

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.224", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.225", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.130")],
)

_pdu_1 = Gude("10.255.5.182", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude("10.255.5.181", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.104",
    serial_number="L1213010421",
)
_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.104",
    serial_number="L1213010376",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1211905251",
    test_pc=_test_pc_1,
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1201900011",
    test_pc=_test_pc_2,
)

_smod_1 = Airscale([_fct_1, _fct_2])

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOB,
    serial_number="YK220600013",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
    attenuation_ports=[],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOB,
    serial_number="YK220600007",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr=" 172.16.73.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
    attenuation_ports=[],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOB,
    serial_number="YK220600008",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
    attenuation_ports=[],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHHA,
    serial_number="EA190311355",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
    attenuation_ports=[],
)

_cu_smod = CU(
    backhaul_site_oam_ip="10.0.67.34",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.67.34", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.67.34", username="Nemuadmin", password="nemuuser"
    ),
)

_du_smod = DU(airscale=Airscale([_fct_1]), rus=[_rmod_1, _rmod_2, _rmod_3])

_gnb_nr_1 = ClassicalBts(cu=_cu_smod, dus=[_du_smod], instance_id=43138)

_enb_lte_1 = RealEnb(
    system_module=Airscale(common_units=[_fct_2]),
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
    instance_id=42138,
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_lte_1],
    gnbs=[_gnb_nr_1],
    tl_cloud_topology="CLOUD_10_18_UTESRANRFSMTNRL34",
    bscs=[None],
    rncs=[None],
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
}

__all__ = ["tl"]
