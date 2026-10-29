#######################################
# TestLine TL398_TL399 Ulm (7_15_UTE5GTL398_TL399)#
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
    addr="10.46.134.224",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 9, 10],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_pdu2 = Gude(
    addr="10.46.134.247",
    port_numbers=[1, 2, 3, 4],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_pdu3 = Gude(
    addr="10.46.134.237",
    port_numbers=[8, 9, 11],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_pdu4 = Gude(
    addr="10.46.134.229",
    port_numbers=[1, 2, 3, 4, 8, 9, 10, 11],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_pdu5 = Gude(
    addr="10.46.134.230",
    port_numbers=[3, 4],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_gNB398_rf_att = HBTE(
    ip_addr="10.46.134.154",
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

_gNB399_rf_att = HBTE(
    ip_addr="10.46.134.138",
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

# ---------------- START gNB-398 ------------------- #

_gNB398_cu = CU(
    backhaul_site_oam_ip="10.47.203.211",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.203.211", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.203.211", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.203.212"),
    x2u=NetworkAddress(v4="10.47.203.213"),
    s1u=NetworkAddress(v4="10.47.203.213"),
)

_gNB398_capu1 = CapacityUnit(addr="192.168.253.20")
_gNB398_capu2 = CapacityUnit(addr="192.168.253.20")
_gNB398_capu3 = CapacityUnit(addr="192.168.253.20")

_gNB398_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB398_capu1, _gNB398_capu2, _gNB398_capu3],
    pdu_port=_pdu1.pdu_ports[3],
)

_gNB398_airscale = Airscale(common_units=[_gNB398_common_unit])


_gNB398_rm35 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu4.pdu_ports[10],
    radio_type="AHFII",
    attenuation_ports=[
        _gNB398_rf_att.attenuator_ports[9],
        _gNB398_rf_att.attenuator_ports[10],
        _gNB398_rf_att.attenuator_ports[11],
        _gNB398_rf_att.attenuator_ports[12],
    ],
)

_gNB398_rm33 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu4.pdu_ports[8],
    radio_type="AHFII",
    attenuation_ports=[
        _gNB398_rf_att.attenuator_ports[1],
        _gNB398_rf_att.attenuator_ports[2],
        _gNB398_rf_att.attenuator_ports[3],
        _gNB398_rf_att.attenuator_ports[4],
    ],
)

_gNB398_rm34 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu4.pdu_ports[9],
    radio_type="AHFII",
    attenuation_ports=[
        _gNB398_rf_att.attenuator_ports[5],
        _gNB398_rf_att.attenuator_ports[6],
        _gNB398_rf_att.attenuator_ports[7],
        _gNB398_rf_att.attenuator_ports[8],
    ],
)

_gNB398_rm32 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu3.pdu_ports[8],
    radio_type="AHLOA",
    attenuation_ports=[
        _gNB398_rf_att.attenuator_ports[13],
        _gNB398_rf_att.attenuator_ports[14],
    ],
)

_gNB398_rm45 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu3.pdu_ports[9],
    radio_type="AHCA",
    attenuation_ports=[
        _gNB398_rf_att.attenuator_ports[15],
        _gNB398_rf_att.attenuator_ports[16],
    ],
)

_gNB398_rm17 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu4.pdu_ports[1],
    radio_type="AKQJ",
    attenuation_ports=[
        _gNB398_rf_att.attenuator_ports[17],
        _gNB398_rf_att.attenuator_ports[18],
        _gNB398_rf_att.attenuator_ports[19],
        _gNB398_rf_att.attenuator_ports[20],
    ],
)

_gNB398_rm22 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu4.pdu_ports[2],
    radio_type="AKQJ",
    attenuation_ports=[
        _gNB398_rf_att.attenuator_ports[21],
        _gNB398_rf_att.attenuator_ports[22],
    ],
)

_gNB398_rm21 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu4.pdu_ports[3],
    radio_type="AKQJ",
    attenuation_ports=[
        _gNB398_rf_att.attenuator_ports[25],
        _gNB398_rf_att.attenuator_ports[26],
        _gNB398_rf_att.attenuator_ports[27],
        _gNB398_rf_att.attenuator_ports[28],
    ],
)

_gNB398_rm02 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu5.pdu_ports[3],
    radio_type="AZQW",
    attenuation_ports=[
        _gNB398_rf_att.attenuator_ports[29],
        _gNB398_rf_att.attenuator_ports[30],
        _gNB398_rf_att.attenuator_ports[31],
        _gNB398_rf_att.attenuator_ports[32],
    ],
)

