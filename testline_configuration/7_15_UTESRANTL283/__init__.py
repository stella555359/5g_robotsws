# This file was updated starting from 7_15_UTESRANTL902
####################################################################################
# TestLine TL283 DTAG (7_15_UTESRANTL283) - single-SMOD site configuration variant #
####################################################################################
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

# ++++++++++++++ TL283 PDU OVERVIEW +++++++++++++++++++
# pdu1-283:            SMODs
# pdu3-293 / pdu4-293: RMODs AHPMDG / OFEGSA
# pdu1-291 / pdu2-291: RMODS AHHB
# pdu1-293:            RMODs AQQQ
# ++++++++++++++ TL283 PDU OVERVIEW +++++++++++++++++++

# pdu1-283 - SMOD_pdu: ASIM
_pdu1_283 = Gude(
    addr="10.46.152.83",
    port_numbers=[1],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# pdu3-293 - RMOD_pdu_1: AHPMDGs #18/#19/#16 and OEFGSAs #09/#08
_pdu3_293 = Gude(
    addr="10.46.152.98",
    port_numbers=[3, 6, 7, 9, 10],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# pdu4-293 - RMOD_pdu_2: OFEGSA #18
_pdu4_293 = Gude(
    addr="10.46.152.99",
    port_numbers=[2],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# pdu1-291 - RMOD_pdu_3: AHHB #14
_pdu1_291 = Gude(
    addr="10.46.152.91",
    port_numbers=[10],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# pdu2-291 - RMOD_pdu_4: AHHBs #15/#16
_pdu2_291 = Gude(
    addr="10.46.152.191",
    port_numbers=[3, 6],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# ---------------- START RF Attenuators
# deul5gatt1-283: HTBE 32-Port
_gNB283_rf_att_1 = HBTE(
    ip_addr="10.46.152.233",
    port="5000",
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 25, 26, 27, 28],
    version=None,
    model="PA-16-16-6-127-0.5-B-S",
)

# deul5gatt2-283: HTBE 32-Port
_gNB283_rf_att_2 = HBTE(
    ip_addr="10.46.152.243",
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
    ],
    version=None,
    model="PA-16-16-6-127-0.5-B-S",
)
# ---------------- END RF Attenuators

# ---------------- START gNB-1 -------------------#
_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.14.137",
        v6="2A00:8A00:6000:2F21::47:14:8310",
        vlan_id=1401,
        routing_v4=RoutingInformation(gateway=""),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:2F21::47:14:8311/124"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.47.14.185",
        v6="2A00:8A00:6000:2F21::47:14:8340",
        vlan_id=1401,
        routing_v4=RoutingInformation(gateway=""),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:2F21::47:14:8342/124"),
    ),
    x2u=NetworkAddress(
        v4="10.47.14.169",
        v6="2A00:8A00:6000:2F21::47:14:8330",
        vlan_id=1401,
        routing_v4=RoutingInformation(gateway=""),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:2F21::47:14:8332/124"),
    ),
    s1u=NetworkAddress(
        v4="10.47.14.169",
        v6="2A00:8A00:6000:2F21::47:14:8330",
        vlan_id=1401,
        routing_v4=RoutingInformation(gateway="2A00:8A00:6000:2F21::47:14:8332/124"),
        routing_v6=RoutingInformation(gateway=""),
    ),
    ngu=NetworkAddress(
        v4="10.47.14.169",
        v6="2A00:8A00:6000:2F21::47:14:8330",
        vlan_id=1401,
        routing_v4=RoutingInformation(gateway=""),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:2F21::47:14:8332/124"),
    ),
    ngc=NetworkAddress(
        v4="10.47.14.185",
        v6="2A00:8A00:6000:2F21::47:14:8340",
        vlan_id=1401,
        routing_v4=RoutingInformation(gateway=""),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:2F21::47:14:8342/124"),
    ),
    xnc=NetworkAddress(
        v4="10.47.14.185",
        v6="2A00:8A00:6000:2F21::47:14:8340",
        vlan_id=1401,
        routing_v4=RoutingInformation(gateway=""),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:2F21::47:14:8342/124"),
    ),
    xnu=NetworkAddress(
        v4="10.47.14.169",
        v6="2A00:8A00:6000:2F21::47:14:8330",
        vlan_id=1401,
        routing_v4=RoutingInformation(gateway=""),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:2F21::47:14:8332/124"),
    ),
)

_BBMOD1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="473096A.107",
    serial_number="L1225000444",
)

