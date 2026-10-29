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

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.164.117", username="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.164.117", username="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(addr="10.42.168.160", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8], model="ATEN")
_pdu_2 = Gude(addr="10.42.168.161", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8], model="ATEN")
_pdu_3 = Gude(addr="10.42.168.235", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8], model="ATEN")
_pdu_4 = Gude(addr="10.42.51.152", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8], model="ATEN")

_fsp_1 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="A.102",
    serial_number="L1163210275",
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIA",
    hardware_version="A.102",
    serial_number="L1163403136",
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIA",
    hardware_version="A.102",
    serial_number="L1163210280",
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.18",
    hardware_type="FBBC",
    hardware_version="A.101",
    serial_number="NK153830442",
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.19",
    hardware_type="FBBC",
    hardware_version="A.101",
    serial_number="NK154530227",
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_2.pdu_ports[8],
    hardware_type="ASIA",
    hardware_version="A.101",
    serial_number="L1162802608",
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_2.pdu_ports[1],
    hardware_type="FSMF",
    hardware_version="A.104",
    serial_number="F7152853991",
    capacity_units=[_fsp_4, _fsp_5],
)

_smod_1 = Flexi([_fct_1])

_smod_2 = Flexi([_fct_2])

_rmod_1 = RU(ru_hw_group="", serial_number="K9180154338", pdu_port=_pdu_1.pdu_ports[6])

_rmod_2 = RU(ru_hw_group="", serial_number="K9174311045", pdu_port=_pdu_1.pdu_ports[8])

_rmod_3 = RU(ru_hw_group="", serial_number="K9172836261", pdu_port=_pdu_3.pdu_ports[1])

_rmod_4 = RU(ru_hw_group="", serial_number="L1172801896", pdu_port=_pdu_3.pdu_ports[3])

_rmod_5 = RU(ru_hw_group="", serial_number="EA150660063", pdu_port=_pdu_4.pdu_ports[5])

_rmod_6 = RU(ru_hw_group="", serial_number="K9163317002", pdu_port=_pdu_4.pdu_ports[6])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)

tl = TestLine(
    test_pc=[_test_pc_1],
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_R4_REALRF_FV1",
)

__all__ = ["tl"]
