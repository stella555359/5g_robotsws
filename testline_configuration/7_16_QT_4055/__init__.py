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
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RU
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.airscale import Airscale, CommonUnit
from taf.config.testline.pdu import PduPort, Gude
from taf.config.testline.appserver import AppServer, TafUeAppServer

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.45.172.115", username="ute", password="UTE.debian12"
    )
)

_test_pc_lte_nsa = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.45.172.19", username="ute", password="UTE.debian12"
    )
)

_appserver_ssh = SshServiceDetails(
    addr="10.45.172.115", username="ute", password="UTE.debian12"
)

_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.45.168.53",
)

_appserver = AppServer(_iperf_details_on_appserver)

_appserver_taf_ue = TafUeAppServer(
    app_server_name="APP_TAF_UE",
    address="10.45.168.53",
    user="qt5g",
    password="5Gqtmoth!",
    bind_interface_ip="10.45.168.53",
    expected_prompt="qt5g@wl-srn-server-1-idf34",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_appserver_taf_ue, interval=1
)  # OPTIONAL

_snmp_user_data = dict(
    userName="administrator",
    authKey="password",
    privKey="password",
    authProtocol="SHA1",
    privProtocol="AES-128",
)

_cu = CU(
    backhaul_site_oam_ip="10.45.173.60",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.45.173.60", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.45.173.60", username="Nemuadmin", password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="10.45.173.60", username="toor4nsn", password="oZPS0POrRieRtu"
)


_du_pdu = Gude(
    addr="10.45.172.134",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_du_pdu_port = PduPort(pdu=_du_pdu, port_no=5)

_du_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[None],
    pdu_port=_du_pdu_port,
)

_airscale = Airscale(common_units=[_du_common_unit])

_ru_pdu = Gude(
    addr="10.45.172.156",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_ru_pdu_port = PduPort(pdu=_ru_pdu, port_no=1)

_ru = RU(
    ru_hw_group="AWEUA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.48.162",
        username="rfsw",
        password="ckBW1r1CX7VUPHcoHd69to3UwvEVm+cGW1aXDlfr51Y=",
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=_ru_pdu_port,
)

_du = DU(airscale=_airscale, rus=[_ru], f1_m_ip_addr="10.45.173.60")

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_android = TafUeAndroid(
    serial_number="R5CT60FAWFN",
    capabilities=["_5G"],
    ue_pc_address="10.45.172.205",
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.45.172.205", username="wro5gqt", password="5Gqtmoth"
    ),
    ueproxy_force_release=False,
    proxy_mngr_port=80,
    imsi="android",
    qualcomm_prototype=False,
    voice_call_dialing_timeout="30",
    network_mode_switch_method="secretcode",
    # https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1546825823#taf.ue.androidKeyevents-SamsungGUI
    airplane_mode_switcher_text="Off|On",
    # service_call_attach="16",                  # use service call if network_mode_switch_method doesnt work
    # service_call_detach="16",
)
_android.ue_type = "android"

_real_enb_pdu = Gude(
    addr="10.45.172.134",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_common_unit_enb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.45.173.9", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_real_enb_pdu.pdu_ports[2],
)

_common_unit_enb.tl_enb = "eNB_16"

_real_enb = Airscale(common_units=[_common_unit_enb])

_4g_ru_pdu = Gude(
    addr="10.45.172.134",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_RadioModule = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.129", username="root", password=""
    ),
    pdu_port=_4g_ru_pdu.pdu_ports[12],
)

_lte_real_enb = RealEnb(system_module=_real_enb, rms=[_RadioModule])

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc_lte_nsa, _test_pc],
    gnbs=[_cbts],
    enbs=[_lte_real_enb],
    ues=[_android],
    appserver=_appserver,
    tl_cloud_topology="4055",
)

tl.target_traffic_5G = {
    "IPERF_DURATION": "180",  # seconds
    "MIN_DL": "240",  # Mbits/sec
    "MAX_DL": "300",  # Mbits/sec
    "MIN_UL": "40",  # Mbits/sec
    "MAX_UL": "50",  # Mbits/sec
    "cell_id_rf1": "13595905",
}

tl.custom = {
    "real_enb": "True",  # True if TL connected to LTE eNB
    "standalone": "False",  # True if SA, False for NSA
    "has_real_core": "True",  # True if TL using realcore
}

tl.scf_variables = {
    "mrbts": "531092",
    "nrbts": "531092",
    "bbmod_1_prodcode": "475266A.104",
    "btsName": "QT-ASIB_ABIO_5G_NSA_TDD_mmw-WRO-4055",
    "location": "WRO",
    "secondEndpointPortId": "1",
    "ntpServerIpAddrOrFqdnList": "10.42.162.252",
    "masterIpAddr": "10.254.7.255",
    "mcc": "555",
    "mnc": "10",
    "mncLength": "2",
    "freqBandIndicatorEutra": "1",
    "freqBandIndicatorNR": "261",
    "nrarfcn": "2079589",
    "nr_pmax": "160",
    "pMaxNROwnCell": "20",
    "enb_x2_ip": "10.45.173.73",
    "mplane_vlan": "105",
    "x2c_or_xnc_vlan": "106",
    "x2u_or_xnu_vlan": "107",
    "s1u_or_ngu_vlan": "108",
    "mplane_ip": "10.45.173.60",
    "mplane_ip_prefix": "26",
    "x2c_or_xnc_ip": "10.45.173.124",
    "x2c_or_xnc_ip_prefix": "26",
    "x2u_or_xnu_ip": "10.45.173.188",
    "x2u_or_xnu_ip_prefix": "26",
    "s1u_or_ngu_ip": "10.45.173.248",
    "s1u_or_ngu_ip_prefix": "26",
    "mplane_gw": "10.45.173.1",
    "x2c_or_xnc_gw": "10.45.173.65",
    "x2u_or_xnu_gw": "10.45.173.129",
    "s1u_or_ngu_gw": "10.45.173.193",
}
tl.android_config_dir = os.path.dirname(os.path.abspath(__file__))

__all__ = ["tl"]
