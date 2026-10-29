####################################################################################
# TestLine-node TL234 TEF  [single RMOD/sector non-RAN-sharing neighboring TL-node] (7_15_UTESRANTL234)
#-----------------------------------------------------------------------------------
# TestLine-node TL232 DTAG_MORAN (7_15_UTESRANTL232) - single-SMOD site configuration variant
# TestLine-node TL235 DTAG [single RMOD/sector non-RAN-sharing neighboring TL-node] (7_15_UTESRANTL235)
####################################################################################
__maintainer__ = "Masiar Makkinejad"
__email__ = "Masiar.Makkinejad@nokia.com"

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

from taf.config.testline.pdn import PDN, PDPTypes, PDNTafUeAndroidDetails, PDNAndroidDetails

from taf.config.testline.appserver import AppServer

from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
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

#++++++++++++++ TL234 PDU OVERVIEW +++++++++++++++++++
# pdu1-2023:           SMODs
# pdu3-2003:           RMODs AHPMDG TL232
# pdu4-2003:           RMODs OFEGSA
# pdu1-2003:           RMODs AHPMDG TL234/TL235
#++++++++++++++ TL234 PDU OVERVIEW +++++++++++++++++++

# pdu1-2023 - SMOD_pdu: ASIB
_pdu1_2023 = Gude(
    addr="10.46.152.123",
    port_numbers=[7],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# pdu3-2003 - RMOD_pdu_1: AHPMDGs #36/#35/#37
_pdu3_2003 = Gude(
    addr="10.46.152.133",
    port_numbers=[3, 6, 9],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# pdu4-2003 - RMOD_pdu_2: OFEGSA #25/#20/#22
_pdu4_2003 = Gude(
    addr="10.46.152.134",
    port_numbers=[5, 8, 11],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# pdu1-2003 - RMOD_pdu_3: AHPMDG #34/#32
_pdu1_2003 = Gude(
    addr="10.46.152.131",
    port_numbers=[6, 9],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# ---------------- START RF Attenuators
# deul5gatt1-232: HTBE 32-Port
_gNB232_rf_att_1 = HBTE(
    ip_addr="10.46.152.223",
    port="5000",
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29,30, 31, 32],
    version=None,
    model="PA-16-16-6-127-0.5-B-S",
)
# ---------------- END RF Attenuators


# ---------------- START gNB-1 -------------------#
_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.223.81",
        #v6="",
        vlan_id=1234,
        routing_v4=RoutingInformation(gateway="10.47.223.86"),
        #routing_v6=RoutingInformation(gateway=""),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(
        v4="10.47.121.121",
        #v6="",
        vlan_id=1434,
        routing_v4=RoutingInformation(gateway=""),
        #routing_v6=RoutingInformation(gateway=""),
    ),
    x2u=NetworkAddress(
        v4="10.47.223.97",
        #v6="",
        vlan_id=1434,
        routing_v4=RoutingInformation(gateway=""),
        #routing_v6=RoutingInformation(gateway=""),
    ),
    s1u=NetworkAddress(
        v4="10.47.223.105",
        #v6="",
        vlan_id=1434,
        routing_v4=RoutingInformation(gateway=""),
        #routing_v6=RoutingInformation(gateway=""),
    ),
    ngu=NetworkAddress(
        v4="10.47.223.121",
        #v6="",
        vlan_id=1334,
        routing_v4=RoutingInformation(gateway=""),
        #routing_v6=RoutingInformation(gateway=""),
    ),
    ngc=NetworkAddress(
        v4="10.47.223.113",
        #v6="",
        vlan_id=1334,
        routing_v4=RoutingInformation(gateway=""),
        #routing_v6=RoutingInformation(gateway=""),
    ),
    xnc=NetworkAddress(
        v4="10.47.223.113",
        #v6="",
        vlan_id=1334,
        routing_v4=RoutingInformation(gateway=""),
        #routing_v6=RoutingInformation(gateway=""),
    ),
    xnu=NetworkAddress(
        v4="10.47.223.121",
        #v6="",
        vlan_id=1334,
        routing_v4=RoutingInformation(gateway=""),
        #routing_v6=RoutingInformation(gateway=""),
    ),
)

_BBMOD1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="475266A.105",
    serial_number="L1233704383",
)

