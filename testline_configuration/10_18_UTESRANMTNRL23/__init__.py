__maintainer__ = "dinu.olariu@nokia.com"
__owner__ = "dinu.olariu@nokia.com"
__email__ = "dinu.olariu@nokia.com"

from taf.config.testline.airscale import CapacityUnit, CommonUnit, Airscale
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
from taf.config.testline.dcap import DcapRnD
from taf.config.testline.lmi import SerialOverHost, SerialOverTcp, Local, Remote

_test_pc_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.77", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_slave = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.78", username="ute", password="ute"
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
    addr="10.255.5.33",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"

_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHCA.value,
    serial_number="L1181711681",
    pdu_port=_pdu_2.pdu_ports[10],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHCA.value,
    serial_number="L1181711696",
    pdu_port=_pdu_2.pdu_ports[11],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHCA.value,
    serial_number="L1181711682",
    pdu_port=_pdu_2.pdu_ports[12],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.23", username="rfsharing", password="Nokia2022!@1"
            )
        ),
        uart_mapping=[Local(port="COM4")],  # windows
    ),
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRGU.value,
    serial_number="AS184104418",
    pdu_port=_pdu_2.pdu_ports[4],
)

_abil = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="A.102",  # ?
    serial_number="L1190810676",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_abia = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="A.103",  # ?
    serial_number="L1191508725",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
)

_asik = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIK",
    hardware_version="A.101",
    serial_number="L1190404504",
    test_pc=_test_pc_master,
)

_asia = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1171316864",
    test_pc=_test_pc_slave,
)

_dcap_1 = DcapRnD(
    HttpConnectionDetails(addr="10.5.19.77", port="9443", username=None, password=None)
)


_cu_asik = CU(
    backhaul_site_oam_ip="10.0.65.23",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.65.23", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.65.23", username="Nemuadmin", password="nemuuser"
    ),
)

a = Airscale([_asik])

_du_asik = DU(airscale=a, rus=[_rmod_1, _rmod_2, _rmod_3])

_classicalBts = ClassicalBts(
    cu=_cu_asik, dus=[_du_asik], instance_id=623023, dcap=_dcap_1
)

_enb_lte = RealEnb(
    system_module=Airscale(common_units=[_asia]),
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
    master=_classicalBts,
    instance_id=621023,
    dcap=_dcap_1,
)

_test_pc_slave.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte.system_module.common_units[0],
        interface_type="lmp",
    )
)

_test_pc_master.connections.append(
    Connection(
        interface="eth1",
        device=_classicalBts.dus[0].airscale.common_units[0],
        interface_type="lmp",
    )
)

tl = TestLine(
    test_pc=_test_pc_master,
    test_pcs=[_test_pc_master, _test_pc_slave],
    gnbs=[_classicalBts],
    enbs=[_enb_lte],
    tl_cloud_topology="CLOUD_HRAN_RFS_AIR_B4_MTNRL23_3AHCA",
)  # ?

UTE_UE_CONFIG = "/home/ute/testline_configuration/10_18_UTESRANMTNRL23/ues.yaml"
DCAP_PROFILES_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANMTNRL23/dcap_profiles.yaml"
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": True,
    "USER_RTWP_CHECK": False,
    "USER_STOP_AND_FIX": False,
}

__all__ = ["tl"]
