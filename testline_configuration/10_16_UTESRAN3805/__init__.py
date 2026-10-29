__maintainer__ = "Jakub Ozierski"
__email__ = "jakub.ozierski@nokia.com"


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


_pdu_1 = Gude("10.42.60.68", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")
_pdu_2 = Gude("10.42.80.128", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")

_rmod_1 = RU(
    radio_type="AZQP",
    ru_hw_group="RF.ERM6.23R3.20230708.001",
    serial_number="1M203844898",
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_2 = RU(
    radio_type="AHEB",
    ru_hw_group="RF.FRM5.23R3.20230719.003",
    serial_number="L1181107579",
    pdu_port=_pdu_1.pdu_ports[11],
)
_rmod_3 = RU(
    radio_type="FRGU",
    ru_hw_group="FRM33.32.R02D",
    serial_number="L1154813412",
    pdu_port=_pdu_1.pdu_ports[9],
)
_rmod_4 = RU(
    radio_type="FXED",
    ru_hw_group="FRM33.32.R02D",
    serial_number="F7154832801",
    pdu_port=_pdu_1.pdu_ports[12],
)
_rmod_7 = RU(
    radio_type="AZQS",
    ru_hw_group="RF.ERM6.23R3.20230708.001",
    serial_number="1M213113938",
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_11 = RU(
    radio_type="FXDB",
    ru_hw_group="VEG23.23.R01",
    serial_number="F7171453993",
    pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_12 = RU(
    radio_type="FXDB",
    ru_hw_group="VEG23.23.R01",
    serial_number="F7171524308",
    pdu_port=_pdu_1.pdu_ports[8],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1204706808",
    rus=[_rmod_7],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1204705907",
    rus=[_rmod_1],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1163607851",
    rus=[_rmod_11, _rmod_12],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1164512021",
    rus=[_rmod_4],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.34",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1163517858",
    rus=[_rmod_2],
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1163605496",
    rus=[_rmod_2, _rmod_3],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1190608724",
)
_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASIA",
    hardware_version="473095A.101",
    serial_number="L1162802406",
)
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_11, _rmod_12],
    oam_ip=NetworkAddress("10.42.182.116"),
    instance_id=5009,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_3, _rmod_4, _rmod_7],
    master=_enb_sbts_1,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.125", username="ute"),
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
    SshServiceDetails(addr="10.42.133.126", username="ute"),
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
    tl_cloud_topology="CLOUD_SRAN_NLWG_1ASIB_2ABIO_1ABIA_1ASIA_3ABIA_2FXDB_FXDE_FRGU_AHEB_AZQP_AZQS",
)

__all__ = ["tl"]
