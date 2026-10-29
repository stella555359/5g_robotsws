__maintainer__ = "emanuela.dima@nokia.com"
__owner__ = "emanuela.dima@nokia.com"
__email__ = "emanuela.dima@nokia.com"
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
from taf.config.testline.airscale import CoreUnit, CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.optical_switch import Calient
from taf.config.testline.dcap import DcapRnD, DcapBasic
from taf.config.testline.fhs import FHS, FhsType

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.102", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.103", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude(
    addr="10.255.2.3",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"  # NORMALLY_OPENED or NORMALLY_CLOSED
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"  # NORMALLY_OPENED or NORMALLY_CLOSED

_pdu_2 = Gude(
    addr="10.255.2.4",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"  # NORMALLY_OPENED or NORMALLY_CLOSED
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"  # NORMALLY_OPENED or NORMALLY_CLOSED
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"  # NORMALLY_OPENED or NORMALLY_CLOSED
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"  # NORMALLY_OPENED or NORMALLY_CLOSED
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"  # NORMALLY_OPENED or NORMALLY_CLOSED
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"  # NORMALLY_OPENED or NORMALLY_CLOSED

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEB.value,
    serial_number="L1182013377",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
    attenuation_ports=[],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEB.value,
    serial_number="L1182205473",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
    attenuation_ports=[],
)


_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEB.value,
    serial_number="EA193373399",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
    attenuation_ports=[],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FHFB.value,
    serial_number="K9180808371",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
    attenuation_ports=[],
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FHFB.value,
    serial_number="K9180548950",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
    attenuation_ports=[],
)

_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FHFB.value,
    serial_number="K9180808369",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
    attenuation_ports=[],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="B.101",
    serial_number="L1223309847",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)


_fct_1 = CoreUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="ASOG",
    hardware_version="A.101",
    serial_number="L1240913056",
    test_pc=_test_pc_1,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="DH220540026",
    test_pc=_test_pc_2,
)

_smod_1 = Airscale(core_units=[_fct_1])
_smod_2 = Airscale([_fct_2])


_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    instance_id=621064,
    oam_ip=NetworkAddress(v4="10.0.65.64"),
)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_1.system_module.core_units[0],
        interface_type="lmp",
    )
)


_enb_lte_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    instance_id=622064,
    oam_ip=NetworkAddress(v4="10.0.67.64"),
)

_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_2.system_module.common_units[0],
        interface_type="lmp",
    )
)


_bsc = BSC(
    name="BSC_PAAVAI",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.27.126.7", username="SYSTEM", password="SYSTEM"
    ),
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_lte_1, _enb_lte_2],
    tl_cloud_topology="None",  # it can remain None, until TL is fully integrated in Cloud Manager and Topology is provided
    bscs=[_bsc],
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": True,
    "USER_RTWP_CHECK": True,
    "LK_USERNAME": "user.name@nokia.com",
    "LK_PASSWORD": "Nokia321x",
    "USER_DCAP_TRACE_COLLECT": True,
}

__all__ = ["tl"]
