# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Paulina Trela"
__email__ = "paulina.trela@nokia.com"
import os
from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CoreUnit
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
from taf.config.testline.testpc import TestPc
from taf.config.testline.attenuator import TopYoung
from taf.config.testline import Connection

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol


_pdu_1 = APC(
    addr="10.44.177.162",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_2 = APC(
    addr="10.44.177.164",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    radio_type="AHIB",
    serial_number="EA174110418",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    radio_type="AHFB",
    serial_number="EA174113441",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
   pdu_port=_pdu_2.pdu_ports[4],
)

_fct_1 = CoreUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
	
    ),
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASOF",
    hardware_version="A.101",
    serial_number="EA232850408",
    rus=[_rmod_1, _rmod_2],
)

_smod_1 = Airscale(core_units=[_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2],
    oam_ip=NetworkAddress("10.42.86.165"),
    instance_id=8391,
)


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.156.194", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.core_units[0],
            interface_type="lmp",
        )
    ],
)


_pdus = [_pdu_1, _pdu_2]

tl = TestLine(
    test_pc=_test_pc_1,
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_NL_1ASOF_1AHIB_1AHFB_UTECA",
    pdus=_pdus,
)

__all__ = ["tl"]
