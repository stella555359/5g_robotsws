__maintainer__ = "adelina.arsanu@nokia.com"
__owner__ = "adelina.arsanu@nokia.com"
__email__ = "adelina.arsanu@nokia.com"

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


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.236",
        username="ute",
        password="UTE.debian12",
        # addr VM 5G first
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.237",
        username="ute",
        password="UTE.debian12",
        # addr VM LTE
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude("10.255.5.186", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude("10.255.5.185", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"


_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVHA.value,
    serial_number="L1243210843",
    pdu_port=_pdu_1.pdu_ports[1],
)
_fct_1 = CoreUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_2.pdu_ports[8],
    hardware_type="ASOG",
    hardware_version="A.102",
    serial_number="L1243802134",
    test_pc=_test_pc_1,
    rus=[_rmod_1],
)
_fct_2 = CoreUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_2.pdu_ports[7],
    hardware_type="ASOE",
    hardware_version="A.103",
    serial_number="DH230410847",
    test_pc=_test_pc_2,
    rus=[_rmod_1],
)

_smod_1 = Airscale(core_units=[_fct_1])
_smod_2 = Airscale(core_units=[_fct_2])

_cu_nr = CU(
    backhaul_site_oam_ip="10.0.65.25",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.65.25", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.65.25", username="Nemuadmin", password="nemuuser"
    ),
)

_du_nr = DU(_smod_1)

_gnb_nr = ClassicalBts(
    cu=_cu_nr,
    dus=[_du_nr],
    instance_id=623025,
)
_enb_lte_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1],
    instance_id=621025,
)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_gnb_nr.dus[0].airscale.core_units[0],
        interface_type="lmp",
    )
)
_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_2.system_module.core_units[0],
        interface_type="lmp",
    )
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_gnb_nr],
    enbs=[_enb_lte_2],
)


RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": True,
    "USER_RTWP_CHECK": False,
    "USER_STOP_AND_FIX": False,
    "USER_SCF_VALIDATION_CHECK": False,
}


__all__ = ["tl"]
