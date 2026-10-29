__maintainer__ = "QT WRO"
__team__ = "MN SRAN Trunk Eng WRO 8 SG"
__email__ = "I_AM_QT@internal.nsn.com"
__owner_email__ = "I_AM_QT@internal.nsn.com"

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
from taf.config.testline.core import EPCSim
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import PduPort, Gude, ATEN
from taf.config.testline.appserver import AppServer, TafUeAppServer


_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.29.52", username="ute", password="ut3pa5s#1d8f",
    )
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.29.54",
        username="ute",
        password="ut3pa5s#1d8f",
    )
)

_appserver_ssh = SshServiceDetails(
    addr="10.5.29.52", username="ute", password="ut3pa5s#1d8f"
)

_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.9.146.30",
)

_appserver = AppServer(_iperf_details_on_appserver)

_appserver_taf_ue_1 = TafUeAppServer(app_server_name="APP_TAF_UE",
    address="10.9.146.30",
    user="iperf_user",
    password="Treperf",
    expected_prompt="iperf_user@srnbackup1")

_data_transfer_iperf_1 = TafUeDataTransferProtocol(protocol_name="iperf",
                                                 app_server=_appserver_taf_ue_1,
                                                 interval=1)                                 #OPTIONAL

_appserver_taf_ue_2 = TafUeAppServer(app_server_name="APP_TAF_UE",
    address="10.5.26.74",
    user="ftp2_user1",
    password="Aikon_123456",
    bind_interface_ip="10.5.26.74",
    expected_prompt="ftp2_user1@rotmftpserver02")

_data_transfer_iperf_2 = TafUeDataTransferProtocol(protocol_name="iperf",
                                                 app_server=_appserver_taf_ue_2,
                                                 interval=1)   

_cu = CU(
    backhaul_site_oam_ip="10.15.236.75",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.15.236.75", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.15.236.75", username="Nemuadmin", password="nemuuser"

    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="10.15.236.75", username="toor4nsn", password="oZPS0POrRieRtu"
)

_du_pdu = Gude(
    addr="10.255.1.52",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
)

_du_pdu_port = PduPort(pdu=_du_pdu, port_no=1),

_du_common_unit0 = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[None],
    pdu_port=_du_pdu.pdu_ports[1],
)

_du_common_unit1 = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[None],
    pdu_port=_du_pdu.pdu_ports[2],
)

_airscale = Airscale(common_units=[_du_common_unit0, _du_common_unit1])

_ru_pdu = Gude(
    addr="10.255.1.51",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
)

_ru_pdu_port0 = PduPort(pdu=_ru_pdu, port_no=7)
_ru_pdu_port1 = PduPort(pdu=_ru_pdu, port_no=12)

_ru0 = RU(
    ru_hw_group="FXJB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="5.5.5.5", username="root", password=""),
    pdu_port=_ru_pdu_port0,
)


_ru1 = RU(
    ru_hw_group="AHEGA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="5.5.5.5", username="root", password=""),
    pdu_port=_ru_pdu_port1,
)

_du = DU(airscale=_airscale, rus=[_ru0, _ru1], f1_m_ip_addr="10.15.236.75")

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_epcsim = EPCSim(
    mme_ip="10.9.146.30",
    mcc=310,
    mnc=260,
    tac=7151,
    default_ssh_connection_details=SshServiceDetails(
        addr="10.9.146.30", username="iperf_user", password="Treperf"
    ),
    dir_path="",
    cfg_filename="",
)

_lmp_connection = SshServiceDetails(
    addr="5.5.5.5", username="user5", password="password5"
)

_android_4G = TafUeAndroid(
    serial_number="R58W81A7KKV",
    capabilities=['_4G'],
    ue_pc_address="10.5.60.203",
    data_transfer=[_data_transfer_iperf_2],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.60.203", username="wro5gqt", password="5Gqtmoth"
    ),
    ueproxy_force_release=False,
    proxy_mngr_port=5000,
    ue_pc_port="5001",#If firewall blocks this port, change to 8080
    imsi="android",
    qualcomm_prototype=False,
    voice_call_dialing_timeout="30",
    network_mode_switch_method="secretcode",
    airplane_mode_switcher_text="Off|On",
)

_android_4G.ue_type = "android"

_android_3G = TafUeAndroid(
    serial_number="R58W81A6BSM",
    capabilities=['_3G'],
    ue_pc_address="10.5.60.203",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.60.203", username="wro5gqt", password="5Gqtmoth"
    ),
    ueproxy_force_release=False,
    proxy_mngr_port=5000,
    ue_pc_port="5001",#If firewall blocks this port, change to 8080
    imsi="android",
    qualcomm_prototype=False,
    voice_call_dialing_timeout="30",
    network_mode_switch_method="secretcode",
    airplane_mode_switcher_text="Off|On",
)

_android_3G.ue_type = "android"

_android_2G = TafUeAndroid(
    serial_number="R58W20JKA6V",
    capabilities=["_2G"],
    ue_pc_address="10.5.60.203",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.60.203", username="wro5gqt", password="5Gqtmoth"
    ),
    ueproxy_force_release=False,
    proxy_mngr_port=5000,
    ue_pc_port="5001",#If firewall blocks this port, change to 8080
    imsi="android",
    qualcomm_prototype=False,
    voice_call_dialing_timeout="30",
    network_mode_switch_method="secretcode",
    airplane_mode_switcher_text="Off|On",
)

_android_2G.ue_type = "android"


tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    core=_epcsim,
    ues=[_android_4G],
    tl_cloud_topology="6022",
    appserver=_appserver,
    test_pcs=[_test_pc_2, _test_pc]
)

