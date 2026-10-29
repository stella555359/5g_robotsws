__maintainer__ = "Radu Turcu"
__email__ = "Radu.Turcu@nokia.com"
# BTS ID: 10829
# BTS name: TL7_ROMAN

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import FPFH
from taf.config.testline.radio import RU
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline import Connection

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.lmi import SerialOverTcp, Remote

_pdu_1 = FPFH(
    addr="10.255.3.158",
    port_numbers=[1, 2, 3, 4, 5, 6],
    #    login="admin",
    #    password="admin",
    #    protocol="http",
)

_pdu_2 = FPFH(
    addr="10.255.3.159",
    port_numbers=[1, 2, 3, 4, 5, 6],
    #    login="admin",
    #    password="admin",
    #    protocol="http",
)

_pdu_3 = FPFH(
    addr="10.255.3.160",
    port_numbers=[1, 2, 3, 4, 5, 6],
    #    login="admin",
    #    password="admin",
    #    protocol="http",
)

_pdu_1.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_OPENED"

_pdu_2.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_OPENED"

_pdu_3.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[6].contactor = "NORMALLY_OPENED"

_pdus = [_pdu_1, _pdu_2, _pdu_3]

MUMIN_AHLOB_AH245000582 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.10"), port=5001)])
MUMIN_AHLOB_AH245000408 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.10"), port=5002)])
MUMIN_AHLOB_AH245000610 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.10"), port=5003)])
MUMIN_AHFIG_BL2137W2PMQ = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.10"), port=5004)])
MUMIN_AHFIG_K9202300358 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.10"), port=5005)])
MUMIN_AHFIG_K9244701952 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.10"), port=5006)])
MUMIN_AEHC_K9223130050 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.10"), port=5007)])
MUMIN_AEHC_L1202005437 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.10"), port=5008)])
MUMIN_AEHC_K9223200776 = SerialOverTcp([Remote(addr=NetworkAddress("10.255.20.10"), port=5009)])


_rmod_1 = RU(
    radio_type="AHLOB",
    ru_hw_group="RF.FRM6.trunk.20241104.001",
    product_code="475910A.101",
    serial_number="AH245000582",
    pdu_port=_pdu_3.pdu_ports[5],
    lmi=MUMIN_AHLOB_AH245000582,
)
_rmod_2 = RU(
    radio_type="AHLOB",
    ru_hw_group="RF.FRM6.trunk.20241104.001",
    product_code="475910A.101",
    serial_number="AH245000408",
    pdu_port=_pdu_3.pdu_ports[6],
    lmi=MUMIN_AHLOB_AH245000408,
)

_rmod_3 = RU(
    radio_type="AHLOB",
    ru_hw_group="RF.FRM6.trunk.20241104.001",
    product_code="475910A.101",
    serial_number="AH245000610",
    pdu_port=_pdu_3.pdu_ports[1],
    lmi=MUMIN_AHLOB_AH245000610,
)

_rmod_4 = RU(
    radio_type="AHFIG",
    ru_hw_group="FRMr5.1a_4T4R",
    product_code="475125A.101",
    serial_number="K9202300358",
    pdu_port=_pdu_2.pdu_ports[5],
    lmi=MUMIN_AHFIG_K9202300358,
)

_rmod_5 = RU(
    radio_type="AHFIG",
    ru_hw_group="FRMr5.1a_4T4R",
    product_code="475125A.101",
    serial_number="BL2137W2PMQ",
    pdu_port=_pdu_2.pdu_ports[4],
    lmi=MUMIN_AHFIG_BL2137W2PMQ,
)

_rmod_6 = RU(
    radio_type="AHFII",
    ru_hw_group="FRMr6.2_4T4R",
    product_code="475656A.101",
    serial_number="K9244701952",
    pdu_port=_pdu_2.pdu_ports[3],
    lmi=MUMIN_AHFIG_K9244701952,
)

_rmod_7 = RU(
    radio_type="AEHC",
    ru_hw_group="RF.CHB0.trunk.20230510.045",
    product_code="475124B.101",
    serial_number="K9223130050",
    pdu_port=_pdu_3.pdu_ports[2],
    lmi=MUMIN_AEHC_K9223130050,
)

_rmod_8 = RU(
    radio_type="AEHC",
    ru_hw_group="RF.CHB0.trunk.20230510.045",
    product_code="475124B.101",
    serial_number="L1202005437",
    pdu_port=_pdu_3.pdu_ports[3],
    lmi=MUMIN_AEHC_L1202005437,
)

_rmod_9 = RU(
    radio_type="AEHC",
    ru_hw_group="RF.CHB0.trunk.20230510.045",
    product_code="475124B.101",
    serial_number="K9223200776",
    pdu_port=_pdu_3.pdu_ports[4],
    lmi=MUMIN_AEHC_K9223200776,
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1225206881",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1164811354",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1233400591",
    rus=[_rmod_7, _rmod_8, _rmod_9],
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.32",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1232404977",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1234205014",
)
_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1234206454",
)
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    oam_ip=NetworkAddress("10.15.236.229"),
    instance_id=10829,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9],
    master=_enb_sbts_1,
)

_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.189", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.20.190", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_SRAN_NLG_10829_2ASIM_1ABIO_1ABIA_2ABIP_3AHLOB_3AHFIG_3AEHC",
)

__all__ = ["tl"]
