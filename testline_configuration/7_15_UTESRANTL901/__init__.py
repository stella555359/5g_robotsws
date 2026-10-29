# This file was updated starting from 7_15_UTESRANTL286
#########################################
# TestLine TL901 Ulm (7_15_UTESRANTL901)#
#########################################
__maintainer__ = "Michele"
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

# ---------------- START Power Switchs
# pdu1-170 - RMOD_pdu
_pdu1_170 = Gude(
    addr="10.46.148.70",
    port_numbers=[2, 3, 4, 7, 8, 10],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# pdu2-170 - RMOD_pdu
_pdu2_170 = Gude(
    addr="10.46.148.170",
    port_numbers=[3, 4, 5, 9, 10, 11],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# pdu1-164 - SMOD_pdu
_pdu1_164 = Gude(
    addr="10.46.148.64",
    port_numbers=[1, 2],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# ---------------- START RF Attenuators
_rf_att_deul5gatt1_165 = HBTE(
    ip_addr="10.46.148.21",
    port="5000",
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 25, 26, 27, 28, 29, 30, 31, 32],
    version=None,
    model="PA-16-16-6-127-0.5-B-S",
)

_rf_att_deul5gatt2_165 = HBTE(
    ip_addr="10.46.148.22",
    port="5000",
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    version=None,
    model="PA-16-16-6-127-0.5-B-S",
)

_rf_att_deul5gatt3_165 = HBTE(
    ip_addr="10.46.148.23",
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

_BBMOD1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    serial_number="DH200294850",
)

_BBMOD2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1224009397",
)

_BBMOD3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIO",
    hardware_version="475266A.105",
    serial_number="DH234521533",
)

_BBMOD4 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIO",
    hardware_version="475266A.105",
    serial_number="DH234521701",
)

_SMOD1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_BBMOD1, _BBMOD2, _BBMOD3],
    pdu_port=_pdu1_164.pdu_ports[1],
    hardware_type="ASIM",
    serial_number="L1243504484",
)

_SMOD2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_BBMOD4],
    pdu_port=_pdu1_164.pdu_ports[2],
    hardware_type="ASIL",
    serial_number="L1211012426",
)

# RMOD-100: AHPMDG #06
_rmod100_AHPMDG_06 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type=RadioTypes.AHPMDG,
    serial_number="K9240206104",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu1_170.pdu_ports[4],
    attenuation_ports=[
        _rf_att_deul5gatt1_165.attenuator_ports[1],
        _rf_att_deul5gatt1_165.attenuator_ports[2],
        _rf_att_deul5gatt1_165.attenuator_ports[3],
        _rf_att_deul5gatt1_165.attenuator_ports[4],
    ],
)

# RMOD-300: OFEGSA #02
_rmod300_OFEGSA_02 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type=FujitsuRadioTypes.OFEGSA,
    serial_number="00212",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu2_170.pdu_ports[4],
    attenuation_ports=[
        _rf_att_deul5gatt1_165.attenuator_ports[5],
        _rf_att_deul5gatt1_165.attenuator_ports[6],
        _rf_att_deul5gatt1_165.attenuator_ports[7],
        _rf_att_deul5gatt1_165.attenuator_ports[8],
    ],
)

# RMOD-400: AHHB #04
_rmod400_AHHB_04 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    radio_type=RadioTypes.AHHB,
    serial_number="LR241216086",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.154", port=2323
    ),
    pdu_port=_pdu1_170.pdu_ports[2],
    attenuation_ports=[
        _rf_att_deul5gatt1_165.attenuator_ports[25],
        _rf_att_deul5gatt1_165.attenuator_ports[26],
        _rf_att_deul5gatt1_165.attenuator_ports[27],
        _rf_att_deul5gatt1_165.attenuator_ports[28],
    ],
)


# RMOD-501: AWHQF #01
_rmod501_AWHQF_01 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    radio_type=RadioTypes.AWHQF,
    serial_number="EB2348R0072",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.154", port=2323
    ),
    pdu_port=_pdu2_170.pdu_ports[9],
    attenuation_ports=[
        _rf_att_deul5gatt1_165.attenuator_ports[29],
        _rf_att_deul5gatt1_165.attenuator_ports[30],
        _rf_att_deul5gatt1_165.attenuator_ports[31],
        _rf_att_deul5gatt1_165.attenuator_ports[32],
    ],
)

