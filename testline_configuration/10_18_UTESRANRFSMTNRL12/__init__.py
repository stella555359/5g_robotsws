__maintainer__ = "constantin.diaconu@nokia.com"
__owner__ = "constantin.diaconu@nokia.com"
__email__ = "constantin.diaconu@nokia.com"

import os
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude, FPFH, PSU, APC
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit, CoreUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.dcap import DcapRnD, DcapBasic
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt
from taf.config.testline.lmi import SerialOverHost, SerialOverTcp, Local, Remote

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.90", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.91", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_3 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.96", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_4 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.57", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = APC(
    "10.255.5.102",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    version="AP7922B",
)
_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[13].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[14].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[15].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[16].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude(
    "10.255.5.103",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"

_pdu_3 = Gude(
    "10.255.5.104",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_3.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[6].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="K9181741639",
    pdu_port=_pdu_1.pdu_ports[4],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="K9184601144",
    pdu_port=_pdu_1.pdu_ports[3],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="K9181609339",
    pdu_port=_pdu_1.pdu_ports[8],

)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2039V0M3M",
    pdu_port=_pdu_3.pdu_ports[1],

)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2031V0F1C",
    pdu_port=_pdu_3.pdu_ports[2],

)
_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2051V0WRI",
    pdu_port=_pdu_3.pdu_ports[3],

)

_rmod_1b = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="K9190717943",
    pdu_port=_pdu_1.pdu_ports[1],
)

_rmod_2b = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="K9180132751",
    pdu_port=_pdu_1.pdu_ports[2],
)

_rmod_3b = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL1944V00FF",
    pdu_port=_pdu_1.pdu_ports[6],

)

_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEHC.value,
    serial_number="K9222600591",
    pdu_port=_pdu_1.pdu_ports[5],
)

_rmod_8 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEHC.value,
    serial_number="K9222600588",
    pdu_port=_pdu_1.pdu_ports[7],
)
_rmod_9 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEHC.value,
    serial_number="K9222600589",
    pdu_port=_pdu_3.pdu_ports[5],

)

_rmod_10 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQQA.value,
    serial_number="L1250102672",
    pdu_port=_pdu_1.pdu_ports[9],
)

_rmod_11 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQQA.value,
    serial_number="L1251202483",
    pdu_port=_pdu_1.pdu_ports[10],
)
_rmod_12 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQQA.value,
    serial_number="L1251202480",
    pdu_port=_pdu_3.pdu_ports[6],

)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1171013137",
    rus=[_rmod_1b, _rmod_2b, _rmod_3b],
)
_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173729545",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)
_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA184778054",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="EA210255348",
    rus=[_rmod_1, _rmod_2],
)
_fsp_5 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="L1201204096",
    rus=[_rmod_3],
)
_fsp_6 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204104860",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)

_fsp_7 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1243301266",
    rus=[_rmod_7, _rmod_8, _rmod_9, _rmod_10, _rmod_11, _rmod_12],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_2.pdu_ports[3],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1204107366",
    test_pc=_test_pc_1,
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_7],
    pdu_port=_pdu_2.pdu_ports[4],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1211905219",
    test_pc=_test_pc_2,
)
_fct_3 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_2.pdu_ports[1],
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="EA190273391",
    test_pc=_test_pc_3,
)

_fct_4 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_2.pdu_ports[2],
    hardware_type="FSMF",
    hardware_version="472181A",
    serial_number="L1142222339",
    test_pc=_test_pc_4,
)

_smod_1 = Airscale([_fct_1, _fct_2])
_smod_2 = Airscale([_fct_3, _fct_4])

_enb_NR = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9, _rmod_10, _rmod_11, _rmod_12],
    instance_id=623012,
    oam_ip=NetworkAddress("10.0.65.12"),
)
_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_NR.system_module.common_units[0],
        interface_type="lmp",
    )
)
_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_NR.system_module.common_units[1],
        interface_type="lmp",
    )
)

_enb_SBTS = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_1b, _rmod_2b, _rmod_3b],
    instance_id=621012,
    oam_ip=NetworkAddress("10.0.69.12"),
)
_test_pc_3.connections.append(
    Connection(
        interface="eth1",
        device=_enb_SBTS.system_module.common_units[0],
        interface_type="lmp",
    )
)
_test_pc_4.connections.append(
    Connection(
        interface="eth1",
        device=_enb_SBTS.system_module.common_units[1],
        interface_type="lmp",
    )
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2, _test_pc_3, _test_pc_4],
    enbs=[_enb_NR, _enb_SBTS],
    tl_cloud_topology="CLOUD_HRAN_RFS_MTNRL12",
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "POWER_ON_FLAG": True,
    "USER_RTWP_CHECK": False,
    "USER_STOP_AND_FIX": True,
    "USER_STOP_AND_FIX_BLOCK_TEST": True,
    "USER_DCAP_TRACE_COLLECT": True,
    "USER_DCAP_TRACE_COLLECT_Master": True,
    "USER_DCAP_TRACE_COLLECT_Slave": True,
    "USER_RSI_INFO_COLLECT": True,
    "USER_SCF_VALIDATION_CHECK": False,
    "NETACT_CHECK": False,
}

__all__ = ["tl"]