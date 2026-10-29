__maintainer__ = "marc.jurca@nokia.com"
__owner__ = "marc.jurca@nokia.com"
__email__ = "amarc.jurca@nokia.com"

from taf.config.testline.airscale import CapacityUnit, CommonUnit, Airscale
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

_test_pc_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.139", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    addr="10.255.5.15",
    port_numbers=[7, 8],
    model="EPC",
    version="8221-1",
)
_pdu_2 = Gude(
    addr="10.255.5.16",
    port_numbers=[2, 4, 5, 10],
    model="EPC",
    version="8221-1",
)


_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"


_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZNC.value,
    serial_number="6Q203405258",
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZNC.value,
    serial_number="6Q203405220",
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZNC.value,
    serial_number="6Q203405297",
    pdu_port=_pdu_2.pdu_ports[10],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AWHHD.value,
    serial_number="6Q203405297",
    pdu_port=_pdu_2.pdu_ports[5],
)

_abio = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.104",  # ?
    serial_number="L1213010375",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
)
_asil = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH212874124",
    test_pc=_test_pc_master,
)


_cu_asil_1 = CU(
    backhaul_site_oam_ip="10.0.65.71",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.65.71", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.65.71", username="Nemuadmin", password="nemuuser"
    ),
)

_du_asil_1 = DU(airscale=Airscale([_asil]), rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4])

_classicalBts_1 = ClassicalBts(cu=_cu_asil_1, dus=[_du_asil_1], instance_id=623071)

_test_pc_master.connections.append(
    Connection(
        interface="eth1",
        device=_classicalBts_1.dus[0].airscale.common_units[0],
        interface_type="lmp",
    )
)

_test_pc_slave = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.140", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_ABIP = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="A.102",
    serial_number="L1240104883",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
)

_fct_asil_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_ABIP],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIL",
    hardware_version="A.102",
    serial_number="L1215007530",
    test_pc=_test_pc_slave,
)

_cu_asil_2 = CU(
    backhaul_site_oam_ip="10.0.67.71",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.67.71", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.67.71", username="Nemuadmin", password="nemuuser"
    ),
)


_du_asil_2 = DU(
    airscale=Airscale([_fct_asil_2]), rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4]
)

_classicalBts_2 = ClassicalBts(cu=_cu_asil_2, dus=[_du_asil_2], instance_id=624071)

_test_pc_slave.connections.append(
    Connection(
        interface="eth1",
        device=_classicalBts_2.dus[0].airscale.common_units[0],
        interface_type="lmp",
    )
)


tl = TestLine(
    test_pc=_test_pc_master,
    test_pcs=[_test_pc_master, _test_pc_slave],
    gnbs=[_classicalBts_1, _classicalBts_2],
)

_calient = Calient(
    addr="10.255.2.169",
    username="rfshare",
    password="Calient2016!",
    port=80,
    model="S320",
)

UTE_UE_CONFIG = "/home/ute/testline_configuration/10_18_UTESRANMTNRL71/ues.yaml"

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "LK_USERNAME": "marc.jurca@nokia.com",
    "LK_PASSWORD": "Nokia2023!",
}

__all__ = ["tl"]
