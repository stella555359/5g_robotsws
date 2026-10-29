# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Marius Stanescu"
__email__ = "marius.stanescu@nokia.com"

from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.testpc import TestPc, Connection


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.153", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.20.154", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.255.1.15", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_2 = Gude("10.255.1.16", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")

_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"


_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171221138"
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173814730"
)

_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214206673"
)

_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.107",
    serial_number="DH240906517"
)

_fsp_5 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="DH201062277"
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4, _fsp_5],
    pdu_port=_pdu_2.pdu_ports[2],
    hardware_type="ASIB",
    serial_number="L1201902200",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_2.pdu_ports[1],
    hardware_type="ASIB",
    serial_number="L1201902195",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPMDG.value,
    serial_number="LR252809671",
    pdu_port=_pdu_1.pdu_ports[7],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPMDG.value,
    serial_number="LR252809673",
    pdu_port=_pdu_1.pdu_ports[6],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPMDG.value,
    serial_number="LR252809681",
    pdu_port=_pdu_1.pdu_ports[5],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQQ.value,
    serial_number="1M252503243",
    pdu_port=_pdu_1.pdu_ports[10],
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQQ.value,
    serial_number="1M252503245",
    pdu_port=_pdu_1.pdu_ports[12],
)

_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQQ.value,
    serial_number="1M252503244",
    pdu_port=_pdu_1.pdu_ports[11],
)

_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXED.value,
    serial_number="L1160409664",
    pdu_port=_pdu_1.pdu_ports[2],
)

_rmod_8 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGB.value,
    serial_number="K9184913960",
    pdu_port=_pdu_1.pdu_ports[4],
)

_fsp_1.rus = ([_rmod_1, _rmod_2, _rmod_3])
_fsp_2.rus = ([_rmod_7])
_fsp_3.rus = ([_rmod_1, _rmod_2, _rmod_3])
_fsp_4.rus = ([_rmod_4, _rmod_5, _rmod_6])
_fsp_5.rus = ([_rmod_8])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3,_rmod_4, _rmod_5, _rmod_6,_rmod_8],
    oam_ip=NetworkAddress("10.15.247.132"),
    instance_id=10432,
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3,_rmod_4, _rmod_5, _rmod_6,_rmod_7],
    master=_enb_sbts_1,
)

_enb_sbts_1.slave = _enb_sbts_2


_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"))
_test_pc_2.connections.append(Connection(interface="eth1", device=_enb_sbts_2.system_module.common_units[0], interface_type="lmp"))



tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NLWG_10432_2ASIB_2ABIA_2ABIO_1ABIL_3AHPMDG_3AVQQ_1FXED_1AHEGB",
)

__all__ = ["tl"]
