# This file was updated starting from 7_15_UTESRANTL285
#########################################
# TestLine TL286 Ulm (7_15_UTESRANTL286)#
#########################################
__maintainer__ = "Giangiacomo Guglielmini"
__email__ = "giangiacomo.guglielmini@nokia.com"

import os

from typing import Optional, List, Union
from enum import Enum

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.bts2g import Bts2G
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.attenuator import TopYoung, JFW
from taf.config.testline import RoutingInformation
from taf.config.testline.core import RealCore
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.attenuator import HBTE
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)

from taf.config.testline.pdn import PDN, PDPTypes, PDNTafUeAndroidDetails, PDNAndroidDetails

from taf.config.testline.appserver import AppServer

from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeMtk
from taf.config.testline.lmi import SerialOverTcp, Remote

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_snmp_user_data = dict(
    userName="user",
    authKey="qwer2009!",
    privKey="qwer2009!",
    authProtocol="SHA",
    privProtocol="AES",
)

# ---------------- START Power Switchs
# pdu1-292 - RMOD_pdu
_pdu1_292 = Gude(
    addr="10.46.152.92",
    port_numbers=[3, 6, 9],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# pdu1-291 - RMOD_pdu#1
_pdu1_291 = Gude(
    addr="10.46.152.91",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# pdu1-285 - SMOD_pdu
_pdu1_285 = Gude(
    addr="10.46.152.85",
    port_numbers=[3, 12],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# ---------------- START RF Attenuators
_gNB286_rf_att_1 = HBTE(
    ip_addr="10.46.152.236",
    port="5000",
    attenuation_port_numbers=[
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        15,
        16,
        17,
        18,
        19,
        20,
        21,
        22,
        23,
        24,
        25,
        26,
        27,
        28,
        29,
        30,
        31,
        32,
    ],
    version=None,
    model="PA-16-16-6-127-0.5-B-S",
)

_gNB286_rf_att_2 = HBTE(
    ip_addr="10.46.152.246",
    port="5000",
    attenuation_port_numbers=[
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        15,
        16,
        17,
        18,
        19,
        20,
        21,
        22,
        23,
        24,
        25,
        26,
        27,
        28,
        29,
        30,
        31,
        32,
    ],
    version=None,
    model="PA-16-16-6-127-0.5-B-S",
)
# ---------------- END RF Attenuators

# ---------------- START gNB-1 -------------------TL286#
_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.13.210",
        v6="",
        vlan_id=1286,
        routing_v4=RoutingInformation(gateway="10.47.13.214/29"),
        routing_v6=RoutingInformation(gateway=""),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.47.13.242",
        v6="",
        vlan_id=1386,
        routing_v4=RoutingInformation(gateway="10.47.13.246/29"),
        routing_v6=RoutingInformation(gateway=""),
    ),
    x2u=NetworkAddress(
        v4="10.47.13.250",
        v6="",
        vlan_id=1386,
        routing_v4=RoutingInformation(gateway="10.47.13.254/29"),
        routing_v6=RoutingInformation(gateway=""),
    ),
    s1u=NetworkAddress(
        v4="10.47.13.250",
        v6="",
        vlan_id=1386,
        routing_v4=RoutingInformation(gateway="10.47.13.254/29"),
        routing_v6=RoutingInformation(gateway=""),
    ),
    ngu=NetworkAddress(
        v4="10.47.13.250",
        v6="",
        vlan_id=1386,
        routing_v4=RoutingInformation(gateway="10.47.13.254/29"),
        routing_v6=RoutingInformation(gateway=""),
    ),
    ngc=NetworkAddress(
        v4="10.47.13.242",
        v6="",
        vlan_id=1386,
        routing_v4=RoutingInformation(gateway="10.47.13.246/29"),
        routing_v6=RoutingInformation(gateway=""),
    ),
    xnc=NetworkAddress(
        v4="10.47.13.242",
        v6="",
        vlan_id=1386,
        routing_v4=RoutingInformation(gateway="10.47.13.246/29"),
        routing_v6=RoutingInformation(gateway=""),
    ),
    xnu=NetworkAddress(
        v4="10.47.13.250",
        v6="",
        vlan_id=1386,
        routing_v4=RoutingInformation(gateway="10.47.13.254/29"),
        routing_v6=RoutingInformation(gateway=""),
    ),
)
_BBMOD1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173805331",
)
_BBMOD2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204206264",
)
_BBMOD3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1204706777",
)
_SMOD1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_BBMOD1, _BBMOD2, _BBMOD3],
    pdu_port=_pdu1_285.pdu_ports[3],
    hardware_type="ASIB",
    serial_number="L1222905906",
)

