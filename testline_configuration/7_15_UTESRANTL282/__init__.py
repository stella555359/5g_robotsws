# This file was updated starting from 7_15_UTESRANTL211
#########################################
# TestLine TL282 Ulm (7_15_UTESRANTL282)#
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

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_snmp_user_data = dict(
    userName="user",
    authKey="qwer2009!",
    privKey="qwer2009!",
    authProtocol="SHA",
    privProtocol="AES",
)

# pdu1-281 - SMOD_pdu
# ---------------- START Power Switchs gNB_282
_pdu1_281 = Gude(
    addr="10.46.152.81",
    port_numbers=[3, 4],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# pdu1-292 - RMOD_pdu#1
_pdu1_292 = Gude(
    addr="10.46.152.92",
    port_numbers=[1, 2, 4, 5, 7, 8],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# pdu2-293 - RMOD_pdu#2
_pdu2_293 = Gude(
    addr="10.46.152.193",
    port_numbers=[10],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# pdu3-293 - RMOD_pdu#3
_pdu3_293 = Gude(
    addr="10.46.152.98",
    port_numbers=[1, 2, 4, 5, 7],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# ---------------- START RF Attenuators
# deul5gatt1-282
_rf_att_deul5gatt1_282 = HBTE(
    ip_addr="10.46.152.232",
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

# deul5gatt2-281
_rf_att_deul5gatt2_281 = HBTE(
    ip_addr="10.46.152.242",
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
        v4="10.47.14.73",
        v6="2a00:8a00:6000:2f21:0:47:14:8211",
        vlan_id=1482,
        routing_v4=RoutingInformation(gateway="10.47.14.70/29"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:2F21::47:14:820F/124"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.47.14.121",
        v6="2a00:8a00:6000:2f21:0:47:14:8242",
        vlan_id=1482,
        routing_v4=RoutingInformation(gateway="10.47.14.121/29"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:2F21::47:14:8240/124"),
    ),
    x2u=NetworkAddress(
        v4="10.47.14.105",
        v6="2a00:8a00:6000:2f21:0:47:14:8232",
        vlan_id=1482,
        routing_v4=RoutingInformation(gateway="10.47.14.104/29"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:2F21::47:14:8230/124"),
    ),
    s1u=NetworkAddress(
        v4="10.47.14.105",
        v6="2a00:8a00:6000:2f21:0:47:14:8232",
        vlan_id=1482,
        routing_v4=RoutingInformation(gateway="10.47.14.104/29"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:2F21::47:14:8230/124"),
    ),
    ngu=NetworkAddress(
        v4="10.47.14.105",
        v6="2a00:8a00:6000:2f21:0:47:14:8232",
        vlan_id=1482,
        routing_v4=RoutingInformation(gateway="10.47.14.104/29"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:2F21::47:14:8230/124"),
    ),
    ngc=NetworkAddress(
        v4="10.47.14.121",
        v6="2a00:8a00:6000:2f21:0:47:14:8242",
        vlan_id=1482,
        routing_v4=RoutingInformation(gateway="10.47.14.121/29"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:2F21::47:14:8240/124"),
    ),
    xnc=NetworkAddress(
        v4="10.47.14.121",
        v6="2a00:8a00:6000:2f21:0:47:14:8242",
        vlan_id=1482,
        routing_v4=RoutingInformation(gateway="10.47.14.121/29"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:2F21::47:14:8240/124"),
    ),
    xnu=NetworkAddress(
        v4="10.47.14.105",
        v6="2a00:8a00:6000:2f21:0:47:14:8232",
        vlan_id=1482,
        routing_v4=RoutingInformation(gateway="10.47.14.104/29"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:2F21::47:14:8230/124"),
    ),
)

_BBMOD1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171422949",
)

_BBMOD2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1241408102_",
)

_BBMOD3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIO",
    hardware_version="475266A.105",
    serial_number="DH234521798",
)

_BBMOD4 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1232105764",
)

_SMOD1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_BBMOD1, _BBMOD2, _BBMOD3],
    pdu_port=_pdu1_281.pdu_ports[3],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1234206416",
)

_SMOD2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        # ssh to the second System Module From the SMOD1: root@fct-0a:~ >ssh  toor4nsn@fct-4a
        addr="fct-4a",
        username="toor4nsn",
        password="oZPS0POrRieRtu",
    ),
    capacity_units=[_BBMOD4],
    pdu_port=_pdu1_281.pdu_ports[4],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1234206417",
)

_rmod1000_AHPMDG_21 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type=RadioTypes.AHPMDG,
    serial_number="K9242702532",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu1_292.pdu_ports[2],
    attenuation_ports=[
        _rf_att_deul5gatt1_282.attenuator_ports[1],
        _rf_att_deul5gatt1_282.attenuator_ports[2],
        _rf_att_deul5gatt1_282.attenuator_ports[3],
        _rf_att_deul5gatt1_282.attenuator_ports[4],
    ],
)

_rmod2000_AHPMDG_13 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type=RadioTypes.AHPMDG,
    serial_number="K9242706826",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.136", port=2323
    ),
    pdu_port=_pdu1_292.pdu_ports[5],
    attenuation_ports=[
        _rf_att_deul5gatt2_281.attenuator_ports[1],
        _rf_att_deul5gatt2_281.attenuator_ports[2],
        _rf_att_deul5gatt2_281.attenuator_ports[3],
        _rf_att_deul5gatt2_281.attenuator_ports[4],
    ],
)

_rmod3000_AHPMDG_12 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type=RadioTypes.AHPMDG,
    serial_number="K9242706927",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.134", port=2323
    ),
    pdu_port=_pdu1_292.pdu_ports[8],
    attenuation_ports=[
        _rf_att_deul5gatt2_281.attenuator_ports[17],
        _rf_att_deul5gatt2_281.attenuator_ports[18],
        _rf_att_deul5gatt2_281.attenuator_ports[19],
        _rf_att_deul5gatt2_281.attenuator_ports[20],
    ],
)

