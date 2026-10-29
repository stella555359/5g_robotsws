# This file was updated starting from 7_15_UTESRANTL286
#########################################
# TestLine TL902 Ulm (7_15_UTESRANTL902)#
#########################################
__maintainer__ = "Martin Alle"
__email__ = "Martin.Alle@nokia.com"

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
from taf.config.testline.radio import RU, RadioTypes, FujitsuRadioTypes
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

from taf.config.testline.pdn import (
    PDN,
    PDPTypes,
    PDNTafUeAndroidDetails,
    PDNAndroidDetails,
)
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
# pdu1-170 - RMOD_pdu
_pdu1_170 = Gude(
    addr="10.46.148.70",
    port_numbers=[1, 5, 6, 9, 11, 12],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# pdu2-170 - RMOD_pdu
_pdu2_170 = Gude(
    addr="10.46.148.170",
    port_numbers=[1, 2, 6, 7, 8],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# pdu1-164 - SMOD_pdu
_pdu1_164 = Gude(
    addr="10.46.148.64",
    port_numbers=[3, 4, 12],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# ---------------- START RF Attenuators
# deul5gatt4-165: HTBE 32-Port
_gNB902_rf_att_4_165 = HBTE(
    ip_addr="10.46.148.24",
    port="5000",
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 25, 26, 27, 28, 29, 30, 31, 32],
    version=None,
    model="PA-16-16-6-127-0.5-B-S",
)

# deul5gatt5-165: HTBE 16-Port
_gNB902_rf_att_5_165 = HBTE(
    ip_addr="10.46.148.25",
    port="5000",
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    version=None,
    model="PA-16-16-6-127-0.5-B-S",
)

# deul5gatt6-165: HTBE 16-Port
_gNB902_rf_att_6_165 = HBTE(
    ip_addr="10.46.148.26",
    port="5000",
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    version=None,
    model="PA-16-16-6-127-0.5-B-S",
)
# ---------------- END RF Attenuators
# ---------------- START gNB-1 -------------------#
_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.46.160.114",
        v6="",
        vlan_id=1401,
        routing_v4=RoutingInformation(gateway="10.46.160.254/28"),
        routing_v6=RoutingInformation(gateway=""),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.46.160.178",
        v6="",
        vlan_id=1401,
        routing_v4=RoutingInformation(gateway="10.46.160.254/28"),
        routing_v6=RoutingInformation(gateway=""),
    ),
    x2u=NetworkAddress(
        v4="10.46.160.146",
        v6="",
        vlan_id=1401,
        routing_v4=RoutingInformation(gateway="10.46.160.254/28"),
        routing_v6=RoutingInformation(gateway=""),
    ),
    s1u=NetworkAddress(
        v4="10.46.160.146",
        v6="",
        vlan_id=1401,
        routing_v4=RoutingInformation(gateway="10.46.160.254/28"),
        routing_v6=RoutingInformation(gateway=""),
    ),
    ngu=NetworkAddress(
        v4="10.46.160.146",
        v6="",
        vlan_id=1401,
        routing_v4=RoutingInformation(gateway="10.46.160.254/28"),
        routing_v6=RoutingInformation(gateway=""),
    ),
    ngc=NetworkAddress(
        v4="10.46.160.178",
        v6="",
        vlan_id=1401,
        routing_v4=RoutingInformation(gateway="10.46.160.254/28"),
        routing_v6=RoutingInformation(gateway=""),
    ),
    xnc=NetworkAddress(
        v4="10.46.160.178",
        v6="",
        vlan_id=1401,
        routing_v4=RoutingInformation(gateway="10.46.160.254/28"),
        routing_v6=RoutingInformation(gateway=""),
    ),
    xnu=NetworkAddress(
        v4="10.46.160.146",
        v6="",
        vlan_id=1401,
        routing_v4=RoutingInformation(gateway="10.46.160.254/28"),
        routing_v6=RoutingInformation(gateway=""),
    ),
)

# RMOD-1000: AHPMDG #01
_rmod1000_AHPMDG_01 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHPMDG.value,
    serial_number="BL2407C6GAG",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu1_170.pdu_ports[12],
    attenuation_ports=[
        _gNB902_rf_att_4_165.attenuator_ports[1],
        _gNB902_rf_att_4_165.attenuator_ports[2],
        _gNB902_rf_att_4_165.attenuator_ports[3],
        _gNB902_rf_att_4_165.attenuator_ports[4],
    ],
    #    lmi=SerialOverTcp(
    #        uart_mapping=[
    #            Remote(addr="10.46.148.", port="5001"),
    #        ],
    #    ),
)

