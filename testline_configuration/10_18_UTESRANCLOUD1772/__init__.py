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
    default_ssh_connection_details=SshServiceDetails(addr="10.5.20.162", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    addr="10.255.3.93",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_2 = Gude(
    addr="10.255.3.94",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_3 = Gude(
    addr="10.255.3.98",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[6].contactor = "NORMALLY_CLOSED"


_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIN",
    hardware_version="474824A.102",
    serial_number="L1210204783",
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1204605736",
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1,_fsp_2],
    pdu_port=_pdu_2.pdu_ports[6],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1234200004",
)

_smod_1 = Airscale([_fct_1])


_rmod_1 = RU(
    ru_hw_group="FRMr6.2a_4T4R",
    radio_type=RadioTypes.AHEGHA.value,
    serial_number="YK223600009",
    pdu_port=_pdu_1.pdu_ports[4],
)

_rmod_2 = RU(
    ru_hw_group="FRMr6.2a_4T4R",
    radio_type=RadioTypes.AHEGHA.value,
    serial_number="YK223600023",
    pdu_port=_pdu_1.pdu_ports[5],
)

_rmod_3 = RU(
    ru_hw_group="FRMr6.2a_4T4R",
    radio_type=RadioTypes.AHEGHA.value,
    serial_number="YK230300080",
    pdu_port=_pdu_1.pdu_ports[6],
)

_rmod_4 = RU(
    ru_hw_group="ScRMTDr6.2_4T4R",
    radio_type=RadioTypes.AWHQN.value,
    serial_number="EB2240R0092",
    pdu_port=_pdu_3.pdu_ports[4],
)

_rmod_5 = RU(
    ru_hw_group="ScRMTDr6.2_4T4R",
    radio_type=RadioTypes.AWHQN.value,
    serial_number="EB2244R1872",
    pdu_port=_pdu_3.pdu_ports[5],
)

_rmod_6 = RU(
    ru_hw_group="ScRMTDr6.2_4T4R",
    radio_type=RadioTypes.AWHQN.value,
    serial_number="AH242307922",
    pdu_port=_pdu_3.pdu_ports[6],
)

_fsp_1.rus = ([_rmod_1, _rmod_2, _rmod_3])
_fsp_2.rus = ([_rmod_4, _rmod_5, _rmod_6])


_enb_sbts = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
        _rmod_6,
    ],
    oam_ip=NetworkAddress("10.15.236.172"),
    instance_id=10772,
)

_test_pc.connections.append(Connection(interface="eth1", device=_enb_sbts.system_module.common_units[0], interface_type="lmp"))


tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_SRAN_N_1772_1ASIM_1ABIN_1ABIO_3AHEGHA_3AWHQN",
)

__all__ = ["tl"]
