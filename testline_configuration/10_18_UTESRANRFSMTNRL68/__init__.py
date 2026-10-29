__maintainer__ = "dorin.caluser@nokia.com"
__owner__ = "dorin.caluser@nokia.com"
__email__ = "dorin.caluser@nokia.com"
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
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
import os
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
        addr="10.5.19.131", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.132", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude("10.255.5.18", [1, 2], model="EPC", version="8221-1")
_pdu_2 = Gude("10.255.5.17", [8, 9, 10, 11, 12], model="EPC", version="8221-1")


_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"


_rmod_1 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type=RadioTypes.AHPMDA.value,
    serial_number="K9193501356",
    pdu_port=_pdu_2.pdu_ports[10],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.168",
                username="rfsharing",
                password="Nokia2022!@1"
            )
        ),
        uart_mapping=[
            Local(
                port="COM11"
            )
        ]
    )

)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type=RadioTypes.AHPMDA.value,
    serial_number="K9191401878",
    pdu_port=_pdu_2.pdu_ports[11],
)

_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEGB.value,
    serial_number="K9213913726",
    pdu_port=_pdu_2.pdu_ports[8],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.55.168",
                username="rfsharing",
                password="Nokia2022!@1"
            )
        ),
        uart_mapping=[
            Local(
                port="COM12"
            )
        ]
    )
)

_rmod_4 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEGB.value,
    serial_number="EA223757249",
    pdu_port=_pdu_2.pdu_ports[9],
)

_abio_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.103",
    serial_number="L1213010352",
    rus=[_rmod_2],
)
_abio_2 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.101",
    serial_number="L1204104856",
    rus=[_rmod_1, _rmod_3, _rmod_4],
)

_abia_1 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="L1171312761",
)
_abia_2 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="EA184277004",
    rus=[_rmod_1, _rmod_2,_rmod_3],
)
_abia_3 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="A.104",
    serial_number="A193774767",
    rus=[_rmod_4],
)


_asib_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_1, _abia_1, _abia_2],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="A.101",
    serial_number="L1204104856",
    test_pc=_test_pc_1,
)
_asib_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_2, _abia_3],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1212509604",
    test_pc=_test_pc_2,
)


_smod_1 = Airscale([_asib_1])
_smod_2 = Airscale([_asib_2])

##### NR Standalone RELATED #####
# PLEASE DELETE THIS SECTION IF YOU DON'T NEED IT - REMOVE ALSO FROM IMPORT SECTION lines with DU, ClassicalBts, CU
# CU class for Central Unit NR
# Data you need to provide: OAM IP, ssh service details (IP, username, pass), WEB acces details (IP, username, pass)

_enb_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3],
    instance_id=1,
    oam_ip=NetworkAddress("10.0.65.68")
)

_enb_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_3, _rmod_4],
    instance_id=623068,
    oam_ip=NetworkAddress("10.0.67.68")
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

# BSC class for defining BSC entity used by GSM.
# Data you need to provide: name, TELNET/SSH connection details (IP address, username, pass)
# Please keep only the relevant connection details (either telenet or ssh), not both
_bsc = BSC(
    name="BSC_PAAVAI",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.27.126.200", username="SYSTEM", password="SYSTEM"
        ),
)
 
# RNC class for defining RNC entity used by WCDMA.
# Data you need to provide: RNC ID, OMS ip, SSH connection details (IP address, username, pass)
_rnc = RNC(
    rnc_id="9",
    oms_ip="10.94.92.156",
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.44.44.219", username="Nemuadmin", password="nemuuser"
    ),
)

_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.5.56.28",
                               user="ftp_5g",
                               password="Aikon_4321",
                               bind_interface_ip="10.5.61.134")

_app_server_2 = TafUeAppServer(app_server_name="APP_2",
                               address="10.9.146.30",
                               user="iperf_user",
                               password="Treperf",
                               bind_interface_ip="10.9.146.30")

_data_transfer_iperf_1 = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_1,
                                                 interval=1,
                                                 server_close_delay=50)

_data_transfer_iperf_2 = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_2,
                                                 interval=1,
                                                 server_close_delay=50)

_android1 = TafUeAndroid(serial_number='H0J9DE1LV01C2900004',
                         ue_pc_address='10.5.53.135',
                         data_transfer=[_data_transfer_iperf_1],
                         ssh_connection_details=SshServiceDetails(addr='10.5.53.135',
                                                                  username='rfs_5g',
                                                                  password='Nokia2022!@1'),
                         ue_pc_port='80',
                         capabilities=['NOKIAXR20'])

_android2 = TafUeAndroid(serial_number='0123456789ABCDEF',
                         ue_pc_address='10.5.53.135',
                         data_transfer=[_data_transfer_iperf_1],
                         ssh_connection_details=SshServiceDetails(addr='10.5.53.135',
                                                                  username='rfs_5g',
                                                                  password='Nokia2022!@1'),
                         ue_pc_port='80',
                         capabilities=['MTK'])

_android3 = TafUeAndroid(serial_number='61c7a852',
                         ue_pc_address='10.5.53.135',
                         data_transfer=[_data_transfer_iperf_2],
                         ssh_connection_details=SshServiceDetails(addr='10.5.53.135',
                                                                  username='rfs_5g',
                                                                  password='Nokia2022!@1'),
                         ue_pc_port='80',
                         capabilities=['SAMSUNG'])

_android4 = TafUeAndroid(serial_number='AQKSLVH002MC0200627',
                         ue_pc_address='10.5.53.135',
                         data_transfer=[_data_transfer_iperf_2],
                         ssh_connection_details=SshServiceDetails(addr='10.5.53.135',
                                                                  username='rfs_5g',
                                                                  password='Nokia2022!@1'),
                         ue_pc_port='80',
                         capabilities=['NOKIA_3G'])

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_1, _enb_2],
    bscs=[_bsc],
    rncs=[_rnc],
    tl_cloud_topology="CLOUD_HRAN_RFS_MTNRL68",
    ues=[_android1, _android2, _android3, _android4],
)

CELL_TARGET_BW_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL68/cell_target_bw.yaml"
#RSI_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL68/rsi_config.yaml"


RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "POWER_ON_FLAG": True,
    "USER_RTWP_CHECK": False,
    "USER_STOP_AND_FIX": False,
    "USER_STOP_AND_FIX_BLOCK_TEST": False,
    "USER_SCF_VALIDATION_CHECK": False,
    "USER_DCAP_TRACE_COLLECT": False,
    "USER_DCAP_TRACE_COLLECT_Master": False,
    "USER_DCAP_TRACE_COLLECT_Slave": False,
    "USER_RSI_INFO_COLLECT": True,
    "RF_DIAGNOSTIC_CARD_CUSTOM_YAML": "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL68/MTNRL68_custom_rmod_setup.yaml",
    "NETACT_CHECK": False,
}

__all__ = ["tl"]