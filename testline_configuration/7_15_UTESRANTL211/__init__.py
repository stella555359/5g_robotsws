#########################################
# TestLine TL211 Ulm (7_15_UTESRANTL211)#
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
# ---------------- START Power Switchs TL211

# pdu1-2011 - SMOD_pdu
_pdu1_2011 = Gude(
    addr="10.46.152.111",
    port_numbers=[1],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# pdu1-2001 - RMOD_pdu
_pdu1_2001 = Gude(
    addr="10.46.152.101",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)


# ---------------- START RF Attenuators TL211

_tl211_rf_att_1 = HBTE(
    ip_addr="10.46.152.201",
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

_tl211_rf_att_2 = HBTE(
    ip_addr="10.46.152.211",
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

# ---------------- START gNB-1 ------------------- TL211
_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.211.17",
        v6="2a00:8a00:6000:600c::1b04",
        vlan_id=1211,
        routing_v4=RoutingInformation(gateway="10.47.211.22/29"),
        routing_v6=RoutingInformation(gateway="GW:2a00:8a00:6000:600c::1b01/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.47.211.49",
        v6="2a00:8a00:6000:600c::1c03",
        vlan_id=1311,
        routing_v4=RoutingInformation(gateway="10.47.211.48/29"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1c01/120"),
    ),
    x2u=NetworkAddress(
        v4="10.47.211.57",
        v6="2a00:8a00:6000:600c::1d03",
        vlan_id=1311,
        routing_v4=RoutingInformation(gateway="10.47.211.56/29"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1d01/120"),
    ),
    s1u=NetworkAddress(
        v4="10.47.211.57",
        v6="2a00:8a00:6000:600c::1e03",
        vlan_id=1311,
        routing_v4=RoutingInformation(gateway="10.47.211.56/29"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1e01/120"),
    ),
    ngu=NetworkAddress(
        v4="10.47.211.57",
        v6="2a00:8a00:6000:600c::1e03",
        vlan_id=1311,
        routing_v4=RoutingInformation(gateway="10.47.211.56/29"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1e01/120"),
    ),
    ngc=NetworkAddress(
        v4="10.47.211.49",
        v6="2a00:8a00:6000:600c::2003",
        vlan_id=1311,
        routing_v4=RoutingInformation(gateway="10.47.211.48/29"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::2004"),
    ),
    xnc=NetworkAddress(
        v4="10.47.211.49",
        v6="2a00:8a00:6000:600c::1c03",
        vlan_id=1311,
        routing_v4=RoutingInformation(gateway="10.47.211.48/29"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1c01/120"),
    ),
    xnu=NetworkAddress(
        v4="10.47.211.57",
        v6="2a00:8a00:6000:600c::1d03",
        vlan_id=1311,
        routing_v4=RoutingInformation(gateway="10.47.211.56/29"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1d01/120"),
    ),
)

# RMOD-1 / RMOD_R-1: AHPMDG #23
_rmod1_AHPMDG_23 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHPMDG.value,
    serial_number="K9242012471",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu1_2001.pdu_ports[2],
    attenuation_ports=[
        _tl211_rf_att_1.attenuator_ports[1],
        _tl211_rf_att_1.attenuator_ports[2],
        _tl211_rf_att_1.attenuator_ports[3],
        _tl211_rf_att_1.attenuator_ports[4],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.181.1", port="5001"),
        ],
    ),
)

# RMOD-2 / RMOD_R-3: AHPMDG #29
_rmod2_AHPMDG_29 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHPMDG.value,
    serial_number="K9243600955",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.136", port=2323
    ),
    pdu_port=_pdu1_2001.pdu_ports[5],
    attenuation_ports=[
        _tl211_rf_att_2.attenuator_ports[1],
        _tl211_rf_att_2.attenuator_ports[2],
        _tl211_rf_att_2.attenuator_ports[3],
        _tl211_rf_att_2.attenuator_ports[4],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.181.2", port="5001"),
        ],
    ),
)

# RMOD-3 / RMOD_R-6: AHPMDG #33
_rmod3_AHPMDG_33 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHPMDG.value,
    serial_number="K9243835109",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.134", port=2323
    ),
    pdu_port=_pdu1_2001.pdu_ports[8],
    attenuation_ports=[
        _tl211_rf_att_2.attenuator_ports[17],
        _tl211_rf_att_2.attenuator_ports[18],
        _tl211_rf_att_2.attenuator_ports[19],
        _tl211_rf_att_2.attenuator_ports[20],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.181.3", port="5001"),
        ],
    ),
)

# RMOD-19 / RMOD_R-2: AVQQ #26
_rmod19_AVQQ_26 = RU(
    ru_hw_group="cMAAr7.1_32T32R",
    radio_type=RadioTypes.AVQQ.value,
    serial_number="1M243613562",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.154", port=2323
    ),
    pdu_port=_pdu1_2001.pdu_ports[1],
    attenuation_ports=[
        _tl211_rf_att_1.attenuator_ports[29],
        _tl211_rf_att_1.attenuator_ports[30],
        _tl211_rf_att_1.attenuator_ports[31],
        _tl211_rf_att_1.attenuator_ports[32],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.180.225", port="5001"),
        ],
    ),
)

