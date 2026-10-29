# ---- README ----
# This configuration file was generated automatically
# Before using this configuration file, please read the following documnent as some variables must be changed before
# running any Robot Test
# Link :

__owner__ = "albert.vienescu@nokia.com"
__maintainer__ = "albert.vienescu@nokia.com"
__email__ = "albert.vienescu@nokia.com"


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


_test_pc_master = TestPc(
    SshServiceDetails(addr="10.5.19.197", username="ute", password="uteUTE!"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_slave = TestPc(
    SshServiceDetails(addr="10.5.19.198", username="ute", password="uteUTE!"),
    connections=[NetworkAddress(v4="192.168.255.130")],
)
# .197 = 5G / .198 = 4G

_pdu_1 = Gude(
    "10.255.5.6", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8220-1"
)
_pdu_2 = Gude(
    "10.255.5.5", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8220-1"
)

_pdu_1.pdu_ports[2].contactor = "NORMALLY_OPENED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_OPENED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_OPENED"
# port2 = LTE / port3 = 5G / port 8 = RF1, port12 = RF2, port11 = RF3

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1211709914",
)
_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1211709908",
)
# SN 5G =L1211709914 / SN 4G = L1211709908/

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1204107428",
    test_pc=_test_pc_master,
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1212506051",
    test_pc=_test_pc_slave,
)
# _fct_1 = 5G / _fct_2 =4G

_rmod_1 = RU(
    ru_hw_group="ScRMTDr6.1_2T2R",
    radio_type=RadioTypes.AWHHH,
    serial_number="EB2213R0834",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
)
_rmod_2 = RU(
    ru_hw_group="ScRMTDr6.1_2T2R",
    radio_type=RadioTypes.AWHHH,
    serial_number="EB2213R0661",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[12],
)
_rmod_3 = RU(
    ru_hw_group="ScRMTDr6.1_2T2R",
    radio_type=RadioTypes.AWHHH,
    serial_number="EB2213R0666",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[11],
)
# IPs from 4G; , pdu_port=_pdu_x.pdu_ports[y] removed

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])
# _smod_1 = 5G / _smod_2 =4G


_enb_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    instance_id=621112,
)


_cu_1 = CU(
    backhaul_site_oam_ip="10.0.65.112",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.65.112", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.65.112", username="Nemuadmin", password="nemuuser"
    ),
)


_du_1 = DU(airscale=_smod_1, rus=[_rmod_1, _rmod_2, _rmod_3])


_gnb_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], instance_id=623112)

_test_pc_master.connections.append(
    Connection(
        interface="eth1",
        device=_gnb_1.dus[0].airscale.common_units[0],
        interface_type="lmp",
    )
)
_test_pc_slave.connections.append(
    Connection(
        interface="eth1",
        device=_enb_2.system_module.common_units[0],
        interface_type="lmp",
    )
)

tl = TestLine(
    test_pc=_test_pc_master,
    test_pcs=[_test_pc_master, _test_pc_slave],
    enbs=[_enb_2],
    gnbs=[_gnb_1],
    tl_cloud_topology="CLOUD_HRAN_RFS_AIL_B1_MTNRL112_2xAWHHH",
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_RTWP_CHECK": False,
    "USER_STOP_AND_FIX": True,
    "POWER_ON_FLAG": True,
}

__all__ = ["tl"]
