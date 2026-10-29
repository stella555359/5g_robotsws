__maintainer__ = "Jakub Ozierski"
__email__ = "jakub.ozierski@nokia.com"
# BTS ID: 5022
# BTS name: Jeze

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
    radio_type="AHFIC",
    ru_hw_group="RF.FRM5.trunk.20231108.002",
    serial_number="K9200523334",
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_2 = RU(
    radio_type="FXDB",
    ru_hw_group="VEG23.23.R01D",
    serial_number="1M143967863",
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_3 = RU(
    radio_type="AHLOA",
    ru_hw_group="RF.FRM5.trunk.20231108.002",
    serial_number="BL1930G11NC",
    pdu_port=_pdu_2.pdu_ports[5],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1182817127",
    rus=[_rmod_1, _rmod_2],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1162608156",
    rus=[_rmod_2],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211511258",
    rus=[_rmod_3]
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_2.pdu_ports[7],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1190601870",
)
_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3],
    pdu_port=_pdu_2.pdu_ports[8],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1190601906",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2],
    oam_ip=NetworkAddress("10.42.182.108"),
    instance_id=5022,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_3],
    master=_enb_sbts_1,
)

_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.21", username="ute"),
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
    SshServiceDetails(addr="10.42.133.22", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_NLWG_ASIB_2ABIA_ASIB_ABIO_AHFIC_FXDB_AHLOA",
)

__all__ = ["tl"]
