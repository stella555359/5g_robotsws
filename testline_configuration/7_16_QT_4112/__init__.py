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
from taf.config.testline.enb import RealEnb
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale, CommonUnit
from taf.config.testline.pdu import PduPort, Gude
from taf.config.testline.appserver import AppServer
from taf.config.testline.core import EPCSim
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
        addr="10.42.158.228", username="ute", password="UTE.debian12"
    )
)

_appserver_ssh = SshServiceDetails(
    addr="10.42.158.228", username="ute", password="UTE.debian12"
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
                                                 interval=1,
                                                 version=2,
                                                 interface_name='ASKEY_4112',
                                                 dt_from_uepc=True)

_cu = CU(
    backhaul_site_oam_ip="10.44.229.170",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.229.170", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.229.170", username="Nemuadmin", password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="10.44.229.170", username="toor4nsn", password="oZPS0POrRieRtu"
)

_du_pdu = Gude(
    addr="10.44.177.110",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
    snmp_user=_snmp_user_data)

_du_pdu_port = PduPort(pdu=_du_pdu, port_no=3)

_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[None],
    pdu_port=_du_pdu_port,
)

_airscale = Airscale(common_units=[_common_unit])

_ru1_pdu = Gude(
    addr="10.44.177.159",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
    snmp_user=_snmp_user_data)

_ru2_pdu = Gude(
    addr="10.44.177.125",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
    snmp_user=_snmp_user_data)

_ru1 = RU(
    ru_hw_group="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="5.5.5.5", username="root", password=""),
    pdu_port=PduPort(pdu=_ru1_pdu, port_no=9),
)
_ru2 = RU(
    ru_hw_group="AHFIB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="5.5.5.5", username="root", password=""),
    pdu_port=PduPort(pdu=_ru2_pdu, port_no=2),
)

_du = DU(airscale=_airscale, rus=[_ru1, _ru2], f1_m_ip_addr="10.44.229.170")

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_epcsim = EPCSim(
    mme_ip="10.45.168.53",
    mcc=310,
    mnc=260,
    tac=7150,
    default_ssh_connection_details=SshServiceDetails(
        addr="10.45.168.53", username="qt5g", password="5Gqtmoth!"
    ),
    dir_path="",
    cfg_filename="",
)

_askey = TafUeAt(com_port='7',
                 serial_number="44caa181",
                 capabilities=['_4G', '_5G'],
                 ue_pc_address='10.42.224.81',
                 ue_pc_login='wro5gqt',
                 ue_pc_password='5Gqtmoth',
                 proxy_mngr_port='80',
                 ueproxy_force_release=False,
                 ue_pc_expected_prompt='wro5gqt@PLWR5G5685',
                 data_transfer=[_data_transfer_iperf])

_askey.ue_type = "askey"

_attenuator = TopYoung(
    ip_addr="10.42.83.5",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24],
    model="TAS_24T24_02G6_90_1C_EJS",
)

tl = TestLine(
    test_pc=_test_pc,
    ues=[_askey],
    gnbs=[_cbts],
    core=_epcsim,
    appserver=_appserver,
    attenuators=[_attenuator],
    tl_cloud_topology="4112",
)

tl.target_traffic_5G = {
    "IPERF_DURATION": "70",  # seconds
    "MIN_DL": "160",  # Mbits/sec
    "MAX_DL": "200",  # Mbits/sec
    "MIN_UL": "40",  # Mbits/sec
    "MAX_UL": "50",  # Mbits/sec
    "cell_id_rf2": "13581825"
}

tl.target_traffic_4G = {
    "IPERF_DURATION": "70",  # seconds
    "MIN_DL": "64",  # Mbits/sec
    "MAX_DL": "80",  # Mbits/sec
    "MIN_UL": "16",  # Mbits/sec
    "MAX_UL": "20",  # Mbits/sec
    "cell_id_rf1": "13581825"
}

tl.attenuation = {
    "attenuation_port": "3001",
    "attenuation_index": {"att": 0},
    "attenuation_4G": {7: 90, 8: 90},
    "attenuation_5G": {7: 0, 8: 0},
    "pdu_model": "Gude",
    "pdu_attenuator_version": "8220-1",
    "pdu_attenuator_ip": "10.44.177.117",
    "pdu_attenuator_port": "12",
}


tl.custom = {
    "real_enb": "True",        # True if TL connected to LTE eNB
    "standalone": "False",      # True if SA, False for NSA
    "has_real_core": "True",    # True if TL not using EPCSim
    "FDD_concurrent": "True",
   # "askey_pdu_ip": "",
   # "askey_pdu_port": "",
}

tl.scf_variables = {
    "mrbts": "53054",
    "nrbts": "53054",
    "btsName": "QT-ASIB_ABIO_5G_NSA_4G_FDD-WRO-4112",#Old WRO-4015
    "location": "WRO_WL_L4_05_Rack_2532",
    "mcc": "555",
    "mnc": "10",
    "mncLength": "2",
    "cPlaneIpAddr": "10.44.229.233",               # x2c_ip address
    "phyCellId": "127",
    "tac": "7150",                                # 7150 for TL in West Link, 7171 for TL in GTB
    "earfcnDL": "900",
    "earfcnUL": "18900",
    "nrCellId": "869236737",
    "ipAddrPrim": "10.44.201.68",             # TATRA NSA Realcore mme address
    "syncInputType_prio1": "1pps/ToD from external GNSS receiver",
    "syncInputType_prio2": "TOPF",
    "ntpServerIpAddrOrFqdnList": "10.42.248.70", # WG NTP (IPv4) Time Server
    "masterIpAddr": "10.42.0.106",                # West Link PTP (IPv4) Time Server
    "physCellId": "12",
    "nrx2link_257": "10.44.229.170",               # mplane_ip address
    "amfIPAddress": "0.0.0.0",
    "fiveGsTac": "7150",                          # TATRA NSA TAC
    "connectorLabel": "EIF1",
    #mplane
    "mplane_vlan": "674",
    "mplane_ip": "10.44.229.170",
    "mplane_ip_prefix": "26",
    "mplane_gw": "10.44.229.129",
    #x2c
    "x2c_or_ngc_label": "x2c",
    "x2c_or_ngc_vlan": "675",
    "x2c_or_ngc_ip": "10.44.229.233",
    "x2c_or_ngc_ip_prefix": "26",
    "x2c_or_ngc_gw": "10.44.229.193",
    #x2u
    "x2u_or_ngu_label": "x2u",
    "x2u_or_ngu_vlan": "676",
    "x2u_or_ngu_ip": "10.44.230.41",
    "x2u_or_ngu_ip_prefix": "26",
    "x2u_or_ngu_gw": "10.44.230.1",
    #s1u
    "s1u_or_ngu_vlan": "677",
    "s1u_or_ngu_ip": "10.44.230.96",
    "s1u_or_ngu_ip_prefix": "26",
    "s1u_or_ngu_gw": "10.44.230.65",
}

tl.android_config_dir = os.path.dirname(os.path.abspath(__file__))

__all__ = ["tl"]