__maintainer__ = "QT WRO"
__team__ = "MN RAN RD T&V OTA&CI QT2"
__email__ = "I_5GQT_WRO@internal.nsn.com"
__owner_email__ = "I_5GQT_WRO@internal.nsn.com"


import os

from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
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
from taf.config.testline.core import EPCSim
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale, CommonUnit
from taf.config.testline.pdu import PduPort, Gude
from taf.config.testline.appserver import AppServer
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
        addr="10.44.180.161", username="ute", password="UTE.debian12"
    )
)

_appserver_ssh = SshServiceDetails(
    addr="10.44.180.161", username="ute", password="UTE.debian12"
)

_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.42.197.170",
)

_appserver = AppServer(_iperf_details_on_appserver)

_appserver_taf_ue_WL = TafUeAppServer(app_server_name="wl-srn-server-2-idf34",
                                   address="10.42.197.170",
                                   user="qt5g",
                                   password="5Gqtmoth!",
                                   bind_interface_ip="10.42.197.170",
                                   expected_prompt="qt5g@wl-srn-server-2-idf34")

_data_transfer_iperf_WL = TafUeDataTransferProtocol(protocol_name="iperf",
                                                app_server=_appserver_taf_ue_WL,
                                                interval=1,
                                                dt_from_uepc=True,
                                                binary_path="~/.iperf/",
                                                version=2,
                                                interface_name="wwan0",                     #name of the Quectel network interface
)

_cu = CU(
    backhaul_site_oam_ip="10.44.65.96",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.229.168", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.229.168", username="Nemuadmin", password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="10.44.229.168", username="toor4nsn", password="oZPS0POrRieRtu"
)

_du_pdu = Gude(
    addr="10.44.177.111",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data)

_du_pdu_port = PduPort(pdu=_du_pdu, port_no=2)

_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[None],
    pdu_port=_du_pdu_port,
)

_airscale = Airscale(common_units=[_common_unit])

_ru_pdu = Gude(
    addr="10.44.117.126",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data)

_ru1 = RU(
    ru_hw_group="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="5.5.5.5", username="root", password=""),
    pdu_port=PduPort(pdu=_ru_pdu, port_no=4),
)
_ru2 = RU(
    ru_hw_group="AHFIB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="5.5.5.5", username="root", password=""),
    pdu_port=PduPort(pdu=_ru_pdu, port_no=3),
)

_du = DU(airscale=_airscale, rus=[_ru1, _ru2], f1_m_ip_addr="10.44.229.168")

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_epcsim = EPCSim(
    mme_ip="10.42.197.170",
    mcc=310,
    mnc=260,
    tac=7150,
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.197.170", username="qt5g", password="5Gqtmoth!"
    ),
    dir_path="",
    cfg_filename="",
)

_quectel_4G_5G = TafUeAt(
    serial_number="867034040009681", #or IMEI in SimCom Quectel UE
    ue_pc_address='10.42.224.113',
    ue_pc_port="80",
    capabilities=['_4G','_5G'],
    data_transfer=[_data_transfer_iperf_WL],
    ue_pc_expected_prompt="wro5gqt@plwrnl5jtxfa8",
    com_port="ttyUSB2",
    ue_pc_login='wro5gqt',
    ue_pc_password='5Gqtmoth123$',
    proxy_mngr_port=5000,
    class_name=PluginAtClassType.quectel)

_quectel_4G_5G.ue_type = "quectel"

tl = TestLine(
    test_pc=_test_pc,
    ues=[_quectel_4G_5G],
    gnbs=[_cbts],
    core=_epcsim,
    appserver=_appserver,
    tl_cloud_topology="4110",
)

tl.target_traffic_5G = {
    "IPERF_DURATION": "70",  # seconds
    "MIN_DL": "160",  # Mbits/sec
    "MAX_DL": "200",  # Mbits/sec
    "MIN_UL": "40",  # Mbits/sec
    "MAX_UL": "50",  # Mbits/sec
    "cell_id_rf2": "13581057"
}

tl.target_traffic_4G = {
    "IPERF_DURATION": "70",  # seconds
    "MIN_DL": "64",  # Mbits/sec
    "MAX_DL": "80",  # Mbits/sec
    "MIN_UL": "16",  # Mbits/sec
    "MAX_UL": "20",  # Mbits/sec
    "cell_id_rf1": "13581057"
}

tl.custom = {
    "real_enb": "True",        # True if TL connected to LTE eNB
    "standalone": "False",      # True if SA, False for NSA
    "has_real_core": "True",    # True if TL not using EPCSim
   # "askey_pdu_ip": "",
   # "askey_pdu_port": "",
}

tl.scf_variables = {
    "mrbts": "53051",
    "nrbts": "53051",
    "btsName": "QT-ASIB_ABIO_5G_NSA_4G_FDD-WRO-4110",#Old WRO-4009
    "location": "WRO_WL_L4_05_Rack_2532",
    "mcc": "555",
    "mnc": "10",
    "mncLength": "2",
    "cPlaneIpAddr": "10.44.229.231",               # x2c_ip address
    "phyCellId": "127",
    "tac": "7150",                                # 7150 for TL in West Link, 7171 for TL in GTB
    "earfcnDL": "900",
    "earfcnUL": "18900",
    "nrCellId": "869187585",
    "ipAddrPrim": "10.44.201.68",             # TATRA NSA Realcore mme address
    "syncInputType_prio1": "1pps/ToD from external GNSS receiver",
    "syncInputType_prio2": "TOPF",
    "ntpServerIpAddrOrFqdnList": "10.42.248.70", # WG NTP (IPv4) Time Server
    "masterIpAddr": "10.42.0.106",                # West Link PTP (IPv4) Time Server
    "physCellId": "12",
    "nrx2link_257": "10.44.229.168",               # mplane_ip address
    "amfIPAddress": "0.0.0.0",
    "fiveGsTac": "7150",                          # TATRA NSA TAC
    "connectorLabel": "EIF1",
    #mplane
    "mplane_vlan": "674",
    "mplane_ip": "10.44.229.168",
    "mplane_ip_prefix": "26",
    "mplane_gw": "10.44.229.129",
    #x2c
    "x2c_or_ngc_label": "x2c",
    "x2c_or_ngc_vlan": "675",
    "x2c_or_ngc_ip": "10.44.229.231",
    "x2c_or_ngc_ip_prefix": "26",
    "x2c_or_ngc_gw": "10.44.229.193",
    #x2u
    "x2u_or_ngu_label": "x2u",
    "x2u_or_ngu_vlan": "676",
    "x2u_or_ngu_ip": "10.44.230.39",
    "x2u_or_ngu_ip_prefix": "26",
    "x2u_or_ngu_gw": "10.44.230.1",
    #s1u
    "s1u_or_ngu_vlan": "677",
    "s1u_or_ngu_ip": "10.44.230.94",
    "s1u_or_ngu_ip_prefix": "26",
    "s1u_or_ngu_gw": "10.44.230.65",
}

tl.android_config_dir = os.path.dirname(os.path.abspath(__file__))

__all__ = ["tl"]
