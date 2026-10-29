__maintainer__ = "QT WRO"
__team__ = "MI MN RAN RD T&V OTA&CI QT1"
__email__ = "I_AM_QT@internal.nsn.com"
__owner_email__ = "I_AM_QT@internal.nsn.com"

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
from taf.config.testline.pdu import PduPort, ENICS
from taf.config.testline.appserver import AppServer, TafUeAppServer
from taf.config.testline.attenuator import AttenuationPort, HBTE

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.33.98.194",
        username="ute",
        password="UTE.debian12",
    )
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.33.95.111",
        username="ute",
        password="UTE.debian12",
    )
)

_appserver_ssh = SshServiceDetails(
    addr="10.33.98.192", username="ute", password="UTE.debian12"
)

_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.35.102.96",
)

_appserver = AppServer(_iperf_details_on_appserver)

_appserver_taf_ue = TafUeAppServer(app_server_name="APP_TAF_UE",
    address="10.35.102.96",
    user="srn",
    password="!!IperfUser@25",
    bind_interface_ip="10.35.102.96",
    expected_prompt="srn@iperfU39",
)

_data_transfer_iperf = TafUeDataTransferProtocol(protocol_name="iperf",
                                                 app_server=_appserver_taf_ue,
                                                 interval=1)                                 #OPTIONAL

_cu = CU(
    backhaul_site_oam_ip="10.33.54.155",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.33.54.155", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.33.54.155", username="Nemuadmin", password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="10.33.54.155", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_pdu = ENICS(
    addr="10.33.11.9",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    model="ENICS",
)

_du_pdu_port0 = PduPort(pdu=_common_unit_pdu, port_no=5)

_du_pdu_port1 = PduPort(pdu=_common_unit_pdu, port_no=6)

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

_attenuator = HBTE(
    ip_addr="172.31.6.230",
    port=5000,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="PA-16-16-6-127-0.5-B-S",
)

_ru_pdu1 = ENICS(
    addr="10.33.16.143",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    model="ENICS"
)

_ru_pdu2 = ENICS(
    addr="10.33.16.144",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    model="ENICS"
)

_ru1 = RU(
    ru_hw_group="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="5.5.5.5", username="root", password=""),
    pdu_port=PduPort(pdu=_ru_pdu1, port_no=7)
)

_ru2 = RU(
    ru_hw_group="AHFIB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="5.5.5.5", username="root", password=""),
    pdu_port=PduPort(pdu=_ru_pdu1, port_no=6)
)

_ru3 = RU(
    ru_hw_group="FRGU",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.11.127", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="5.5.5.5", username="root", password=""),
    pdu_port=PduPort(pdu=_ru_pdu2, port_no=9)
)

_du = DU(airscale=_airscale, rus=[_ru1, _ru2, _ru3], f1_m_ip_addr="10.33.54.155")

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_lmp_connection = SshServiceDetails(
    addr="5.5.5.5", username="user5", password="password5"
)

_android_4G_5G = TafUeAndroid(
    serial_number="PetuusaC300",
    capabilities=["_5G", "_4G"],
    ue_pc_address="10.33.10.74",
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.33.10.74", username="FIOUSRUSR", password="!SRkuivasranta2"
    ),
    ueproxy_force_release=False,
    proxy_mngr_port=80,
    imsi="android",
    qualcomm_prototype=False,
    voice_call_dialing_timeout="30",
    network_mode_switch_method="secretcode",
    airplane_mode_switcher_text="Airplane mode",
)

_android_4G_5G.ue_type = "android"

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    core=None,
    ues=[_android_4G_5G],
    attenuator=[_attenuator],
    tl_cloud_topology="7011",
    test_pcs=[_test_pc_2, _test_pc],
)

