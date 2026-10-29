# This file was updated starting from 10_16_UTESRAN358
#########################################
# TestLine TL233 Ulm (7_15_UTESRANTL233)#
#########################################
__maintainer__ = "Nikolay Shkulepov"
__email__ = "nikolay.shkulepov@nokia.com"

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

# ---------------- START Power Switchs gNB_233

# pdu1_2023 - SMOD_pdu: gNB. AP
_pdu1_2023 = Gude(
    addr="10.46.152.123",
    port_numbers=[5, 6],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# pdu1-2003 - RMOD_pdu#1: AHPMDG41, AHPMDG39, AHPMDG43
_pdu1_2003 = Gude(
    addr="10.46.152.134",
    port_numbers=[3, 6, 9],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)


# ---------------- START RF Attenuators
_gNB233_rf_att_1 = HBTE(
    ip_addr="10.46.152.239",
    port="5000",
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    version=None,
    model="PA-16-16-6-127-0.5-B-S",
)
# ---------------- END RF Attenuators

# ---------------- START gNB-1 -------------------TL233#
_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.84.3",
        v6="2a00:8a00:6000:600c::1b04",
        vlan_id=517,
        routing_v4=RoutingInformation(gateway="10.42.84.1/24"),
        routing_v6=RoutingInformation(gateway="GW:2a00:8a00:6000:600c::1b01/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.42.85.3",
        v6="2a00:8a00:6000:600c::1c03",
        vlan_id=518,
        routing_v4=RoutingInformation(gateway="10.42.85.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1c01/120"),
    ),
    x2u=NetworkAddress(
        v4="10.42.85.67",
        v6="2a00:8a00:6000:600c::1d03",
        vlan_id=519,
        routing_v4=RoutingInformation(gateway="10.42.85.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1d01/120"),
    ),
    s1u=NetworkAddress(
        v4="10.42.85.131",
        v6="2a00:8a00:6000:600c::1e03  ",
        vlan_id=520,
        routing_v4=RoutingInformation(gateway="10.42.85.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1e01/120"),
    ),
    ngu=NetworkAddress(
        v4="10.42.85.131",
        v6="2a00:8a00:6000:600c::1e03  ",
        vlan_id=520,
        routing_v4=RoutingInformation(gateway="10.42.85.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1e01/120"),
    ),
    ngc=NetworkAddress(
        v4="10.42.86.3",
        v6="2a00:8a00:6000:600c::2003",
        vlan_id=521,
        routing_v4=RoutingInformation(gateway="10.42.86.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::2004"),
    ),
    xnc=NetworkAddress(
        v4="10.42.85.3",
        v6="2a00:8a00:6000:600c::1c03",
        vlan_id=518,
        routing_v4=RoutingInformation(gateway="10.42.85.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1c01/120"),
    ),
    xnu=NetworkAddress(
        v4="10.42.85.67",
        v6="2a00:8a00:6000:600c::1d03",
        vlan_id=519,
        routing_v4=RoutingInformation(gateway="10.42.85.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1d01/120"),
    ),
)
_BBMOD1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171216180",
)
_BBMOD2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223400358",
)
_BBMOD3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223309881",
)
_SMOD1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_BBMOD1, _BBMOD2, _BBMOD3],
    pdu_port=_pdu1_2023.port_numbers[0],
    hardware_type="ASIB",
    serial_number="DH212077196",
)
# RMOD_R-1: AHPMDG #41
_rmod1_AHPMDG_41 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type=RadioTypes.AHPMDG,
    serial_number="EA223662686",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu1_2003.port_numbers[0],
    attenuation_ports=[
        _gNB233_rf_att_1.attenuation_port_numbers[0],
        _gNB233_rf_att_1.attenuation_port_numbers[1],
        _gNB233_rf_att_1.attenuation_port_numbers[2],
        _gNB233_rf_att_1.attenuation_port_numbers[3],
    ],
)

# RMOD_R-2: AHPMDG #39
_rmod1_AHPMDG_39 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type=RadioTypes.AHPMDG,
    serial_number="EA223662696",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.136", port=2323
    ),
    pdu_port=_pdu1_2003.port_numbers[1],
    attenuation_ports=[
        _gNB233_rf_att_1.attenuation_port_numbers[4],
        _gNB233_rf_att_1.attenuation_port_numbers[5],
        _gNB233_rf_att_1.attenuation_port_numbers[6],
        _gNB233_rf_att_1.attenuation_port_numbers[7],
    ],
)

