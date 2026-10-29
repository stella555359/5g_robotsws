# This script was generated automatically, --None-- values indicate lacking data, please fill them manually
__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "marek.starzyk@nokia.com"
__customer__ = "Generic"
__bucket__ = "STRESSED_TEST_LINES"
__rack__ = "GTA-915"

from taf.config.testline.enb import RealEnb
from taf.config.testline.airscale import Airscale
from taf.config.testline.pdu import Gude
from taf.config.testline.pdu import ATEN
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline import Connection
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.lmi import SerialOverTcp, Remote, SerialOverHost, Local

# ************************************************ PDUs ************************************************

#SMOD PORT 1-ASIM_L, PORT 2-ASIM_P; RMOD PORT 3-ARDB_2152, PORT 4-ARDB_2181, PORT 5-AWHHJ_7352, PORT 6-AWHHJ_7341
_pdu_1 = ATEN(
    addr="10.42.199.231",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
)

#RMOD PORT 5-AVQA_3484, PORT 6-AVQA_3485, PORT 10-AHEGHA_9603, PORT 11-AVQA_3487
_pdu_2 = Gude(
    addr="10.42.80.63",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu_1, _pdu_2]

# ************************************************ RMs *************************************************

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type="ARDB",
    serial_number="LR250502152",
    pdu_port=_pdu_1.pdu_ports[3],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.32", port=5001),
        ]
    ),
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type="ARDB",
    serial_number="LR250502181",
    pdu_port=_pdu_1.pdu_ports[4],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.140", port=5001),
        ]
    ),
)
_rmod_3 = RU(
    ru_hw_group="ScRMTDr6.2_4T4R",
    radio_type="AWHHJ",
    serial_number="1M244307352",
    pdu_port=_pdu_1.pdu_ports[5],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.38", port=5001),
        ]
    ),
)
_rmod_4 = RU(
    ru_hw_group="ScRMTDr6.2_4T4R",
    radio_type="AWHHJ",
    serial_number="1M244307341",
    pdu_port=_pdu_1.pdu_ports[6],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.28", port=5001),
        ]
    ),
)
_rmod_5 = RU(
    ru_hw_group="FRMr5.1_2T4R",
    radio_type="AHEGHA",
    serial_number="K9245049603",
    pdu_port=_pdu_2.pdu_ports[10],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.192", port=5001),
        ]
    ),
)
_rmod_6 = RU(
    ru_hw_group="cMAAr7.1_32T32R",
    radio_type="AVQA",
    serial_number="L1250103487",
    pdu_port=_pdu_2.pdu_ports[11],
)
_rmod_7 = RU(
    ru_hw_group="cMAAr7.1_32T32R",
    radio_type="AVQA",
    serial_number="L1250103485",
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_8 = RU(
    ru_hw_group="cMAAr7.1_32T32R",
    radio_type="AVQA",
    serial_number="L1250103484",
    pdu_port=_pdu_2.pdu_ports[5],
)

# ************************************************ DUAL-ASIM ************************************************

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171304592",
    rus=[_rmod_5],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIN",
    hardware_version="474824A.103",
    serial_number="L1213615746",
    rus=[_rmod_5],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173805319",
    rus=[_rmod_1, _rmod_2],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1244007761",
    rus=[_rmod_6, _rmod_7, _rmod_8],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1244007749",
    rus=[_rmod_3, _rmod_4],
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1244806860",
    rus=[_rmod_5],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="DH250403400",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="DH250403339",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_5], global_bts_id=5015, instance_id=5015)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8],
                      master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2

# ************************************************ VMs ************************************************

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.217", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.133.218", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    pdus=_pdus,
    tl_cloud_topology="CLOUD_SRAN_NLWG_2ASIM_2ABIA_1ABIN_3ABIP_3AVQA_2AWHHJ_2ARDB_1AHEGHA_UUFWRO",
)

__all__ = ["tl"]
