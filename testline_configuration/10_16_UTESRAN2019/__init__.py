__maintainer__ = "Jakub Ozierski"
__email__ = "jakub.ozierski@nokia.com"



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

_pdu_1 = Gude("10.42.199.151", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")

_rmod_1 = RU(
    radio_type="FXEB",
    ru_hw_group="FRMr2.3_3T6R",
    serial_number="K9144100128",
    pdu_port=_pdu_1.pdu_ports[9],
)
_rmod_2 = RU(
    radio_type="FXEB",
    ru_hw_group="FRMr2.3_3T6R",
    serial_number="L6144950988",
    pdu_port=_pdu_1.pdu_ports[12],
)
_rmod_3 = RU(
    radio_type="FXJB",
    ru_hw_group="FRMr2.3_3T6R",
    serial_number="K9170226111",
    pdu_port=_pdu_1.pdu_ports[11],
)
_rmod_4 = RU(
    radio_type="FXJB",
    ru_hw_group="FRMr2.3_3T6R",
    serial_number="K9170734958",
    pdu_port=_pdu_1.pdu_ports[10],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.18",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="L6151132849",
    rus=[_rmod_1, _rmod_2],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.19",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="NK170732601",
    rus=[_rmod_3, _rmod_4],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="FSMF",
    hardware_version="A.103",
    serial_number="F7141741656",
    capacity_units=[_fsp_1, _fsp_2],
)

_smod_1 = Flexi([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
    oam_ip=NetworkAddress("10.42.18.63"),
    instance_id=5054,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.62.93", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_LWG_1FSMF_2FBBC_2FXJB_2FXEB",
)

__all__ = ["tl"]
