# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Marius Irimia"
__email__ = "marius.irimia@nokia.com"

from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.132", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.20.133", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.255.1.2", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2 = Gude("10.255.1.3", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_3 = Gude("10.255.1.4", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")

_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[12].contactor = "NORMALLY_CLOSED"


_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1241104106",
)

_fsp_3 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171907946",
)

_fsp_4 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1241104188",
)

_fsp_5 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="DH243724658",
)

_fsp_6 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233704774",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_3],
    pdu_port=_pdu_2.pdu_ports[1],
    hardware_type="ASIM",
    serial_number="L1241210692",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_2.pdu_ports[2],
    hardware_type="ASIM",
    serial_number="L1241210691",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOB.value,
    serial_number="AH243522025",
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOB.value,
    serial_number="AH243007650",
    pdu_port=_pdu_1.pdu_ports[1],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOB.value,
    serial_number="AH243522208",
    pdu_port=_pdu_1.pdu_ports[3],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFII.value,
    serial_number="K9244701821",
    pdu_port=_pdu_1.pdu_ports[4],
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFII.value,
    serial_number="K9244701861",
    pdu_port=_pdu_1.pdu_ports[7],
)

_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFII.value,
    serial_number="K9244701864",
    pdu_port=_pdu_1.pdu_ports[8],
)

_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZHL.value,
    serial_number="AH244105480",
    pdu_port=_pdu_3.pdu_ports[7],
)

_rmod_8 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZHL.value,
    serial_number="AH244105479",
    pdu_port=_pdu_3.pdu_ports[8],
)

_rmod_9 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AENB.value,
    serial_number="1M224820442",
    pdu_port=_pdu_3.pdu_ports[1],
)

_rmod_10 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHDB.value,
    serial_number="EA191172176",
    pdu_port=_pdu_3.pdu_ports[12],
)

_fsp_1.rus = [_rmod_1, _rmod_2, _rmod_3]
_fsp_3.rus = [_rmod_4, _rmod_5, _rmod_6]

_fsp_4.rus = [_rmod_7]
_fsp_5.rus = [_rmod_4, _rmod_5, _rmod_6]
_fsp_6.rus = [_rmod_9, _rmod_10]


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    oam_ip=NetworkAddress("10.15.247.28"),
    instance_id=10328,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9, _rmod_10],
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

_rnc = RNC(
    rnc_id=252,
    oms_ip=NetworkAddress("10.92.249.149"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.91.190.126", username="Nemuadmin", password="Nokia@123"
    ),
)

_bsc = BSC(
    name="BSC_ASTRA",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.27.142.199", username="SYSTEM", password="SYSTEM"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NLG_1328_2ASIL_4ABIO_1ABIP_1ABIA_2AZHL_3AHLOA_3AHFIB_1AHDB_1AENB",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]

