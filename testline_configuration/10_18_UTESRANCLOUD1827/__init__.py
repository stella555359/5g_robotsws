__maintainer__ = "George Medesan"
__email__ = "medesan.george@nokia.com"
# BTS ID: 10827
# BTS name: OPEL

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
    addr="10.255.3.20",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)


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

_pdus = [_pdu_1, _pdu_2]

_rmod_1 = RU(
    radio_type="AHEH",
    ru_hw_group="RF.FRM5.23R3.20230719.003",
    serial_number="EA203856875",
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_2 = RU(
    radio_type="AHEH",
    ru_hw_group="RF.FRM5.23R3.20230719.003",
    serial_number="EA203856873",
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_3 = RU(
    radio_type="AHEH",
    ru_hw_group="RF.FRM5.23R3.20230719.003",
    serial_number="DH210669329",
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_4 = RU(
    radio_type="AZQU",
    ru_hw_group="RF.ERM6.23R2.20230530.005",
    serial_number="4H210930132",
    pdu_port=_pdu_2.pdu_ports[10],
)
_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.105",
    serial_number="L1225207053",
    rus=[_rmod_4],
)

_fsp_2 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.105",
    serial_number="L1225207061",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[12],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH220446110",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
    oam_ip=NetworkAddress("10.15.236.227"),
    instance_id=10827,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.195", username="ute"),
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
    pdus=_pdus,
    tl_cloud_topology="CLOUD_SRAN_NL_10827_1ASIB_2ABIO_1AZQU_3AHEH",
)

__all__ = ["tl"]
