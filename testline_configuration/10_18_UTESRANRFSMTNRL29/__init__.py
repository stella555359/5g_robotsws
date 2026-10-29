__maintainer__ = "razvan.rechesan@nokia.com"
__owner__ = "razvan.rechesan@nokia.com"
__email__ = "razvan.rechesan@nokia.com"

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
from taf.config.testline.airscale import CommonUnit, CapacityUnit, CoreUnit
from taf.config.testline.dcap import DcapRnD, DcapBasic
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.181", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.182", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.255.5.79", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude("10.255.5.78", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AWHHF.value,
    serial_number="EB2103R1134",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.41.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AWHHF.value,
    serial_number="EB2103R1116",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.41.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AWHHF.value,
    serial_number="EB2030R1840",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.41.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEHB.value,
    serial_number="L1202800988",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.16.42", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[11],
)
_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEHB.value,
    serial_number="L1202800987",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.16.46", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[12],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1233103418",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204104853",
    rus=[_rmod_4, _rmod_5],
)

_fct_1 = CoreUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASOH",
    hardware_version="A.101",
    serial_number="L1241601493",
    test_pc=_test_pc_1,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1234206584",
    test_pc=_test_pc_2,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
)

_smod_1 = Airscale([_fct_2])

_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.0.66.29"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.66.29", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.66.29", username="Nemuadmin", password="nemuuser"
    ),
)
_du_1 = DU(
    airscale=Airscale(core_units=[_fct_1]),
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
)

_gnb_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], instance_id=623029)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_gnb_1.dus[0].airscale.core_units[0],
        interface_type="lmp",
    )
)
_enb_2 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    instance_id=621029,
    oam_ip=NetworkAddress(v4="10.0.68.29"),
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
    enbs=[_enb_2],
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_gnb_1],
    tl_cloud_topology="None",
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_RTWP_CHECK": True,
    "USER_RTWP_CHECK": True,
}

__all__ = ["tl"]
