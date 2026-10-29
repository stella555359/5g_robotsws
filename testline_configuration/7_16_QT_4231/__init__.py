__maintainer__ = "QT WRO"
__team__ = "MN RAN RD T&V OTA&CI QT2"
__email__ = "I_5GQT_WRO@internal.nsn.com"
__owner_email__ = "I_5GQT_WRO@internal.nsn.com"

import os
from taf.config.testline import TafUeDataTransferProtocol
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)

from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RU
from taf.config.testline.enb import RealEnb
from taf.config.testline.ue import TafUeAt, PluginAtClassType
from taf.config.testline.airscale import Airscale, CommonUnit
from taf.config.testline.pdu import ATEN, EPC, Gude
from taf.config.testline.appserver import AppServer, TafUeAppServer
from taf.config.testline.attenuator import TopYoung
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.158.93",
        username="ute",
        password="UTE.debian12"
    )
)

_test_pc_lte_nsa = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.158.185",
        username="ute",
        password="UTE.debian12"
    )
)

_appserver_ssh = SshServiceDetails(
    addr="10.42.158.93", username="ute", password="UTE.debian12"
)

_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.45.168.53",
)

_appserver = AppServer(_iperf_details_on_appserver)

_appserver_taf_ue_WL = TafUeAppServer(app_server_name="wl-srn-server-1-idf34",
                                   address="10.45.168.53",
                                   user="qt5g",
                                   password="5Gqtmoth!",
                                   bind_interface_ip="10.45.168.53",
                                   expected_prompt="qt5g@wl-srn-server-1-idf34")


_data_transfer_iperf_WL = TafUeDataTransferProtocol(protocol_name="iperf",
                                                 app_server=_appserver_taf_ue_WL,
                                                 interval=1,
                                                 binary_path='/cygdrive/c/iperf/',
                                                 interface_name='ASKEY_4231',
                                                 dt_from_uepc=True)


_cu = CU(
    backhaul_site_oam_ip="10.44.229.184",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.229.184", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.229.184", username="Nemuadmin", password="nemuuser"
    ),
)

_snmp_user_data=dict(
    userName="administrator",
    authKey="password",
    privKey="password",
    authProtocol="SHA1",
    privProtocol="AES-128",
)

_du_lmp_connection = SshServiceDetails(
    addr="10.44.229.184", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_pdu = Gude(addr="10.44.177.111", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8221-1", snmp_user=_snmp_user_data)

_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[None],
    pdu_port=_common_unit_pdu.pdu_ports[9],
    hardware_type="ASOG",
    hardware_version="A.101",
)

_airscale = Airscale(common_units=[_common_unit])

_5g_ru_pdu = Gude(addr="10.44.177.125", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8220-1", snmp_user=_snmp_user_data)

_ru = RU(
    ru_hw_group="AEQE",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.2", username="rfsw", password="HfBKgqIOogKY3BlGtiniuCI9bs76C8jYsAY6vw8f/Tw="
    ),
    lmp_connection=SshServiceDetails(
        addr="5.5.5.5", username="rfsw", password="HfBKgqIOogKY3BlGtiniuCI9bs76C8jYsAY6vw8f/Tw="
    ),
    pdu_port=_5g_ru_pdu.pdu_ports[12],
)

_du = DU(airscale=_airscale, rus=[_ru], f1_m_ip_addr="10.44.229.184")

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_4g_ru_pdu = Gude(addr="10.44.177.116", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC",
                  version="8220-1", snmp_user=_snmp_user_data)

_RadioModule = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=_4g_ru_pdu.pdu_ports[12],
)

_real_enb_pdu = Gude(addr="10.44.177.110", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC",
                  version="8220-1", snmp_user=_snmp_user_data)

