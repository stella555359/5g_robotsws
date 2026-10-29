__maintainer__ = "toader.zapartan@nokia.com"
__owner__ = "toader.zapartan@nokia.com"
__email__ = "toader.zapartan@nokia.com"
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.bts2g import Bts2G
from taf.config.testline.nb import NB
from taf.config.testline.ran import RNC
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.36", username="ute", password="userpassword"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.29.130", username="rfsharing", password="Nokia2022!@1"
    ),
    connections=[NetworkAddress(v4="192.168.255.132")],
)


_pdu_1 = Gude("10.255.2.36", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")


_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude("10.255.2.37", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")


_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"


_fsp = CapacityUnit(
    addr="", hardware_type="FBBC", hardware_version="A.101", serial_number="NK160530949"
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp],
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="FSMF",
    hardware_version="A.105",
    serial_number="AS182206856",
    test_pc=_test_pc_1,
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.131", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="FSMF",
    hardware_version="102",
    serial_number="TY132821618",
    test_pc=_test_pc_2,
)

_smod_1 = Flexi([_fct_1])
_smod_2 = Flexi([_fct_2])


_rmod_1 = RU(
    ru_hw_group="FRMr2.3_3T3R",
    radio_type=RadioTypes.FXEB,
    serial_number="K9150516816",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.1", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_2 = RU(
    ru_hw_group="FRMr2.3_3T3R",
    radio_type=RadioTypes.FXEB,
    serial_number="F7154027451",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.254.4", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_3 = RU(
    ru_hw_group="FRMr2.3_3T3R",
    radio_type=RadioTypes.FRHB,
    serial_number="EA153160034",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.206", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[12],
)
_rmod_4 = RU(
    ru_hw_group="FRMr2.3_3T3R",
    radio_type=RadioTypes.FRHB,
    serial_number="EA153061909",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.207", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
)
_rmod_5 = RU(
    ru_hw_group="FRMr2.3_3T3R",
    radio_type=RadioTypes.FRHB,
    serial_number="EA153061928",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.208", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
)
_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    oam_ip=NetworkAddress("10.5.40.33"),
    instance_id=10033,
)


_bts2g_gsm_2 = Bts2G(
    bcf_id="1033",
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2],
    master=_enb_lte_1,
)


_bsc = BSC(
    name="BSC_BUICK",
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.5.8.132", username="SYSTEM", password="SYSTEM"
    ),
)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_1.system_module.common_units[0],
        interface_type="lmp",
    )
)

_test_pc_2.connections.append(
    Connection(
        interface="LMP",
        device=_bts2g_gsm_2.system_module.common_units[0],
        interface_type="lmp",
    )
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_lte_1],
    bts2g_objects=[_bts2g_gsm_2],
    tl_cloud_topology="CLOUD_HRAN_RFS_FC_LG07_2FXEB_3FRHB",
    bscs=[_bsc],
    rncs=[None],
)


UTE_UE_CONFIG = "/home/ute/testline_configuration/10_18_UTESRANRFSWLGMT7/ues.yaml"
UEM_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSWLGMT7/ues2.yaml"

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": False,
    "fail_if_wrn_threshold": True,
}

__all__ = ["tl"]
