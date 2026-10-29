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
from taf.config.testline.enb import RealEnb

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.33.98.195", username="ute", password="UTE.debian12",
    )
)

_test_pc_lte_nsa = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.33.98.196", username="ute", password="UTE.debian12"
    )
)

_appserver_ssh = SshServiceDetails(
    addr="10.33.98.201", username="ute", password="UTE.debian12"
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
   expected_prompt="srn@iperfU39")

_data_transfer_iperf = TafUeDataTransferProtocol(protocol_name="iperf",
                                                 app_server=_appserver_taf_ue,
                                                 interval=1,
                                                 version=2,
                                                 interface_name='ASKEY_7009',
                                                 dt_from_uepc=True)

_snmp_user_data = dict(
    userName="administrator",
    authKey="password",
    privKey="password",
    authProtocol="SHA1",
    privProtocol="AES-128",
)

_cu = CU(
    backhaul_site_oam_ip="10.33.54.136",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.33.54.136", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.33.54.136", username="Nemuadmin", password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="10.33.54.136", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_pdu = ENICS(
    addr="10.33.11.9",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
)

_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[None],
    pdu_port=_common_unit_pdu.pdu_ports[7],
)

_airscale = Airscale(common_units=[_common_unit])

_5g_ru_pdu = ENICS(
    addr="10.33.10.107",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
)

_ru = RU(
    ru_hw_group="AEUD",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.162",
        username="rfsw",
        password="PD6N1DB0lWmwomtNL2qd3ISypbiocdGRy7U+Lipiksk=",
    ),
    lmp_connection=SshServiceDetails(
        addr="5.5.5.5",
        username="rfsw",
        password="PD6N1DB0lWmwomtNL2qd3ISypbiocdGRy7U+Lipiksk=",
    ),
    pdu_port=_5g_ru_pdu.pdu_ports[1],
)   

_du = DU(airscale=_airscale, rus=[_ru], f1_m_ip_addr="10.33.54.136")

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_askey = TafUeAt(com_port='4',
            serial_number="400bda6d",
            capabilities=['_5G'],
            ue_pc_address='10.33.10.64',
            ue_pc_login='FIOUSRUSR',
            ue_pc_password='!SRkuivasranta2',
            proxy_mngr_port='80',
            ueproxy_force_release=False,
            ue_pc_expected_prompt='FIOUSRUSR@FIOU4LF00056',
            data_transfer=[_data_transfer_iperf]
)

_askey.ue_type = "askey"

_real_enb_pdu = ENICS(
    addr="10.33.11.9",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
)

_common_unit_enb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.33.54.137", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_real_enb_pdu.pdu_ports[8],
)

_4g_ru_pdu = ENICS(
    addr="10.35.50.151",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
)

_RadioModule = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=_4g_ru_pdu.pdu_ports[5],
)

_common_unit_enb.tl_enb = "eNB-7009"

_real_enb = Airscale(common_units=[_common_unit_enb])

_lte_real_enb = RealEnb(system_module=_real_enb, rms=[_RadioModule])

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc_lte_nsa, _test_pc],
    ues=[_askey],
    gnbs=[_cbts],
    enbs=[_lte_real_enb],
    appserver=_appserver,
    tl_cloud_topology="7009",
)

tl.target_traffic_5G = {
    "IPERF_DURATION": "180", #seconds
    "MIN_DL": "240", #Mbits/sec
    "MAX_DL": "300", #Mbits/sec
    "MIN_UL": "40", #Mbits/sec
    "MAX_UL": "50", #Mbits/sec
    "cell_id_rf1": "18740993"
}

tl.custom = {
    "real_enb": "True",  # True if 5G NSA TL is connected to LTE eNB
    "standalone": "False",  # True if SA, False for NSA
    "has_real_core": "True",  # True if TL using realcore
}

tl.scf_variables = {
    "mrbts": "73206",
    "nrbts": "73206",
    "bbmod_1_prodcode": "475266A.102",
    "btsName": "QT-ASIB_ABIO_5G_NSA_TDD_mmw-OULU-7009",
    "location": "OULU",
    "secondEndpointPortId": "1",
    "ntpServerIpAddrOrFqdnList": "10.35.50.209",
    "masterIpAddr": "10.33.50.2",
    "mcc": "244",
    "mnc": "9",
    "mncLength": "2",
    "freqBandIndicatorEutra": "1",
    "freqBandIndicatorNR": "261",
    "nrarfcn": "2079589",
    "nr_pmax": "160",
    "pMaxNROwnCell": "18",
    "enb_x2_ip": "10.33.54.137",
    "mplane_vlan": "1",
    "mplane_ip": "10.33.54.136",
    "mplane_ip_prefix": "27",
    "mplane_gw": "10.33.54.129",
}
tl.android_config_dir = os.path.dirname(os.path.abspath(__file__))

__all__ = ["tl"]
