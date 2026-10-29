__maintainer__ = "Andrei Maria"
__email__ = "andrei.maria@nokia.com"

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
    addr="10.255.3.13",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_2 = Gude(
    addr="10.255.3.14",
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
    radio_type="FRHC",
    ru_hw_group="FRM32.13.R14",
    serial_number="F7163008765",
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_2 = RU(
    radio_type="AHCA",
    ru_hw_group="RF.FRM5.trunk.20220408.017",
    serial_number="1M222033049",
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_3 = RU(
    radio_type="AHIB",
    ru_hw_group="RF.FRM5.trunk.20220408.017",
    serial_number="EA174211168",
    pdu_port=_pdu_3.pdu_ports[6],
)

_rmod_4 = RU(
    radio_type="AHEH",
    ru_hw_group="RF.FRM5.trunk.20220408.017",
    serial_number="DH210474361",
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_5 = RU(
    radio_type="AHEH",
    ru_hw_group="RF.FRM5.trunk.20220408.017",
    serial_number="DH210474308",
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_6 = RU(
    radio_type="AHEH",
    ru_hw_group="RF.FRM5.trunk.20220408.017",
    serial_number="DH210474332",
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_7 = RU(
    radio_type="AHLOA",
    ru_hw_group="RF.FRM5.trunk.20220408.017",
    serial_number="K9183926118",
    pdu_port=_pdu_3.pdu_ports[7],
)

_fsp_1 = CapacityUnit(
    addr="fd5f:4268:2387:a8e::3:123d",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1172604840",
    rus=[_rmod_5],
)
_fsp_2 = CapacityUnit(
    addr="fd5f:4268:2387:a881:0040:43ff:fe80:0201",
    hardware_type="ABIN",
    hardware_version="474824A.103",
    serial_number="L1214007293",
    rus=[_rmod_1, _rmod_7],
)
_fsp_3 = CapacityUnit(
    addr="fd5f:4268:2387:a881:0040:43ff:fe80:0301",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="DH220845313",
    rus=[_rmod_6],
)
_fsp_4 = CapacityUnit(
    addr="fd5f:4268:2387:a8e::3:223d",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA184778068",
    rus=[_rmod_4],
)
_fsp_5 = CapacityUnit(
    addr="fd5f:4268:2387:a8e::3:233d",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9172606422",
    rus=[_rmod_2],
)
_fsp_6 = CapacityUnit(
    addr="fd5f:4268:2387:a8e::3:243d",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA185079918",
    rus=[_rmod_3],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1192109432",
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1171800901",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_5, _rmod_6, _rmod_7],
    oam_ip=NetworkAddress("10.15.236.225"),
    instance_id=10825,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_2, _rmod_3, _rmod_4],
    master=_enb_sbts_1,
)

_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.224", username="ute"),
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
    SshServiceDetails(addr="10.5.20.225", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_NLWG_10825_1ASIB_1ABIA_1ABIN_1ABIO_1ASIA_3ABIA_1FRHC_1AHCA_1AHIB_3AHEH_1AHLOA",
)

__all__ = ["tl"]
