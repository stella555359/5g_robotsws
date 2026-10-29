__maintainer__ = "Oana Badea"
__email__ = "oana.badea@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(addr="10.5.20.64", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    addr="10.255.3.96",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_2 = Gude(
    addr="10.255.3.98",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="475266A.104",
    serial_number="L1201005255",
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="475266A.104",
    serial_number="L1190101424",
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIK",
    hardware_version="474021A.102",
    serial_number="EA202553507",
)

_smod_1 = Airscale([_fct_1])


_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHBCC.value,
    serial_number="BL2138Y27XV",
    pdu_port=_pdu_1.pdu_ports[6],
)

_rmod_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHBCC.value,
    serial_number="BL2138Y27VZ",
    pdu_port=_pdu_1.pdu_ports[5],
)

_rmod_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHBCC.value,
    serial_number="BL2138Y27VX",
    pdu_port=_pdu_2.pdu_ports[12],
)


_rmod_7 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="AS200203981",
    pdu_port=_pdu_2.pdu_ports[7],
)

_rmod_8 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="AS200704318",
    pdu_port=_pdu_2.pdu_ports[8],
)

_rmod_9 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHCA.value,
    serial_number="1M194808592",
    pdu_port=_pdu_2.pdu_ports[9],
)

_fsp_1.rus = ([_rmod_7, _rmod_8, _rmod_9])

_fsp_2.rus = ([_rmod_4, _rmod_5, _rmod_6])



_enb_sbts = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_4,
        _rmod_5,
        _rmod_6,
		_rmod_7,
		_rmod_8,
		_rmod_9,
    ],
    oam_ip=NetworkAddress("10.15.236.176"),
    instance_id=10776,
)

_test_pc.connections.append(Connection(interface="eth1", device=_enb_sbts.system_module.common_units[0], interface_type="lmp"))


tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_SRAN_N_1776_1ASIK_2ABIL_3AHCA_3AHBCC",
)

__all__ = ["tl"]
