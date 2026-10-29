__maintainer__ = "Marcin Berkowski"
__email__ = "marcin.berkowski@nokia.com"
# BTS ID: 5057
# BTS name: Galileo2

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline import Connection
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc


from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc


_pdu_1 = Gude("10.42.80.143", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_2 = Gude("10.42.80.157", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")

_rmod_1 = RU(
    radio_type="FXED",
    ru_hw_group="FRM33.32.R16D",
    serial_number="F7173049371",
    pdu_port=_pdu_1.pdu_ports[8],
)
_rmod_2 = RU(
    radio_type="FXDB",
    ru_hw_group="VEG23.23.R09D",
    serial_number="1M171321219",
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_3 = RU(
    radio_type="AZHL",
    ru_hw_group="20240421.002",
    serial_number="AH221630190",
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_4 = RU(
    radio_type="AHFIB",
    ru_hw_group="RF.FRM5.trunk24.20240419.008",
    serial_number="BL2241V0CQC",
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_5 = RU(
    radio_type="FRGU",
    ru_hw_group="FRM33.32.R16D",
    serial_number="K9170918496",
    pdu_port=_pdu_1.pdu_ports[11],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173008327",
    rus=[_rmod_1, _rmod_2, _rmod_5],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204509708",
    rus=[_rmod_4],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171212683",
    rus=[_rmod_5],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204301239",
    rus=[],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233803087",
    rus=[_rmod_3],
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.32",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233803068",
    rus=[],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_5],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIM",
    hardware_version="474767A.101",
    serial_number="L1233503557",
)
_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASIL",
    hardware_version="475765A.104",
    serial_number="L1214008202",
)
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    oam_ip=NetworkAddress("10.42.182.97"),
    instance_id=5057,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_5],
    master=_enb_sbts_1,
)

_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.231", username="ute"),
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
    SshServiceDetails(addr="10.42.62.192", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_NLWG_ASIM_ASIL_2ABIA_2ABIO_2ABIP_FXED_FXDB_AZHL_AHFIB_FRGU",
)

__all__ = ["tl"]
