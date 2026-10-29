__maintainer__ = "Jakub Ozierski"
__email__ = "jakub.ozierski@nokia.com"
# BTS ID: 5084
# BTS Name: Asolka

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

_pdu_1 = Gude("10.42.199.244", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")

_rmod_1 = RU(
    radio_type="FXED",
    ru_hw_group="FRM33.27.R01",
    serial_number="F7154832795",
    pdu_port=_pdu_1.pdu_ports[4],
)
_rmod_2 = RU(
    radio_type="AHFIC",
    ru_hw_group="RF.FRM5.23R2.20230327.003",
    serial_number="BL2037K2098",
    pdu_port=_pdu_1.pdu_ports[7],
)
_rmod_3 = RU(
    radio_type="AHFB",
    ru_hw_group="RF.FRM5.23R2.20230327.003",
    serial_number="EA174113459",
    pdu_port=_pdu_1.pdu_ports[9],
)
_rmod_4 = RU(
    radio_type="AHIB",
    ru_hw_group="RF.FRM5.23R2.20230327.003",
    serial_number="EA185013661",
    pdu_port=_pdu_1.pdu_ports[2],
)
_rmod_5 = RU(
    radio_type="AHCA",
    ru_hw_group="RF.FRM5.23R2.20230327.003",
    serial_number="L1181700166",
    pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_6 = RU(
    radio_type="AHIB",
    ru_hw_group="RF.FRM5.23R2.20230327.003",
    serial_number="EA174211171",
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_7 = RU(
    radio_type="AHIB",
    ru_hw_group="RF.FRM5.23R2.20230327.003",
    serial_number="EA174211168",
    pdu_port=_pdu_1.pdu_ports[1],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173004924",
    rus=[_rmod_1, _rmod_2],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1163517860",
    rus=[_rmod_2, _rmod_3],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1192700699",
    rus=[_rmod_4],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204301240",
    rus=[_rmod_5],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIN",
    hardware_version="474824A.102",
    serial_number="L1204906164",
    rus=[_rmod_6],
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.32",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1193315222",
    rus=[_rmod_7],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1210402813",
)
_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1210304033",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
    oam_ip=NetworkAddress("10.42.182.8"),
    instance_id=5007,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_5, _rmod_6, _rmod_7],
    master=_enb_sbts_1
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.5", username="ute"),
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
    SshServiceDetails(addr="10.42.250.227", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_enb_sbts_1.slave = _enb_sbts_2

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NLWG_ASIL_2ABIA_ABIL_ASIL_ABIO_ABIN_ABIL_3AHIB_AHCA_AHFIC_AHFB_FXED",
)

__all__ = ["tl"]
