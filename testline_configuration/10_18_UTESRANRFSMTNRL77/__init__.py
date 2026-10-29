__maintainer__ = "user.name@nokia.com"
__owner__ = "user.name@nokia.com"
__email__ = "user.name@nokia.com"
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.lmi import SerialOverHost,SerialOverTcp,Local, Remote
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
from taf.config.testline.fhs import FHS, FhsType

# This VM is MASTER from automation point of view, but is named BTS1 in the feature configuration
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.36", username="ute", password="userpassword"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.38", username="ute", password="userpassword"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

# This VMs connected to the same Airscale(fullrack AMIA) is SLAVE from automation point of view, but is named BTS1 in the feature configuration
_test_pc_3 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.37", username="ute", password="userpassword"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

# _dcap_1 = DcapRnD( HttpConnectionDetails( addr="10.5.21.239", port="9443" ))


_pdu_1 = Gude("10.255.2.51", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")
_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"  # BTS1 left SM
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"  # BTS1 right SM
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"  # BTS2

_pdu_2 = Gude("10.255.2.50", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")
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


_pdu_3 = Gude("10.255.2.49", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")
_pdu_3.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[10].contactor = "NORMALLY_CLOSED"


_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPMDD.value,
    serial_number="6Q204500336",
    pdu_port=_pdu_2.pdu_ports[6],
    lmi=SerialOverHost(
        host=TestPc(
           default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.31",
                username="rfsharing",
                password="Nokia2022!@1"
            )
        ),
        uart_mapping=[  # windows
            Local(
                port="COM22"
            )
        ]
    )
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPMDD.value,
    serial_number="LR240512247",
    pdu_port=_pdu_2.pdu_ports[8],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPMDD.value,
    serial_number="LR240512256",
    pdu_port=_pdu_2.pdu_ports[9],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGF.value,
    serial_number="DH244422506",
    pdu_port=_pdu_2.pdu_ports[10],
    lmi=SerialOverHost(
        host=TestPc(
           default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.32",
                username="rfsharing",
                password="Nokia2022!@1"
            )
        ),
        uart_mapping=[  # windows
            Local(
                port="COM6"
            )
        ]
    )
)

_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGF.value,
    serial_number="DH244422514",
    pdu_port=_pdu_2.pdu_ports[11],
)

_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEGF.value,
    serial_number="DH244422511",
    pdu_port=_pdu_2.pdu_ports[12],
)
_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHHB.value,
    serial_number="LR250207193",
    pdu_port=_pdu_2.pdu_ports[1],
    lmi=SerialOverHost(
        host=TestPc(
           default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.32",
                username="rfsharing",
                password="Nokia2022!@1"
            )
        ),
        uart_mapping=[  # windows
            Local(
                port="COM4"
            )
        ]
    )
)

_rmod_8 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHHB.value,
    serial_number="LR250207246",
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_9 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHHB.value,
    serial_number="LR250207264",
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_10 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHSB.value,
    serial_number="RW234900052",
    pdu_port=_pdu_2.pdu_ports[4],
    lmi=SerialOverHost(
        host=TestPc(
           default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.32",
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
_rmod_11 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHSB.value,
    serial_number="LR243604499",
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_12 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHSB.value,
    serial_number="RW234900051",
    pdu_port=_pdu_2.pdu_ports[7],
)
_rmod_13 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AQQQA.value,
    serial_number="1M244307631",
    pdu_port=_pdu_3.pdu_ports[8],
    lmi=SerialOverHost(
        host=TestPc(
           default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.31",
                username="rfsharing",
                password="Nokia2022!@1"
            )
        ),
        uart_mapping=[  # windows
            Local(
                port="COM9"
            )
        ]
    )
)

_rmod_14 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AQQQA.value,
    serial_number="1M244307629",
    pdu_port=_pdu_3.pdu_ports[9],
)
_rmod_15 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AQQQA.value,
    serial_number="1M244307560",
    pdu_port=_pdu_3.pdu_ports[10],
)