# _BBMOD2 = CapacityUnit(
#     addr="192.168.253.26",
#     hardware_type="ABIQ",
#     hardware_version="476397A.102",
#     serial_number="L1243811802",
# )

# _BBMOD3 = CapacityUnit(
#     addr="192.168.253.30",
#     hardware_type="ABIO",
#     hardware_version="475792A.102",
#     serial_number="DH250612236",
# )

_SMOD1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_BBMOD1],
    pdu_port=_pdu1_2023.pdu_ports[7],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1200806988",
)


# TL234 RMOD-1: AHPMDG #34 (connected to TL-Node-234_TEF)
_rmod1_AHPMDG_34 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHPMDG.value,
    serial_number="K9243835138",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.134", port=2323
    ),
    pdu_port=_pdu1_2003.pdu_ports[6],
    attenuation_ports=[
        _gNB232_rf_att_1.attenuator_ports[25],
        _gNB232_rf_att_1.attenuator_ports[26],
        _gNB232_rf_att_1.attenuator_ports[27],
        _gNB232_rf_att_1.attenuator_ports[28],
    ],
    #lmi=SerialOverTcp(
    #    uart_mapping=[
    #        Remote(addr="10.46.181.16", port="5001"),
    #    ],
    #),
)

# TL235 RMOD-1000: AHPMDG #32 (connected to TL-Node-235_DTAG)
_rmod1_AHPMDG_32 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHPMDG.value,
    serial_number="K9243835107",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.134", port=2323
    ),
    pdu_port=_pdu3_2003.pdu_ports[9],
    attenuation_ports=[
        _gNB232_rf_att_1.attenuator_ports[29],
        _gNB232_rf_att_1.attenuator_ports[30],
        _gNB232_rf_att_1.attenuator_ports[31],
        _gNB232_rf_att_1.attenuator_ports[32],
    ],
    #lmi=SerialOverTcp(
    #    uart_mapping=[
    #        Remote(addr="10.46.181.16", port="5001"),
    #    ],
    #),
)

# RMOD-1000: AHPMDG #36 (connected to TL-Node-232-1_DTAG-TEF_MORAN)
_rmod1_AHPMDG_36 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHPMDG.value,
    serial_number="K9244211504",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu3_2003.pdu_ports[3],
    attenuation_ports=[
        _gNB232_rf_att_1.attenuator_ports[1],
        _gNB232_rf_att_1.attenuator_ports[2],
        _gNB232_rf_att_1.attenuator_ports[3],
        _gNB232_rf_att_1.attenuator_ports[4],
    ],
    #lmi=SerialOverTcp(
    #    uart_mapping=[
    #        Remote(addr="", port="5001"),
    #    ],
    #),
)

# RMOD-1400: OFEGSA #25 (connected to TL-Node-232-1_DTAG-TEF_MORAN)
_rmod2_OFEGSA_25 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type=FujitsuRadioTypes.OFEGSA.value,
    serial_number="00308",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu4_2003.pdu_ports[5],
    attenuation_ports=[
        _gNB232_rf_att_1.attenuator_ports[5],
        _gNB232_rf_att_1.attenuator_ports[6],
        _gNB232_rf_att_1.attenuator_ports[7],
        _gNB232_rf_att_1.attenuator_ports[8],
    ],
)

# RMOD-2000: AHPMDG #35 (connected to TL-Node-232-1_DTAG-TEF_MORAN)
_rmod3_AHPMDG_35 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHPMDG.value,
    serial_number="K9242706911",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.136", port=2323
    ),
    pdu_port=_pdu3_2003.pdu_ports[6],
    attenuation_ports=[
        _gNB232_rf_att_1.attenuator_ports[9],
        _gNB232_rf_att_1.attenuator_ports[10],
        _gNB232_rf_att_1.attenuator_ports[11],
        _gNB232_rf_att_1.attenuator_ports[12],
    ],
    #lmi=SerialOverTcp(
    #    uart_mapping=[
    #        Remote(addr="", port="5001"),
    #    ],
    #),
)