tl.target_traffic_2G = {
    "MIN_DL": "0.01", #Mbits/sec
    "MIN_UL": "0.01", #Mbits/sec
    "MAX_DL": "0.05", #Mbits/sec
    "MAX_UL": "0.025", #Mbits/sec
    "IPERF_DURATION": "70", #seconds
    "cell_id_rf1": "1181"
}

tl.target_traffic_3G = {
    "MIN_DL": "0.32", #Mbits/sec
    "MIN_UL": "0.16", #Mbits/sec
    "MAX_DL": "0.4", #Mbits/sec
    "MAX_UL": "0.2", #Mbits/sec
    "IPERF_DURATION": "70", #seconds
    "cell_id_rf1": "36751"
}
tl.target_traffic_4G = {
    "MIN_DL": "4", #Mbits/sec
    "MIN_UL": "3", #Mbits/sec
    "MAX_DL": "30", #Mbits/sec
    "MAX_UL": "20", #Mbits/sec
    "IPERF_DURATION": "70", #seconds
    "cell_id_rf1": "2732804"
}

tl.custom = {
    "real_enb": "True",        # True if TL connected to LTE eNB
    "has_real_core": "True",    # True if TL not using EPCSim
    "standalone": "False",
    "is_MRAT": "True",
}

tl.scf_variables = {
    # General
    "btsid": "10675",
    "bbmod_1_prodcode": "473096A.103",
    "btsName": "QT-ASIB_FSMF_ABIA_4G_3G_2G_FDD-TSR-6022",
    "location": "TSR",
    
    #TSR
    "bfdDestIpAddr": "10.15.236.75",
    "sdlPrimaryDestIp": "10.105.24.50",
    # Sync
    "_gps": "false",
    "_top": "true",
    "masterIpAddr": "10.15.223.101",  # Optional (comment if not used)
    "ntpServerIpAddr": "10.15.236.1",  # Optional (comment if not used)

    # IP addresses
    "ipif_1": "10.15.236.75",  # (WRO, TSR) BTS m-plane and LTE, (HGZ) BTS m-plane and LTE/WCDMA/GSM
    "ipif_1_prefixlength": "24",
    "ipif_1_destipprefixlength": "0",
    "ipif_1_destipaddr": "0.0.0.0",
    "ipif_1_gateway": "10.15.236.1",

    "ipif_2": "10.15.232.75",  # (WRO, TSR) WCDMA, (HGZ) NR: ngu and s1u
    "ipif_2_prefixlength": "24",
    "ipif_2_destipprefixlength": "24",
    "ipif_2_destipaddr": "10.91.190.0",
    "ipif_2_gateway": "10.15.232.1",

    "ipif_3": "10.15.251.75",  # (WRO, TSR) GSM, (HGZ) NR/LTE: x2c
    "ipif_3_prefixlength": "24",
    "ipif_3_destipprefixlength": "28",
    "ipif_3_destipaddr": "10.5.23.128",
    "ipif_3_gateway": "10.15.236.1",

    "ipif_4": "10.15.252.75",  # (WRO, TSR) NR, (HGZ) NR/LTE: x2u
    "ipif_4_prefixlength": "24",
    # "ipif_4_destipprefixlength": "0",
    # "ipif_4_destipaddr": "0.0.0.0",
    # "ipif_4_gateway": "10.42.107.225",

    # "ipif_5": "",  # (TSR) GSM 2, (WRO, HGZ) Optional (comment if not used)
    # "ipif_5_prefixlength": "",  # Optional (comment if not used)
    
    #RTPOL
    "rtpol_orderNumber_1": "1",
    "srcIpAddress_1": "0.0.0.0",
    "srcIpPrefixLength_1": "24",
    # "rtpol_orderNumber_2": "",
    # "srcIpAddress_2": "",
    # "srcIpPrefixLength_2": "",
    # "rtpol_orderNumber_3": "",
    # "srcIpAddress_3": "",
    # "srcIpPrefixLength_3": "",
    
    # VLANs
    "vlan_1": "461",  # IPIF-1
    "vlan_2": "361",  # IPIF-2
    "vlan_3": "261",  # IPIF-3
    "vlan_4": "262",  # IPIF-4
    # "vlan_5": "",  # Optional (comment if not used)

    # GSM
    "bcfid": "3118",
    "bscid": "1",
    "perTrxPower": "391",
    "gsm_ipaddressomusig": "10.27.126.213",

    # WCDMA
    "wcdma_rncidentifier": "252",
    "wcdma_sctpfarendsubnetipaddress": "10.27.141.205",
    "wcdma_sctpfarendsubnetprefixlength": "27",
    "wcdma_sctpportmin": "49675",
    "wncel_id": "36751",
    "wncel_id_defaultcarrier": "10625",
    "maxCarrierPower": "421",
    # LTE
    "lnbtsid": "10675",
    "ipAddrPrim": "10.55.192.6",
    # "gtpu_sgwipaddress": "",  # Optional (comment if not used)
    "mcc": "244",
    "mnc": "8",
    "tac": "8205",
    "lncel_id01": "46753",
    "lncel_id01_phycell": "4",
    "lncel_id01_earfcndl": "3650",
    "lncel_id01_earfcnul": "21650",
    "LCELL": "4",
    "lcrId": "4",

    #power management
    "neType": "VRF-TSR-1 claudiu.casmir@nokia.com",
    "moduleLocation_smod1": "L20C002",
    "moduleLocation_smod2": "L20C002",
    "moduleLocation_rmod1": "L20C001",
    "moduleLocation_rmod2": "L20C001",
}



tl.android_config_dir = os.path.dirname(os.path.abspath(__file__))

__all__ = ["tl"]
