__maintainer__ = "Costanda Cristina"
__email__ = "cristina.costanda@nokia.com"

from taf.config.testline.airscale import Airscale
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import APC, FPFH
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.47.72", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = FPFH(
    addr="10.255.1.44",
    port_numbers=[1, 2, 3, 4, 5, 6],
)

_pdu_2 = APC(
    addr="10.255.1.45",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
)

_pdu_1.pdu_ports[1].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_OPENED"

_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1234800767"
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1234800773"
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_2.pdu_ports[2],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1251402090",
    test_pc=_test_pc_1,
)

_smod_1 = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQA.value,
    serial_number="L1251502474",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.14", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQA.value,
    serial_number="L1251502458",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.6", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPB.value,
    serial_number="DH251614032",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPJ.value,
    serial_number="K9232931978",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
    oam_ip=NetworkAddress("10.15.236.87"),
    instance_id=10687,
)

_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"))

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_N_10687_1ASIM_2ABIP_2AVQA_1AHPB_1AHPJ",

)

__all__ = ["tl"]