# RMOD-600: AHPMDG #03
_rmod600_AHPMDG_03 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type=RadioTypes.AHPMDG,
    serial_number="BL2407C6GUA",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.136", port=2323
    ),
    pdu_port=_pdu1_170.pdu_ports[8],
    attenuation_ports=[
        _rf_att_deul5gatt2_165.attenuator_ports[1],
        _rf_att_deul5gatt2_165.attenuator_ports[2],
        _rf_att_deul5gatt2_165.attenuator_ports[3],
        _rf_att_deul5gatt2_165.attenuator_ports[4],
    ],
)

# RMOD-800: OFEGSA #01
_rmod800_OFEGSA_01 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type=FujitsuRadioTypes.OFEGSA,
    serial_number="00185",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu2_170.pdu_ports[4],
    attenuation_ports=[
        _rf_att_deul5gatt2_165.attenuator_ports[5],
        _rf_att_deul5gatt2_165.attenuator_ports[6],
        _rf_att_deul5gatt2_165.attenuator_ports[7],
        _rf_att_deul5gatt2_165.attenuator_ports[8],
    ],
)

# RMOD-900: AHHB #07
_rmod900_AHHB_07 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",  # To be checked!
    radio_type=RadioTypes.AHHB,
    serial_number="LR241216304",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.158", port=2323
    ),
    pdu_port=_pdu1_170.pdu_ports[3],
    attenuation_ports=[
        _rf_att_deul5gatt2_165.attenuator_ports[9],
        _rf_att_deul5gatt2_165.attenuator_ports[10],
        _rf_att_deul5gatt2_165.attenuator_ports[11],
        _rf_att_deul5gatt2_165.attenuator_ports[12],
    ],
)

# RMOD-1001: AWHQF #03
_rmod1001_AWHQF_03 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",  # To be checked!
    radio_type=RadioTypes.AWHQF,
    serial_number="EB2348R0132",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.154", port=2323
    ),
    pdu_port=_pdu2_170.pdu_ports[10],
    attenuation_ports=[
        _rf_att_deul5gatt2_165.attenuator_ports[13],
        _rf_att_deul5gatt2_165.attenuator_ports[14],
        _rf_att_deul5gatt2_165.attenuator_ports[15],
        _rf_att_deul5gatt2_165.attenuator_ports[16],
    ],
)

# RMOD-1100: AHPMDG #05
_rmod1100_AHPMDG_05 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type=RadioTypes.AHPMDG,
    serial_number="K9240708245",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.134", port=2323
    ),
    pdu_port=_pdu1_170.pdu_ports[10],
    attenuation_ports=[
        _rf_att_deul5gatt3_165.attenuator_ports[1],
        _rf_att_deul5gatt3_165.attenuator_ports[2],
        _rf_att_deul5gatt3_165.attenuator_ports[3],
        _rf_att_deul5gatt3_165.attenuator_ports[4],
    ],
)

# RMOD-1300: OFEGSA #15
_rmod1300_OFEGSA_15 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type=FujitsuRadioTypes.OFEGSA,
    serial_number="00317",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu2_170.pdu_ports[5],
    attenuation_ports=[
        _rf_att_deul5gatt3_165.attenuator_ports[5],
        _rf_att_deul5gatt3_165.attenuator_ports[6],
        _rf_att_deul5gatt3_165.attenuator_ports[7],
        _rf_att_deul5gatt3_165.attenuator_ports[8],
    ],
)

# RMOD-1400: AHHB #10
_rmod1400_AHHB_10 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    radio_type=RadioTypes.AHHB,
    serial_number="LR241216312",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.162", port=2323
    ),
    pdu_port=_pdu1_170.pdu_ports[7],
    attenuation_ports=[
        _rf_att_deul5gatt3_165.attenuator_ports[9],
        _rf_att_deul5gatt3_165.attenuator_ports[10],
        _rf_att_deul5gatt3_165.attenuator_ports[11],
        _rf_att_deul5gatt3_165.attenuator_ports[12],
    ],
)

# RMOD-1501: AWHQF #04
_rmod1501_AWHQF_04 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",  # To be checked!
    radio_type=RadioTypes.AWHQF,
    serial_number="EB2348R0157",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.154", port=2323
    ),
    pdu_port=_pdu2_170.pdu_ports[11],
    attenuation_ports=[
        _rf_att_deul5gatt3_165.attenuator_ports[13],
        _rf_att_deul5gatt3_165.attenuator_ports[14],
        _rf_att_deul5gatt3_165.attenuator_ports[15],
        _rf_att_deul5gatt3_165.attenuator_ports[16],
    ],
)

_airscale = Airscale(common_units=[_SMOD1])
_airscale_gNB1 = DU(
    airscale=_airscale,
    rus=[
        _rmod100_AHPMDG_06,
        _rmod300_OFEGSA_02,
        _rmod501_AWHQF_01,
        _rmod600_AHPMDG_03,
        _rmod800_OFEGSA_01,
        _rmod1001_AWHQF_03,
        _rmod1100_AHPMDG_05,
        _rmod1300_OFEGSA_15,
        _rmod1400_AHHB_10,
        _rmod1501_AWHQF_04,
    ],
)

