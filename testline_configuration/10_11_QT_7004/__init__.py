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
        addr="10.33.98.201",
        username="ute",
        password="UTE.debian12",
    )
)
#########appserver##########
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
                                                 interface_name='ASKEY_7004',
                                                 dt_from_uepc=True)
  

_cu = CU(
    backhaul_site_oam_ip="10.33.54.142",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.33.54.142", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.33.54.142", username="Nemuadmin", password="nemuuser"
    ),
)

_du_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_pdu = ENICS(addr="10.33.11.10", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
model="ENICS")

_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[None],
    pdu_port=_common_unit_pdu.pdu_ports[1],
)

_airscale = Airscale(common_units=[_common_unit])

_ru_pdu = ENICS(
    addr="10.33.16.143",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
)

_ru1 = RU(
    ru_hw_group="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129",
        username="root",
        password="",
    ),
    lmp_connection=SshServiceDetails(
        addr="5.5.5.5",
        username="root",
        password="",
    ),
    pdu_port=_ru_pdu.pdu_ports[1],
)

_ru2 = RU(
    ru_hw_group="AHFIB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", 
        username="root", 
        password="",
    ),
    lmp_connection=SshServiceDetails(
        addr="5.5.5.5",
        username="root",
        password=""
    ),
    pdu_port=_ru_pdu.pdu_ports[2],
)

_du = DU(airscale=_airscale, rus=[_ru1, _ru2], f1_m_ip_addr="10.33.54.142")

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_askey = TafUeAt(com_port='7',
            serial_number="5b856385",
            capabilities=['_4G', '_5G'],
            ue_pc_address='10.33.10.58',
            ue_pc_login='FIOUSRUSR',
            ue_pc_password='!SRkuivasranta2',
            proxy_mngr_port='80',
            ueproxy_force_release=False,
            ue_pc_expected_prompt='FIOUSRUSR@FIOU5EF70845',
            data_transfer=[_data_transfer_iperf]
)

_askey.ue_type = "askey"

tl = TestLine(
    test_pc=_test_pc,
    ues=[_askey],
    gnbs=[_cbts],
    appserver=_appserver,
    tl_cloud_topology="7004",
)

tl.target_traffic_5G = {
    "MIN_DL": "160",  # Mbits/sec
    "MAX_DL": "200",  # Mbits/sec
    "MIN_UL": "40",  # Mbits/sec
    "MAX_UL": "50",  # Mbits/sec
    "IPERF_DURATION": "70",
    "cell_id_rf2": "18742273"
}

tl.target_traffic_4G = {
    "MIN_DL": "64",  # Mbits/sec
    "MAX_DL": "80",  # Mbits/sec
    "MIN_UL": "15",  # Mbits/sec
    "MAX_UL": "20",  # Mbits/sec
    "IPERF_DURATION": "70",  # seconds
    "cell_id_rf1": "18742273"
}

tl.custom = {
    "real_enb": "True",        # True if TL connected to LTE eNB
    "has_real_core": "True",    # True if TL not using EPCSim
}

tl.scf_variables = {
    "mrbts": "73212",
    "nrbts": "73212",
    "btsName": "QT-ASIB_ABIO_5G_NSA_4G_FDD-OULU-7004",
    "location": "OULU",
    "mcc": "244",
    "mnc": "9",
    "mncLength": "2",
    "cPlaneIpAddr": "10.33.54.142",               
    "phyCellId": "104",
    "tac": "9000",                              
    "earfcnDL": "900",
    "earfcnUL": "18900",
    "nrCellId": "1199505409",
    "ipAddrPrim": "10.33.58.200",        #Realcore mme address
    "syncInputType_prio1": "TOPF",                # no second sync defined
    "ntpServerIpAddrOrFqdnList": "10.35.50.209", 
    "masterIpAddr": "10.33.50.2",             
    "physCellId": "12",
    "nrx2link_257": "10.33.54.152",                # mplane_ip address
    "amfIPAddress": "10.33.58.200",
    "fiveGsTac": "9000",                          # For TLs OULU
    "connectorLabel": "EIF5",

    #mplane
    "mplane_ip": "10.33.54.142",
    "mplane_ip_prefix": "27",
    "mplane_gw": "10.33.54.129",
   

   #x2c
    "x2c_or_ngc_ip": "10.33.54.152",
    "x2c_or_ngc_ip_prefix": "27",

}

__all__ = ["tl"]