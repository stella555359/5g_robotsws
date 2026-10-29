# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Denis Gruia"
__email__ = "denis.gruia@nokia.com"

from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
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
    SshServiceDetails(addr="10.5.20.37", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.20.38", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.255.1.9", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_2 = Gude("10.255.1.10", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_3 = Gude("10.255.1.7", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_4 = Gude("10.255.1.8", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")


_pdu_2.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[10].contactor = "NORMALLY_CLOSED"


_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173824673",
)
_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1213010343",
)
_fsp_3 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="AS172532336",
)

_fsp_4 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="AS172532284",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1192100888",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="FSMF",
    hardware_version="472181A",
    serial_number="NK163060801",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Flexi([_fct_2])

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXDB.value,
    serial_number="1M161966744",
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXDB.value,
    serial_number="1M161966737",
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRGY.value,
    serial_number="K9165119523",
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRGY.value,
    serial_number="K9165119527",
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPMDA.value,
    serial_number="K9203002674",
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHCA.value,
    serial_number="1M190429335",
    pdu_port=_pdu_2.pdu_ports[11],
)
_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AENB.value,
    serial_number="1M220107813",
    pdu_port=_pdu_4.pdu_ports[10],
)

_fsp_1.rus = [_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5]
_fsp_2.rus = [_rmod_6, _rmod_7]
_fsp_3.rus = [_rmod_7]
_fsp_4.rus = [_rmod_3]

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7],
    oam_ip=NetworkAddress("10.15.236.25"),
    instance_id=10625,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
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
    oms_ip=NetworkAddress("10.27.141.158"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.91.190.126", username="Nemuadmin", password="systeM123!"
    ),
)

_bsc = BSC(
    name="BSC_DHARANI",
    logging_telnet_connection_details=SshServiceDetails(addr="10.27.126.20", username="SYSTEM", password="SYSTEM"),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NLWG_1625_1ASIB_1ABIA_1ABIO_1FSMF_2FBBC_2FXDB_2FRGY_1AHPMDA_1AHCA_1AEHC",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
