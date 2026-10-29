#######################################
# TestLine TL107 Ulm (7_15_UTE5GTL107)#
#######################################
__maintainer__ = "MN ECE RD ULM L2PS 04 SG SQD64"
__team__ = "MN ECE RD ULM L2PS 04 SG SQD64"
__email__ = "I_MN_ECE_ULM_RD_L2PS_04_SG_SQD64_NIMS@internal.nsn.com"

import os

from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import AppServer
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import RealEnb
from taf.config.testline import RoutingInformation
from taf.config.testline.core import RealCore4G
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.attenuator import HBTE
from taf.config.testline.pdn import PDN, PDPTypes
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeMtk


cfg_dir = os.path.dirname(os.path.abspath(__file__))

_tampereCore = RealCore4G(mcc="555", mnc="10")

_snmp_user_data = dict(
    userName="user",
    authKey="qwer2009!",
    privKey="qwer2009!",
    authProtocol="SHA",
    privProtocol="AES",
)

_pdns = [
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi1.nokia.com.mnc001.mcc540.gprs"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi2.nokia.com.mnc001.mcc540.gprs"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsa"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi3.nokia.com.mnc001.mcc540.gprs"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsaslicemqi1.mnc001.mcc540.gprs"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi1.nokia.com.mnc007.mcc244.gprs"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsaslicemqi2.mnc007.mcc244.gprs"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi3.nokia.com.mnc007.mcc244.gprs"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi2.nokia.com.mnc007.mcc244.gprs"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi4.nokia.com.mnc001.mcc540.gprs"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi5.nokia.com.mnc001.mcc540.gprs"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi4.nokia.com.mnc007.mcc244.gprs"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsagbr1.nokia.com"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi5.nokia.com.mnc007.mcc244.gprs"),
]


# ---------------- START gNB-1 ------------------- #
_gnb1_rf_att = HBTE(
    ip_addr="10.46.133.82",
    port="5000",
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    version=None,
    model="PA-16-16-6-127-0.5-B-S",
)

_gnb1_comu_pdu = Gude(
    addr="10.46.133.46",
    port_numbers=[5],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_gnb1_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.198.194",
        routing=RoutingInformation(gateway="10.47.201.222", ip_prefix_length=27),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.198.194", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.198.194", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.198.195"),
    x2u=NetworkAddress(v4="10.47.198.196"),
    s1u=NetworkAddress(v4="10.47.198.196"),
)

_gnb1_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")

_gnb1_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.11", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gnb1_capu1],
    pdu_port=_gnb1_comu_pdu.pdu_ports[5],
    hardware_type="ASIK",
)

_gnb1_airscale = Airscale(common_units=[_gnb1_common_unit])

_gnb1_rf_pdu1 = Gude(
    addr="10.46.133.17",
    port_numbers=[1, 2, 3],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_gnb1_du_rm1 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb1_rf_pdu1.pdu_ports[1],
    radio_type="AHCA",
    attenuation_ports=[
        _gnb1_rf_att.attenuator_ports[1],
        _gnb1_rf_att.attenuator_ports[2],
        _gnb1_rf_att.attenuator_ports[3],
        _gnb1_rf_att.attenuator_ports[4],
    ],
)

_gnb1_du_rm2 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb1_rf_pdu1.pdu_ports[2],
    radio_type="AHCA",
    attenuation_ports=[
        _gnb1_rf_att.attenuator_ports[5],
        _gnb1_rf_att.attenuator_ports[6],
        _gnb1_rf_att.attenuator_ports[7],
        _gnb1_rf_att.attenuator_ports[8],
    ],
)

_gnb1_du_rm3 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb1_rf_pdu1.pdu_ports[3],
    radio_type="AHCA",
    attenuation_ports=[
        _gnb1_rf_att.attenuator_ports[9],
        _gnb1_rf_att.attenuator_ports[10],
        _gnb1_rf_att.attenuator_ports[11],
        _gnb1_rf_att.attenuator_ports[12],
    ],
)

_gnb1_du = DU(airscale=_gnb1_airscale, rus=[_gnb1_du_rm1, _gnb1_du_rm2, _gnb1_du_rm3])

_gnb1 = ClassicalBts(cu=_gnb1_cu, dus=[_gnb1_du])

# ----------------- END gNB-1 -------------------- #

# ---------------- START eNB-1 ------------------- #
_enb1_rf_att = HBTE(
    ip_addr="10.46.133.82",
    port="5000",
    attenuation_port_numbers=[13, 14, 15, 16],
    version=None,
    model="PA-16-16-6-127-0.5-B-S",
)

