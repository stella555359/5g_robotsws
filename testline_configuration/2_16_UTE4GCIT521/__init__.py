__maintainer__ = "Przemyslaw Krolikowski"
__owner_email__ = "I_MN_RAN_TRUNK_SG_WRO2@internal.nsn.com"
__email__ = "przemyslaw.krolikowski@nokia.com"

from taf.config.testline.airscale import CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.164.121", username="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.164.122", username="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_3 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.164.123", username="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(addr="10.42.51.165", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8], model="ATEN")
_pdu_2 = Gude(addr="10.42.51.151", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8], model="APC")
_pdu_3 = Gude(addr="10.42.51.153", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8], model="ATEN")
_pdu_4 = Gude(addr="10.42.51.154", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8], model="ATEN")
_pdu_5 = Gude(addr="10.42.168.146", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8], model="ATEN")
_pdu_6 = Gude(addr="10.42.169.181", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8], model="ATEN")

_fsp_1 = CapacityUnit(
    addr="192.168.253.18",
    hardware_type="FBBC",
    hardware_version="A.101",
    serial_number="NK154530237",
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.19",
    hardware_type="FBBC",
    hardware_version="A.101",
    serial_number="NK153930194",
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.18",
    hardware_type="FBBC",
    hardware_version="A.101",
    serial_number="L6144715129",
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.19",
    hardware_type="FBBC",
    hardware_version="A.101",
    serial_number="L6144841578",
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.18",
    hardware_type="FBBC",
    hardware_version="A.101",
    serial_number="L1142608136",
)

_fsp_6 = CapacityUnit(
    addr="192.168.253.19",
    hardware_type="FBBC",
    hardware_version="A.101",
    serial_number="NK153930197",
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="FSMF",
    hardware_version="A.103",
    serial_number="L1141928994",
    capacity_units=[_fsp_1, _fsp_2],
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="FSMF",
    hardware_version="A.103",
    serial_number="L1141935519",
    capacity_units=[_fsp_3, _fsp_4],
)

_fct_3 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="FSMF",
    hardware_version="A.104",
    serial_number="K9153121159",
    capacity_units=[_fsp_5, _fsp_6],
)

_smod_1 = Flexi([_fct_1])

_smod_2 = Flexi([_fct_2])

_smod_3 = Flexi([_fct_3])

_rmod_1 = RU(ru_hw_group="", serial_number="L1141610234", pdu_port=_pdu_2.pdu_ports[7])
_rmod_2 = RU(ru_hw_group="", serial_number="L1154813378", pdu_port=_pdu_2.pdu_ports[1])
_rmod_3 = RU(ru_hw_group="", serial_number="L1144000564", pdu_port=_pdu_5.pdu_ports[8])
_rmod_4 = RU(ru_hw_group="", serial_number="EA171681441", pdu_port=_pdu_6.pdu_ports[1])
_rmod_5 = RU(ru_hw_group="", serial_number="EA164180003", pdu_port=_pdu_6.pdu_ports[2])
_rmod_6 = RU(ru_hw_group="", serial_number="K9174417076", pdu_port=_pdu_3.pdu_ports[7])
_rmod_7 = RU(ru_hw_group="", serial_number="L1151002018", pdu_port=_pdu_5.pdu_ports[5])
_rmod_8 = RU(ru_hw_group="", serial_number="K9131116464", pdu_port=_pdu_5.pdu_ports[2])
_rmod_9 = RU(ru_hw_group="", serial_number="K9133823211", pdu_port=_pdu_5.pdu_ports[4])
_rmod_10 = RU(ru_hw_group="", serial_number="L1151400036", pdu_port=_pdu_4.pdu_ports[1])
_rmod_11 = RU(ru_hw_group="", serial_number="K9150911479", pdu_port=_pdu_3.pdu_ports[3])
_rmod_12 = RU(ru_hw_group="", serial_number="F7152424452", pdu_port=_pdu_2.pdu_ports[6])
_rmod_13 = RU(ru_hw_group="", serial_number="K9155150216", pdu_port=_pdu_3.pdu_ports[1])
_rmod_14 = RU(ru_hw_group="", serial_number="L6144924166", pdu_port=_pdu_4.pdu_ports[4])
_rmod_15 = RU(ru_hw_group="", serial_number="K9151112436", pdu_port=_pdu_4.pdu_ports[2])
_rmod_16 = RU(ru_hw_group="", serial_number="L6133311539", pdu_port=_pdu_2.pdu_ports[8])
_rmod_17 = RU(ru_hw_group="", serial_number="YP170701416", pdu_port=_pdu_4.pdu_ports[3])
_rmod_18 = RU(ru_hw_group="", serial_number="K9144722978", pdu_port=_pdu_2.pdu_ports[2])
_rmod_19 = RU(ru_hw_group="", serial_number="K9155010269", pdu_port=_pdu_3.pdu_ports[6])
_rmod_20 = RU(ru_hw_group="", serial_number="L1161504981", pdu_port=_pdu_2.pdu_ports[3])
_rmod_21 = RU(ru_hw_group="", serial_number="L1144915035", pdu_port=_pdu_2.pdu_ports[4])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
        _rmod_6,
        _rmod_7,
        _rmod_8,
        _rmod_9,
        _rmod_10,
    ],
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[
        _rmod_11,
        _rmod_12,
        _rmod_13,
        _rmod_14,
        _rmod_15,
        _rmod_16,
    ],
)

_enb_sbts_3 = RealEnb(
    system_module=_smod_3,
    rms=[
        _rmod_17,
        _rmod_18,
        _rmod_19,
        _rmod_20,
        _rmod_21,
    ],
)

tl = TestLine(
    test_pc=[_test_pc_1],
    test_pcs=[_test_pc_1, _test_pc_2, _test_pc_3],
    enbs=[_enb_sbts_1, _enb_sbts_2, _enb_sbts_3],
    tl_cloud_topology="CLOUD_3F_REALRF_CA1",
)

__all__ = ["tl"]
