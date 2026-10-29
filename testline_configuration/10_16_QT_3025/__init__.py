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
from taf.config.testline.ue import TafUeAt, PluginAtClassType

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.241.84",
        username="ute",
        password="UTE.debian12",
    )
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.241.90",
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

_data_transfer_iperf_WG_Android = TafUeDataTransferProtocol(protocol_name="iperf",
                                                 app_server=_appserver_taf_ue_WG,
                                                 interval=1,)

_data_transfer_iperf_WG_QC = TafUeDataTransferProtocol(protocol_name="iperf",
                                                 app_server=_appserver_taf_ue_WG,
                                                 interval=1,
                                                 binary_path='/cygdrive/c/iperf/',
                                                 interface_name='QUECTEL_3025',
                                                 dt_from_uepc=True)

_appserver_taf_ue_WL = TafUeAppServer(app_server_name="wl-srn-server-1-idf34",
    address="10.45.168.53",
    user="qt5g",
    password="5Gqtmoth!",
    bind_interface_ip="10.45.168.53",
    expected_prompt="qt5g@wl-srn-server-1-idf34")

_data_transfer_iperf_WL_Quectel = TafUeDataTransferProtocol(protocol_name="iperf",
                                                    app_server=_appserver_taf_ue_WL,
                                                    interval=1,
                                                    binary_path='/cygdrive/c/iperf/',
                                                    interface_name='QUECTEL_3025',
                                                    dt_from_uepc=True)

_snmp_user_data = dict(
    userName="administrator",
    authKey="password",
    privKey="password",
    authProtocol="SHA1",
    privProtocol="AES-128",
)

_cu = CU(
    backhaul_site_oam_ip="10.42.6.38",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.42.6.38", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.6.38", username="Nemuadmin", password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="10.42.6.38", username="toor4nsn", password="oZPS0POrRieRtu"
)

_du_pdu = Gude(
    addr="10.44.71.21",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
    snmp_user=_snmp_user_data,
)

_du_pdu_port0 = PduPort(pdu=_du_pdu, port_no=9)

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
    addr="10.44.71.20",
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
    pdu_port=PduPort(pdu=_ru_pdu, port_no=1)
)

_ru2 = RU(
    ru_hw_group="FXJB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.10.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="5.5.5.5", username="root", password=""),
    pdu_port=PduPort(pdu=_ru_pdu, port_no=11)
)

_du = DU(airscale=_airscale, rus=[_ru1, _ru2], f1_m_ip_addr="10.42.6.38")

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_lmp_connection = SshServiceDetails(
    addr="5.5.5.5", username="user5", password="password5"
)

_quectel_4G = TafUeAt(
    com_port="3", 
    #serial_number="867034040009996", #or IMEI in SimCom Quectel UE
    imei="867034040009996",
    capabilities=["_4G"],
    ue_pc_address="10.42.156.133",
    ue_pc_login="wro5gqt",
    ue_pc_password="5Gqtmoth",
    ue_pc_expected_prompt="wro5gqt@PLWR5G5954",
    data_transfer=[_data_transfer_iperf_WG_QC],
    proxy_mngr_port=80,
    ueproxy_force_release=False,
    class_name=PluginAtClassType.quectel,
    processes_to_kill=['Vysor'])

_quectel_4G.ue_type = "quectel"

_quectel_3G = TafUeAt(
    com_port="3", 
    serial_number="867034040009996", #or IMEI in SimCom Quectel UE
    capabilities=["_3G"],
    ue_pc_address="10.42.156.133",
    ue_pc_login="wro5gqt",
    ue_pc_password="5Gqtmoth",
    ue_pc_expected_prompt="wro5gqt@PLWR5G5954",
    data_transfer=[_data_transfer_iperf_WG_QC],
    proxy_mngr_port=80,
    ueproxy_force_release=False,
    class_name=PluginAtClassType.quectel,
    processes_to_kill=['Vysor'])

_quectel_3G.ue_type = "quectel"

_android_2G = TafUeAndroid(
    serial_number="8d28610e",
    capabilities=["_2G"],
    ue_pc_address="10.42.156.133",
    data_transfer=[_data_transfer_iperf_WG_Android],
    ssh_connection_details=SshServiceDetails(
        addr="10.42.156.133", username="wro5gqt", password="5Gqtmoth"
    ),
    ueproxy_force_release=False,
    proxy_mngr_port=80,
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
    ues=[_quectel_4G],
    tl_cloud_topology="3025",
    test_pcs=[_test_pc_2, _test_pc],
)

