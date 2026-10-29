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
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale, CommonUnit
from taf.config.testline.ue import Android, TafUeAndroid
from taf.config.testline.pdu import PduPort, Gude
from taf.config.testline.appserver import AppServer
from taf.config.testline.attenuator import TopYoung
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.ue import TafUeAt

_snmp_user_data = dict(
    userName="administrator",
    authKey="password",
    privKey="password",
    authProtocol="SHA1",
    privProtocol="AES-128",
) 

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.194.121", username="ute", password="UTE.debian12"
    )
)  

_appserver_ssh = SshServiceDetails(
    addr="10.42.194.121", username="ute", password="UTE.debian12"
)

_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.45.168.53",
)

_appserver = AppServer(_iperf_details_on_appserver)

_appserver_taf_ue = TafUeAppServer(app_server_name="APP_TAF_UE",
    address="10.45.168.53",
    user="qt5g",
    password="5Gqtmoth!",
    bind_interface_ip="10.45.168.53",
    expected_prompt="qt5g@wl-srn-server-1-idf34")


_data_transfer_iperf = TafUeDataTransferProtocol(protocol_name="iperf",
                                                 app_server=_appserver_taf_ue,
                                                 interval=1
                                                 )


_cu = CU(
    backhaul_site_oam_ip="10.44.229.140",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.229.140", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.229.140", username="Nemuadmin", password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="10.44.229.140", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_pdu = Gude(
    addr="10.44.177.110", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8221-1", snmp_user=_snmp_user_data
)

_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[None],
    pdu_port=_common_unit_pdu.pdu_ports[11],
)

_airscale = Airscale(common_units=[_common_unit])


_5g_ru_pdu = Gude(
    addr="10.44.177.125", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8221-1", snmp_user=_snmp_user_data
)

_ru1 = RU(
    ru_hw_group="AHCA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.130", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="5.5.5.5", username="root", password=""),
    pdu_port=_5g_ru_pdu.pdu_ports[8],
)

_ru2 = RU(
    ru_hw_group="AHCA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="5.5.5.5", username="root", password=""),
    pdu_port=_5g_ru_pdu.pdu_ports[9],
)

_ru3 = RU(
    ru_hw_group="AHCA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="5.5.5.5", username="root", password=""),
    pdu_port=_5g_ru_pdu.pdu_ports[10],
)

_du = DU(airscale=_airscale, rus=[_ru1, _ru2, _ru3], f1_m_ip_addr="10.44.229.140")

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_android = TafUeAndroid(
    serial_number="HZQN1876AAKA2000584",
    capabilities=["_5G"],
    ue_pc_address="10.44.72.92",
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.44.72.92", username="wro5gqt", password="5Gqtmoth"
    ),
    proxy_mngr_port=80,
    ueproxy_force_release=False,
    imsi="android",
    qualcomm_prototype=False,
    voice_call_dialing_timeout="30",
    network_mode_switch_method="secretcode",
    airplane_mode_switcher_text="Aeroplane mode",
)

_android.ue_type = "android"

_attenuator = TopYoung(
    ip_addr="10.42.83.5",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24],
    model="TAS_24T24_02G6_90_1C_EJS",
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    ues=[_android],
    appserver=_appserver,
    attenuators=[_attenuator],
    tl_cloud_topology="4201",
)

tl.target_traffic_5G = {
    "IPERF_DURATION": "70", #seconds
    "MIN_DL": "80", #Mbits/sec
    "MAX_DL": "100", #Mbits/sec
    "MIN_UL": "40", #Mbits/sec
    "MAX_UL": "50", #Mbits/sec
    "cell_id_rf1": "849730",
    "cell_id_rf2": "849729",
    "cell_id_rf3": "849731",
}

tl.attenuation = {
    "attenuation_port": "3001",
    "attenuation_index": {"rf1":0, "rf2":0, "rf3":0},
    "attenuation_rf1": {1:0, 2:0},
    "attenuation_rf2": {3:0, 4:0},
    "attenuation_rf3": {5:0, 6:0},
    "pdu_model": "Gude",
    "pdu_attenuator_version": "8220-1",
    "pdu_attenuator_ip": "10.44.177.117",
    "pdu_attenuator_rf1_port": "12",
    "pdu_attenuator_rf2_port": "12",
    "pdu_attenuator_rf3_port": "12",
}

tl.custom = {
    "real_enb": "False",  # True if 5G NSA TL is connected to LTE eNB
    "standalone": "True",  # True if SA, False for NSA
    "has_real_core": "True",  # True if TL using realcore
    "askey_pdu_ip": "10.44.177.",
    "askey_pdu_port": "",
}

tl.android_config_dir = os.path.dirname(os.path.abspath(__file__))

tl.scf_variables = {
    "mrbts": "53108",
    "btsName": "QT-ASIK_ABIL_5G_SA_FDD-WRO-4201", #Old WRO-4041
    "location": "WRO_WL_L4_05_Rack_2532",
    "firstEndpointPortId_RMOD_1": "2",
    "firstEndpointPortId_RMOD_2": "1",
    "firstEndpointPortId_RMOD_3": "2",
    "secondEndpointPortId": "1",
    "ntpServerIpAddrOrFqdnList": "10.42.248.70",
    "masterIpAddr": "10.42.0.106",
    "mcc": "540",
    "mnc": "1",
    "mncLength": "2",
    "freqBandIndicatorNR": "5",
    "gscnOrSsPbchArfcn": "2204",
    "nr_pmax": "440",
    "pMaxNROwnCell": "29",
    "nrarfcnDl": "176500",
    "nrarfcnUl": "167500",
    "amfIPAddress": "10.27.28.136",
    "fiveGsTac": "7151",
    #mplane
    "mplane_vlan": "674",
    "mplane_ip": "10.44.229.140",
    "mplane_ip_prefix": "26",
    "mplane_gw": "10.44.229.129",
    #xnc
    "x2c_or_ngc_label": "x2c",
    "x2c_or_xnc_vlan": "675",
    "x2c_or_xnc_ip": "10.44.229.203",
    "x2c_or_xnc_ip_prefix": "26",
    "x2c_or_xnc_gw": "10.44.229.193",
    #xnu
    "x2u_or_ngu_label": "x2u",
    "x2u_or_xnu_vlan": "676",
    "x2u_or_xnu_ip": "10.44.230.11",
    "x2u_or_xnu_ip_prefix": "26",
    "x2u_or_xnu_gw": "10.44.230.1",
    #ngc
    "ngc_vlan": "679",
    "ngc_ip": "10.44.230.201",
    "ngc_ip_prefix": "26",
    "ngc_gw": "10.44.230.193",
}

__all__ = ["tl"]
