# This file was updated starting from 7_15_UTESRANTL211
#########################################
# TestLine TL285 Ulm (7_15_UTESRANTL285)#
#########################################
__maintainer__ = "Michele Bertolini"
__email__ = "Michele.Bertolini@nokia.com"

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

from taf.config.testline.pdn import PDN, PDPTypes

from taf.config.testline.appserver import AppServer

from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeMtk
from taf.config.testline import Airphone

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_snmp_user_data = dict(
    userName="user",
    authKey="qwer2009!",
    privKey="qwer2009!",
    authProtocol="SHA",
    privProtocol="AES",
)

# ---------------- START Power Switchs gNB_285
# pdu2-292 - RMOD_pdu's A1 A2 A3 A4 A5 A6 B1 B2
_pdu2_292 = Gude(
    addr="10.46.152.192",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# pdu2-291 - RMOD_pdu#2
_pdu2_291 = Gude(
    addr="10.46.133.28",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# pdu1-285 - SBTS (master) AirScale port A1 | Airphone (secondary) AirScale Port A2 |
_pdu1_285 = Gude(
    addr="10.46.152.85",
    port_numbers=[1, 2],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)


# ---------------- START RF Attenuators
_rf_att_deul5gatt1_285 = HBTE(
    ip_addr="10.46.152.235",
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

_rf_att_deul5gatt2_285 = HBTE(
    ip_addr="10.46.152.245",
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

# ---------------- START gNB-1 -------------------TL285#
_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.13.209",
        v6="2a00:8a00:6000:600c::1b04",
        vlan_id=1286,
        routing_v4=RoutingInformation(gateway="10.47.13.209/29"),
        routing_v6=RoutingInformation(gateway="GW:2a00:8a00:6000:600c::1b01/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.47.13.241",
        v6="2a00:8a00:6000:600c::1c03",
        vlan_id=1386,
        routing_v4=RoutingInformation(gateway="10.47.13.246/29"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1c01/120"),
    ),
    x2u=NetworkAddress(
        v4="10.47.13.249",
        v6="2a00:8a00:6000:600c::1d03",
        vlan_id=1386,
        routing_v4=RoutingInformation(gateway="10.47.13.254/29"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1d01/120"),
    ),
    s1u=NetworkAddress(
        v4="10.47.13.249",
        v6="2a00:8a00:6000:600c::1e03",
        vlan_id=1386,
        routing_v4=RoutingInformation(gateway="10.47.13.254/29"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1e01/120"),
    ),
    ngu=NetworkAddress(
        v4="10.47.13.249",
        v6="2a00:8a00:6000:600c::1e03  ",
        vlan_id=1386,
        routing_v4=RoutingInformation(gateway="10.47.13.254/29"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1e01/120"),
    ),
    ngc=NetworkAddress(
        v4="10.47.13.241",
        v6="2a00:8a00:6000:600c::2003",
        vlan_id=1386,
        routing_v4=RoutingInformation(gateway="10.47.13.246/29"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::2004"),
    ),
    xnc=NetworkAddress(
        v4="10.47.13.241",
        v6="2a00:8a00:6000:600c::1c03",
        vlan_id=1386,
        routing_v4=RoutingInformation(gateway="10.47.13.246/29"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1c01/120"),
    ),
    xnu=NetworkAddress(
        v4="10.47.13.249",
        v6="2a00:8a00:6000:600c::1d03",
        vlan_id=1386,
        routing_v4=RoutingInformation(gateway="10.47.13.254/29"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1d01/120"),
    ),
)

_BBMOD1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="473096A.107",
    serial_number="L1225000452",
)

_BBMOD2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1241408148",
)

_BBMOD3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1243900138",
)

_SMOD1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_BBMOD1, _BBMOD2, _BBMOD3],
    pdu_port=_pdu1_285.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH211464406",
)
# RMOD_R-1: AHPMDB #03
_rmod1_AHPMDB_03 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type=RadioTypes.AHPMDB,
    serial_number="EA223662686",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu2_292.pdu_ports[2],
    attenuation_ports=[
        _rf_att_deul5gatt1_285.attenuator_ports[1],
        _rf_att_deul5gatt1_285.attenuator_ports[2],
        _rf_att_deul5gatt1_285.attenuator_ports[3],
        _rf_att_deul5gatt1_285.attenuator_ports[4],
    ],
)

# RMOD_R-2: AHPMDB #02
_rmod2_AHPMDB_02 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type=RadioTypes.AHPMDB,
    serial_number="EA223662696",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.136", port=2323
    ),
    pdu_port=_pdu2_292.pdu_ports[5],
    attenuation_ports=[
        _rf_att_deul5gatt2_285.attenuator_ports[1],
        _rf_att_deul5gatt2_285.attenuator_ports[2],
        _rf_att_deul5gatt2_285.attenuator_ports[3],
        _rf_att_deul5gatt2_285.attenuator_ports[4],
    ],
)

# RMOD_R-3: AHPMDB #01
_rmod3_AHPMDB_01 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type=RadioTypes.AHPMDB,
    serial_number="EA223662811",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.134", port=2323
    ),
    pdu_port=_pdu2_292.pdu_ports[8],
    attenuation_ports=[
        _rf_att_deul5gatt1_285.attenuator_ports[17],
        _rf_att_deul5gatt1_285.attenuator_ports[18],
        _rf_att_deul5gatt1_285.attenuator_ports[19],
        _rf_att_deul5gatt1_285.attenuator_ports[20],
    ],
)

