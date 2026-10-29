__maintainer__ = "andrei.aninoiu@nokia.com"
__owner__ = "andrei.aninoiu@nokia.com"
__email__ = "andrei.aninoiu@nokia.com"

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

_test_pc_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.223", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_slave = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.222", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    addr="10.255.5.86",
    port_numbers=[10],
    model="EPC",
    version="8221-1",
)
_pdu_2 = Gude(
    addr="10.255.5.85",
    port_numbers=[9, 10],
    model="EPC",
    version="8221-1",
)


_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"

_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZHL.value,
    serial_number="YK203400052",
    pdu_port=_pdu_1.pdu_ports[10],
)
_abio = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.104",
    serial_number="L1213010377",
    rus=[_rmod_1],
)
_asib = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio],
    pdu_port=_pdu_2.pdu_ports[9],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1192701838",
    test_pc=_test_pc_slave,
)

_cu_asib_1 = CU(
    backhaul_site_oam_ip="10.0.69.117",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.69.117", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.69.117", username="Nemuadmin", password="nemuuser"
    ),
)

_du_asib_1 = DU(airscale=Airscale([_asib]), rus=[_rmod_1])

_classicalBts_1 = ClassicalBts(cu=_cu_asib_1, dus=[_du_asib_1], instance_id=62111)

_enb_lte = RealEnb(
    system_module=Airscale(common_units=[_asib]),
    rms=[_rmod_1],
    master=_classicalBts_1,
    instance_id=62111,
)

_test_pc_slave.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte.system_module.common_units[0],
        interface_type="lmp",
    )
)

_abip = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="A.102",
    serial_number="L1240104955",
    rus=[_rmod_1],
)

_asim_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip],
    pdu_port=_pdu_2.pdu_ports[10],
    hardware_type="ASIM",
    hardware_version="A.102",
    serial_number="L1233402443",
    test_pc=_test_pc_master,
)

_cu_asim_2 = CU(
    backhaul_site_oam_ip="10.0.65.117",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.65.117", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.65.117", username="Nemuadmin", password="nemuuser"
    ),
)


_du_asim_2 = DU(airscale=Airscale([_asim_2]), rus=[_rmod_1])

_classicalBts_2 = ClassicalBts(cu=_cu_asim_2, dus=[_du_asim_2], instance_id=62311)

_test_pc_master.connections.append(
    Connection(
        interface="eth1",
        device=_classicalBts_2.dus[0].airscale.common_units[0],
        interface_type="lmp",
    )
)


tl = TestLine(
    test_pc=_test_pc_master,
    test_pcs=[_test_pc_master, _test_pc_slave],
    gnbs=[_classicalBts_2],
    enbs=[_enb_lte],
    tl_cloud_topology="CLOUD_HRAN_RFS_AIL_B1_AIR_B1_MTNRL117_1xAZHL",
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "LK_USERNAME": "andrei.aninoiu@nokia.com",
    "LK_PASSWORD": "Nokia2024!!",
}

__all__ = ["tl"]
