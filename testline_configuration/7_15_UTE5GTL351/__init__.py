######################################
#  TestLine 351 Ulm                  #
######################################
__maintainer__ = "MN RAN Pz ULM 2 SqdGp63"
__team__ = "MN RAN Pz ULM 2 SqdGp63"
__email__ = "i_pz_ulm_sqd_63@internal.nsn.com"

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
from taf.config.testline.ue import Android
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.attenuator import HBTE
from taf.config.testline.pdn import PDN, PDPTypes
from taf.config.testline.core import RealCore
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeMtk
from taf.config.testline.ue import TafUeAndroid


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
_tampereCore = RealCore(mcc="540", mnc="01", pdns=_pdns)

_comu_pdu = Gude(
    addr="10.46.134.226",
    port_numbers=[1, 3, 4, 5, 7, 9, 10],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)


_gNB351_rf_pdu1 = Gude(
    addr="10.46.134.239",
    port_numbers=[1, 4, 7],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)
_gNB351_rf_pdu2 = Gude(
    addr="10.46.134.206",
    port_numbers=[1, 2, 3, 4, 6, 9, 12],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)
_gNB351_rf_pdu3 = Gude(
    addr="10.46.134.217",
    port_numbers=[2],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_rf_att = HBTE(
    ip_addr="10.46.134.156",
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

_rf_att_1 = HBTE(
    ip_addr="10.46.134.158",
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
    ],
    version=None,
    model="PA-16-16-6-127-0.5-B-S",
)

# ---------------- START gnb-1 ------------------------ gnb_351-1

_gNB351_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.203.201",
        routing_v4=RoutingInformation(
            gateway="10.47.203.222", destIpAddr="10.47.203.192/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.203.201", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.203.201", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.203.202"),
    x2u=NetworkAddress(v4="10.47.203.203"),
    s1u=NetworkAddress(v4="10.47.203.203"),
)

_gNB351_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIO")
_gNB351_capu2 = CapacityUnit(addr="192.168.253.24", hardware_type="ABIO")
_gNB351_capu3 = CapacityUnit(addr="192.168.253.28", hardware_type="ABIO")

_gNB351_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB351_capu1, _gNB351_capu2, _gNB351_capu3],
    pdu_port=_comu_pdu.pdu_ports[5],
    hardware_type="ASIB",
)

_gNB351_airscale = Airscale(common_units=[_gNB351_comu])


_gNB351_AHLOA_51 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB351_rf_pdu2.pdu_ports[3],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att.attenuator_ports[1],
        _rf_att.attenuator_ports[2],
    ],
)

_gNB351_AHLOA_01 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB351_rf_pdu2.pdu_ports[6],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att.attenuator_ports[3],
        _rf_att.attenuator_ports[4],
    ],
)

_gNB351_AHLOA_06 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB351_rf_pdu2.pdu_ports[9],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att.attenuator_ports[5],
        _rf_att.attenuator_ports[6],
    ],
)

_gNB351_AHFIB_19 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB351_rf_pdu1.pdu_ports[1],
    radio_type="AHFIB",
    attenuation_ports=[
        _rf_att.attenuator_ports[9],
        _rf_att.attenuator_ports[10],
        _rf_att.attenuator_ports[11],
        _rf_att.attenuator_ports[12],
    ],
)
_gNB351_AHFIB_53 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB351_rf_pdu1.pdu_ports[7],
    radio_type="AHFIB",
    attenuation_ports=[
        _rf_att.attenuator_ports[13],
        _rf_att.attenuator_ports[14],
        _rf_att.attenuator_ports[15],
        _rf_att.attenuator_ports[16],
    ],
)
_gNB351_AHFIB_11 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB351_rf_pdu1.pdu_ports[4],
    radio_type="AHFIB",
    attenuation_ports=[
        _rf_att.attenuator_ports[17],
        _rf_att.attenuator_ports[18],
        _rf_att.attenuator_ports[19],
        _rf_att.attenuator_ports[20],
    ],
)

