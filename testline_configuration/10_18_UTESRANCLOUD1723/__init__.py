# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Marius Irimia"
__email__ = "marius.irimia@nokia.com"

from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes, FujitsuRadioTypes
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
    SshServiceDetails(addr="10.5.20.21", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.20.22", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.255.1.6", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2 = Gude("10.255.1.7", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_3 = Gude("10.255.1.4", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_4 = Gude("10.255.1.8", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")

_pdu_4.pdu_ports[8].contactor = "NORMALLY_OPEN"
_pdu_3.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"



_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIL",
    hardware_version="474020B.101",
    serial_number="EA201056243",
)
_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1224207740",
)
_fsp_3 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1171013102",
)
_fsp_4 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1234902936",
)
_fsp_5 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1170303291",
)
_fsp_6 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1241407094",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[12],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233302572",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH200762729",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="K9190717891",
    pdu_port=_pdu_2.pdu_ports[8],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="K9190800018",
    pdu_port=_pdu_2.pdu_ports[7],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQL.value,
    serial_number="L1233006672",
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2050G1TM0",
    pdu_port=_pdu_3.pdu_ports[9],
)
_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHHB.value,
    serial_number="EA184679145",
    pdu_port=_pdu_3.pdu_ports[6],
)
_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQC.value,
    serial_number="1M241500381",
    pdu_port=_pdu_1.pdu_ports[9],
)
_rmod_7 = RU(
    ru_hw_group="",
    radio_type=FujitsuRadioTypes.OFEGSA.value,
    serial_number="00360",
    pdu_port=_pdu_4.pdu_ports[8],
)


_fsp_1.rus = [_rmod_2]
_fsp_2.rus = [_rmod_3, _rmod_4, _rmod_5]
_fsp_3.rus = [_rmod_1]
_fsp_4.rus = [_rmod_6]
_fsp_5.rus = [_rmod_1]
_fsp_6.rus = [_rmod_7]

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_6, _rmod_7],
    oam_ip=NetworkAddress("10.15.236.123"),
    instance_id=10723,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2, rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4,_rmod_5], master=_enb_sbts_1
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
    name="BSC_ASTRA_SBTS",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.27.142.199", username="SYSTEM", password="SYSTEM"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NLWG_1723_1ASIM_1ASIB_2ABIA_2ABIQ_1ABIO_1ABIL_2AHLOA_1AHFIB_1AHHB_1AHED_1AVQL_1AVQC",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
