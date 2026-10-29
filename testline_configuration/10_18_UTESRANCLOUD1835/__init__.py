__maintainer__ = "Radu Turcu"
__email__ = "Radu.Turcu@nokia.com"
# BTS ID: 10835
# BTS name: TL14_ARO

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude, APC
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

_pdu_1 = Gude(
    addr="10.255.3.22",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_2 = Gude(
    addr="10.255.3.23",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8220-1",
)

_pdu_3 = Gude(
    addr="10.255.3.12",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8220-1",
)
_pdu_3.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[12].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[9].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_OPENED"


_pdus = [_pdu_1, _pdu_2, _pdu_3]

_rmod_1 = RU(
    radio_type="FXED",
    ru_hw_group="FRM33.32.R15D",
    product_code="472924A.202",
    serial_number="F7165065575",
    pdu_port=_pdu_2.pdu_ports[10],
)

_rmod_2 = RU(
    radio_type="AHGB",
    ru_hw_group="RF.FRM5.trunk24.20240402.001",
    product_code="474514A.102",
    serial_number="EA184983009",
    pdu_port=_pdu_2.pdu_ports[7],
)

_rmod_3 = RU(
    radio_type="AHBCC",
    ru_hw_group="RF.FRM5.trunk24.20240402.001",
    product_code="474341A.101",
    serial_number="BL2215Y297L",
    pdu_port=_pdu_2.pdu_ports[5],
)

_rmod_4 = RU(
    radio_type="AHIB",
    ru_hw_group="RF.FRM5.trunk24.20240402.001",
    product_code="474050A.102",
    serial_number="AH192600659",
    pdu_port=_pdu_2.pdu_ports[12],
)

_rmod_5 = RU(
    radio_type="AHIB",
    ru_hw_group="RF.FRM5.trunk24.20240402.001",
    product_code="474050A.102",
    serial_number="EA185013699",
    pdu_port=_pdu_2.pdu_ports[9],
)

_rmod_6 = RU(
    radio_type="AHIB",
    ru_hw_group="RF.FRM5.trunk24.20240402.001",
    product_code="474050A.102",
    serial_number="EA185013710",
    pdu_port=_pdu_2.pdu_ports[11],
)

_rmod_7 = RU(
    radio_type="AHCA",
    ru_hw_group="RF.FRM5.trunk24.20240402.001",
    product_code="473966A.101",
    serial_number="AS195003416",
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_8 = RU(
    radio_type="AEHC",
    ru_hw_group="RF.CHB0.trunk.20241015.023",
    product_code="475124B.M02",
    serial_number="AH234800096",
    pdu_port=_pdu_3.pdu_ports[4],
)

_rmod_9 = RU(
    radio_type="AZHN",
    ru_hw_group="RF.ERM6.trunk.20241015.027",
    product_code="475547A.101",
    serial_number="4H205130127",
    pdu_port=_pdu_1.pdu_ports[4],
)

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9172606443",
    rus=[_rmod_1, _rmod_2],
)
_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9172606506",
    rus=[_rmod_3],
)
_fsp_3 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1194509173",
    rus=[_rmod_6],
)
_fsp_4 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214208620",
    rus=[_rmod_8, _rmod_9],
)
_fsp_5 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIN",
    hardware_version="474824A.103",
    serial_number="L1213706150",
    rus=[_rmod_5, _rmod_7],
)
_fsp_6 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="DH212564270",
    rus=[_rmod_4],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="DH221041098",
)
_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="DH221041159",
)
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_6],
    oam_ip=NetworkAddress("10.15.236.235"),
    instance_id=10835,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_7, _rmod_5, _rmod_4, _rmod_8, _rmod_9],
    master=_enb_sbts_1,
)

_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.185", username="ute"),
    connections=[
        NetworkAddress(v4="10.5.20.0"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.20.186", username="ute"),
    connections=[
        NetworkAddress(v4="10.5.20.0"),
        Connection(interface="eth1",
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
    tl_cloud_topology="CLOUD_SRAN_NLWG_10835_2ASIL_2ABIA_2ABIL_1ABIO_1ABIN_FXED_AHGB_AHBCC_3AHIB_AHIB_AEHC_AZHN",
)

__all__ = ["tl"]
