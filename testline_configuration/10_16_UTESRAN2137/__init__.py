__maintainer__ = "Jakub Ozierski"
__email__ = "jakub.ozierski@nokia.com"
# BTS ID: 5078
# BTS Name: Axe

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


_pdu_1 = Gude("10.42.80.128", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")
_pdu_2 = Gude("10.42.80.195", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")

_rmod_1 = RU(
    ru_hw_group="FRM32.13.R04",
    serial_number="L1145006938",
    pdu_port=_pdu_1.pdu_ports[8],
    radio_type="FRGY",
)
_rmod_2 = RU(
    ru_hw_group="RF.FRM5.22R2.20220203.004",
    serial_number="EA174113447",
    pdu_port=_pdu_1.pdu_ports[7],
    radio_type="AHFB",
)
_rmod_3 = RU(
    ru_hw_group="RF.FRM5.22R2.20220203.004",
    serial_number="EA174211161",
    pdu_port=_pdu_1.pdu_ports[6],
    radio_type="AHIB",
)
_rmod_4 = RU(
    ru_hw_group="VEG22.13.R02",
    serial_number="F7153842928",
    pdu_port=_pdu_1.pdu_ports[12],
    radio_type="FXDB",
)
_rmod_5 = RU(
    ru_hw_group="RF.FRM5.22R2.20220203.004",
    serial_number="AS204801926",
    pdu_port=_pdu_1.pdu_ports[9],
    radio_type="AHCA",
)
_rmod_6 = RU(
    ru_hw_group="RF.FRM5.22R2.20220203.004",
    serial_number="EA203856873",
    pdu_port=_pdu_2.pdu_ports[2],
    radio_type="AHEH",
)
_rmod_7 = RU(
    ru_hw_group="RF.FRM5.22R2.20220203.004",
    serial_number="6Q184814311",
    pdu_port=_pdu_2.pdu_ports[7],
    radio_type="AHEC",
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1172906416",
    rus=[_rmod_4],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1172906424",
    rus=[_rmod_1, _rmod_4, _rmod_7],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIN",
    hardware_version="474824A.101",
    serial_number="L1205105842",
    rus=[_rmod_3],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204209896",
    rus=[_rmod_2],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.34",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211511275",
    rus=[_rmod_5, _rmod_6],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="ASIL",
    hardware_version="A474767A.101",
    serial_number="L1202606199",
)
_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1202800735",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_3, _rmod_4, _rmod_7],
    oam_ip=NetworkAddress("10.42.182.5"),
    instance_id=5078,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_2, _rmod_5, _rmod_6],
    master=_enb_sbts_1,
)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.9", username="ute"),
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
    SshServiceDetails(addr="10.42.133.10", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_NLWG_2ASIL_2ABIA_2ABIO_1ABIN_1FRGY_1AHFB_1AHIB_1FXDB_AHCA_AHEH_AHEC",
)

__all__ = ["tl"]
