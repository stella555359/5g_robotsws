# ---- README ----
# This configuration file was generated automatically
# Before using  this configuration file, please read the following documnent as some variables must be changed before
# running any Robot Test
# Link :

__owner__ = "georgiana.stefan@nokia.com"
__maintainer__ = "georgiana.stefan@nokia.com"
__email__ = "georgiana.stefan@nokia.com"


from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude, APC
from taf.config.testline.radio import RU, RadioTypes
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
from taf.config.testline.dcap import DcapRnD
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.87", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.88", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = APC(
    "10.255.5.102",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    version="AP7922B",
)
_pdu_1.pdu_ports[14].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[15].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[16].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude(
    "10.255.5.103",
    [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"


_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQL.value,
    serial_number="L1232810777",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.2", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[16],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQL.value,
    serial_number="L1232810778",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.6", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[15],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AVQL.value,
    serial_number="L1234906566",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.10", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[14],
)
_abip_1 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1233201709",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_abiq_2 = CapacityUnit(
    addr="",
    hardware_type="ABIQ",
    hardware_version="476397A.101",
    serial_number="L1232208157",
    rus=[_rmod_1],
)
_abiq_3 = CapacityUnit(
    addr="",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1233103422",
    rus=[_rmod_2],
)
_abiq_4 = CapacityUnit(
    addr="",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1233103986",
    rus=[_rmod_3],
)
_asil_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip_1],
    pdu_port=_pdu_2.pdu_ports[7],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1212705941",
    test_pc=_test_pc_1,
)
_asib_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abiq_2,_abiq_3,_abiq_4],
    pdu_port=_pdu_2.pdu_ports[8],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH213333823",
    test_pc=_test_pc_2,
)

_dcap_1 = DcapRnD(
    HttpConnectionDetails(
        addr="10.5.19.87", port="9443", username=None, password=None
    )
)

_cu_asil_1 = CU(
    backhaul_site_oam_ip="10.0.65.26",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.65.26", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.65.26", username="Nemuadmin", password="nemuuser"
    ),
)

_du_asil_1 = DU(airscale=Airscale([_asil_1]), rus=[_rmod_1, _rmod_2, _rmod_3])


_classicalBts_1 = ClassicalBts(
    cu=_cu_asil_1, dus=[_du_asil_1], instance_id=43166, dcap=_dcap_1
)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_classicalBts_1.dus[0].airscale.common_units[0],
        interface_type="lmp",
    )
)

_cu_asib_2 = CU(
    backhaul_site_oam_ip="10.0.67.26",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.67.26", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.67.26", username="Nemuadmin", password="nemuuser"
    ),
)

_du_asib_2 = DU(airscale=Airscale([_asib_2]), rus=[_rmod_1, _rmod_2, _rmod_3])

_classicalBts_2 = ClassicalBts(
    cu=_cu_asib_2, dus=[_du_asib_2], instance_id=43176, dcap=_dcap_1
)

_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_classicalBts_2.dus[0].airscale.common_units[0],
        interface_type="lmp",
    )
)

_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.5.56.28",
                               user="ftp_5g",
                               password="Aikon_4321",
                               bind_interface_ip="10.5.61.134")

_data_transfer_iperf_1 = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_1,
                                                 interval=1,
                                                 interface_name='5gsatimi',
                                                 server_close_delay=50)


_android1 = TafUeAndroid(serial_number='H0E9DE1LV0390400104',
                         ue_pc_address='10.5.55.94',
                         data_transfer=[_data_transfer_iperf_1],
                         ssh_connection_details=SshServiceDetails(addr='10.5.55.94',
                                                                  username='rfsharing',
                                                                  password='Nokia2022!@1'),
                         ue_pc_port='80',
                         capabilities=['REAL_ANDROID_UE_1'])

_android2 = TafUeAndroid(serial_number='H2J9FI1CN03A1100126',
                         ue_pc_address='10.5.55.94',
                         data_transfer=[_data_transfer_iperf_1],
                         ssh_connection_details=SshServiceDetails(addr='10.5.55.94',
                                                                  username='rfsharing',
                                                                  password='Nokia2022!@1'),
                         ue_pc_port='80',
                         capabilities=['REAL_ANDROID_UE_2'])

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_classicalBts_1, _classicalBts_2],
    tl_cloud_topology="CLOUD_10_18_UTESRANRFSMTNRL26",
    ues=[_android1, _android2],
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_RTWP_CHECK": False,
    "USER_STOP_AND_FIX": False,
    "USER_DCAP_TRACE_COLLECT": False,
    "USER_DCAP_TRACE_COLLECT_Master": False,
    "USER_DCAP_TRACE_COLLECT_Slave": False,
}

DCAP_PROFILES_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL26/dcap_profiles.yaml"
)

ATTENUATOR_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL26/pa.yaml"
)

CELL_TARGET_BW_PATH = ( 
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL26/cell_target_bw.yaml"
)

__all__ = ["tl"]