# RMOD_R-19: AEQQ #03  NRCELL-173 (202335173Q3)
_rmod19_AEQQ_03 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    radio_type=RadioTypes.AEQQ,
    serial_number="1M224104228",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.154", port=2323
    ),
    pdu_port=_pdu2_291.pdu_ports[1],
    attenuation_ports=[
        _rf_att_deul5gatt1_285.attenuator_ports[29],
        _rf_att_deul5gatt1_285.attenuator_ports[30],
        _rf_att_deul5gatt1_285.attenuator_ports[31],
        _rf_att_deul5gatt1_285.attenuator_ports[32],
    ],
)

# RMOD_R-20: AEQQ #02  NRCELL-172 (202335173Q2)
_rmod20_AEQQ_02 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    radio_type=RadioTypes.AEQQ,
    serial_number="1M224104247",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.158", port=2323
    ),
    pdu_port=_pdu2_291.pdu_ports[4],
    attenuation_ports=[
        _rf_att_deul5gatt2_285.attenuator_ports[13],
        _rf_att_deul5gatt2_285.attenuator_ports[14],
        _rf_att_deul5gatt2_285.attenuator_ports[15],
        _rf_att_deul5gatt2_285.attenuator_ports[16],
    ],
)

# RMOD_R-4: AEQQ #01  NRCELL-171 (202335173Q1)
_rmod21_AEQQ_01 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    radio_type=RadioTypes.AEQQ,
    serial_number="1M224104249",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.162", port=2323
    ),
    pdu_port=_pdu2_291.pdu_ports[7],
    attenuation_ports=[
        _rf_att_deul5gatt2_285.attenuator_ports[29],
        _rf_att_deul5gatt2_285.attenuator_ports[30],
        _rf_att_deul5gatt2_285.attenuator_ports[31],
        _rf_att_deul5gatt2_285.attenuator_ports[32],
    ],
)

# RMOD_R-7: AHEGHA #11
_rmod7_AHEGHA_11 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEGB,
    serial_number="K9244426653",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.133", port=2323
    ),
    pdu_port=_pdu2_291.pdu_ports[2],
    attenuation_ports=[
        _rf_att_deul5gatt1_285.attenuator_ports[5],
        _rf_att_deul5gatt1_285.attenuator_ports[6],
        _rf_att_deul5gatt1_285.attenuator_ports[7],
        _rf_att_deul5gatt1_285.attenuator_ports[8],
    ],
)

# RMOD_R-8: AHEGHA #12
_rmod8_AHEGHA_12 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEGB,
    serial_number="K9244426654",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.131", port=2323
    ),
    pdu_port=_pdu2_291.pdu_ports[5],
    attenuation_ports=[
        _rf_att_deul5gatt2_285.attenuator_ports[5],
        _rf_att_deul5gatt2_285.attenuator_ports[6],
        _rf_att_deul5gatt2_285.attenuator_ports[7],
        _rf_att_deul5gatt2_285.attenuator_ports[8],
    ],
)