# RMOD-2400: OFEGSA #20 (connected to TL-Node-232-1_DTAG-TEF_MORAN)
_rmod4_OFEGSA_20 = RU(
    ru_hw_group="TA08029-B312/01",
    radio_type=FujitsuRadioTypes.OFEGSA.value,
    serial_number="00310",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu4_2003.pdu_ports[8],
    attenuation_ports=[
        _gNB232_rf_att_1.attenuator_ports[13],
        _gNB232_rf_att_1.attenuator_ports[14],
        _gNB232_rf_att_1.attenuator_ports[15],
        _gNB232_rf_att_1.attenuator_ports[16],
    ],
)

# RMOD-3000: AHPMDG #37 (connected to TL-Node-232-1_DTAG-TEF_MORAN)
_rmod5_AHPMDG_37 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHPMDG.value,
    serial_number="K9242706868",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.134", port=2323
    ),
    pdu_port=_pdu3_2003.pdu_ports[9],
    attenuation_ports=[
        _gNB232_rf_att_1.attenuator_ports[17],
        _gNB232_rf_att_1.attenuator_ports[18],
        _gNB232_rf_att_1.attenuator_ports[19],
        _gNB232_rf_att_1.attenuator_ports[20],
    ],
    #lmi=SerialOverTcp(
    #    uart_mapping=[
    #        Remote(addr="10.46.181.16", port="5001"),
    #    ],
    #),
)

# RMOD-3400: OFEGSA #22 (connected to TL-Node-232-1_DTAG-TEF_MORAN)
_rmod6_OFEGSA_22 = RU(
    ru_hw_group="TA08029-B312/01",
    radio_type=FujitsuRadioTypes.OFEGSA.value,
    serial_number="00307",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu4_2003.pdu_ports[11],
    attenuation_ports=[
        _gNB232_rf_att_1.attenuator_ports[21],
        _gNB232_rf_att_1.attenuator_ports[22],
        _gNB232_rf_att_1.attenuator_ports[23],
        _gNB232_rf_att_1.attenuator_ports[24],
    ],
)


#_airscale = Airscale(common_units=[_SMOD1])
_airscale = Airscale(common_units=[_SMOD1])

_airscale_gNB1 = DU(
    airscale=_airscale,
    #airscale=_airscale_Common,
    rus=[
        _rmod1_AHPMDG_34,    # TL234
        # TL232
        _rmod1_AHPMDG_36,    # TL232
        _rmod2_OFEGSA_25,    # TL232
        _rmod3_AHPMDG_35,    # TL232
        _rmod4_OFEGSA_20,    # TL232
        _rmod5_AHPMDG_37,    # TL232
        _rmod6_OFEGSA_22,    # TL232
        # TL235
        _rmod1_AHPMDG_32,    # TL235
    ],
)

_comnBTS_gNB1 = ClassicalBts(
    cu=_cu_gnb_1, dus=[_airscale_gNB1], global_bts_id=402341, instance_id=402341
)

# ----------------- START eNB Common --------------------#
_airscale_Common = Airscale(common_units=[_SMOD1])

_comnBTS_eNB1 = RealEnb(
    system_module=_airscale_Common,
    rms=[
        _rmod1_AHPMDG_34,    # TL234
        # TL232
        _rmod1_AHPMDG_36,    # TL232
        _rmod2_OFEGSA_25,    # TL232
        _rmod3_AHPMDG_35,    # TL232
        _rmod4_OFEGSA_20,    # TL232
        _rmod5_AHPMDG_37,    # TL232
        _rmod6_OFEGSA_22,    # TL232
        # TL235
        _rmod1_AHPMDG_32,    # TL235
    ],
    oam_ip=NetworkAddress(v4="10.47.223.81"),
)
# ----------------- STOP eNB Common ------------------- #