# RMOD_R-1: AHPMDB #06
_rmod1_AHPMDB_06 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type=RadioTypes.AHPMDB.value,
    serial_number="AS220107963",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu1_292.pdu_ports[3],
    attenuation_ports=[
        _gNB286_rf_att_1.attenuator_ports[1],
        _gNB286_rf_att_1.attenuator_ports[2],
        _gNB286_rf_att_1.attenuator_ports[3],
        _gNB286_rf_att_1.attenuator_ports[4],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.180.31", port="5001"),
        ],
    ),
)

# RMOD_R-2: AHPMDB #05
_rmod2_AHPMDB_05 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type=RadioTypes.AHPMDB.value,
    serial_number="AS213313839",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.136", port=2323
    ),
    pdu_port=_pdu1_292.pdu_ports[6],
    attenuation_ports=[
        _gNB286_rf_att_2.attenuator_ports[1],
        _gNB286_rf_att_2.attenuator_ports[2],
        _gNB286_rf_att_2.attenuator_ports[3],
        _gNB286_rf_att_2.attenuator_ports[4],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.180.32", port="5001"),
        ],
    ),
)

# RMOD_R-3: AHPMDB #04
_rmod3_AHPMDB_04 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type=RadioTypes.AHPMDB.value,
    serial_number="AS205305246",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.134", port=2323
    ),
    pdu_port=_pdu1_292.pdu_ports[9],
    attenuation_ports=[
        _gNB286_rf_att_2.attenuator_ports[17],
        _gNB286_rf_att_2.attenuator_ports[18],
        _gNB286_rf_att_2.attenuator_ports[19],
        _gNB286_rf_att_2.attenuator_ports[20],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.180.33", port="5001"),
        ],
    ),
)

# RMOD_R-19: AEQQ #04
_rmod19_AEQQ_04 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    radio_type=RadioTypes.AEQQ.value,
    serial_number="1M210912474",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.154", port=2323
    ),
    pdu_port=_pdu1_291.pdu_ports[2],
    attenuation_ports=[
        _gNB286_rf_att_1.attenuator_ports[29],
        _gNB286_rf_att_1.attenuator_ports[30],
        _gNB286_rf_att_1.attenuator_ports[31],
        _gNB286_rf_att_1.attenuator_ports[32],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.181.21", port="5001"),
        ],
    ),
)

# RMOD_R-20: AEQQ #05
_rmod20_AEQQ_05 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    radio_type=RadioTypes.AEQQ.value,
    serial_number="1M220620977",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.158", port=2323
    ),
    pdu_port=_pdu1_291.pdu_ports[5],
    attenuation_ports=[
        _gNB286_rf_att_2.attenuator_ports[13],
        _gNB286_rf_att_2.attenuator_ports[14],
        _gNB286_rf_att_2.attenuator_ports[15],
        _gNB286_rf_att_2.attenuator_ports[16],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.181.22", port="5001"),
        ],
    ),
)

# RMOD_R-21: AEQQ #06
_rmod21_AEQQ_06 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    radio_type=RadioTypes.AEQQ.value,
    serial_number="1M220620966",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.162", port=2323
    ),
    pdu_port=_pdu1_291.pdu_ports[2],
    attenuation_ports=[
        _gNB286_rf_att_2.attenuator_ports[29],
        _gNB286_rf_att_2.attenuator_ports[30],
        _gNB286_rf_att_2.attenuator_ports[31],
        _gNB286_rf_att_2.attenuator_ports[32],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.181.23", port="5001"),
        ],
    ),
)

