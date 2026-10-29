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
from taf.config.testline.pdu import PduPort, Gude, ATEN
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.ue import TafUeAt, PluginAtClassType

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.241.3",
        username="ute",
        password="UTE.debian12",
    )
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.241.4",
        username="ute",
        password="UTE.debian12",
    )
)

_appserver_taf_ue_WL = TafUeAppServer(app_server_name="wl-srn-server-2-idf34",
    address="10.42.197.170",
    user="qt5g",
    password="5Gqtmoth!",
    bind_interface_ip="10.42.197.170",
    expected_prompt="qt5g@wl-srn-server-2-idf34")

_data_transfer_iperf_WL = TafUeDataTransferProtocol(protocol_name="iperf",
                                                 app_server=_appserver_taf_ue_WL,
                                                 interval=1,
                                                 binary_path='/cygdrive/c/iperf/',
                                                 interface_name='QUECTEL_3003',
                                                 dt_from_uepc=True)

_appserver_taf_ue_WG = TafUeAppServer(app_server_name="wg-srn-iperf-728",
    address="10.44.184.246",
    user="qt5g",
    password="5Gqtmoth!",
    bind_interface_ip="10.44.184.246",
    expected_prompt="qt5g@wg-srn-iperf-728")

_data_transfer_iperf_WG_Android = TafUeDataTransferProtocol(protocol_name="iperf",
                                                 app_server=_appserver_taf_ue_WG,
                                                 interval=1)

_data_transfer_iperf_WG_Quectel = TafUeDataTransferProtocol(protocol_name="iperf",
                                                 app_server=_appserver_taf_ue_WG,
                                                 interval=1,
                                                 binary_path='/cygdrive/c/iperf/',
                                                 interface_name='QUECTEL_3003',
                                                 dt_from_uepc=True)                                              

_cu = CU(
    backhaul_site_oam_ip="10.42.6.39",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.42.6.39", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.42.6.39", username="Nemuadmin", password="nemuuser"
			   
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="10.42.6.39", username="toor4nsn", password="oZPS0POrRieRtu"
)

_snmp_user_data = dict(
    userName="administrator",
    authKey="password",
    privKey="password",
    authProtocol="SHA1",
    privProtocol="AES-128",
)

_du_pdu = ATEN(
    addr="10.44.71.8",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
    snmp_user=_snmp_user_data,
)

_du_pdu_port0 = PduPort(pdu=_du_pdu, port_no=2)

_du_pdu_port1 = PduPort(pdu=_du_pdu, port_no=1)

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
    addr="10.44.71.9",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
    snmp_user=_snmp_user_data,
)

_ru1 = RU(
    ru_hw_group="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="5.5.5.5", username="root", password=""),
    pdu_port=PduPort(pdu=_ru_pdu, port_no=2)
)

_ru2 = RU(
    ru_hw_group="AHFIB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="5.5.5.5", username="root", password=""),
    pdu_port=PduPort(pdu=_ru_pdu, port_no=3)
)

_ru3 = RU(
    ru_hw_group="FRGU",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.11.127", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="5.5.5.5", username="root", password=""),
    pdu_port=PduPort(pdu=_ru_pdu, port_no=1)
)

_du = DU(airscale=_airscale, rus=[_ru1, _ru2, _ru3], f1_m_ip_addr="10.42.6.42")

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_lmp_connection = SshServiceDetails(
    addr="5.5.5.5", username="user5", password="password5"
)

_quectel_3G_4G_5G = TafUeAt(
    com_port='13', 
    #serial_number="867034040010267", #or IMEI in SimCom Quectel UE
    imei="867034040010267",
    capabilities=['_4G','_5G'],
    ue_pc_address='10.42.36.207',
    ue_pc_login='wro5gqt',
    ue_pc_password='5Gqtmoth',
    ue_pc_expected_prompt="wro5gqt@PLWR5G5904",
    data_transfer=[_data_transfer_iperf_WL],
    proxy_mngr_port=80, 
    ueproxy_force_release=False,
    class_name=PluginAtClassType.quectel,
    processes_to_kill=['Vysor'])

_quectel_3G_4G_5G.ue_type = "quectel"

_android_2G = TafUeAndroid(
    serial_number="37775c91",
    capabilities=["_2G"],
    ue_pc_address="10.42.36.207",
    data_transfer=[_data_transfer_iperf_WG_Android],
    ssh_connection_details=SshServiceDetails(
        addr="10.42.36.207", username="wro5gqt", password="5Gqtmoth"
    ),
    ueproxy_force_release=False,
    proxy_mngr_port=80,
    imsi="android",
    qualcomm_prototype=False,
    voice_call_dialing_timeout="30",
    network_mode_switch_method="secretcode",
)

_android_2G.ue_type = "android"

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    core=None,
    ues=[_quectel_3G_4G_5G],
    tl_cloud_topology="3003",
    test_pcs=[_test_pc_2, _test_pc]
)

