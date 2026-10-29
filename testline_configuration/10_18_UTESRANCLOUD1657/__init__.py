# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:contact: lte-vrf-cloud-agents-dev@LIST.NOKIA.COM
"""

__maintainer__ = "Pirjol Mihai"
__email__ = "mihai-adrian.pirjol@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import FPFH
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.ran import BSC
from taf.config.testline.lmi import SerialOverTcp, Remote

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(addr="10.5.47.44", username="ute", password="UTE.debian12"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(addr="10.5.47.45", username="ute", password="UTE.debian12"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = FPFH(
    addr="10.255.3.132",
    port_numbers=[1, 2, 3, 4, 5, 6],
)

_pdu_2 = FPFH(
    addr="10.255.3.130",
    port_numbers=[1, 2, 3, 4, 5, 6],
)

_pdu_3 = FPFH(
    addr="10.255.3.134",
    port_numbers=[1, 2, 3, 4, 5, 6],
)

_pdu_4 = FPFH(
    addr="10.255.3.131",
    port_numbers=[1, 2, 3, 4, 5, 6],
)

_pdu_1.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[6].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[4].contactor = "NORMALLY_OPENED"


_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1223507674",
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1223509740",
)

_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.107",
    serial_number="L1223614884",
)

_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1223509797",
)
_fsp_5 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1223509824",
)



_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1243200136",
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1224709958",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


MUMIN_AHFII_K9244537337 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.6"), port=5004)])
MUMIN_AHFII_K9244701863 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.6"), port=5005)])
MUMIN_AHFII_K9244701862 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.6"), port=5006)])
MUMIN_AEHC_K9223200774 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.6"), port=5007)])
MUMIN_AEHC_K9223200769 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.6"), port=5008)])
MUMIN_AEHC_K9214727488 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.6"), port=5009)])
MUMIN_AHLOA_K9183920896 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.6"), port=5010)])
MUMIN_AHLOA_BL2248G1DI9 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.6"), port=5011)])
MUMIN_AHLOA_K9183920895 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.6"), port=5012)])


_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="K9183920895",
    pdu_port=_pdu_2.pdu_ports[3],
    lmi=MUMIN_AHLOA_K9183920895,
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2248G1DI9",
    pdu_port=_pdu_2.pdu_ports[2],
    lmi=MUMIN_AHLOA_BL2248G1DI9,
)

_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="K9183920896",
    pdu_port=_pdu_2.pdu_ports[1],
    lmi=MUMIN_AHLOA_K9183920896,
)

_rmod_4 = RU(
    ru_hw_group="CPRI",
    radio_type=RadioTypes.AHFII.value,
    serial_number="K9244701862",
    pdu_port=_pdu_3.pdu_ports[4],
    lmi=MUMIN_AHFII_K9244701862,
)

_rmod_5 = RU(
    ru_hw_group="CPRI",
    radio_type=RadioTypes.AHFII.value,
    serial_number="K9244701863",
    pdu_port=_pdu_3.pdu_ports[5],
    lmi=MUMIN_AHFII_K9244701863,
)

_rmod_6 = RU(
    ru_hw_group="CPRI",
    radio_type=RadioTypes.AHFII.value,
    serial_number="K9244537337",
    pdu_port=_pdu_3.pdu_ports[6],
    lmi=MUMIN_AHFII_K9244537337,
)

_rmod_7 = RU(
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    radio_type=RadioTypes.AEHC.value,
    serial_number="K9223200769",
    pdu_port=_pdu_4.pdu_ports[4],
    # lmi=MUMIN_AEHC_K9223200769,
)

_rmod_8 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type=RadioTypes.AEHC.value,
    serial_number="K9223200774",
    pdu_port=_pdu_2.pdu_ports[6],
    # lmi=MUMIN_AEHC_K9223200774,
)

_rmod_9 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type=RadioTypes.AEHC.value,
    serial_number="K9214727488",
    pdu_port=_pdu_2.pdu_ports[5],
    # lmi=MUMIN_AEHC_K9214727488,
)


_fsp_1.rus = ([_rmod_1, _rmod_2, _rmod_3])
_fsp_2.rus = ([_rmod_4, _rmod_5, _rmod_6])
_fsp_3.rus = ([_rmod_4, _rmod_5, _rmod_6])
_fsp_4.rus = ([_rmod_7, _rmod_8, _rmod_9])
_fsp_5.rus = ([_rmod_7, _rmod_8, _rmod_9])



_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    oam_ip=NetworkAddress("10.15.236.57"),
    instance_id=10657,
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_7, _rmod_8, _rmod_9],
    master=_enb_sbts_1
)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"))
_test_pc_2.connections.append(Connection(interface="eth1", device=_enb_sbts_2.system_module.common_units[0], interface_type="lmp"))

_bsc = BSC(
    name="BSC_AVENSIS_DAHARANI",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.27.126.214", username="SYSTEM", password="SYSTEM"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NLG_1657_2ASIL_5ABIO_1ABIA_3AHLOA_6AHFII_3AEHC",
    bscs=[_bsc]
)

__all__ = ["tl"]
