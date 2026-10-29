__maintainer__ = "albert.vienescu@nokia.com"
__owner__ = "albert.vienescu@nokia.com"
__email__ = "albert.vienescu@nokia.com"

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
from taf.config.testline.nb import NB
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc

import os
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.232", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.233", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(addr="10.255.5.151", port_numbers=[7, 11], model="EPC", version="8221-1")
_pdu_2 = Gude(
    addr="10.255.5.152", port_numbers=[6, 8, 9, 11], model="EPC", version="8221-1"
)

_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AKNB.value,
    serial_number="1M223512391",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[8],
    attenuation_ports=[],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AKQJ.value,
    serial_number="1M230610899",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[9],
    attenuation_ports=[],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AKNB.value,
    serial_number="1M223512400",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[11],
    attenuation_ports=[],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.ARGA.value,
    serial_number="F7204203029",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[6],
    attenuation_ports=[],
)
_abio_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.104",
    serial_number="L1221102656",
    rus=[_rmod_4],
)
_abio_2 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.104",
    serial_number="L1221102629",
    rus=[_rmod_1, _rmod_2],
)
_abio_3 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.104",
    serial_number="L1221102628",
    rus=[_rmod_3],
)
_abio_4 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.104",
    serial_number="L1213010440",
    rus=[_rmod_4],
)
_abio_5 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.102",
    serial_number="L1204606239",
    rus=[_rmod_1, _rmod_2],
)
_abio_6 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.104",
    serial_number="L1221102627",
    rus=[_rmod_3],
)

_asil = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_4, _abio_5, _abio_6],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="DH223747193",
    test_pc=_test_pc_1,
)

_asib = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_1, _abio_2, _abio_3],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1201902159",
    test_pc=_test_pc_2,
)


_smod_1 = Airscale([_asil])
_smod_2 = Airscale([_asib])

_enb_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
    instance_id=622063,
    oam_ip=NetworkAddress(v4="10.0.67.63"),
)
_enb_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
    instance_id=621063,
    oam_ip=NetworkAddress(v4="10.0.65.63"),
)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_1.system_module.common_units[0],
        interface_type="lmp",
    )
)
_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_2.system_module.common_units[0],
        interface_type="lmp",
    )
)

_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.5.56.28",
                               user="ftp_5g",
                               expected_prompt='ftp',
                               password="Aikon_4321",
                               bind_interface_ip="10.5.61.134")

_data_transfer_iperf_1 = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_1,
                                                 interval=1,
                                                 server_close_delay=50)
                                                 
_data_transfer_iperf_2 = TafUeDataTransferProtocol(protocol_name='iperf',
                                                   app_server=_app_server_1,
                                                   binary_path='C:/Iperf/',
                                                   interface_name='Askey',
                                                   interval=1,
                                                   server_close_delay=50,
                                                   # version=2,
                                                   dt_from_uepc=True)

                     
_at1 = TafUeAt(com_port='3',
               capabilities=['Askey'],
               ue_pc_address='10.5.53.163',
               ue_pc_login='rfsharing',
               ue_pc_password='Nokia2022!@1',
               ue_pc_expected_prompt='rfsharing@ROTMSRANU50063',
               data_transfer=[_data_transfer_iperf_2],
               ue_pc_port='81')                         

_android2 = TafUeAndroid(serial_number='H0J9DE1LV0250900107',
                         ue_pc_address='10.5.53.163',
                         data_transfer=[_data_transfer_iperf_1],
                         ssh_connection_details=SshServiceDetails(addr='10.5.53.163',
                                                                  username='rfsharing',
                                                                  password='Nokia2022!@1'),
                         ue_pc_port='80',
                         capabilities=['NokiaXR20'])

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_1, _enb_2],
    ues=[_at1, _android2],
    tl_cloud_topology="CLOUD_HRAN_RFS_AILR_B1_B2_B3_B4_B5_B6_MTNRL63_2AKNB_1AKQJ_1ARGA" 
)    
RSI_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANMTNRL23/rsi_config.yaml"

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": True,
    "USER_RTWP_CHECK": True,
    "USER_DCAP_TRACE_COLLECT": False,
    "USER_DCAP_TRACE_COLLECT_Master": False,
    "USER_DCAP_TRACE_COLLECT_Slave": False,
    "USER_DCAP_TRACE_COLLECT_Slave1": False,
    "USER_RSI_INFO_COLLECT": True,
}
CELL_TARGET_BW_PATH = (         
	 "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL63/cell_target_bw.yaml")
__all__ = ["tl"]