_gNB351_AKQJ_25 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB351_rf_pdu2.pdu_ports[1],
    radio_type="AKQJ",
    attenuation_ports=[
        _rf_att.attenuator_ports[21],
        _rf_att.attenuator_ports[22],
        _rf_att.attenuator_ports[21],
        _rf_att.attenuator_ports[22],
        _rf_att.attenuator_ports[23],
        _rf_att.attenuator_ports[24],
    ],
)

_gNB351_AKQJ_27 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB351_rf_pdu2.pdu_ports[2],
    radio_type="AKQJ",
    attenuation_ports=[
        _rf_att.attenuator_ports[25],
        _rf_att.attenuator_ports[26],
        _rf_att.attenuator_ports[25],
        _rf_att.attenuator_ports[26],
        _rf_att.attenuator_ports[27],
        _rf_att.attenuator_ports[28],
    ],
)

_gNB351_du = DU(
    airscale=_gNB351_airscale,
    rus=[
        _gNB351_AHLOA_51,
        _gNB351_AHLOA_01,
        _gNB351_AHLOA_06,
        _gNB351_AHFIB_19,
        _gNB351_AHFIB_53,
        _gNB351_AHFIB_11,
        _gNB351_AKQJ_25,
        _gNB351_AKQJ_27,
    ],
)

_gNB351 = ClassicalBts(cu=_gNB351_cu, dus=[_gNB351_du])
# ---------------- END gnb-1 ------------------------

# ---------------- START gnb-2 ------------------------ gnb_352-1

_gNB352_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.203.205",
        routing_v4=RoutingInformation(
            gateway="10.47.203.222", destIpAddr="10.47.203.192/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.203.205", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.203.205", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.203.206"),
    x2u=NetworkAddress(v4="10.47.203.207"),
    s1u=NetworkAddress(v4="10.47.203.207"),
)

_gNB352_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIN")

_gNB352_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB352_capu1],
    pdu_port=_comu_pdu.pdu_ports[3],
    hardware_type="ASIL",
)

_gNB352_airscale = Airscale(common_units=[_gNB352_comu])

_gNB351_AHLOA_05 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB351_rf_pdu2.pdu_ports[12],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att_1.attenuator_ports[1],
        _rf_att_1.attenuator_ports[2],
    ],
)

_gNB351_AHFIB_22 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB351_rf_pdu3.pdu_ports[2],
    radio_type="AHFIB",
    attenuation_ports=[
        _rf_att_1.attenuator_ports[3],
        _rf_att_1.attenuator_ports[4],
        _rf_att_1.attenuator_ports[5],
        _rf_att_1.attenuator_ports[6],
    ],
)

_gNB351_AKQJ_28 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB351_rf_pdu2.pdu_ports[4],
    radio_type="AKQJ",
    attenuation_ports=[
        _rf_att_1.attenuator_ports[7],
        _rf_att_1.attenuator_ports[8],
        _rf_att_1.attenuator_ports[7],
        _rf_att_1.attenuator_ports[8],
        _rf_att_1.attenuator_ports[9],
        _rf_att_1.attenuator_ports[10],
    ],
)

_gNB352_du = DU(
    airscale=_gNB352_airscale,
    rus=[
        _gNB351_AHLOA_05,
        _gNB351_AHFIB_22,
        _gNB351_AKQJ_28,
    ],
)

_gNB352 = ClassicalBts(cu=_gNB352_cu, dus=[_gNB352_du])
# ---------------- END gnb-2 ------------------------


# ---------------- START eNB-1 ------------------------ eNB_351

_eNB351_capu = CapacityUnit(addr="192.168.253.20")

_eNB351_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB351_capu],
    pdu_port=_comu_pdu.pdu_ports[4],
)


_eNB351_rm1 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_comu_pdu.pdu_ports[1],
    radio_type="FRHC",
    attenuation_ports=[
        _rf_att.attenuator_ports[29],
        _rf_att.attenuator_ports[30],
        _rf_att.attenuator_ports[31],
        _rf_att.attenuator_ports[32],
    ],
)

