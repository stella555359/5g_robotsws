__maintainer__ = "roxana-lacramioara.olariu@nokia.com"
__owner__ = "roxana-lacramioara.olariu@nokia.com"
__email__ = "roxana-lacramioara.olariu@nokia.com"
import os
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
from taf.config.testline.airscale import CommonUnit, CapacityUnit, CoreUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.optical_switch import Calient
from taf.config.testline.dcap import DcapRnD, DcapBasic
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.153", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.154", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude(
    addr="10.255.5.73",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_2 = Gude(
    addr="10.255.5.72",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"


_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEH.value,
    serial_number="EA221150677",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.81.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
    attenuation_ports=[],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFII.value,
    serial_number="YK214600109",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.81.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
    attenuation_ports=[],
)


_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FHFB.value,
    serial_number="K9170817461",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.15.0", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
    attenuation_ports=[],
)


_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="B.101",
    serial_number="L1223402975",
    rus=[_rmod_1, _rmod_2],
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1212609726",
    test_pc=_test_pc_1,
)


_fct_2 = CoreUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASOG",
    hardware_version="A.101",
    serial_number="L1240913058",
    test_pc=_test_pc_2,
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_enb_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2],
    instance_id=623053,
    oam_ip=NetworkAddress(v4="10.0.65.53"),
)

_enb_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    instance_id=622053,
    oam_ip=NetworkAddress(v4="10.0.71.53"),
)


_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_1.system_module.common_units[0],
        interface_type="lmp",
    )
)

_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_2.system_module.common_units[0],
        interface_type="lmp",
    )
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_1, _enb_2],
    tl_cloud_topology="None",
)


RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": True,
    "USER_RTWP_CHECK": False,
    #    "USER_DCAP_TRACE_COLLECT": True,
    #    "USER_DCAP_TRACE_COLLECT_Master": True,
    #    "USER_DCAP_TRACE_COLLECT_Slave": True,
}

__all__ = ["tl"]
