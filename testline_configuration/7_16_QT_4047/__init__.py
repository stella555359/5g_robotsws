__maintainer__ = "QT WRO"
__team__ = "MN RAN RD T&V OTA&CI QT2"
__email__ = "I_5GQT_WRO@internal.nsn.com"

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
from taf.config.testline.core import EPCSim
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import PduPort, ATEN
from taf.config.testline.appserver import AppServer, TafUeAppServer
from taf.config.testline.attenuator import TopYoung

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.75.193",
        username="ute",
        password="UTE.debian12",
    )
)

_appserver_ssh = SshServiceDetails(
    addr="10.44.75.193", username="ute", password="UTE.debian12"
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
                                   expected_prompt="qt5g@wl-srn-server-1-idf34",
                                   )

_data_transfer_iperf = TafUeDataTransferProtocol(protocol_name="iperf",
                                                 app_server=_appserver_taf_ue,
                                                 interval=1)  # OPTIONAL

_snmp_user_data = dict(
    userName="administrator",
    authKey="password",
    privKey="password",
    authProtocol="SHA1",
    privProtocol="AES-128",
)

_cu = CU(
    backhaul_site_oam_ip="10.44.80.12",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.80.12", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.80.12", username="Nemuadmin", password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="10.44.80.12", username="toor4nsn", password="oZPS0POrRieRtu"
)

_du_capacity_unit = CapacityUnit(addr="6.6.6.6")

_du_pdu = ATEN(
    addr="10.42.61.173", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8]
)

_du_pdu_port = PduPort(pdu=_du_pdu, port_no=4)

_du_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[_du_capacity_unit],
    pdu_port=_du_pdu_port,
)

_airscale = Airscale(common_units=[_du_common_unit])

_ru_pdu = ATEN(addr="10.42.61.173", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])

_ru_pdu_port = PduPort(pdu=_ru_pdu, port_no=7)

_ru = RU(
    ru_hw_group="AEHC",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.162", username="rfsw", password="bdS%ztWG3v7%SjreCVA79wTPb"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="root"
    ),
    pdu_port=_ru_pdu_port,
)

_du = DU(airscale=_airscale, rus=[_ru], f1_m_ip_addr="10.44.80.12")

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_epcsim = EPCSim(
    mme_ip="10.45.168.53",
    mcc=540,
    mnc=1,
    tac=7151,
    default_ssh_connection_details=SshServiceDetails(
        addr="10.45.168.53", username="qt5g", password="5Gqtmoth!"
    ),
    dir_path="/home/ute/Robot_LteEmu",
    cfg_filename="Robot_LteEmu_Config",
)

_android = TafUeAndroid(
    serial_number="HZQN1876AAKA1500043",
    ssh_connection_details=SshServiceDetails(
        addr="10.42.22.140", username="wro5gqt", password="5Gqtmoth"
    ),
    capabilities=['_5G'],
    ue_pc_address="10.42.22.140",
    data_transfer=[_data_transfer_iperf],
    proxy_mngr_port=80,
    # ueproxy manager will not be visible unless proxy_mngr_port is configured! (default value: 9955 - used in autostart)
    ueproxy_force_release=False,
    imsi="android",
    qualcomm_prototype=False,
    voice_call_dialing_timeout="30",
    network_mode_switch_method="secretcode",
    airplane_mode_switcher_text="Airplane mode",
)

_android.ue_type = "android"

_attenuator = TopYoung(
    ip_addr="10.42.61.249",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24],
    model="TAS_24T24_02G6_90_1S_EJS",
)

tl = TestLine(
    test_pc=_test_pc,
    ues=[_android],
    gnbs=[_cbts],
    core=_epcsim,
    appserver=_appserver,
    attenuators=[_attenuator],
    tl_cloud_topology="4047",
)

tl.target_traffic_5G = {
    "IPERF_DURATION": "180",  # seconds
    "MIN_DL": "320", #Mbits/sec
    "MAX_DL": "400", #Mbits/sec
    "MIN_UL": "32", #Mbits/sec
    "MAX_UL": "40", #Mbits/sec
    "cell_id_rf1": "849857"
}

tl.attenuation = {
    "attenuation_port": "3001",
    "attenuation_5G": {7: 20, 8: 25},
    "attenuation_index": {"att": 0},
    "pdu_model": "ATEN",
    "pdu_attenuator_ip": "10.44.205.7",
    "pdu_attenuator_port": "2",
}

tl.custom = {
    "real_enb": "False",  # True if TL connected to LTE eNB
    "standalone": "True",  # True if SA, False for NSA
    "has_real_core": "True",  # True if TL using realcore
}

tl.scf_variables = {
    "mrbts": "53116",
    "bbmod_1_prodcode": "474020A.102",
    "btsName": "QT-ASIK_ABIL_5G_SA_TDD-WRO-4047",
    "location": "WRO",
    "secondEndpointPortId": "1",
    "mcc": "1",
    "mnc": "1",
    "mncLength": "2",
    "nr_pmax": "360",
    "pMaxNROwnCell": "26",
    "physCellId": "50",
    "pMaxEutra": "23",
    "fiveGsTac": "7151",
    "x2c_or_xnc_label": "ngc",
    "x2u_or_xnu_label": "ngu",
    "mplane_vlan": "459",
    "x2c_or_xnc_vlan": "460",
    "x2u_or_xnu_vlan": "461",
    "s1u_or_ngu_vlan": "462",
    "ntpServer_ip": "10.42.248.70",
    "masterIpAddr": "10.42.0.106",
    "amfIPAddress": "10.27.28.136",
    "mplane_ip": "10.44.80.12",
    "mplane_ip_prefix": "26",
    "x2c_or_xnc_ip": "10.44.80.72",
    "x2c_or_xnc_ip_prefix": "26",
    "x2u_or_xnu_ip": "10.44.65.246",
    "x2u_or_xnu_ip_prefix": "26",
    "s1u_or_ngu_ip": "10.44.66.54",
    "s1u_or_ngu_ip_prefix": "26",
    "mplane_gw": "10.44.80.1",
    "x2c_or_xnc_gw": "10.44.80.65",
    "x2u_or_xnu_gw": "10.44.65.193",
    "s1u_or_ngu_gw": "10.44.66.1",
}

tl.android_config_dir = os.path.dirname(os.path.abspath(__file__))

__all__ = ["tl"]
