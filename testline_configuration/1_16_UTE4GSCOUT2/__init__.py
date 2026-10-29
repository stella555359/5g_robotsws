__maintainer__ = "Kamil Ostrzolek"
__owner_email__ = "kamil.ostrzolek@nokia.com"
__email__ = "kamil.ostrzolek@nokia.com"

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
from taf.config.testline.ran import BSC, RNC

__all__ = ["tl"]

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.164.142", username="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu = Gude(
    addr="10.42.168.188",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu.pdu_ports[9],
    hardware_type="FSMF",
    hardware_version="A.103",
    serial_number="F7151100824",
)

_smod = Flexi([_fct_1])

_rmod_1 = RU(
    ru_hw_group="FRMr3.3_3T6R",
    radio_type=RadioTypes.FRHA,
    serial_number="L9112101818",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.198", port=2323
    ),
    pdu_port=_pdu.pdu_ports[8],
)

_enb_sbts = RealEnb(system_module=_smod, rms=[_rmod_1])

tl = TestLine(
    test_pc=[_test_pc],
    test_pcs=[_test_pc],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_RF_F_1746_1a2_FRHA",
)
