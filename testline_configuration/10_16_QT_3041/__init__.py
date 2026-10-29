__maintainer__ = "QT WRO"
__team__ = "MN RAN RD T&V OTA&CI QT1"
__email__ = "I_5GQT_WRO@internal.nsn.com"
__owner_email__ = "I_5GQT_WRO@internal.nsn.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.cloud_hosting import (
    NCIR,
    ControlNode,
    CloudDeployment,
    DeploymentFlavorStack,
    DeploymentNetworkStack,
    DeploymentVnfStack,
    ComputeNode,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RU
from taf.config.testline.core import EPCSim
from taf.config.testline.ue import Airphone, Android
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import PduPort, ATEN
from taf.config.testline.appserver import AppServer
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.ue import TafUeAt
from taf.config.testline.attenuator import Eubus

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.164.58", username="ute", password="UTE.debian12"
    )
)

#########appserver##########
_appserver_ssh = SshServiceDetails(
    addr="10.42.164.58", username="ute", password="UTE.debian12"
)

_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.44.184.204",
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
                                                 interface_name='ASKEY_3041',
                                                 dt_from_uepc=True)

_cu = CU(
    backhaul_site_oam_ip="10.44.227.4",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.227.4", username="robot", password="rastre1"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.227.4", username="Nemuadmin", password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_du_capacity_unit = CapacityUnit(addr="6.6.6.6")

_du_pdu = ATEN(
    addr="10.42.168.169",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
)

_du_pdu_port = PduPort(pdu=_du_pdu, port_no=1)

_du_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[_du_capacity_unit],
    pdu_port=_du_pdu_port,
)

_airscale = Airscale(common_units=[_du_common_unit])

_ru_pdu = ATEN(
    addr="10.42.168.250",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
)

_ru1 = RU(
    ru_hw_group="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="5.5.5.5", username="root", password=""),
    pdu_port=PduPort(pdu=_ru_pdu, port_no=8)
)

_ru2 = RU(
    ru_hw_group="AHFIB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="5.5.5.5", username="root", password=""),
    pdu_port=PduPort(pdu=_ru_pdu, port_no=6)
)

_du = DU(airscale=_airscale, rus=[_ru1, _ru2], f1_m_ip_addr="10.44.227.4")

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_askey = TafUeAt(com_port='4',
                 serial_number="68bd89c1",
                 capabilities=['_4G', '_5G'],
                 ue_pc_address='10.42.172.8',
                 ue_pc_login='wro5gqt',
                 ue_pc_password='5Gqtmoth',
                 proxy_mngr_port='80',
                 ueproxy_force_release=False,
                 ue_pc_expected_prompt='wro5gqt@PLWR5G5534',
                 data_transfer=[_data_transfer_iperf])

_askey.ue_type = "askey"

_attenuator = Eubus(
    ip_addr="10.42.171.28",
    port=23,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    cloud_hostings=[],
    core=None,
    ues=[_askey],
    attenuators=[_attenuator],
    appserver=_appserver,
    tl_cloud_topology="3041",
)

tl.target_traffic_5G = {
    "MIN_DL": "80",  # Mbits/sec
    "MIN_UL": "40",  # Mbits/sec
    "MAX_DL": "100",  # Mbits/sec
    "MAX_UL": "50",  # Mbits/sec
    "IPERF_DURATION": "70",
    "cell_id_rf2": "13583617"
}

tl.target_traffic_4G = {
    "MIN_DL": "64",  # Mbits/sec
    "MIN_UL": "16",  # Mbits/sec
    "MAX_DL": "80",  # Mbits/sec
    "MAX_UL": "20",  # Mbits/sec
    "IPERF_DURATION": "70",  # seconds
    "cell_id_rf1": "13583617"
}

tl.attenuation = {
    "attenuation_port": "23",
    "attenuation_index": {"att": 0},
    "pdu_model": "ATEN",
    "pdu_attenuator_ip": "10.42.168.250",
    "pdu_attenuator_port": "7",
    "attenuator_ip": "10.42.171.28",
    "attenuator_type": "EUBUS",
    "attenuation_4G": {5: 0, 6: 0, 7: 90, 8: 90},
    "attenuation_5G": {5: 0, 6: 0, 7: 0, 8: 0},
}

tl.custom = {
    "real_enb": "True",  # True if TL connected to LTE eNB
    "has_real_core": "True",  # True if TL not using EPCSim
    "askey_pdu_ip": "10.42.169.27",
    "askey_pdu_port": "2"
}

tl.scf_variables = {
    "mrbts": "53061",
    "nrbts": "53061",
    "bbmod_1_prodcode": "475266A.103",
    "btsName": "QT-ASIB_ABIO_5G_NSA_4G_FDD-WRO-3041",
    "location": "WRO_GTB_124",
    "mcc": "555",
    "mnc": "10",
    "mncLength": "2",
    "cPlaneIpAddr": "10.44.227.36",               # x2c_ip address
    "phyCellId": "104",
    "tac": "7171",                                # 7150 for TL in West Link, 7171 for TL in GTB
    "earfcnDL": "900",
    "earfcnUL": "18900",
    "nrCellId": "869351425",
    "ipAddrPrim": "10.44.201.68",             # TATRA NSA Realcore mme address
    "syncInputType_prio1": "TOPF",                # no second sync defined
    "ntpServerIpAddrOrFqdnList": "10.42.162.252", # GTB NTP (IPv4) Time Server
    "masterIpAddr": "10.42.161.252",              # GTB PTP (IPv4) Time Server
    "physCellId": "12",
    "nrx2link_257": "10.44.227.4",                # mplane_ip address
    "amfIPAddress": "0.0.0.0",
    "fiveGsTac": "7102",                          # For TLs in GTB
    "connectorLabel": "EIF5",

    #mplane
    "mplane_vlan": "168",
    "mplane_ip": "10.44.227.4",
    "mplane_ip_prefix": "27",
    "mplane_gw": "10.44.227.1",
    #x2c
    "x2c_or_ngc_label": "x2c",
    "x2c_or_ngc_vlan": "169",
    "x2c_or_ngc_ip": "10.44.227.36",
    "x2c_or_ngc_ip_prefix": "27",
    "x2c_or_ngc_gw": "10.44.227.33",
    #x2u
    "x2u_or_ngu_label": "x2u",
    "x2u_or_ngu_vlan": "170",
    "x2u_or_ngu_ip": "10.44.227.68",
    "x2u_or_ngu_ip_prefix": "27",
    "x2u_or_ngu_gw": "10.44.227.65",
    #no s1u interface
}

__all__ = ["tl"]
