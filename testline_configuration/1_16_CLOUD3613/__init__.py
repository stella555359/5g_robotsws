__maintainer__ = "Szymon Romanowski"
__team__ = "MN RAN Pz WRO 3 SG05"
__email__ = "szymon.romanowski@nokia.com"
__owner_email__ = "szymon.romanowski@nokia.com"

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
from taf.config.testline import Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc

_pdu_1 = Gude("10.42.80.127", [12], "EPC", "8220-1")
_pdu_2 = Gude("10.42.80.122", [6], "EPC", "8220-1")
_pdus = [_pdu_1, _pdu_2]

_rmod_1 = RU(
    radio_type="RadioTypes.AHPD.value",
    ru_hw_group="RF.FRM5.trunk24.20250112.001",
    product_code="474712A.101", 
    serial_number="6Q200201934",   
    default_telnet_connection_details=TelnetConnectionDetails(
    addr="172.16.33.128", port=2323
   ),
    pdu_port=_pdu_2.pdu_ports[6],
)

_fct_1 = CoreUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[12],
    hardware_type="ASOE",
    hardware_version="475587A.101",
    serial_number="EA211854090",
    rus=[_rmod_1],
)

_smod_1 = Airscale(core_units=[_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],
    oam_ip=NetworkAddress("10.42.20.231"),
    instance_id=100860,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.62.15", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.core_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_RF_ASOE_AZHA",
)

__all__ = ["tl"]
