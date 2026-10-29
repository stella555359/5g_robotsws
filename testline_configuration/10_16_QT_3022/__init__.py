__maintainer__ = "QT WRO"
__team__ = "MN RAN RD T&V OTA&CI QT1"
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
from taf.config.testline.pdu import PduPort, Gude, APC
from taf.config.testline.appserver import TafUeAppServer

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.241.69",
        username="ute",
        password="UTE.debian12",
    )
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.241.70",
        username="ute",
        password="UTE.debian12",
    )
)

_appserver_taf_ue_WG = TafUeAppServer(app_server_name="wg-srn-iperf-728",
    address="10.44.184.246",
    user="qt5g",
    password="5Gqtmoth!",
    bind_interface_ip="10.44.184.246",
    expected_prompt="qt5g@wg-srn-iperf-728")

_data_transfer_iperf_WG = TafUeDataTransferProtocol(protocol_name="iperf",
                                                 app_server=_appserver_taf_ue_WG,
                                                 interval=1)

_snmp_user_data = dict(
    userName="administrator",
    authKey="password",
    privKey="password",
    authProtocol="SHA1",
    privProtocol="AES-128",
)

_cu = CU(
    backhaul_site_oam_ip="10.42.6.50",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.42.6.50", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.6.50", username="Nemuadmin", password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="10.42.6.50", username="toor4nsn", password="oZPS0POrRieRtu"
)

_du_pdu = Gude(
    addr="10.44.71.11",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
    snmp_user=_snmp_user_data,
)

_du_pdu_port0 = PduPort(pdu=_du_pdu, port_no=1)

_du_pdu_port1 = PduPort(pdu=_du_pdu, port_no=2)

_du_common_unit0 = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[None],
    pdu_port=_du_pdu_port0,
)

_du_common_unit1 = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[None],
    pdu_port=_du_pdu_port1,
)

_airscale = Airscale(common_units=[_du_common_unit0, _du_common_unit1])

_ru_pdu = Gude(
    addr="10.44.71.11",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
    snmp_user=_snmp_user_data,
)

_ru1 = RU(
    ru_hw_group="AHEGA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="5.5.5.5", username="root", password=""),
    pdu_port=PduPort(pdu=_ru_pdu, port_no=4)
)

_ru2 = RU(
    ru_hw_group="FXJB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.10.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="5.5.5.5", username="root", password=""),
    pdu_port=PduPort(pdu=_ru_pdu, port_no=3)
)

_du = DU(airscale=_airscale, rus=[_ru1, _ru2], f1_m_ip_addr="10.42.6.50")

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_lmp_connection = SshServiceDetails(
    addr="5.5.5.5", username="user5", password="password5"
)

_android_4G = TafUeAndroid(
    serial_number="37d4d268",
    capabilities=["_4G"],
    ue_pc_address="10.45.165.252",
    data_transfer=[_data_transfer_iperf_WG],
    ssh_connection_details=SshServiceDetails(
        addr="10.45.165.252", username="wro5gqt", password="5Gqtmoth"
    ),
    ueproxy_force_release=False,
    proxy_mngr_port=5000,
    imsi="android",
    qualcomm_prototype=False,
    voice_call_dialing_timeout="30",
    network_mode_switch_method="secretcode",
    airplane_mode_switcher_text="Off|On",
)

_android_4G.ue_type = "android"

_android_3G = TafUeAndroid(
    serial_number="90fe61bf",
    capabilities=["_3G"],
    ue_pc_address="10.45.165.252",
    data_transfer=[_data_transfer_iperf_WG],
    ssh_connection_details=SshServiceDetails(
        addr="10.45.165.252", username="wro5gqt", password="5Gqtmoth"
    ),
    ueproxy_force_release=False,
    proxy_mngr_port=5000,
    imsi="android",
    qualcomm_prototype=False,
    voice_call_dialing_timeout="30",
    network_mode_switch_method="secretcode",
    airplane_mode_switcher_text="Off|On",
)

_android_3G.ue_type = "android"

_android_2G = TafUeAndroid(
    serial_number="cfe1828b",
    capabilities=["_2G"],
    ue_pc_address="10.45.165.252",
    data_transfer=[_data_transfer_iperf_WG],
    ssh_connection_details=SshServiceDetails(
        addr="10.45.165.252", username="wro5gqt", password="5Gqtmoth"
    ),
    ueproxy_force_release=False,
    proxy_mngr_port=5000,
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
    core=None,
    ues=[_android_4G],
    tl_cloud_topology="3022",
    test_pcs=[_test_pc_2, _test_pc],
)