_capacity_unit_1_BTS1 = CapacityUnit(
    addr=" ",
    hardware_type="ABIA",
    serial_number="L1173915576",
    rus=[],
)
_capacity_unit_2_BTS1 = CapacityUnit(
    addr=" ",
    hardware_type="ABIA",
    serial_number="L1172604849",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_capacity_unit_3_BTS1 = CapacityUnit(
    addr=" ",
    hardware_type="ABIA",
    serial_number="EA184778100",
    rus=[],
)
_capacity_unit_4_BTS2 = CapacityUnit(
    addr=" ",
    hardware_type="ABIO",
    serial_number="L1204008390",
    rus=[_rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9],
)
_capacity_unit_5_BTS2 = CapacityUnit(
    addr=" ",
    hardware_type="ABIO",
    serial_number="L1204104564",
    rus=[_rmod_10, _rmod_11, _rmod_12],
)                                     
_capacity_unit_6_BTS3 = CapacityUnit(
    addr=" ",
    hardware_type="ABIO",
    serial_number="L1211209599",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)
_capacity_unit_7_BTS3 = CapacityUnit(
    addr=" ",
    hardware_type="ABIO",
    serial_number="L1224009398",
    rus=[_rmod_13, _rmod_14, _rmod_15],
)
_capacity_unit_8_BTS3 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    serial_number="L1223402765",
    rus=[_rmod_10, _rmod_11, _rmod_12],
)                                     

_fct_BTS1left = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        _capacity_unit_1_BTS1,
        _capacity_unit_2_BTS1,
        _capacity_unit_3_BTS1,
    ],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1201902154",
    test_pc=_test_pc_1,
)
_fct_BTS1right = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_capacity_unit_4_BTS2, _capacity_unit_5_BTS2],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1201902173",
    test_pc=_test_pc_3,
)
_fct_BTS2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[
        _capacity_unit_6_BTS3,
        _capacity_unit_7_BTS3,
        _capacity_unit_8_BTS3,                      
    ],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1201106385",
    test_pc=_test_pc_2,
)

_smod_BTS1 = Airscale([_fct_BTS1left, _fct_BTS1right])
_smod_BTS2 = Airscale([_fct_BTS2])

_enb_sbts = RealEnb(
    system_module=_smod_BTS1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
        _rmod_6,
        _rmod_7,
        _rmod_8,
        _rmod_9,
        _rmod_10,
        _rmod_11,
        _rmod_12,         
    ],
    oam_ip=NetworkAddress("10.0.69.77"),
    instance_id=621077,
)

_du_1 = DU(_smod_BTS2, rus=[_rmod_13, _rmod_14, _rmod_15, _rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_10, _rmod_11, _rmod_12 ] )
_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.0.65.77"),  # 5G M-plane
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

# _gnbs_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], global_bts_id=623077, instance_id=623077, dcap=_dcap_1)

_gnbs_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], global_bts_id=623077, instance_id=623077)

_rnc = RNC(
    rnc_id=9,
    oms_ip="10.5.18.77",
    logging_ssh_connection_details=SshServiceDetails(
        addr="x.x.x.x", username="username", password="pass"
    ),
)
_bsc = BSC(
    name="BSC_PAVAI",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.5.17.77", username="username", password="pass"
    ),
    logging_ssh_connection_details=SshServiceDetails(
        addr="x.x.x.x", username="username", password="pass"
    ),
)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_sbts.system_module.common_units[0],
        interface_type="lmp",
    )
)
_test_pc_3.connections.append(
    Connection(
        interface="eth1",
        device=_enb_sbts.system_module.common_units[1],
        interface_type="lmp",
    )
)
_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_gnbs_1.dus[0].airscale.common_units[0],
        interface_type="lmp",
    )
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2, _test_pc_3],
    gnbs=[_gnbs_1],
    enbs=[_enb_sbts],
    bscs=[_bsc],
    rncs=[_rnc],
    tl_cloud_topology="CLOUD_HRAN_RFS_AILR_AIL_MTNRL77",
)

# RSI_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL77/rsi_config.yaml"

# CELL_TARGET_BW_PATH = (
#    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL77/cell_target_bw.yaml"
# )

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_RTWP_CHECK": False,
    "USER_DCAP_TRACE_COLLECT": False,
    "USER_DCAP_TRACE_COLLECT_Master": False,
    "USER_DCAP_TRACE_COLLECT_Slave": False,
    "USER_SCF_VALIDATION_CHECK": False,
    "USER_STOP_AND_FIX_BLOCK_TEST": True,
    "USER_RSI_INFO_COLLECT": True,
    "RF_DIAGNOSTIC_CARD_CUSTOM_YAML": "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL77/custom_rmod_setup.yaml"
}

# DCAP_PROFILES_CONFIG_PATH = ("/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL77/dcap_profiles.yaml")


__all__ = ["tl"]