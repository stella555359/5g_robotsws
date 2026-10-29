__maintainer__ = "dorin.caluser@nokia.com"
__owner__ = "dorin.caluser@nokia.com"
__email__ = "dorin.caluser@nokia.com"
from taf.config.testline.lmi import SerialOverHost,SerialOverTcp,Local, Remote
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
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
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.lmi import SerialOverHost,SerialOverTcp,Local, Remote


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.33", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.34", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)



_pdu_1 = Gude("10.255.5.107", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude("10.255.5.108", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPMDB.value,
    serial_number="AS220890753",
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
    radio_type=RadioTypes.AHPMDB.value,
    serial_number="AS214812114",
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
    radio_type=RadioTypes.AHPMDB.value,
    serial_number="AS214812125",

    pdu_port=_pdu_1.pdu_ports[2],
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

_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGC.value,
    serial_number="EA231552536",
    pdu_port=_pdu_1.pdu_ports[12],
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGC.value,
    serial_number="EA231552539",
    pdu_port=_pdu_1.pdu_ports[6],
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
    #             port="COM11"
    #         )
    #     ]
    # )
)

_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGC.value,
    serial_number="EA231552537",
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
    #             port="COM13"
    #         )
    #     ]
    # )
)


_fsp_abia1 = CapacityUnit(
    addr="", 
    hardware_type="ABIA", 
    hardware_version="A.103", 
    serial_number="EA190976332",
    rus=[_rmod_4, _rmod_5, _rmod_6],
)
_fsp_abia2 = CapacityUnit(
    addr="", 
    hardware_type="ABIA", 
    hardware_version="A.102", 
    serial_number="L1164811201",
)
_fsp_abia3 = CapacityUnit(
    addr="", 
    hardware_type="ABIA", 
    hardware_version="A.102", 
    serial_number="L1170317783",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_fsp_abio = CapacityUnit(
    addr="", 
    hardware_type="ABIO", 
    hardware_version="A.101", 
    serial_number="L1204008410",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_abia1, _fsp_abia2, _fsp_abia3],
    pdu_port=_pdu_2.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH211464536",
    test_pc=_test_pc_1,
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_abio],
    pdu_port=_pdu_2.pdu_ports[4],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1205104651",
    test_pc=_test_pc_2,
)


_smod_1 = Airscale([_fct_1, _fct_2])

_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    instance_id=623061,
    oam_ip=NetworkAddress("10.0.65.61"),
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
        device=_enb_lte_1.system_module.common_units[1],
        interface_type="lmp",
    )
)


_bsc = BSC(
    name="BSC_PAAVAI",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.27.126.7", username="SYSTEM", password="SYSTEM"
    ),
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_lte_1],
    tl_cloud_topology="CLOUD_HRAN_RFS_AILR_B1-B4_MTNRL61_3AHPMDB_3AHEGC",
)

RFS_TL_FLAGS = { 
    "SYSLOG_CHECK": False,
    "fail_if_unexpected_alarms": True, 
    "fail_if_wrn_threshold": True, 
    "POWER_ON_FLAG": True, 
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