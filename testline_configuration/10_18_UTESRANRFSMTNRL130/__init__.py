__maintainer__ = "adelina.ivan@nokia.com"
__owner__ = "adelina.ivan@nokia.com"
__email__ = "adelina.ivan@nokia.com"
import os
from taf.config.testline.airscale import CapacityUnit, CommonUnit, Airscale
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt

_test_pc_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.183", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_slave = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.21.184", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.130")],
)
_pdu_1 = Gude(
    addr="10.255.7.6",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_2 = Gude(
    addr="10.255.7.7",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"

_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZQC.value,
    serial_number="AH221403363",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.41.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
    attenuation_ports=[],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZQC.value,
    serial_number="1M181624857",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.41.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
    attenuation_ports=[],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AZQC.value,
    serial_number="AH193502373",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.41.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
    attenuation_ports=[],
)

_abio_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.101",
    serial_number="L1204101547",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_abio_2 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.101",
    serial_number="l1204104712",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_asil_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_1],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1210402791",
    test_pc=_test_pc_master,
)

_asil_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_2],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="DH223747198",
    test_pc=_test_pc_slave,
)

a = Airscale([_asil_1])

_du_asil = DU(airscale=a, rus=[_rmod_1, _rmod_2, _rmod_3])

_cu_asil = CU(
    backhaul_site_oam_ip="10.0.65.130",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.65.130", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.65.130", username="Nemuadmin", password="nemuuser"
    ),
)

_classicalBts = ClassicalBts(cu=_cu_asil, dus=[_du_asil], instance_id=623130)

_enb_lte = RealEnb(
    system_module=Airscale(common_units=[_asil_2]),
    rms=[_rmod_1, _rmod_2, _rmod_3],
    instance_id=621130,
)


_test_pc_slave.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte.system_module.common_units[0],
        interface_type="lmp",
    )
)

_test_pc_master.connections.append(
    Connection(
        interface="eth1",
        device=_classicalBts.dus[0].airscale.common_units[0],
        interface_type="lmp",
    )
)

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.5.56.28",
    user="ftp_5g",
    password="Aikon_123456",
    bind_interface_ip="10.5.61.134"
)

_data_transfer_iperf_1 = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_app_server_1,
    interval=1,
    server_close_delay=50
)

_data_transfer_iperf_2 = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_app_server_1,
    interval=1,
    server_close_delay=50
)

_android1 = TafUeAndroid(
    serial_number='H0D9FI1LV0180800015',
    ue_pc_address='10.5.53.160',
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr='10.5.53.160',
        username='rfsharing',
        password='Nokia2022!@1'
    ),
    ue_pc_port='80',
    capabilities=['REAL_ANDROID_UE_1']
)

_android2 = TafUeAndroid(
    serial_number='H2J9FI1G803C2100306',
    ue_pc_address='10.5.53.160',
    data_transfer=[_data_transfer_iperf_2],
    ssh_connection_details=SshServiceDetails(
        addr='10.5.53.160',
        username='rfsharing',
        password='Nokia2022!@1'
    ),
    ue_pc_port='80',
    capabilities=['REAL_ANDROID_UE_2']
)


tl = TestLine(
    test_pc=_test_pc_master,
    test_pcs=[_test_pc_master, _test_pc_slave],
    gnbs=[_classicalBts],
    enbs=[_enb_lte],
    tl_cloud_topology="CLOUD_HRAN_RFS_AIL_B1_AIR_B4-_MTNRL130_3xAZQC",
    ues=[_android1, _android2],
)

ATTENUATOR_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL130/pa.yaml"

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "fail_if_unexpected_rtwp": True,
    "USER_RTWP_CHECK": False,
    "USER_RTWP_CHECK_Master": False,
    "USER_RTWP_CHECK_Slave": False,
    "USER_STOP_AND_FIX": False,
}
__all__ = ["tl"]
