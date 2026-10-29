__maintainer__ = "Jakub Ozierski"
__email__ = "jakub.ozierski@nokia.com"
# BTS ID: 5021
# BTS Name: Libra

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude, ATEN
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

_pdu_1 = ATEN(addr="10.42.80.51", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12])
_pdu_2 = ATEN(addr="10.42.80.96", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12])

_rmod_1 = RU(
    radio_type="FXDB",
    ru_hw_group="VEG21.06.R02",
    serial_number="1M143924972",
    pdu_port=_pdu_1.pdu_ports[2],
)
_rmod_2 = RU(
    radio_type="AHFIC",
    ru_hw_group="FRM51.07.R26",
    serial_number="K9200523333",
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_3 = RU(
    radio_type="AHFIB",
    ru_hw_group="FRM51.07.R26",
    serial_number="BL1911V00CF",
    pdu_port=_pdu_2.pdu_ports[3],
)

_fsp_1 = CapacityUnit(
    addr="fd5f:4268:2387:a881:0040:43ff:fe80:0101",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204301226",
    rus=[_rmod_3],
)
_fsp_2 = CapacityUnit(
    addr="fd5f:4268:2387:a881:0040:43ff:fe80:0201",
    hardware_type="ABIN",
    hardware_version="474824A.101",
    serial_number="L1204212544",
    rus=[_rmod_2],
)
_fsp_3 = CapacityUnit(
    addr="fd5f:4268:2387:a881:0040:43ff:fe80:0300",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173708021",
    rus=[_rmod_1],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_2.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1190601899",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    oam_ip=NetworkAddress("10.42.18.250"),
    instance_id=5021,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.250.226", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_LWG_1ASIB_1ABIO_2ABIA_1FXDB_1AHFIC_1AHFIB",
)

__all__ = ["tl"]
