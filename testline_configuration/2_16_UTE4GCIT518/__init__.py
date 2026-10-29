__maintainer__ = "Maciej Spibida"
__owner_email__ = "I_MN_RAN_TRUNK_SG_WRO2@internal.nsn.com"
__email__ = "maciej.spibida@nokia.com"

from taf.config.testline.airscale import CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.164.118", username="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(addr="10.42.168.160", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8], model="ATEN")
_pdu_2 = Gude(addr="10.42.51.167", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8], model="ATEN")
_pdu_3 = Gude(addr="10.42.168.235", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8], model="ATEN")
_pdu_4 = Gude(addr="10.42.168.236", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8], model="ATEN")
_pdu_5 = Gude(addr="10.42.168.237", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8], model="ATEN")

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="A.102",
    serial_number="L1163403124",
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="A.102",
    serial_number="L1163403144",
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="A.102",
    serial_number="L1163319128",
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIA",
    hardware_version="A.101",
    serial_number="L1163104865",
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
)

_smod = Flexi([_fct_1])

_rmod_1 = RU(ru_hw_group="", serial_number="YP144606A21", pdu_port=_pdu_5.pdu_ports[5])

_rmod_2 = RU(ru_hw_group="", serial_number="13W358F20265", pdu_port=_pdu_5.pdu_ports[2])

_rmod_3 = RU(ru_hw_group="", serial_number="15W349Z50035", pdu_port=_pdu_2.pdu_ports[1])

_rmod_4 = RU(ru_hw_group="", serial_number="YP1631A0014", pdu_port=_pdu_5.pdu_ports[4])

_rmod_5 = RU(ru_hw_group="", serial_number="YP145203B93", pdu_port=_pdu_5.pdu_ports[6])

_rmod_6 = RU(ru_hw_group="", serial_number="YP1542014B7", pdu_port=_pdu_5.pdu_ports[1])

_rmod_7 = RU(ru_hw_group="", serial_number="13W343R60015", pdu_port=_pdu_5.pdu_ports[3])

_rmod_8 = RU(ru_hw_group="", serial_number="YP160300E84", pdu_port=_pdu_3.pdu_ports[2])

_rmod_9 = RU(ru_hw_group="", serial_number="16W323D90396", pdu_port=_pdu_2.pdu_ports[5])

_rmod_10 = RU(ru_hw_group="", serial_number="YP1715A0001", pdu_port=_pdu_4.pdu_ports[8])

_rmod_11 = RU(
    ru_hw_group="", serial_number="LBALLU-YD17240LA9N", pdu_port=_pdu_5.pdu_ports[7]
)

_rmod_12 = RU(
    ru_hw_group="", serial_number="LBALLU-YD152601CDY", pdu_port=_pdu_5.pdu_ports[8]
)

_enb_sbts = RealEnb(
    system_module=_smod,
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
        _rmod_10,
        _rmod_11,
        _rmod_12,
    ],
)

tl = TestLine(
    test_pc=[_test_pc],
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_R4_REALRF_FV2",
)

__all__ = ["tl"]