# RMOD-1400: OFEGSA #06
_rmod1400_OFEGSA_06 = RU(
    ru_hw_group="3rd party O-RU",
    radio_type=FujitsuRadioTypes.OFEGSA.value,
    serial_number="00184",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu2_170.pdu_ports[6],
    attenuation_ports=[
        _gNB902_rf_att_4_165.attenuator_ports[5],
        _gNB902_rf_att_4_165.attenuator_ports[6],
        _gNB902_rf_att_4_165.attenuator_ports[7],
        _gNB902_rf_att_4_165.attenuator_ports[8],
    ],
)

# RMOD-1800: AQQQ #01
_rmod1800_AQQQ_01 = RU(
    ru_hw_group="cMAAr6.2_32T32R",
    radio_type=RadioTypes.AQQQ.value,
    serial_number="1M241904796",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.154", port=2323
    ),
    pdu_port=_pdu1_170.pdu_ports[1],
    attenuation_ports=[
        _gNB902_rf_att_4_165.attenuator_ports[29],
        _gNB902_rf_att_4_165.attenuator_ports[30],
        _gNB902_rf_att_4_165.attenuator_ports[31],
        _gNB902_rf_att_4_165.attenuator_ports[32],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.181.47", port="5001"),
        ],
    ),
)

# RMOD-2000: AHPMDG #04
_rmod2000_AHPMDG_04 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHPMDG.value,
    serial_number="BL2407C6GRR",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.136", port=2323
    ),
    pdu_port=_pdu2_170.pdu_ports[2],
    attenuation_ports=[
        _gNB902_rf_att_5_165.attenuator_ports[1],
        _gNB902_rf_att_5_165.attenuator_ports[2],
        _gNB902_rf_att_5_165.attenuator_ports[3],
        _gNB902_rf_att_5_165.attenuator_ports[4],
    ],
    #    lmi=SerialOverTcp(
    #        uart_mapping=[
    #            Remote(addr="10.46.148.", port="5001"),
    #        ],
    #    ),
)

# RMOD-2400: OFEGSA #03
_rmod2400_OFEGSA_03 = RU(
    ru_hw_group="3rd party O-RU",
    radio_type=FujitsuRadioTypes.OFEGSA.value,
    serial_number="00181",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu2_170.pdu_ports[7],
    attenuation_ports=[
        _gNB902_rf_att_5_165.attenuator_ports[5],
        _gNB902_rf_att_5_165.attenuator_ports[6],
        _gNB902_rf_att_5_165.attenuator_ports[7],
        _gNB902_rf_att_5_165.attenuator_ports[8],
    ],
)

# RMOD-2800: AQQQ #02
_rmod2800_AQQQ_02 = RU(
    ru_hw_group="cMAAr6.2_32T32R",
    radio_type=RadioTypes.AQQQ.value,
    serial_number="1M241904794",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.158", port=2323
    ),
    pdu_port=_pdu1_170.pdu_ports[5],
    attenuation_ports=[
        _gNB902_rf_att_5_165.attenuator_ports[13],
        _gNB902_rf_att_5_165.attenuator_ports[14],
        _gNB902_rf_att_5_165.attenuator_ports[15],
        _gNB902_rf_att_5_165.attenuator_ports[16],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.181.48", port="5001"),
        ],
    ),
)

# RMOD-3000: AHPMDG #02
_rmod3000_AHPMDG_02 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHPMDG.value,
    serial_number="BL2407C6EY6",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.134", port=2323
    ),
    pdu_port=_pdu1_164.pdu_ports[12],
    attenuation_ports=[
        _gNB902_rf_att_6_165.attenuator_ports[1],
        _gNB902_rf_att_6_165.attenuator_ports[2],
        _gNB902_rf_att_6_165.attenuator_ports[3],
        _gNB902_rf_att_6_165.attenuator_ports[4],
    ],
    #    lmi=SerialOverTcp(
    #    uart_mapping=[
    #        Remote(addr="10.46.148.", port="5001"),
    #    ],
    #    ),
)

# RMOD-3400: OFEGSA #05
_rmod3400_OFEGSA_05 = RU(
    ru_hw_group="3rd party O-RU",
    radio_type=FujitsuRadioTypes.OFEGSA.value,
    serial_number="00211",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu2_170.pdu_ports[8],
    attenuation_ports=[
        _gNB902_rf_att_6_165.attenuator_ports[5],
        _gNB902_rf_att_6_165.attenuator_ports[6],
        _gNB902_rf_att_6_165.attenuator_ports[7],
        _gNB902_rf_att_6_165.attenuator_ports[8],
    ],
)