# RMOD_R-9: AHEGHA #13
_rmod9_AHEGHA_13 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEGB,
    serial_number="K9244426669",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.132", port=2323
    ),
    pdu_port=_pdu2_291.pdu_ports[8],
    attenuation_ports=[
        _rf_att_deul5gatt2_285.attenuator_ports[21],
        _rf_att_deul5gatt2_285.attenuator_ports[22],
        _rf_att_deul5gatt2_285.attenuator_ports[23],
        _rf_att_deul5gatt2_285.attenuator_ports[24],
    ],
)

_airscale_TL285 = Airscale(common_units=[_SMOD1])
_airscale_gNB1 = DU(
    airscale=_airscale_TL285,
    rus=[
        _rmod1_AHPMDB_03,
        _rmod2_AHPMDB_02,
        _rmod3_AHPMDB_01,
        _rmod19_AEQQ_03,
        _rmod20_AEQQ_02,
        _rmod21_AEQQ_01,
    ],
)
_comnBTS_gNB1 = ClassicalBts(
    cu=_cu_gnb_1, dus=[_airscale_gNB1], global_bts_id=2851, instance_id=2851
)

# ----------------- START eNB Common --------------------TL285 #
_airscale_Common = Airscale(common_units=[_SMOD1])

_comnBTS_eNB1 = RealEnb(
    system_module=_airscale_Common,
    rms=[
        _rmod1_AHPMDB_03,
        _rmod2_AHPMDB_02,
        _rmod3_AHPMDB_01,
        _rmod7_AHEGHA_11,
        _rmod8_AHEGHA_12,
        _rmod9_AHEGHA_13,
    ],
    oam_ip=NetworkAddress(v4="10.47.13.209"),
)
# ----------------- STOP eNB Common --------------------TL285 #

# ----------------- START GSM Common --------------------TL285 #
_bts2g_gsm = Bts2G(
    system_module=_airscale_Common,
    rms=[
        _rmod1_AHPMDB_03,
        _rmod2_AHPMDB_02,
        _rmod3_AHPMDB_01,
    ],
    bcf_id="10",
    master=_comnBTS_eNB1,
)

_bsc = BSC(
    name="BSC-22",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.38.63.245", username="SYSTEM", password="SYSTEM"
    ),
)
# ----------------- STOP GSM Common --------------------TL285 #

# ---------------- START Core APP Server ------------------- #
_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="DEUL5Gappsrv03.ulm.nsn-rdnet.net",
        username="ute",
        password="UTE.debian12",
    ),
    network_interface_address="10.47.194.203",
    # iperf_path="iperf",
    # ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254],
)

_appserver = AppServer(_iperf_details_on_appserver)

# DEUL5Gappsrv03
_app_server_03 = TafUeAppServer(
    app_server_name="DEUL5Gappsrv03",
    # address="10.47.194.203",
    address="DEUL5Gappsrv03.ulm.nsn-rdnet.net",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.203",
    #    binary_path="iperf",
    #    ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254]
)

_app_server_03_for_PING = TafUeAppServer(
    app_server_name="DEUL5Gappsrv03",
    address="10.47.194.203",
    # address="DEUL5Gappsrv03.ulm.nsn-rdnet.net",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.203",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_03,
    interval=1,
    #    binary_path="/data/local/tmp/iperf",
    version=3,
    dt_from_uepc=True,
)

_data_transfer_ping = TafUeDataTransferProtocol(
    protocol_name="ping",
    app_server=_app_server_03_for_PING,
    interval=1,
)

_data_transfer_ftp = TafUeDataTransferProtocol(
    protocol_name="ftp",
    app_server=_app_server_03,
    interval=1,
)
# ---------------- END Core APP Server ------------------- #

# ---------------- START PDNs ------------------- #
_pdns = [
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsa"),
]

_tampereCore = RealCore(mcc="555", mnc="10", pdns=_pdns)
# ---------------- END PDNs.

# ---------------- START QC UE1: Qualcomm#45 SDX65 ------------------------ #
_ue_ctrl_pc1_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC1-285.intra.noklab.net",
    username="deul5g",
    password="Nuc2Ue4PzLab!",
    # addr="10.46.135.67", username="deul5g", password="Nuc2Ue4PzLab!"
)

