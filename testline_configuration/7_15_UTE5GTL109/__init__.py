#######################################
# TestLine TL109 Ulm (7_15_UTE5GTL109)#
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
from taf.config.testline import RoutingInformation
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

_tampereCore = RealCore(mcc="555", mnc="10", pdns=_pdns)


_snmp_user_data = dict(
    userName="user",
    authKey="qwer2009!",
    privKey="qwer2009!",
    authProtocol="SHA",
    privProtocol="AES",
)

# ------------------ pdus ------------------------- #

_pdu1 = Gude(
    addr="10.46.133.45",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_pdu2 = Gude(
    addr="10.46.133.37",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_pdu3 = Gude(
    addr="10.46.133.17",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)


# ---------------- START gNB-109 ------------------- #
_gNB109_rf_att = HBTE(
    ip_addr="10.46.133.85",
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

_gNB109_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.198.207",
        routing_v4=RoutingInformation(
            gateway="10.47.198.222", destIpAddr="10.47.198.192/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.198.207", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.198.207", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.198.208"),
    x2u=NetworkAddress(v4="10.47.198.209"),
    s1u=NetworkAddress(v4="10.47.198.209"),
)

_gNB109_capu1 = CapacityUnit(addr="192.168.253.20")

_gNB109_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB109_capu1],
    pdu_port=_pdu1.pdu_ports[3],
)

_gNB109_airscale = Airscale(common_units=[_gNB109_common_unit])


_gNB109_rm01 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu2.pdu_ports[11],
    radio_type="AHFIB",
    attenuation_ports=[
        _gNB109_rf_att.attenuator_ports[1],
        _gNB109_rf_att.attenuator_ports[2],
        _gNB109_rf_att.attenuator_ports[3],
        _gNB109_rf_att.attenuator_ports[4],
    ],
)

_gNB109_rm02 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu2.pdu_ports[10],
    radio_type="AHFIB",
    attenuation_ports=[
        _gNB109_rf_att.attenuator_ports[5],
        _gNB109_rf_att.attenuator_ports[6],
        _gNB109_rf_att.attenuator_ports[7],
        _gNB109_rf_att.attenuator_ports[8],
    ],
)

_gNB109_rm03 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1.pdu_ports[12],
    radio_type="AHCA",
    attenuation_ports=[
        _gNB109_rf_att.attenuator_ports[9],
        _gNB109_rf_att.attenuator_ports[10],
    ],
)

_gNB109_rm04 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu2.pdu_ports[3],
    radio_type="AZQG",
    attenuation_ports=[
        _gNB109_rf_att.attenuator_ports[11],
        _gNB109_rf_att.attenuator_ports[12],
        _gNB109_rf_att.attenuator_ports[13],
        _gNB109_rf_att.attenuator_ports[14],
    ],
)

_gNB109_rm05 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu2.pdu_ports[8],
    radio_type="AZQW",
    attenuation_ports=[
        _gNB109_rf_att.attenuator_ports[15],
        _gNB109_rf_att.attenuator_ports[16],
        _gNB109_rf_att.attenuator_ports[17],
        _gNB109_rf_att.attenuator_ports[18],
    ],
)

_gNB109_rm06 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu2.pdu_ports[4],
    radio_type="AZQW",
    attenuation_ports=[
        _gNB109_rf_att.attenuator_ports[19],
        _gNB109_rf_att.attenuator_ports[20],
        _gNB109_rf_att.attenuator_ports[21],
        _gNB109_rf_att.attenuator_ports[22],
    ],
)

_gNB109_du1 = DU(
    airscale=_gNB109_airscale,
    rus=[
        _gNB109_rm01,
        _gNB109_rm02,
        _gNB109_rm03,
        _gNB109_rm04,
        _gNB109_rm05,
        _gNB109_rm06,
    ],
)

_gNB109 = ClassicalBts(cu=_gNB109_cu, dus=[_gNB109_du1])

# ------------------ END gNB-109 ---------------------- #

# ----------------- START gNB-110 --------------------- #
_gNB110_rf_att = HBTE(
    ip_addr="10.46.133.90",
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

_gNB110_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.198.214",
        routing_v4=RoutingInformation(
            gateway="10.47.198.222", destIpAddr="10.47.198.192/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.198.214", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.198.214", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.198.215"),
    x2u=NetworkAddress(v4="10.47.198.216"),
    s1u=NetworkAddress(v4="10.47.198.216"),
)

_gNB110_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIO")

_gNB110_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB110_capu1],
    pdu_port=_pdu1.pdu_ports[5],
)

_gNB110_airscale = Airscale(common_units=[_gNB110_common_unit])


_gNB110_du_rm65 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu2.pdu_ports[9],
    radio_type="AHFIB",
    attenuation_ports=[
        _gNB110_rf_att.attenuator_ports[1],
        _gNB110_rf_att.attenuator_ports[2],
        _gNB110_rf_att.attenuator_ports[3],
        _gNB110_rf_att.attenuator_ports[4],
    ],
)

_gNB110_du_rm19 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu3.pdu_ports[3],
    radio_type="AZQG",
    attenuation_ports=[
        _gNB110_rf_att.attenuator_ports[5],
        _gNB110_rf_att.attenuator_ports[6],
        _gNB110_rf_att.attenuator_ports[7],
        _gNB110_rf_att.attenuator_ports[8],
    ],
)

