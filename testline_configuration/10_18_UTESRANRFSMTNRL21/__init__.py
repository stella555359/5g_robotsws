# Here you have a template for TAF config format in LTE-GSM/WCDMA-LTE/NR-LTE/NR-NR Cases.
# Spacing and indentation MUST be taken into account, otherwise Gerrit commits will FAIL
# Please remove ALL comments before any commit

# add your email to the following 3 lines
__maintainer__ = "oana.vacarescu@nokia.com"
__owner__ = "oana.vacarescu@nokia.com"
__email__ = "oana.vacarescu@nokia.com"
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.lmi import SerialOverHost,SerialOverTcp,Local, Remote
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

# TestPc class defines details about VMs/PC UEs connected to eNB
# Data you need to provide: VM ip, username, pass(defined in Cloud Manager user profile settings), eth1 lmp ip
# You can create as many TestPc objects as you need (for VM1, VM2, PC UE). NetworkAddress for VM2 (192.168.255.130) and for PC (192.168.255.131)
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.151", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.152", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude("10.255.5.182", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8221-1")
_pdu_3 = Gude("10.255.5.183", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8221-1")
#_pdu_2 = FPFH("10.255.5.99", [1, 2, 3, 4, 5, 6], login="admin", password="admin", protocol="http")

_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[8].contactor = "NORMALLY_CLOSED"
#_pdu_2.pdu_ports[3].contactor = "NORMALLY_OPENED"
#_pdu_2.pdu_ports[7].contactor = "NORMALLY_OPENED"


_rmod_1 = RU(
    ru_hw_group="FRMr6.1_4T4R",
    radio_type=RadioTypes.AHEGHA.value,
    serial_number="BL2330H60B2",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.85.128", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[1],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.53.133", username="rfsharing", password="Nokia2022!@1"
            )
        ),
        uart_mapping=[Local(port="COM48")],  # windows
    ),
)

_rmod_2 = RU(
    ru_hw_group="FRMr6.1_4T4R",
    radio_type=RadioTypes.AHEGHA.value,
    serial_number="BL2331H60BR",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.85.131", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[3],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.53.133", username="rfsharing", password="Nokia2022!@1"
            )
        ),
        uart_mapping=[Local(port="COM40")],  # windows
    ),
)

_rmod_3 = RU(
    ru_hw_group="FRMr6.1_4T4R",
    radio_type=RadioTypes.AHEGHA.value,
    serial_number="K9242154828",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.85.130", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[8],
    lmi=SerialOverHost(
        host=TestPc(
            default_ssh_connection_details=SshServiceDetails(
                addr="10.5.53.135", username="rfs_5g", password="Nokia2022!@1"
            )
        ),
        uart_mapping=[Local(port="COM47")],  # windows
    ),
)

_abio_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1204706794",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_abio_2 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204104885",
    rus=[_rmod_1],
)
_abio_3 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1212615345",
    rus=[_rmod_2, _rmod_3],
)
_abia_1 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171309134",
    rus=[_rmod_1],
)
_abio_4 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211511340",
    rus=[_rmod_1],
)
_abia_3 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1190712896",
)


_asib_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_1, _abio_2, _abio_3],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1192701828",
    test_pc=_test_pc_1,
)
_asib_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_1, _abio_4, _abia_3],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1201004613",
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
    instance_id=621021,
    oam_ip=NetworkAddress("10.0.71.21")
)

_enb_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1],
    instance_id=621021,
    oam_ip=NetworkAddress("10.0.69.21")
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
    rnc_id="8",
    oms_ip="10.55.1.178",
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
    tl_cloud_topology="CLOUD_HRAN_RFS_AIL_B1-3_AIR_B4_MTNRL21_3xAHEGHA",
    ues=[_android1, _android2, _android3, _android4],
)

CELL_TARGET_BW_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL21/cell_target_bw.yaml"




RFS_TL_FLAGS = {
    "fail_if_unexpected_rtwp":False,   
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_RTWP_CHECK": False,
    "USER_STOP_AND_FIX": True,
    "USER_STOP_AND_FIX_BLOCK_TEST": True,
    "USER_RSI_INFO_COLLECT":True,
    "RF_DIAGNOSTIC_CARD_CUSTOM_YAML": "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL21/rsi_config.yaml",
    "RMOD_UDP_LOG_CONFIG_PATH": "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL21/auto_udp.yaml"
}

__all__ = ["tl"]