_rmod13_AHHB_17 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHHB,
    serial_number="LR243208077",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.134", port=2323
    ),
    pdu_port=_pdu1_292.pdu_ports[1],
    attenuation_ports=[
        _rf_att_deul5gatt1_282.attenuator_ports[25],
        _rf_att_deul5gatt1_282.attenuator_ports[26],
        _rf_att_deul5gatt1_282.attenuator_ports[27],
        _rf_att_deul5gatt1_282.attenuator_ports[28],
    ],
)

_rmod14_AHHB_18 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHHB,
    serial_number="LR243208079",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.134", port=2323
    ),
    pdu_port=_pdu1_292.pdu_ports[4],
    attenuation_ports=[
        _rf_att_deul5gatt2_281.attenuator_ports[9],
        _rf_att_deul5gatt2_281.attenuator_ports[10],
        _rf_att_deul5gatt2_281.attenuator_ports[11],
        _rf_att_deul5gatt2_281.attenuator_ports[12],
    ],
)

_rmod15_AHHB_19 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHHB,
    serial_number="LR241216087",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.134", port=2323
    ),
    pdu_port=_pdu1_292.pdu_ports[7],
    attenuation_ports=[
        _rf_att_deul5gatt2_281.attenuator_ports[25],
        _rf_att_deul5gatt2_281.attenuator_ports[26],
        _rf_att_deul5gatt2_281.attenuator_ports[27],
        _rf_att_deul5gatt2_281.attenuator_ports[28],
    ],
)

_rmod1800_AVQQ_19 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    radio_type=RadioTypes.AVQQ,
    serial_number="1M242507370",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.154", port=2323
    ),
    pdu_port=_pdu3_293.pdu_ports[1],
    attenuation_ports=[
        _rf_att_deul5gatt2_281.attenuator_ports[29],
        _rf_att_deul5gatt2_281.attenuator_ports[30],
        _rf_att_deul5gatt2_281.attenuator_ports[31],
        _rf_att_deul5gatt2_281.attenuator_ports[32],
    ],
)

