__maintainer__ = "iuga.dacian@nokia.com"
__owner__ = "iuga.dacian@nokia.com"
__email__ = "iuga.dacian@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit, CoreUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
import os 
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude, APC
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.nb import NB
from taf.config.testline.ran import RNC
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.testpc import TestPc
from taf.config.testline.dcap import DcapRnD, DcapBasic

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.141", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.142", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.130")],
)
_dcap_n = DcapRnD(
    HttpConnectionDetails(
        addr="10.5.19.141", port="9443", username=None, password=None
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

_android1 = TafUeAndroid(serial_number='H2J9FI1G803C2100204',
                        ue_pc_address='10.5.55.16',
                        data_transfer=[_data_transfer_iperf_1],
                        ssh_connection_details=SshServiceDetails(addr='10.5.55.16',
                                                                 username='rfsharing',
                                                                 password='Nokia2022!@1'),
                        ue_pc_port='80',
                        capabilities=['NR_FDD_B25'])

_android2 = TafUeAndroid(serial_number='H0R9FI1CN0230900572',
                        ue_pc_address='10.5.55.16',
                        data_transfer=[_data_transfer_iperf_1],
                        ssh_connection_details=SshServiceDetails(addr='10.5.55.16',
                                                                 username='rfsharing',
                                                                 password='Nokia2022!@1'),
                        ue_pc_port='80',
                        capabilities=['LTE_FDD_B25'])

_android3 = TafUeAndroid(serial_number='H0V9DE1CN0192200068',
                        ue_pc_address='10.5.55.16',
                        data_transfer=[_data_transfer_iperf_1],
                        ssh_connection_details=SshServiceDetails(addr='10.5.55.16',
                                                                 username='rfsharing',
                                                                 password='Nokia2022!@1'),
                        ue_pc_port='80',
                        capabilities=['NR_FDD_B2'])

_android4 = TafUeAndroid(serial_number='H0E9DE1CN0192200189',
                        ue_pc_address='10.5.55.16',
                        data_transfer=[_data_transfer_iperf_1],
                        ssh_connection_details=SshServiceDetails(addr='10.5.55.16',
                                                                 username='rfsharing',
                                                                 password='Nokia2022!@1'),
                        ue_pc_port='80',
                        capabilities=['LTE_FDD_B2'])

_android5 = TafUeAndroid(serial_number='H0J9DE1LV01B1200145',
                        ue_pc_address='10.5.55.16',
                        data_transfer=[_data_transfer_iperf_1],
                        ssh_connection_details=SshServiceDetails(addr='10.5.55.16',
                                                                 username='rfsharing',
                                                                 password='Nokia2022!@1'),
                        ue_pc_port='80',
                        capabilities=['NR_TDD_B41_60MHz'])

_android6 = TafUeAndroid(serial_number='H0D9FI1LV0180800045',
                        ue_pc_address='10.5.55.16',
                        data_transfer=[_data_transfer_iperf_1],
                        ssh_connection_details=SshServiceDetails(addr='10.5.55.16',
                                                                 username='rfsharing',
                                                                 password='Nokia2022!@1'),
                        ue_pc_port='80',
                        capabilities=['NR_TDD_B41_100MHz'])

_pdu_1 = Gude("10.255.5.9", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2 = Gude("10.255.5.8", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_3 = Gude("10.255.5.5", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_3.pdu_ports[11].contactor = "NORMALLY_OPENED"
_pdu_3.pdu_ports[12].contactor = "NORMALLY_OPENED"


_rmod_1 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFB.value,
    serial_number="EA183110569",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
    attenuation_ports=[],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFB.value,
    serial_number="EA183011259",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
    attenuation_ports=[],
)

_rmod_3 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHFB.value,
    serial_number="EA183011105",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
    attenuation_ports=[],
)

_rmod_4 = RU(
    ru_hw_group="ScRMTDr6.1_2T2R",
    radio_type=RadioTypes.AWHHH.value,
    serial_number="EB2213R0666",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[11],
    attenuation_ports=[],
)

_rmod_5 = RU(
    ru_hw_group="ScRMTDr6.1_2T2R",
    radio_type=RadioTypes.AWHHH.value,
    serial_number="EB2213R0661",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[12],
    attenuation_ports=[],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1233103405",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIM",
    hardware_version="475765A.102",
    serial_number="L1230610620",
    test_pc=_test_pc_1,
)


_fct_2 = CommonUnit(
     SshServiceDetails(
         addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
     ),
     capacity_units=[],
     pdu_port=_pdu_1.pdu_ports[2],
     hardware_type="ASOE",
     hardware_version="A.102",
     serial_number="EA214652491",
     test_pc=_test_pc_2,
     rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_cu_smod = CU(backhaul_site_oam_ip=NetworkAddress(v4="10.0.71.16"),
         oam_ssh_connection_details=SshServiceDetails(addr='10.0.71.16', username='toor4nsn', password='oZPS0POrRieRtu'),
         oam_http_connection_details=HttpConnectionDetails(addr='10.0.71.16', username='Nemuadmin', password='nemuuser'))

_du_smod = DU(airscale=Airscale([_fct_1]), rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5])

_enb_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    instance_id=624016,
    oam_ip=NetworkAddress(v4="10.0.71.16")
)
_enb_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    instance_id=623016,
    oam_ip=NetworkAddress(v4="10.0.69.16")
)

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_1.system_module.common_units[0],
        interface_type="lmp"
    )
)
_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_2.system_module.common_units[0],
        interface_type="lmp"
    )
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_2, _enb_1],
    tl_cloud_topology="CLOUD_HRAN_RFS_AIL_B1_ASOE_MTNRL16_3AHFB_2AWHHH",
    ues=[_android1, _android2, _android3, _android4, _android5, _android6]
)

RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_DCAP_TRACE_COLLECT": False,
    "USER_DCAP_TRACE_COLLECT_Master": False,
    "USER_DCAP_TRACE_COLLECT_Slave": False
}

CELL_TARGET_BW_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL16/cell_target_bw.yaml"
#DCAP_PROFILES_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL16/dcap_profiles.yaml"



__all__ = ["tl"]
