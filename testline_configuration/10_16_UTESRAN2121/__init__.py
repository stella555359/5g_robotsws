# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Artur Lebek"
__email__ = "artur.lebek@nokia.com"


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
from taf.config.testline.testpc import TestPc


from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.82.43", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.42.199.221", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")

_fsp_1 = CapacityUnit(
    addr="192.168.253.18",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="AS173030539",
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.19",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="AS173030598",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="FSMF",
    hardware_version="A.105",
    serial_number="AS174916898",
)

_smod_1 = Flexi([_fct_1])


_rmod_1 = RU(
    ru_hw_group="FRMr2.1_3T6R",
    radio_type=RadioTypes.FRGS,
    serial_number="L6141003822",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)
_rmod_2 = RU(
    ru_hw_group="FRMr2.1_3T6R",
    radio_type=RadioTypes.FRGS,
    serial_number="L6141003826",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_3 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FXDA,
    serial_number="F7143812629",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
)
_rmod_4 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FXDA,
    serial_number="F7143812628",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)
_rmod_5 = RU(
    ru_hw_group="FRMr4.3a_2T2R_Halo",
    radio_type=RadioTypes.FHKA,
    serial_number="EA172750076",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_6 = RU(
    ru_hw_group="FRMr4.3a_2T2R_Halo",
    radio_type=RadioTypes.FHKA,
    serial_number="EA172750128",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)
_rmod_7 = RU(
    ru_hw_group="FRMr4.3a_2T2R_Halo",
    radio_type=RadioTypes.FHKA,
    serial_number="EA172750104",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[8],
)

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7],
    oam_ip=NetworkAddress("10.42.146.41"),
    instance_id=101041,
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_L_1FSMF_2FBBC_2FRGS_2FXDA_3FHKA",
)

__all__ = ["tl"]
