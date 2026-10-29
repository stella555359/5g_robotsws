__maintainer__ = "QT WRO"
__team__ = "MN RAN RD T&V OTA&CI QT1"
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
from taf.config.testline.pdu import ENICS
from taf.config.testline.appserver import AppServer, TafUeAppServer

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.33.98.204",
        username="ute",
        password="UTE.debian12",
    )
)

_appserver_ssh = SshServiceDetails(
    addr="10.33.98.204", username="ute", password="UTE.debian12"
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
    backhaul_site_oam_ip="10.33.54.145",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.33.54.145", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.33.54.145", username="Nemuadmin", password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="10.33.54.145", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_pdu = ENICS(addr="10.33.11.10", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
model="ENICS")

_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[None],
    pdu_port=_common_unit_pdu.pdu_ports[4],
)

_airscale = Airscale(common_units=[_common_unit])

_ru_pdu = ENICS(addr="10.35.49.120", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
model="ENICS")

_ru = RU(
    ru_hw_group="AEHC",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.162",
        username="rfsw",
        password="bdS%ztWG3v7%SjreCVA79wTPb",
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.8.162",
        username="rfsw",
        password="bdS%ztWG3v7%SjreCVA79wTPb",
    ),
    pdu_port=_ru_pdu.pdu_ports[2],
)

_du = DU(airscale=_airscale, rus=[_ru], f1_m_ip_addr="10.33.54.145")

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_android = TafUeAndroid(
    serial_number="0123456789ABCDEF",
        ssh_connection_details=SshServiceDetails(
        addr="10.33.10.73", username="FIOUSRUSR", password="!SRkuivasranta2"
    ),
    capabilities=['_5G'],
    ue_pc_address="10.33.10.73",
    data_transfer=[_data_transfer_iperf],
    proxy_mngr_port=80,
    ueproxy_force_release=False,
    imsi="android",
    qualcomm_prototype=False,
    voice_call_dialing_timeout="30",
    network_mode_switch_method="secretcode",
    airplane_mode_switcher_text="Airplane mode",
)

_android.ue_type = "android"

tl = TestLine(
    test_pc=_test_pc,
    ues=[_android],
    gnbs=[_cbts],
    appserver=_appserver,
    tl_cloud_topology="7006",
)

tl.target_traffic_5G = {
    "IPERF_DURATION": "180", #seconds
    "MIN_DL": "120", #Mbits/sec
    "MAX_DL": "150", #Mbits/sec
    "MIN_UL": "20", #Mbits/sec
    "MAX_UL": "50", #Mbits/sec
    "cell_id_rf1": "1171441",
}

tl.custom = {
    "real_enb": "False",        # True if TL connected to LTE eNB
    "standalone": "True",       # True if SA, False for NSA
    "has_real_core": "True",    # True if TL using realcore
}

tl.scf_variables = {
    # Sections IDs
    "mrbts": "73215",
    # MRBTS
    "btsName": "QT-ASIK_ABIL_5G_SA_TDD-OULU-7006",
    "location": "OULU",
    "secondEndpointPortId": "1", 
    "ntpServer_ip": "10.35.50.209",
    "masterIpAddr": "10.33.50.2",
    "bbmod_1_prodcode": "474020A.102",
    "mcc": "244",
    "mnc": "9",
    "mncLength": "2",
    "nr_pmax": "360",
    "pMaxNROwnCell": "26",
    "pMaxEutra": "23",
    "physCellId": "50",
    "fiveGsTac": "9926",
    "amfIPAddress": "10.33.58.136",
    "fiveGsTac": "9926",
    "mplane_ip": "10.33.54.145",
    "mplane_ip_prefix": "27",
    "mplane_gw": "10.33.54.129",
}

tl.android_config_dir = os.path.dirname(os.path.abspath(__file__))

__all__ = ["tl"]