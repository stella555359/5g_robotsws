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
from taf.config.testline.pdu import PduPort, Gude
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.attenuator import TopYoung

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.241.81",
        username="ute",
        password="UTE.debian12",
    )
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.241.87",
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

_appserver_taf_ue_WL = TafUeAppServer(app_server_name="wl-srn-server-3-1094",
    address="10.42.249.116",
    user="qt5g",
    password="5Gqtmoth!",
    bind_interface_ip="10.42.249.116",
    expected_prompt="qt5g@wl-srn-server-3-1094")

_data_transfer_iperf_WL = TafUeDataTransferProtocol(protocol_name="iperf",
                                                 app_server=_appserver_taf_ue_WL,
                                                 interval=1)

_snmp_user_data = dict(
    userName="administrator",
    authKey="password",
    privKey="password",
    authProtocol="SHA1",
    privProtocol="AES-128",
)

_cu = CU(
    backhaul_site_oam_ip="10.42.6.42",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.42.6.42", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.6.42", username="Nemuadmin", password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="10.42.6.42", username="toor4nsn", password="oZPS0POrRieRtu"
)

_du_pdu = Gude(
    addr="10.44.71.8",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
    snmp_user=_snmp_user_data,
)

_du_pdu_port0 = PduPort(pdu=_du_pdu, port_no=8)

_du_pdu_port1 = PduPort(pdu=_du_pdu, port_no=7)

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
    addr="10.44.71.8",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
    snmp_user=_snmp_user_data,
)

_ru1 = RU(
    ru_hw_group="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="5.5.5.5", username="root", password=""),
    pdu_port=PduPort(pdu=_ru_pdu, port_no=11)
)

_ru2 = RU(
    ru_hw_group="AHFIB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="5.5.5.5", username="root", password=""),
    pdu_port=PduPort(pdu=_ru_pdu, port_no=10)
)

_ru3 = RU(
    ru_hw_group="FRGU",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.11.127", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="5.5.5.5", username="root", password=""),
    pdu_port=PduPort(pdu=_du_pdu, port_no=9)
)

_du = DU(airscale=_airscale, rus=[_ru1, _ru2, _ru3], f1_m_ip_addr="10.42.6.42")

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_lmp_connection = SshServiceDetails(
    addr="5.5.5.5", username="user5", password="password5"
)

_android_4G_5G = TafUeAndroid(
    serial_number="5529ce8c",
    capabilities=["_5G", "_4G"],
    ue_pc_address="10.42.156.131",
    data_transfer=[_data_transfer_iperf_WL],
    ssh_connection_details=SshServiceDetails(
        addr="10.42.156.131", username="wro5gqt", password="5Gqtmoth"
    ),
    ueproxy_force_release=False,
    proxy_mngr_port=5000,
    imsi="android",
    qualcomm_prototype=False,
    voice_call_dialing_timeout="30",
    network_mode_switch_method="secretcode",
    airplane_mode_switcher_text="Airplane mode",
)

_android_4G_5G.ue_type = "android"

