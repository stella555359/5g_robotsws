# This file was updated starting from 7_15_UTESRANTL283
####################################################################################
# TestLine TL284 DTAG (7_15_UTESRANTL284) - single-SMOD site configuration variant #
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

# ++++++++++++++ TL284 PDU OVERVIEW +++++++++++++++++++
# pdu1-283:            SMODs
# pdu4-293             RMODs AHPMDK
# pdu2-291 / pdu2-292: RMODS AHHB
# pdu4-293:            RMODs OFEGSA / AVQQ
# ++++++++++++++ TL283 PDU OVERVIEW +++++++++++++++++++

# pdu1-283 - SMOD_pdu: ASIM left and right
_pdu1_283 = Gude(
    addr="10.46.152.83",
    port_numbers=[3, 4],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# pdu4-293 - RMOD_pdu_2: AHPMDK / OFEGSA / AVQQ
_pdu4_293 = Gude(
    addr="10.46.152.99",
    port_numbers=[1, 3, 4, 5, 6, 7, 8, 9, 10],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# pdu2-292 - RMOD_pdu_3: AHHB
_pdu2_292 = Gude(
    addr="10.46.152.192",
    port_numbers=[9, 10],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# pdu2-291 - RMOD_pdu_4:
_pdu2_291 = Gude(
    addr="10.46.152.191",
    port_numbers=[9],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# ---------------- START RF Attenuators
# deul5gatt1-284: HTBE 32-Port
_gNB284_rf_att_1_284 = HBTE(
    ip_addr="10.46.152.234",
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
        13,
        14,
        15,
        16,
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

# deul5gatt2-284: HTBE 32-Port
_gNB284_rf_att_2_284 = HBTE(
    ip_addr="10.46.152.244",
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
# ---------------- START gNB-1 -------------------#
_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.14.201",
        v6="2A00:8A00:6000:2F21::47:14:8411",
        vlan_id=1484,
        routing_v4=RoutingInformation(gateway=""),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:2F21::47:14:8411/124"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.47.14.249",
        v6="2A00:8A00:6000:2F21::47:14:8440",
        vlan_id=1484,
        routing_v4=RoutingInformation(gateway=""),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:2F21::47:14:8442/124"),
    ),
    x2u=NetworkAddress(
        v4="10.47.14.233",
        v6="2A00:8A00:6000:2F21::47:14:8430",
        vlan_id=1484,
        routing_v4=RoutingInformation(gateway=""),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:2F21::47:14:8432/124"),
    ),
    s1u=NetworkAddress(
        v4="10.47.14.233",
        v6="2A00:8A00:6000:2F21::47:14:8430",
        vlan_id=1484,
        routing_v4=RoutingInformation(gateway=""),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:2F21::47:14:8432/124"),
    ),
    ngu=NetworkAddress(
        v4="10.47.14.233",
        v6="2A00:8A00:6000:2F21::47:14:8430",
        vlan_id=1484,
        routing_v4=RoutingInformation(gateway=""),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:2F21::47:14:8432/124"),
    ),
    ngc=NetworkAddress(
        v4="10.47.14.249",
        v6="2A00:8A00:6000:2F21::47:14:8440",
        vlan_id=1484,
        routing_v4=RoutingInformation(gateway=""),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:2F21::47:14:8442/124"),
    ),
    xnc=NetworkAddress(
        v4="10.47.14.249",
        v6="2A00:8A00:6000:2F21::47:14:8440",
        vlan_id=1484,
        routing_v4=RoutingInformation(gateway=""),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:2F21::47:14:8442/124"),
    ),
    xnu=NetworkAddress(
        v4="10.47.14.233",
        v6="2A00:8A00:6000:2F21::47:14:8430",
        vlan_id=1484,
        routing_v4=RoutingInformation(gateway=""),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:2F21::47:14:8432/124"),
    ),
)

_BBMOD1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="473096A.107",
    serial_number="L1233206750",
)

_BBMOD2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1241507178",
)

_BBMOD3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="DH250612229",
)

_BBMOD4 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1242304296",
)

_SMOD1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_BBMOD1, _BBMOD2, _BBMOD3],
    pdu_port=_pdu1_283.pdu_ports[3],
    hardware_type="ASIM",
    serial_number="L1243308547",
)

_SMOD2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_BBMOD4],
    pdu_port=_pdu1_283.pdu_ports[4],
    hardware_type="ASIM",
    serial_number="L1243308550",
)

