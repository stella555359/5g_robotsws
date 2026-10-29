__maintainer__ = "Artur Kaczybura"
__team__ = "siso"
__email__ = "artur.kaczybur@nokia.com"
__owner_email__ = "artur.kaczybura@nokia.com"

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.optical_switch import OpticalSwitch, Leoni
from taf.config.testline.testpc import TestPc, Connection


_pdu_1 = Gude("10.42.169.165", [4, 9, 10, 11], "EPC", "8221-1")
_pdu_2 = Gude("10.42.168.251", [3, 11], "EPC", "8221-1")
_pdu_3 = Gude("10.42.169.167", [2, 3], "EPC", "8221-1")


_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="BL1933G10OF",
    pdu_port=_pdu_3.pdu_ports[3],
    product_code="474331A.101",
    radio_type="AHLOA",
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="K9190907509",
    pdu_port=_pdu_1.pdu_ports[11],
    product_code="474331A.101",
    radio_type="AHLOA",
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="K9190907510",
    pdu_port=_pdu_1.pdu_ports[9],
    product_code="474331A.101",
    radio_type="AHLOA",
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="K9175116258",
    pdu_port=_pdu_3.pdu_ports[2],
    product_code="474216A.101",
    radio_type="AHFIB",
)
_rmod_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="BL1919V00IX",
    pdu_port=_pdu_1.pdu_ports[10],
    product_code="474216A.101",
    radio_type="AHFIB",
)
_rmod_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="K9181046169",
    pdu_port=_pdu_1.pdu_ports[4],
    product_code="474216A.101",
    radio_type="AHFIB",
)


_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="L1162717654",
    pdu_port=_pdu_2.pdu_ports[3],
    rus=[_rmod_3 ],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    serial_number="L1172804854",
    pdu_port=_pdu_2.pdu_ports[3],
    rus=[_rmod_6],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    serial_number="L1171802347",
    pdu_port=_pdu_2.pdu_ports[11],
    rus=[_rmod_4],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    serial_number="L1164413241",
    pdu_port=_pdu_2.pdu_ports[3],
    rus=[_rmod_1, _rmod_2],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    serial_number="L1215008525",
    pdu_port=_pdu_2.pdu_ports[3],
    rus=[_rmod_5],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_2.pdu_ports[3],
    hardware_type="ASIB",
    serial_number="L1182413248",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu_2.pdu_ports[11],
    hardware_type="ASIB",
    serial_number="L1202810837",
)

# _opt_sw_1 = Leoni(addr="10.42.170.189", model="mol 10x(1x2)", port=10001)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_4, _rmod_3, _rmod_6],
    oam_ip=NetworkAddress("10.42.174.201"),
    instance_id=1457,
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_5],
    master=_enb_sbts_1,
)

_enb_sbts_1.slave = _enb_sbts_2


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.184.152", username="ute"),
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
    SshServiceDetails(addr="10.42.184.153", username="ute"),
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
    #    optical_switches=[_opt_sw_1],
)

__all__ = ["tl"]
