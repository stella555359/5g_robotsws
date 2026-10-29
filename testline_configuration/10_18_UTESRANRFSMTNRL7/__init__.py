__maintainer__ = "nicoleta.popescu@nokia.com"
__owner__ = "radu.hirsovescu@nokia.com"
__email__ = "nicoleta.popescu@nokia.com"
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
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
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
import os
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.173", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.174", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_3 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.199", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_pdu_1 = Gude("10.255.5.37", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8220-1")
_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude("10.255.5.36", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8220-1")
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="K9181816196",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="K9190800015",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="K9190800014",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[11],
)

_fsp_1 = CapacityUnit(
    addr="", hardware_type="ABIL", hardware_version="474020B.102", serial_number="L1201204086", rus=[_rmod_1, _rmod_2],
)
_fsp_2 = CapacityUnit(
    addr="", hardware_type="ABIN", hardware_version="474824A.101", serial_number="L1204214788", rus=[_rmod_1],
)
_fsp_3 = CapacityUnit(
    addr="", hardware_type="ABIA", hardware_version="473096A.102", serial_number="Ll1163900494", rus=[_rmod_2],
)
_fsp_4 = CapacityUnit(
    addr="", hardware_type="ABIO", hardware_version="475266A.104", serial_number="L1221102630", rus=[_rmod_3],
)
_fsp_5 = CapacityUnit(
    addr="", hardware_type="ABIO", hardware_version="475266A.104", serial_number="L1221102631", rus=[_rmod_3],
)
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1,_fsp_4,_fsp_5],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIM",
    hardware_version="A.102",
    serial_number="L1230610642",
    test_pc=_test_pc_1,
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1210402793",
    test_pc=_test_pc_2,
)
_fct_3 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1202606189",
    test_pc=_test_pc_3,
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2,_fct_3])

_dcap_1 = DcapRnD(
    HttpConnectionDetails(
        addr="10.5.19.173", port="9443", username="dcapuser", password="dcapadmin!"
    )
)

_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.5.56.28",
                               expected_prompt="ftp",
                               user="ftp_5g",
                               password="Aikon_4321",
                               bind_interface_ip="10.5.61.132")

_data_transfer_iperf_1 = TafUeDataTransferProtocol(protocol_name='iperf',
                                                   app_server=_app_server_1,
                                                   binary_path='C:/Iperf/',
                                                   interface_name='Askey',
                                                   interval=1,
                                                   server_close_delay=50,
                                                   dt_from_uepc=True)

#_data_transfer_iperf_2 = TafUeDataTransferProtocol(protocol_name='iperf',
#                                                   app_server=_app_server_1,
#                                                   interval=1,
#                                                   server_close_delay=50)

_at1 = TafUeAt(com_port='15',
               serial_number='d62e5fc1',
               capabilities=['ASKEY_UE'],
               ue_pc_address='10.5.60.183',
               ue_pc_login='rfsharing',
               ue_pc_password='Nokia2022!@1',
               ue_pc_expected_prompt='rfsharing@ROTMCDSU15195',
               data_transfer=[_data_transfer_iperf_1],
               ue_pc_port='81')
               
#_android1 = TafUeAndroid(serial_number='H0D9FI1CN01B2301050',
#                         ue_pc_address='10.5.60.183',
#                         data_transfer=[_data_transfer_iperf_2],
#                         ssh_connection_details=SshServiceDetails(addr='10.5.60.166',
#                                                                  username='rfsharing',
#                                                                  password='Nokia2022!@1'),
#                         ue_pc_port='80',
#                         capabilities=['REAL_ANDROID_UE'])


_cu_smod = CU(backhaul_site_oam_ip=NetworkAddress(v4="10.0.65.7"),
         oam_ssh_connection_details=SshServiceDetails(addr="10.0.65.7", username='toor4nsn', password='oZPS0POrRieRtu'),
         oam_http_connection_details=HttpConnectionDetails(addr="10.0.65.7", username='Nemuadmin', password='nemuuser'))

_du_smod = DU(airscale=Airscale([_fct_1]), rus=[_rmod_1, _rmod_2, _rmod_3])

_gnb_nr_1 = ClassicalBts(cu=_cu_smod, dus=[_du_smod], instance_id=623007, dcap=_dcap_1)

_test_pc_1.connections.append(Connection(interface="eth1", device=_gnb_nr_1.dus[0].airscale.common_units[0], interface_type="lmp"))

_enb_lte_1 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2],
    instance_id=621007,
    oam_ip=NetworkAddress(v4="10.0.69.7"),
    dcap=_dcap_1,
)

_test_pc_2.connections.append(Connection(interface="eth1", device=_enb_lte_1.system_module.common_units[0], interface_type="lmp"))
_test_pc_3.connections.append(Connection(interface="eth1", device=_enb_lte_1.system_module.common_units[1], interface_type="lmp"))

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2, _test_pc_3],
    enbs=[_enb_lte_1],
    gnbs=[_gnb_nr_1],
    tl_cloud_topology="CLOUD_HRAN_RFS_AIL_B1-2_AILR_B1_B4-6_MTNRL7_3xAHLOA_1xFRIJ",
    #ues=[_android1, _at1]
    ues=[_at1]
)

DCAP_PROFILES_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL7/dcap_profiles.yaml"
)
RSI_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL7/rsi_config.yaml"

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_RTWP_CHECK":  False,
    "USER_DCAP_TRACE_COLLECT": False,
    "USER_DCAP_TRACE_COLLECT_Master": False,
    "USER_DCAP_TRACE_COLLECT_Slave": False, 
    "USER_RSI_INFO_COLLECT": True,
}

__all__ = ["tl"]