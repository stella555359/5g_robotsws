__maintainer__ = "QT WRO"
__team__ = "RAN RD T&V OTA&CI QT2"
__email__ = "I_5GQT_WRO@internal.nsn.com"


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
from taf.config.testline.pdu import Gude
from taf.config.testline.appserver import AppServer, TafUeAppServer

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.33.98.158",
        username="ute",
        password="UTE.debian12",
    )
)

_appserver_ssh = SshServiceDetails(
    addr="10.33.98.158", username="ute", password="UTE.debian12"
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


_snmp_user_data=dict(
    userName="administrator",
    authKey="password",
    privKey="password",
    authProtocol="SHA1",
    privProtocol="AES-128",
)

_cu = CU(
    backhaul_site_oam_ip="10.35.218.138",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.35.218.138", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.35.218.138", username="Nemuadmin", password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="10.35.218.138", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_pdu = Gude(addr="0.0.0.0", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
model="EPC", version="8221-1", snmp_user=_snmp_user_data)

_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[None],
    pdu_port=_common_unit_pdu.pdu_ports[1],
)

_airscale = Airscale(common_units=[_common_unit])

_5g_ru_pdu = Gude(addr="1.1.1.1", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
model="EPC", version="8221-1", snmp_user=_snmp_user_data)

_ru = RU(
    ru_hw_group="AHFIB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.128", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="root"
    ),
    pdu_port=_5g_ru_pdu.pdu_ports[9],
)

_du = DU(airscale=_airscale, rus=[_ru], f1_m_ip_addr="10.35.218.138")

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_android = TafUeAndroid(
    serial_number="0123456789ABCDEF",
        ssh_connection_details=SshServiceDetails(
        addr="10.33.9.20", username="FIOUSRUSR", password="!SRkuivasranta2"
    ),
    capabilities=['_5G', '_4G'],
    ue_pc_address="10.33.9.20",
    data_transfer=[_data_transfer_iperf],
    proxy_mngr_port=80,  # ueproxy manager will not be visible unless proxy_mngr_port is configured! (default value: 9955 - used in autostart)
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
    tl_cloud_topology="5555",
)

tl.target_traffic_4G = {
    "IPERF_DURATION": "180", # seconds
    "MIN_DL": "160", #Mbits/sec
    "MAX_DL": "200", #Mbits/sec
    "MIN_UL": "80", #Mbits/sec
    "MAX_UL": "100", #Mbits/sec
    "cell_id_rf1": "1"
}

tl.target_traffic_5G = {
    "IPERF_DURATION": "180", # seconds
    "MIN_DL": "64", #Mbits/sec
    "MAX_DL": "80", #Mbits/sec
    "MIN_UL": "16", #Mbits/sec
    "MAX_UL": "20", #Mbits/sec
    "cell_id_rf1": "822607873"
}

tl.custom = {
    "real_enb": "False",        # True if 5G NSA TL is connected to LTE eNB
    "standalone": "True",       # True if SA, False for NSA
    "has_real_core": "True",    # True if TL using realcore
}

tl.scf_variables = {
    "mrbtsid": "50208",
    "lnbtsid": "0",
    "btsName": "CON49_LTE_AXEGHA",
    "location": "OTAVA4",
    "mcc": "244",
    "mnc": "9",
    "mncLength": "2",
    "pmax": "400",
    "lncel": "51",
    "lcell": "1",
    "ipAddrPrim": "10.33.58.200",	
    "tac": "9000",	
    "vlanId": "1",
    "gateway": "10.35.218.129",
    "localIpAddr": "10.35.218.138",
}

tl.android_config_dir = os.path.dirname(os.path.abspath(__file__))

__all__ = ["tl"]