_BBMOD2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1241507177",
)

_BBMOD3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIO",
    hardware_version="475266A.105",
    serial_number="DH234521599",
)

_SMOD1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_BBMOD1, _BBMOD2, _BBMOD3],
    pdu_port=_pdu1_283.pdu_ports[1],
    hardware_type="ASIM",
    serial_number="L1243308382",
)

# RMOD-1000: AHPMDG #18
_rmod1_AHPMDG_18 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHPMDG.value,
    serial_number="K9242706829",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu3_293.pdu_ports[3],
    attenuation_ports=[
        _gNB283_rf_att_1.attenuator_ports[1],
        _gNB283_rf_att_1.attenuator_ports[2],
        _gNB283_rf_att_1.attenuator_ports[3],
        _gNB283_rf_att_1.attenuator_ports[4],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.181.14", port="5001"),
        ],
    ),
)

# RMOD-1400: OFEGSA #09
_rmod2_OFEGSA_09 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type=FujitsuRadioTypes.OFEGSA.value,
    serial_number="00308",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu3_293.pdu_ports[7],
    attenuation_ports=[
        _gNB283_rf_att_1.attenuator_ports[5],
        _gNB283_rf_att_1.attenuator_ports[6],
        _gNB283_rf_att_1.attenuator_ports[7],
        _gNB283_rf_att_1.attenuator_ports[8],
    ],
)

# RMOD-1600: AHHB #14
_rmod3_AHHB_14 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHHB.value,
    serial_number="LR243208056",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu1_291.pdu_ports[10],
    attenuation_ports=[
        _gNB283_rf_att_1.attenuator_ports[25],
        _gNB283_rf_att_1.attenuator_ports[26],
        _gNB283_rf_att_1.attenuator_ports[27],
        _gNB283_rf_att_1.attenuator_ports[28],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.180.21", port="5001"),
        ],
    ),
)

# RMOD-2000: AHPMDG #19
_rmod5_AHPMDG_19 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHPMDG.value,
    serial_number="K9242706911",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.136", port=2323
    ),
    pdu_port=_pdu3_293.pdu_ports[6],
    attenuation_ports=[
        _gNB283_rf_att_2.attenuator_ports[1],
        _gNB283_rf_att_2.attenuator_ports[2],
        _gNB283_rf_att_2.attenuator_ports[3],
        _gNB283_rf_att_2.attenuator_ports[4],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.181.15", port="5001"),
        ],
    ),
)

# RMOD-2400: OFEGSA #08
_rmod6_OFEGSA_08 = RU(
    ru_hw_group="TA08029-B312/01",
    radio_type=FujitsuRadioTypes.OFEGSA.value,
    serial_number="00310",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu3_293.pdu_ports[10],
    attenuation_ports=[
        _gNB283_rf_att_2.attenuator_ports[5],
        _gNB283_rf_att_2.attenuator_ports[6],
        _gNB283_rf_att_2.attenuator_ports[7],
        _gNB283_rf_att_2.attenuator_ports[8],
    ],
)

# RMOD-2600: AHHB #15
_rmod7_AHHB_15 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHHB.value,
    serial_number="LR243208078",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu2_291.pdu_ports[3],
    attenuation_ports=[
        _gNB283_rf_att_2.attenuator_ports[9],
        _gNB283_rf_att_2.attenuator_ports[10],
        _gNB283_rf_att_2.attenuator_ports[11],
        _gNB283_rf_att_2.attenuator_ports[12],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.180.22", port="5001"),
        ],
    ),
)

