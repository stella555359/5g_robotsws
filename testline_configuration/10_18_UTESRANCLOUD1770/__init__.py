# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Cornelia Cozma"
__email__ = "cornelia.cozma@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.138", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.20.163", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude("10.255.3.94", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2 = Gude("10.255.3.93", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_3 = Gude("10.255.3.98", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")

_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[10].contactor = "NORMALLY_CLOSED"

_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_fsp_1 = CapacityUnit(
    addr="None",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1222208786",
)

_fsp_2 = CapacityUnit(
    addr="None",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="DH214641760",
)

_fsp_3 = CapacityUnit(
    addr="None",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1201005365",
)

_fsp_4 = CapacityUnit(
    addr="None",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1194507959",
)

_fsp_5 = CapacityUnit(
    addr="None",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1190809339",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1240802137",
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3,_fsp_4,_fsp_5],
    pdu_port=_pdu_3.pdu_ports[10],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1240802093",
)


_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type=RadioTypes.AEHC.value,
    serial_number="AH231800536",
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type=RadioTypes.AEHC.value,
    serial_number="AH232700009",
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_3 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type=RadioTypes.AEHC.value,
    serial_number="AH231800537",
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_4T4RR",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="K9183140940",
    pdu_port=_pdu_2.pdu_ports[7],
)
_rmod_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2151V0UUF",
    pdu_port=_pdu_2.pdu_ports[8],
)
_rmod_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL1915V000Z",
    pdu_port=_pdu_2.pdu_ports[9],
)
_rmod_7 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL1850G10SO",
    pdu_port=_pdu_2.pdu_ports[10],
)
_rmod_8 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2112G18J8",
    pdu_port=_pdu_2.pdu_ports[11],
)
_rmod_9 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2024G17DZ",
    pdu_port=_pdu_2.pdu_ports[12],
)

_fsp_1.rus = [_rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9]
_fsp_2.rus = [_rmod_1, _rmod_2, _rmod_3]


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3,_rmod_4,_rmod_5,_rmod_6,_rmod_7,_rmod_8,_rmod_9],
    oam_ip=NetworkAddress("10.15.236.170"),
    instance_id=10770,
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[],
    master=_enb_sbts_1
)

_enb_sbts_1.slave = _enb_sbts_2


_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"))
_test_pc_2.connections.append(Connection(interface="eth1", device=_enb_sbts_2.system_module.common_units[0], interface_type="lmp"))


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1,_test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_N_1770_1ASIL_2ABIO__3AEHC_3AHFIB_3AHLOA",
)

__all__ = ["tl"]
