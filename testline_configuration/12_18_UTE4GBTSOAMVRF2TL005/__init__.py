__maintainer__ = "alin.necula@nokia.com"
__owner__ = "alin.necula@nokia.com"
__email__ = "alin.necula@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
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
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.25.107", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.25.108", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude("10.255.3.65", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC")
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude("10.255.3.64", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC")
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"


_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="EA185079679",
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="EA185079657",
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="EA185079944",
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="EA185079945",
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="EA185079880",
)

_fsp_6 = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="EA185079947",
)


_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="RW190400571",
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    test_pc=_test_pc_1,
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[12],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="AH184117220",
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    test_pc=_test_pc_2,
)


_smod_1 = Airscale([_fct_1])

_smod_2 = Airscale([_fct_2])


_rmod_1 = RU(
    ru_hw_group="RRH2.3",
    radio_type=RadioTypes.FHEB,
    serial_number="1M175200369",
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="RRH2.3",
    radio_type=RadioTypes.FHEB,
    serial_number="1M175200343",
    pdu_port=_pdu_2.pdu_ports[11],
)


_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2])
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_1, _rmod_2], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_L_1ASIA_3ABIA_1ASIA_3ABIA_2FHEB_1MDEA",
)


__all__ = ["tl"]