_common_unit_enb = CommonUnit(      #QT_LTE_eNB_01
    lmp_connection=SshServiceDetails(
        addr="10.44.231.19", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_real_enb_pdu.pdu_ports[5],
)

_common_unit_enb.tl_enb = "QT_LTE_eNB_01"

_real_enb = Airscale(common_units=[_common_unit_enb])

_lte_real_enb = RealEnb(system_module=_real_enb, rms=[_RadioModule])

_askey = TafUeAt(com_port='3',
                 serial_number="320e707",
                 capabilities=['_5G'],
                 ue_pc_address='10.44.72.92',
                 ue_pc_login='wro5gqt',
                 ue_pc_password='5Gqtmoth',
                 proxy_mngr_port='80',
                 ueproxy_force_release=False,
                 ue_pc_expected_prompt='wro5gqt@PLWR5G5389',
                 data_transfer=[_data_transfer_iperf_WL])

_askey.ue_type = "askey"
  
_attenuator = TopYoung(
    ip_addr="10.42.83.5",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24],
    model="TAS_24T24_02G6_90_1C_EJS",
)

_attenuator_enb = TopYoung(
   ip_addr="10.42.83.5",
   port=3001,
   attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24],
   model="TAS_24T24_02G6_90_1C_EJS",
) 

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc_lte_nsa, _test_pc],
    gnbs=[_cbts],
    enbs=[_lte_real_enb],
    ues=[_askey],
    appserver=_appserver,
    attenuators=[_attenuator, _attenuator_enb],
    tl_cloud_topology="4231",
)

tl.target_traffic_5G = {
    "IPERF_DURATION": "180", #seconds
    "MIN_DL": "120", #Mbits/sec
    "MAX_DL": "150", #Mbits/sec
    "MIN_UL": "32", #Mbits/sec
    "MAX_UL": "40", #Mbits/sec
    "cell_id_rf1": "13594883"
}

tl.attenuation = {
    "attenuation_port": "3001",
    "attenuation_index": {"att":0},
    "attenuation_5G": {15:0},
    "pdu_model": "Gude",
    "pdu_attenuator_version": "8220-1",
    "pdu_attenuator_ip": "10.44.177.117",
    "pdu_attenuator_port": "12",

}

tl.custom = {
    "real_enb": "True",          # True if 5G NSA TL is connected to LTE eNB
    "standalone": "False",       # True if SA, False for NSA
    "has_real_core": "True",     # True if TL using realcore
	"askey_pdu_ip": "10.44.177.119",
    "askey_pdu_port": "9",
	# "ue_pc_pdu_ip": "10.44.177.118",
	# "ue_pc_pdu_port": "3",
}

tl.scf_variables = {
    "mrbts": "531053",
    "nrbts": "531053",
    "btsName": "QT-ASOG_5G_NSA_TDD-WRO-4231", #new 4031, tmp 4231
    "location": "WRO_WL_L4_05_Rack_2532",
    "secondEndpointPortId": "1",
    "ntpServerIpAddrOrFqdnList": "10.42.248.70",
    "masterIpAddr": "10.42.0.106",
    "mcc": "555",
    "mnc": "10",
    "mncLength": "2",
    "nr_pmax": "260",
    "pMaxNROwnCell": "23",
    "enb_x2_ip": "10.44.231.83", #QT_LTE_eNB_01 U&C-Plane
    #mplane					 
    "mplane_vlan": "674",
    "mplane_ip": "10.44.229.184",
    "mplane_ip_prefix": "26",
    "mplane_gw": "10.44.229.129",
    #x2c
    "x2c_or_xnc_label": "x2c",
    "x2c_or_xnc_vlan": "675",
    "x2c_or_xnc_ip":"10.44.229.247",
    "x2c_or_xnc_ip_prefix": "26",
    "x2c_or_xnc_gw": "10.44.229.193",
    #x2u
    "x2u_or_xnu_label": "x2u",
    "x2u_or_xnu_vlan": "676",
    "x2u_or_xnu_ip": "10.44.230.55",
    "x2u_or_xnu_ip_prefix": "26",
    "x2u_or_xnu_gw": "10.44.230.1",
    #s1u
    "s1u_or_ngu_vlan": "677",
    "s1u_or_ngu_ip": "10.44.230.110",
    "s1u_or_ngu_ip_prefix": "26",								
    "s1u_or_ngu_gw": "10.44.230.65",
}


tl.android_config_dir = os.path.dirname(os.path.abspath(__file__))

__all__ = ["tl"]
