__maintainer__ = "Dan Moldovan"
__email__ = "dan.moldovan@nokia.com"
# BTS ID: 10832
# BTS Name: BMW

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
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
    addr="10.255.3.21",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_2 = Gude(
    addr="10.255.3.22",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="RF.FRM5.trunk.20230813.003",
    serial_number="F7163008769",
    radio_type="FRHC",
    pdu_port=_pdu_1.pdu_ports[8],
)
_rmod_2 = RU(
    ru_hw_group="RF.FRM5.trunk.20230813.003",
    serial_number="EA184982942",
    radio_type="AHGB",
    pdu_port=_pdu_1.pdu_ports[11],
)
_rmod_7 = RU(
    ru_hw_group="FRM33.32.R05D",
    serial_number="K9183920885",
    radio_type="AHLOA",
    pdu_port=_pdu_1.pdu_ports[10],
)

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIQ",
    hardware_version="476397A.101",
    serial_number="L1232305678",
    rus=[_rmod_2],
)
_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIN",
    hardware_version="474824A.103",
    serial_number="L1214007295",
    rus=[_rmod_1],
)
_fsp_3 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1211709881",
    rus=[_rmod_7],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_2.pdu_ports[3],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="DH221041157",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_7],
    oam_ip=NetworkAddress("10.15.236.232"),
    instance_id=10832,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.160", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_NL_10832_ASIL_ABIQ_1ABIN_1ABIO_FRHC_AHFB_AHLOA",
)

__all__ = ["tl"]