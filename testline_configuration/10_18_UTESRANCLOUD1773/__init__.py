__maintainer__ = "Oana Badea"
__email__ = "oana.badea@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection


from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(addr="10.5.20.137", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    addr="10.255.3.96",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_2 = Gude(
    addr="10.255.3.97",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"


_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1222104503",
)


_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233302552",
)

_smod_1 = Airscale([_fct_1])


_rmod_1 = RU(
    ru_hw_group="FRMr2.3_32T32R_Vegas",
    radio_type=RadioTypes.AEQN.value,
    serial_number="CV193500488",
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="FRMr2.3_32T32R_Vegas",
    radio_type=RadioTypes.AEQN.value,
    serial_number="CV193400197",
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_3 = RU(
    ru_hw_group="FRMr2.3_32T32R_Vegas",
    radio_type=RadioTypes.AEQN.value,
    serial_number="CV193700152",
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_4 = RU(
    ru_hw_group="FRMr2.3_32T32R_Vegas",
    radio_type=RadioTypes.AEQN.value,
    serial_number="CV202800259",
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_5 = RU(
    ru_hw_group="FRMr2.3_32T32R_Vegas",
    radio_type=RadioTypes.AEQN.value,
    serial_number="CV192901861",
    pdu_port=_pdu_2.pdu_ports[5],
)

_rmod_6 = RU(
    ru_hw_group="FRMr2.3_32T32R_Vegas",
    radio_type=RadioTypes.AEQN.value,
    serial_number="CV194100606",
    pdu_port=_pdu_2.pdu_ports[6],
)

_fsp_1.rus = ([_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6])

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
    oam_ip=NetworkAddress("10.15.236.173"),
    instance_id=10773,
)

_test_pc.connections.append(Connection(interface="eth1", device=_enb_sbts.system_module.common_units[0], interface_type="lmp"))

_rnc = RNC(
    rnc_id=252,
    oms_ip=NetworkAddress("10.92.249.149"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.91.190.126", username="Nemuadmin", password="Nokia@123"
    ),
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_SRAN_N_1773_1ASIM_1ABIO_6AEQN",
    rncs=[_rnc],
)
__all__ = ["tl"]
