# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "alina.potocean@nokia.com"
__owner__ = "alina.potocean@nokia.com"
__email__ = "alina.potocean@nokia.com"

from typing import Optional, List, Union
from enum import Enum
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


from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.dcap import DcapRnD, DcapBasic

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.179", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_dcap_n = DcapRnD(
    HttpConnectionDetails(
        addr="10.5.19.179", port="9443", username="dcapuser", password="dcapadmin!"
    )
)

_pdu_1 = Gude("10.255.5.88", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2 = Gude("10.255.5.89", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASOE",
    hardware_version="A.102",
    serial_number="EA213353858",
    test_pc=_test_pc_1,
)

_smod_1 = Airscale([_fct_1])


_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AREA,
    serial_number="EA212650486",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.131", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AREA,
    serial_number="EA192671148",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGA,
    serial_number="K9185204368",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHBCA,
    serial_number="BL1917M001D",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
    instance_id=623045,
    dcap=_dcap_n,
)

_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"))

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_HRAN_RFS_ASOE_MTNRL45_2xAREA_1xAHEGA_1xAHBCA",
)
##### ADDITIONAL VARIABLES  #####
# Path to ues.yaml configuration file. Useful for ute_ue automated voice call/data transfer tests
UTE_UE_CONFIG = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL45/ues.yaml"
DCAP_PROFILES_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL45/dcap_profiles.yaml"

# Path to logical_config.yaml configuration file. Useful for logical HW config changes automated tests
# TARGET_LOGICAL_CONFIG_PATH = ("/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL45/logical_config.yaml")


RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_DCAP_TRACE_COLLECT": True,
    "USER_DCAP_TRACE_COLLECT_Master": True,
}

__all__ = ["tl"]
