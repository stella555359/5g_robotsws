__maintainer__ = "Lorena Borobar"
__email__ = "lorena.borobar@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import SshServiceDetails, TelnetConnectionDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude
from taf.config.testline.pdu import FPFH
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(addr="10.5.20.137", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    addr="10.255.1.98",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_2 = Gude(
    addr="10.255.1.99",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_3 = Gude(
    addr="10.255.1.100",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_4 = FPFH(
    addr="10.255.1.181",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    protocol="http",
)

_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"

_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"

_pdu_3.pdu_ports[6].contactor = "NORMALLY_CLOSED"

_pdu_4.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[4].contactor = "NORMALLY_OPENED"
_pdu_4.pdu_ports[6].contactor = "NORMALLY_OPENED"


_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.107",
    serial_number="DH240102424",
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1242304439",
)

_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171213611",
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_3.pdu_ports[6],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1240608851",
)

_smod_1 = Airscale([_fct_1])


_rmod_1 = RU(
    ru_hw_group="FRMTDr5.1_1_4T4R",
    radio_type=RadioTypes.AZNA.value,
    serial_number="6Q182948780",
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_2 = RU(
    ru_hw_group="FRMTDr5.1_1_4T4R",
    radio_type=RadioTypes.AZNA.value,
    serial_number="6Q190823499",
    pdu_port=_pdu_2.pdu_ports[8],
)

_rmod_3 = RU(
    ru_hw_group="FRMTDr5.1_1_4T4R",
    radio_type=RadioTypes.AZNA.value,
    serial_number="6Q190823458",
    pdu_port=_pdu_2.pdu_ports[7],
)


_rmod_4 = RU(
    ru_hw_group="cMAAr6.2a_32T32R",
    radio_type=RadioTypes.AQQF.value,
    serial_number="NQ242397718",
    pdu_port=_pdu_4.pdu_ports[3],
)

_rmod_5 = RU(
    ru_hw_group="cMAAr6.2a_32T32R",
    radio_type=RadioTypes.AQQF.value,
    serial_number="NQ242397719",
    pdu_port=_pdu_4.pdu_ports[4],
)

_rmod_6 = RU(
    ru_hw_group="cMAAr6.2a_32T32R",
    radio_type=RadioTypes.AQQF.value,
    serial_number="K9253421996",
    pdu_port=_pdu_4.pdu_ports[6],
)

_rmod_7 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type=RadioTypes.ARDB.value,
    serial_number="AS213804375",
    pdu_port=_pdu_2.pdu_ports[10],
)

_rmod_8 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type=RadioTypes.ARGA.value,
    serial_number="K9221000347",
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_9 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type=RadioTypes.AREA.value,
    serial_number="EA201653423",
    pdu_port=_pdu_1.pdu_ports[3],
)


_fsp_1.rus = ([_rmod_1, _rmod_2, _rmod_3])

_fsp_2.rus = ([_rmod_4, _rmod_5, _rmod_6, _rmod_8, _rmod_9])

_fsp_3.rus = ([_rmod_7, _rmod_9])


_enb_sbts = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
        _rmod_6,
        _rmod_7,
        _rmod_8,
        _rmod_9,
    ],
    oam_ip=NetworkAddress("10.15.236.130"),
    instance_id=10730,
)

_bsc = BSC(
    name="BSC_ASTRA",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.27.51.234", username="VRFTSR", password="VRFTSR!@"
    ),
 )


_test_pc.connections.append(Connection(interface="eth1", device=_enb_sbts.system_module.common_units[0], interface_type="lmp"))


tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_SRAN_NLG_1730_1ASIM_1ABIO_1ABIP_1ABIA_3AZNA_3AQQF_1ARDB_1ARGA_1AREA",
    bscs=[_bsc]
)

__all__ = ["tl"]
