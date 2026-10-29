__maintainer__ = "Pirjol Mihai-Adrian"
__email__ = "mihai-adrian.pirjol@nokia.com"
__owner_email__ = "mihai-adrian.pirjol@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection


from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(addr="10.5.20.128", username="ute", password="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.20.173", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude(
    addr="10.255.1.19",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_2 = Gude(
    addr="10.255.1.20",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

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

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.104",
    serial_number="L1214403650",
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="K9173814765",
)

_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="A.102",
    serial_number="L1251302721",
)

_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="A.102",
    serial_number="L1251302723",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1242501079",
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIM",
    hardware_version="A.101",
    serial_number="L1224503554",
)


_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="K9182103359",
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2039G1M2X",
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="K9182044781",
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2042V0PMR",
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="K9175224477",
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="K9174641485",
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_7 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type=RadioTypes.AHEC.value,
    serial_number="L1203605099",
    pdu_port=_pdu_2.pdu_ports[9],
)
_rmod_8 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type=RadioTypes.AHEC.value,
    serial_number="L1203605091",
    pdu_port=_pdu_2.pdu_ports[10],
)
_rmod_9 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type=RadioTypes.AHEC.value,
    serial_number="L1203605090",
    pdu_port=_pdu_2.pdu_ports[11],
)

_fsp_1.rus = [_rmod_1, _rmod_2, _rmod_3]
_fsp_2.rus = [_rmod_4, _rmod_5, _rmod_6]
_fsp_3.rus = [_rmod_7, _rmod_8, _rmod_9]
_fsp_4.rus = [_rmod_4, _rmod_5, _rmod_6]


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    oam_ip=NetworkAddress("10.15.236.146"),
    instance_id=10476,
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_7, _rmod_8, _rmod_9, _rmod_4, _rmod_5, _rmod_6],
    master=_enb_sbts_1,
)
_enb_sbts_1.slave = _enb_sbts_2


_bsc = BSC(
    name="BSC_AVENSIS_SBTS",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.27.142.197", username="SYSTEM", password="SYSTEM"
    ),
)

_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"))
_test_pc_2.connections.append(Connection(interface="eth1", device=_enb_sbts_2.system_module.common_units[0], interface_type="lmp"))

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NLWG_1746_1ASIM_2ABIA_1ABIO_1FXED_1FRGU_2AHFIB",
    bscs=[_bsc],
)

__all__ = ["tl"]