_gNB110_du_rm00 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu3.pdu_ports[4],
    radio_type="AZQW",
    attenuation_ports=[
        _gNB110_rf_att.attenuator_ports[9],
        _gNB110_rf_att.attenuator_ports[10],
        _gNB110_rf_att.attenuator_ports[11],
        _gNB110_rf_att.attenuator_ports[12],
    ],
)

_gNB110_du = DU(
    airscale=_gNB110_airscale, rus=[_gNB110_du_rm65, _gNB110_du_rm19, _gNB110_du_rm00]
)

_gNB110 = ClassicalBts(cu=_gNB110_cu, dus=[_gNB110_du])

# ----------------- END gNB-110 -------------------- #

# ----------------- START eNB-1 -------------------- #

_eNB109_capu = CapacityUnit(addr="192.168.253.20", hardware_type="ABIA")

_eNB109_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB109_capu],
    pdu_port=_pdu1.pdu_ports[4],
    hardware_type="ASIA",
)


_eNB109_rm = RU(
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
        _gNB109_rf_att.attenuator_ports[23],
        _gNB109_rf_att.attenuator_ports[24],
    ],
)

_eNB109_airscale = Airscale(common_units=[_eNB109_comu])

_eNB109 = RealEnb(
    system_module=_eNB109_airscale,
    rms=[_eNB109_rm],
    oam_ip=NetworkAddress(v4="10.47.198.206"),
)
# ------------------ END eNB-109 --------------------- #

# ----------------- START eNB-110 -------------------- #

_eNB110_capu = CapacityUnit(addr="192.168.253.20", hardware_type="ABIA")

_eNB110_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB110_capu],
    pdu_port=_pdu1.pdu_ports[6],
    hardware_type="ASIA",
)


_eNB110_rm = RU(
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
        _gNB110_rf_att.attenuator_ports[13],
        _gNB110_rf_att.attenuator_ports[14],
    ],
)

_eNB110_airscale = Airscale(common_units=[_eNB110_comu])

_eNB110 = RealEnb(
    system_module=_eNB110_airscale,
    rms=[_eNB110_rm, _gNB110_du_rm65],
    oam_ip=NetworkAddress(v4="10.47.198.213"),
)
# ----------------- END eNB-110 -------------------- #
# ---------------- START Core APP Server ----------------- #

_app_server_1 = TafUeAppServer(
    app_server_name="DEUL-appsrv27",
    address="10.44.35.227",
    user="ute",
    password="ute",
    bind_interface_ip="10.44.35.227",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, version=2
)


# ---------------- END Core APP Server ------------------- #

# ---------------- START QC UE2: Qualcomm #54 SDX70 ---------------------- #
_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.135.117", username="deul5g", password="Nuc2Ue4PzLab!"
)

_android1 = TafUeAndroid(
    serial_number="62a1fb3a",
    ue_pc_address="10.46.135.117",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.46.135.117", username="deul5g", password="Nuc2Ue4PzLab!"
    ),
    ue_pc_port="8080",
)
# ---------------- END QC UE2: Qualcomm #54 SDX70 ------------------------ #

# ---------------- START MTK UE1: MTK #52 M80 Figeac ---------------------- #
_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.135.116", username="deul5g", password="Nuc2Ue4PzLab!"
)

_mtk1 = TafUeAndroid(
    serial_number="0123456789ABCDEF",
    ue_pc_address="10.46.135.116",
    capabilities=["REAL_UE", "REAL_MTK"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.46.135.116", username="deul5g", password="Nuc2Ue4PzLab!"
    ),
    ue_pc_port="1234",
)
# ---------------- END MTK UE1: MTK #52 M80 Figeac ---------------------- #


# ---------------- START TEST PCs ------------------------ #

_testpc1_ssh = SshServiceDetails(
    addr="10.47.198.243", username="ute", password="UTE.debian12"
)
_testpc1 = TestPc(default_ssh_connection_details=_testpc1_ssh, connections=[_gNB109])

_testpc2_ssh = SshServiceDetails(
    addr="10.47.198.247", username="ute", password="UTE.debian12"
)
_testpc2 = TestPc(default_ssh_connection_details=_testpc2_ssh, connections=[_eNB109])

_testpc3_ssh = SshServiceDetails(
    addr="10.47.198.244", username="ute", password="UTE.debian12"
)
_testpc3 = TestPc(default_ssh_connection_details=_testpc3_ssh, connections=[_gNB110])

_testpc4_ssh = SshServiceDetails(
    addr="10.47.198.248", username="ute", password="UTE.debian12"
)
_testpc4 = TestPc(default_ssh_connection_details=_testpc4_ssh, connections=[_eNB110])


# ---------------- END TEST PCs -------------------------- #
_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.44.35.227", username="ute", password="ute"
    ),
    network_interface_address="10.44.35.227",
    iperf_path="iperf",
    ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254],
)

_appserver = AppServer(_iperf_details_on_appserver)


# ----------------------------------------- TL ----------------------------------------- #

tl = TestLine(
    test_pc=_testpc1,
    test_pcs=[_testpc1, _testpc2, _testpc3, _testpc4],
    gnbs=[_gNB109, _gNB110],
    enbs=[_eNB109, _eNB110],
    core=_tampereCore,
    ues=[_android1, _mtk1],
    appserver=_appserver,
    attenuators=[_gNB109_rf_att, _gNB110_rf_att],
    tl_cloud_topology="CLASSICAL_5G_TYPE",
)

__all__ = ["tl"]
# ----------------------------------------- TL ----------------------------------------- #