# RMOD-1000: AHPMDK #8
_rmod1000_AHPMDK_04 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type=RadioTypes.AHPMDG.value,
    serial_number="L1254601177",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu4_293.pdu_ports[3],
    attenuation_ports=[
        _gNB284_rf_att_1_284.attenuator_ports[1],
        _gNB284_rf_att_1_284.attenuator_ports[2],
        _gNB284_rf_att_1_284.attenuator_ports[3],
        _gNB284_rf_att_1_284.attenuator_ports[4],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.181.7", port="5001"),
        ],
    ),
)

# RMOD-1400: OFEGSA #16
_rmod1400_OFEGSA_16 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type=FujitsuRadioTypes.OFEGSA.value,
    serial_number="00321",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu4_293.pdu_ports[5],
    attenuation_ports=[
        _gNB284_rf_att_1_284.attenuator_ports[5],  # Band:32 (1500 L-band) TX Only!
        _gNB284_rf_att_1_284.attenuator_ports[6],
        _gNB284_rf_att_1_284.attenuator_ports[7],
        _gNB284_rf_att_1_284.attenuator_ports[8],
        _gNB284_rf_att_1_284.attenuator_ports[13],  # Band:3 (1800+)
        _gNB284_rf_att_1_284.attenuator_ports[14],
        _gNB284_rf_att_1_284.attenuator_ports[15],
        _gNB284_rf_att_1_284.attenuator_ports[16],
        _gNB284_rf_att_1_284.attenuator_ports[21],  # Band:1 (2100)
        _gNB284_rf_att_1_284.attenuator_ports[22],
        _gNB284_rf_att_1_284.attenuator_ports[23],
        _gNB284_rf_att_1_284.attenuator_ports[24],
    ],
)

# RMOD-1600: AHHB #05
_rmod1600_AHHB_05 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHHB.value,
    serial_number="LR241216087",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu2_291.pdu_ports[9],
    attenuation_ports=[
        _gNB284_rf_att_1_284.attenuator_ports[25],
        _gNB284_rf_att_1_284.attenuator_ports[26],
        _gNB284_rf_att_1_284.attenuator_ports[27],
        _gNB284_rf_att_1_284.attenuator_ports[28],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.180.41", port="5001"),
        ],
    ),
)

# RMOD-2000: AHPMDK #17
_rmod2000_AHPMDK_03 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type=RadioTypes.AHPMDG.value,
    serial_number="L1254601179",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.136", port=2323
    ),
    pdu_port=_pdu4_293.pdu_ports[6],
    attenuation_ports=[
        _gNB284_rf_att_2_284.attenuator_ports[1],
        _gNB284_rf_att_2_284.attenuator_ports[2],
        _gNB284_rf_att_2_284.attenuator_ports[3],
        _gNB284_rf_att_2_284.attenuator_ports[4],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.181.8", port="5001"),
        ],
    ),
)

# RMOD-2400: OFEGSA #13
_rmod2400_OFEGSA_13 = RU(
    ru_hw_group="TA08029-B312/01",
    radio_type=FujitsuRadioTypes.OFEGSA.value,
    serial_number="0100",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu4_293.pdu_ports[8],
    attenuation_ports=[
        _gNB284_rf_att_2_284.attenuator_ports[5],
        _gNB284_rf_att_2_284.attenuator_ports[6],
        _gNB284_rf_att_2_284.attenuator_ports[7],
        _gNB284_rf_att_2_284.attenuator_ports[8],
    ],
)

# RMOD-2600: AHHB #23
_rmod2600_AHHB_23 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHHB.value,
    serial_number="LR243208077",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu2_292.pdu_ports[9],
    attenuation_ports=[
        _gNB284_rf_att_2_284.attenuator_ports[9],
        _gNB284_rf_att_2_284.attenuator_ports[10],
        _gNB284_rf_att_2_284.attenuator_ports[11],
        _gNB284_rf_att_2_284.attenuator_ports[12],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.180.42", port="5001"),
        ],
    ),
)


# RMOD-3000: AHPMDK #20
_rmod3000_AHPMDK_05 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type=RadioTypes.AHPMDG.value,
    serial_number="L1254503793",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.134", port=2323
    ),
    pdu_port=_pdu4_293.pdu_ports[9],
    attenuation_ports=[
        _gNB284_rf_att_2_284.attenuator_ports[17],
        _gNB284_rf_att_2_284.attenuator_ports[18],
        _gNB284_rf_att_2_284.attenuator_ports[19],
        _gNB284_rf_att_2_284.attenuator_ports[20],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.181.9", port="5001"),
        ],
    ),
)

