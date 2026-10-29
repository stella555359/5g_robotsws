__maintainer__ = ""
__owner_email__ = ""

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


_test_pc_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.62.39", username="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_slave = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.62.40", username="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu = Gude(
    addr="10.42.199.165",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)


_fsp_1 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="FBBC",
    hardware_version="A.102",
    serial_number="NK154530161",
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="FBBC",
    hardware_version="A.102",
    serial_number="NK154330810",
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu.pdu_ports[6],
    hardware_type="FSMF",
    hardware_version="A.104",
    serial_number="L1142123523",
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu.pdu_ports[7],
    hardware_type="FSMF",
    hardware_version="A.104",
    serial_number="EA144864631",
)


_smod_1 = Flexi([_fct_1])
_smod_2 = Flexi([_fct_2])

_rmod_1 = RU(
    ru_hw_group="FRMr3.3_3T6R",
    radio_type=RadioTypes.FRHA,
    serial_number="L1124008144",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.198", port=2323
    ),
    pdu_port=_pdu.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="FRMr3.3_3T6R",
    radio_type=RadioTypes.FRHA,
    serial_number="L1123900471",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.198", port=2323
    ),
    pdu_port=_pdu.pdu_ports[2],
)

_rmod_3 = RU(
    ru_hw_group="FRMr3.3_3T6R",
    radio_type=RadioTypes.FRHA,
    serial_number="F7141725340",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.198", port=2323
    ),
    pdu_port=_pdu.pdu_ports[3],
)

_rmod_4 = RU(
    ru_hw_group="FRMr3.3_3T6R",
    radio_type=RadioTypes.FRHA,
    serial_number="L6131313305",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.19enbs8", port=2323
    ),
    pdu_port=_pdu.pdu_ports[4],
)

_rmod_5 = RU(
    ru_hw_group="FRMr3.3_3T6R",
    radio_type=RadioTypes.FRHA,
    serial_number="L6131313289",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.198", port=2323
    ),
    pdu_port=_pdu.pdu_ports[5],
)


_enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_5])
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_3])

tl = TestLine(
    test_pc=[_test_pc_master],
    test_pcs=[_test_pc_master, _test_pc_slave],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_RFS_FC_LTE1829_1a2_2xFXEB_2xFRMA_FRHC_2",
)

__all__ = ["tl"]
