__maintainer__ = "radu.hirsovescu@nokia.com"
__owner__ = "radu.hirsovescu@nokia.com"
__email__ = "radu.hirsovescu@nokia.com"
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
        addr="10.5.19.175", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.176", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_3 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.188", username="ute", password="uteUTE!"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude("10.255.5.185", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"

_pdu_2 = Gude("10.255.5.184", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"

_pdu_3 = Gude("10.255.5.186", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_3.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[6].contactor = "NORMALLY_CLOSED"

_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="K9183920950",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
)
_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="K9181816201",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.132", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[9],
)
_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="K9181717463",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.131", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)
_rmod_4 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2135V0JZ9",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_5 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2135V0K0L",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.73.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_6 = RU(
    ru_hw_group="BL2135V0JUB",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2135V0JUB",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.77.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[12],
)
_rmod_7 = RU(
    ru_hw_group="BL2032V0I40",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2032V0I40",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.77.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
)
_rmod_8 = RU(
    ru_hw_group="L1205002760",
    radio_type=RadioTypes.AEHC.value,
    serial_number="L1205002760",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.22", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[5],
)
_rmod_9 = RU(
    ru_hw_group="L1204110673",
    radio_type=RadioTypes.AEHC.value,
    serial_number="L1204110673",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.18", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[6],
)
_rmod_10 = RU(
    ru_hw_group="L1204110677",
    radio_type=RadioTypes.AEHC.value,
    serial_number="L1204110677",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.56.14", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[2],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1194509181",
    rus=[_rmod_1, _rmod_3],
)
_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1192702091",
    rus=[_rmod_2],
)
_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1211802916",
    rus=[_rmod_4, _rmod_5],
)
_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="DH251512037",
    rus=[_rmod_8, _rmod_9, _rmod_10],
)
_fsp_5 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223400392",
    rus=[_rmod_6, _rmod_7],
)
_fsp_6 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1181314458",
    rus=[_rmod_4, _rmod_5],
)
_fsp_7 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA184778052",
    rus=[_rmod_7, _rmod_1, _rmod_3],
)
_fsp_8 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1191507738",
    rus=[_rmod_6, _rmod_2],
)
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="L1250803304",
    test_pc=_test_pc_1,
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_6, _fsp_7, _fsp_8],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIA",
    hardware_version="A.203",
    serial_number="EA190273561",
    test_pc=_test_pc_2,
)

_fct_3 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="L1224209082",
    test_pc=_test_pc_3,
)

_smod_1 = Airscale([_fct_1, _fct_3])
_smod_2 = Airscale([_fct_2])

_dcap_1 = DcapRnD(
    HttpConnectionDetails(
        addr="10.5.19.175", port="9443", username="dcapuser", password="dcapadmin!"
    )
)

_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.5.56.28",
                               expected_prompt="ftp",
                               user="ftp_5g",
                               password="Aikon_123456",
                               bind_interface_ip="10.5.61.132")

_data_transfer_iperf_1 = TafUeDataTransferProtocol(protocol_name='iperf',
                                                   app_server=_app_server_1,
                                                   binary_path='C:/Iperf/',
                                                   interface_name='Askey',
                                                   interval=1,
                                                   server_close_delay=50,
                                                   version=2,
                                                   dt_from_uepc=True)

_data_transfer_iperf_2 = TafUeDataTransferProtocol(protocol_name='iperf',
                                                   app_server=_app_server_1,
                                                   interval=1,
                                                   server_close_delay=50)

_at1 = TafUeAt(com_port='18',
               serial_number='66a4629c',
               capabilities=['ASKEY_UE'],
               ue_pc_address='10.5.53.132',
               ue_pc_login='rfsharing',
               ue_pc_password='Nokia2022!@1',
               ue_pc_expected_prompt='rfsharing@ROTMSRANU23132',
               data_transfer=[_data_transfer_iperf_1],
               ue_pc_port='81')

_at2 = TafUeAt(com_port='21',
               serial_number='dad020d7',
               capabilities=['ASKEY_UE'],
               ue_pc_address='10.5.53.132',
               ue_pc_login='rfsharing',
               ue_pc_password='Nokia2022!@1',
               ue_pc_expected_prompt='$',
               data_transfer=[_data_transfer_iperf_1],
               ue_pc_port='81')

_android1 = TafUeAndroid(serial_number='344f594f5a583398',
                         ue_pc_address='10.5.53.132',
                         data_transfer=[_data_transfer_iperf_2],
                         ssh_connection_details=SshServiceDetails(addr='10.5.53.132',
                                                                  username='rfsharing',
                                                                  password='Nokia2022!@1'),
                         ue_pc_port='80',
                         capabilities=['REAL_ANDROID_UE'])

_cu_smod = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.0.65.32"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.0.65.32", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.0.65.32", username="Nemuadmin", password="nemuuser"
    ),
)

_du_smod = DU(
    airscale=Airscale([_fct_1, _fct_3]),
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9, _rmod_10],
)

_gnb_nr_1 = ClassicalBts(cu=_cu_smod, dus=[_du_smod], instance_id=623032, dcap=_dcap_1)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_gnb_nr_1.dus[0].airscale.common_units[0],
        interface_type="lmp",
    )
)

_enb_lte_1 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7],
    instance_id=621032,
    dcap=_dcap_1,
)

_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_1.system_module.common_units[0],
        interface_type="lmp",
    )
)

_test_pc_3.connections.append(
    Connection(
        interface="eth1",
        device=_gnb_nr_1.dus[0].airscale.common_units[1],
        interface_type="lmp",
    )
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2, _test_pc_3],
    gnbs=[_gnb_nr_1],
    enbs=[_enb_lte_1],
    tl_cloud_topology="CLOUD_10_18_UTESRANRFSMTNRL32",
    ues=[_at1, _at2, _android1]
)

DCAP_PROFILES_CONFIG_PATH = (
    "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL32/dcap_profiles.yaml"
)

RSI_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL32/rsi_config.yaml"

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_DCAP_TRACE_COLLECT": False,
    "USER_DCAP_TRACE_COLLECT_Master": False,
    "USER_DCAP_TRACE_COLLECT_Slave": False,
    "USER_RSI_INFO_COLLECT": False,
    "USER_RTWP_CHECK": False,
}

__all__ = ["tl"]