# _bts2g_gsm = Bts2G(
#     system_module=_airscale_Common,
#     rms=[
#         _rmod1_AHPMDG_36,
#         _rmod3_AHPMDG_35,
#         _rmod5_AHPMDG_37,
#     ],
#     bcf_id="33",
#     master=_comnBTS_gNB1,
# )

# _bsc = BSC(
#     name="BSC-416075",
#     logging_telnet_connection_details=TelnetConnectionDetails(
#         addr="2A00:8A00:4000:6000:0000:0000:0082:7F07", username="SYSTEM", password="SYSTEM"
#     ),
# )

# ---------------- START Core APP Server -------------------
_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="DEUL5Gappsrv37.ulm.nsn-rdnet.net",
        username="ute",
        password="UTE.debian12",
    ),
    network_interface_address="10.47.194.237",
    # iperf_path="iperf",
    # ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254],
)

_appserver = AppServer(_iperf_details_on_appserver)

# DEUL5Gappsrv37
_app_server_for_IPERF_PING = TafUeAppServer(
    app_server_name="DEUL5Gappsrv37",
    address="DEUL5Gappsrv37.ulm.nsn-rdnet.net",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.237",
)

_app_server_for_FTP = TafUeAppServer(
    app_server_name="DEUL5Gappsrv37",
    address="DEUL5Gappsrv37.ulm.nsn-rdnet.net",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.237",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_for_IPERF_PING,
    interface_name='rmnet_data0',
    interval=1,
    version=3,
    dt_from_uepc=True,
    server_close_delay=300,
    # binary_path="/data/local/tmp/iperf",
)

_data_transfer_ping = TafUeDataTransferProtocol(
    protocol_name="ping",
    app_server=_app_server_for_IPERF_PING,
    interface_name='rmnet_data0',
    interval=1,
)

_data_transfer_ftp = TafUeDataTransferProtocol(
    protocol_name="ftp",
    app_server=_app_server_for_FTP,
    interface_name='rmnet_data0',
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
        apnName="n26ho.ulm.com",
        apnType=['DEFAULT'],
        ),
    PDNTafUeAndroidDetails(
        entryName="voice_apn",
        apnName="ims5g",
        apnType=['MMS', 'IMS'],
        ),
]

_core_DTAG = RealCore(mcc="1", mnc="1")     # Note: "pdns" given in RealCore() must be of instances of PDN()
_core_TEF  = RealCore(mcc="1", mnc="2")     # Note: "pdns" given in RealCore() must be of instances of PDN()
# ---------------- END PDNs.

# ---------------- START UEs Controll NUC PSc ------------------------ #
_ue_ctrl_NUC_pc1_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC232-1.intra.noklab.net",
    username="deul5g",
    password="Nuc2Ue4PzLab!",
    # addr="10.46.135.49", username="deul5g", password="Nuc2Ue4PzLab!"
)

# ---------------- END UEs Controll NUC PSc ------------------------ #
_ue_ctrl_pc1_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC232-1.intra.noklab.net",
    username="deul5g",
    password="Nuc2Ue4PzLab!",
)