_rmod2800_AVQQ_12 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    radio_type=RadioTypes.AVQQ,
    serial_number="1M242506309",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.158", port=2323
    ),
    pdu_port=_pdu3_293.pdu_ports[4],
    attenuation_ports=[
        _rf_att_deul5gatt2_281.attenuator_ports[13],
        _rf_att_deul5gatt2_281.attenuator_ports[14],
        _rf_att_deul5gatt2_281.attenuator_ports[15],
        _rf_att_deul5gatt2_281.attenuator_ports[16],
    ],
)

_rmod3800_AVQQ_11 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    radio_type=RadioTypes.AVQQ,
    serial_number="1M242507372",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.162", port=2323
    ),
    pdu_port=_pdu3_293.pdu_ports[7],
    attenuation_ports=[
        _rf_att_deul5gatt1_282.attenuator_ports[29],
        _rf_att_deul5gatt1_282.attenuator_ports[30],
        _rf_att_deul5gatt1_282.attenuator_ports[31],
        _rf_att_deul5gatt1_282.attenuator_ports[32],
    ],
)

_rmod1400_OFEGSA_10 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEGB,
    serial_number="DH243711352",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.133", port=2323
    ),
    pdu_port=_pdu2_293.pdu_ports[10],
    attenuation_ports=[
        _rf_att_deul5gatt1_282.attenuator_ports[5],
        _rf_att_deul5gatt1_282.attenuator_ports[6],
        _rf_att_deul5gatt1_282.attenuator_ports[7],
        _rf_att_deul5gatt1_282.attenuator_ports[8],
    ],
)

_rmod2400_OFEGSA_14 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEGB,
    serial_number="DH243711400",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.131", port=2323
    ),
    pdu_port=_pdu3_293.pdu_ports[2],
    attenuation_ports=[
        _rf_att_deul5gatt2_281.attenuator_ports[5],
        _rf_att_deul5gatt2_281.attenuator_ports[6],
        _rf_att_deul5gatt2_281.attenuator_ports[7],
        _rf_att_deul5gatt2_281.attenuator_ports[8],
    ],
)

_rmod3400_OFEGSA_12 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEGB,
    serial_number="DH243711402",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.132", port=2323
    ),
    pdu_port=_pdu3_293.pdu_ports[5],
    attenuation_ports=[
        _rf_att_deul5gatt2_281.attenuator_ports[21],
        _rf_att_deul5gatt2_281.attenuator_ports[22],
        _rf_att_deul5gatt2_281.attenuator_ports[23],
        _rf_att_deul5gatt2_281.attenuator_ports[24],
    ],
)

_airscale_TL282 = Airscale(common_units=[_SMOD1])
_airscale_gNB1 = DU(
    airscale=_airscale_TL282,
    rus=[
        _rmod1000_AHPMDG_21,
        _rmod1400_OFEGSA_10,
        _rmod1800_AVQQ_19,
        _rmod2000_AHPMDG_13,
        _rmod2400_OFEGSA_14,
        _rmod2800_AVQQ_12,
        _rmod3000_AHPMDG_12,
        _rmod3400_OFEGSA_12,
        _rmod3800_AVQQ_11,
    ],
)
_comnBTS_gNB1 = ClassicalBts(
    cu=_cu_gnb_1, dus=[_airscale_gNB1], global_bts_id=452821, instance_id=452821
)

# ----------------- START eNB Common --------------------TL282 #
_airscale_Common = Airscale(common_units=[_SMOD1])

