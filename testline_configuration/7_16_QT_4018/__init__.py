__maintainer__ = "QT WRO"
__team__ = "MN RAN RD T&V OTA&CI QT2"
__email__ = "I_5GQT_WRO@internal.nsn.com"
__owner_email__ = "I_5GQT_WRO@internal.nsn.com"

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
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale, CommonUnit
from taf.config.testline.pdu import Gude
from taf.config.testline.appserver import AppServer
from taf.config.testline.attenuator import TopYoung
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.ue import TafUeAt

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.194.67", username="ute", password="UTE.debian12"
    )
)

_appserver_ssh = SshServiceDetails(
    addr="10.42.194.67", username="ute", password="UTE.debian12"
)

_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.45.168.53",
)

_appserver = AppServer(_iperf_details_on_appserver)

_appserver_taf_ue = TafUeAppServer(app_server_name="APP_TAF_UE",
    address="10.45.168.53",
    user="qt5g",
    password="5Gqtmoth!",
    bind_interface_ip="10.45.168.53",
    expected_prompt="qt5g@wl-srn-server-1-idf34")

_data_transfer_iperf = TafUeDataTransferProtocol(protocol_name="iperf",
                                                 app_server=_appserver_taf_ue,
                                                 interval=1,
                                                 version=2,
                                                 interface_name='ASKEY_4018',
                                                 dt_from_uepc=True)

_snmp_user_data=dict(
    userName="administrator",
    authKey="password",
    privKey="password",
    authProtocol="SHA1",
    privProtocol="AES-128",
)
_cu = CU(
    backhaul_site_oam_ip="10.44.80.48",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.80.48", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.80.48", username="Nemuadmin", password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="10.44.80.48", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_pdu = Gude(addr="10.44.177.92", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
model="EPC", version="8221-1", snmp_user=_snmp_user_data)

_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[None],
    pdu_port=_common_unit_pdu.pdu_ports[12],
)

_airscale = Airscale(common_units=[_common_unit])

_5g_ru_pdu = Gude(addr="10.44.177.21", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
model="EPC", version="8221-1", snmp_user=_snmp_user_data)

_ru1 = RU(
    ru_hw_group="AHCA AS195112281",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.77.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="5.5.5.5", username="root", password=""),
    pdu_port=_5g_ru_pdu.pdu_ports[11],
)
_ru2 = RU(
    ru_hw_group="AHCA AS195112271",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.77.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="5.5.5.5", username="root", password=""),
    pdu_port=_5g_ru_pdu.pdu_ports[6],
)
_ru3 = RU(
    ru_hw_group="AHCA AS195200012",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.77.130", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="5.5.5.5", username="root", password=""),
    pdu_port=_5g_ru_pdu.pdu_ports[8],
)

_du = DU(airscale=_airscale, rus=[_ru1, _ru2, _ru3], f1_m_ip_addr="10.44.80.48")

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_epcsim = EPCSim(
    mme_ip="10.1.1.100",
    mcc=555,
    mnc=10,
    tac=61,
    default_ssh_connection_details=SshServiceDetails(
        addr="10.45.168.53", username="qt5g", password="5Gqtmoth!"
    ),
    dir_path="",
    cfg_filename="",
)

_askey = TafUeAt(com_port='4',
                serial_number="e249156b",
                capabilities=['_5G'],
                ue_pc_address='10.42.63.202',
                ue_pc_login='wro5gqt',
                ue_pc_password='5Gqtmoth',
                proxy_mngr_port='80',
                ueproxy_force_release=False,
                ue_pc_expected_prompt='wro5gqt@PLWR5G5384',
                data_transfer=[_data_transfer_iperf])

_askey.ue_type = "askey"

_attenuator = TopYoung(
    ip_addr="10.42.68.200",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24],
    model="TAS_24T24_02G6_90_1C_EJS",
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    core=_epcsim,
    ues=[_askey],
    appserver=_appserver,
    attenuators=[_attenuator],
    tl_cloud_topology="4018",
)

tl.target_traffic_5G = {
    "IPERF_DURATION": "70", #seconds
    "MIN_DL": "80", #Mbits/sec
    "MAX_DL": "100", #Mbits/sec
    "MIN_UL": "40", #Mbits/sec
    "MAX_UL": "50", #Mbits/sec
    "cell_id_rf1": "849554",
    "cell_id_rf2": "849553",
    "cell_id_rf3": "849555",
}

tl.attenuation = {
    "attenuation_port": "3001",
    "attenuation_index": {"rf1":0, "rf2":0, "rf3":0},
    "attenuation_rf1": {7:0, 8:0},
    "attenuation_rf2": {9:0, 10:0},
    "attenuation_rf3": {11:0, 12:0},
    "pdu_model": "Gude",
    "pdu_attenuator_version": "8221-1",
    "pdu_attenuator_ip": "10.44.206.123",
    "pdu_attenuator_rf1_port": "6",
    "pdu_attenuator_rf2_port": "6",
    "pdu_attenuator_rf3_port": "6",
}

tl.custom = {
    "real_enb": "False",          # True if 5G NSA TL is connected to LTE eNB
    "standalone": "True",         # True if SA, False for NSA
    "has_real_core": "True",      # True if TL using realcore
    "askey_pdu_ip": "10.44.177.84",
    "askey_pdu_port": "2",
}

tl.scf_variables = {
    "mrbts": "53097",
    "btsName": "QT-ASIK_ABIL_5G_SA_FDD-WRO-4018",
    "location": "WRO",
    "firstEndpointPortId_RMOD_1": "2",
    "firstEndpointPortId_RMOD_2": "1",
    "firstEndpointPortId_RMOD_3": "2",
    "secondEndpointPortId": "1",
    "ntpServerIpAddrOrFqdnList": "10.42.248.70",
    "masterIpAddr": "10.42.0.106",
    "bbmod_1_prodcode": "474020A.102",
    "mcc": "540",
    "mnc": "1",
    "mncLength": "2",
    "freqBandIndicatorNR": "5",
    "gscnOrSsPbchArfcn": "2204",
    "nr_pmax": "410",
    "pMaxNROwnCell": "23",
    "nrarfcnDl": "176500",
    "nrarfcnUl": "167500",
    "amfIPAddress": "10.27.28.136",
    "fiveGsTac": "7151",
    "mplane_vlan": "459",
    "x2c_or_ngc_label": "x2c",
    "x2c_or_xnc_vlan": "460",
    "x2u_or_ngu_label": "x2u",
    "x2u_or_xnu_vlan": "461",
    "ngc_vlan": "462",
    "mplane_ip": "10.44.80.48",
    "mplane_ip_prefix": "26",
    "x2c_or_xnc_ip": "10.44.80.109",
    "x2c_or_xnc_ip_prefix": "26",
    "x2u_or_xnu_ip": "10.44.65.239",
    "x2u_or_xnu_ip_prefix": "26",
    "ngc_ip": "10.44.66.47",
    "ngc_ip_prefix": "26",
    "mplane_gw": "10.44.80.1",
    "x2c_or_xnc_gw": "10.44.80.65",
    "x2u_or_xnu_gw": "10.44.65.193",
    "ngc_gw": "10.44.66.1",
}

__all__ = ["tl"]
