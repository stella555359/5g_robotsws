__maintainer__ = "raluca.cetin@nokia.com"
__owner__ = "raluca.cetin@nokia.com"
__email__ = "raluca.cetin@nokia.com"
import os
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
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.dcap import DcapRnD, DcapBasic
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt

_dcap_n = DcapRnD(
    HttpConnectionDetails(
        addr="10.5.19.126", port="9443", username="None", password="None"
    )
)
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.126", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.127", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_pdu_1 = Gude("10.255.5.74", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2 = Gude("10.255.5.75", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"
_pdu_3 = Gude("10.255.5.76", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_3.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZHA.value,
    serial_number="RW191507788",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
    attenuation_ports=[],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEQP.value,
    serial_number="1M201414010",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.6", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[12],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AEQP.value,
    serial_number="1M211915358",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.10", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
)
_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1224207723",
    rus=[_rmod_3, _rmod_4],
)
_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1213010366",
    rus=[_rmod_3, _rmod_4],
)
_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    serial_number="EA193774833",
    rus=[_rmod_1],
)
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_3.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1192302840",
    test_pc=_test_pc_2,
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4],
    pdu_port=_pdu_3.pdu_ports[5],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH212873441",
    test_pc=_test_pc_1,
)
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_cu_smod = CU(
    backhaul_site_oam_ip="10.0.65.52",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.65.52", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.65.52", username="Nemuadmin", password="nemuuser"
    ),
)
_du_smod = DU(airscale=Airscale([_fct_2]), rus=[_rmod_3, _rmod_4])

_gnb_nr_1 = ClassicalBts(
    cu=_cu_smod,
    dus=[_du_smod], 
    instance_id=623052,
    dcap=_dcap_n,
)

_test_pc_1.connections.append(Connection(interface="eth1", device=_gnb_nr_1.dus[0].airscale.common_units[0], interface_type="lmp"))

_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],
    instance_id=621052,
    oam_ip=NetworkAddress(v4="10.0.69.52"),
    dcap=_dcap_n,
)

_test_pc_2.connections.append(Connection(interface="eth1", device=_enb_lte_1.system_module.common_units[0], interface_type="lmp"))

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

_android1 = TafUeAndroid(serial_number='6a2c7f6d',
                         ue_pc_address='10.5.53.152',
                         data_transfer=[_data_transfer_iperf_1],
                         ssh_connection_details=SshServiceDetails(addr='10.5.53.152',
                                                                  username='rfs_5g',
                                                                  password='Nokia2022!@1'),
                         ue_pc_port='80',
                         capabilities=['REAL_ANDROID_UE_1'])

_android2 = TafUeAndroid(serial_number='H0J9DE1CN01C2100384',
                         ue_pc_address='10.5.53.152',
                         data_transfer=[_data_transfer_iperf_2],
                         ssh_connection_details=SshServiceDetails(addr='10.5.53.152',
                                                                  username='rfs_5g',
                                                                  password='Nokia2022!@1'),
                         ue_pc_port='80',
                         capabilities=['REAL_ANDROID_UE_2'])

tl = TestLine(
    test_pc=_test_pc_1,
    enbs=[_enb_lte_1],
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_gnb_nr_1],
    tl_cloud_topology="CLOUD_HRAN_RFS_AIL_B1_B2_MTNRL52_3AEQP_1AZHA",
    ues=[_android1, _android2],
)

UTE_UE_CONFIG = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL52/ues.yaml"

ATTENUATOR_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL52/pa.yaml"

DCAP_PROFILES_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL52/dcap_profiles.yaml"
RSI_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL52/rsi_config.yaml"

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_SCF_VALIDATION_CHECK": True,
    "USER_DCAP_TRACE_COLLECT": True,
    "USER_DCAP_TRACE_COLLECT_Master": True,
    "USER_DCAP_TRACE_COLLECT_Slave": True,
    "USER_RSI_INFO_COLLECT": True,
}

__all__ = ["tl"]
