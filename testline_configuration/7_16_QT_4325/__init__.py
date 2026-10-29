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
    IperfDataTransferDetails,)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RU
from taf.config.testline.core import EPCSim
from taf.config.testline.airscale import Airscale, CommonUnit
from taf.config.testline.pdu import PduPort, ATEN, Gude
from taf.config.testline.appserver import AppServer
from taf.config.testline.enb import RealEnb
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
        addr="10.44.75.3",
        username="ute",
        password="UTE.debian12")
)

_appserver_ssh = SshServiceDetails(
    addr="10.44.75.3",
    username="ute",
    password="UTE.debian12"
)

_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.45.168.53"
)

_appserver = AppServer(_iperf_details_on_appserver)

_appserver_taf_ue = TafUeAppServer(
    app_server_name="APP_TAF_UE",
    address="10.45.168.53",
    user="qt5g",
    password="5Gqtmoth!",
    bind_interface_ip="10.45.168.53",
    expected_prompt="qt5g@wl-srn-server-1-idf34",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_taf_ue,
    interval=1,
    version=2,
    interface_name='ASKEY_4325',
    dt_from_uepc=True,
)

_cu = CU(
    backhaul_site_oam_ip="10.44.88.184",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.88.184",
        username="robot",
        password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.88.184",
        username="Nemuadmin",
        password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="10.44.88.184",
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
    pdu_port=_common_unit_pdu.pdu_ports[10],
)

_airscale = Airscale(common_units=[_common_unit])

_5g_ru_pdu = ATEN(
    addr="10.44.206.125",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8]
)

_ru = RU(
    ru_hw_group="AVQL",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.154",
        username="root",
        password="HfBKgqIOogKY3BlGtiniuCI9bs76C8jYsAY6vw8f/Tw="
    ),
    lmp_connection=SshServiceDetails(
        addr="5.5.5.5",
        username="root",
        password="HfBKgqIOogKY3BlGtiniuCI9bs76C8jYsAY6vw8f/Tw="
    ),
    pdu_port=_5g_ru_pdu.pdu_ports[5],
)

_du = DU(
    airscale=_airscale,
    rus=[_ru],
    f1_m_ip_addr="10.44.88.184"
)

_cbts = ClassicalBts(
    cu=_cu,
    dus=[_du]
)

_askey = TafUeAt(com_port='4',
                 serial_number="ce887d24",
                 capabilities=['_5G'],
                 ue_pc_address='10.44.72.88',
                 ue_pc_login='wro5gqt',
                 ue_pc_password='5Gqtmoth',
                 proxy_mngr_port='80',
                 ueproxy_force_release=False,
                 ue_pc_expected_prompt='wro5gqt@PLWR5G5457',
                 data_transfer=[_data_transfer_iperf]
)

_askey.ue_type = "askey"

_attenuator = TopYoung(
    ip_addr="10.42.61.129",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24],
    model="TAS_24T24_04G6_90_1S_EJS",
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    core=None,
    ues=[_askey],
    appserver=_appserver,
    attenuators=[_attenuator],
    tl_cloud_topology="4325",
)

tl.target_traffic_5G = {
    "IPERF_DURATION": "180",  # seconds
    "MIN_DL": "320",  # Mbits/sec
    "MAX_UL": "50",  # Mbits/sec
    "MIN_UL": "40",  # Mbits/sec
    "MAX_DL": "400",  # Mbits/sec
    "cell_id_rf1": "869416961"
}

tl.attenuation = {
    "attenuation_port": "3001",
    "attenuation_5G": {22:5},
    "attenuation_index": {"att":0},
    "pdu_model": "ATEN",
    "pdu_attenuator_ip": "10.44.206.125",
    "pdu_attenuator_port": "8",
}

tl.custom = {
    "real_enb": "False",  # True if 5G NSA TL is connected to LTE eNB
    "standalone": "True",  # True if SA, False for NSA
    "has_real_core": "True",  # True if TL using realcore
    "askey_pdu_ip": "10.42.61.177",
    "askey_pdu_port": "5"
}

tl.scf_variables = {
    "mrbts": "53065",
    "nrbts": "53065",
    "btsName": "QT-ASOE_5G_SA_TDD-WRO-4325", #old 4037
    "location": "WRO",
    "ntpServerIpAddrOrFqdnList": "10.42.248.70",
    "masterIpAddr": "10.42.0.106",
    "timeZone": "(GMT+1) Europe/Warsaw",
    "mcc": "310",
    "mnc": "260",
    "mncLength": "3",
    "nr_pmax": "350",
    "pMaxNROwnCell": "33",
    "fiveGsTac": "7151",

	#mplane
    "mplane_ip": "10.44.88.184",
    "mplane_ip_prefix": "26",
    "mplane_gw": "10.44.88.129",	
	"mplane_vlan": "480",

    #x2c
    "x2c_or_xnc_ip": "10.44.88.248",
    "x2c_or_xnc_ip_prefix": "26",
    "x2c_or_xnc_gw": "10.44.88.193",	
    "x2c_or_xnc_vlan": "481",

    #x2u
    "x2u_or_xnu_ip": "10.44.89.60",
    "x2u_or_xnu_ip_prefix": "26",
    "x2u_or_xnu_gw": "10.44.89.1",
    "x2u_or_xnu_vlan": "482",

    #s1u
    "s1u_or_ngu_ip": "10.44.89.97",
    "s1u_or_ngu_ip_prefix": "26",
    "s1u_or_ngu_gw": "10.44.89.65",
    "s1u_or_ngu_vlan": "483",

    "connectorLabel": "S-RF7",
}

tl.android_config_dir = os.path.dirname(os.path.abspath(__file__))

__all__ = ["tl"]