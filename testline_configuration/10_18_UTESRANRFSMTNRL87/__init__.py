__maintainer__ = "florina.stefan@nokia.com"
__owner__ = "florina.stefan@nokia.com"
__email__ = "florina.stefan@nokia.com"

import os
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt
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
from taf.config.testline.dcap import DcapRnD
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.fhs import FHS, FhsType



# TestPc class defines details about VMs/PC UEs connected to eNB
# Data you need to provide: VM ip, username, pass(defined in Cloud Manager user profile settings), eth1 lmp ip
# You can create as many TestPc objects as you need (for VM1, VM2, PC UE). NetworkAddress for VM2 (192.168.255.130) and for PC (192.168.255.131)
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.230", username="ute", password="UTE.debian12"
        #SBTS2
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.231", username="ute", password="UTE.debian12"
        #SBTS1
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


# Gude class for PDU defining.
# Data you need to provide: PDU IP, port (12 by default), type (EPC, APC, etc)
# Then, for each port, specify it's contactor position: NORMALLY_OPEN or NORMALLY_CLOSED
# You can create as many Gude objects as you need (in case your SMODs/RMODs are connected to multiple PDUs)
_pdu_1 = Gude("10.255.7.3", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8221-1")
_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude("10.255.7.4", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8221-1")
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"


# RU class for RMOD defining.
# Data you need to provide: RMOD type (FHEB, FXDB, etc), serial number, IP address, PDU port where it is connected
# You can create as many RU objects as you need (in case of multiple RMODs)
_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2027G1AP1",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="10.255.7.4", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIG.value,
    serial_number="BL2247W2NYZ",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="10.255.7.4", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)


# CapacityUnit class for extension hardware. Defining this object is optional.
# Data you need to provide: hardware type, version, serial number; optional: IP address and PDU port
# You can create as many CapacityUnit objects as you need (in case of multiple FBBC, ABIL, etc)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223402765",
    rus=[_rmod_1, _rmod_2],
)
_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1240104934",
    rus=[_rmod_1],
)
_dcap_1 = DcapRnD(
    HttpConnectionDetails(
        addr="10.5.21.230", port="9443", username=None, password=None
    )
)


# CommonUnit class for SMOD defining.
# Data you need to provide: hardware IP address, username, pass, capacity unit object(if defined), PDU port where it is connected
# serial number and TestPc object which contains data about assigned VM
# You can create as many CommonUnit objects as you need (in case of multiple SMODs)
# Capacity units is mandatory attribute. If not equipped, it should be set with empty list, i.e capacity_units


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1240903605",
    test_pc=_test_pc_2,
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1240903530",
    test_pc=_test_pc_1,
)


_smod_1 = Airscale([_fct_1, _fct_2])


_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2],
    instance_id=623087,
    dcap=_dcap_1
)


_test_pc_2.connections.append(Connection(interface="eth1", device=_enb_lte_1.system_module.common_units[0], interface_type="lmp"))

_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_lte_1.system_module.common_units[1], interface_type="lmp"))


DCAP_PROFILES_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL87/dcap_profiles.yaml"

tl = TestLine(
    test_pc=_test_pc_2,
    test_pcs=[_test_pc_2, _test_pc_1],
    enbs=[_enb_lte_1],
    tl_cloud_topology="CLOUD_HRAN_RFS_AILR_B1-3_B5-6_AILR_B1_B4_MTNRL87_3xAEHC_3xFHEB_3xAZHL_2xFXEF",
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_RTWP_CHECK": False,
    "USER_STOP_AND_FIX": False,
    "USER_DCAP_TRACE_COLLECT": False,
    "USER_DCAP_TRACE_COLLECT_Master": False
}


##### ADDITIONAL VARIABLES  #####
# Path to ues.yaml configuration file. Useful for ute_ue automated voice call/data transfer tests
#UTE_UE_CONFIG = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL45/ues.yaml"

__all__ = ["tl"]