_android_3G = TafUeAndroid(
    serial_number="cfe111d4",
    capabilities=["_3G"],
    ue_pc_address="10.42.156.131",
    data_transfer=[_data_transfer_iperf_WG],
    ssh_connection_details=SshServiceDetails(
        addr="10.42.156.131", username="wro5gqt", password="5Gqtmoth"
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
    serial_number="37e0a8f9",
    capabilities=["_2G"],
    ue_pc_address="10.42.156.131",
    data_transfer=[_data_transfer_iperf_WG],
    ssh_connection_details=SshServiceDetails(
        addr="10.42.156.131", username="wro5gqt", password="5Gqtmoth"
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

_attenuator = TopYoung(
    ip_addr="10.44.160.84",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24],
    model="TAS_24T24_04G6_90_1S_EJS",
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    core=None,
    ues=[_android_4G_5G],
    tl_cloud_topology="3005",
    attenuators=[_attenuator],
    test_pcs=[_test_pc_2, _test_pc],
)

tl.target_traffic_2G = {
    "MIN_DL": "0.01",  # Mbits/sec
    "MIN_UL": "0.01",  # Mbits/sec
    "MAX_DL": "0.1",  # Mbits/sec
    "MAX_UL": "0.05",  # Mbits/sec
    "IPERF_DURATION": "70",  # seconds
    "cell_id_rf1": "3901",
}

tl.target_traffic_3G = {
    "MIN_DL": "0.32",  # Mbits/sec
    "MIN_UL": "0.16",  # Mbits/sec
    "MAX_DL": "0.4",  # Mbits/sec
    "MAX_UL": "0.2",  # Mbits/sec
    "IPERF_DURATION": "70",  # seconds
    "cell_id_rf1": "9111",
}

tl.target_traffic_4G = {
    "MIN_DL": "48",  # Mbits/sec
    "MIN_UL": "32",  # Mbits/sec
    "MAX_DL": "60",  # Mbits/sec
    "MAX_UL": "40",  # Mbits/sec
    "IPERF_DURATION": "70",  # seconds
    "cell_id_rf1": "13587211",
}

tl.target_traffic_5G = {
    "MIN_DL": "104",  # Mbits/sec
    "MIN_UL": "40",  # Mbits/sec
    "MAX_DL": "130",  # Mbits/sec
    "MAX_UL": "50",  # Mbits/sec
    "IPERF_DURATION": "70",  # seconds
    "cell_id_rf1": "13587211",
}

tl.attenuation = {
    "pdu_model": "ATEN",
    "pdu_attenuator_ip": "10.44.71.2",
    "pdu_attenuator_port": "3",
    "attenuation_index": {"att": 0, "rf1": 0, "rf2": 0},
    "attenuation_2G": {21: 90, 22: 90, 23: 0, 24: 0},
    "attenuation_3G": {21: 90, 22: 90, 23: 0, 24: 0},
    "attenuation_4G": {21: 0, 22: 0, 23: 0, 24: 0},
    "attenuation_5G": {21: 0, 22: 0, 23: 0, 24: 0},
}

tl.custom = {
    "is_MRAT": "True",
}

tl.scf_variables = {
    # General
    "btsid": "53075",
    "btsName": "QT-ASIM_ASIM_ABIO_5G_NSA_4G_3G_2G_FDD-WRO-3005",
    "location": "WRO",
    "bbmod_1_prodcode": "475266A.102",
    "bbmod_2_prodcode": "473096A.107",
    "bbmod_3_prodcode": "473096A.102",

    # Sync
    "_gps": "false",
    "_top": "true",
    "masterIpAddr": "10.42.0.98",  # Optional (comment if not used)
    "ntpServerIpAddr": "10.42.248.70",  # Optional (comment if not used)

    # IP addresses
    "ipif_1": "10.42.6.42",  # (WRO, TSR) BTS m-plane and LTE, (HGZ) BTS m-plane and LTE/WCDMA/GSM
    "ipif_1_prefixlength": "27",
    "ipif_1_destipprefixlength": "0",
    "ipif_1_destipaddr": "0.0.0.0",
    "ipif_1_gateway": "10.42.6.33",

    "ipif_2": "10.42.5.234",  # (WRO, TSR) WCDMA, (HGZ) NR: ngu and s1u
    "ipif_2_prefixlength": "27",
    "ipif_2_destipprefixlength": "0",
    "ipif_2_destipaddr": "0.0.0.0",
    "ipif_2_gateway": "10.42.5.225",

    "ipif_3": "10.42.6.10",  # (WRO, TSR) GSM, (HGZ) NR/LTE: x2c
    "ipif_3_prefixlength": "27",
    "ipif_3_destipprefixlength": "0",
    "ipif_3_destipaddr": "0.0.0.0",
    "ipif_3_gateway": "10.42.6.1",

    "ipif_4": "10.42.107.226",  # (WRO, TSR) NR, (HGZ) NR/LTE: x2u
    "ipif_4_prefixlength": "27",
    "ipif_4_destipprefixlength": "0",
    "ipif_4_destipaddr": "0.0.0.0",
    "ipif_4_gateway": "10.42.107.225",

    # "ipif_5": "",  # (TSR) GSM 2, (WRO, HGZ) Optional (comment if not used)
    # "ipif_5_prefixlength": "",  # Optional (comment if not used)

    # VLANs
    "vlan_1": "193",  # IPIF-1
    "vlan_2": "191",  # IPIF-2
    "vlan_3": "192",  # IPIF-3
    "vlan_4": "81",  # IPIF-4
    # "vlan_5": "",  # Optional (comment if not used)

    # GSM
    "bcfid": "1390",
    "bscid": "25",
    "perTrxPower": "400",
    "gsm_ipaddressomusig": "10.42.245.38",

    # WCDMA
    "wcdma_rncidentifier": "25",
    "wcdma_sctpfarendsubnetipaddress": "10.42.28.72",
    "wcdma_sctpfarendsubnetprefixlength": "28",
    "wcdma_sctpportmin": "50911",
    "wncel_id": "9111",
    "wncel_id_defaultcarrier": "10650",

    # LTE
    "lnbtsid": "53075",
    "ipAddrPrim": "10.44.201.68",
    #"gtpu_sgwipaddress": "10.42.249.83",  # Optional (comment if not used)
    "mcc": "555",
    "mnc": "10",
    "tac": "7151",
    "lncel_id01": "14333",
    "lncel_id01_phycell": "211",
    "lncel_id01_earfcndl": "900",
    "lncel_id01_earfcnul": "18900",
    "lncel_id02": "14334",
    "lncel_id02_phycell": "11",
    "lncel_id02_earfcndl": "250",
    "lncel_id02_earfcnul": "18250",
    "nrcellid": "869580801",

    # NR
    "nrbtsid": "53075",
    "nrcell_physcell": "60",
    "nrcell_nrarfcndl": "126900",
    "nrcell_nrarfcnul": "136100",
    "carrierFreqNrCell": "176210",
    "_ngCplane": "false",
    "_xnLink": "false",
}

tl.android_config_dir = os.path.dirname(os.path.abspath(__file__))

__all__ = ["tl"]