# ---------------- START UE1 (DTAG): Samsung S25 (SM-S931B Exynos) ------------------------
_ue1_S25_DTAG = TafUeAndroid(
    ssh_connection_details=_ue_ctrl_pc1_ssh_details,
    serial_number='R3CY4056ZLP',
    capabilities=["REAL_UE"
                  "REAL_ANDROID_UE",
                  "UE_1",
                  "UE_DTAG",
                 ],
    ue_pc_address='DEUL5GNUC232-1.intra.noklab.net',
    data_transfer=[_data_transfer_iperf,
                   _data_transfer_ping,
                   _data_transfer_ftp],
    phone_number='+3548247700026',             # OPTIONAL (however MANDATORY for Voice Calls to work properly)
    ue_pc_port='8080',
    imei='352688836327946',
    imsi='001017700000026',
    pdns=_pdns_for_ue1,
    qualcomm_prototype=True,
    #service_call_attach='123',
    #service_call_detach='124',
    network_mode_switch_method='keyevents',
    #airplane_mode_switcher_text='Airplane',
    #airplane_mode_confirm_button_text='OK',
    path_to_network_mode_type='Mobile networks/Network mode',
    is_rooted='no',                            # will be removed, no need to pass it anymore, the check happens on the UE instead
    #voice_call_technology='2G',
    #voice_call_technology_timeout=60.0,
    #voice_call_dialing_timeout=-1.0,
    #processes_to_kill=['Vysor'],              # OPTIONAL if list is not empty, processes will try to be killed on UEPC
    download_proxy_logs=True,                  # OPTIONAL (default is True)
    compress_proxy_logs=True,                  # OPTIONAL (default is False; if True ue_proxy logs would be left in zipped archive beside robot logs)
    #ueproxy_force_release=True,               # OPTIONAL [proxy.mngr] parameter specify if ueproxy service should be released before running next test suite (omit if proxy mngr communication not configured)
    allow_kw_logs=True,                        # OPTIONAL (default is True; if False kw_data logs would be skipped)
)
# ---------------- END UE2 (DTAG): Samsung S25 ------------------------

# ---------------- START UE2 (TEF): Samsung S25 (SM-S931B Exynos) ------------------------
_ue2_S25_TEF = TafUeAndroid(
    ssh_connection_details=_ue_ctrl_pc1_ssh_details,
    serial_number='R3CY40588QJ',
    capabilities=["REAL_UE"
                  "REAL_ANDROID_UE",
                  "UE_2",
                  "UE_TEF",
                 ],
    ue_pc_address='DEUL5GNUC232-1.intra.noklab.net',
    data_transfer=[_data_transfer_iperf,
                   _data_transfer_ping,
                   _data_transfer_ftp],
    phone_number='+3548275700002',             # OPTIONAL (however MANDATORY for Voice Calls to work properly)
    ue_pc_port='8080',
    imei='352688836341848',
    imsi='001020000000002',
    pdns=_pdns_for_ue2,
    qualcomm_prototype=True,
    #service_call_attach='123',
    #service_call_detach='124',
    #network_mode_switch_method='keyevents',
    #airplane_mode_switcher_text='Airplane',
    #airplane_mode_confirm_button_text='OK',
    path_to_network_mode_type='Mobile networks/Preferred network type',
    is_rooted='no',                            # will be removed, no need to pass it anymore, the check happens on the UE instead
    #voice_call_technology='2G',
    #voice_call_technology_timeout=60.0,
    #voice_call_dialing_timeout=-1.0,
    #processes_to_kill=['Vysor'],              # OPTIONAL if list is not empty, processes will try to be killed on UEPC
    download_proxy_logs=True,                  # OPTIONAL (default is True)
    compress_proxy_logs=True,                  # OPTIONAL (default is False; if True ue_proxy logs would be left in zipped archive beside robot logs)
    #ueproxy_force_release=True,               # OPTIONAL [proxy.mngr] parameter specify if ueproxy service should be released before running next test suite (omit if proxy mngr communication not configured)
    allow_kw_logs=True,                        # OPTIONAL (default is True; if False kw_data logs would be skipped)
)
# ----------------END UE2 (DTAG): Samsung S25 ------------------------ #


# ---------------- START TEST PCs ------------------------ #
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="7-15-UTESRANTL234-1.ulm.nsn-rdnet.net",
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
    #bts2g_objects=[_bts2g_gsm],
    gnbs=[_comnBTS_gNB1],
    enbs=[_comnBTS_eNB1],
    pdus=[_pdu1_2023, _pdu3_2003, _pdu4_2003, _pdu1_2003],
    core=_core_DTAG,
    attenuators=[_gNB232_rf_att_1],
    appserver=_appserver,
    tl_cloud_topology="N/A",
    #ues=[_ue1_S25_DTAG],
    ues=[_ue1_S25_DTAG, _ue2_S25_TEF],
    #bscs=[_bsc],
)

__all__ = ["tl"]
# ----------------------------------------- TL ----------------------------------------- #