# RMOD_R-3: AHPMDG #43
_rmod1_AHPMDG_43 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type=RadioTypes.AHPMDG,
    serial_number="EA223662811",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.134", port=2323
    ),
    pdu_port=_pdu1_2003.port_numbers[2],
    attenuation_ports=[
        _gNB233_rf_att_1.attenuation_port_numbers[8],
        _gNB233_rf_att_1.attenuation_port_numbers[9],
        _gNB233_rf_att_1.attenuation_port_numbers[10],
        _gNB233_rf_att_1.attenuation_port_numbers[11],
    ],
)



_airscale_TL233 = Airscale(common_units=[_SMOD1])
_airscale_gNB1 = DU(
    airscale=_airscale_TL233,
    rus=[
        _rmod1_AHPMDG_41,
        _rmod1_AHPMDG_39,
        _rmod1_AHPMDG_43,
    ],
)
_comnBTS_gNB1 = ClassicalBts(
    cu=_cu_gnb_1, dus=[_airscale_gNB1], global_bts_id=8011, instance_id=8011
)

# ----------------- START eNB Common --------------------TL233 #
_airscale_Common = Airscale(common_units=[_SMOD1])

_comnBTS_eNB1 = RealEnb(
    system_module=_airscale_Common,
    rms=[
        _rmod1_AHPMDG_41,
        _rmod1_AHPMDG_39,
        _rmod1_AHPMDG_43,
    ],
    oam_ip=NetworkAddress(v4="10.47.13.209"),
)
# ----------------- STOP eNB Common --------------------TL233 #


_bsc = BSC(
    name="BSC-22",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.38.63.245", username="SYSTEM", password="SYSTEM"
    ),
)

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
_app_server_1 = TafUeAppServer(
    app_server_name="DEUL5Gappsrv03",
    # address="10.47.194.203",
    address="DEUL5Gappsrv03.ulm.nsn-rdnet.net",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.203",
    #    binary_path="iperf",
    #    ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254]
)

_app_server_2 = TafUeAppServer(
    app_server_name="DEUL5Gappsrv03",
    address="10.47.194.203",
    # address="DEUL5Gappsrv03.ulm.nsn-rdnet.net",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.203",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    interval=1,
    #    binary_path="/data/local/tmp/iperf",
    version=3,
    dt_from_uepc=True,
)

_data_transfer_ping = TafUeDataTransferProtocol(
    protocol_name="ping",
    app_server=_app_server_2,
    interval=1,
)

_data_transfer_ftp = TafUeDataTransferProtocol(
    protocol_name="ftp",
    app_server=_app_server_1,
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
    addr="DEUL5GNUC1-233.intra.noklab.net",
    username="deul5g",
    password="Nuc2Ue4PzLab!",
    # addr="10.46.135.67", username="deul5g", password="Nuc2Ue4PzLab!"
)

_qualcomm45_sdx65 = TafUeAndroid(
    serial_number="ade6a19a",
    # ue_pc_address="10.46.135.67",
    ue_pc_address="DEUL5GNUC1-233.intra.noklab.net",
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
)
# ----------------END QC UE1: Qualcomm#45 SDX65 ------------------------ #

# ---------------- START MTK UE1 ------------------------
_ue_ctrl_pc2_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC2-233.intra.noklab.net", username="deul5g", password="Nuc2Ue4PzLab!"
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
    ue_pc_address="DEUL5GNUC2-233.intra.noklab.net",
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
                hardware_type='ASIL',
                capacity_units=[
                    CapacityUnit(addr='192.168.253.84', hardware_type='ABIO'),
                    CapacityUnit(addr='192.168.253.85', hardware_type='ABIO')],
                pdu_port=_pdu1_2023.port_numbers[1],
            )
        ]
    ),
)
# ---------------- END Airphone UE0 ------------------------

# ---------------- START TEST PCs ------------------------ #
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="7-15-UTESRANTL233-1.ulm.nsn-rdnet.net",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[
        Connection(interface="eth1", device=_SMOD1, interface_type="lmp"),
        _airphone
    ],
)
# ---------------- END TEST PCs -------------------------- #

# ----------------------------------------- TL ----------------------------------------- #
tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_comnBTS_gNB1],
    enbs=[_comnBTS_eNB1],
    pdus=[_pdu1_2003, _pdu1_2023],
    core=_tampereCore,
    attenuators=[_gNB233_rf_att_1],
    appserver=_appserver,
    tl_cloud_topology="CLOUD_SRAN_NLG_1ASIB_1ABIA_2ABIO_3AHPMDB_3AHEGB_3AHHB_3AEQQ",
    ues=[_airphone, _qualcomm45_sdx65, _mtk58asAndroid],
    bscs=[_bsc],
)

__all__ = ["tl"]
# ----------------------------------------- TL ----------------------------------------- #
