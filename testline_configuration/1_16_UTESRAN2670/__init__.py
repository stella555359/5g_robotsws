__maintainer__ = "Pawel Moskal"
__owner_email__ = "pawel.moskal@nokia.com"
__team__ = "uuf"
__email__ = "pawel.moskal@nokia.com"

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
    SshServiceDetails(addr="10.42.121.80", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.121.81", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.44.130.79", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")

_fsp_1 = CapacityUnit(
    addr="192.168.253.34",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="EA163820605",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="FSMF",
    hardware_version="A.103",
    serial_number="L1142102508",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[12],
    hardware_type="FSMF",
    hardware_version="A.107",
    serial_number="F7171804567",
)

_smod_1 = Flexi([_fct_1])
_smod_2 = Flexi([_fct_2])

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type=RadioTypes.AHDB,
    serial_number="6Q190351835",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.231", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)
_rmod_2 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FRGU,
    serial_number="K9180147073",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.230", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[10],
)

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1])
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_2], master=_enb_sbts_1)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_LG_2FSMF_1FBBC_1AHDB_1FRGU",
)

__all__ = ["tl"]