_gNB398_du1 = DU(
    airscale=_gNB398_airscale,
    rus=[
        _gNB398_rm35,
        _gNB398_rm33,
        _gNB398_rm34,
        _gNB398_rm32,
        _gNB398_rm45,
        _gNB398_rm17,
        _gNB398_rm22,
        _gNB398_rm21,
        _gNB398_rm02,
    ],
)

_gNB398 = ClassicalBts(cu=_gNB398_cu, dus=[_gNB398_du1])

# ------------------ END gNB-398 ---------------------- #

# ----------------- START gNB-399 --------------------- #

_gNB399_cu = CU(
    backhaul_site_oam_ip="10.47.203.215",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.203.215", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.203.215", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.203.216"),
    x2u=NetworkAddress(v4="10.47.203.216"),
    s1u=NetworkAddress(v4="10.47.203.217"),
)

_gNB399_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIP")
_gNB399_capu2 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIP")

_gNB399_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB399_capu1, _gNB399_capu2],
    pdu_port=_pdu1.pdu_ports[5],
)

_gNB399_airscale = Airscale(common_units=[_gNB399_common_unit])


_gNB399_du_rm36 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu4.pdu_ports[11],
    radio_type="AHFII",
    attenuation_ports=[
        _gNB399_rf_att.attenuator_ports[1],
        _gNB399_rf_att.attenuator_ports[2],
        _gNB399_rf_att.attenuator_ports[3],
        _gNB399_rf_att.attenuator_ports[4],
    ],
)

_gNB399_du_rm34 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu3.pdu_ports[11],
    radio_type="AHLOA",
    attenuation_ports=[
        _gNB399_rf_att.attenuator_ports[5],
        _gNB399_rf_att.attenuator_ports[6],
    ],
)

_gNB399_du_rm07 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu5.pdu_ports[4],
    radio_type="AZQW",
    attenuation_ports=[
        _gNB399_rf_att.attenuator_ports[11],
        _gNB399_rf_att.attenuator_ports[12],
        _gNB399_rf_att.attenuator_ports[13],
        _gNB399_rf_att.attenuator_ports[14],
    ],
)

_gNB399_du_rm20 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu4.pdu_ports[4],
    radio_type="AKQJ",
    attenuation_ports=[
        _gNB399_rf_att.attenuator_ports[7],
        _gNB399_rf_att.attenuator_ports[8],
        _gNB399_rf_att.attenuator_ports[9],
        _gNB399_rf_att.attenuator_ports[10],
    ],
)

_gNB399_du = DU(
    airscale=_gNB399_airscale,
    rus=[
        _gNB399_du_rm36,
        _gNB399_du_rm34,
        _gNB399_du_rm07,
        _gNB399_du_rm20,
    ],
)

_gNB399 = ClassicalBts(cu=_gNB399_cu, dus=[_gNB399_du])

# ----------------- END gNB-399 -------------------- #

# ----------------- START eNB-1 -------------------- #

_eNB398_capu = CapacityUnit(addr="192.168.253.20", hardware_type="ABIA")

_eNB398_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB398_capu],
    pdu_port=_pdu1.pdu_ports[4],
    hardware_type="ASIA",
)


_eNB398_rm = RU(
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
        _gNB398_rf_att.attenuator_ports[23],
        _gNB398_rf_att.attenuator_ports[24],
    ],
)

_eNB398_airscale = Airscale(common_units=[_eNB398_comu])

_eNB398 = RealEnb(
    system_module=_eNB398_airscale,
    rms=[
        _gNB398_rm35,
        _gNB398_rm33,
        _gNB398_rm34,
        _gNB398_rm32,
        _gNB398_rm45,
        _eNB398_rm,
    ],
    oam_ip=NetworkAddress(v4="10.47.203.210"),
)
# ------------------ END eNB-398 --------------------- #

# ----------------- START eNB-399 -------------------- #

_eNB399_capu = CapacityUnit(addr="192.168.253.20", hardware_type="ABIA")

_eNB399_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB399_capu],
    pdu_port=_pdu1.pdu_ports[6],
    hardware_type="ASIA",
)


_eNB399_rm = RU(
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
        _gNB399_rf_att.attenuator_ports[15],
        _gNB399_rf_att.attenuator_ports[16],
    ],
)

_eNB399_airscale = Airscale(common_units=[_eNB399_comu])

_eNB399 = RealEnb(
    system_module=_eNB399_airscale,
    rms=[
        _gNB399_du_rm36,
        _gNB399_du_rm34,
        _eNB399_rm,
    ],
    oam_ip=NetworkAddress(v4="10.47.203.214"),
)
# ----------------- END eNB-399 -------------------- #

