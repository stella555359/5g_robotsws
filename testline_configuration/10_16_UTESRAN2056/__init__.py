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
    SshServiceDetails(addr="10.42.250.140", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude("10.42.80.243", [1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12], "EPC", "")
_pdu_2 = Gude("10.42.80.242", [1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12], "EPC", "")


_fsp_1 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1162604031",
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIA",
    hardware_version="A.101",
    serial_number="L1162214153",
)

_smod_1 = Airscale([_fct_1])


_rmod_1 = RU(
    ru_hw_group="CPRI-A_RRH_2T4R",
    radio_type=RadioTypes.UHEB,
    serial_number="YP1630A0023",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.18.0", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_2 = RU(
    ru_hw_group="CPRI-A_RRH_2T4R",
    radio_type=RadioTypes.UHEB,
    serial_number="YP1629A002F",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.18.1", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_3 = RU(
    ru_hw_group="CPRI-A_RRH_2T4R",
    radio_type=RadioTypes.UHEB,
    serial_number="YP1617030A7",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.18.2", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.42.146.19"),
    instance_id=101019,
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_L_1ASIA_1ABIA_3UHEB",
)

__all__ = ["tl"]
