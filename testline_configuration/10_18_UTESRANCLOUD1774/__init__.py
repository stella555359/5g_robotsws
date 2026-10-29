# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Giorgia Toth"
__email__ = "giorgia.toth@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.136", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.255.3.96", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2 = Gude("10.255.3.98", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_3 = Gude("10.255.3.94", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")

_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"

_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"

_pdu_3.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[3].contactor = "NORMALLY_CLOSED"

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1210302491",
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214608328",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1234205016",
)

_smod_1 = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZQS.value,
    serial_number="4H210230015",
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQL.value,
    serial_number="L1233006671",
    pdu_port=_pdu_3.pdu_ports[1],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZQS.value,
    serial_number="4H210230016",
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQL.value,
    serial_number="L1232903130",
    pdu_port=_pdu_3.pdu_ports[2],
)
_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZQS.value,
    serial_number="1M212807185",
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQL.value,
    serial_number="L1232903131",
    pdu_port=_pdu_3.pdu_ports[3],
)

_fsp_1.rus = [_rmod_2, _rmod_4, _rmod_6]
_fsp_2.rus = [_rmod_1, _rmod_3, _rmod_5]

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
        _rmod_6,
    ],
    oam_ip=NetworkAddress("10.15.236.174"),
    instance_id=10774,
)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_sbts_1.system_module.common_units[0],
        interface_type="lmp",
    )
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_N_1774_ASIM_2ABIO_3AZQS_3AVQL",
)

__all__ = ["tl"]
