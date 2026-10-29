__maintainer__ = "maria_-_cristina.drind@nokia.com"
__owner__ = "maria_-_cristina.drind@nokia.com"
__email__ = "maria_-_cristina.drind@nokia.com"
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
from taf.config.testline.lmi import SerialOverHost,SerialOverTcp,Local, Remote

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.249", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.130")],
)
_pdu_1 = Gude("10.255.5.117", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2 = Gude("10.255.5.118", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVHA.value,
    serial_number="L1245105085",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr=" ", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVHA.value,
    serial_number="L1243507213",
    pdu_port=_pdu_2.pdu_ports[9],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.171",
                username="rfsharing",
                password="Nokia2022!@1"
            )
        ),
        uart_mapping=[  # windows
            Local(
                port="COM19"
            )
        ]
    )
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVHA.value,
    serial_number="L1244506719",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr=" ", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[12],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.171",
                username="rfsharing",
                password="Nokia2022!@1"
            )
        ),
        uart_mapping=[  # windows
            Local(
                port="COM12"
            )
        ]
    )
)

_fsp_1 = CapacityUnit(
    addr="", hardware_type="ABIP", hardware_version="A.102", serial_number="L1234800798", rus=[_rmod_1, _rmod_2, _rmod_3]
)
_fsp_2 = CapacityUnit(
    addr="", hardware_type="ABIO", hardware_version="A.104", serial_number="L1213010415", rus=[_rmod_1, _rmod_2, _rmod_3]
)
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1234206606",
    test_pc=_test_pc_1,
)

_smod_1 = Airscale([_fct_1])

_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    instance_id=621070,
)

_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_lte_1.system_module.common_units[0], interface_type="lmp"))


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_lte_1],
    tl_cloud_topology="CLOUD_10_18_UTESRANRFSMTNRL70",
)
RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_RTWP_CHECK": False,
    "USER_MASTER_TECH": "SBTS",
    "RF_DIAGNOSTIC_CARD_CUSTOM_YAML": "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL70/MTNRL70_custom_rmod_setup.yaml",
    "RMOD_UDP_LOG_CONFIG_PATH": "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL70/MTNRL70_rmod_udp_log.yaml",
}

__all__ = ["tl"]
