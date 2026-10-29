__maintainer__ = "ricardo.maia@nokia.com"
__owner__ = "ricardo.maia@nokia.com"
__email__ = "ricardo.maia@nokia.com"

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

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.171", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.172", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude("10.255.5.88", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude("10.255.5.89", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZNA.value,
    serial_number="EA203458801",
    pdu_port=_pdu_1.pdu_ports[3],
    # lmi=SerialOverHost(
    #     host=TestPc(
    #         default_ssh_connection_details=SshServiceDetails(
    #             addr="10.5.55.59",
    #             username="rfsharing",
    #             password="Nokia2022!@1"
    #         )
    #     ),
    #     uart_mapping=[  # windows
    #         Local(
    #             port="COM7"
    #         )
    #     ]
    # )
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZNA.value,
    serial_number="6Q190504531",
    pdu_port=_pdu_1.pdu_ports[4],
    # lmi=SerialOverHost(
    #     host=TestPc(
    #         default_ssh_connection_details=SshServiceDetails(
    #             addr="10.5.55.59",
    #             username="rfsharing",
    #             password="Nokia2022!@1"
    #         )
    #     ),
    #     uart_mapping=[  # windows
    #         Local(
    #             port="COM13"
    #         )
    #     ]
    # )
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZNA.value,
    serial_number="6Q191211551",
    pdu_port=_pdu_1.pdu_ports[5],
    # lmi=SerialOverHost(
    #     host=TestPc(
    #         default_ssh_connection_details=SshServiceDetails(
    #             addr="10.5.55.59",
    #             username="rfsharing",
    #             password="Nokia2022!@1"
    #         )
    #     ),
    #     uart_mapping=[  # windows
    #         Local(
    #             port="COM8"
    #         )
    #     ]
    # )
)


_fsp_abip = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="A.102",
    serial_number="L1233203463",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_fct_2 = CoreUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASOG",
    hardware_version="A.102",
    serial_number="L1243405086",
    test_pc=_test_pc_2,
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_abip],
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1234206576",
    test_pc=_test_pc_1,
)


_smod_2 = Airscale(core_units=[_fct_2])
_smod_1 = Airscale([_fct_1])

_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    instance_id=621046,
    oam_ip=NetworkAddress("10.0.69.46"),
)

_enb_lte_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    instance_id=622046,
    oam_ip=NetworkAddress("10.0.71.46"),
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
        interface="eth1",
        device=_enb_lte_2.system_module.core_units[0],
        interface_type="lmp",
    )
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_lte_1, _enb_lte_2],
    tl_cloud_topology="CLOUD_10_18_UTESRANRFSMTNRL46",
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "POWER_ON_FLAG": False,
    "USER_RTWP_CHECK": False,
    "USER_STOP_AND_FIX": False,
    "USER_STOP_AND_FIX_BLOCK_TEST": False,
    "USER_DCAP_TRACE_COLLECT": False,
    "USER_DCAP_TRACE_COLLECT_Master": False,
    "USER_DCAP_TRACE_COLLECT_Slave": False,
    "USER_RSI_INFO_COLLECT": True,
    "USER_SCF_VALIDATION_CHECK": False,
    "RF_DIAGNOSTIC_CARD_CUSTOM_YAML": "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL61/custom_rmod_setup.yaml",
    "NETACT_CHECK": False,
}
__all__ = ["tl"]