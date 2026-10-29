# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Paulina Trela"
__email__ = "paulina.trela@nokia.com"

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CoreUnit
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
    addr="10.44.205.120",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8041-1",
)
_pdu_2 = APC(
    addr="10.44.206.193",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8220-1"
)
_pdu_3 = APC(
    addr="10.44.177.162",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8220-1"
)

_rmod_1 = RU(
    ru_hw_group="cMAAr6.2_32T32R", 
    radio_type="AQQJ",
    serial_number="NQ232691295",
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.22.0.2", port=2323),
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_2 = RU(
    ru_hw_group="cMAAr6.2_32T32R",
    radio_type="AQQJ",
    serial_number="K9243420749", 
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.22.0.6", port=2323),
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_3 = RU(
    ru_hw_group="cMAAr6.2_32T32R",
    radio_type="AQQJ",
    serial_number="K9243420750",
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.22.0.10", port=2323),
    pdu_port=_pdu_2.pdu_ports[9],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHPB",
    serial_number="K9194304166", 
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.33.128", port=2323),
    pdu_port=_pdu_1.pdu_ports[8],
)
_rmod_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHPB", 
    serial_number="K9183204807", 
    default_telnet_connection_details=TelnetConnectionDetails(addr="172.16.33.129", port=2323), 
    pdu_port=_pdu_1.pdu_ports[6],
)

_fct_1 = CoreUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_3.pdu_ports[7],
    hardware_type="ASOE",
    hardware_version="A.101",
    serial_number="EA211854181",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
)

_smod_1 = Airscale(core_units=[_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    oam_ip=NetworkAddress("10.42.84.62"),
    instance_id=8037,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.156.191", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.core_units[0],
            interface_type="lmp",
        )
    ],
)

_pdus = [_pdu_1, _pdu_2, _pdu_3]

tl = TestLine(
    test_pc=_test_pc_1,
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_N_1xASOE_3xAQQJ_2xAHPB_UTECA",
    pdus=_pdus,
)

__all__ = ["tl"]
