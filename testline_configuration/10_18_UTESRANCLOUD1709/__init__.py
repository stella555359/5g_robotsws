# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Andreea Burtic"
__email__ = "andreea.burtic@nokia.com"

from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.connection_details import SshServiceDetails

from taf.config.testline.testpc import TestPc, Connection

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.53.21", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.53.22", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.255.1.116", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2 = Gude("10.255.1.117", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")

_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171213613",
)

_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1201005249",
)

_fsp_3 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173758872",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1,_fsp_3],
    pdu_port=_pdu_2.pdu_ports[1],
    hardware_type="ASIB",
    serial_number="DH204667833",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIB",
    serial_number="DH204667823",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRGU.value,
    serial_number="AS180236096",
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGB.value,
    serial_number="K9200617480",
    pdu_port=_pdu_1.pdu_ports[4],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGB.value,
    serial_number="K9184605583",
    pdu_port=_pdu_1.pdu_ports[5],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXDB.value,
    serial_number="K9173917795",
    pdu_port=_pdu_1.pdu_ports[6],
)

_fsp_1.rus = ([_rmod_1])
_fsp_2.rus = ([_rmod_2,_rmod_3])
_fsp_3.rus = ([_rmod_1,_rmod_4])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_4],
    oam_ip=NetworkAddress("10.15.236.109"),
    instance_id=10709,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_2, _rmod_3],
    master=_enb_sbts_1,
)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"))
_test_pc_2.connections.append(Connection(interface="eth1", device=_enb_sbts_2.system_module.common_units[0], interface_type="lmp"))

_rnc = RNC(
    rnc_id=252,
    oms_ip=NetworkAddress("10.92.249.149"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.91.190.121", username="Nemuadmin", password="Nokia@123"
    ),
)

_bsc = BSC(
    name="BSC_SARA_SBTS",
    logging_telnet_connection_details=SshServiceDetails(
        addr="10.92.14.108", username="SYSTEM", password="SYSTEM"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NLWG_1709_1ASIB_1ASIB_2ABIA_1ABIL_1FRGU_2AHEGB_1FXDB",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
