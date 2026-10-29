__maintainer__ = "QT WRO"
__team__ = "MN RAN RD T&V OTA&CI QT1"
__email__ = "I_AM_QT@internal.nsn.com"
__owner_email__ = "I_AM_QT@internal.nsn.com"


import os
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
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
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import PduPort, APC, ATEN
from taf.config.testline.appserver import AppServer, TafUeAppServer


_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.158.113", 
        username="ute", 
        password="UTE.debian12"
    )
)

_appserver_ssh = SshServiceDetails(
    addr="10.44.158.113", username="ute", password="UTE.debian12"
)

_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.44.184.204",
)

_appserver = AppServer(_iperf_details_on_appserver)

_appserver_taf_ue_WG = TafUeAppServer(app_server_name="wg-srn-iperf-728",
    address="10.44.184.246",
    user="qt5g",
    password="5Gqtmoth!",
    bind_interface_ip="10.44.184.246",
    expected_prompt="qt5g@wg-srn-iperf-728")

_data_transfer_iperf_WG = TafUeDataTransferProtocol(protocol_name="iperf",
                                                 app_server=_appserver_taf_ue_WG,
                                                 interval=1)                               #OPTIONAL

_snmp_user_data = dict(
    userName="administrator",
    authKey="password",
    privKey="password",
    authProtocol="SHA1",
    privProtocol="AES-128",
)

_cu = CU(
    backhaul_site_oam_ip="10.44.227.239",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.227.239", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.227.239", username="Nemuadmin", password="nemuuser"

    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="10.44.227.239", username="toor4nsn", password="oZPS0POrRieRtu"
)

_du_pdu = ATEN(
    addr="10.42.170.97",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
)

_du_pdu_port = PduPort(pdu=_du_pdu, port_no=5)

_du_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[None],
    pdu_port=_du_pdu_port,
)

_airscale = Airscale(common_units=[_du_common_unit])

_ru_pdu = ATEN(
    addr="10.42.168.169",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
)

_ru_pdu_port = PduPort(pdu=_ru_pdu, port_no=2) 

_ru = RU(
    ru_hw_group="AZNA",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34",
        username="root",
        password="w@=EIj7P6R0bVy85OjCVa^ho&8",
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.254.34",
        username="root",
        password="w@=EIj7P6R0bVy85OjCVa^ho&8",
    ),
    pdu_port=_ru_pdu_port,
)

_du = DU(airscale=_airscale, rus=[_ru], f1_m_ip_addr="10.44.227.239")

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_epcsim = EPCSim(
    mme_ip="10.44.184.204", #appserver gta
    mcc=244,
    mnc=8,
    tac=7201,  
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.184.204", username="qt5g", password="5Gqtmoth!"
    ),
    dir_path="",
    cfg_filename="",
)

_lmp_connection = SshServiceDetails(
    addr="5.5.5.5", username="user5", password="password5"
)

_android_4G = TafUeAndroid(
    serial_number="ad77b844",
    capabilities=["_4G"],
    ue_pc_address="10.42.172.188",
    data_transfer=[_data_transfer_iperf_WG],
    ssh_connection_details=SshServiceDetails(
        addr="10.42.172.188", username="wro5gqt", password="5Gqtmoth"
    ),
    proxy_mngr_port=5000,
    imsi="android",
    qualcomm_prototype=False,
    voice_call_dialing_timeout="30",
    network_mode_switch_method="secretcode",
    airplane_mode_switcher_text="Off|On",

)
_android_4G.ue_type = "android"

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    core=_epcsim,
    ues=[_android_4G],
    tl_cloud_topology="3111",
    appserver=_appserver,
    test_pcs=[_test_pc],
) 

tl.target_traffic_4G = {
    "MIN_DL": "40",  # Mbits/sec
    "MIN_UL": "12",  # Mbits/sec
    "MAX_DL": "50",  # Mbits/sec
    "MAX_UL": "15",  # Mbits/sec
    "IPERF_DURATION": "70",  # seconds
    "cell_id_rf1": "2252289",
}    
  
tl.custom = {
    "real_enb": "True",        # True if TL connected to LTE eNB
    "has_real_core": "True",    # True if TL not using EPCSim
}

tl.scf_variables = {
    # Sections IDs
    "MRBTS": "8798",
    "LNBTS": "8798",
    "LNCEL": "2222",
    "LNCEL_2": "3333",
    "LCELL_1": "1",
    "LCELL_2": "11",

    "bbmod_1_prodcode": "473096A.102",
    # Site specific variables
    "_top": "true",

    # MRBTS
    "btsName": "QT-ASIB-ABIA-4G-TDD-WRO-3111",

    # MRBTS/EQM/APEQM
    "location": "WRO",

    # MRBTS/LNBTS
    "mcc": "244",
    "mnc": "8",

    # MRBTS/LNBTS/LNMME
    "ipAddrPrim": "10.44.201.68",

    # MRBTS/LNBTS/LNCEL
    "lcrId_1": "1",
    "lcrId_2": "11",
    "phyCellId_1": "20",
    "phyCellId_2": "21",
    "tac_1": "7102",
    "tac_2": "7151",

    # MRBTS/LNBTS/LNCEL/LNCEL_TDD
    "earfcn_1": "39000",
    "earfcn_2": "39550",

    # MRBTS/MNL/MNLENT/SYNC/CLOCK/NTP
    "ntpServerIpAddrOrFqdnList": "10.42.162.252",

    # MRBTS/MNL/MNLENT/SYNC/CLOCK/TOP/TOPF
    "masterIpAddr": "10.42.161.252",

    # MRBTS/MNL/MNLENT/SYNC/TIME

    # MRBTS/TNLSVC/TNL/ETHSVC/ETHIF/VLANIF
    "vlanId": "175",

    # MRBTS/TNLSVC/TNL/IPNO/IPRT
    "gateway": "10.44.227.225",

    # MRBTS/TNLSVC/TNL/IPNO/IPIF/IPADDRESSV4
    "localIpAddr": "10.44.227.239",
}

tl.android_config_dir = os.path.dirname(os.path.abspath(__file__))

__all__ = ["tl"]