# RMOD-20 / RMOD_R-4: AVQQ #25
_rmod20_AVQQ_25 = RU(
    ru_hw_group="cMAAr7.1_32T32R",
    radio_type=RadioTypes.AVQQ.value,
    serial_number="1M243505026",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.158", port=2323
    ),
    pdu_port=_pdu1_2001.pdu_ports[4],
    attenuation_ports=[
        _tl211_rf_att_2.attenuator_ports[13],
        _tl211_rf_att_2.attenuator_ports[14],
        _tl211_rf_att_2.attenuator_ports[15],
        _tl211_rf_att_2.attenuator_ports[16],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.180.226", port="5001"),
        ],
    ),
)

# RMOD-21 / RMOD_R-5: AVQQ #28
_rmod21_AVQQ_28 = RU(
    ru_hw_group="cMAAr7.1_32T32R",
    radio_type=RadioTypes.AVQQ.value,
    serial_number="1M243505030",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.162", port=2323
    ),
    pdu_port=_pdu1_2001.pdu_ports[7],
    attenuation_ports=[
        _tl211_rf_att_2.attenuator_ports[29],
        _tl211_rf_att_2.attenuator_ports[30],
        _tl211_rf_att_2.attenuator_ports[31],
        _tl211_rf_att_2.attenuator_ports[32],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.180.227", port="5001"),
        ],
    ),
)

# RMOD-7 / RMOD_R-7: AHEGHA #08  f1
_rmod7_AHEGHA_08 = RU(
    ru_hw_group="FRMr6.2a_4T4R",
    radio_type=RadioTypes.AHEGHA.value,
    serial_number="K9244426701",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.133", port=2323
    ),
    pdu_port=_pdu1_2001.pdu_ports[3],
    attenuation_ports=[
        _tl211_rf_att_1.attenuator_ports[5],
        _tl211_rf_att_1.attenuator_ports[6],
        _tl211_rf_att_1.attenuator_ports[7],
        _tl211_rf_att_1.attenuator_ports[8],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.181.4", port="5001"),
        ],
    ),
)

# RMOD-8 / RMOD_R-8: AHEGHA #09
_rmod8_AHEGHA_09 = RU(
    ru_hw_group="FRMr6.2a_4T4R",
    radio_type=RadioTypes.AHEGHA.value,
    serial_number="K9244426702",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.131", port=2323
    ),
    pdu_port=_pdu1_2001.pdu_ports[6],
    attenuation_ports=[
        _tl211_rf_att_2.attenuator_ports[5],
        _tl211_rf_att_2.attenuator_ports[6],
        _tl211_rf_att_2.attenuator_ports[7],
        _tl211_rf_att_2.attenuator_ports[8],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.181.5", port="5001"),
        ],
    ),
)

# RMOD-9 / RMOD_R-9: AHEGHA #07
_rmod9_AHEGHA_07 = RU(
    ru_hw_group="FRMr6.2a_4T4R",
    radio_type=RadioTypes.AHEGHA.value,
    serial_number="K9244426700",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.132", port=2323
    ),
    pdu_port=_pdu1_2001.pdu_ports[9],
    attenuation_ports=[
        _tl211_rf_att_2.attenuator_ports[21],
        _tl211_rf_att_2.attenuator_ports[22],
        _tl211_rf_att_2.attenuator_ports[23],
        _tl211_rf_att_2.attenuator_ports[24],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.181.6", port="5001"),
        ],
    ),
)


# RMOD-10 / RMOD_R-10: AHEGHA #08  f2
_rmod10_AHEGHA_08 = RU(
    ru_hw_group="FRMr6.2a_4T4R",
    radio_type=RadioTypes.AHEGHA.value,
    serial_number="K9244426701",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.133", port=2323
    ),
    pdu_port=_pdu1_2001.pdu_ports[3],
    attenuation_ports=[
        _tl211_rf_att_1.attenuator_ports[13],
        _tl211_rf_att_1.attenuator_ports[14],
        _tl211_rf_att_1.attenuator_ports[15],
        _tl211_rf_att_1.attenuator_ports[16],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.181.4", port="5001"),
        ],
    ),
)

