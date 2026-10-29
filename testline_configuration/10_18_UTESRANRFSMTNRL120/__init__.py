__maintainer__ = "dorin.caluser@nokia.com"
__owner__ = "dorin.caluser@nokia.com"
__email__ = "dorin.caluser@nokia.com"

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




# TestPc class defines details about VMs/PC UEs connected to eNB
# Data you need to provide: VM ip, username, pass(defined in Cloud Manager user profile settings), eth1 lmp ip
# You can create as many TestPc objects as you need (for VM1, VM2, PC UE). NetworkAddress for VM2 (192.168.255.130) and for PC (192.168.255.131)
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.239", username="ute", password="ute"
        #addr VM 5G first
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.240", username="ute", password="ute"
        #addr VM LTE
        
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


# DCAP class defines details about DCAP server used by test to collect logs; one ore more DCAP objects can be declared
# Data you need to provide: DCAP IP, username, pass, port(default=9443) for usage of local VM installed DCAP or 443 for external DCAP
_dcap_1 = DcapRnD(
    HttpConnectionDetails(
        addr="10.5.21.239", port="9443"
    )
)


_pdu_1 = Gude("10.255.5.3", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude("10.255.5.4", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"  #used for new ok module
#_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"   #used for old broken module
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"

_pdu_3 = Gude("10.255.5.2", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")
_pdu_3.pdu_ports[2].contactor = "NORMALLY_CLOSED"

_pdu_4_awhhd = FPFH("10.255.5.206", [1, 2, 3, 4, 5, 6], login="admin", password="admin", protocol="http")
_pdu_4_awhhd.pdu_ports[4].contactor = "NORMALLY_OPENED"

_pdu_psu = PSU(addr="10.255.5.158", port_numbers=[1])

_pdu_5 = Gude("10.255.5.6", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")
_pdu_5.pdu_ports[5].contactor = "NORMALLY_OPENED"
_pdu_5.pdu_ports[6].contactor = "NORMALLY_OPENED"   



_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEHC.value,
    serial_number="L1205002748",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.154", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[2],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.53.6",
                username="rfsharing",
                password="Nokia2022!@1"
            )
        ),
        uart_mapping=[
            Local(
                port="COM10"
            )
        ]
    )
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEHC.value,
    serial_number="K9214824399",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.158", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.53.6",
                username="rfsharing",
                password="Nokia2022!@1"
            )
        ),
        uart_mapping=[
            Local(
                port="COM9"
            )
        ]
    )
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEHC.value,
    serial_number="L1210303036",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.162", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.53.6",
                username="rfsharing",
                password="Nokia2022!@1"
            )
        ),
        uart_mapping=[
            Local(
                port="COM7"
            )
        ]
    )
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AWHHD.value,
    serial_number="EB2237R0331",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.131", port=2323
    ),
    pdu_port=_pdu_5.pdu_ports[5],
#    pdu_port=_pdu_4_awhhd.pdu_ports[4],
)
_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AWHHD.value,
    serial_number="EB2237R0323",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.132", port=2323
    ),
    pdu_port=_pdu_5.pdu_ports[6],
)
_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AWHHD.value,
    serial_number="EB2237R0335",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.133", port=2323
    ),
    # pdu_port=_pdu_2.pdu_ports[2],
    pdu_port=_pdu_2.pdu_ports[6],
)


_fct_1 = CoreUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[12],
    hardware_type="ASOG",
    hardware_version="A.101",
    serial_number="L1243710151",
    test_pc=_test_pc_1,
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)
_fct_2 = CoreUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASOE",
    hardware_version="A.103",
    serial_number="DH224020759",
    test_pc=_test_pc_2,
    rus=[_rmod_1, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)

_smod_1 = Airscale(core_units=[_fct_1])
_smod_2 = Airscale(core_units=[_fct_2])

#_enb_lte_1 = RealEnb(
#    system_module=_smod_1,
#    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
#    instance_id=621120,
#    dcap=_dcap_1,
#)

_cu_nr = CU(
    backhaul_site_oam_ip="10.0.65.120",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.65.120", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.65.120", username="Nemuadmin", password="nemuuser"
    ),
)

_du_nr = DU(_smod_1)
#_du_nr = DU(airscale=_smod_1, rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6])

_gnb_nr = ClassicalBts(
    cu=_cu_nr,
    dus=[_du_nr],
    instance_id=621120,
    dcap=_dcap_1)