# RMOD_R-7: AHEGB #11
_rmod7_AHEGB_11 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEGB.value,
    serial_number="EA211551610",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.133", port=2323
    ),
    pdu_port=_pdu1_291.pdu_ports[3],
    attenuation_ports=[
        _gNB286_rf_att_1.attenuator_ports[5],
        _gNB286_rf_att_1.attenuator_ports[6],
        _gNB286_rf_att_1.attenuator_ports[7],
        _gNB286_rf_att_1.attenuator_ports[8],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.180.37", port="5001"),
        ],
    ),
)

# RMOD_R-8: AHEGB #10
_rmod8_AHEGB_10 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEGB.value,
    serial_number="EA204451357",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.131", port=2323
    ),
    pdu_port=_pdu1_291.pdu_ports[6],
    attenuation_ports=[
        _gNB286_rf_att_2.attenuator_ports[5],
        _gNB286_rf_att_2.attenuator_ports[6],
        _gNB286_rf_att_2.attenuator_ports[7],
        _gNB286_rf_att_2.attenuator_ports[8],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.180.38", port="5001"),
        ],
    ),
)

# RMOD_R-9: AHEGB #12
_rmod9_AHEGB_12 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEGB.value,
    serial_number="EA211656524",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.132", port=2323
    ),
    pdu_port=_pdu1_291.pdu_ports[3],
    attenuation_ports=[
        _gNB286_rf_att_2.attenuator_ports[21],
        _gNB286_rf_att_2.attenuator_ports[22],
        _gNB286_rf_att_2.attenuator_ports[23],
        _gNB286_rf_att_2.attenuator_ports[24],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.180.39", port="5001"),
        ],
    ),
)

# RMOD_R-13: AHHB #12
_rmod13_AHHB_12 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHHB.value,
    serial_number="EA212054775",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.132", port=2323
    ),
    pdu_port=_pdu1_291.pdu_ports[1],
    attenuation_ports=[
        _gNB286_rf_att_1.attenuator_ports[25],
        _gNB286_rf_att_1.attenuator_ports[26],
        _gNB286_rf_att_1.attenuator_ports[27],
        _gNB286_rf_att_1.attenuator_ports[28],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.180.34", port="5001"),
        ],
    ),
)

# RMOD_R-14: AHHB #13
_rmod14_AHHB_13 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHHB.value,
    serial_number="EA212157315",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.132", port=2323
    ),
    pdu_port=_pdu1_291.pdu_ports[4],
    attenuation_ports=[
        _gNB286_rf_att_2.attenuator_ports[9],
        _gNB286_rf_att_2.attenuator_ports[10],
        _gNB286_rf_att_2.attenuator_ports[11],
        _gNB286_rf_att_2.attenuator_ports[12],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.180.35", port="5001"),
        ],
    ),
)

# RMOD_R-15: AHHB #11
_rmod15_AHHB_11 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHHB.value,
    serial_number="EA184676227",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.132", port=2323
    ),
    pdu_port=_pdu1_291.pdu_ports[7],
    attenuation_ports=[
        _gNB286_rf_att_2.attenuator_ports[25],
        _gNB286_rf_att_2.attenuator_ports[26],
        _gNB286_rf_att_2.attenuator_ports[27],
        _gNB286_rf_att_2.attenuator_ports[28],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.180.36", port="5001"),
        ],
    ),
)

