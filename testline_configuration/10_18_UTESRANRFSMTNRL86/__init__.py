__maintainer__ = "claudia-elisabeta.gruin@nokia.com"
__owner__ = "claudia-elisabeta.gruin@nokia.com"
__email__ = "claudia-elisabeta.gruin@nokia.com"
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

_test_pc_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.111", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_slave = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.112", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.255.5.30", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude("10.255.5.29", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"


_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQC.value,
    serial_number="1M235231321",
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGA.value,
    serial_number="K9192320874",
    pdu_port=_pdu_2.pdu_ports[11],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGA.value,
    serial_number="K9182544318",
    pdu_port=_pdu_2.pdu_ports[12],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AREA.value,
    serial_number="EA211352801",
    pdu_port=_pdu_2.pdu_ports[7],
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AREA.value,
    serial_number="K9221140919",
    pdu_port=_pdu_2.pdu_ports[8],
)


_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1233103406",
    rus=[_rmod_2, _rmod_3, _rmod_4, _rmod_5],
)

_fct_1 = CoreUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASOG",
    hardware_version="A.101",
    serial_number="L1241503102",
    test_pc=_test_pc_slave,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1192701835",
    test_pc=_test_pc_master,
)

_smod_1 = Airscale(common_units=[_fct_2])
_smod_2 = Airscale(core_units=[_fct_1])

_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_2, _rmod_3, _rmod_4, _rmod_5],
    instance_id=623086,
)

_enb_lte_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    instance_id=624086,
)

_test_pc_master.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_1.system_module.common_units[0],
        interface_type="lmp",
    )
)

_test_pc_slave.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_2.system_module.core_units[0],
        interface_type="lmp",
    )
)


tl = TestLine(
    test_pc=_test_pc_master,
    test_pcs=[_test_pc_master, _test_pc_slave],
    enbs=[_enb_lte_1, _enb_lte_2],
    tl_cloud_topology="None",
)


RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": True,
    "USER_RTWP_CHECK": False,
    "USER_STOP_AND_FIX": False,
    "USER_SCF_VALIDATION_CHECK": True,
}
__all__ = ["tl"]
