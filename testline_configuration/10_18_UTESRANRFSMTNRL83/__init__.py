__maintainer__ = "nicoleta.popescu@nokia.com"
__owner__ = "nicoleta.popescu@nokia.com"
__email__ = "nicoleta.popescu@nokia.com"
from taf.config.testline.airscale import CapacityUnit, CommonUnit, Airscale, CoreUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.100", username="ute", password="userpassword"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.101", username="ute", password="userpassword"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    "10.255.5.148",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude(
    "10.255.5.149",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"

_pdu_3 = Gude(
    "10.255.7.54",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_3.pdu_ports[1].contactor = "NORMALLY_CLOSED"


_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQC.value,
    serial_number="1M245101149",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.16.2", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQC.value,
    serial_number="1M243414480",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.16.6", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQC.value,
    serial_number="1M245101148",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.16.10", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[1],
)

_fct_1 = CoreUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASOE",
    hardware_version="A.103",
    serial_number="DH230510653",
    test_pc=_test_pc_1,
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_fct_2 = CoreUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASOE",
    hardware_version="A.103",
    serial_number="EA221952835",
    test_pc=_test_pc_2,
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

# _cu_smod = CU(backhaul_site_oam_ip=NetworkAddress(v4="10.0.65.7"),
#         oam_ssh_connection_details=SshServiceDetails(addr="10.0.65.7", username='toor4nsn', password='oZPS0POrRieRtu'),
#         oam_http_connection_details=HttpConnectionDetails(addr="10.0.65.7", username='Nemuadmin', password='nemuuser'))
#
# _du_smod = DU(airscale=Airscale([_fct_1]), rus=[_rmod_1, _rmod_2, _rmod_3])
#
# _gnb_nr_1 = ClassicalBts(cu=_cu_smod, dus=[_du_smod], instance_id=623007, dcap=_dcap_1)
#
# _test_pc_1.connections.append(Connection(interface="eth1", device=_gnb_nr_1.dus[0].airscale.common_units[0], interface_type="lmp"))

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    instance_id=622083,
    oam_ip=NetworkAddress(v4="10.0.71.83"),
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    instance_id=621083,
    oam_ip=NetworkAddress(v4="10.0.69.83"),
)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_sbts_1.system_module.common_units[0],
        interface_type="lmp",
    )
)
_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_sbts_2.system_module.common_units[0],
        interface_type="lmp",
    )
)
# _rnc = RNC(
#   rnc_id=8,
#    oms_ip="10.55.1.178",
#    logging_ssh_connection_details=SshServiceDetails(
#        addr="10.44.44.219", username="root", password="root"
#    ),
# )

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
)
# UTE_UE_CONFIG = "/home/ute/testline_configuration/10_18_UTESRANMTNRL23/ues.yaml"
# RSI_CONFIG_PATH = (
#    "/home/ute/testline_configuration/10_18_UTESRANMTNRL23/rsi_config.yaml"
# )

RSI_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL83/rsi_config.yaml"

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": True,
    "USER_RTWP_CHECK": True,
    "USER_STOP_AND_FIX": False,
    "USER_SCF_VALIDATION_CHECK": True,
}
__all__ = ["tl"]
