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
    IperfDataTransferDetails,)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RU
from taf.config.testline.enb import RealEnb
from taf.config.testline.ue import TafUeAt
from taf.config.testline.airscale import Airscale, CommonUnit
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.appserver import AppServer, TafUeAppServer
from taf.config.testline.attenuator import TopYoung

_snmp_user_data = dict(
    userName="administrator",
    authKey="password",
    privKey="password",
    authProtocol="SHA1",
    privProtocol="AES-128",
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.75.212",
        username="ute",
        password="UTE.debian12",
    )
)

_test_pc_lte_nsa = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.75.20",
        username="ute",
        password="UTE.debian12",
    )
)

_appserver_ssh = SshServiceDetails(
    addr="10.44.75.212",
    username="ute",
    password="UTE.debian12"
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
    protocol_name="iperf",
    app_server=_appserver_taf_ue,
    interval=1,
    version=2,
    interface_name='ASKEY_4048',
    dt_from_uepc=True
)

_cu = CU(
    backhaul_site_oam_ip="10.44.65.73",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.65.73",
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.65.73",
        username="Nemuadmin",
        password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="10.44.65.73",
    username="toor4nsn",
    password="oZPS0POrRieRtu"
)

_common_unit_pdu = Gude(
    addr="10.44.177.91",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC", version="8221-1",
    snmp_user=_snmp_user_data
)

_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[None],
    pdu_port=_common_unit_pdu.pdu_ports[12],
)

_airscale = Airscale(common_units=[_common_unit])

_5g_ru_pdu = ATEN(
    addr="10.44.206.125",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8]
)

_ru = RU(
    ru_hw_group="AVQL",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.154",
        username="rfsw",
        password="HfBKgqIOogKY3BlGtiniuCI9bs76C8jYsAY6vw8f/Tw=",
    ),
    lmp_connection=SshServiceDetails(
        addr="5.5.5.5",
        username="rfsw",
        password="HfBKgqIOogKY3BlGtiniuCI9bs76C8jYsAY6vw8f/Tw=",
    ),
    pdu_port=_5g_ru_pdu.pdu_ports[4],
)

_du = DU(
    airscale=_airscale,
    rus=[_ru],
    f1_m_ip_addr="10.44.65.73"
    )

_cbts = ClassicalBts(
    cu=_cu,
    dus=[_du]
)

_4g_ru_pdu = ATEN(
    addr="10.42.61.175",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8]
)

_RadioModule = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.100.1",
        username="root",
        password="umniedziala"
    ),
    pdu_port=_4g_ru_pdu.pdu_ports[2],
)

_askey = TafUeAt(com_port='8',
                 serial_number="722f6e90",
                 capabilities=['_5G'],
                 ue_pc_address='10.42.22.53',
                 ue_pc_login='wro5gqt',
                 ue_pc_password='5Gqtmoth',
                 proxy_mngr_port='80',
                 ueproxy_force_release=False,
                 ue_pc_expected_prompt='wro5gqt@PLWR5G5598',
                 data_transfer=[_data_transfer_iperf]
)
							 
_askey.ue_type = "askey"

_real_enb_pdu = Gude(
    addr="10.44.177.91",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC", version="8221-1",
    snmp_user=_snmp_user_data
)

_common_unit_enb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.44.90.44",
        username="toor4nsn",
        password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_real_enb_pdu.pdu_ports[3],
    hardware_type="ASIA",
    hardware_version="A.202",
)

_common_unit_enb.tl_enb = "eNB_19"

_real_enb = Airscale(common_units=[_common_unit_enb])

_lte_real_enb = RealEnb(system_module=_real_enb)

_attenuator = TopYoung(
    ip_addr="10.42.61.129",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24],
    model="TAS_24T24_04G6_90_1S_EJS",
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc_lte_nsa, _test_pc],
    gnbs=[_cbts],
    enbs=[_lte_real_enb],
    core=None,
    ues=[_askey],
    appserver=_appserver,
    attenuators=[_attenuator],
    tl_cloud_topology="4048",
)

tl.target_traffic_5G = {
    "IPERF_DURATION": "180",  # seconds
    "MIN_DL": "320",  # Mbits/sec
    "MAX_DL": "400",  # Mbits/sec
    "MIN_UL": "40",  # Mbits/sec
    "MAX_UL": "50",  # Mbits/sec
    "cell_id_rf1": "13596674",
}

tl.attenuation = {
    "attenuation_port": "3001",
    "attenuation_5G": {1: 10, 2: 10},
    "eNB_attenuation": {24:0},
    "attenuation_index": {"att":0, "eNB": 0},
    "pdu_model": "ATEN",
    "pdu_attenuator_ip": "10.44.206.125",
    "pdu_attenuator_port": "8",
}

tl.custom = {
    "real_enb": "True",  # True if 5G NSA TL is connected to LTE eNB
    "standalone": "False",  # True if SA, False for NSA
    "has_real_core": "True",  # True if TL using realcore
    #"SB_pdu_ip": "10.42.61.175", SB_39 linked to 4048  
    #"SB_pdu_port": "5"
}

tl.scf_variables = {
    "mrbts": "531123",
    "nrbts": "531123",
    "btsName": "QT-ASOE_5G_NSA_TDD-WRO-4048",
    "location": "WRO",
    "ntpServerIpAddrOrFqdnList": "10.42.248.70",
    "masterIpAddr": "10.42.0.106",
    "mcc": "555",
    "mnc": "10",
    "mncLength": "2",
    "nr_pmax": "350",
    "pMaxNROwnCell": "33",
    "enb_x2_ip": "10.44.90.44",
    "mplane_vlan": "459",
    "x2c_or_xnc_vlan": "460",
    "x2u_or_xnu_vlan": "461",
    "s1u_or_ngu_vlan": "462",
    "mplane_ip": "10.44.65.73",
    "mplane_ip_prefix": "26",
    "x2c_or_xnc_ip": "10.44.65.137",
    "x2c_or_xnc_ip_prefix": "26",
    "x2u_or_xnu_ip": "10.44.65.229",
    "x2u_or_xnu_ip_prefix": "26",
    "s1u_or_ngu_ip": "10.44.66.6",
    "s1u_or_ngu_ip_prefix": "26",
    "mplane_gw": "10.44.65.65",
    "x2c_or_xnc_gw": "10.44.65.129",
    "x2u_or_xnu_gw": "10.44.65.193",
    "s1u_or_ngu_gw": "10.44.66.1",
    "connectorLabel": "S-RF7",
}

tl.android_config_dir = os.path.dirname(os.path.abspath(__file__))

__all__ = ["tl"]
