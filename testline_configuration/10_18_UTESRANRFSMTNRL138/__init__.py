__owner__ = "maria_-_cristina.drind@nokia.com"
__maintainer__ = "maria_-_cristina.drind@nokia.com"
__email__ = "maria_-_cristina.drind@nokia.com"

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
from taf.config.testline.pdu import Gude, FPFH
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
from taf.config.testline.optical_switch import Calient
from taf.config.testline.dcap import DcapRnD, DcapBasic
from taf.config.testline.lmi import SerialOverHost,SerialOverTcp,Local, Remote

_dcap_n = DcapRnD(
    HttpConnectionDetails(
        addr="10.5.52.15", port="9443", username=None, password=None
    )
)

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.52.15", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.52.16", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.5.56.28",
                               user="ftp_5g",
                               expected_prompt='ftp',
                               password="Aikon_123456",
                               bind_interface_ip="10.5.61.134")

_data_transfer_iperf_1 = TafUeDataTransferProtocol(protocol_name='iperf',  
                                                   app_server=_app_server_1,
                                                   interval=1,
                                                   server_close_delay=50)

_app_server_2 = TafUeAppServer(app_server_name="APP_2",
                               address="10.9.146.30",
                               user="iperf_user",
                               password="Treperf",
                               bind_interface_ip="10.9.146.30"
                               )

_data_transfer_iperf_2 = TafUeDataTransferProtocol(protocol_name='iperf',  
                                                   app_server=_app_server_2,
                                                   interval=1,
                                                   server_close_delay=50)
_android1 = TafUeAndroid(serial_number='H0D9FI1LV0230900650',
                        ue_pc_address='10.5.55.24',
                        data_transfer=[_data_transfer_iperf_1],
                        ssh_connection_details=SshServiceDetails(addr='10.5.55.24',
                                                                 username='rfsharing',
                                                                 password='Nokia2022!@1'),
                        ue_pc_port='80',
                        capabilities=['UE1_AHFII_5G_SA'])

_android2 = TafUeAndroid(serial_number='AQKSLVH040M93000071',
                        ue_pc_address='10.5.55.24',
                        data_transfer=[_data_transfer_iperf_1],
                        ssh_connection_details=SshServiceDetails(addr='10.5.55.24',
                                                                 username='rfsharing',
                                                                 password='Nokia2022!@1'),
                        ue_pc_port='80',
                        capabilities=['UE2_LTE_5G_NSA'])

_android3 = TafUeAndroid(serial_number='HZQN1876AAK82902560',
                        ue_pc_address='10.5.55.24',
                        data_transfer=[_data_transfer_iperf_1],
                        ssh_connection_details=SshServiceDetails(addr='10.5.55.24',
                                                                 username='rfsharing',
                                                                 password='Nokia2022!@1'),
                        ue_pc_port='80',
                        capabilities=['UE3_AHLOB_AEHC_5G_SA'])

_android4 = TafUeAndroid(serial_number='H2J9FI1CN03C2500312',
                        ue_pc_address='10.5.55.24',
                        data_transfer=[_data_transfer_iperf_1],
                        ssh_connection_details=SshServiceDetails(addr='10.5.55.24',
                                                                 username='rfsharing',
                                                                 password='Nokia2022!@1'),
                        ue_pc_port='80',
                        capabilities=['UE4_LTE_5G_NSA'])
_pdu_1 = Gude(
    "10.255.5.229",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_2 = Gude(
    "10.255.5.227",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_3 = FPFH("10.255.5.155", [1, 2, 3, 4, 5, 6], login="admin", password="admin", protocol="http")


_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
#_pdu_3.pdu_ports[1].contactor = "NORMALLY_CLOSED"
#_pdu_3.pdu_ports[2].contactor = "NORMALLY_CLOSED"
#_pdu_3.pdu_ports[3].contactor = "NORMALLY_CLOSED"
#_pdu_3.pdu_ports[4].contactor = "NORMALLY_CLOSED"
#_pdu_3.pdu_ports[5].contactor = "NORMALLY_CLOSED"
#_pdu_3.pdu_ports[6].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFII.value,
    serial_number="BL2214N400L",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_3.pdu_ports[4],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFII.value,
    serial_number="BL2222N4079",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_3.pdu_ports[5],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFII.value,
    serial_number="BL2214N400X",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_3.pdu_ports[6],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOB.value,
    serial_number="BL2244D50YX",
    pdu_port=_pdu_3.pdu_ports[1],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.24",
                username="rfsharing",
                password="Nokia2022!@1"
            )
        ),
        uart_mapping=[  # windows
            Local(
                port="COM21"
            )
        ]
    )
)
_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOB.value,
    serial_number="BL2233D5093",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_3.pdu_ports[2],
)
_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOB.value,
    serial_number="BL2233D5094",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_3.pdu_ports[3],
)
_rmod_7 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVHA.value,
    serial_number="L1243509223",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_8 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVHA.value,
    serial_number="L1251202370",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_9 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVHA.value,
    serial_number="L1251202371",
    pdu_port=_pdu_2.pdu_ports[6],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.24",
                username="rfsharing",
                password="Nokia2022!@1"
            )
        ),
        uart_mapping=[  # windows
            Local(
                port="COM25"
            )
        ]
    )
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="DH250611963",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233201703",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233203473",
    rus=[_rmod_7, _rmod_8, _rmod_9],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1233402444",
    test_pc=_test_pc_1,
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[ _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIM",
    hardware_version="A.104",
    serial_number="L1234206577",
    test_pc=_test_pc_2,
)

_smod_1 = Airscale(common_units=[_fct_1, _fct_2])

_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9],
    instance_id=621138,
    oam_ip=NetworkAddress(v4="10.0.65.138"),
    dcap=_dcap_n,
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

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_lte_1],
    ues=[_android1, _android2, _android3, _android4],
    tl_cloud_topology="CLOUD_HRAN_RFS_AILR_B1-3-4-5_MTNRL138_3xAEHC_3xAHLOB_3xAHFII",
)
RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_RTWP_CHECK": False,
    "USER_STOP_AND_FIX": True,
    "USER_DCAP_TRACE_COLLECT": False,
    "USER_DCAP_TRACE_COLLECT_Master": False,
    "USER_RSI_INFO_COLLECT": True,
    "RF_DIAGNOSTIC_CARD_CUSTOM_YAML": "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL138/MTNRL138_custom_rmod_setup.yaml",
    "RMOD_UDP_LOG_CONFIG_PATH": "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL138/MTNRL138_rmod_udp_log.yaml",
    
}
UTE_UE_CONFIG = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL138/ues.yaml"
DCAP_PROFILES_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL138/dcap_profiles.yaml"
RSI_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL138/rsi_config.yaml"
CELL_TARGET_BW_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL138/cell_target_bw.yaml"

__all__ = ["tl"]
