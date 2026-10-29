# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Katarzyna Kot-Bartkowiak"
__team__ = "RAN_PZ_WRO3_SG01"
__email__ = "I_MN_RAN_PZ_OPER_WRO_1_VRF@internal.nsn.com"
__owner_email__ = "katarzyna.kot-bartkowiak@nokia.com"

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CoreUnit
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
from taf.config.testline.testpc import TestPc
from taf.config.testline import Connection

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc


_pdu_1 = Gude(
    addr="10.42.60.139",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8220-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    radio_type="AHFB",
    serial_number="EA173612546",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    radio_type="AHIB",
    serial_number="EA174810878",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)

_fct_1 = CoreUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASOF",
    hardware_version="A.101",
    serial_number="EA232850439",
    rus=[_rmod_1, _rmod_2],
)

_smod_1 = Airscale(core_units=[_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2],
    oam_ip=NetworkAddress("10.42.20.130"),
    instance_id=8086,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.39", username="ute"), 
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.core_units[0],
            interface_type="lmp",
        )
    ],
)

_pdus = [_pdu_1]

tl = TestLine(
    test_pc=_test_pc_1,
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_NL_1ASOF_1AHFB_1AHIB_UTECA",
    pdus=_pdus,
)

__all__ = ["tl"]