# ---------------- START Core APP Server ----------------- #

_app_server_1 = TafUeAppServer(
    app_server_name="DEUL5Gappsrv14",
    address="10.47.194.214",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.214",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, version=2
)


# ---------------- END Core APP Server ------------------- #

# ---------------- START QC UE1: Qualcomm #61 SDX75 ---------------------- #
_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.135.55", username="deul5g", password="Nuc2Ue4PzLab!"
)

_android1 = TafUeAndroid(
    serial_number="9d8bcbc",
    ue_pc_address="10.46.135.55",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE", "UE1", "X75"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.46.135.55", username="deul5g", password="Nuc2Ue4PzLab!"
    ),
    ue_pc_port="8080",
)
# ---------------- END QC UE1: Qualcomm #61 SDX70 ------------------------ #

# ---------------- START MTK UE2: MTK #56 M80 Dujac ---------------------- #
_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.135.56", username="deul5g", password="Nuc2Ue4PzLab!"
)

_mtk1 = TafUeAndroid(
    serial_number="0123456789ABCDEF",
    ue_pc_address="10.46.135.56",
    capabilities=["REAL_UE", "REAL_MTK", "UE2", "MTK"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.46.135.56", username="deul5g", password="Nuc2Ue4PzLab!"
    ),
    ue_pc_port="1234",
)
# ---------------- END QC UE2: MTK #56 M80 Dujac ------------------------ #

# ---------------- START QC UE3: Qualcomm #59 SDX70 ---------------------- #
_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.135.21", username="deul5g", password="Nuc2Ue4PzLab!"
)

_android2 = TafUeAndroid(
    serial_number="a14b8ea4",
    ue_pc_address="10.46.135.21",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE", "UE3", "X70"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.46.135.21", username="deul5g", password="Nuc2Ue4PzLab!"
    ),
    ue_pc_port="8080",
)
# ---------------- END QC UE3: Qualcomm #59 SDX70 ------------------------ #

# ---------------- START QC UE4: Qualcomm #48 SDX65 ---------------------- #
_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.135.23", username="deul5g", password="Nuc2Ue4PzLab!"
)

_android3 = TafUeAndroid(
    serial_number="ce472e06",
    ue_pc_address="10.46.135.23",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE", "UE4", "X65"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.46.135.23", username="deul5g", password="Nuc2Ue4PzLab!"
    ),
    ue_pc_port="8080",
)
# ---------------- END QC UE4: Qualcomm #48 SDX65 ------------------------ #


# ---------------- START TEST PCs ------------------------ #

_testpc1_ssh = SshServiceDetails(
    addr="10.47.203.245", username="ute", password="UTE.debian12"
)
_testpc1 = TestPc(default_ssh_connection_details=_testpc1_ssh, connections=[_gNB398])

_testpc2_ssh = SshServiceDetails(
    addr="10.47.203.246", username="ute", password="UTE.debian12"
)
_testpc2 = TestPc(default_ssh_connection_details=_testpc2_ssh, connections=[_eNB398])

_testpc3_ssh = SshServiceDetails(
    addr="10.47.203.247", username="ute", password="UTE.debian12"
)
_testpc3 = TestPc(default_ssh_connection_details=_testpc3_ssh, connections=[_gNB399])

_testpc4_ssh = SshServiceDetails(
    addr="10.47.203.248", username="ute", password="UTE.debian12"
)
_testpc4 = TestPc(default_ssh_connection_details=_testpc4_ssh, connections=[_eNB399])


# ---------------- END TEST PCs -------------------------- #
_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.47.194.214", username="ute", password="UTE.debian12"
    ),
    network_interface_address="10.47.194.214",
    iperf_path="iperf",
    ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254],
)

_appserver = AppServer(_iperf_details_on_appserver)


# ----------------------------------------- TL ----------------------------------------- #

tl = TestLine(
    test_pc=_testpc1,
    test_pcs=[_testpc1, _testpc2, _testpc3, _testpc4],
    gnbs=[_gNB398, _gNB399],
    enbs=[_eNB398, _eNB399],
    core=_tampereCore,
    ues=[_android1, _mtk1, _android2, _android3],
    appserver=_appserver,
    attenuators=[_gNB398_rf_att, _gNB399_rf_att],
    tl_cloud_topology="CLASSICAL_5G_TYPE",
)

__all__ = ["tl"]

# ----------------------------------------- TL ----------------------------------------- #