_comnBTS_gNB1 = ClassicalBts(
    cu=_cu_gnb_1, dus=[_airscale_gNB1], global_bts_id=8011, instance_id=8011
)

# ----------------- START eNB Common --------------------#
_airscale_Common = Airscale(common_units=[_SMOD1])

_comnBTS_eNB1 = RealEnb(
    system_module=_airscale_Common,
    rms=[
        _rmod100_AHPMDG_06,
        _rmod300_OFEGSA_02,
        _rmod400_AHHB_04,
        _rmod600_AHPMDG_03,
        _rmod800_OFEGSA_01,
        _rmod900_AHHB_07,
        _rmod1100_AHPMDG_05,
        _rmod1300_OFEGSA_15,
        _rmod1400_AHHB_10,
    ],
    oam_ip=NetworkAddress(v4="10.46.160.114"),
)
# ----------------- STOP eNB Common ------------------- #

_bts2g_gsm = Bts2G(
    system_module=_airscale_Common,
    rms=[
        _rmod100_AHPMDG_06,
        _rmod600_AHPMDG_03,
        _rmod1100_AHPMDG_05,
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
_pdns = [
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsa"),
]

_tampereCore = RealCore(mcc="555", mnc="10", pdns=_pdns)
# ---------------- END PDNs.

# ---------------- START UEs Controll NUC PSc ------------------------ #
_ue_ctrl_PC_NUC1_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC1-901.intra.noklab.net",
    username="deul5g",
    password="Nuc2Ue4PzLab!",
    # addr="10.46.135.67", username="deul5g", password="Nuc2Ue4PzLab!"
)

_ue_ctrl_PC_NUC2_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC2-901.intra.noklab.net",
    username="deul5g",
    password="Nuc2Ue4PzLab!",
)

_ue_ctrl_PC_NUC3_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC3-901.intra.noklab.net",
    username="deul5g",
    password="Nuc2Ue4PzLab!",
)