# RMOD-3000: AHPMDG #16
_rmod9_AHPMDG_16 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHPMDG.value,
    serial_number="K9242706868",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.134", port=2323
    ),
    pdu_port=_pdu3_293.pdu_ports[9],
    attenuation_ports=[
        _gNB283_rf_att_2.attenuator_ports[17],
        _gNB283_rf_att_2.attenuator_ports[18],
        _gNB283_rf_att_2.attenuator_ports[19],
        _gNB283_rf_att_2.attenuator_ports[20],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.181.16", port="5001"),
        ],
    ),
)

# RMOD-3400: OFEGSA #18
_rmod10_OFEGSA_18 = RU(
    ru_hw_group="TA08029-B312/01",
    radio_type=FujitsuRadioTypes.OFEGSA.value,
    serial_number="00307",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu4_293.pdu_ports[2],
    attenuation_ports=[
        _gNB283_rf_att_2.attenuator_ports[21],
        _gNB283_rf_att_2.attenuator_ports[22],
        _gNB283_rf_att_2.attenuator_ports[23],
        _gNB283_rf_att_2.attenuator_ports[24],
    ],
)

# RMOD-3600: AHHB #16
_rmod11_AHHB_16 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHHB.value,
    serial_number="LR243208080",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu2_291.pdu_ports[6],
    attenuation_ports=[
        _gNB283_rf_att_2.attenuator_ports[25],
        _gNB283_rf_att_2.attenuator_ports[26],
        _gNB283_rf_att_2.attenuator_ports[27],
        _gNB283_rf_att_2.attenuator_ports[28],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.180.23", port="5001"),
        ],
    ),
)

_airscale_Common = Airscale(common_units=[_SMOD1])

_airscale_gNB1 = DU(
    airscale=_airscale_Common,
    rus=[
        _rmod1_AHPMDG_18,
        _rmod2_OFEGSA_09,
        _rmod5_AHPMDG_19,
        _rmod6_OFEGSA_08,
        _rmod9_AHPMDG_16,
        _rmod10_OFEGSA_18,
    ],
)

_comnBTS_gNB1 = ClassicalBts(
    cu=_cu_gnb_1, dus=[_airscale_gNB1], global_bts_id=2831, instance_id=2831
)

# ----------------- START eNB Common --------------------#
# _airscale_Common = Airscale(common_units=[_SMOD1])

_comnBTS_eNB1 = RealEnb(
    system_module=_airscale_Common,
    rms=[
        _rmod1_AHPMDG_18,
        _rmod2_OFEGSA_09,
        _rmod3_AHHB_14,
        _rmod5_AHPMDG_19,
        _rmod6_OFEGSA_08,
        _rmod7_AHHB_15,
        _rmod9_AHPMDG_16,
        _rmod10_OFEGSA_18,
        _rmod11_AHHB_16,
    ],
    oam_ip=NetworkAddress(v4="10.47.14.137"),
)
# ----------------- STOP eNB Common ------------------- #

_bts2g_gsm = Bts2G(
    system_module=_airscale_Common,
    rms=[
        _rmod1_AHPMDG_18,
        _rmod5_AHPMDG_19,
        _rmod9_AHPMDG_16,
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
        addr="DEUL5Gappsrv23.ulm.nsn-rdnet.net",
        username="ute",
        password="UTE.debian12",
    ),
    network_interface_address="10.47.194.223",
    # iperf_path="iperf",
    # ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254],
)

_appserver = AppServer(_iperf_details_on_appserver)

# DEUL5Gappsrv23
_app_server_23 = TafUeAppServer(
    app_server_name="DEUL5Gappsrv23",
    # address="10.47.194.223",
    address="DEUL5Gappsrv23.ulm.nsn-rdnet.net",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.223",
    #    binary_path="iperf",
    #    ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254]
)

