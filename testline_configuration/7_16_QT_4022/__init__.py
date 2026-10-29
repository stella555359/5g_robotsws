__maintainer__ = "QT WRO"
__team__ = "MN RAN RD T&V OTA&CI QT2"
__email__ = "I_5GQT_WRO@internal.nsn.com"
__owner_email__ = "I_5GQT_WRO@internal.nsn.com"


import os
																			
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)										   
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RU
from taf.config.testline.core import EPCSim										  
from taf.config.testline.airscale import Airscale, CommonUnit
from taf.config.testline.pdu import ATEN, Gude														
from taf.config.testline.appserver import AppServer
from taf.config.testline.attenuator import TopYoung
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer 
from taf.config.testline.ue import TafUeAt, PluginAtClassType

_snmp_user_data = dict(
    userName="administrator",
    authKey="password",
    privKey="password",
    authProtocol="SHA1",
    privProtocol="AES-128",
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.195.231",
        username="ute",
        password="UTE.debian12"
    )
)
						  													 														
_appserver_ssh = SshServiceDetails(
    addr="10.42.195.231",
    username="ute",
    password="UTE.debian12"
)

_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.45.168.53"
)

_appserver = AppServer(_iperf_details_on_appserver)

_appserver_taf_ue = TafUeAppServer(app_server_name="APP_TAF_UE",
    address="10.45.168.53",
    user="qt5g",
    password="5Gqtmoth!",
    bind_interface_ip="10.45.168.53",
    expected_prompt="qt5g@wl-srn-server-1-idf34",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_taf_ue,
    binary_path='/cygdrive/c/iperf/',
    interface_name='QUECTEL_4022',
    dt_from_uepc=True,
)

_cu = CU(
    backhaul_site_oam_ip="10.44.80.9",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.80.9",
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.80.9",
        username="Nemuadmin",
        password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="10.44.80.9",
    username="toor4nsn",
    password="oZPS0POrRieRtu"
)

_common_unit_pdu = Gude(
    addr="10.44.177.91",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC", version="8221-1",
    snmp_user=_snmp_user_data
)

_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[None],
    pdu_port=_common_unit_pdu.pdu_ports[6],
)

_airscale = Airscale(common_units=[_common_unit])
			   					 
_5g_ru_pdu = ATEN(
    addr="10.44.206.125",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8]
)										  

_ru = RU(
    ru_hw_group="AEHC",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.162",
        username="rfsw",
        password="HfBKgqIOogKY3BlGtiniuCI9bs76C8jYsAY6vw8f/Tw="
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1",
        username="root",
        password="root"
    ),
    pdu_port=_5g_ru_pdu.pdu_ports[2],
)

_du = DU(
    airscale=_airscale,
    rus=[_ru],
    f1_m_ip_addr="10.44.80.9"
)

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_epcsim = EPCSim(
    mme_ip="10.45.168.53",
    mcc=540,
    mnc=1,
    tac=7151,
    default_ssh_connection_details=SshServiceDetails(
        addr="10.45.168.53",
        username="qt5g",
        password="5Gqtmoth!"
    ),
    dir_path="/home/ute/Robot_LteEmu",
    cfg_filename="Robot_LteEmu_Config",
)																

_quectel_5G = TafUeAt(
    com_port='8', 
    #serial_number="867978050013050", #or IMEI in SimCom Quectel UE
    imei="867978050013050",
    capabilities=['_5G'],
    ue_pc_address='10.42.224.80',
    ue_pc_login='wro5gqt',
    ue_pc_password='5Gqtmoth',
    ue_pc_expected_prompt="wro5gqt@PLWR5G5995",
    data_transfer=[_data_transfer_iperf],
    proxy_mngr_port=80, 
    ueproxy_force_release=False,
    class_name=PluginAtClassType.quectel,
    processes_to_kill=['Vysor'])

_quectel_5G.ue_type = "quectel"

_attenuator = TopYoung(
    ip_addr="10.42.61.129",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24],
    model="TAS_24T24_04G6_90_1S_EJS",
)

tl = TestLine(
    test_pc=_test_pc,								  
    gnbs=[_cbts],				 
    core=_epcsim,
    ues=[_quectel_5G],
    appserver=_appserver,
    attenuators=[_attenuator],
    tl_cloud_topology="4022",
)

tl.target_traffic_5G = {
    "IPERF_DURATION": "180", #seconds
    "MIN_DL": "320", #Mbits/sec
    "MAX_DL": "400", #Mbits/sec
    "MIN_UL": "32", #Mbits/sec
    "MAX_UL": "40", #Mbits/sec
    "cell_id_rf1": "849601"
}

tl.attenuation = {
    "attenuation_port": "3001",
    "attenuation_5G": {5:65, 6:65, 7:65, 8:65},
    "attenuation_index": {"att":0},
    "pdu_model": "ATEN",						   
    "pdu_attenuator_ip": "10.44.206.125",
    "pdu_attenuator_port": "8",
}

tl.custom = {
    "real_enb": "False",        # True if 5G NSA TL is connected to LTE eNB
    "standalone": "True",       # True if SA, False for NSA
    "has_real_core": "True",    # True if TL using realcore
    "askey_pdu_ip": "10.42.61.177",
    "askey_pdu_port": "0",
}

tl.scf_variables = {
    "mrbts": "53100",
    "btsName": "QT-ASIK_ABIL_5G_SA_TDD-WRO-4022",
    "location": "WRO",
    "secondEndpointPortId": "1",											 							  
    "bbmod_1_prodcode": "474020A.102", 
    "mcc": "1",
    "mnc": "1",
    "mncLength": "2",
    "nr_pmax": "360",
    "pMaxNROwnCell": "23",
    "physCellId": "50",
    "pMaxEutra": "23",
    "fiveGsTac": "7151",
    "x2c_or_xnc_label": "x2c",
    "x2u_or_xnu_label": "x2u",
    "mplane_vlan": "459",
    "x2c_or_xnc_vlan": "460",
    "x2u_or_xnu_vlan": "461",
    "s1u_or_ngu_vlan": "462",
    "ntpServer_ip": "10.42.248.70",
    "masterIpAddr": "10.42.0.106",
    "amfIPAddress": "10.27.28.136",
    "mplane_ip": "10.44.80.9",
    "mplane_ip_prefix": "26",
    "x2c_or_xnc_ip": "10.44.80.123",
    "x2c_or_xnc_ip_prefix": "26",
    "x2u_or_xnu_ip": "10.44.65.240",
    "x2u_or_xnu_ip_prefix": "26",
    "s1u_or_ngu_ip": "10.44.66.48",
    "s1u_or_ngu_ip_prefix": "26",
    "mplane_gw": "10.44.80.1",
    "x2c_or_xnc_gw": "10.44.80.65",
    "x2u_or_xnu_gw": "10.44.65.193",
    "s1u_or_ngu_gw": "10.44.66.1",
}

tl.android_config_dir = os.path.dirname(os.path.abspath(__file__))

__all__ = ["tl"]