_enb1_comu_pdu = Gude(
    addr="10.46.133.46",
    port_numbers=[3],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_enb1_capu = CapacityUnit(addr="192.168.253.20", hardware_type="ABIA")

_enb1_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_enb1_capu],
    pdu_port=_enb1_comu_pdu.pdu_ports[3],
    hardware_type="ASIK",
)

_enb1_rf_pdu = Gude(
    addr="10.46.133.46",
    port_numbers=[1],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_enb1_du_rm1 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_enb1_rf_pdu.pdu_ports[1],
    radio_type="AHCA",
    attenuation_ports=[
        _enb1_rf_att.attenuator_ports[13],
        _enb1_rf_att.attenuator_ports[14],
        _enb1_rf_att.attenuator_ports[15],
        _enb1_rf_att.attenuator_ports[16],
    ],
)

_enb1_airscale = Airscale(common_units=[_enb1_comu])

_enb1 = RealEnb(
    system_module=_enb1_airscale,
    rms=[_enb1_du_rm1],
    oam_ip=NetworkAddress(v4="10.47.199.70"),
)
# ---------------- STOP eNB-1 ------------------- #


# ---------------- START MTK UE1: Mediatek #41 M80 ------------------- #
_mtk_host_ssh1 = SshServiceDetails(
    addr="10.46.135.27", username="deul5g", password="Nuc2Ue4PzLab!"
)


_app_server_1 = TafUeAppServer(
    app_server_name="DEUL5Gappsrv28",
    address="10.44.35.230",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.44.35.230",
    binary_path="iperf",
    ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254],
)
_mtk_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    interval=1,
    binary_path="/data/local/tmp/iperf",
    version=2,
)


_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, version=2
)


_mtk1 = TafUeMtk(
    ue_pc_address="10.46.135.27",
    ue_pc_port=5432,
    serial_number="0123456789ABCDEF",
    data_transfer=[_mtk_data_transfer_iperf],
    com_port="auto",
    edb_file_path="auto",
    log_filter="2.Gen98_Default_Standard",
    imei="123451234512346",
    imsi="5555107000000136",
    pdns=_pdns,
    default_pdn_name="ulmsa",
    capabilities=["REAL_MEDIATEK_UE", "MTK_UE1"],
)

# ---------------- END MTK UE1: Mediatek #41 M80 --------------------- #


# ---------------- START MTK UE2: Mediatek #22 M70 ------------------- #
_mtk_host_ssh2 = SshServiceDetails(
    addr="10.46.135.27", username="deul5g", password="Nuc2Ue4PzLab!"
)

_mtk2 = TafUeMtk(
    ue_pc_address="10.46.135.27",
    ue_pc_port=5432,
    serial_number="0123456789ABCDEF",
    data_transfer=[_mtk_data_transfer_iperf],
    com_port="auto",
    edb_file_path="auto",
    log_filter="2.Gen98_Default_Standard",
    imei="123451234512346",
    imsi="5540017000001082",
    pdns=_pdns,
    default_pdn_name="ulmsa",
    capabilities=["REAL_MEDIATEK_UE", "MTK_UE1"],
)


# ---------------- END MTK UE2: Mediatek #21 M70 --------------------- #


# ---------------- START QC UE3: Qualcomm #40 SDX65 ------------------------ #
_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.135.29", username="deul5g", password="Nuc2Ue4PzLab!"
)


# ---------------- END QC UE3: Qualcomm #40 SDX65 ------------------------ #


# ---------------- START Core APP Server ------------------- #
_core_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.44.35.230", username="ute", password="ute"
    ),
    network_interface_address="10.44.35.230",
    iperf_path="/usr/bin/iperf",
    port=5432,
)

_core_appserver = AppServer(iperf_details=_core_iperf)
# ---------------- END Core APP Server ------------------- #


# ---------------- START TEST PCs ------------------------ #
_testpc_ssh1 = SshServiceDetails(addr="10.47.198.241", username="ute", password="ute")
_testpc1 = TestPc(default_ssh_connection_details=_testpc_ssh1, connections=[_gnb1])

_testpc_ssh2 = SshServiceDetails(addr="10.47.198.241", username="ute", password="ute")
_testpc2 = TestPc(default_ssh_connection_details=_testpc_ssh2, connections=[_enb1])
# ---------------- END TEST PCs -------------------------- #


# ----------------------------------------- TL ----------------------------------------- #
tl = TestLine(
    test_pc=_testpc1,
    test_pcs=[_testpc1, _testpc2],
    gnbs=[_gnb1],
    enbs=[_enb1],
    core=_tampereCore,
    ues=[_mtk1, _mtk2],
    appserver=_core_appserver,
    attenuators=[_gnb1_rf_att, _enb1_rf_att],
    tl_cloud_topology="CLASSICAL_5G_TYPE",
)

__all__ = ["tl"]
# ----------------------------------------- TL ----------------------------------------- #
