__maintainer__ = "Anna Maciejewska"
__email__ = "anna.maciejewska@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.121.133", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude("10.44.167.97", [7, 8, 9, 10], "EPC", "")


_fsp_1 = CapacityUnit(
    addr="fd5f:4268:2387:a881:0040:43ff:fe80:0101",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1211302335",
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH211572364",
)


_smod_1 = Airscale([_fct_1])


_rmod_1 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FRGU,
    serial_number="AS174505178",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[8],
)
_rmod_2 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FRGU,
    serial_number="AS174414942",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.16.130", username="root", password="root"
    ),
    pdu_port=_pdu_1.pdu_ports[9],
)


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2],
    oam_ip=NetworkAddress("10.44.166.100"),
    instance_id=1108,
)


_rnc = RNC(
    rnc_id=38,
    oms_ip=NetworkAddress("10.44.44.219"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.42.91.74", username="nokiadmin", password="system"
    ),
)

_bsc = BSC(
    name="BSC_mcBSC32",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.42.4.132", username="SYSTEM", password="SYSTEM1"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