# RMOD-11 / RMOD_R-11: AHEGHA #08  f3
_rmod11_AHEGHA_08 = RU(
    ru_hw_group="FRMr6.2a_4T4R",
    radio_type=RadioTypes.AHEGHA.value,
    serial_number="K9244426701",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.133", port=2323
    ),
    pdu_port=_pdu1_2001.pdu_ports[3],
    attenuation_ports=[
        _tl211_rf_att_1.attenuator_ports[21],
        _tl211_rf_att_1.attenuator_ports[22],
        _tl211_rf_att_1.attenuator_ports[23],
        _tl211_rf_att_1.attenuator_ports[24],
    ],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.46.181.4", port="5001"),
        ],
    ),
)


_BBMOD1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="473096A.107",
    serial_number="L1233206754",
    rus=[
        _rmod1_AHPMDG_23,
        _rmod2_AHPMDG_29,
        _rmod3_AHPMDG_33,
    ],
)

_BBMOD2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1241507276",
    rus=[
        _rmod1_AHPMDG_23,
        _rmod2_AHPMDG_29,
        _rmod3_AHPMDG_33,
        _rmod7_AHEGHA_08,
        _rmod8_AHEGHA_09,
        _rmod9_AHEGHA_07,
    ],
)

_BBMOD3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIQ",
    hardware_version="476397A.102",
    serial_number="L1241507179",
    rus=[
        _rmod19_AVQQ_26,
        _rmod20_AVQQ_25,
        _rmod21_AVQQ_28,
        _rmod7_AHEGHA_08,
        _rmod8_AHEGHA_09,
        _rmod9_AHEGHA_07,
    ],
)

_SMOD1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_BBMOD1, _BBMOD2, _BBMOD3],
    pdu_port=_pdu1_2011.pdu_ports[1],
    hardware_type="ASIB",
    serial_number="L1200900064",
)

_airscale_TL211 = Airscale(common_units=[_SMOD1])
_airscale_gNB1 = DU(
    airscale=_airscale_TL211,
    rus=[
        _rmod1_AHPMDG_23,
        _rmod2_AHPMDG_29,
        _rmod3_AHPMDG_33,
        _rmod19_AVQQ_26,
        _rmod20_AVQQ_25,
        _rmod21_AVQQ_28,
        _rmod7_AHEGHA_08,
        _rmod8_AHEGHA_09,
        _rmod9_AHEGHA_07,
        _rmod10_AHEGHA_08,
        _rmod11_AHEGHA_08,
    ],
)
_comnBTS_gNB1 = ClassicalBts(
    cu=_cu_gnb_1, dus=[_airscale_gNB1], global_bts_id=452111, instance_id=452111
)

_comnBTS_eNB1 = RealEnb(
    system_module=_airscale_TL211,
    rms=[
        _rmod1_AHPMDG_23,
        _rmod2_AHPMDG_29,
        _rmod3_AHPMDG_33,
        _rmod19_AVQQ_26,
        _rmod20_AVQQ_25,
        _rmod21_AVQQ_28,
        _rmod7_AHEGHA_08,
        _rmod8_AHEGHA_09,
        _rmod9_AHEGHA_07,
        _rmod10_AHEGHA_08,
        _rmod11_AHEGHA_08,
    ],
    oam_ip=NetworkAddress(v4="10.47.211.17"),
)
# ----------------- STOP eNB Common -------------------- TL211

_bts2g_gsm_1 = Bts2G(
    system_module=_airscale_TL211,
    rms=[
        _rmod1_AHPMDG_23,
        _rmod2_AHPMDG_29,
        _rmod3_AHPMDG_33,
        _rmod19_AVQQ_26,
        _rmod20_AVQQ_25,
        _rmod21_AVQQ_28,
        _rmod7_AHEGHA_08,
        _rmod8_AHEGHA_09,
        _rmod9_AHEGHA_07,
    ],
    bcf_id="10",
    master=_comnBTS_eNB1,
)

_bsc1 = BSC(
    name="BSC-21",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.38.63.245", username="SYSTEM", password="SYSTEM"
    ),
)

