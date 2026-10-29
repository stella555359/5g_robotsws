# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Denis Gruia"
__email__ = "denis.gruia@nokia.com"

from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude, FPFH
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.connection_details import SshServiceDetails

from taf.config.testline.testpc import TestPc, Connection

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.47.38", username="ute", password="UTE.debian12"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.47.39", username="ute", password="UTE.debian12"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_2 = FPFH("10.255.3.108", [1, 2, 3, 4, 5, 6], login="admin", password="admin")
_pdu_3 = FPFH("10.255.3.109", [1, 2, 3, 4, 5, 6], login="admin", password="admin")
_pdu_4 = FPFH("10.255.3.110", [1, 2, 3, 4, 5, 6], login="admin", password="admin")

_pdu_4.pdu_ports[6].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[6].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[1].contactor = "NORMALLY_OPENED"

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.105",
    serial_number="DH230145189",
)

_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1224106718",
)

_fsp_3 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1162908835",
)
_fsp_4 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.105",
    serial_number="L1233704116",
)

_fsp_5 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1223509767",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_2.pdu_ports[1],
    hardware_type="ASIL",
    serial_number="L1224209064",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu_2.pdu_ports[1],
    hardware_type="ASIL",
    serial_number="DH220747204",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIG.value,
    serial_number="BL2247W2NQD",
    pdu_port=_pdu_4.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIG.value,
    serial_number="BL2247W2NR5",
    pdu_port=_pdu_3.pdu_ports[2],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIG.value,
    serial_number="BL2247W2NRS",
    pdu_port=_pdu_3.pdu_ports[1],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEHC.value,
    serial_number="L1212614403",
    pdu_port=_pdu_3.pdu_ports[6],
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEHC.value,
    serial_number="L1212614401",
    pdu_port=_pdu_4.pdu_ports[5],
)

_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEHC.value,
    serial_number="K9223200775",
    pdu_port=_pdu_4.pdu_ports[6],
)

_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOB.value,
    serial_number="AH243522415",
    pdu_port=_pdu_4.pdu_ports[2],
)

_rmod_8 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOB.value,
    serial_number="AH245000510",
    pdu_port=_pdu_4.pdu_ports[3],
)

_rmod_9 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOB.value,
    serial_number="AH245000464",
    pdu_port=_pdu_4.pdu_ports[4],
)

_fsp_1.rus = ([_rmod_7, _rmod_8, _rmod_9])
_fsp_2.rus = ([_rmod_1, _rmod_2, _rmod_3])
_fsp_3.rus = ([_rmod_1, _rmod_2, _rmod_3])
_fsp_4.rus = ([_rmod_4, _rmod_5, _rmod_6])
_fsp_5.rus = ([_rmod_4, _rmod_5, _rmod_6])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_3, _rmod_4, _rmod_5, _rmod_7, _rmod_8, _rmod_9],
    oam_ip=NetworkAddress("10.15.236.121"),
    instance_id=10721,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_4, _rmod_5, _rmod_6],
    master=_enb_sbts_1,
)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"))
_test_pc_2.connections.append(Connection(interface="eth1", device=_enb_sbts_2.system_module.common_units[0], interface_type="lmp"))


_bsc = BSC(
        name="BSC_R2D2_SBTS",
        logging_telnet_connection_details=SshServiceDetails(
        addr="10.42.4.132", username="TSRUSER", password="TSRUSER@123"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NLWG_1721_2ASIL_4ABIO_1ABIA_3AHLOA_3AHFIG_3AEHC",
    bscs=[_bsc],
)

__all__ = ["tl"]