tl.target_traffic_2G = {
    "MIN_DL": "0.01",  # Mbits/sec
    "MIN_UL": "0.01",  # Mbits/sec
    "MAX_DL": "0.05",  # Mbits/sec
    "MAX_UL": "0.025",  # Mbits/sec
    "IPERF_DURATION": "70",  # seconds
    "cell_id_rf1": "171",
}

tl.target_traffic_3G = {
    "MIN_DL": "0.32",  # Mbits/sec
    "MIN_UL": "0.16",  # Mbits/sec
    "MAX_DL": "0.4",  # Mbits/sec
    "MAX_UL": "0.2",  # Mbits/sec
    "IPERF_DURATION": "70",  # seconds
    "cell_id_rf1": "9201",
}

tl.target_traffic_4G = {
    "MIN_DL": "12",  # Mbits/sec
    "MIN_UL": "8",  # Mbits/sec
    "MAX_DL": "15",  # Mbits/sec
    "MAX_UL": "10",  # Mbits/sec
    "IPERF_DURATION": "70",  # seconds
    "cell_id_rf1": "1048577",
}

tl.custom = {
    "is_MRAT": "True",
}

tl.scf_variables = {
    # General
    "btsid": "4096",
    "btsName": "QT-ASIB_FSMF_ABIA_4G_3G_2G_FDD-WRO-3022",
    "location": "WRO",

    # Sync
    "_gps": "false",
    "_top": "true",
    "masterIpAddr": "10.42.161.252",  # Optional (comment if not used)
    "ntpServerIpAddr": "10.42.162.252",  # Optional (comment if not used)

    # IP addresses
    "ipif_1": "10.42.6.50",  # (WRO, TSR) BTS m-plane and LTE, (HGZ) BTS m-plane and LTE/WCDMA/GSM
    "ipif_1_prefixlength": "27",
    "ipif_1_destipprefixlength": "0",
    "ipif_1_destipaddr": "0.0.0.0",
    "ipif_1_gateway": "10.42.6.33",

    "ipif_2": "10.42.5.242",  # (WRO, TSR) WCDMA, (HGZ) NR: ngu and s1u
    "ipif_2_prefixlength": "27",
    "ipif_2_destipprefixlength": "0",
    "ipif_2_destipaddr": "0.0.0.0",
    "ipif_2_gateway": "10.42.5.225",

    "ipif_3": "10.42.6.18",  # (WRO, TSR) GSM, (HGZ) NR/LTE: x2c
    "ipif_3_prefixlength": "27",
    "ipif_3_destipprefixlength": "0",
    "ipif_3_destipaddr": "0.0.0.0",
    "ipif_3_gateway": "10.42.6.1",

    #RTPOL
    "rtpol_orderNumber_1": "1",
    "srcIpAddress_1": "10.42.5.242",
    "srcIpPrefixLength_1": "32",
    "rtpol_orderNumber_2": "2",
    "srcIpAddress_2": "10.44.182.118",
    "srcIpPrefixLength_2": "32",
    "rtpol_orderNumber_3": "3",
    "srcIpAddress_3": "10.42.6.18",
    "srcIpPrefixLength_3": "32",
    
    # VLANs
    "vlan_1": "193",  # IPIF-1
    "vlan_2": "191",  # IPIF-2
    "vlan_3": "192",  # IPIF-3

    # GSM
    "bcfid": "1017",
    "bscid": "25",
    "perTrxPower": "391",
    "gsm_ipaddressomusig": "10.42.245.47",

    # WCDMA
    "wcdma_rncidentifier": "10",
    "wcdma_sctpfarendsubnetipaddress": "10.44.194.3",
    "wcdma_sctpfarendsubnetprefixlength": "27",
    "wcdma_sctpportmin": "50920",
    "wncel_id": "9201",
    "wncel_id_defaultcarrier": "10740",
    "maxCarrierPower": "421",
    # LTE
    "lnbtsid": "4096",
    "ipAddrPrim": "10.44.201.68",
    #"gtpu_sgwipaddress": "10.42.178.83",  # Optional (comment if not used)
    "mcc": "244",
    "mnc": "8",
    "tac": "7102",
    "lncel_id01": "23316",
    "lncel_id01_phycell": "1",
    "lncel_id01_earfcndl": "3630",
    "lncel_id01_earfcnul": "21630",
    "LCELL": "1",
    "lcrId": "1",
}

tl.android_config_dir = os.path.dirname(os.path.abspath(__file__))

__all__ = ["tl"]