_eNB351_airscale = Airscale(common_units=[_eNB351_comu])

_eNB351 = RealEnb(
    system_module=_eNB351_airscale,
    rms=[
        _gNB351_AHLOA_51,
        _gNB351_AHLOA_01,
        _gNB351_AHLOA_06,
        _gNB351_AHFIB_19,
        _gNB351_AHFIB_53,
        _gNB351_AHFIB_11,
        _eNB351_rm1,
    ],
    oam_ip=NetworkAddress(v4="10.47.203.200"),
)
# ---------------- END eNB-1 ------------------------

# ---------------- START QC UE1 ------------------------


_ue_ctrl_pc1_ssh_details = SshServiceDetails(
    addr="10.46.135.51", username="deul5g", password="Nuc2Ue4PzLab!"
)
_appserver_ssh = SshServiceDetails(
    addr="10.47.194.212", username="ute", password="UTE.debian12"
)

_iperf_UE = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    iperf_version="2",
)
_SDX70_1 = Android(
    ssh_connection_details=_ue_ctrl_pc1_ssh_details,
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE", "UE_1"],
    serial_number="ddb451bf",
    server_dir="C:/pyro_server",
    python_path="C:/Python38/python.exe",
    iperf_details=_iperf_UE,
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    serial_com="6",
    diag_com="5",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    pdu_port=_comu_pdu.pdu_ports[9],
)

# ---------------- END QC UE1 ------------------------

# ---------------- START TAF_UE_PROXY UEs ----------------

_app_server_1 = TafUeAppServer(
    app_server_name="DEUL5Gappsrv12",
    address="10.47.194.212",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.212",
    binary_path="iperf",
    ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254],
)


_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, version=2
)

_Qualcomm1 = TafUeAndroid(
    serial_number="4dfb4433",
    ue_pc_address="10.46.135.51",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE", "UE_1"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc1_ssh_details,
    ue_pc_port="8080",
)

_mtk_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    interval=1,
    binary_path="/data/local/tmp/iperf",
    version=2,
)

_mtk2 = TafUeMtk(
    ue_pc_address="10.46.135.52",
    ue_pc_port=1234,
    serial_number="0123456789ABCDEF",
    data_transfer=[_mtk_data_transfer_iperf],
    com_port="auto",
    edb_file_path="auto",
    log_filter="2.Gen98_Default_Standard",
    imei="35190103413008",
    imsi="540017000001035",
    pdns=_pdns,
    default_pdn_name="ulmsa",
    capabilities=["REAL_UE", "REAL_MTK_UE2", "MTK_UE2", "UE_2"],
)

# ---------------- STOP TAF_UE_PROXY UEs ----------------

_core_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.47.194.212", username="ute", password="ute"
    ),
    network_interface_address="10.47.194.212",
    iperf_path="/usr/bin/iperf",
)

_core_appserver = AppServer(iperf_details=_core_iperf)


# ---------------- Start TEST PCs ------------------------
_gNB351_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.203.241",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[_gNB351],
)

_eNB351_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.203.242",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[_eNB351],
)

_gNB352_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.203.243",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[_gNB352],
)

# ---------------- End TEST PCs ------------------------

tl = TestLine(
    test_pc=_gNB351_test_pc,
    test_pcs=[_gNB351_test_pc, _eNB351_test_pc, _gNB352_test_pc],
    gnbs=[_gNB351, _gNB352],
    enbs=[_eNB351],
    pdus=[
        _comu_pdu,
        _gNB351_rf_pdu1,
        _gNB351_rf_pdu2,
        _gNB351_rf_pdu3,
    ],
    core=_tampereCore,
    ues=[_Qualcomm1, _mtk2],
    appserver=_core_appserver,
    attenuators=[
        _rf_att,
        _rf_att_1,
    ],
    tl_cloud_topology="CLASSICAL_5G",
)

__all__ = ["tl"]