tl.target_traffic_2G = {
    "MIN_DL": "0.01", #Mbits/sec
    "MIN_UL": "0.01", #Mbits/sec
    "MAX_DL": "0.05", #Mbits/sec
    "MAX_UL": "0.025", #Mbits/sec
    "IPERF_DURATION": "70", #seconds
    "cell_id_rf1": "1241"
}

tl.target_traffic_3G = {
    "MIN_DL": "0.32", #Mbits/sec
    "MIN_UL": "0.16", #Mbits/sec
    "MAX_DL": "0.4", #Mbits/sec
    "MAX_UL": "0.2", #Mbits/sec
    "IPERF_DURATION": "70", #seconds
    "cell_id_rf1": "2001"
}

tl.target_traffic_4G = {
    "MIN_DL": "48",  # Mbits/sec
    "MIN_UL": "32",  # Mbits/sec
    "MAX_DL": "60",  # Mbits/sec
    "MAX_UL": "40",  # Mbits/sec
    "IPERF_DURATION": "70", #seconds
    "cell_id_rf1": "2153739"
}

tl.target_traffic_5G = {
    "MIN_DL": "104",  # Mbits/sec
    "MIN_UL": "40",  # Mbits/sec
    "MAX_DL": "130",  # Mbits/sec
    "MAX_UL": "50",  # Mbits/sec
    "IPERF_DURATION": "70", #seconds
    "cell_id_rf1": "2153739"
}

tl.custom = {
    "is_MRAT": "True",
    #"quectel_pdu_ip": "10.44.71.2"
    #"quectel_pdu_ip_port": "6"
}

tl.scf_variables = {
    # General
    "btsid": "8413",
    "btsName": "QT-ASIM_ASIM_ABIO_5G_NSA_4G_3G_2G_FDD-WRO-3003",
    "location": "WRO",
    "bbmod_1_prodcode": "475266A.102",
    "bbmod_2_prodcode": "473096A.103",
    "bbmod_3_prodcode": "473096A.103",

   # Sync
    "_gps": "false",
    "_top": "true",
    "masterIpAddr": "10.42.0.98",  # Optional (comment if not used)
    "ntpServerIpAddr": "10.42.248.70",  # Optional (comment if not used)

    # IP addresses
    "ipif_1": "10.42.6.39",  # (WRO, TSR) BTS m-plane and LTE, (HGZ) BTS m-plane and LTE/WCDMA/GSM
    "ipif_1_prefixlength": "27",
    "ipif_1_destipprefixlength": "0",
    "ipif_1_destipaddr": "0.0.0.0",
    "ipif_1_gateway": "10.42.6.33",

    "ipif_2": "10.42.5.231",  # (WRO, TSR) WCDMA, (HGZ) NR: ngu and s1u
    "ipif_2_prefixlength": "27",
    "ipif_2_destipprefixlength": "0",
    "ipif_2_destipaddr": "0.0.0.0",
    "ipif_2_gateway": "10.42.5.225",

    "ipif_3": "10.42.6.7",  # (WRO, TSR) GSM, (HGZ) NR/LTE: x2c
    "ipif_3_prefixlength": "27",
    "ipif_3_destipprefixlength": "0",
    "ipif_3_destipaddr": "0.0.0.0",
    "ipif_3_gateway": "10.42.6.1",

    "ipif_4": "10.42.107.246",  # (WRO, TSR) NR, (HGZ) NR/LTE: x2u
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
    "bcfid": "1240",
    "bscid": "25",
    "perTrxPower": "400",
    "gsm_ipaddressomusig": "10.42.245.38",

    # WCDMA
    "wcdma_rncidentifier": "10",
    "wcdma_sctpfarendsubnetipaddress": "10.44.194.3",
    "wcdma_sctpfarendsubnetprefixlength": "27",
    "wcdma_sctpportmin": "50020",
    "wncel_id": "2001",
    "wncel_id_defaultcarrier": "10730",

    # LTE
    "lnbtsid": "8413",
    "ipAddrPrim": "10.44.201.68",
    #"gtpu_sgwipaddress": "10.42.249.83",  # Optional (comment if not used)
    "mcc": "555",
    "mnc": "10",
    "tac": "7151",
    "lncel_id01": "13709",
    "lncel_id01_phycell": "211",
    "lncel_id01_earfcndl": "1100",
    "lncel_id01_earfcnul": "19100",
    "lncel_id02": "13710",
    "lncel_id02_phycell": "11",
    "lncel_id02_earfcndl": "250",
    "lncel_id02_earfcnul": "18250",
    "nrcellid": "137838593",

    # NR
    "nrbtsid": "8413",
    "nrcell_physcell": "60",
    "nrcell_nrarfcndl": "126900",
    "nrcell_nrarfcnul": "136100",
    "carrierFreqNrCell": "176210",
    "_ngCplane": "false",
    "_xnLink": "false",
}

tl.android_config_dir = os.path.dirname(os.path.abspath(__file__))

__all__ = ["tl"]