_qualcomm45_sdx65 = TafUeAndroid(
    serial_number="ade6a19a",
    # ue_pc_address="10.46.135.67",
    ue_pc_address="DEUL5GNUC1-285.intra.noklab.net",
    # proxy_mngr_port=9955,  # ueproxy manager will not be visible unless proxy_mngr_port is configured! (default value: 9955 - used in autostart)
    capabilities=[
        "REAL_UE",
        "REAL_ANDROID_UE",
        "REAL_QUALCOMM_UE",
        "UE_1",
    ],
    data_transfer=[_data_transfer_iperf, _data_transfer_ping, _data_transfer_ftp],
    ssh_connection_details=_ue_ctrl_pc1_ssh_details,
    ue_pc_port="8080",  # If proxy_mngr_port is defined in Ue object ue_pc_port will be omitted!
    # pdu_port=_pdu2_292.pdu_ports[12],
)
# ----------------END QC UE1: Qualcomm#45 SDX65 ------------------------ #

# ---------------- START MTK UE1 ------------------------
_ue_ctrl_pc2_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC2-285.intra.noklab.net", username="deul5g", password="Nuc2Ue4PzLab!"
)

# _mtk_data_transfer_iperf = TafUeDataTransferProtocol(
#     protocol_name="iperf",
#     app_server=_app_server_47,
#     interval=1,
#     #    binary_path="/data/local/tmp/iperf",
#     version=2,
#     dt_from_uepc=True,
# )

# _mtk55 = TafUeMtk(
#    ue_pc_address="10.46.135.54",
#    ue_pc_port=1234,
#    serial_number="0123456789ABCDEF",
#    data_transfer=[
#        _mtk_data_transfer_iperf,
#    ],
#    com_port="auto",
#    edb_file_path="auto",
#    log_filter="2.Gen98_Default_Standard",
#    imei="35190103413004",  # needs to be updated
#    imsi="540017000001125",  # needs to be updated
#    pdns=_pdns,
#    default_pdn_name="ulmsa",
#    capabilities=["REAL_UE", "REAL_MTK_UE", "UE_1"],
# )

# Mediatek#58 M80 Figeac
_mtk58asAndroid = TafUeAndroid(
    serial_number="0123456789ABCDEF",
    ue_pc_address="DEUL5GNUC2-285.intra.noklab.net",
    capabilities=["REAL_UE", "REAL_MTK_UE", "UE_2"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc2_ssh_details,
    ue_pc_port="8080",
)
# ---------------- END MTK UE1 ------------------------

# ---------------- START Airphone UE0 ------------------------
_airphone = Airphone(
    egate=SshServiceDetails("", ""),
    l2_ssh_connection_details=SshServiceDetails("", ""),
    l3_ssh_connection_details=SshServiceDetails("", ""),
    l1=Airscale(
        common_units=[
            CommonUnit(
                lmp_connection=SshServiceDetails(
                    "192.168.200.1", "toor4nsn", password="oZPS0POrRieRtu"
                ),
                hardware_type="ASIL",
                capacity_units=[
                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIO"),
                    CapacityUnit(addr="192.168.253.85", hardware_type="ABIO"),
                ],
                pdu_port=_pdu2_291.pdu_ports[3],
            )
        ]
    ),
)
# ---------------- END Airphone UE0 ------------------------

# ---------------- START TEST PCs ------------------------ #
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        # addr="10.47.12.85", username="ute", password="ute"
        addr="7-15-UTESRANTL285.ulm.nsn-rdnet.net",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[
        Connection(interface="eth1", device=_SMOD1, interface_type="lmp"),
        _airphone,
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
    pdus=[_pdu2_291, _pdu2_292],
    core=_tampereCore,
    attenuators=[_rf_att_deul5gatt1_285, _rf_att_deul5gatt2_285],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_SRAN_NLG_1ASIB_1ABIA_2ABIO_3AHPMDB_3AHEGB_3AHHB_3AEQQ",
    ues=[_airphone, _qualcomm45_sdx65, _mtk58asAndroid],
    bscs=[_bsc],
)

__all__ = ["tl"]
# ----------------------------------------- TL ----------------------------------------- #
