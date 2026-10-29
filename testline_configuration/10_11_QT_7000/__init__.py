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
from taf.config.testline.ue import TafUeAt
from taf.config.testline.airscale import Airscale, CommonUnit
from taf.config.testline.pdu import ENICS
from taf.config.testline.appserver import AppServer, TafUeAppServer

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.33.98.192",
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
                                                 interval=1,
                                                 version=2,
                                                 interface_name='ASKEY_7000',
                                                 dt_from_uepc=True)

_cu = CU(
    backhaul_site_oam_ip="10.33.54.133",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.33.54.133", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.33.54.133", username="Nemuadmin", password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="10.33.54.133", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_pdu = ENICS(addr="10.33.11.9", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
model="ENICS")

_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[None],
    pdu_port=_common_unit_pdu.pdu_ports[4],
)

_airscale = Airscale(common_units=[_common_unit])

_ru_pdu = ENICS(addr="10.35.50.151", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
model="ENICS")

_ru1 = RU(
    ru_hw_group="AVQL",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.1.2", username="rfsw", password="f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0="
    ),
    lmp_connection=SshServiceDetails(
        addr="5.5.5.5", username="rfsw", password="f6gh0K2nXq0O8XqVFkUuMtJnzuKm0U3box0QcYgugn0="
    ),
    pdu_port=_ru_pdu.pdu_ports[1],
)
_ru2 = RU(
    ru_hw_group="AHEB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.128", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(
        addr="5.5.5.5", username="root", password="root"
    ),
    pdu_port=_ru_pdu.pdu_ports[4],
)

_du = DU(airscale=_airscale, rus=[_ru1, _ru2], f1_m_ip_addr="10.33.54.133")

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_askey = TafUeAt(com_port='4',
            serial_number="60551a43",
            capabilities=['_4G', '_5G'],
            ue_pc_address='10.33.10.61',
            ue_pc_login='FIOUSRUSR',
            ue_pc_password='!SRkuivasranta2',
            proxy_mngr_port='80',
            ueproxy_force_release=False,
            ue_pc_expected_prompt='FIOUSRUSR@FIOU4LF00403',
            data_transfer=[_data_transfer_iperf]
)

_askey.ue_type = "askey"

tl = TestLine(
    test_pc=_test_pc,
    ues=[_askey],
    gnbs=[_cbts],
    appserver=_appserver,
    tl_cloud_topology="7000",
)

tl.target_traffic_4G = {
    "MIN_DL": "48", #Mbits/sec
    "MIN_UL": "12", #Mbits/sec
    "MAX_DL": "60", #Mbits/sec
    "MAX_UL": "15", #Mbits/sec
    "IPERF_DURATION": "60", #seconds
    "cell_id_rf1": "18739980"
}

tl.target_traffic_5G = {
    "MIN_DL": "320", #Mbits/sec
    "MIN_UL": "40", #Mbits/sec
    "MAX_DL": "400", #Mbits/sec
    "MAX_UL": "50", #Mbits/sec
    "IPERF_DURATION": "180", #seconds
    "cell_id_rf2": "18739980"
}

tl.custom = {
    "real_enb": "True",        # True if 5G NSA TL is connected to  LTE eNB
    "standalone": "False",       # True if SA, False for NSA
    "has_real_core": "True",    # True if TL using realcore
}

tl.scf_variables = {
    "mrbts": "73203",
    "nrbts": "73203",
    "lnbts": "73203",
    "adjGnbId": "73203",
    "bbmod_1_prodcode": "475792A.102",
    "bbmod_2_prodcode": "475792A.102",
    "btsName": "QT_TL10-ASIL_ABIP_5G_NSA_TDD_4G_FDD-OTAVA_73203",
    "location": "OULU",
    "mcc": "244",
    "mnc": "9",
    "mncLength": "2",
    "cPlaneIpAddr": "10.33.54.133",
    "phyCellId": "12",
    "tac": "9000",
    "earfcnDL": "1400",
    "earfcnUL": "19400",
    "nrCellId": "1199357953",
    "ipAddrPrim": "10.33.58.200",
    "ntpServerIpAddrOrFqdnList": "10.35.50.209",
    "masterIpAddr": "10.35.50.209",
    "physCellId": "69",
    "ln_pMax": "391",
    "nr_pMax": "200",
    "enb_x2_ip": "10.33.54.151",
    "amfIPAddress": "10.33.58.200",
    "fiveGsTac": "9000",                          

    #mplane
    "mplane_ip": "10.33.54.133",
    "lte_ip": "10.33.54.151",
    "mplane_ip_prefix": "27",
    "mplane_gw": "10.33.54.129",
    #x2c
    #"x2c_or_ngc_label": "x2c",
    #"x2c_or_ngc_vlan": "170",
    #"x2c_or_ngc_ip": "10.44.227.79",
    #"x2c_or_ngc_ip_prefix": "27",
    #"x2c_or_ngc_gw": "10.44.227.65",
    #x2u
    #"x2u_or_ngu_label": "x2u",
    #"x2u_or_ngu_vlan": "169",
    #"x2u_or_ngu_ip": "10.44.227.47",
    #"x2u_or_ngu_ip_prefix": "27",
    #"x2u_or_ngu_gw": "10.44.227.33",
}

tl.android_config_dir = os.path.dirname(os.path.abspath(__file__))

__all__ = ["tl"]
