# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Marcelina Plawiak"
__email__ = "marcelina.plawiak@nokia.com"

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
    SshServiceDetails(addr="10.42.250.136", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude("10.42.199.187", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")
_pdu_2 = Gude("10.42.199.185", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")


_fsp_1 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173824834",
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171401718",
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="L1171209419",
)

_smod_1 = Flexi([_fct_1])


_rmod_1 = RU(
    ru_hw_group="FRMr2.2_3T6R_Medusa",
    radio_type=RadioTypes.FXEA,
    serial_number="	1M143944150",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_2 = RU(
    ru_hw_group="FRMr2.2_3T6R_Medusa",
    radio_type=RadioTypes.FXEA,
    serial_number="1M143923387",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)
_rmod_3 = RU(
    ru_hw_group="FRMr3.1_6T6R",
    radio_type=RadioTypes.FRHF,
    serial_number="F7182716513",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_4 = RU(
    ru_hw_group="FRMr2.1_3T6R",
    radio_type=RadioTypes.FRMA,
    serial_number="K9124916942",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[12],
)
_rmod_5 = RU(
    ru_hw_group="FRMr2.1_3T6R",
    radio_type=RadioTypes.FRMA,
    serial_number="K9172901321",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[11],
)


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    oam_ip=NetworkAddress("10.42.146.8"),
    instance_id=101008,
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_L_1ASIA_2ABIA_2FXEA_1FRHF_2FRMA",
)

__all__ = ["tl"]
