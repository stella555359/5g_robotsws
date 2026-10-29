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
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.20.173", username="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    addr="10.255.3.25",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_2 = Gude(
    addr="10.255.3.26",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_2.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"


_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214608322",
)

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214403637",
)


_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_2.pdu_ports[2],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH201860943",
)

_smod_1 = Airscale([_fct_1])


_rmod_1 = RU(
    ru_hw_group="FRMr2.3_32T32R_Vegas",
    radio_type=RadioTypes.AHPE.value,
    serial_number="4H193830032",
    pdu_port=_pdu_1.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="FRMr2.3_32T32R_Vegas",
    radio_type=RadioTypes.AHPE.value,
    serial_number="1M204604188",
    pdu_port=_pdu_1.pdu_ports[2],
)

_rmod_3 = RU(
    ru_hw_group="FRMr2.3_32T32R_Vegas",
    radio_type=RadioTypes.AHPE.value,
    serial_number="1M204604284",
    pdu_port=_pdu_1.pdu_ports[3],
)

_rmod_4 = RU(
    ru_hw_group="FRMr2.3_32T32R_Vegas",
    radio_type=RadioTypes.AHCA.value,
    serial_number="AS215109527",
    pdu_port=_pdu_1.pdu_ports[4],
)

_rmod_5 = RU(
    ru_hw_group="FRMr2.3_32T32R_Vegas",
    radio_type=RadioTypes.AHCA.value,
    serial_number="AS215109528",
    pdu_port=_pdu_1.pdu_ports[5],
)

_rmod_6 = RU(
    ru_hw_group="FRMr2.3_32T32R_Vegas",
    radio_type=RadioTypes.AHCA.value,
    serial_number="AS215109530",
    pdu_port=_pdu_1.pdu_ports[6],
)

_fsp_1.rus = [_rmod_1, _rmod_2, _rmod_3]
_fsp_2.rus = [_rmod_4, _rmod_5, _rmod_6]

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
    oam_ip=NetworkAddress("10.15.236.107"),
    instance_id=10707,
)

_test_pc.connections.append(
    Connection(
        interface="eth1",
        device=_enb_sbts.system_module.common_units[0],
        interface_type="lmp",
    )
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_SRAN_N_1707_1ASIB_2ABIO_3AHPE_3AHCA",
)
__all__ = ["tl"]
