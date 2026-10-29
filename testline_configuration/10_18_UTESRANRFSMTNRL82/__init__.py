__maintainer__ = "adelina.branc@nokia.com"
__owner__ = "adelina.branc@nokia.com"
__email__ = "adelina.branc@nokia.com"
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
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.31", username="ute", password="userpassword"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.32", username="ute", password="userpassword"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    addr="10.255.5.12",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude(
    addr="10.255.5.11",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
# _pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FXED.value,
    serial_number="F7164423456",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[10],
    attenuation_ports=[],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.FRGU.value,
    serial_number="K9172851293",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[12],
    attenuation_ports=[],
)

_fsp_abil = CapacityUnit(
    addr="", hardware_type="ABIL", hardware_version="A.102", serial_number="L1190810676", rus=[_rmod_1]
)

_fsp_abia = CapacityUnit(
    addr="", hardware_type="ABIA", hardware_version="A.103", serial_number="L1181412134", rus=[_rmod_1, _rmod_2]
)

_fct_asik = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_abil],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIK",
    hardware_version="A.102",
    serial_number="DH200864035",
    test_pc=_test_pc_1,
)

_fct_asib = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_abia],
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1202107114",
    test_pc=_test_pc_2,
)

_cu_asik = CU(
    backhaul_site_oam_ip="10.0.65.82",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.65.82", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.65.82", username="Nemuadmin", password="nemuuser"
    ),
)

_du_asik = DU(airscale=Airscale([_fct_asik]), rus=[_rmod_1])

_gnb_nr_1 = ClassicalBts(cu=_cu_asik, dus=[_du_asik], instance_id=623082)

_enb_lte_1 = RealEnb(
    system_module=Airscale(common_units=[_fct_asib]),
    rms=[_rmod_1, _rmod_2],
    instance_id=621082,
)

_bsc = BSC(
    name="BSC_PAAVAI",
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.27.126.7", username="SYSTEM", password="SYSTEM"
    ),
)

_test_pc_1.connections.append(Connection(interface="eth1", device=_gnb_nr_1.dus[0].airscale.common_units[0], interface_type="lmp"))
_test_pc_2.connections.append(Connection(interface="eth1", device=_enb_lte_1.system_module.common_units[0], interface_type="lmp"))

_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.5.56.24",
                               user="ftp3_5g",
                               password="Aikon_4321",
                               bind_interface_ip="10.5.61.138")

_data_transfer_iperf_1 = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_1,
                                                 interval=1,
                                                 server_close_delay=50)

_data_transfer_iperf_2 = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_1,
                                                 interval=1,
                                                 server_close_delay=50)

_android1 = TafUeAndroid(serial_number='412baf39',
                         ue_pc_address='10.5.53.182',
                         data_transfer=[_data_transfer_iperf_1],
                         ssh_connection_details=SshServiceDetails(addr='10.5.53.182',
                                                                  username='rfsharing',
                                                                  password='Nokia2022!@1'),
                         ue_pc_port='80',
                         capabilities=['REAL_ANDROID_UE'])

_android2 = TafUeAndroid(serial_number='H0J9DE1LV01C0401431',
                         ue_pc_address='10.5.53.182',
                         data_transfer=[_data_transfer_iperf_2],
                         ssh_connection_details=SshServiceDetails(addr='10.5.53.182',
                                                                  username='rfsharing',
                                                                  password='Nokia2022!@1'),
                         ue_pc_port='80',
                         capabilities=['XR20'])

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_lte_1],
    gnbs=[_gnb_nr_1],
    bscs=[_bsc],
    ues=[_android1, _android2],
)

UTE_UE_CONFIG = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL82/ues.yaml"
ATTENUATOR_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL82/pa.yaml"

TARGET_LOGICAL_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL82/logical_config.yaml"

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": False,
    "fail_if_wrn_threshold": True,
    "LK_USERNAME": "gabriel.stanculescu@nokia.com",
    "LK_PASSWORD": "Gabi1234!",
    "fail_if_unexpected_rtwp": False,
    "USER_RTWP_CHECK": False,
}


__all__ = ["tl"]
