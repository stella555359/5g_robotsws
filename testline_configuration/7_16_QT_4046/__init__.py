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
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.airscale import Airscale, CommonUnit
from taf.config.testline.pdu import PduPort, ATEN
from taf.config.testline.appserver import AppServer, TafUeAppServer
from taf.config.testline.attenuator import TopYoung

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.75.127", username="ute", password="UTE.debian12"
    )
)

#########appserver##########
_appserver_ssh = SshServiceDetails(
    addr="10.44.75.127", username="ute", password="UTE.debian12"
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
                                                 interval=1,
                                                 server_close_delay=50)                                 #OPTIONAL

_cu = CU(
    backhaul_site_oam_ip="10.44.80.41",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.80.41", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.80.41", username="Nemuadmin", password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="10.44.80.41", username="toor4nsn", password="oZPS0POrRieRtu"
)

_du_pdu = ATEN(addr="10.44.206.42", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9])

_du_pdu_port = PduPort(pdu=_du_pdu, port_no=2)

_du_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[None],
    pdu_port=_du_pdu_port,
)

_airscale = Airscale(common_units=[_du_common_unit])

_ru_pdu1 = ATEN(addr="10.42.61.176", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9])
_ru_pdu2 = ATEN(addr="10.44.205.7", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9])

_ru1 = RU(
    ru_hw_group="AZQP",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.9.2", username="rfsw", password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ="
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.102.1",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    pdu_port=PduPort(pdu=_ru_pdu1, port_no=6),
)
_ru2 = RU(
    ru_hw_group="AZNA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.102.1",
        username="root",
        password="",
    ),
    pdu_port=PduPort(pdu=_ru_pdu2, port_no=1),
)

_du = DU(airscale=_airscale, rus=[_ru1, _ru2], f1_m_ip_addr="10.44.80.41")

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_android = TafUeAndroid(
    serial_number="ed3f92c0",
    ssh_connection_details=SshServiceDetails(
        addr="10.42.22.140", username="wro5gqt", password="5Gqtmoth"
    ),
    capabilities=['_4G','_5G'],
    ue_pc_address="10.42.22.140",
    data_transfer=[_data_transfer_iperf],
    proxy_mngr_port=80,  # ueproxy manager will not be visible unless proxy_mngr_port is configured! (default value: 9955 - used in autostart)
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
    gnbs=[_cbts],
    ues=[_android],
    appserver=_appserver,
    attenuators=[_attenuator],
    tl_cloud_topology="4046",
)

tl.target_traffic_5G = {
    "IPERF_DURATION": "70", #seconds
    "MIN_DL": "160",  # Mbits/sec
    "MAX_DL": "200",  # Mbits/sec
    "MIN_UL": "32",  # Mbits/sec
    "MAX_UL": "40",  # Mbits/sec
    "cell_id_rf1": "13583361"
}

tl.target_traffic_4G = {
    "IPERF_DURATION": "70", #seconds
    "MIN_DL": "48",  # Mbits/sec
    "MAX_DL": "60",  # Mbits/sec
    "MIN_UL": "12",  # Mbits/sec
    "MAX_UL": "15",  # Mbits/sec
    "cell_id_rf1": "13583363"
}

tl.attenuation = {
    "attenuation_port": "3001",
    "attenuation_4G": {5:40, 6:40, 4:90},
    "attenuation_5G": {5:40, 6:40, 4:0},
    "attenuation_index": {"att":0},
    "pdu_model": "ATEN",
    "pdu_attenuator_ip": "10.44.205.7",
    "pdu_attenuator_port": "2",
}

tl.custom = {
    "real_enb": "False",         # True if 5G NSA TL is connected to LTE eNB
    "standalone": "False",       # True if SA, False for NSA
    "has_real_core": "True",     # True if TL using realcore
    "TDD_concurrent": "True",
}

tl.scf_variables = {
    "mrbts": "53060",
    "btsName": "QT-ASIL_ABIO_5G_NSA_4G_TDD-WRO-4046",
    "location": "WRO",
    "bbmod_1_prodcode": "475266A.102",
    "bbmod_2_prodcode": "475266A.102",
    "secondEndpointPortId": "1",
    "X2Cplane_DN1_IPIF_id": "2",
    "cPlane_DN1_IPIF_id": "1",
    "uPlane_DN1_IPIF_id": "3",
    "mcc": "555",
    "mnc": "10",
    "mncLength": "2",
    "pmax": "373",
    "nr_pmax": "390",
    "pMaxOwnCell": "26",
    "pMaxNROwnCell": "26",
    "tac": "7150",
    "nrCellId": "869335073",
    "earfcn_1": "39100",
    "earfcn_2": "39400",
    "earfcn_3": "42290",
    "phyCellId_1": "121",
    "phyCellId_2": "123",
    "phyCellId_3": "128",
    "physCellId": "12",
    "lncel": "549",
    "masterIpAddr": "10.42.0.106",
    "cPlaneIpAddr": "10.44.80.102",
    "ipAddrPrim": "10.44.201.68",
    "enb_x2_ip": "10.44.80.41",
    "x2c_or_xnc_label": "x2c",
    "x2u_or_xnu_label": "x2u",
    "mplane_vlan": "459",
    "x2c_or_xnc_vlan": "460",
    "x2u_or_xnu_vlan": "461",
    "s1u_or_ngu_vlan": "462",
    "mplane_ip": "10.44.80.41",
    "mplane_ip_prefix": "26",
    "x2c_or_xnc_ip": "10.44.80.102",
    "x2c_or_xnc_ip_prefix": "26",
    "x2u_or_xnu_ip": "10.44.65.211",
    "x2u_or_xnu_ip_prefix": "26",
    "s1u_or_ngu_ip": "10.44.66.15",
    "s1u_or_ngu_ip_prefix": "26",
    "mplane_gw": "10.44.80.1",
    "x2c_or_xnc_gw": "10.44.80.65",
    "x2u_or_xnu_gw": "10.44.65.193",
    "s1u_or_ngu_gw": "10.44.66.1",
}


tl.android_config_dir = os.path.dirname(os.path.abspath(__file__))

__all__ = ["tl"]