# RMOD-3800: AQQQ #03
_rmod3800_AQQQ_03 = RU(
    ru_hw_group="cMAAr6.2_32T32R",
    radio_type=RadioTypes.AQQQ.value,
    serial_number="1M241904792",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.162", port=2323
    ),
    pdu_port=_pdu1_170.pdu_ports[6],
    attenuation_ports=[
        _gNB902_rf_att_6_165.attenuator_ports[13],
        _gNB902_rf_att_6_165.attenuator_ports[14],
        _gNB902_rf_att_6_165.attenuator_ports[15],
        _gNB902_rf_att_6_165.attenuator_ports[16],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.181.49", port="5001"),
        ],
    ),
)

_BBMOD1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    serial_number="DH200294850",
    rus=[
        _rmod1000_AHPMDG_01,
        _rmod2000_AHPMDG_04,
        _rmod3000_AHPMDG_02,
    ],
)

_BBMOD2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1224009397",
    rus=[
        _rmod1000_AHPMDG_01,
        _rmod2000_AHPMDG_04,
        _rmod3000_AHPMDG_02,
    ],
)

_BBMOD3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIO",
    hardware_version="475266A.105",
    serial_number="DH234521533",
    rus=[
        _rmod1400_OFEGSA_06,
        _rmod2400_OFEGSA_03,
        _rmod3400_OFEGSA_05,
    ],
)

_BBMOD4 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIO",
    hardware_version="475266A.105",
    serial_number="DH234521701",
    rus=[
        _rmod1800_AQQQ_01,
        _rmod2800_AQQQ_02,
        _rmod3800_AQQQ_03,
    ],
)

_SMOD1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_BBMOD1, _BBMOD2, _BBMOD3],
    pdu_port=_pdu1_164.pdu_ports[3],
    hardware_type="ASIL",
    serial_number="L1214909668",
)

_SMOD2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_BBMOD4],
    pdu_port=_pdu1_164.pdu_ports[4],
    hardware_type="ASIL",
    serial_number="L1211012426",
)

_airscale_Common = Airscale(common_units=[_SMOD1, _SMOD2])

_airscale_gNB1 = DU(
    airscale=_airscale_Common,
    rus=[
        _rmod1000_AHPMDG_01,
        _rmod1400_OFEGSA_06,
        _rmod1800_AQQQ_01,
        _rmod2000_AHPMDG_04,
        _rmod2400_OFEGSA_03,
        _rmod2800_AQQQ_02,
        _rmod3000_AHPMDG_02,
        _rmod3400_OFEGSA_05,
        _rmod3800_AQQQ_03,
    ],
)

_comnBTS_gNB1 = ClassicalBts(
    cu=_cu_gnb_1, dus=[_airscale_gNB1], global_bts_id=9021, instance_id=9021
)

# ----------------- START eNB Common --------------------#
_comnBTS_eNB1 = RealEnb(
    system_module=_airscale_Common,
    rms=[
        _rmod1000_AHPMDG_01,
        _rmod1400_OFEGSA_06,
        _rmod1800_AQQQ_01,
        _rmod2000_AHPMDG_04,
        _rmod2400_OFEGSA_03,
        _rmod2800_AQQQ_02,
        _rmod3000_AHPMDG_02,
        _rmod3400_OFEGSA_05,
        _rmod3800_AQQQ_03,
    ],
    oam_ip=NetworkAddress(v4="10.46.160.114"),
)
# ----------------- STOP eNB Common ------------------- #

_bts2g_gsm = Bts2G(
    system_module=_airscale_Common,
    rms=[
        _rmod1000_AHPMDG_01,
        _rmod2000_AHPMDG_04,
        _rmod3000_AHPMDG_02,
    ],
    bcf_id="17",
    master=_comnBTS_gNB1,
)

_bsc = BSC(
    name="BSC-22",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.38.63.245", username="SYSTEM", password="SYSTEM"
    ),
)

# ---------------- START Core APP Server ------------------- #
_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="DEUL5Gappsrv13.ulm.nsn-rdnet.net",
        username="ute",
        password="UTE.debian12",
    ),
    network_interface_address="10.47.194.213",
    # iperf_path="iperf",
    # ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254],
)

_appserver = AppServer(_iperf_details_on_appserver)

# DEUL5Gappsrv13
_app_server_13 = TafUeAppServer(
    app_server_name="DEUL5Gappsrv13",
    # address="10.47.194.213",
    address="DEUL5Gappsrv13.ulm.nsn-rdnet.net",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.213",
    #    binary_path="iperf",
    #    ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254]
)

_app_server_for_PING = TafUeAppServer(
    app_server_name="DEUL5Gappsrv13",
    address="10.47.194.213",
    # address="DEUL5Gappsrv03.ulm.nsn-rdnet.net",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.213",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_13,
    interval=1,
    #    binary_path="/data/local/tmp/iperf",
    version=3,
    dt_from_uepc=True,
)

