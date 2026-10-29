# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Anna Mosiadz"
__email__ = "anna.mosiadz@nokia.com"

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
    SshServiceDetails(addr="10.42.250.141", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude("10.42.80.243", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")
_pdu_2 = Gude("10.42.80.242", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")


_fsp_1 = CapacityUnit(
    addr="192.168.253.18",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="AS172532259",
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.19",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="NK154630675",
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="FSMF",
    hardware_version="A.204",
    serial_number="EA154752177",
)

_smod_1 = Flexi([_fct_1])


_rmod_1 = RU(
    ru_hw_group="CPRI-A_RRH_2T4R",
    radio_type=RadioTypes.UHEF,
    serial_number="YP162904FF7",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.131", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[9],
)
_rmod_2 = RU(
    ru_hw_group="CPRI-A_RRH_2T4R",
    radio_type=RadioTypes.UHEF,
    serial_number="YP162705A15",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)
_rmod_3 = RU(
    ru_hw_group="CPRI-A_RRH_2T4R",
    radio_type=RadioTypes.UHEF,
    serial_number="YP16300073B",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
)
_rmod_4 = RU(
    ru_hw_group="CPRI-A_RRH_2T2R",
    radio_type=RadioTypes.UHGA,
    serial_number="YP15120BE93",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.132", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_5 = RU(
    ru_hw_group="CPRI-A_RRH_2T4R",
    radio_type=RadioTypes.UHGA,
    serial_number="YP15120C0B9",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.133", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    oam_ip=NetworkAddress("10.42.183.91"),
    instance_id=101020,
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_L_1FSMF_2FBBC_3UHEF_2UHGA",
)

__all__ = ["tl"]