_comnBTS_eNB1 = RealEnb(
    system_module=_airscale_Common,
    rms=[
        _rmod1000_AHPMDG_21,
        _rmod1400_OFEGSA_10,
        _rmod2000_AHPMDG_13,
        _rmod2400_OFEGSA_14,
        _rmod3000_AHPMDG_12,
        _rmod3400_OFEGSA_12,
        # _rmod13_AHHB_17,
        # _rmod14_AHHB_18,
        # _rmod15_AHHB_19,
    ],
    oam_ip=NetworkAddress(v4="10.47.14.73"),
)
# ----------------- STOP eNB Common --------------------TL282 #
# ----------------- START GSM Common --------------------TL282 #
_bts2g_gsm = Bts2G(
    system_module=_airscale_Common,
    rms=[
        _rmod1000_AHPMDG_21,
        _rmod2000_AHPMDG_13,
        _rmod3000_AHPMDG_12,
    ],
    bcf_id="10",
    master=_comnBTS_eNB1,
)

_bsc = BSC(
    name="BSC-414803",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.38.63.245", username="SYSTEM", password="SYSTEM"
    ),
)
# ----------------- STOP GSM Common --------------------TL282 #
# ---------------- START Core APP Server ------------------- #
_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="DEUL-appsrv10.ulm.nsn-rdnet.net",
        username="ute",
        password="UTE.debian12",
    ),
    network_interface_address="10.44.35.210",
    # iperf_path="iperf",
    # ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254],
)

_appserver = AppServer(_iperf_details_on_appserver)

_app_server_10 = TafUeAppServer(
    app_server_name="DEUL-appsrv10",
    # address="10.47.194.203",
    address="DEUL-appsrv10.ulm.nsn-rdnet.net",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.44.35.210",
    #    binary_path="iperf",
    #    ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254]
)

_app_server_10_for_PING = TafUeAppServer(
    app_server_name="DEUL-appsrv10",
    address="10.44.35.210",
    # address="DEUL5Gappsrv03.ulm.nsn-rdnet.net",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.44.35.210",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_10,
    interval=1,
    #    binary_path="/data/local/tmp/iperf",
    version=3,
    dt_from_uepc=True,
)

_data_transfer_ping = TafUeDataTransferProtocol(
    protocol_name="ping",
    app_server=_app_server_10_for_PING,
    interval=1,
)

_data_transfer_ftp = TafUeDataTransferProtocol(
    protocol_name="ftp",
    app_server=_app_server_10,
    interval=1,
)
# ---------------- END Core APP Server ------------------- #
# ---------------- START PDNs ------------------- #
_pdns = [
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsa"),
]

_tampereCore = RealCore(mcc="555", mnc="10", pdns=_pdns)
# ---------------- END PDNs.
# ---------------- START UEs Controll NUC PSc ------------------------ #
_ue_ctrl_NUC_pc1_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC1-282.intra.noklab.net",
    username="deul5g",
    password="Nuc2Ue4PzLab!",
    # addr="10.46.135.67", username="deul5g", password="Nuc2Ue4PzLab!"
)

_ue_ctrl_NUC_pc2_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC2-212.intra.noklab.net",
    username="deul5g",
    password="Nuc2Ue4PzLab!",
)
# ---------------- END UEs Controll NUC PSc ------------------------ #

# https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=776246841#HowTo/Allyouneedtoknow-QualcommMTPdevicesinUlm
# ---------------- START QC UE2: Qualcomm#28 ------------------------ #
_qualcomm28_sdx60 = TafUeAndroid(
    serial_number="df403ce",
    ue_pc_address="DEUL5GNUC1-212.intra.noklab.net",
    capabilities=[
        "REAL_UE",
        "REAL_ANDROID_UE",
        "REAL_QUALCOMM_UE",
        "UE_2",
    ],
    data_transfer=[_data_transfer_iperf, _data_transfer_ping, _data_transfer_ftp],
    ssh_connection_details=_ue_ctrl_NUC_pc1_ssh_details,
    ue_pc_port="8080",
)
# ----------------END QC UE1: Qualcomm#28 ------------------------ #

