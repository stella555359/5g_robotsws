# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

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
    SshServiceDetails(addr="10.5.20.161", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.255.3.94", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2 = Gude("10.255.3.95", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")

_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"


_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"



_fsp_1 = CapacityUnit(
    addr="None",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1223007798",
)

_fsp_2 = CapacityUnit(
    addr="None",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1213010419",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1240406548",
)

_smod_1 = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type=RadioTypes.AQQL.value,
    serial_number="DH232011180",
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_2 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type=RadioTypes.AQQL.value,
    serial_number="L1221302541",
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_3 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type=RadioTypes.AQQL.value,
    serial_number="DH232011182",
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_4 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type=RadioTypes.AQQN.value,
    serial_number="DH233841304",
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_5 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type=RadioTypes.AQQN.value,
    serial_number="L1222202094",
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_6 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type=RadioTypes.AQQN.value,
    serial_number="L1221004009",
    pdu_port=_pdu_2.pdu_ports[5],
)



_fsp_1.rus = [_rmod_1, _rmod_2, _rmod_3]
_fsp_2.rus = [_rmod_4, _rmod_5, _rmod_6]

_enb_sbts = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3,_rmod_4, _rmod_5, _rmod_6],
    oam_ip=NetworkAddress("10.15.236.171"),
    instance_id=10771,
)

_test_pc.connections.append(Connection(interface="eth1", device=_enb_sbts.system_module.common_units[0], interface_type="lmp"))

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_SRAN_N_1771_1ASIB_2ABIO_3AQQL_3AQQN",
)

__all__ = ["tl"]