# ---------------- START Core APP Server -------------------
_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="DEUL5Gappsrv07.ulm.nsn-rdnet.net",
        username="ute",
        password="UTE.debian12",
    ),
    network_interface_address="10.47.194.207",
    # iperf_path="iperf",
    # ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254],
)

_appserver = AppServer(_iperf_details_on_appserver)

# DEUL5Gappsrv07
_app_server_for_IPERF_PING = TafUeAppServer(
    app_server_name="DEUL5Gappsrv07",
    address="DEUL5Gappsrv07.ulm.nsn-rdnet.net",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.207",
)

_app_server_for_FTP = TafUeAppServer(
    app_server_name="DEUL5Gappsrv07",
    address="DEUL5Gappsrv07.ulm.nsn-rdnet.net",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.207",
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

# ---------------- START TEST PCs ------------------------ #
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        # addr="10.47.12.85", username="ute", password="ute"
        addr="7-15-UTESRANTL211.ulm.nsn-rdnet.net",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[
        Connection(interface="eth1", device=_SMOD1, interface_type="lmp"),
    ],
)
# ---------------- END TEST PCs -------------------------- #

# ---------------- START UE CTRl PCs ------------------------
_ue_ctrl_NUC_pc1_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC1-211.intra.noklab.net",
    username="deul5g",
    password="Nuc2Ue4PzLab!"
)

_ue_ctrl_NUC_pc2_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC211-2.intra.noklab.net",
    username="deul5g",
    password="Nuc2Ue4PzLab!",
)

# ---------------- START UE1: Samsung S24 Ultra #41 (SM-S911B Qualcomm) ------------------------
_ue1 = TafUeAndroid(
    ssh_connection_details=_ue_ctrl_NUC_pc1_ssh_details,
    serial_number='R5CX92VJJ9M',
    capabilities=["REAL_UE"
                  "REAL_ANDROID_UE",
                  "UE_2",    # temporarily referncing UE_1 as UE_2 as long as TA code has not been updated yet
                 ],
    ue_pc_address='DEUL5GNUC1-211.intra.noklab.net',
    data_transfer=[_data_transfer_iperf,
                   _data_transfer_ping,
                   _data_transfer_ftp],
    phone_number='+358480011058',
    ue_pc_port='8080',
    imei='350683212463870',
    imsi='001010000011058',
    pdns=_pdns_for_ue1,
    qualcomm_prototype=True,
    network_mode_switch_method='keyevents',
    path_to_network_mode_type='Mobile networks/Network mode',
    is_rooted='no',
    download_proxy_logs=True,
    compress_proxy_logs=True,
    allow_kw_logs=True,
)
# ---------------- END UE1: Samsung S24 Ultra #41 (SM-S911B Qualcomm) ------------------------

# ---------------- START UE2: Samsung S24 #19 (SM-S921B Exynos) ------------------------
_ue2 = TafUeAndroid(
    ssh_connection_details=_ue_ctrl_NUC_pc2_ssh_details,
    serial_number='R3CX9051S9R',
    capabilities=["REAL_UE"
                  "REAL_ANDROID_UE",
                  "UE_1",    # temporarily referncing UE_2 as UE_1 as long as TA code has not been updated yet
                 ],
    ue_pc_address='DEUL5GNUC211-2.intra.noklab.net',
    data_transfer=[_data_transfer_iperf,
                   _data_transfer_ping,
                   _data_transfer_ftp],
    phone_number='+3548247700091',
    ue_pc_port='8080',
    imei='358673441432152',
    imsi='001017700000091',
    pdns=_pdns_for_ue2,
    qualcomm_prototype=True,
    network_mode_switch_method='keyevents',
    path_to_network_mode_type='Mobile networks/Network mode',
    is_rooted='no',
    download_proxy_logs=True,
    compress_proxy_logs=True,
    allow_kw_logs=True,
)
# ---------------- END UE2: Samsung S24 #19 (SM-S921B Exynos) ------------------------


# ----------------------------------------- TL ----------------------------------------- TL211
tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    bts2g_objects=[_bts2g_gsm_1],
    gnbs=[_comnBTS_gNB1],
    enbs=[_comnBTS_eNB1],
    pdus=[_pdu1_2001, _pdu1_2011],
    core=_realCore,
    attenuators=[_tl211_rf_att_1, _tl211_rf_att_2],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_SRAN_NLG_1ASIB_1ABIA_2ABIO_3AHPMDB_3AHEGB_3AHHB_3AVQQ",
    ues=[_ue1, _ue2],
    bscs=[_bsc1],
)

__all__ = ["tl"]
# ----------------------------------------- TL ----------------------------------------- #
