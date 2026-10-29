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
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.airscale import Airscale, CommonUnit
from taf.config.testline.pdu import ENICS
from taf.config.testline.appserver import AppServer, TafUeAppServer

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.33.98.205",
        username="ute",
        password="UTE.debian12",
    )
)

_appserver_ssh = SshServiceDetails(
    addr="10.33.98.205", username="ute", password="UTE.debian12"
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
    backhaul_site_oam_ip="10.33.54.133",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.33.54.146", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.33.54.146", username="Nemuadmin", password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="10.33.54.146", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_pdu = ENICS(addr="10.33.11.10", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
model="ENICS")

_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[None],
    pdu_port=_common_unit_pdu.pdu_ports[5],
)

_airscale = Airscale(common_units=[_common_unit])

_ru_pdu = ENICS(addr="10.33.16.143", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
model="ENICS")

_ru1 = RU(
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
    pdu_port=_ru_pdu.pdu_ports[3],
)

_du = DU(airscale=_airscale, rus=[_ru1], f1_m_ip_addr="10.33.54.146")

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_android = TafUeAndroid(
    serial_number="0123456789ABCDEF",
        ssh_connection_details=SshServiceDetails(
        addr="10.33.10.67", username="FIOUSRUSR", password="!SRkuivasranta2"
    ),
    capabilities=['_4G'],
    ue_pc_address="10.33.10.67",
    data_transfer=[_data_transfer_iperf],
    proxy_mngr_port=80,  # ueproxy manager will not be visible unless proxy_mngr_port is configured! (default value: 9955 - used in autostart)
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
    ues=[_android],
    gnbs=[_cbts],
    appserver=_appserver,
    tl_cloud_topology="7001",
)

tl.target_traffic_4G = {
    "MIN_DL": "40",  # Mbits/sec
    "MIN_UL": "12",  # Mbits/sec
    "MAX_DL": "50",  # Mbits/sec
    "MAX_UL": "15",  # Mbits/sec
    "IPERF_DURATION": "70",  # seconds
    "cell_id_rf1": "18743297, 18743307",
}

tl.custom = {
    "real_enb": "True",        # True if TL connected to LTE eNB
    "has_real_core": "True",    # True if TL not using EPCSim
}

tl.scf_variables = {
    # Sections IDs
    "MRBTS": "73216",
    "LNBTS": "73216",
    "LNCEL": "2222",
    "LNCEL_2": "3333",
    "LCELL_1": "1",
    "LCELL_2": "11",
    "bbmod_1_prodcode": "473096A.103",

    # Site specific variables
    "_top": "true",

    # MRBTS
    "btsName": "QT-ASIB-ABIA-4G-TDD-OULU-7001",

    # MRBTS/EQM/APEQM
    "location": "OULU",

    # MRBTS/LNBTS
    "mcc": "244",
    "mnc": "9",

    # MRBTS/LNBTS/LNMME
    "ipAddrPrim": "10.33.58.200",

    # MRBTS/LNBTS/LNCEL
    "lcrId_1": "1",
    "lcrId_2": "11",
    "phyCellId_1": "18",
    "phyCellId_2": "19",
    "tac_1": "9000",
    "tac_2": "9000",

    # MRBTS/LNBTS/LNCEL/LNCEL_TDD
    "earfcn_1": "39000",
    "earfcn_2": "39550",

    # MRBTS/MNL/MNLENT/SYNC/CLOCK/NTP
    "ntpServerIpAddrOrFqdnList": "10.35.50.209",

    # MRBTS/MNL/MNLENT/SYNC/CLOCK/TOP/TOPF
    "masterIpAddr": "10.33.50.2",

    # MRBTS/MNL/MNLENT/SYNC/TIME

    # MRBTS/TNLSVC/TNL/IPNO/IPRT
    "gateway": "10.33.54.129",

    # MRBTS/TNLSVC/TNL/IPNO/IPIF/IPADDRESSV4
    "localIpAddr": "10.33.54.146",
}


tl.android_config_dir = os.path.dirname(os.path.abspath(__file__))

__all__ = ["tl"]