tl.target_traffic_2G = {
    "MIN_DL": "0.01",  # Mbits/sec
    "MIN_UL": "0.01",  # Mbits/sec
    "MAX_DL": "0.05",  # Mbits/sec
    "MAX_UL": "0.025",  # Mbits/sec
    "IPERF_DURATION": "70",  # seconds
    "cell_id_rf1": "91",
}

tl.target_traffic_3G = {
    "MIN_DL": "0.32",  # Mbits/sec
    "MIN_UL": "0.16",  # Mbits/sec
    "MAX_DL": "0.4",  # Mbits/sec
    "MAX_UL": "0.2",  # Mbits/sec
    "IPERF_DURATION": "70",  # seconds
    "cell_id_rf1": "34001",
}

tl.target_traffic_4G = {
    "MIN_DL": "12",  # Mbits/sec
    "MIN_UL": "8",  # Mbits/sec
    "MAX_DL": "15",  # Mbits/sec
    "MAX_UL": "10",  # Mbits/sec
    "IPERF_DURATION": "70",  # seconds
    "cell_id_rf1": "1044481",
}

tl.custom = {
    "is_MRAT": "True",
}

tl.scf_variables = {
    # General
    "btsid": "4080",
    "btsName": "QT-ASIB_FSMF_ABIA_4G_3G_2G_FDD-WRO-3025",
    "location": "WRO",

    # Sync
    "_gps": "false",
    "_top": "true",
    "masterIpAddr": "10.42.161.252",  # Optional (comment if not used)
    "ntpServerIpAddr": "10.42.162.252",  # Optional (comment if not used)

    # IP addresses
    "ipif_1": "10.42.6.38",  # (WRO, TSR) BTS m-plane and LTE, (HGZ) BTS m-plane and LTE/WCDMA/GSM
    "ipif_1_prefixlength": "27",
    "ipif_1_destipprefixlength": "0",
    "ipif_1_destipaddr": "0.0.0.0",
    "ipif_1_gateway": "10.42.6.33",

    "ipif_2": "10.42.5.230",  # (WRO, TSR) WCDMA, (HGZ) NR: ngu and s1u
    "ipif_2_prefixlength": "25",
    "ipif_2_destipprefixlength": "0",
    "ipif_2_destipaddr": "0.0.0.0",
    "ipif_2_gateway": "10.42.5.225",

    "ipif_3": "10.42.6.6",  # (WRO, TSR) GSM, (HGZ) NR/LTE: x2c
    "ipif_3_prefixlength": "27",
    "ipif_3_destipprefixlength": "0",
    "ipif_3_destipaddr": "0.0.0.0",
    "ipif_3_gateway": "10.42.6.1",

    #RTPOL
    "rtpol_orderNumber_1": "1",
    "srcIpAddress_1": "10.42.6.38",
    "srcIpPrefixLength_1": "32",
    "rtpol_orderNumber_2": "2",
    "srcIpAddress_2": "10.42.5.230",
    "srcIpPrefixLength_2": "32",
    "rtpol_orderNumber_3": "3",
    "srcIpAddress_3": "10.42.6.6",
    "srcIpPrefixLength_3": "32",
    
    # VLANs
    "vlan_1": "193",  # IPIF-1
    "vlan_2": "191",  # IPIF-2
    "vlan_3": "192",  # IPIF-3

    # GSM
    "bcfid": "1009",
    "bscid": "25",
    "perTrxPower": "391",
    "gsm_ipaddressomusig": "10.42.245.47",

    # WCDMA
    "wcdma_rncidentifier": "25",
    "wcdma_sctpfarendsubnetipaddress": "10.42.28.72",
    "wcdma_sctpfarendsubnetprefixlength": "28",
    "wcdma_sctpportmin": "50340",
    "wncel_id": "34001",
    "wncel_id_defaultcarrier": "10740",
    "maxCarrierPower": "430",
    # LTE
    "lnbtsid": "4080",
    "ipAddrPrim": "10.44.201.68",
    #"gtpu_sgwipaddress": "10.42.178.83",  # Optional (comment if not used)
    "mcc": "555",
    "mnc": "10",
    "tac": "7102",
    "lncel_id01": "15628",
    "lncel_id01_phycell": "1",
    "lncel_id01_earfcndl": "3700",
    "lncel_id01_earfcnul": "21700",
    "LCELL": "1",
    "lcrId": "1",
}


tl.android_config_dir = os.path.dirname(os.path.abspath(__file__))

__all__ = ["tl"]
