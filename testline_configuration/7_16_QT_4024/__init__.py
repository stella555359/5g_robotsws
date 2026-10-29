__maintainer__ = "QT WRO"
__team__ = "MN RAN RD T&V OTA&CI QT2"
__email__ = "I_5GQT_WRO@internal.nsn.com"
__owner_email__ = "I_5GQT_WRO@internal.nsn.com"

import os
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
from taf.config.testline.airscale import Airscale, CommonUnit
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.appserver import AppServer
from taf.config.testline.enb import RealEnb
from taf.config.testline.attenuator import TopYoung
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer 
from taf.config.testline.ue import TafUeAt
from taf.config.testline.lmi import SerialOverTcp, SerialOverHost, LMI, Remote, Local
		
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.209.183", username="ute", password="UTE.debian12"
    )
)

_test_pc_lte_nsa = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.209.228", username="ute", password="UTE.debian12"
    )
)

_appserver_ssh = SshServiceDetails(
    addr="10.42.209.183", username="ute", password="UTE.debian12"
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
    expected_prompt="qt5g@wl-srn-server-1-idf34",
)

_data_transfer_iperf = TafUeDataTransferProtocol(protocol_name="iperf",
                                                 app_server=_appserver_taf_ue,
                                                 interval=1,
                                                 version=2,
                                                 interface_name='ASKEY_4024',
                                                 dt_from_uepc=True)

_snmp_user_data = dict(
    userName="administrator",
    authKey="password",
    privKey="password",
    authProtocol="SHA1",
    privProtocol="AES-128",
)

_cu = CU(
    backhaul_site_oam_ip="10.44.88.152",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.88.152", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.88.152", username="Nemuadmin", password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="10.44.88.152", username="toor4nsn", password="oZPS0POrRieRtu"
)


_common_unit_pdu = ATEN(addr="10.42.61.174", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9])

_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[None],
    pdu_port=_common_unit_pdu.pdu_ports[5],
)

_airscale = Airscale(common_units=[_common_unit])

_lmi_card1 = LMI(product_code="093193A.X03",
               uart_mapping=[Local(port="COM5"), Local(port="COM6")],
               host=TestPc(default_ssh_connection_details=SshServiceDetails(addr="10.44.72.172",
                                                                            username="wro5gqt",
                                                                            password="5Gqtmoth")))

_lmi_card1.lmi_ssh_ru = { "addr": "192.168.101.1", "fh_interface": "eCPRI", "username": "serviceuser"}

_lmi_card1.rsi_port = "9093"

_5g_ru_pdu = Gude(addr="10.44.206.213", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8221-1",)

_ru = RU(
    ru_hw_group="cMAAr7.1_64T64R_4M",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.154", username="rfsw", password="f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0="
    ),
    lmp_connection=SshServiceDetails(
        addr="5.5.5.5", username="rfsw", password="f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0="
    ),
	serial_number="L1233203407",
	radio_type="AVQL",
	lmi=_lmi_card1,		   
    pdu_port=_5g_ru_pdu.pdu_ports[1],
)

_du = DU(airscale=_airscale, rus=[_ru], f1_m_ip_addr="10.44.88.152")

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_epcsim = EPCSim(
    mme_ip="10.45.168.53",
    mcc=555,
    mnc=10,
    tac=7151,
    default_ssh_connection_details=SshServiceDetails(
        addr="10.45.168.53", username="qt5g", password="5Gqtmoth!"
    ),
    dir_path="/home/ute/Robot_LteEmu",
    cfg_filename="Robot_LteEmu_Config",
)

_askey = TafUeAt(com_port='3',
                serial_number="a122e593",
                capabilities=['_5G'],
                ue_pc_address='10.44.72.172',
                ue_pc_login='wro5gqt',
                ue_pc_password='5Gqtmoth',
                proxy_mngr_port='80',
                ueproxy_force_release=False,
                ue_pc_expected_prompt='wro5gqt@(PLWR5G|plwr5g)5516',
                data_transfer=[_data_transfer_iperf])

_askey.ue_type = "askey"

_4g_ru_pdu = Gude(addr="10.44.206.27", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8221-1", snmp_user=_snmp_user_data)

_RadioModule = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=_4g_ru_pdu.pdu_ports[7],
)

_real_enb_pdu = Gude(addr="10.44.205.225", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8221-1", snmp_user=_snmp_user_data)

_common_unit_enb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.44.90.48", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_real_enb_pdu.pdu_ports[2],
)

_real_enb = Airscale(common_units=[_common_unit_enb])

_lte_real_enb = RealEnb(system_module=_real_enb, rms=[_RadioModule])

_attenuator = TopYoung(
    ip_addr="10.42.54.39",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24],
    model="TAS_24T24_02G6_90_1S_EJS",
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc_lte_nsa, _test_pc],
    gnbs=[_cbts],
    enbs=[_lte_real_enb],
    core=_epcsim,
    ues=[_askey],
    appserver=_appserver,
    attenuators=[_attenuator],
    tl_cloud_topology="4024",
)

tl.target_traffic_5G = {
    "IPERF_DURATION": "180", #seconds
    "MIN_DL": "320", #Mbits/sec
    "MAX_DL": "400", #Mbits/sec
    "MIN_UL": "40", #Mbits/sec
    "MAX_UL": "50", #Mbits/sec
    "cell_id_rf1": "13592320",
}

tl.attenuation = {
    "attenuation_port": "3001",
    "attenuation_5G": {3: 0, 4: 0, 5: 0, 6: 0},
    "attenuation_index": {"att":0},
    "pdu_model": "ATEN",
    "pdu_attenuator_ip": "10.44.206.123",
    "pdu_attenuator_port": "7",
}

tl.custom = {
    "real_enb": "True",          # True if 5G NSA TL is connected to LTE eNB
    "standalone": "False",         # True if SA, False for NSA
    "has_real_core": "True",      # True if TL using realcore
    "askey_pdu_ip": "10.44.177.21",
    "askey_pdu_port": "4",
}

tl.scf_variables = {
    "mrbts": "530951",
    "nrbts": "530951",
    "btsName": "QT-ASOE_5G_NSA_TDD-WRO-4024",
    "location": "WRO",
    "ntpServerIpAddrOrFqdnList": "10.42.248.70",
    "masterIpAddr": "10.42.0.106",
    "mcc": "310",
    "mnc": "260",
    "mncLength": "3",
    "nr_pmax": "200",
    "pMaxNROwnCell": "23",
    "enb_x2_ip": "10.44.90.48",
    "mplane_vlan": "480",
    "x2c_or_xnc_vlan": "481",
    "x2u_or_xnu_vlan": "482",
    "s1u_or_ngu_vlan": "483",
    "mplane_ip": "10.44.88.152",
    "mplane_ip_prefix": "26",
    "x2c_or_xnc_ip": "10.44.88.216",
    "x2c_or_xnc_ip_prefix": "26",
    "x2u_or_xnu_ip": "10.44.89.26",
    "x2u_or_xnu_ip_prefix": "26",
    "s1u_or_ngu_ip": "10.44.89.93",
    "s1u_or_ngu_ip_prefix": "26",
    "mplane_gw": "10.44.88.129",
    "x2c_or_xnc_gw": "10.44.88.193",
    "x2u_or_xnu_gw": "10.44.89.1",
    "s1u_or_ngu_gw": "10.44.89.65",
    "connectorLabel": "S-RF7",
}

tl.android_config_dir = os.path.dirname(os.path.abspath(__file__))

__all__ = ["tl"]