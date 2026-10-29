__maintainer__ = "patricia.gavra@nokia.com"
__owner__ = "patricia.gavra@nokia.com"
__email__ = "patricia.gavra@nokia.com"
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude, APC
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
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.optical_switch import Calient
from taf.config.testline.dcap import DcapRnD, DcapBasic
from taf.config.testline.fhs import FHS, FhsType


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.226", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.227", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    addr="10.255.5.216",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_2 = Gude(
    addr="10.255.5.217",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVHQA.value,
    serial_number="1M250101603",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
    attenuation_ports=[],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVHQA.value,
    serial_number="1M245101145",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
    attenuation_ports=[],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVHQA.value,
    serial_number="1M245101147",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
    attenuation_ports=[],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233201697",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.105",
    serial_number="L1230601457",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="DH221644852",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204101558",
    rus=[_rmod_3],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1250309595",
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
    serial_number="L1234206594",
    test_pc=_test_pc_2,
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    instance_id=621003,
    oam_ip=NetworkAddress("10.0.65.3"),
    #dcap=_dcap_1,
)

_enb_lte_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    instance_id=624003,
    oam_ip=NetworkAddress("10.0.67.3"),
    #dcap=_dcap_1,
)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_1.system_module.common_units[0],
        interface_type="lmp",
    )
)

_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_2.system_module.common_units[0],
        interface_type="lmp",
    )
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_lte_1, _enb_lte_2],
    tl_cloud_topology="CLOUD_10_18_UTESRANRFSMTNRL3",
)

#RSI_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL3/rsi_config.yaml"

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": True,
    "USER_RTWP_CHECK": False,
    "USER_MASTER_TECH": "SBTS",
    "USER_RSI_INFO_COLLECT": True,
    #    "USER_DCAP_TRACE_COLLECT": True,
    #    "USER_DCAP_TRACE_COLLECT_Master": True,
    #    "USER_DCAP_TRACE_COLLECT_Slave": True,
}

__all__ = ["tl"]