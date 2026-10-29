# ---- README ----
# This configuration file was generated automatically
# Before using this configuration file, please read the following documnent as some variables must be changed before
# running any Robot Test
# Link :

__owner__ = "petronela.daraban@nokia.com"
__maintainer__ = "petronela.daraban@nokia.com"
__email__ = "petronela.daraban@nokia.com"

import os
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude, APC
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
from taf.config.testline.optical_switch import Calient
from taf.config.testline.dcap import DcapRnD, DcapBasic
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt
from taf.config.testline.fhs import FHS, FhsType

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.213", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.129")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.212", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.129")],
)

_pdu_1 = Gude(
    addr="10.255.5.38",
    port_numbers=[3, 5, 6, 7, 8, 10],
    model="EPC",
    version="8220-1",
)


_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHCA.value,
    serial_number="1M192827902",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.41.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIHA.value,
    serial_number="RW233403223",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.41.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIHA.value,
    serial_number="RW233403221",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.77.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOB.value,
    serial_number="AH243522045",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.41.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[10],
)
_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOB.value,
    serial_number="AH243522208",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.41.131", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)
_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1212210193",
    rus=[_rmod_1, _rmod_2, _rmod_4, _rmod_5],
)
_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA185173961",
    rus=[_rmod_2],
)
_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="RW190402309",
    rus=[_rmod_4],
)

_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1232001219",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_5],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="DH223747239",
    test_pc=_test_pc_1,
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="L1244004859",
    test_pc=_test_pc_2,
)


_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_enb_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_4, _rmod_5],
    instance_id=621005,
    oam_ip=NetworkAddress("10.0.71.5"),
)

_enb_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_5],
    instance_id=624005,
    oam_ip=NetworkAddress("10.0.65.5"),
)


_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_1.system_module.common_units[0],
        interface_type="lmp",
    )
)

_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_2.system_module.common_units[0],
        interface_type="lmp",

    )
)



tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_1, _enb_2],
)


RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": False,
    "USER_RTWP_CHECK": False,
    "USER_RSI_INFO_COLLECT": True,
    #    "USER_DCAP_TRACE_COLLECT": True,
    #    "USER_DCAP_TRACE_COLLECT_Master": True,
    #    "USER_DCAP_TRACE_COLLECT_Slave": True,
}
__all__ = ["tl"]
