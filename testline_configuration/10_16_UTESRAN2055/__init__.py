# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Anna Grabas"
__email__ = "anna.grabas@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
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


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.157.116", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude("10.42.77.4", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")


_fsp_1 = CapacityUnit(
    addr="192.168.253.18",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="L1142811239",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="FSMF",
    hardware_version="A.103",
    serial_number="K9152011266",
)

_smod_1 = Flexi([_fct_1])

_rmod_1 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FRGU,
    serial_number="AS183601423",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.207", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[11],
)
_rmod_2 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FRGU,
    serial_number="AS182112280",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.206", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[9],
)

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2],
    oam_ip=NetworkAddress("10.42.20.14"),
    instance_id=101047,
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_L_1FSMF_2FRGU",
)

__all__ = ["tl"]
