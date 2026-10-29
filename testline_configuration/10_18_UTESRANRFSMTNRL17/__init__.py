__maintainer__ = "adrian.beta@nokia.com"
__owner__ = "adrian.beta@nokia.com"
__email__ = "adrian.beta@nokia.com"

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
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.73", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.74", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    addr="10.255.5.34",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_2 = Gude(
    addr="10.255.5.35",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"

_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGG.value,
    serial_number="RW232200995",
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.85.128", port=2323),
    pdu_port=_pdu_2.pdu_ports[7],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGA.value,
    serial_number="K9185204368",
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.81.129", port=2323),
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FHPD.value,
    serial_number="EA173052759",
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.15.0", port=2323),
    pdu_port=_pdu_2.pdu_ports[5],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIN",
    hardware_version="A.101",
    serial_number="L1204214787",
    rus=[_rmod_1, _rmod_3],
)
_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.101",
    serial_number="L1204104948",
    rus=[_rmod_1, _rmod_2],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="L1223608559",
    test_pc=_test_pc_1,
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1200808330",
    test_pc=_test_pc_2,
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_3,

    ],
    instance_id=622017,
    oam_ip=NetworkAddress(v4="10.0.67.17"),
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
    ],
    instance_id=621204,
    oam_ip=NetworkAddress(v4="10.0.65.17"),
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
    tl_cloud_topology="None",  # it can remain None, until TL is fully integrated in Cloud Manager and Topology is provided,
)
RSI_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANMTNRL17/rsi_config.yaml"
RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": True,
    "USER_RTWP_CHECK": True,
    "USER_STOP_AND_FIX": True,
    "USER_RSI_INFO_COLLECT": True,
}

__all__ = ["tl"]
