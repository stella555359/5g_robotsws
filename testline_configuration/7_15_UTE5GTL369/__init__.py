#######################################
# TestLine TL369_TL370 Ulm (7_15_UTE5GTL369)#
#######################################
__maintainer__ = "MN RAN Pz ULM"
__team__ = "MN RAN Pz ULM"
__email__ = "ran-pz-ulm-ta@list.nokia.com"

import os

from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.appserver import AppServer
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import RealEnb
from taf.config.testline.core import RealCore
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.attenuator import HBTE
from taf.config.testline.pdn import PDN, PDPTypes
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid


cfg_dir = os.path.dirname(os.path.abspath(__file__))


_pdns = [
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsa"),
]

_tampereCore = RealCore(mcc="540", mnc="01", pdns=_pdns)


_snmp_user_data = dict(
    userName="user",
    authKey="qwer2009!",
    privKey="qwer2009!",
    authProtocol="SHA",
    privProtocol="AES",
)

# ------------------ pdus ------------------------- #

_pdu1 = Gude(
    addr="10.46.134.223",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 9, 10],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_pdu2 = Gude(
    addr="10.46.134.22",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_pdu3 = Gude(
    addr="10.46.134.207",
    port_numbers=[1],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_gNB369_rf_att = HBTE(
    ip_addr="10.46.134.153",
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

_gNB370_rf_att = HBTE(
    ip_addr="10.46.134.197",
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
    ],
    version=None,
    model="PA-16-16-6-127-0.5-B-S",
)

# ---------------- START gNB-369 ------------------- #

_gNB369_cu = CU(
    backhaul_site_oam_ip="10.47.203.141",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.203.141", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.203.141", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.203.142"),
    x2u=NetworkAddress(v4="10.47.203.143"),
    s1u=NetworkAddress(v4="10.47.203.143"),
)

_gNB369_capu1 = CapacityUnit(addr="192.168.253.20")
_gNB369_capu2 = CapacityUnit(addr="192.168.253.20")
_gNB369_capu3 = CapacityUnit(addr="192.168.253.20")

_gNB369_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB369_capu1, _gNB369_capu2, _gNB369_capu3],
    pdu_port=_pdu1.pdu_ports[3],
)

_gNB369_airscale = Airscale(common_units=[_gNB369_common_unit])


_gNB369_rm30 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu2.pdu_ports[2],
    radio_type="AHFII",
    attenuation_ports=[
        _gNB369_rf_att.attenuator_ports[1],
        _gNB369_rf_att.attenuator_ports[2],
        _gNB369_rf_att.attenuator_ports[3],
        _gNB369_rf_att.attenuator_ports[4],
    ],
)

_gNB369_rm32 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu2.pdu_ports[5],
    radio_type="AHFII",
    attenuation_ports=[
        _gNB369_rf_att.attenuator_ports[5],
        _gNB369_rf_att.attenuator_ports[6],
        _gNB369_rf_att.attenuator_ports[7],
        _gNB369_rf_att.attenuator_ports[8],
    ],
)

_gNB369_rm31 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu2.pdu_ports[8],
    radio_type="AHFII",
    attenuation_ports=[
        _gNB369_rf_att.attenuator_ports[9],
        _gNB369_rf_att.attenuator_ports[10],
        _gNB369_rf_att.attenuator_ports[11],
        _gNB369_rf_att.attenuator_ports[12],
    ],
)

_gNB369_rm31_2 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu2.pdu_ports[9],
    radio_type="AHLOA",
    attenuation_ports=[
        _gNB369_rf_att.attenuator_ports[13],
        _gNB369_rf_att.attenuator_ports[14],
    ],
)

_gNB369_rm22 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu3.pdu_ports[1],
    radio_type="AHCA",
    attenuation_ports=[
        _gNB369_rf_att.attenuator_ports[15],
        _gNB369_rf_att.attenuator_ports[16],
    ],
)

_gNB369_rm09 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu2.pdu_ports[1],
    radio_type="AKQJ",
    attenuation_ports=[
        _gNB369_rf_att.attenuator_ports[17],
        _gNB369_rf_att.attenuator_ports[18],
        _gNB369_rf_att.attenuator_ports[18],
        _gNB369_rf_att.attenuator_ports[18],
        _gNB369_rf_att.attenuator_ports[19],
        _gNB369_rf_att.attenuator_ports[20],
    ],
)

_gNB369_rm14 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu2.pdu_ports[4],
    radio_type="AKQJ",
    attenuation_ports=[
        _gNB369_rf_att.attenuator_ports[21],
        _gNB369_rf_att.attenuator_ports[21],
        _gNB369_rf_att.attenuator_ports[21],
        _gNB369_rf_att.attenuator_ports[21],
        _gNB369_rf_att.attenuator_ports[22],
    ],
)

