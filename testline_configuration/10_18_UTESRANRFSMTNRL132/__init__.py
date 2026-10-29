__maintainer__ = "mihai.dobre@nokia.com"
__owner__ = "mihai.dobre@nokia.com"
__email__ = "mihai.dobre@nokia.com"
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
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.optical_switch import Calient

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.196", username="ute", password="pass"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.197", username="ute", password="pass"
    ),
    connections=[NetworkAddress(v4="192.168.255.130")],
)
_pdu_1 = Gude("10.255.2.111", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2 = Gude("10.255.2.110", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZQS.value,
    serial_number="1M212806942",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.1.2", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[12],
    attenuation_ports=[],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZQS.value,
    serial_number="1M213114018",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.1.154", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[11],
    attenuation_ports=[],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZQU.value,
    serial_number="1M212809323",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.2", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
    attenuation_ports=[],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZQU.value,
    serial_number="1M212809324",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.6", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
    attenuation_ports=[],
)
_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZQU.value,
    serial_number="1M222314736",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.154", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
    attenuation_ports=[],
)
_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPE.value,
    serial_number="1M202303616",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
    attenuation_ports=[],
)
_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEH.value,
    serial_number="EA224752502",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
    attenuation_ports=[],
)
_rmod_8 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEH.value,
    serial_number="EA224752546",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
    attenuation_ports=[],
)
_rmod_9 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEH.value,
    serial_number="EA224752564",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.131", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
    attenuation_ports=[],
)


_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.104",
    serial_number="L1213010415",
    rus=[_rmod_3, _rmod_4, _rmod_5],
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.101",
    serial_number="L1204104944",
    rus=[_rmod_1, _rmod_2],
)
_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.101",
    serial_number="L1204104861",
    rus=[_rmod_6, _rmod_7, _rmod_8, _rmod_9],
)

_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.101",
    serial_number="L1204008421",
    rus=[_rmod_3, _rmod_4, _rmod_5],
)
_fsp_5 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.101",
    serial_number="L1204104951",
    rus=[_rmod_1, _rmod_2],
)
_fsp_6 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.101",
    serial_number="L1204104860",
    rus=[_rmod_6, _rmod_7, _rmod_8, _rmod_9],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1211205017",
    test_pc=_test_pc_1,
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1200905318",
    test_pc=_test_pc_2,
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
        _rmod_6,
        _rmod_7,
        _rmod_8,
        _rmod_9,
    ],
    instance_id=621132,
    oam_ip=NetworkAddress("10.0.65.132"),
)
_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_1.system_module.common_units[0],
        interface_type="lmp",
    )
)

_enb_lte_2 = RealEnb(
    system_module=_smod_2,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
        _rmod_6,
        _rmod_7,
        _rmod_8,
        _rmod_9,
    ],
    instance_id=622132,
    oam_ip=NetworkAddress("10.0.67.132"),
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
    tl_cloud_topology="CLOUD_10_18_UTESRANRFSMTNRL132",
    bscs=[None],
    rncs=[None],
)

RSI_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL132/rsi_config.yaml"
RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_RSI_INFO_COLLECT": True,
}
__all__ = ["tl"]
