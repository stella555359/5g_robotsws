__maintainer__ = "Sebastian Mikos"
__team__ = "MN 5G&SC 5G Pz 2 WRO 5 SG"
__email__ = "I_5GSC_5G_PZ2_WRO_5@internal.nsn.com"
__owner_email__ = "sebastian.mikos@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import AppServer
from taf.config.testline import TafUeDataTransferProtocol
from taf.config.testline.pdn import PDNTafUeAndroidDetails
from taf.config.testline.pdu import Gude
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.attenuator import JFW
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb, NetworkAddress, RoutingInformation
# _CFG_DIR = os.path.dirname(os.path.abspath(__file__))


_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.42.61.65",
                               user="5g",
                               password="2019H@slo",
                               bind_interface_ip="10.42.197.170")

_data_transfer_iperf = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_1,
                                                 interval=1)                                  
 
_data_transfer_ping = TafUeDataTransferProtocol(protocol_name='ping',
                                                app_server=_app_server_1,
                                                interval=1)
 
_data_transfer_ftp = TafUeDataTransferProtocol(protocol_name='ftp',
                                               app_server=_app_server_1,
                                               interval=1)
_pdn1 = \
    PDNTafUeAndroidDetails(entryName='internet',                  
                           apnName='internet',                       
                           apnType=['DEFAULT'],   
                           )                      

_pdu_1 = Gude("10.44.205.64", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2 = Gude("10.44.205.51", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")

_ru1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.129", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="",
    pdu_port=_pdu_1.pdu_ports[10],
    radio_type="AHPF",
)
_ru2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.128", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="",
    pdu_port=_pdu_1.pdu_ports[11],
    radio_type="AHPF",
)

_abil_master = CapacityUnit(addr="fd5f:4268:2387:a881:40:43ff:fe80:1101", hardware_type="ABIO", rus=[_ru1, _ru2])

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master],
    hardware_type="ASIB",
    pdu_port=_pdu_2.pdu_ports[12],
)
_airscale = Airscale([_common_unit])
_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.91.147",
        routing=RoutingInformation(gateway="10.44.91.1", ip_prefix_length=26),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(
        v4="10.44.90.209",
        routing=RoutingInformation(
            gateway="10.44.90.1",
            ip_prefix_length=26,
        ),
    ),
    x2u=NetworkAddress(
        v4="10.44.91.19",
        routing=RoutingInformation(gateway="10.44.91.1", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.44.91.83",
        routing=RoutingInformation(gateway="10.44.91.1", ip_prefix_length=26),
    ),
)

_du = DU(_airscale)
_classical_bts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=50016, instance_id=50016)
_core = RealCore5G(mcc=310, mnc=260)
_core_ssh = SshServiceDetails(addr="10.42.61.65", username="5g", password="2019H@slo")
_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_iperf_ue = IperfDataTransferDetails(
    ssh_connection_details=_core_ssh,
    network_interface_address="10.42.197.170",
    iperf_path="",
)

_attenuator = JFW(
    ip_addr="10.42.61.10",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
)
_appserver = AppServer(_iperf_ue)

# _ue_pc_ssh = SshServiceDetails("10.42.22.158", "wro5grrm", password="5gpass!1")
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.137", username="ute", password="ute"
    ),
    connections=[_classical_bts.dus[0].airscale.common_units[0]]

)

_qualcomm_ue = TafUeAndroid(serial_number='74453808',
                         capabilities=['REAL_UE','SA_QUALCOMM'],
                         ue_pc_address='10.42.22.158',
                         data_transfer=[_data_transfer_iperf,
                                        _data_transfer_ping,
                                        _data_transfer_ftp],
                         ssh_connection_details=SshServiceDetails(addr='10.42.22.158',
                                                                  username='wro5grrm',
                                                                  password='5gpass!1'),
                         ue_pc_port='8080',
                         pdns=[_pdn1],
                         qualcomm_prototype=True,
                         network_mode_switch_method='ADB',
                         is_rooted='no',
                         voice_call_technology='nr',
                         voice_call_technology_timeout=60.0,
                         voice_call_dialing_timeout=-1.0)

_qualcomm_ue_2 = TafUeAndroid(serial_number='e4daa611',
                         capabilities=['REAL_UE', 'SA_QUALCOMM_SDX60'],
                         ue_pc_address='10.42.22.158',
                         data_transfer=[_data_transfer_iperf,
                                        _data_transfer_ping,
                                        _data_transfer_ftp],
                         ssh_connection_details=SshServiceDetails(addr='10.42.22.158',
                                                                  username='wro5grrm',
                                                                  password='5gpass!1'),
                         ue_pc_port='8080',
                         pdns=[_pdn1],
                         qualcomm_prototype=True,
                         network_mode_switch_method='ADB',
                         is_rooted='no',
                         voice_call_technology='nr',
                         voice_call_technology_timeout=60.0,
                         voice_call_dialing_timeout=-1.0)

_mtk_ue = TafUeAndroid(serial_number='PETPINT',
                         capabilities=['REAL_UE', 'MTK_UE'],
                         ue_pc_address='10.42.22.158',
                         data_transfer=[_data_transfer_iperf,
                                        _data_transfer_ping,
                                        _data_transfer_ftp],
                         ssh_connection_details=SshServiceDetails(addr='10.42.22.158',
                                                                  username='wro5grrm',
                                                                  password='5gpass!1'),
                         ue_pc_port='8080',
                         pdns=[_pdn1],
                         network_mode_switch_method='ADB',
                         is_rooted='no',
                         voice_call_technology='nr',
                         voice_call_technology_timeout=60.0,
                         voice_call_dialing_timeout=-1.0)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    gnbs=[_classical_bts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_QC_ASIBL_ABIOB1_2xAHPF",
    core=_core,
    ues=[_mtk_ue, _qualcomm_ue, _qualcomm_ue_2],
    appserver=_appserver,
    attenuators=[_attenuator],
)
__all__ = ["tl"]
