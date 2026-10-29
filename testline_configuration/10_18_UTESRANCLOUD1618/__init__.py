__owner__ = "Delia Nacov"
__maintainer__ = "Delia Nacov"
__email__ = "delia.nacov@nokia.com"


from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import FPFH
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.47.21", username="ute", password="UTE.debian12"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.47.22", username="ute", password="UTE.debian12"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = FPFH(addr="10.255.3.113", port_numbers=[1, 2, 3, 4, 5, 6], protocol="http")
_pdu_2 = FPFH(addr="10.255.3.114", port_numbers=[1, 2, 3, 4, 5, 6], protocol="http")
_pdu_3 = FPFH(addr="10.255.3.111", port_numbers=[1, 2, 3, 4, 5, 6], protocol="http")
_pdu_4 = FPFH(addr="10.255.3.112", port_numbers=[1, 2, 3, 4, 5, 6], protocol="http")


_pdu_1.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_OPENED"

_pdu_2.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_OPENED"

_pdu_3.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[6].contactor = "NORMALLY_OPENED"

_pdu_4.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[6].contactor = "NORMALLY_OPENED"


_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1222104503",
)
_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1242304437",
)
_fsp_3 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1182904379",
)
_fsp_4 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1242304438",
)
_fsp_5 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1242304435",
)
_fsp_6 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1241408095",
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1242501045",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1234205004",
)


_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOB.value,
    serial_number="AH243706172",
    pdu_port=_pdu_4.pdu_ports[4],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOB.value,
    serial_number="AH243007651",
    pdu_port=_pdu_4.pdu_ports[5],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOB.value,
    serial_number="AH243007669",
    pdu_port=_pdu_4.pdu_ports[6],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFII.value,
    serial_number="K9244701942",
    pdu_port=_pdu_4.pdu_ports[1],
)
_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFII.value,
    serial_number="K9244701851",
    pdu_port=_pdu_4.pdu_ports[2],
)
_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFII.value,
    serial_number="K9244701938",
    pdu_port=_pdu_4.pdu_ports[3],
)
_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVHA.value,
    serial_number="L1244910560",
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_8 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVHA.value,
    serial_number="L1244904284",
    pdu_port=_pdu_1.pdu_ports[4],
)

_rmod_9 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVHA.value,
    serial_number="L1244904283",
    pdu_port=_pdu_1.pdu_ports[5],
)
_rmod_10 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQL.value,
    serial_number="L1233000599",
    pdu_port=_pdu_3.pdu_ports[1],
)
_rmod_11 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEHC.value,
    serial_number="L1213305032",
    pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_12 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRGU.value,
    serial_number="K9170910530",
    pdu_port=_pdu_2.pdu_ports[3],
)


_fsp_1.rus = [_rmod_1, _rmod_2, _rmod_3]
_fsp_2.rus = [_rmod_10]
_fsp_3.rus = [_rmod_4, _rmod_5, _rmod_6]
_fsp_4.rus = [_rmod_7, _rmod_8, _rmod_9]
_fsp_5.rus = [_rmod_4, _rmod_5, _rmod_6]
_fsp_6.rus = [_rmod_11, _rmod_12]


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1,_rmod_2,_rmod_3,_rmod_4,_rmod_5,_rmod_6,_rmod_10],
    oam_ip=NetworkAddress("10.15.236.18"),
    instance_id=10618,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_4,_rmod_5,_rmod_6,_rmod_7,_rmod_8,_rmod_9,_rmod_11,_rmod_12],
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


_bsc = BSC(
    name="BSC_TIMISOARA",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.5.42.36", username="SYSTEM", password="SYSTEM"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NLG_1618_2ASIM_1ABIA_1ABIO_3ABIP_1ABIQ_1FRGU_1AEHC_3AHFII_3AHLOB_3AVHA_1AVQL",
    bscs=[_bsc],
)

__all__ = ["tl"]