# https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1052877183#id-10Samsung(ExynosandQualcomm)-SamsungdevicesinuseinUlm
# ---------------- START QC UE1: S24 Ultra ------------------------ #
_S24_Ultra_41 = TafUeAndroid(
    # serial_number="R5CX92VJJ9M",
    serial_number="R5CX92VJKBL",
    ue_pc_address="DEUL5GNUC1-212.intra.noklab.net",
    # proxy_mngr_port=9955,  # ueproxy manager will not be visible unless proxy_mngr_port is configured! (default value: 9955 - used in autostart)
    capabilities=[
        "REAL_UE",
        "REAL_ANDROID_UE",
        "REAL_QUALCOMM_UE",
        "UE_4",
    ],
    data_transfer=[_data_transfer_iperf, _data_transfer_ping, _data_transfer_ftp],
    ssh_connection_details=_ue_ctrl_NUC_pc1_ssh_details,
    ue_pc_port="8080",  # If proxy_mngr_port is defined in Ue object ue_pc_port will be omitted!
    # pdu_port=_pdu1_360.pdu_ports[12],
)
# ----------------END QC UE1------------------------ #
# ---------------- START UE2: S24 ------------------------
_S24_18 = TafUeAndroid(
    serial_number="R3CX90524ZB",
    ue_pc_address="DEUL5GNUC1-282.intra.noklab.net",
    # proxy_mngr_port=9955,  # ueproxy manager will not be visible unless proxy_mngr_port is configured! (default value: 9955 - used in autostart)
    capabilities=[
        "REAL_UE",
        "REAL_ANDROID_UE",
        "REAL_Exynos_UE",
        "UE_3",
    ],
    data_transfer=[_data_transfer_iperf, _data_transfer_ping, _data_transfer_ftp],
    ssh_connection_details=_ue_ctrl_NUC_pc1_ssh_details,
    ue_pc_port="8080",  # If proxy_mngr_port is defined in Ue object ue_pc_port will be omitted!
    # pdu_port=_pdu1_360.pdu_ports[12],
)
# ---------------- END UE2 ------------------------
# ---------------- START Prototype_01: S25 ------------------------
_S25_Prototype_01 = TafUeAndroid(
    # serial_number="R3CX90524ZB",
    serial_number="00000ab48e446793",
    ue_pc_address="DEUL5GNUC1-282.intra.noklab.net",
    # proxy_mngr_port=9955,  # ueproxy manager will not be visible unless proxy_mngr_port is configured! (default value: 9955 - used in autostart)
    capabilities=[
        "REAL_UE",
        "REAL_ANDROID_UE",
        "REAL_Exynos_UE",
        "UE_1",
    ],
    data_transfer=[_data_transfer_iperf, _data_transfer_ping, _data_transfer_ftp],
    ssh_connection_details=_ue_ctrl_NUC_pc1_ssh_details,
    ue_pc_port="8080",  # If proxy_mngr_port is defined in Ue object ue_pc_port will be omitted!
    # pdu_port=_pdu1_360.pdu_ports[12],
)
# ---------------- END Prototype_01 ------------------------
# ---------------- START TEST PCs ------------------------ #
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="7-15-UTESRANTL282.ulm.nsn-rdnet.net",
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
    pdus=[_pdu1_281, _pdu2_293, _pdu3_293, _pdu1_292],
    core=_tampereCore,
    attenuators=[_rf_att_deul5gatt1_282, _rf_att_deul5gatt2_281],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_SRAN_NLG_1ASIB_1ABIA_2ABIO_3AHPMDB_3AHEGB_3AHHB_3AVQQ",
    # ues=[_S24_Ultra, _S24_18],
    ues=[_S24_Ultra_41, _qualcomm28_sdx60],
    bscs=[_bsc],
)

__all__ = ["tl"]
# ----------------------------------------- TL ----------------------------------------- #
