# ---- README ----
# This configuration file was generated automatically
# Before using this configuration file, please read the following documnent as some variables must be changed before
# running any Robot Test
# Link :

__owner__ = "Cuca Beatrice"
__maintainer__ = "Cuca Beatrice"
__email__ = "beatrice.cuca@nokia.com"


from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit

from taf.config.testline.enb import RealEnb
from taf.config.testline.bts2g import Bts2G
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.21.100", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.53.6", username="rfsharing", password="Nokia2022!@1"),
    connections=[NetworkAddress(v4="192.168.255.130")],
)


_pdu_1 = Gude("10.255.2.72", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_2 = Gude("10.255.2.71", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")


_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"


_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173917410",
)
_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="RW190402310",
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1215007548",
    test_pc=_test_pc_1,
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.131", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_2.pdu_ports[7],
    hardware_type="ESMC",
    hardware_version="FSM",
    serial_number="4H170462697",
    test_pc=_test_pc_2,
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Flexi([_fct_2])


_rmod_1 = RU(
    ru_hw_group="FRMr2.3_3T6R",
    radio_type=RadioTypes.FXEB,
    serial_number="L6144308141",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.4", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
)
_rmod_2 = RU(
    ru_hw_group="FRMr2.3_3T6R",
    radio_type=RadioTypes.FXEB,
    serial_number="1M144161120",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.4", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[11],
)
_rmod_3 = RU(
    ru_hw_group="FRMr2.3_3T6R",
    radio_type=RadioTypes.FRGU,
    serial_number="K9170943080",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.4", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[9],
)
_rmod_4 = RU(
    ru_hw_group="FRMr2.3_3T6R",
    radio_type=RadioTypes.FRPA,
    serial_number="EA174212746",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.4", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[12],
)
_rmod_5 = RU(
    ru_hw_group="FRMr2.3_3T6R",
    radio_type=RadioTypes.AHPD,
    serial_number="6Q190435461",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.4", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
)

_enb_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    oam_ip=NetworkAddress("None"),
    instance_id=10640,
)


_bts2g_2 = Bts2G(system_module=_smod_2, rms=[_rmod_1, _rmod_2], bcf_id=1640)


_bsc = BSC(
    name="BSC_TIMISOARA",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.5.42.236", username="SYSTEM", password="SYSTEM"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_1],
    bts2g_objects=[_bts2g_2],
    tl_cloud_topology="CLOUD_HRAN_RFS_AIL_B1_B2_LGMTAS21_2FXEB_1FRGU_1FRPA_1AHPD",
    bscs=[_bsc],
)

__all__ = ["tl"]