_gNB369_rm10 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu2.pdu_ports[7],
    radio_type="AKQJ",
    attenuation_ports=[
        _gNB369_rf_att.attenuator_ports[25],
        _gNB369_rf_att.attenuator_ports[26],
        _gNB369_rf_att.attenuator_ports[26],
        _gNB369_rf_att.attenuator_ports[26],
        _gNB369_rf_att.attenuator_ports[27],
        _gNB369_rf_att.attenuator_ports[28],
    ],
)

_gNB369_rm19 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu2.pdu_ports[3],
    radio_type="AZQW",
    attenuation_ports=[
        _gNB369_rf_att.attenuator_ports[29],
        _gNB369_rf_att.attenuator_ports[30],
        _gNB369_rf_att.attenuator_ports[30],
        _gNB369_rf_att.attenuator_ports[30],
        _gNB369_rf_att.attenuator_ports[31],
        _gNB369_rf_att.attenuator_ports[32],
    ],
)

_gNB369_du1 = DU(
    airscale=_gNB369_airscale,
    rus=[
        _gNB369_rm30,
        _gNB369_rm32,
        _gNB369_rm31,
        _gNB369_rm31_2,
        _gNB369_rm22,
        _gNB369_rm09,
        _gNB369_rm14,
        _gNB369_rm10,
        _gNB369_rm19,
    ],
)

_gNB369 = ClassicalBts(cu=_gNB369_cu, dus=[_gNB369_du1])

# ------------------ END gNB-369 ---------------------- #

# ----------------- START gNB-370 --------------------- #

_gNB370_cu = CU(
    backhaul_site_oam_ip="10.47.203.146",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.203.146", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.203.146", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.203.147"),
    x2u=NetworkAddress(v4="10.47.203.147"),
    s1u=NetworkAddress(v4="10.47.203.148"),
)

_gNB370_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIO")
_gNB370_capu2 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIO")

_gNB370_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB370_capu1, _gNB370_capu2],
    pdu_port=_pdu1.pdu_ports[5],
)

_gNB370_airscale = Airscale(common_units=[_gNB370_common_unit])


_gNB370_du_rm22 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu2.pdu_ports[11],
    radio_type="AHFII",
    attenuation_ports=[
        _gNB370_rf_att.attenuator_ports[1],
        _gNB370_rf_att.attenuator_ports[2],
        _gNB370_rf_att.attenuator_ports[3],
        _gNB370_rf_att.attenuator_ports[4],
    ],
)

_gNB370_du_rm29 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu2.pdu_ports[12],
    radio_type="AHLOA",
    attenuation_ports=[
        _gNB370_rf_att.attenuator_ports[5],
        _gNB370_rf_att.attenuator_ports[6],
    ],
)

_gNB370_du_rm11 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu2.pdu_ports[10],
    radio_type="AKQJ",
    attenuation_ports=[
        _gNB370_rf_att.attenuator_ports[11],
        _gNB370_rf_att.attenuator_ports[12],
        _gNB370_rf_att.attenuator_ports[13],
        _gNB370_rf_att.attenuator_ports[14],
    ],
)

_gNB370_du_rm04 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu2.pdu_ports[6],
    radio_type="AZQW",
    attenuation_ports=[
        _gNB370_rf_att.attenuator_ports[7],
        _gNB370_rf_att.attenuator_ports[8],
        _gNB370_rf_att.attenuator_ports[9],
        _gNB370_rf_att.attenuator_ports[10],
    ],
)

_gNB370_du = DU(
    airscale=_gNB370_airscale,
    rus=[
        _gNB370_du_rm22,
        _gNB370_du_rm29,
        _gNB370_du_rm11,
        _gNB370_du_rm04,
    ],
)

_gNB370 = ClassicalBts(cu=_gNB370_cu, dus=[_gNB370_du])

# ----------------- END gNB-370 -------------------- #

# ----------------- START eNB-1 -------------------- #

_eNB369_capu = CapacityUnit(addr="192.168.253.20", hardware_type="ABIA")

_eNB369_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB369_capu],
    pdu_port=_pdu1.pdu_ports[4],
    hardware_type="ASIA",
)


_eNB369_rm = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1.pdu_ports[1],
    radio_type="FRHC",
    attenuation_ports=[
        _gNB369_rf_att.attenuator_ports[23],
        _gNB369_rf_att.attenuator_ports[24],
    ],
)

_eNB369_airscale = Airscale(common_units=[_eNB369_comu])

_eNB369 = RealEnb(
    system_module=_eNB369_airscale,
    rms=[
        _gNB369_rm30,
        _gNB369_rm32,
        _gNB369_rm31,
        _gNB369_rm31_2,
        _gNB369_rm22,
        _eNB369_rm,
    ],
    oam_ip=NetworkAddress(v4="10.47.203.140"),
)
# ------------------ END eNB-369 --------------------- #

# ----------------- START eNB-370 -------------------- #

_eNB370_capu = CapacityUnit(addr="192.168.253.20", hardware_type="ABIA")

_eNB370_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB370_capu],
    pdu_port=_pdu1.pdu_ports[6],
    hardware_type="ASIA",
)


