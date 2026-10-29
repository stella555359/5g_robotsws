__maintainer__ = "QT WRO"
__team__ = "MN RAN RD T&V OTA&CI QT1"
__email__ = "I_AM_QT@internal.nsn.com"
__owner_email__ = "I_AM_QT@internal.nsn.com"


import os
from taf.config.testline import TafUeDataTransferProtocol
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import PduPort, Gude, EPC
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.ue import TafUeAt, PluginAtClassType

#_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.194.104", 
		username="ute", 
		password="UTE.debian12"
    )
)

_appserver_taf_ue_WL = TafUeAppServer(app_server_name="APP_TAF_UE",
    address="10.42.249.116",
    user="qt5g",
    password="5Gqtmoth!",
    bind_interface_ip="10.42.249.116",
    expected_prompt="qt5g@wl-srn-server-3-1094")
	
_data_transfer_iperf_WL = TafUeDataTransferProtocol(protocol_name="iperf",
                                                 app_server=_appserver_taf_ue_WL,
                                                 interval=1,
                                                 binary_path='/cygdrive/c/iperf/',
                                                 interface_name='QUECTEL_3154',
                                                 dt_from_uepc=True)  
												 
_cu = CU(
    backhaul_site_oam_ip="10.44.229.150",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.229.150", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.229.150", username="Nemuadmin", password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)
										 

_snmp_user_data=dict(
    userName="administrator",
    authKey="password",
    privKey="password",
    authProtocol="SHA1",
    privProtocol="AES-128",
)

_du_pdu = Gude(
    addr="10.44.177.237",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_du_pdu_port = PduPort(pdu=_du_pdu, port_no=4)

_du_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[None],
    pdu_port=_du_pdu_port,
)

_airscale = Airscale(common_units=[_du_common_unit])

_ru1_pdu = Gude(
    addr="10.44.177.228",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_ru2_pdu = Gude(
    addr="10.44.177.228",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_ru1_pdu_port = PduPort(pdu=_ru1_pdu, port_no=6)

_ru2_pdu_port = PduPort(pdu=_ru2_pdu, port_no=1)

_ru1 = RU(
    ru_hw_group="AHEB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="5.5.5.5", username="root", password=""),
    pdu_port=_ru1_pdu_port,
)

_ru2 = RU(
    ru_hw_group="AVQL",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.1.2", username="rfsw", password="f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0="
    ),
    lmp_connection=SshServiceDetails(addr="5.5.5.5", username="rfsw", password="f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0="),
    pdu_port=_ru2_pdu_port,
)

_du = DU(airscale=_airscale, rus=[_ru1, _ru2], f1_m_ip_addr="10.44.229.150")

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_ue_pdu = Gude(
    addr="10.44.177.237",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version='8221-1',
)

_ue_pdu_port = PduPort(pdu=_ue_pdu, port_no=5)

_quectel_4G_5G = TafUeAt(
    com_port='7',
    imei='867034040009624',
    capabilities=['_4G','_5G'],
    ue_pc_address='10.42.215.60',
    ue_pc_login='wro5gqt',
    ue_pc_password='5Gqtmoth',
    ue_pc_expected_prompt="wro5gqt@6022",
    data_transfer=[_data_transfer_iperf_WL],
    proxy_mngr_port=80, 
    ueproxy_force_release=False,
    class_name=PluginAtClassType.quectel,
    processes_to_kill=['Vysor'])

_quectel_4G_5G.ue_type = "quectel"

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    core=None,
    ues=[_quectel_4G_5G],
    tl_cloud_topology="3154",
)

tl.target_traffic_4G = {
    "MIN_DL": "48", #Mbits/sec
    "MIN_UL": "12", #Mbits/sec
    "MAX_DL": "60", #Mbits/sec
    "MAX_UL": "15", #Mbits/sec
    "IPERF_DURATION": "60", #seconds
    "cell_id_rf1": "13601036"
}
 
tl.target_traffic_5G = {
    "MIN_DL": "320", #Mbits/sec
    "MIN_UL": "40", #Mbits/sec
    "MAX_DL": "400", #Mbits/sec
    "MAX_UL": "50", #Mbits/sec
    "IPERF_DURATION": "180", #seconds
    "cell_id_rf2": "13601036"
}

tl.scf_variables = {
    "mrbts": "53129",
    "nrbts": "53129",
    "lnbts": "53129",
    "adjGnbId": "53129",
    "bbmod_1_prodcode": "475792A.102",
    "bbmod_2_prodcode": "475792A.102",
    "btsName": "QT-ASIL_ABIP_5G_NSA_TDD_4G_FDD-WRO-3154",
    "location": "WRO",
    "mcc": "450",
    "mnc": "05",
    "mncLength": "2",
    "cPlaneIpAddr": "10.44.229.254",               # x2c_ip address
    "phyCellId": "12",
    "tac": "7150",                                # 7150 for TL in West Link, 7171 for TL in GTB
    "earfcnDL": "1850",
    "earfcnUL": "19850",
    "nrCellId": "870465537",
    "ipAddrPrim": "10.44.201.68",            # TATRA NSA Realcore mme address
    "ntpServerIpAddrOrFqdnList": "10.42.248.70", # GTB NTP (IPv4) Time Server
    "masterIpAddr": "10.42.0.106",              # GTB PTP (IPv4) Time Server
    "physCellId": "69",
    "ln_pMax": "391",
    "nr_pMax": "200", #nie ustawione w Templatce
    "enb_x2_ip": "10.44.229.150",                # mplane_ip address
    "amfIPAddress": "0.0.0.0",
    "fiveGsTac": "7150",                          # For TLs in GTB

    #mplane
    "mplane_vlan": "674",
    "mplane_ip": "10.44.229.150",
    "mplane_ip_prefix": "26",
    "mplane_gw": "10.44.229.129",    
    #x2c
    "x2c_or_ngc_label": "x2c",
    "x2c_or_ngc_vlan": "676",
    "x2c_or_ngc_ip": "10.44.230.62",
    "x2c_or_ngc_ip_prefix": "26",
    "x2c_or_ngc_gw": "10.44.230.1",
    #x2u
    "x2u_or_ngu_label": "x2u",
    "x2u_or_ngu_vlan": "675",
    "x2u_or_ngu_ip": "10.44.229.254",
    "x2u_or_ngu_ip_prefix": "26",
    "x2u_or_ngu_gw": "10.44.229.193",
    #no s1u interface


}

__all__ = ["tl"]