_app_server_for_PING = TafUeAppServer(
    app_server_name="DEUL5Gappsrv23",
    address="10.47.194.223",
    # address="DEUL5Gappsrv23.ulm.nsn-rdnet.net",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.223",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_23,
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
    app_server=_app_server_23,
    interval=1,
)
# ---------------- END Core APP Server ------------------- #
# ---------------- START CORE PDNs ------------------- #
_pdns = [
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsa"),
]

_tampereCore = RealCore(mcc="555", mnc="10", pdns=_pdns)
# ---------------- END CORE PDNs.
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
    addr="DEUL5GNUC283-1.intra.noklab.net",
    username="deul5g",
    password="Nuc2Ue4PzLab!",
)

_ue_ctrl_NUC_pc2_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC283-2.intra.noklab.net",
    username="deul5g",
    password="Nuc2Ue4PzLab!",
)
# ---------------- END UEs Controll NUC PSc ------------------------ #

# ---------------- START UE: Samsung S24 Ultra #30 (SM-S928B Qualcomm) ------------------------
_Samsung_S24_Ultra_30 = TafUeAndroid(
    ssh_connection_details=_ue_ctrl_NUC_pc1_ssh_details,
    serial_number="R5CX92VJ67X",
    capabilities=[
        "REAL_UE",
        "REAL_ANDROID_UE",
        "REAL_QUALCOMM_Chipset",
        "UE_2",  # UE_2 is just a name used inside the TA code.
    ],
    ue_pc_address="DEUL5GNUC283-1.intra.noklab.net",
    data_transfer=[_data_transfer_iperf, _data_transfer_ping, _data_transfer_ftp],
    # phone_number='+3548247700026',
    ue_pc_port="8080",
    imei="350683212459894",
    imsi="001010000011102",
    pdns=_pdns_for_ue,
    qualcomm_prototype=False,
    network_mode_switch_method="keyevents",
    path_to_network_mode_type="Mobile networks/Network mode",
    is_rooted="no",
    download_proxy_logs=True,
    compress_proxy_logs=True,
    allow_kw_logs=True,
)
# ---------------- END UE: Samsung S24 Ultra #30 (SM-S928B Qualcomm) ------------------------

# ---------------- START UE: Samsung S24 #22 (SM-S921B Exynos) ------------------------
_Samsung_S24_22 = TafUeAndroid(
    ssh_connection_details=_ue_ctrl_NUC_pc2_ssh_details,
    serial_number="R3CX905147E",
    capabilities=[
        "REAL_UE",
        "REAL_Exynos_Chipset",
        "REAL_ANDROID_UE",
        "UE_1",  # UE_1 is just a name used inside the TA code.
    ],
    ue_pc_address="DEUL5GNUC283-2.intra.noklab.net",
    data_transfer=[_data_transfer_iperf, _data_transfer_ping, _data_transfer_ftp],
    # phone_number='+3548247700026',
    ue_pc_port="8080",
    imei="358673441424878",
    imsi="001017700000039",
    pdns=_pdns_for_ue,
    qualcomm_prototype=False,
    network_mode_switch_method="keyevents",
    path_to_network_mode_type="Mobile networks/Network mode",
    is_rooted="no",
    download_proxy_logs=True,
    compress_proxy_logs=True,
    allow_kw_logs=True,
)
# ---------------- END UE: Samsung S24 #17 (SM-S921B Exynos) ------------------------

# ---------------- START TEST PCs ------------------------ #
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="7-15-UTESRANTL283.ulm.nsn-rdnet.net",
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
    pdus=[_pdu1_283, _pdu3_293, _pdu4_293, _pdu1_291, _pdu2_291],
    core=_realCore,
    attenuators=[_gNB283_rf_att_1, _gNB283_rf_att_2],
    appserver=_appserver,
    tl_cloud_topology="N/A",
    ues=[_Samsung_S24_22, _Samsung_S24_Ultra_30],
    bscs=[_bsc],
)

__all__ = ["tl"]
# ----------------------------------------- TL ----------------------------------------- #
