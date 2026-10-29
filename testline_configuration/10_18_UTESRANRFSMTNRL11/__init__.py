__maintainer__ = "geraldina.isfan@nokia.com"
__owner__ = "geraldina.isfan@nokia.com"
__email__ = "geraldina.isfan@nokia.com"

import os
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude, FPFH, PSU
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit, CoreUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.dcap import DcapRnD, DcapBasic
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt
from taf.config.testline.lmi import SerialOverHost,SerialOverTcp,Local, Remote




# TestPc class defines details about VMs/PC UEs connected to eNB
# Data you need to provide: VM ip, username, pass(defined in Cloud Manager user profile settings), eth1 lmp ip
# You can create as many TestPc objects as you need (for VM1, VM2, PC UE). NetworkAddress for VM2 (192.168.255.130) and for PC (192.168.255.131)
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.92", username="ute", password="uteUTE!"
        #addr VM 5G first
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

# DCAP class defines details about DCAP server used by test to collect logs; one ore more DCAP objects can be declared
# Data you need to provide: DCAP IP, username, pass, port(default=9443) for usage of local VM installed DCAP or 443 for external DCAP
_dcap_1 = DcapRnD(
    HttpConnectionDetails(
        addr="10.5.21.239", port="9443"
    )
)


_pdu_1 = Gude("10.255.5.178", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2 = Gude("10.255.5.179", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPC.value,
    serial_number="RW252101227",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.6", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPC.value,
    serial_number="RW252101228",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.1.154", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPC.value,
    serial_number="RW252101182",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.1.154", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AREA.value,
    serial_number="K9221141022",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.1.154", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AREA.value,
    serial_number="EA191771542",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.1.154", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)

_fct_1 = CoreUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_2.pdu_ports[2],
    hardware_type="ASOE",
    hardware_version="A.102",
    serial_number="EA214652569",
    test_pc=_test_pc_1,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
)

_smod_1 = Airscale(core_units=[_fct_1])



_enb_SBTS = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    instance_id=622011,
#    dcap=_dcap_1,
)



_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_SBTS.system_module.core_units[0], interface_type="lmp"))


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_SBTS],
    tl_cloud_topology="CLOUD_HRAN_RFS_MTNRL11",

)

#DCAP_PROFILES_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL120/dcap_profiles.yaml"


RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "POWER_ON_FLAG": True,
    "USER_RTWP_CHECK": False,
    "USER_STOP_AND_FIX": True,
    "USER_STOP_AND_FIX_BLOCK_TEST": True,
    "USER_DCAP_TRACE_COLLECT": True,
    "USER_DCAP_TRACE_COLLECT_Master": True,
    "USER_DCAP_TRACE_COLLECT_Slave": True,
    "USER_RSI_INFO_COLLECT": True,
    "USER_SCF_VALIDATION_CHECK": False,
    "NETACT_CHECK": False,
}



__all__ = ["tl"]

