__owner__ = "daciana.peia@nokia.com"
__maintainer__ = "daciana.peia@nokia.com"
__email__ = "daciana.peia@nokia.com"

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
from taf.config.testline.bts2g import Bts2G
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
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


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.65", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.5.56.28",
                               user="ftp_5g",
                               expected_prompt='ftp',
                               password="Aikon_4321",
                               bind_interface_ip="10.5.61.132")

_data_transfer_iperf_1 = TafUeDataTransferProtocol(protocol_name='iperf',  
                                                   app_server=_app_server_1,
                                                   interval=1,
                                                   server_close_delay=50)  

_android1 = TafUeAndroid(serial_number='HZQN1876BAK92100738',
                        ue_pc_address='10.5.53.81',
                        data_transfer=[_data_transfer_iperf_1],
                        ssh_connection_details=SshServiceDetails(addr='10.5.53.81',
                                                                 username='rfsharing',
                                                                 password='Nokia2022!@1'),
                        ue_pc_port='80',
                        capabilities=['REAL_ANDROID_UE_LTE_B3'])

_android2 = TafUeAndroid(serial_number='RFCT30X9TRL',
                        ue_pc_address='10.5.53.81',
                        data_transfer=[_data_transfer_iperf_1],
                        ssh_connection_details=SshServiceDetails(addr='10.5.53.81',
                                                                 username='rfsharing',
                                                                 password='Nokia2022!@1'),
                        ue_pc_port='80',
                        capabilities=['REAL_ANDROID_UE_LTE_B1'])                       

_android3 = TafUeAndroid(serial_number='HZQN1876AAK82902625',
                        ue_pc_address='10.5.53.81',
                        data_transfer=[_data_transfer_iperf_1],
                        ssh_connection_details=SshServiceDetails(addr='10.5.53.81',
                                                                 username='rfsharing',
                                                                 password='Nokia2022!@1'),
                        ue_pc_port='80',
                        capabilities=['REAL_ANDROID_UE_NR_B3'])     

_data_transfer_iperf_2 = TafUeDataTransferProtocol(protocol_name='iperf',  
                                                   app_server=_app_server_1,
                                                   binary_path='C:/Iperf/',
                                                   interface_name='FHS',
                                                   interval=1,
                                                   server_close_delay=50,
                                                   version=2,
                                                   dt_from_uepc=True) 
_at4 = TafUeAt(com_port='25',
                serial_number='23757ba1',
                capabilities=['REAL_ANDROID_UE_NR_B1'],
                ue_pc_address='10.5.53.81',
                ue_pc_login='rfsharing',
                ue_pc_password='Nokia2022!@1',
                ue_pc_expected_prompt='rfsharing@ROTMSRANU50066',
                data_transfer=[_data_transfer_iperf_2],
                ue_pc_port='81',)
                
_dcap_n = DcapRnD(
    HttpConnectionDetails(
        addr="10.5.19.65", port="9443", username=None, password=None
    )
)

_pdu_1 = Gude("10.255.5.18", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2 = Gude("10.255.5.19", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")


_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"


_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIN",
    hardware_version="474824A.103",
    serial_number="L1214007356",
)
_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIN",
    hardware_version="474824A.102",
    serial_number="L1204906178",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1202204632",
    test_pc=_test_pc_1,
)

_smod_1 = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="FRMr2.3_3T6R",
    radio_type=RadioTypes.FXEB,
    serial_number="L6131617459",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group="FRMr2.3_3T6R",
    radio_type=RadioTypes.FXEB,
    serial_number="F7133502862",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_4 = RU(
    ru_hw_group="FRMr3.0_3T6R",
    radio_type=RadioTypes.ARGA,
    serial_number="AS211809249",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)


_enb_2 = RealEnb(
    system_module=_smod_1, 
    rms=[_rmod_1, _rmod_2, _rmod_4], 
    instance_id=623066,
    oam_ip=NetworkAddress(v4="10.0.65.66"),
    dcap=_dcap_n,
)

_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_2.system_module.common_units[0], interface_type="lmp"))

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_2],
    ues=[_android1, _android2, _android3, _at4],
    tl_cloud_topology="CLOUD_HRAN_RFS_AIL_B1_B2_MTNRL66_2FXEB_1ARGA",
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_RTWP_CHECK": False,
    "USER_DCAP_TRACE_COLLECT": False,
    "USER_DCAP_TRACE_COLLECT_Master": False,
}

UTE_UE_CONFIG='/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL66/ues.yaml'
DCAP_PROFILES_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL66/dcap_profiles.yaml"
ATTENUATOR_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL66/pa.yaml"

__all__ = ["tl"]
