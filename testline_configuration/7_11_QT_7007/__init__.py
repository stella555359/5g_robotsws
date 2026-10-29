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
from taf.config.testline import RU
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.airscale import Airscale, CommonUnit
from taf.config.testline.appserver import AppServer, TafUeAppServer
from taf.config.testline.pdu import ENICS
from taf.config.testline.core import EPCSim
from taf.config.testline.attenuator import AttenuationPort, HBTE

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.33.98.203", username="ute", password="UTE.debian12"
    )
)

_snmp_user_data = dict(
    userName="administrator",
    authKey="password",
    privKey="password",
    authProtocol="SHA1",
    privProtocol="AES-128",
)

_cu = CU(
    backhaul_site_oam_ip="10.33.54.144",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.33.54.144", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.33.54.144", username="Nemuadmin", password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="10.33.54.144", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_pdu = ENICS(addr="10.33.11.10", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
model="ENICS")

_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[None],
    pdu_port=_common_unit_pdu.pdu_ports[3],
)

_airscale = Airscale(common_units=[_common_unit])

_attenuator = HBTE(
    ip_addr="172.31.6.230",
    port=5000,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="PA-16-16-6-127-0.5-B-S",
)

_ru_pdu = ENICS(
    addr="10.33.16.143",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
)

_ru1 = RU(
    ru_hw_group="AHCA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="5.5.5.5", username="root", password=""),
    pdu_port=_ru_pdu.pdu_ports[3],
    attenuation_ports=[
        _attenuator.attenuator_ports[5],
        _attenuator.attenuator_ports[6],
    ],
)

_ru2 = RU(
    ru_hw_group="AHCA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="5.5.5.5", username="root", password=""),
    pdu_port=_ru_pdu.pdu_ports[5],
     attenuation_ports=[
        _attenuator.attenuator_ports[3],
        _attenuator.attenuator_ports[4],
    ],
)

_ru3 = RU(
    ru_hw_group="AHCA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.130", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="5.5.5.5", username="root", password=""),
    pdu_port=_ru_pdu.pdu_ports[8],
     attenuation_ports=[
        _attenuator.attenuator_ports[1],
        _attenuator.attenuator_ports[2],
    ],
)

_du = DU(airscale=_airscale, rus=[_ru1, _ru2, _ru3], f1_m_ip_addr="10.44.76.48")

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_appserver_ssh = SshServiceDetails(
    addr="10.33.98.203", username="ute", password="UTE.debian12"
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
    
_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_appserver_taf_ue, interval=1
)  # OPTIONAL

_android = TafUeAndroid(
    serial_number="0123456789ABCDEF",
    capabilities=["_5G"],
    ue_pc_address="10.33.10.70",
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.33.10.70", username="FIOUSRUSR", password="!SRkuivasranta2"
    ),
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
    gnbs=[_cbts],
    ues=[_android],
    appserver=_appserver,
    attenuator=[_attenuator],
    tl_cloud_topology="7007",
)

tl.target_traffic_5G = {
    "IPERF_DURATION": "70",  # seconds
    "MIN_DL": "80",  # Mbits/sec
    "MAX_DL": "100",  # Mbits/sec
    "MIN_UL": "40",  # Mbits/sec
    "MAX_UL": "50",  # Mbits/sec
    "cell_id_rf1": "1171425",
    "cell_id_rf2": "1171426",
    "cell_id_rf3": "1171427",
}

tl.attenuation = {
    "attenuation_rf1": {5: 0, 6:0},
    "attenuation_rf2": {3: 0, 4:0},
    "attenuation_rf3": {1: 0, 2:0},
    "attenuation_index": {"rf1":0, "rf2":0, "rf3":0},
    "pdu_model": "GUDE",
    "pdu_attenuator_version": "8221-1",
    "pdu_attenuator_ip": "10.33.10.173",
    "pdu_attenuator_rf1_port": "1",
    "pdu_attenuator_rf2_port": "1",
    "pdu_attenuator_rf3_port": "1",
    "att_max_value": "127",
    "att_off_value": "0",
    "attenuation_port": 5000,
}


tl.custom = {
    "real_enb": "False",  # True if 5G NSA TL is connected to LTE eNB
    "standalone": "True",  # True if SA, False for NSA
    "has_real_core": "True",  # True if TL using realcore
}

tl.android_config_dir = os.path.dirname(os.path.abspath(__file__))

tl.scf_variables = {
    "mrbts": "73214",
    "btsName": "QT-ASIK_ABIL_5G_SA_FDD-OULU-7007",
    "location": "OULU",
    "firstEndpointPortId_RMOD_1": "1",
    "firstEndpointPortId_RMOD_2": "2",
    "firstEndpointPortId_RMOD_3": "1",
    "secondEndpointPortId": "2",
    "ntpServerIpAddrOrFqdnList": "10.35.50.209",
    "masterIpAddr": "10.35.50.2",
    "bbmod_1_prodcode": "474020B.102",
    "mcc": "244",
    "mnc": "9",
    "mncLength": "2",
    "freqBandIndicatorNR": "5",
    "gscnOrSsPbchArfcn": "2204",
    "nr_pmax": "400",
    "pMaxNROwnCell": "23",
    "nrarfcnDl": "176500",
    "nrarfcnUl": "167500",
    "amfIPAddress": "10.33.58.136",
    "fiveGsTac": "9926",
    "mplane_ip": "10.33.54.144",
    "mplane_ip_prefix": "27",
    "mplane_gw": "10.33.54.129",
}

__all__ = ["tl"]
