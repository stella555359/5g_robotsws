__maintainer__ = "QT WRO"
__team__ = "MN RAN RD T&V OTA&CI QT2"
__email__ = "I_5GQT_WRO@internal.nsn.com"
__owner_email__ = "I_5GQT_WRO@internal.nsn.com"


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
from taf.config.testline.enb import RealEnb
from taf.config.testline import RU
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.airscale import Airscale, CommonUnit
from taf.config.testline.pdu import ENICS
from taf.config.testline.appserver import AppServer, TafUeAppServer

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.33.98.207",
        username="ute",
        password="UTE.debian12",
    )
)

_test_pc_lte_nsa = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.33.98.199",
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
    backhaul_site_oam_ip="10.33.54.148",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.33.54.148", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.33.54.148", username="Nemuadmin", password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="10.33.54.148", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_pdu = ENICS(addr="10.33.11.10", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
model="ENICS")

_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[None],
    pdu_port=_common_unit_pdu.pdu_ports[7],
    hardware_type="ASOE",
    hardware_version="A.101",
)

_airscale = Airscale(common_units=[_common_unit])

_5g_ru_pdu = ENICS(addr="10.35.50.151", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
model="ENICS")

_ru = RU(
    ru_hw_group="AVQL",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.1.2", username="rfsw", password="f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0="
    ),
    lmp_connection=SshServiceDetails(
        addr="5.5.5.5", username="rfsw", password="f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0="
    ),
    pdu_port=_5g_ru_pdu.pdu_ports[2],
)

_du = DU(airscale=_airscale, rus=[_ru], f1_m_ip_addr="10.33.54.148")

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_4g_ru_pdu = ENICS(addr="10.35.50.152", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
model="ENICS")

_RadioModule = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.8.128", username="root", password=""
    ),
    pdu_port=_4g_ru_pdu.pdu_ports[3],
)

_real_enb_pdu = ENICS(addr="10.33.11.9", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
model="ENICS")
_common_unit_enb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.33.54.140", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_real_enb_pdu.pdu_ports[11],
)           
_real_enb = Airscale(common_units=[_common_unit_enb])

_lte_real_enb = RealEnb(system_module=_real_enb, rms=[_RadioModule]) 


_android = TafUeAndroid(
    serial_number="0123456789ABCDEF",
        ssh_connection_details=SshServiceDetails(
        addr="10.33.10.71", username="FIOUSRUSR", password="!SRkuivasranta2"
    ),
    capabilities=['_5G', '_4G'],
    ue_pc_address="10.33.10.71",
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
    test_pcs=[_test_pc_lte_nsa, _test_pc],
    ues=[_android],
    gnbs=[_cbts],
    enbs=[_lte_real_enb],
    appserver=_appserver,
    tl_cloud_topology="7003",
)

tl.target_traffic_5G = {
    "IPERF_DURATION": "180", #seconds
    "MIN_DL": "320", #Mbits/sec
    "MAX_DL": "400", #Mbits/sec
    "MIN_UL": "40", #Mbits/sec
    "MAX_UL": "50", #Mbits/sec
    "cell_id_rf1": "18741760"
}

tl.custom = {
    "real_enb": "True",  # True if 5G NSA TL is connected to LTE eNB
    "standalone": "False",  # True if SA, False for NSA
    "has_real_core": "True",  # True if TL using realcore
}

tl.scf_variables = {
    "mrbts": "73218",
    "nrbts": "73218",
    "btsName": "QT-ASOE_5G_NSA_TDD-OULU-7003",
    "location": "OULU",
    "ntpServerIpAddrOrFqdnList": "10.35.50.209",
    "masterIpAddr": "10.33.50.2",
    "mcc": "244",
    "mnc": "9",
    "mncLength": "2",
    "nr_pmax": "300",
    "pMaxNROwnCell": "30",
    "enb_x2_ip": "10.33.54.140",
    #mplane
    "mplane_ip": "10.33.54.148",
    "mplane_ip_prefix": "27",
    "mplane_gw": "10.33.54.129",
    "connectorLabel": "S-RF7"
}

tl.android_config_dir = os.path.dirname(os.path.abspath(__file__))

__all__ = ["tl"]