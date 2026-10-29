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


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.181", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.182", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.130")],
)

_dcap_1 = DcapRnD(
    HttpConnectionDetails(addr="10.5.19.181", port="9443", username=None, password=None)
)

_pdu_1 = Gude(
    addr="10.255.7.6",
    port_numbers=[3, 4],
    model="EPC",
    version="8221-1",
)
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude(
    addr="10.255.7.5",
    port_numbers=[1, 2, 9],
    model="EPC",
    version="8221-1",
)
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRPD.value,
    serial_number="EA194410653",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[1],
    attenuation_ports=[],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRPD.value,
    serial_number="EA194510057",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[9],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXED.value,
    serial_number="F7165208065",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[2],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIN",
    hardware_version="474824A.101",
    serial_number="L1204214754",
    rus=[_rmod_3],
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1164304365",
    rus=[_rmod_1, _rmod_2],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1192007434",
    test_pc=_test_pc_1,
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1192007429",
    test_pc=_test_pc_2,
)


_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_cu_smod = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.0.65.129"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.65.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.65.129", username="Nemuadmin", password="nemuuser"
    ),
)
_du_smod = DU(airscale=_smod_1, rus=[_rmod_1, _rmod_2])
_gnb_nr_1 = ClassicalBts(cu=_cu_smod, dus=[_du_smod], instance_id=623129, dcap=_dcap_1)
_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_gnb_nr_1.dus[0].airscale.common_units[0],
        interface_type="lmp",
    )
)

_enb_lte_1 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    instance_id=621129,
    oam_ip=NetworkAddress(v4="10.0.69.129"),
    dcap=_dcap_1,
)
_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_1.system_module.common_units[0],
        interface_type="lmp",
    )
)


tl = TestLine(
    test_pc=_test_pc_1,
    enbs=[_enb_lte_1],
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_gnb_nr_1],
    tl_cloud_topology="CLOUD_10_18_UTESRANRFSMTNRL129",
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_RTWP_CHECK": False,
    "USER_DCAP_TRACE_COLLECT": True,
    "USER_DCAP_TRACE_COLLECT_Master": True,
    "USER_DCAP_TRACE_COLLECT_Slave": True,
}

DCAP_PROFILES_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL129/dcap_profiles.yaml"
)

__all__ = ["tl"]