tl.target_traffic_4G = {
    "MIN_DL": "48",  # Mbits/sec
    "MIN_UL": "32",  # Mbits/sec
    "MAX_DL": "60",  # Mbits/sec
    "MAX_UL": "40",  # Mbits/sec
    "IPERF_DURATION": "70",  # seconds
    "cell_id_rf1": "18740491",
}

tl.target_traffic_5G = {
    "MIN_DL": "104",  # Mbits/sec
    "MIN_UL": "40",  # Mbits/sec
    "MAX_DL": "130",  # Mbits/sec
    "MAX_UL": "50",  # Mbits/sec
    "IPERF_DURATION": "70",  # seconds
    "cell_id_rf1": "18740491",
}

tl.attenuation = {
    "pdu_model": "GUDE",
    "pdu_attenuator_ip": "10.33.10.173",
    "pdu_attenuator_port": "1",
    "pdu_attenuator_version": "8221-1",
    "attenuation_index": {"att": 0},
    "attenuation_2G": {7:127, 8:127},
    "attenuation_3G": {7:127, 8:127},
    "attenuation_4G": {7:127, 8:127},
    "attenuation_5G": {7:0, 8:0},
    "att_max_value": "127",
    "att_off_value": "0",
    "attenuation_port": 5000,
}

tl.custom = {
    "is_MRAT": "True",
}

tl.scf_variables = {
    # General
    "btsid": "73205",
    "btsName": "QT-ASIM_ASIM_ABIO_5G_NSA_4G_3G_2G_FDD-7011",
    "location": "OULU",
    "bbmod_1_prodcode": "475266A.103U",
    "bbmod_2_prodcode": "473096A.107",
    "bbmod_3_prodcode": "473096A.107",

    # Sync
    "_gps": "false",
    "_top": "true",
    "masterIpAddr": "10.33.50.2",  # Optional (comment if not used)
    "ntpServerIpAddr": "10.35.50.209",  # Optional (comment if not used)

    # IP addresses
    "ipif_1": "10.33.54.135",
    "ipif_1_prefixlength": "27",
    "ipif_1_destipprefixlength": "0",
    "ipif_1_destipaddr": "0.0.0.0",
    "ipif_1_gateway": "10.33.54.129",

    "ipif_2": "10.33.54.155",
    "ipif_2_prefixlength": "27",
    "ipif_2_destipprefixlength": "0",
    "ipif_2_destipaddr": "0.0.0.0",
    "ipif_2_gateway": "10.33.54.129",

    # GSM
    "bcfid": "305",
    "bscid": "606",
    "perTrxPower": "400",
    "gsm_ipaddressomusig": "10.35.70.176",

    # WCDMA
    "wcdma_rncidentifier": "604",
    "wcdma_sctpfarendsubnetipaddress": "10.35.74.149",
    "wcdma_sctpfarendsubnetprefixlength": "32",
    "wcdma_sctpportmin": "49230",
    "wncel_id": "1",
    "wncel_id_defaultcarrier": "10650",

    # LTE
    "lnbtsid": "73205",
    "ipAddrPrim": "10.33.58.200",
    #"gtpu_sgwipaddress": "10.42.249.83",  # Optional (comment if not used)
    "mcc": "244",
    "mnc": "9",
    "tac": "9000",
    "lncel_id01": "13733",
    "lncel_id01_phycell": "69",
    "lncel_id01_earfcndl": "900",
    "lncel_id01_earfcnul": "18900",
    "lncel_id02": "13734",
    "lncel_id02_phycell": "11",
    "lncel_id02_earfcndl": "250",
    "lncel_id02_earfcnul": "18250",
    "nrcellid": "1199390721",

    # NR
    "nrbtsid": "73205",
    "nrcell_physcell": "60",
    "nrcell_nrarfcndl": "126900",
    "nrcell_nrarfcnul": "136100",
    "carrierFreqNrCell": "176210",
    "_ngCplane": "false",
    "_xnLink": "false",
}

tl.android_config_dir = os.path.dirname(os.path.abspath(__file__))

__all__ = ["tl"]