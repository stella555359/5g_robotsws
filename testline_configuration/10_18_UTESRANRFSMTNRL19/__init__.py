# ---- README ----
# This configuration file was generated automatically
# Before using this configuration file, please read the following documnent as some variables must be changed before
# running any Robot Test
# Link :

__owner__ = "violeta.zanfirescu@nokia.com"
__maintainer__ = "violeta.zanfirescu@nokia.com"
__email__ = "violeta.zanfirescu@nokia.com"


from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.bts2g import Bts2G
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
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.98", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.99", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.130")],
)


_pdu_1 = Gude("10.255.5.33", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")
_pdu_2 = Gude("10.255.5.34", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")


_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"


_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020A.X22",
    serial_number="L1182710855",
)
_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA184778040",
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_2.pdu_ports[11],
    hardware_type="ASIA",
    hardware_version="A.M01",
    serial_number="L1182711566",
    test_pc=_test_pc_1,
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu_2.pdu_ports[12],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="EA190273391",
    test_pc=_test_pc_2,
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_rmod_1 = RU(
    ru_hw_group="FRMr3.3_3T6R",
    radio_type=RadioTypes.FXEF,
    serial_number="EA202910592",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)
_rmod_2 = RU(
    ru_hw_group="FRMr3.3_3T6R",
    radio_type=RadioTypes.FXEF,
    serial_number="EA202910581",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)
_rmod_3 = RU(
    ru_hw_group="FRMr2.2_3T6R",
    radio_type=RadioTypes.FRGP,
    serial_number="L6132033590",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.224.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[8],
)


_enb_2 = RealEnb(
    system_module=_smod_2, rms=[_rmod_1, _rmod_2, _rmod_3], instance_id=42121
)


_cu_1 = CU(
    backhaul_site_oam_ip="10.0.65.19",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.65.19", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.65.19", username="Nemuadmin", password="nemuuser"
    ),
)

_du_1 = DU(airscale=_smod_1, rus=[_rmod_1, _rmod_2])


_gnb_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], instance_id=43121)


_bsc = BSC(
    name="BSC_TIMISOARA",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.5.42.236", username="SYSTEM", password="SYSTEM"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_2],
    gnbs=[_gnb_1],
    tl_cloud_topology="CLOUD_HRAN_RFS_AILR_B1_B1_MTNRL19_2FXEF_1FRGP",
    bscs=[_bsc],
)
RFS_TL_FLAGS = {
"USER_RTWP_CHECK":  False
}
__all__ = ["tl"]
