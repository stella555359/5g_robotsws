# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "zhlu"
__email__ = "zhonggenn.lu@nokia-sbell.com"
__owner_email__ = "zhonggenn.lu@nokia-sbell.com"

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
    SshServiceDetails(addr="10.108.152.233", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.108.152.238", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude("10.108.166.200", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "FACOM", "")
_pdu_2 = Gude("10.106.205.14", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "FACOM", "")


_fsp_1 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="6Q174907979",
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIA",
    hardware_version="A.202",
    serial_number="K9173157673",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_2.pdu_ports[8],
    hardware_type="FSMF",
    hardware_version="A.101",
    serial_number="EA173863750",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Flexi([_fct_2])

# _rmod_1 = RU(ru_hw_group='FRMr3.2_6T6R', radio_type=RadioTypes.FXDB, serial_number='RY163500059', default_telnet_connection_details=TelnetConnectionDetails(addr='172.16.8.132', port=2323), pdu_port=_pdu_3.pdu_ports[4])
_rmod_1 = RU(
    ru_hw_group="FRMr2.3_3T6R",
    radio_type=RadioTypes.AHEB,
    serial_number="1M164904526",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_2 = RU(
    ru_hw_group="FRMr2.3_3T6R",
    radio_type=RadioTypes.FRGY,
    serial_number="EA174510949",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_3 = RU(
    ru_hw_group="FRMr2.3_3T6R",
    radio_type=RadioTypes.FRGY,
    serial_number="1M164904526",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)


# _enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2], oam_ip=NetworkAddress('10.69.82.211'), instance_id=882)
_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
    ],
    oam_ip=NetworkAddress("10.69.70.146"),
    instance_id=126,
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2


_rnc = RNC(
    rnc_id=301,
    oms_ip=NetworkAddress("10.70.119.30"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.70.119.30", username="nokiadmin", password="system"
    ),
)

_bsc = BSC(
    name="BSC_1",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.70.120.17", username="SYSTEM", password="SYSTEM"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_LWG_1ASIA_1ABIA_1FSMF_1FXED_2AHFB",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