_data_transfer_ping = TafUeDataTransferProtocol(
    protocol_name="ping",
    app_server=_app_server_for_PING,
    interval=1,
)

_data_transfer_ftp = TafUeDataTransferProtocol(
    protocol_name="ftp",
    app_server=_app_server_13,
    interval=1,
)
# ---------------- END Core APP Server ------------------- #
# ---------------- START PDNs ------------------- #
_pdns_for_ue = [
    PDNTafUeAndroidDetails(
        entryName="data_apn",
        apnName="ulmsa",
        apnType=["DEFAULT"],
    ),
    PDNTafUeAndroidDetails(
        entryName="voice_apn",
        apnName="ims5g",
        apnType=["MMS", "IMS"],
    ),
]

_realCore = RealCore(mcc="1", mnc="1")
# ---------------- END PDNs.
# ---------------- START UEs Controll NUC PSc ------------------------ #
_ue_ctrl_NUC_pc1_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC902-1.intra.noklab.net",
    username="deul5g",
    password="Nuc2Ue4PzLab!",
    # addr="10.46.135.67", username="deul5g", password="Nuc2Ue4PzLab!"
)

_ue_ctrl_NUC_pc2_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC902-2.intra.noklab.net",
    username="deul5g",
    password="Nuc2Ue4PzLab!",
)
# ---------------- END UEs Controll NUC PSc ------------------------ #
# ---------------- START UE1: Samsung S24 Ultra #25 (SM-S928B Qualcomm) ------------------------
_ue_S24_Ultra_25 = TafUeAndroid(
    ssh_connection_details=_ue_ctrl_NUC_pc1_ssh_details,
    serial_number="R5CX92VJAMK",
    capabilities=[
        "REAL_UE",
        "REAL_QUALCOMM_Chipset",
        "REAL_ANDROID_UE",
        "UE_2",  # This is just a name. in Future use e.g. Exynos_Chipset...temp referencing UE_2 as UE_1 as long as TA code has not updated yet
    ],
    ue_pc_address="DEUL5GNUC902-1.intra.noklab.net",
    data_transfer=[_data_transfer_iperf, _data_transfer_ping, _data_transfer_ftp],
    # phone_number="+3548247700026",
    ue_pc_port="8080",
    imei="350683212461353",
    imsi="001010000011052",
    pdns=_pdns_for_ue,
    qualcomm_prototype=False,
    network_mode_switch_method="keyevents",
    path_to_network_mode_type="Mobile networks/Network mode",
    is_rooted="no",
    download_proxy_logs=True,
    compress_proxy_logs=True,
    allow_kw_logs=True,
)
# ---------------- END UE1: Samsung S24 Ultra #25 (SM-S928B Qualcomm) ------------------------
# ---------------- START UE2: Samsung S24 #17 (SM-S921B Exynos) ------------------------
_ue_S24_17 = TafUeAndroid(
    ssh_connection_details=_ue_ctrl_NUC_pc2_ssh_details,
    serial_number="R3CX90508FH",
    capabilities=[
        "REAL_UE",
        "REAL_ANDROID_UE",
        "REAL_Exynos_Chipset",
        "UE_1",  # This is just a name. in Future use e.g. Exynos_Chipset...temp referencing UE_2 as UE_1 as long as TA code has not updated yet
    ],
    ue_pc_address="DEUL5GNUC902-2.intra.noklab.net",
    data_transfer=[_data_transfer_iperf, _data_transfer_ping, _data_transfer_ftp],
    # phone_number="+3548247700026",
    ue_pc_port="8080",
    imei="358673441415389",
    imsi="001010000011060",
    pdns=_pdns_for_ue,
    qualcomm_prototype=False,
    network_mode_switch_method="keyevents",
    path_to_network_mode_type="Mobile networks/Network mode",
    is_rooted="no",
    download_proxy_logs=True,
    compress_proxy_logs=True,
    allow_kw_logs=True,
)
# ---------------- END UE2: Samsung S24 #17 (SM-S921B Exynos) ------------------------
# ---------------- START TEST PCs ------------------------ #
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="7-15-UTESRANTL902.ulm.nsn-rdnet.net",
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
    pdus=[_pdu1_170, _pdu2_170, _pdu1_164],
    core=_realCore,
    attenuators=[_gNB902_rf_att_4_165, _gNB902_rf_att_5_165, _gNB902_rf_att_6_165],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_SRAN_NLG_1ASIB_1ABIA_2ABIO_3AHPMDB_3AHEGB_3AHHB_3AQQQ",
    ues=[_ue_S24_17, _ue_S24_Ultra_25],
    bscs=[_bsc],
)

__all__ = ["tl"]
# ----------------------------------------- TL ----------------------------------------- #