_airscale_TL286 = Airscale(common_units=[_SMOD1])
_airscale_gNB1 = DU(
    airscale=_airscale_TL286,
    rus=[
        _rmod1_AHPMDB_06,
        _rmod2_AHPMDB_05,
        _rmod3_AHPMDB_04,
        _rmod7_AHEGB_11,
        _rmod8_AHEGB_10,
        _rmod9_AHEGB_12,
        _rmod19_AEQQ_04,
        _rmod20_AEQQ_05,
        _rmod21_AEQQ_06,
    ],
)
_comnBTS_gNB1 = ClassicalBts(
    cu=_cu_gnb_1, dus=[_airscale_gNB1], global_bts_id=2861, instance_id=2861
)

# ----------------- START eNB Common --------------------TL286 #
_airscale_Common = Airscale(common_units=[_SMOD1])

_comnBTS_eNB1 = RealEnb(
    system_module=_airscale_Common,
    rms=[
        _rmod1_AHPMDB_06,
        _rmod2_AHPMDB_05,
        _rmod3_AHPMDB_04,
        _rmod7_AHEGB_11,
        _rmod8_AHEGB_10,
        _rmod9_AHEGB_12,
        _rmod13_AHHB_12,
        _rmod14_AHHB_13,
        _rmod15_AHHB_11,
    ],
    oam_ip=NetworkAddress(v4="10.47.13.210"),
)
# ----------------- STOP eNB Common --------------------TL286 #

_bts2g_gsm = Bts2G(
    system_module=_airscale_Common,
    rms=[
        _rmod1_AHPMDB_06,
        _rmod2_AHPMDB_05,
        _rmod3_AHPMDB_04,
    ],
    bcf_id="17",
    master=_comnBTS_eNB1,
)

_bsc = BSC(
    name="BSC-22",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.38.63.245", username="SYSTEM", password="SYSTEM"
    ),
)

# ---------------- START Core APP Server -------------------
_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="DEUL5Gappsrv05.ulm.nsn-rdnet.net",
        username="ute",
        password="UTE.debian12",
    ),
    network_interface_address="10.47.194.205",
    # iperf_path="iperf",
    # ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254],
)

_appserver = AppServer(_iperf_details_on_appserver)

# DEUL5Gappsrv05
_app_server_for_IPERF_PING = TafUeAppServer(
    app_server_name="DEUL5Gappsrv05",
    address="DEUL5Gappsrv05.ulm.nsn-rdnet.net",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.205",
)

_app_server_for_FTP = TafUeAppServer(
    app_server_name="DEUL5Gappsrv05",
    address="DEUL5Gappsrv05.ulm.nsn-rdnet.net",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.205",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_for_IPERF_PING,
    #interface_name='rmnet_data0',    # specify EITHER "interface_name" in config OR "apn" in test
    interval=1,
    version=3,
    dt_from_uepc=True,
    server_close_delay=60,
    # binary_path="/data/local/tmp/iperf",
)

_data_transfer_ping = TafUeDataTransferProtocol(
    protocol_name="ping",
    app_server=_app_server_for_IPERF_PING,
    #interface_name='rmnet_data0',    # specify EITHER "interface_name" in config OR "apn" in test
    interval=1,
)

_data_transfer_ftp = TafUeDataTransferProtocol(
    protocol_name="ftp",
    app_server=_app_server_for_FTP,
    #interface_name='rmnet_data0',    # specify EITHER "interface_name" in config OR "apn" in test
    interval=1,
)
# ---------------- END Core APP Server ------------------- #


# ---------------- START PDNs ------------------- #
_pdns_for_ue1 = [
    PDNTafUeAndroidDetails(
        entryName="data_apn",
        apnName="ulmsa",
        apnType=['DEFAULT'],
        ),
    PDNTafUeAndroidDetails(
        entryName="voice_apn",
        apnName="ims5g",
        apnType=['MMS', 'IMS'],
        ),
]

_pdns_for_ue2 = [
    PDNTafUeAndroidDetails(
        entryName="data_apn",
        apnName="ulmsa",
        apnType=['DEFAULT'],
        ),
    PDNTafUeAndroidDetails(
        entryName="voice_apn",
        apnName="ims5g",
        apnType=['MMS', 'IMS'],
        ),
]