_eNB370_rm = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1.pdu_ports[2],
    radio_type="FRHC",
    attenuation_ports=[
        _gNB370_rf_att.attenuator_ports[15],
        _gNB370_rf_att.attenuator_ports[16],
    ],
)

_eNB370_airscale = Airscale(common_units=[_eNB370_comu])

_eNB370 = RealEnb(
    system_module=_eNB370_airscale,
    rms=[
        _gNB370_du_rm22,
        _gNB370_du_rm29,
        _eNB370_rm,
    ],
    oam_ip=NetworkAddress(v4="10.47.203.145"),
)
# ----------------- END eNB-370 -------------------- #

# ---------------- START Core APP Server ----------------- #

_app_server_1 = TafUeAppServer(
    app_server_name="DEUL-appsrv14",
    address="10.47.194.230",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.230",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, version=2
)


# ---------------- END Core APP Server ------------------- #

# ---------------- START QC UE1: Qualcomm #61 SDX80 ---------------------- #
_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.135.22", username="deul5g", password="Nuc2Ue4PzLab!"
)

_android1 = TafUeAndroid(
    serial_number="9d8bcbc",
    ue_pc_address="10.46.135.22",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE", "UE1", "UE_1", "SDX80"],
    pdu_port=_pdu1.pdu_ports[7],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.46.135.22", username="deul5g", password="Nuc2Ue4PzLab!"
    ),
    ue_pc_port="8080",
)
# ---------------- END QC UE1: Qualcomm #61 SDX80 ------------------------ #

# ---------------- START MTK UE2: MTK #56 M80 D ---------------------- #
_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.135.57", username="deul5g", password="Nuc2Ue4PzLab!"
)

_mtk1 = TafUeAndroid(
    serial_number="0123456789ABCDEF",
    ue_pc_address="10.46.135.57",
    capabilities=["REAL_UE", "REAL_MTK", "UE2", "MTK"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.46.135.57", username="deul5g", password="Nuc2Ue4PzLab!"
    ),
    ue_pc_port="1234",
)
# ---------------- END QC UE2: MTK #56 M80 D ------------------------ #

# ---------------- START QC UE3: Qualcomm #59 SDX70 ---------------------- #
_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.135.108", username="deul5g", password="Nuc2Ue4PzLab!"
)

_android2 = TafUeAndroid(
    serial_number="needs_to_be_added",
    ue_pc_address="10.46.135.108",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE", "UE3", "X70"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.46.135.108", username="deul5g", password="Nuc2Ue4PzLab!"
    ),
    ue_pc_port="8080",
)
# ---------------- END QC UE3: Qualcomm #59 SDX70 ------------------------ #

# ---------------- START QC UE4: Qualcomm #48 SDX65 ---------------------- #
_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.135.115", username="deul5g", password="Nuc2Ue4PzLab!"
)

_android3 = TafUeAndroid(
    serial_number="b25ba8e8",
    ue_pc_address="10.46.135.115",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE", "UE4", "X65"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.46.135.115", username="deul5g", password="Nuc2Ue4PzLab!"
    ),
    ue_pc_port="8080",
)
# ---------------- END QC UE4: Qualcomm #48 SDX65 ------------------------ #


# ---------------- START TEST PCs ------------------------ #

_testpc1_ssh = SshServiceDetails(
    addr="10.47.203.181", username="ute", password="UTE.debian12"
)
_testpc1 = TestPc(default_ssh_connection_details=_testpc1_ssh, connections=[_gNB369])

_testpc2_ssh = SshServiceDetails(addr="10.47.203.182", username="ute", password="ute")
_testpc2 = TestPc(default_ssh_connection_details=_testpc2_ssh, connections=[_eNB369])

_testpc3_ssh = SshServiceDetails(
    addr="10.47.203.183", username="ute", password="UTE.debian12"
)
_testpc3 = TestPc(default_ssh_connection_details=_testpc3_ssh, connections=[_gNB370])

_testpc4_ssh = SshServiceDetails(addr="10.47.203.184", username="ute", password="ute")
_testpc4 = TestPc(default_ssh_connection_details=_testpc4_ssh, connections=[_eNB370])


# ---------------- END TEST PCs -------------------------- #
_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.47.194.230", username="ute", password="ute"
    ),
    network_interface_address="10.47.194.230",
    iperf_path="iperf",
    ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254],
)

_appserver = AppServer(_iperf_details_on_appserver)


# ----------------------------------------- TL ----------------------------------------- #

tl = TestLine(
    test_pc=_testpc1,
    test_pcs=[_testpc1, _testpc2, _testpc3, _testpc4],
    gnbs=[_gNB369, _gNB370],
    enbs=[_eNB369, _eNB370],
    core=_tampereCore,
    ues=[_android1, _mtk1, _android2, _android3],
    appserver=_appserver,
    attenuators=[_gNB369_rf_att, _gNB370_rf_att],
    tl_cloud_topology="CLASSICAL_5G_TYPE",
)

__all__ = ["tl"]

# ----------------------------------------- TL ----------------------------------------- #
