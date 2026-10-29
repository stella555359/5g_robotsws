__maintainer__ = "Lukasz Waszczak"
__owner_email__ = "lukasz.waszczak@nokia.com"
__team__ = "pz2wro2"
__email__ = "lukasz.waszczak@nokia.com"

import os
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


# testline config variables


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.121.244", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.121.245", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


pdu = Gude("10.44.128.220", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")


_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1163319143",
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1163607866",
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1204701023",
)

_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="472797A.101",
    serial_number="L1192408892",
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=pdu.pdu_ports[7],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1191006745",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4],
    pdu_port=pdu.pdu_ports[6],
    hardware_type="ASIK",
    hardware_version="A.102",
    serial_number="EA193954858",
)


_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_rmod_1 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.FHFB,
    serial_number="L1145108048",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=pdu.pdu_ports[8],
)

_rmod_2 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHLOA,
    serial_number="L1181711699",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.130", port=2323
    ),
    pdu_port=pdu.pdu_ports[4],
)

_rmod_3 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.FHFB,
    serial_number="L1145108046",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.131", port=2323
    ),
    pdu_port=pdu.pdu_ports[2],
)

_rmod_4 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHLOA,
    serial_number="EA203950523",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.129", port=2323
    ),
    pdu_port=pdu.pdu_ports[3],
)

_rmod_5 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.FHFB,
    serial_number="L1145108044",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.130", port=2323
    ),
    pdu_port=pdu.pdu_ports[1],
)

_rmod_6 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHLOA,
    serial_number="BL2016G1ANO",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.128", port=2323
    ),
    pdu_port=pdu.pdu_ports[5],
)

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    oam_ip=NetworkAddress("10.42.193.235"),
    instance_id=11227,
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_2, _rmod_4, _rmod_6],
    oam_ip=NetworkAddress("10.45.163.146"),
    instance_id=4016,
)

# _enb_sbts_1.slave = _enb_sbts_2
# tl = TestLine(test_pc=_test_pc_1, test_pcs=[_test_pc_1, _test_pc_2], enbs=[_enb_sbts_1, _enb_sbts_2], tl_cloud_topology='not added to agent yet')
tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="not added to agent yet",
    pdus=[pdu],
)

__all__ = ["tl"]
