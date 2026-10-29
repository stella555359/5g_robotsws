# ---- README ----
# This configuration file was generated automatically
# Before using this configuration file, please read the following documnent as some variables must be changed before
# running any Robot Test
# Link :

__owner__ = "laurentiu.macean@nokia.com"
__maintainer__ = "laurentiu.macean@nokia.com"
__email__ = "laurentiu.macean@nokia.com"


from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.nb import NB
from taf.config.testline.bts2g import Bts2G
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.19.195", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.19.196", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.130")],
)


_pdu_1 = Gude("10.255.5.34", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_2 = Gude("10.255.5.33", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")


_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"


_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204104854",
)
_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204104870",
)
_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1204706796",
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1212506052",
    test_pc=_test_pc_1,
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1210402794",
    test_pc=_test_pc_2,
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_rmod_1 = RU(
    ru_hw_group="FRMrRH6.0_6T6R",
    radio_type=RadioTypes.AZHL,
    serial_number="YK203400052",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.2", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[9],
)
_rmod_2 = RU(
    ru_hw_group="FRMrRH6.0_6T6R",
    radio_type=RadioTypes.AZHL,
    serial_number="AH211600355",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.154", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_3 = RU(
    ru_hw_group="FRMrRH6.0_6T6R",
    radio_type=RadioTypes.AZHL,
    serial_number="YK203400048",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.6", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)


_enb_2 = RealEnb(
    system_module=_smod_2, rms=[_rmod_1, _rmod_2, _rmod_3], instance_id=42110
)


_cu_1 = CU(
    backhaul_site_oam_ip="10.0.65.10",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.65.10", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.65.10", username="Nemuadmin", password="nemuuser"
    ),
)

_du_1 = DU(airscale=_smod_1, rus=[_rmod_1, _rmod_2, _rmod_3])


_gnb_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], instance_id=43110)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_2],
    gnbs=[_gnb_1],
    tl_cloud_topology="CLOUD_HRAN_RFS_AILR_B1_B2_B4_MTNRL10_3xAZHL",
)

__all__ = ["tl"]
