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
from taf.config.testline.ue import TafUeAndroid, TafUeAt
from taf.config.testline.airscale import Airscale, CommonUnit
from taf.config.testline.pdu import ENICS
from taf.config.testline.appserver import AppServer, TafUeAppServer
from taf.config.testline.attenuator import AttenuationPort, HBTE                                                   

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.33.98.202",
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
    backhaul_site_oam_ip="10.33.54.143",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.33.54.143", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.33.54.143", username="Nemuadmin", password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="10.33.54.143", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_pdu = ENICS(addr="10.33.11.10", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
model="ENICS")

_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[None],
    pdu_port=_common_unit_pdu.pdu_ports[2],
    hardware_type="ASIL",
    hardware_version="A.102",
)

_airscale = Airscale(common_units=[_common_unit])

_attenuator = HBTE(
    ip_addr="172.31.6.233",
    port=5000,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="PA-16-16-6-127-0.5-B-S",
)

_5g_ru_pdu = ENICS(addr="10.33.16.144", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
model="ENICS")
                     
                              
_ru1 = RU(
    ru_hw_group="AZNA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.1.2", username="rfsw", password="f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0="
    ),
    lmp_connection=SshServiceDetails(
        addr="5.5.5.5", username="rfsw", password="f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0="
    ),
    pdu_port=_5g_ru_pdu.pdu_ports[5],
    attenuation_ports=[
        _attenuator.attenuator_ports[8],
    ],
)

_ru2 = RU(
    ru_hw_group="AZQP",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.1.2", username="rfsw", password="f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0="
    ),
    lmp_connection=SshServiceDetails(
        addr="5.5.5.5", username="rfsw", password="f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0="
    ),
    pdu_port=_5g_ru_pdu.pdu_ports[2],
)


_du = DU(airscale=_airscale, rus=[_ru1, _ru2], f1_m_ip_addr="10.33.54.143")

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_askey = TafUeAt(com_port='5',
            serial_number="2820ffee",
            capabilities=['_4G', '_5G'],
            ue_pc_address='10.33.10.60',
            ue_pc_login='FIOUSRUSR',
            ue_pc_password='!SRkuivasranta2',
            proxy_mngr_port='80',
            ueproxy_force_release=False,
            ue_pc_expected_prompt='FIOUSRUSR@FIOU4LF00313',
            data_transfer=[_data_transfer_iperf]
)

_askey.ue_type = "askey"

tl = TestLine(
    test_pc=_test_pc,
    ues=[_askey],
    gnbs=[_cbts],
    appserver=_appserver,
    attenuator=[_attenuator],
    tl_cloud_topology="7005",
)

tl.target_traffic_4G = {
    "IPERF_DURATION": "70",  # seconds
    "MIN_DL": "48", #Mbits/sec
    "MAX_DL": "60", #Mbits/sec
    "MIN_UL": "12", #Mbits/sec
    "MAX_UL": "15", #Mbits/sec
    "cell_id_rf1": "18742531",
}

tl.target_traffic_5G = {
    "IPERF_DURATION": "70",  # seconds
    "MIN_DL": "160", #Mbits/sec
    "MAX_DL": "200", #Mbits/sec
    "MIN_UL": "32", #Mbits/sec
    "MAX_UL": "40", #Mbits/sec
    "cell_id_rf1": "18742529",
}

tl.attenuation = {
    "attenuation_4G": {8:127},
    "attenuation_5G": {8:0},
    "attenuation_index": {"rf1":0},
    "pdu_model": "GUDE",
    "pdu_attenuator_version": "8221-1",
    "pdu_attenuator_ip": "172.31.6.233",
    "pdu_attenuator_rf1_port": "11",
    "att_max_value": "127",
    "att_off_value": "0",
    "attenuation_port": 5000,
}

tl.custom = {
    "real_enb": "True",  # True if 5G NSA TL is connected to LTE eNB
    "standalone": "False",  # True if SA, False for NSA
    "has_real_core": "True",  # True if TL using realcore
    "TDD_concurrent": "True",
}
                    
 
tl.scf_variables = {
    "mrbts": "73213",
    "btsName": "QT-ASIL_ABIO_5G_NSA_4G_TDD-OULU-7005",
    "location": "OULU",
    "bbmod_1_prodcode": "475266A.101",
    "bbmod_1_prodcode": "475266A.102",
    "X2Cplane_DN1_IPIF_id": "2", #########
    "cPlane_DN1_IPIF_id": "1",#########
    "uPlane_DN1_IPIF_id": "3",#########
    "secondEndpointPortId": "1",
    "mcc": "244",
    "mnc": "9",
    "mncLength": "2",
    "pmax": "373", 
    "nr_pmax": "390",
    "pMaxOwnCell": "26",
    "pMaxNROwnCell": "23",
    "tac": "9000",
    "nrCellId": "1199521825",
    "earfcn_1": "39000",
    "earfcn_2": "39400",
    "earfcn_3": "42490",
    "phyCellId_1": "111",
    "phyCellId_2": "258",
    "phyCellId_3": "257",
    "physCellId": "12",
    "lncel": "549",

    "masterIpAddr": "10.33.50.2",
    "ipAddrPrim": "10.33.58.200",
    "enb_x2_ip": "10.33.54.143",
    "mplane_ip": "10.33.54.143",
    "mplane_ip_prefix": "27",
    "mplane_gw": "10.44.229.129",
}

tl.android_config_dir = os.path.dirname(os.path.abspath(__file__))

__all__ = ["tl"]