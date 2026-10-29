__maintainer__ = "Jakub Ozierski"
__email__ = "jakub.ozierski@nokia.com"
# BTS ID: 5077
# BTS Name: Tesla

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

_pdu_1 = Gude("10.42.60.48", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")

_rmod_1 = RU(
    radio_type="FXDB",
    ru_hw_group="VEG22.42.R01",
    serial_number="F7173209230",
    pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_2 = RU(
    radio_type="FRGU",
    ru_hw_group="FRM32.41.R01",
    serial_number="K9171026870",
    pdu_port=_pdu_1.pdu_ports[8],
)
_rmod_4 = RU(
    radio_type="FXED",
    ru_hw_group="FRM32.41.R01",
    serial_number="1M184443740",
    pdu_port=_pdu_1.pdu_ports[11],
)
_rmod_5 = RU(
    radio_type="FXED",
    ru_hw_group="FRM32.41.R01",
    serial_number="F7172701259",
    pdu_port=_pdu_1.pdu_ports[10],
)
_rmod_6 = RU(
    radio_type="FRHC",
    ru_hw_group="FRM32.41.R01",
    serial_number="F7173820988",
    pdu_port=_pdu_1.pdu_ports[7],
)
_rmod_7 = RU(
    radio_type="FRHC",
    ru_hw_group="FRM32.41.R01",
    serial_number="L1141527945",
    pdu_port=_pdu_1.pdu_ports[9],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173602188",
    rus=[_rmod_1, _rmod_4, _rmod_5, _rmod_6, _rmod_7],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173602158",
    rus=[_rmod_1, _rmod_2],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[12],
    hardware_type="ASIA",
    hardware_version="A.101",
    serial_number="L1173810166",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_4, _rmod_5, _rmod_6, _rmod_7],
    oam_ip=NetworkAddress("10.42.182.3"),
    instance_id=5077,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.250.195", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_LW_1ASIA_2ABIA_FXDB_FRGU_2FXED_2FRHC",
)

__all__ = ["tl"]