# RMOD-3400: OFEGSA #17
_rmod3400_OFEGSA_17 = RU(
    ru_hw_group="TA08029-B312/01",
    radio_type=FujitsuRadioTypes.OFEGSA.value,
    serial_number="0100",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu4_293.pdu_ports[10],
    attenuation_ports=[
        _gNB284_rf_att_2_284.attenuator_ports[21],
        _gNB284_rf_att_2_284.attenuator_ports[22],
        _gNB284_rf_att_2_284.attenuator_ports[23],
        _gNB284_rf_att_2_284.attenuator_ports[24],
    ],
)

# RMOD-3600: AHHB #24
_rmod3600_AHHB_24 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type=RadioTypes.AHHB.value,
    serial_number="LR243208079",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu2_292.pdu_ports[10],
    attenuation_ports=[
        _gNB284_rf_att_2_284.attenuator_ports[25],
        _gNB284_rf_att_2_284.attenuator_ports[26],
        _gNB284_rf_att_2_284.attenuator_ports[27],
        _gNB284_rf_att_2_284.attenuator_ports[28],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.180.43", port="5001"),
        ],
    ),
)

# RMOD-1800: AVQY #04 - has been replaced by AVQY#04 in the meantime, needs to be updated
_rmod1800_AVQY_04 = RU(
    ru_hw_group="cMAAr7.1_32T32R_eCPRI",
    radio_type=RadioTypes.AVQQ.value,
    serial_number="L1253502999",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.154", port=2323
    ),
    pdu_port=_pdu4_293.pdu_ports[1],
    attenuation_ports=[
        _gNB284_rf_att_1_284.attenuator_ports[29],
        _gNB284_rf_att_1_284.attenuator_ports[30],
        _gNB284_rf_att_1_284.attenuator_ports[31],
        _gNB284_rf_att_1_284.attenuator_ports[32],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.180.237", port="5001"),
        ],
    ),
)

# RMOD-2800: AVQY #05 - has been replaced by AVQY#05 in the meantime, needs to be updated
_rmod2800_AVQY_05 = RU(
    ru_hw_group="cMAAr7.1_32T32R_eCPRI",
    radio_type=RadioTypes.AVQQ.value,
    serial_number="L1253503000",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.154", port=2323
    ),
    pdu_port=_pdu4_293.pdu_ports[4],
    attenuation_ports=[
        _gNB284_rf_att_2_284.attenuator_ports[13],
        _gNB284_rf_att_2_284.attenuator_ports[14],
        _gNB284_rf_att_2_284.attenuator_ports[15],
        _gNB284_rf_att_2_284.attenuator_ports[16],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.180.238", port="5001"),
        ],
    ),
)

# RMOD-3800: AVQY #06 - has been replaced by AVQY#06 in the meantime, needs to be updated
_rmod3800_AVQY_06 = RU(
    ru_hw_group="cMAAr7.1_32T32R_eCPRI",
    radio_type=RadioTypes.AVQQ.value,
    serial_number="L1253503001",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.154", port=2323
    ),
    pdu_port=_pdu4_293.pdu_ports[7],
    attenuation_ports=[
        _gNB284_rf_att_2_284.attenuator_ports[29],
        _gNB284_rf_att_2_284.attenuator_ports[30],
        _gNB284_rf_att_2_284.attenuator_ports[31],
        _gNB284_rf_att_2_284.attenuator_ports[32],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.180.239", port="5001"),
        ],
    ),
)


# _airscale = Airscale(common_units=[_SMOD1])
_airscale = Airscale(common_units=[_SMOD1, _SMOD2])

_airscale_gNB1 = DU(
    airscale=_airscale,
    # airscale=_airscale_Common,
    rus=[
        _rmod1000_AHPMDK_04,
        _rmod1400_OFEGSA_16,
        _rmod1800_AVQY_04,
        _rmod2000_AHPMDK_03,
        _rmod2400_OFEGSA_13,
        _rmod2800_AVQY_05,
        _rmod3000_AHPMDK_05,
        _rmod3400_OFEGSA_17,
        _rmod3800_AVQY_06,
    ],
)

_comnBTS_gNB1 = ClassicalBts(
    cu=_cu_gnb_1, dus=[_airscale_gNB1], global_bts_id=2841, instance_id=2841
)

# ----------------- START eNB Common --------------------#
_airscale_Common = Airscale(common_units=[_SMOD1, _SMOD2])