_realCore = RealCore(mcc="1", mnc="1")
# ---------------- END PDNs.

# ---------------- START UE CTRl PCs ------------------------
_ue_ctrl_NUC_pc1_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC286-1.intra.noklab.net",
    username="deul5g",
    password="Nuc2Ue4PzLab!"
)

_ue_ctrl_NUC_pc2_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC286-2.intra.noklab.net",
    username="deul5g",
    password="Nuc2Ue4PzLab!",
)

# ---------------- START UE1: Samsung S23 #01 (SM-S911B Qualcomm) ------------------------
_ue1 = TafUeAndroid(
    ssh_connection_details=_ue_ctrl_NUC_pc1_ssh_details,
    serial_number='RFCX50DQGXF',
    capabilities=["REAL_UE"
                  "REAL_ANDROID_UE",
                  "UE_2",    # temporarily referncing UE_1 as UE_2 as long as TA code has not been updated yet
                 ],
    ue_pc_address='DEUL5GNUC286-1.intra.noklab.net',
    data_transfer=[_data_transfer_iperf,
                   _data_transfer_ping,
                   _data_transfer_ftp],
    #phone_number='+3548247700026',
    ue_pc_port='8080',
    imei='351064278869897',
    imsi='001010000011061',
    pdns=_pdns_for_ue1,
    qualcomm_prototype=True,
    network_mode_switch_method='keyevents',
    path_to_network_mode_type='Mobile networks/Network mode',
    is_rooted='no',
    download_proxy_logs=True,
    compress_proxy_logs=True,
    allow_kw_logs=True,
)
# ---------------- END UE1: Samsung S23 #01 (SM-S911B Qualcomm) ------------------------

# ---------------- START UE2: Samsung S24 #01 (SM-S921B Exynos) ------------------------
_ue2 = TafUeAndroid(
    ssh_connection_details=_ue_ctrl_NUC_pc2_ssh_details,
    serial_number='RFCX31HVCVK',
    capabilities=["REAL_UE"
                  "REAL_ANDROID_UE",
                  "UE_1",    # temporarily referncing UE_2 as UE_1 as long as TA code has not been updated yet
                 ],
    ue_pc_address='DEUL5GNUC286-2.intra.noklab.net',
    data_transfer=[_data_transfer_iperf,
                   _data_transfer_ping,
                   _data_transfer_ftp],
    #phone_number='+3548247700026',
    ue_pc_port='8080',
    imei='355680654841576',
    imsi='001017700000090',
    pdns=_pdns_for_ue2,
    qualcomm_prototype=True,
    network_mode_switch_method='keyevents',
    path_to_network_mode_type='Mobile networks/Network mode',
    is_rooted='no',
    download_proxy_logs=True,
    compress_proxy_logs=True,
    allow_kw_logs=True,
)
# ---------------- END UE2: Samsung S24 #01 (SM-S921B Exynos) ------------------------

# ---------------- START TEST PCs ------------------------ #
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        # addr="10.47.12.86", username="ute", password="ute"
        addr="7-15-UTESRANTL286-1.ulm.nsn-rdnet.net",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[
        Connection(interface="eth1", device=_SMOD1, interface_type="lmp"),
    ],
)
# ---------------- END TEST PCs -------------------------- #

# ----------------------------------------- TL ----------------------------------------- #
tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    bts2g_objects=[_bts2g_gsm],
    gnbs=[_comnBTS_gNB1],
    enbs=[_comnBTS_eNB1],
    pdus=[_pdu1_285, _pdu1_291, _pdu1_292],
    core=_realCore,
    attenuators=[_gNB286_rf_att_1, _gNB286_rf_att_2],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_SRAN_NLG_1ASIB_1ABIA_2ABIO_3AHPMDB_3AHEGB_3AHHB_3AEQQ",
    ues=[_ue1, _ue2],
    bscs=[_bsc],
)

__all__ = ["tl"]
# ----------------------------------------- TL ----------------------------------------- #
