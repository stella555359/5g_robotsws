__maintainer__ = ""
__owner_email__ = ""
__email__ = ""

from taf.config.testline.airscale import CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import APC
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.ran import BSC, RNC

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.184.3", username="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu = APC(
    addr="10.42.168.4",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu.pdu_ports[1],
    hardware_type="FSMF",
    hardware_version="A.104",
    serial_number="L1133811748",
)
_smod = Flexi([_fct_1])
_rmod_1 = RU(
    ru_hw_group="FRMr3.3_3T6R",
    radio_type=RadioTypes.FRHA,
    serial_number="L1110210645",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.198", port=2323
    ),
    pdu_port=_pdu.pdu_ports[2],
)
_rmod_2 = RU(
    ru_hw_group="FRMr3.3_3T6R",
    radio_type=RadioTypes.FRHA,
    serial_number="L1110210644",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.198", port=2323
    ),
    pdu_port=_pdu.pdu_ports[3],
)

_enb_sbts = RealEnb(system_module=_smod, rms=[_rmod_1, _rmod_2])

_bsc = BSC(
    name="BSC_Leopard",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.42.89.4", username="SYSTEM", password="SYSTEM"
    ),
)

tl = TestLine(
    test_pc=[_test_pc],
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_RF_F_H9_2xFRHA",
    bscs=[_bsc],
)
__all__ = ["tl"]