_enb_lte_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    instance_id=623120,
    dcap=_dcap_1,
)


#_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_lte_1.system_module._units[0], interface_type="lmp"))
_test_pc_1.connections.append(Connection(interface="eth1", device=_gnb_nr.dus[0].airscale.core_units[0], interface_type="lmp"))
_test_pc_2.connections.append(Connection(interface="eth1", device=_enb_lte_2.system_module.core_units[0], interface_type="lmp"))

_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.5.56.28",
                               user="ftp_5g",
                               password="Aikon_123456",
                               bind_interface_ip="10.5.61.134")

_data_transfer_iperf_1 = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_1,
                                                 interval=1,
                                                 server_close_delay=50)

_data_transfer_iperf_2 = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_1,
                                                 interval=1,
                                                 server_close_delay=50)

_data_transfer_iperf_3 = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_1,
                                                 interval=1,
                                                 server_close_delay=50)

_data_transfer_iperf_4 = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_1,
                                                 interval=1,
                                                 server_close_delay=50)

_android1 = TafUeAndroid(serial_number='H0D9FI1LV0180600355',
                         ue_pc_address='10.5.53.233',
                         data_transfer=[_data_transfer_iperf_1],
                         ssh_connection_details=SshServiceDetails(addr='10.5.53.233',
                                                                  username='rfsharing',
                                                                  password='Nokia2022!@1'),
                         ue_pc_port='80',
                         capabilities=['NR_AEHC'])

_android2 = TafUeAndroid(serial_number='AQKSLVH040M93000131',
                        #serial_number='HZQN1876AAK82900477',
                         ue_pc_address='10.5.53.233',
                         data_transfer=[_data_transfer_iperf_2],
                         ssh_connection_details=SshServiceDetails(addr='10.5.53.233',
                                                                  username='rfsharing',
                                                                  password='Nokia2022!@1'),
                         ue_pc_port='80',
                         capabilities=['LTE_AEHC'])
                         
_android3 = TafUeAndroid(serial_number='AQKSLVH040M93000006',
                         ue_pc_address='10.5.53.233',
                         data_transfer=[_data_transfer_iperf_3],
                         ssh_connection_details=SshServiceDetails(addr='10.5.53.233',
                                                                  username='rfsharing',
                                                                  password='Nokia2022!@1'),
                         ue_pc_port='80',
                         capabilities=['LTE_AWHHD'])

_android4 = TafUeAndroid(serial_number='H0J9DE1CN01C2100350',
                         ue_pc_address='10.5.53.233',
                         data_transfer=[_data_transfer_iperf_4],
                         ssh_connection_details=SshServiceDetails(addr='10.5.53.233',
                                                                  username='rfsharing',
                                                                  password='Nokia2022!@1'),
                         ue_pc_port='80',
                         capabilities=['NR_AWHHD'])



tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_gnb_nr],
    enbs=[_enb_lte_2],
#    enbs=[_enb_lte_1, _enb_lte_2],
    tl_cloud_topology="CLOUD_HRAN_RFS_ASOG_ASOE_MTNRL120_3xAEHC_3XAWHHD",
    ues=[_android1, _android2, _android3, _android4],
)

DCAP_PROFILES_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL120/dcap_profiles.yaml"
#RSI_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL120/rsi_config.yaml"
CELL_TARGET_BW_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL120/cell_target_bw.yaml"

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "POWER_ON_FLAG": True,
    "USER_RTWP_CHECK": False,
    "USER_STOP_AND_FIX": False,
    "USER_STOP_AND_FIX_BLOCK_TEST": False,
    "USER_DCAP_TRACE_COLLECT": True,
    "USER_DCAP_TRACE_COLLECT_Master": True,
    "USER_DCAP_TRACE_COLLECT_Slave": True,
    "USER_RSI_INFO_COLLECT": True,
    "USER_SCF_VALIDATION_CHECK": False,
    "RF_DIAGNOSTIC_CARD_CUSTOM_YAML": "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL120/MTNRL120_custom_rmod_setup.yaml",
    "NETACT_CHECK": False,
    "SYSLOG_CHECK": False,
}


##### ADDITIONAL VARIABLES  #####
# Path to ues.yaml configuration file. Useful for ute_ue automated voice call/data transfer tests
#UTE_UE_CONFIG = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL45/ues.yaml"

__all__ = ["tl"]


