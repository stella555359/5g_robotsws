# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Denis Gruia"
__email__ = "denis.gruia@nokia.com"

from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude, FPFH
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.connection_details import SshServiceDetails

from taf.config.testline.testpc import TestPc, Connection

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.158", username="ute", password="UTE.debian12"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.20.159", username="ute", password="UTE.debian12"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = FPFH(
    "10.255.3.31",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    login="admin",
    password="admin",
)
_pdu_2 = FPFH(
    "10.255.3.32",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    login="admin",
    password="admin",
)
_pdu_3 = FPFH(
    "10.255.3.30",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    login="admin",
    password="admin",
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

_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_pdu_3.pdu_ports[12].contactor = "NORMALLY_CLOSED"

# pos 1:1
_fsp_1 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1222202163",
)

# pos 1:2
_fsp_2 = CapacityUnit(
    addr="192.168.253.25",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1221800948",
)

# pos 1:3
_fsp_3 = CapacityUnit(
    addr="192.168.253.29",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="DH221046292",
)

# pos 2:1
_fsp_4 = CapacityUnit(
    addr="192.168.253.37",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1222006185",
)

# pos 2:2
_fsp_5 = CapacityUnit(
    addr="192.168.253.41",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1222101793",
)

# pos 2:3
_fsp_6 = CapacityUnit(
    addr="192.168.253.45",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1222202236",
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_2.pdu_ports[1],
    hardware_type="ASIB",
    serial_number="DH200762699",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_2.pdu_ports[2],
    hardware_type="ASIB",
    serial_number="L1204013270",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXED.value,
    serial_number="F7165121033",
    pdu_port=_pdu_1.pdu_ports[3],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXED.value,
    serial_number="F7164823175",
    pdu_port=_pdu_1.pdu_ports[4],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXED.value,
    serial_number="F7180820099",
    pdu_port=_pdu_1.pdu_ports[2],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXED.value,
    serial_number="F7180820105",
    pdu_port=_pdu_1.pdu_ports[1],
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGB.value,
    serial_number="K9190103644",
    pdu_port=_pdu_1.pdu_ports[5],
)

_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGB.value,
    serial_number="K9190103654",
    pdu_port=_pdu_1.pdu_ports[6],
)

_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXED.value,
    serial_number="L1152303354",
    pdu_port=_pdu_1.pdu_ports[7],
)

_rmod_8 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXED.value,
    serial_number="F7183519770",
    pdu_port=_pdu_1.pdu_ports[8],
)

_rmod_9 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXED.value,
    serial_number="F7165065574",
    pdu_port=_pdu_1.pdu_ports[9],
)

_rmod_10 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXED.value,
    serial_number="F7173563087",
    pdu_port=_pdu_1.pdu_ports[10],
)

_rmod_11 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXED.value,
    serial_number="F7173503757",
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_12 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXED.value,
    serial_number="F7173563072",
    pdu_port=_pdu_2.pdu_ports[5],
)

_rmod_13 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXED.value,
    serial_number="L1170715214",
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_14 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXED.value,
    serial_number="1M171777350",
    pdu_port=_pdu_2.pdu_ports[7],
)

_rmod_15 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXED.value,
    serial_number="F7173503796",
    pdu_port=_pdu_2.pdu_ports[8],
)

_rmod_16 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXED.value,
    serial_number="F7165057123",
    pdu_port=_pdu_2.pdu_ports[9],
)

_rmod_17 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXED.value,
    serial_number="F7165057299",
    pdu_port=_pdu_2.pdu_ports[11],
)

_rmod_18 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXED.value,
    serial_number="F7165057165",
    pdu_port=_pdu_1.pdu_ports[12],
)

_rmod_19 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXED.value,
    serial_number="F7173600653",
    pdu_port=_pdu_3.pdu_ports[12],
)

_rmod_20 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXED.value,
    serial_number="F7162935744",
    pdu_port=_pdu_2.pdu_ports[10],
)

_rmod_21 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXED.value,
    serial_number="F7173563069",
    pdu_port=_pdu_2.pdu_ports[11],
)

_rmod_22 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXED.value,
    serial_number="F7173600657",
    pdu_port=_pdu_2.pdu_ports[12],
)

_fsp_1.rus = [_rmod_1, _rmod_2, _rmod_3, _rmod_4]
_fsp_2.rus = [_rmod_5, _rmod_6]
_fsp_3.rus = [_rmod_7, _rmod_8, _rmod_9, _rmod_10]
_fsp_4.rus = [_rmod_11, _rmod_14, _rmod_15]
_fsp_5.rus = [_rmod_16, _rmod_17, _rmod_18]
_fsp_6.rus = [_rmod_19, _rmod_20, _rmod_21, _rmod_22]

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
    oam_ip=NetworkAddress("10.15.236.106"),
    instance_id=10721,
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
        _rmod_17,
        _rmod_18,
        _rmod_19,
        _rmod_20,
        _rmod_21,
        _rmod_22,
    ],
    master=_enb_sbts_1,
)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_sbts_1.system_module.common_units[0],
        interface_type="lmp",
    )
)
_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_sbts_2.system_module.common_units[0],
        interface_type="lmp",
    )
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_N_1706_6ABIO_22FXED",
)

__all__ = ["tl"]
