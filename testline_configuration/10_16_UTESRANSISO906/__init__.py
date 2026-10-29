__maintainer__ = "Daria Wronska"
__team__ = "siso"
__email__ = "daria.wronska@nokia.com"
__owner_email__ = "daria.wronska@nokia.com"

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
from taf.config.testline.pdu import ATEN
from taf.config.testline.radio import RU
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc

_pdu_1 = Gude("10.42.169.33", [2, 5], "EPC", "8220-1")
_pdu_2 = ATEN("10.42.169.16", [7], "", "")
_pdu_3 = Gude("10.42.169.32", [11, 12], "EPC", "8220-1")


_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    serial_number="EA174410379",
    pdu_port=_pdu_1.pdu_ports[2],
    radio_type="AHIB",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.129", port=2323
    ),
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    serial_number="EA174410248",
    pdu_port=_pdu_3.pdu_ports[11],
    radio_type="AHIB",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr=" 172.16.37.128", port=2323
    ),
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    serial_number="EA174410361",
    pdu_port=_pdu_3.pdu_ports[12],
    radio_type="AHIB",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr=" 172.16.37.130", port=2323
    ),
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223309845",
    pdu_port=_pdu_2.pdu_ports[7],
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_2.pdu_ports[7],
    hardware_type="ASIB",
    serial_number="DH214044572",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.42.174.170"),
    instance_id=1435,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.184.27", username="ute"),
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
    tl_cloud_topology="CLOUD_10_16_UTESRANSISO906",
)

__all__ = ["tl"]
