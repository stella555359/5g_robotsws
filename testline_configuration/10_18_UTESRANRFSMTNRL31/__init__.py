__maintainer__ = "adelina.ivan@nokia.com"
__owner__ = "adina-maria.hotac@nokia.com"
__email__ = "adina-maria.hotac@nokia.com"
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
from taf.config.testline.testpc import TestPc
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU

_test_pc_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.177", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_slave = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.178", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.130")],
)
_pdu_1 = Gude(
    addr="10.255.5.179",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_2 = Gude(
    addr="10.255.5.180",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_abio = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.101",  # ?
    serial_number="L1204104710",
)
_abio = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.101",  # ?
    serial_number="L1204104699",
)
_asib = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1205104691",
    test_pc=_test_pc_master,
)
_asil = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio],
    pdu_port=_pdu_1.pdu_ports[12],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1212609725",
    test_pc=_test_pc_slave,
)
_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHIB,
    serial_number="EA185013710",
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHIB,
    serial_number="EA185013665",
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHIB,
    serial_number="AH192600659",
    pdu_port=_pdu_2.pdu_ports[6],
)
_cu_asib = CU(
    backhaul_site_oam_ip="10.0.67.31",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.67.31", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.67.31", username="Nemuadmin", password="nemuuser"
    ),
)
a = Airscale([_asib])
_du_asib = DU(airscale=a, rus=[_rmod_1, _rmod_2, _rmod_3])
_classicalBts = ClassicalBts(cu=_cu_asib, dus=[_du_asib], instance_id=43100)
_enb_lte = RealEnb(
    system_module=Airscale(common_units=[_asil]),
    rms=[_rmod_1, _rmod_2, _rmod_3],
    master=_classicalBts,
    instance_id=42136,
)
_classicalBts.slave = _enb_lte
tl = TestLine(
    test_pc=_test_pc_master,
    test_pcs=[_test_pc_master, _test_pc_slave],
    gnbs=[_classicalBts],
    enbs=[_enb_lte],
    tl_cloud_topology="CLOUD_HRAN_RFS_AIL_B1_MTNRL31_3AHIB",
)  # ?
RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "LK_USERNAME": "bogdan.hurduzeu@nokia.com",
    "LK_PASSWORD": "Nokia123!",
}
__all__ = ["tl"]