_ue_ctrl_PC_NUC4_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC4-901.intra.noklab.net",
    username="deul5g",
    password="Nuc2Ue4PzLab!",
)
# ---------------- END UEs Controll NUC PSc ------------------------ #
# ---------------- START SAMSUNG UEs: ------------------------------------ #
# - https://confluence.ext.net.nokia.com/display/5GFTUlm/10+Samsung+UEs  - #
# ---------------- START SAMSUNG UE1: S24 #13 ---------------------------- #
_Samsung_Nr13_S24 = TafUeAndroid(
    serial_number="R3CX904ZEMA",
    ue_pc_address="DEUL5GNUC1-901.intra.noklab.net",
    capabilities=[
        "REAL_UE",
        "REAL_ANDROID_UE",
        "REAL_SAMSUNG_UE",
        "UE_1",
    ],
    data_transfer=[_data_transfer_iperf, _data_transfer_ping, _data_transfer_ftp],
    ssh_connection_details=_ue_ctrl_PC_NUC1_ssh_details,
    ue_pc_port="8080",
)
# ---------------- END SAMSUNG UE1: S24 #13 ------------------------------ #
# ---------------- START SAMSUNG UE1: S24 #99 ---------------------------- #
_Samsung_Nr99_S24 = TafUeAndroid(
    serial_number="R3CX9051S9R",
    ue_pc_address="DEUL5GNUC4-901.intra.noklab.net",
    capabilities=[
        "REAL_UE",
        "REAL_ANDROID_UE",
        "REAL_SAMSUNG_UE",
        "UE_2",
    ],
    data_transfer=[_data_transfer_iperf, _data_transfer_ping, _data_transfer_ftp],
    ssh_connection_details=_ue_ctrl_PC_NUC4_ssh_details,
    ue_pc_port="8080",
)
# ---------------- END SAMSUNG UE1: S24 #99 ------------------------------ #
# ---------------- END SAMSUNG UEs: -------------------------------------- #
# ---------------- START Qualcomm UEs: ------------------------------------ #
# - https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=776246841#HowTo/Allyouneedtoknow-QualcommMTPdevicesinUlm
# ---------------- START QC UE1: Qualcomm#30 ------------------------ #
_qualcomm30_sdx60 = TafUeAndroid(
    serial_number="ddb8cca9",
    # ue_pc_address="10.46.135.67",
    ue_pc_address="DEUL5GNUC1-901.intra.noklab.net",
    # proxy_mngr_port=9955,  # ueproxy manager will not be visible unless proxy_mngr_port is configured! (default value: 9955 - used in autostart)
    capabilities=[
        "REAL_UE",
        "REAL_ANDROID_UE",
        "REAL_QUALCOMM_UE",
        "UE_1",
    ],
    data_transfer=[_data_transfer_iperf, _data_transfer_ping, _data_transfer_ftp],
    ssh_connection_details=_ue_ctrl_PC_NUC1_ssh_details,
    ue_pc_port="8080",  # If proxy_mngr_port is defined in Ue object ue_pc_port will be omitted!
)
# ---------------- END QC UE1: Qualcomm#30 ------------------------ #
# ---------------- START QC UE2: Qualcomm#28 ------------------------ #
_qualcomm28_sdx60 = TafUeAndroid(
    serial_number="df403ce",
    ue_pc_address="DEUL5GNUC1-901.intra.noklab.net",
    capabilities=[
        "REAL_UE",
        "REAL_ANDROID_UE",
        "REAL_QUALCOMM_UE",
        "UE_2",
    ],
    data_transfer=[_data_transfer_iperf, _data_transfer_ping, _data_transfer_ftp],
    ssh_connection_details=_ue_ctrl_PC_NUC1_ssh_details,
    ue_pc_port="8080",
)
# ---------------- END QC UE1: Qualcomm#28 ------------------------ #
# ---------------- START QC UE3: Qualcomm#36------------------------ #
_qualcomm36_sdx60 = TafUeAndroid(
    serial_number="5715dccf",
    ue_pc_address="DEUL5GNUC2-901.intra.noklab.net",
    capabilities=[
        "REAL_UE",
        "REAL_ANDROID_UE",
        "REAL_QUALCOMM_UE",
        "UE_3",
    ],
    data_transfer=[_data_transfer_iperf, _data_transfer_ping, _data_transfer_ftp],
    ssh_connection_details=_ue_ctrl_PC_NUC2_ssh_details,
    ue_pc_port="8080",
)
# ---------------- END QC UE3: Qualcomm#36 ------------------------ #
# ---------------- START QC UE4: Qualcomm#37------------------------ #
_qualcomm37_sdx60 = TafUeAndroid(
    serial_number="d9900567",
    ue_pc_address="DEUL5GNUC2-901.intra.noklab.net",
    capabilities=[
        "REAL_UE",
        "REAL_ANDROID_UE",
        "REAL_QUALCOMM_UE",
        "UE_4",
    ],
    data_transfer=[_data_transfer_iperf, _data_transfer_ping, _data_transfer_ftp],
    ssh_connection_details=_ue_ctrl_PC_NUC2_ssh_details,
    ue_pc_port="8080",
)
# ----------------END QC UE3: Qualcomm#36 ------------------------ #
# ---------------- START MTK UE1 ------------------------
_ue_ctrl_pc2_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC2-901.intra.noklab.net", username="deul5g", password="Nuc2Ue4PzLab!"
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
    ue_pc_address="DEUL5GNUC2-901.intra.noklab.net",
    capabilities=["REAL_UE", "REAL_MTK_UE", "UE_2"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc2_ssh_details,
    ue_pc_port="8080",
)
# ---------------- END MTK UE1 ------------------------
# ---------------- START TEST PCs ------------------------ #
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="7-15-UTESRANTL901.ulm.nsn-rdnet.net",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[
        Connection(interface="eth1", device=_SMOD1, interface_type="lmp"),
    ],
)
# ---------------- END TEST PCs -------------------------- #
# ----------------------------------------- START TL ----------------------------------------- #
tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    bts2g_objects=[_bts2g_gsm],
    gnbs=[_comnBTS_gNB1],
    enbs=[_comnBTS_eNB1],
    pdus=[_pdu1_170, _pdu2_170, _pdu1_164],
    core=_tampereCore,
    attenuators=[
        _rf_att_deul5gatt1_165,
        _rf_att_deul5gatt2_165,
        _rf_att_deul5gatt3_165,
    ],
    appserver=_appserver,
    tl_cloud_topology="CLASSICAL_SRAN_2ASIL_1ABIA_3ABIO_3AHPMDG_3OFEGSA_3AHHB_3AWHQF",
    ues=[_Samsung_Nr13_S24, _Samsung_Nr99_S24],
    # ues=[_qualcomm45_sdx65, _mtk58asAndroid],
    # ues=[_qualcomm30_sdx60, _qualcomm28_sdx60, _qualcomm36_sdx60, _qualcomm37_sdx60],
    bscs=[_bsc],
)

__all__ = ["tl"]
# ----------------------------------------- END TL ----------------------------------------- #