_comnBTS_eNB1 = RealEnb(
    system_module=_airscale_Common,
    rms=[
        _rmod1000_AHPMDK_04,
        _rmod1400_OFEGSA_16,
        _rmod1600_AHHB_05,
        _rmod1800_AVQY_04,
        _rmod2000_AHPMDK_03,
        _rmod2400_OFEGSA_13,
        _rmod2600_AHHB_23,
        _rmod2800_AVQY_05,
        _rmod3000_AHPMDK_05,
        _rmod3400_OFEGSA_17,
        _rmod3600_AHHB_24,
        _rmod3800_AVQY_06,
    ],
    oam_ip=NetworkAddress(v4="10.47.14.201"),
)
# ----------------- STOP eNB Common ------------------- #

_bts2g_gsm = Bts2G(
    system_module=_airscale_Common,
    rms=[
        _rmod1000_AHPMDK_04,
        _rmod2000_AHPMDK_03,
        _rmod3000_AHPMDK_05,
    ],
    bcf_id="27",
    master=_comnBTS_gNB1,
)

_bsc = BSC(
    name="BSC-414731",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.38.63.245", username="SYSTEM", password="SYSTEM"
    ),
)

# ---------------- START Core APP Server ------------------- #
_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="DEUL5Gappsrv17.ulm.nsn-rdnet.net",
        username="ute",
        password="UTE.debian12",
    ),
    network_interface_address="10.47.194.217",
    # iperf_path="iperf",
    # ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254],
)

_appserver = AppServer(_iperf_details_on_appserver)

# DEUL5Gappsrv17
_app_server_17 = TafUeAppServer(
    app_server_name="DEUL5Gappsrv17",
    # address="10.47.194.223",
    address="DEUL5Gappsrv17.ulm.nsn-rdnet.net",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.217",
    #    binary_path="iperf",
    #    ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254]
)

_app_server_for_PING = TafUeAppServer(
    app_server_name="DEUL5Gappsrv17",
    address="10.47.194.217",
    # address="DEUL5Gappsrv23.ulm.nsn-rdnet.net",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.217",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_17,
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
    app_server=_app_server_17,
    interval=1,
)
# ---------------- END Core APP Server ------------------- #
# ---------------- START Core PDNs ------------------- #
_pdns = [
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsa"),
]

_tampereCore = RealCore(mcc="001", mnc="01", pdns=_pdns)
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
    addr="DEUL5GNUC284-1.intra.noklab.net",
    username="deul5g",
    password="Nuc2Ue4PzLab!",
    # addr="10.46.135.49", username="deul5g", password="Nuc2Ue4PzLab!"
)
# ---------------- END UEs Controll NUC PSc ------------------------ #
# ---------------- START UE: Samsung S24 Ultra #39  (Qualcomm) ------------------------ TL284
_ue_S24_Ultra_39 = TafUeAndroid(
    serial_number="R5CX92VJCEZ",
    ue_pc_address="DEUL5GNUC284-1.intra.noklab.net",
    ssh_connection_details=_ue_ctrl_NUC_pc1_ssh_details,
    # proxy_mngr_port=9955,  # ueproxy manager will not be visible unless proxy_mngr_port is configured! (default value: 9955 - used in autostart)
    capabilities=[
        "REAL_UE",
        "REAL_ANDROID_UE",
        "REAL_QUALCOMM_Chipset",
        "UE_1",
    ],
    data_transfer=[_data_transfer_iperf, _data_transfer_ping, _data_transfer_ftp],
    phone_number="+3548247700040",
    ue_pc_port="8080",  # If proxy_mngr_port is defined in Ue object ue_pc_port will be omitted!
    imei="350683212461940",
    imsi="001017700000040",
    pdns=_pdns_for_ue,
    qualcomm_prototype=False,
    network_mode_switch_method="keyevents",
    path_to_network_mode_type="Mobile networks/Network mode",
    is_rooted="no",
    download_proxy_logs=True,
    compress_proxy_logs=True,
    allow_kw_logs=True,
)
# ---------------- END UE: S24  Ultra #39 ------------------------
# ---------------- START TEST PCs ------------------------ #
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="7-15-UTESRANTL284.ulm.nsn-rdnet.net",
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
    pdus=[_pdu1_283, _pdu4_293, _pdu2_292, _pdu2_291],
    core=_tampereCore,
    attenuators=[_gNB284_rf_att_1_284, _gNB284_rf_att_2_284],
    appserver=_appserver,
    tl_cloud_topology="N/A",
    ues=[_ue_S24_Ultra_39],
    bscs=[_bsc],
)

__all__ = ["tl"]
# ----------------------------------------- TL ----------------------------------------- #
