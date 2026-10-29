__maintainer__ = "raluca-elena.butcovan@nokia.com@nokia.com"
__owner__ = "vlad-darius.mindrutau@nokia.com@nokia.com"
__email__ = "vlad-darius.mindrutau@nokia.com@nokia.com"

import os
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
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

#This VMs connected to the same Airscale(fullrack AMIA) is MASTER from automation point of view, but is named BTS1 in the feature configuration
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.192", username="ute", password="userpassword"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.193", username="ute", password="userpassword"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
#This VM is MASTER from automation point of view, but is named BTS2 in the feature configuration
_test_pc_3 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.191", username="ute", password="userpassword"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

#_dcap_1 = DcapRnD( HttpConnectionDetails( addr="10.5.21.239", port="9443" ))


_pdu_1 = Gude("10.255.7.18", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED" #BTS1 left SM
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED" #BTS2
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED" #BTS1 right SM

_pdu_2 = Gude("10.255.7.17", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"


_pdu_3 = Gude("10.255.7.19", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_3.pdu_ports[7].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2027G1ATV",
    pdu_port=_pdu_2.pdu_ports[7],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="K9181741636",
    pdu_port=_pdu_2.pdu_ports[8],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="K9183920898",
    pdu_port=_pdu_2.pdu_ports[9],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIG.value,
    serial_number="BL2247W2NYW",
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIG.value,
    serial_number="BL2247W2NZD",
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIG.value,
    serial_number="BL2247W2NVS",
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEHC.value,
    serial_number="K9224913889",
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_8 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEHC.value,
    serial_number="L1210107218",
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_9 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEHC.value,
    serial_number="K9224913887",
    pdu_port=_pdu_3.pdu_ports[7],
)

_capacity_unit_1_BTS1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    serial_number="L1203201096",
    rus=[_rmod_1, _rmod_2],
)

_capacity_unit_2_BTS1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    serial_number="L1201204094",
    rus=[_rmod_3],
)

_capacity_unit_3_BTS1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    serial_number="EA212360759",
    rus=[_rmod_4],
)

_capacity_unit_4_BTS1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    serial_number="DH220744752",
    rus=[_rmod_7, _rmod_8, _rmod_9],
)

_capacity_unit_5_BTS1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    serial_number="L1201204089",
    rus=[_rmod_5],
)

_capacity_unit_6_BTS1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    serial_number="EA212360735",
    rus=[_rmod_6],
)

_capacity_unit_1_BTS2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="EA185173938",
    rus=[_rmod_4, _rmod_5],
)

_capacity_unit_2_BTS2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="L1181415980",
    rus=[_rmod_6],
)

_capacity_unit_3_BTS2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="K9173805508",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)


_fct_BTS1left = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[ _capacity_unit_1_BTS1, _capacity_unit_2_BTS1, _capacity_unit_3_BTS1],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="DH223747203",
    test_pc=_test_pc_1,
)
_fct_BTS1right = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[ _capacity_unit_4_BTS1, _capacity_unit_5_BTS1, _capacity_unit_6_BTS1],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="DH223747202",
    test_pc=_test_pc_2,
)
_fct_BTS2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[ _capacity_unit_1_BTS2, _capacity_unit_2_BTS2, _capacity_unit_3_BTS2],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIA",
    hardware_version="A.102",
    serial_number="L1174803788",
    test_pc=_test_pc_3,
)

_smod_BTS1 = Airscale([_fct_BTS1left, _fct_BTS1right])
_smod_BTS2 = Airscale([_fct_BTS2])

_enb_sbts = RealEnb( system_module=_smod_BTS2, rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6], oam_ip=NetworkAddress("10.0.71.137"), instance_id=622137,)

#_du_1 = DU(_smod_BTS2)
_du_1 = DU(airscale=Airscale([_fct_BTS1left, _fct_BTS1right]), rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9])
_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.0.65.137"),  # 5G M-plane
    oam_ssh_connection_details=SshServiceDetails(addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"),
    oam_http_connection_details=HttpConnectionDetails(addr="192.168.255.129", username="Nemuadmin", password="nemuuser"),
)


_gnbs_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], global_bts_id=623137, instance_id=623137)

_test_pc_1.connections.append(Connection(interface="eth1", device=_gnbs_1.dus[0].airscale.common_units[0], interface_type="lmp"))
_test_pc_2.connections.append(Connection(interface="eth1", device=_gnbs_1.dus[0].airscale.common_units[1], interface_type="lmp"))
_test_pc_3.connections.append(Connection(interface="eth1", device=_enb_sbts.system_module.common_units[0], interface_type="lmp"))




tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2, _test_pc_3],
    gnbs=[_gnbs_1],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_10_18_UTESRANRFSMTNRL137",
)

RSI_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL137/rsi_config.yaml"

CELL_TARGET_BW_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL137/cell_target_bw.yaml"
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_RTWP_CHECK": False,
    "USER_STOP_AND_FIX": False,
    "USER_DCAP_TRACE_COLLECT": False,
    "USER_DCAP_TRACE_COLLECT_Master": False,
    "USER_DCAP_TRACE_COLLECT_Slave": False,
    "USER_SCF_VALIDATION_CHECK": False,
}

#DCAP_PROFILES_CONFIG_PATH = ("/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL137/dcap_profiles.yaml")


__all__ = ["tl"]