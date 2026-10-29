######################################
#  TestLine 367 Ulm                  #
######################################
__maintainer__ = "MN RAN Pz ULM 2 SG SqdGp63"
__team__ = "MN RAN Pz ULM 2 SG SqdGp63"
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
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.pdn import PDN, PDPTypes
from taf.config.testline.core import RealCore
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.attenuator import HBTE
from taf.config.testline.ue import TafUeMtk
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
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

_rf_att = HBTE(
    ip_addr="10.46.134.155",
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
    ip_addr="10.46.134.137",
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

_comu_pdu = Gude(
    addr="10.46.134.225",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 9, 10],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_rf_pdu1 = Gude(
    addr="10.46.134.21",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_rf_pdu2 = Gude(
    addr="10.46.134.207",
    port_numbers=[4],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_rf_pdu3 = Gude(
    addr="10.46.134.219",
    port_numbers=[9, 12],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)
# ---------------- START gnb-1 ------------------------ gnb_367-1

_gNB367_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.203.131",
        routing_v4=RoutingInformation(
            gateway="10.47.203.158", destIpAddr="10.47.203.128/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.203.131", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.203.131", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.203.132"),
    x2u=NetworkAddress(v4="10.47.203.133"),
    s1u=NetworkAddress(v4="10.47.203.133"),
)

_gNB367_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")

_gNB367_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB367_capu1],
    pdu_port=_comu_pdu.pdu_ports[5],
    hardware_type="ASIM",
)

_gNB367_airscale = Airscale(common_units=[_gNB367_comu])


_gNB367_du_rm_AHFII_25 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu1.pdu_ports[1],
    radio_type="AHFII",
    attenuation_ports=[
        _rf_att.attenuator_ports[1],
        _rf_att.attenuator_ports[2],
        _rf_att.attenuator_ports[3],
        _rf_att.attenuator_ports[3],
    ],
)

_gNB367_du_rm_AHFII_23 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu1.pdu_ports[5],
    radio_type="AHFII",
    attenuation_ports=[
        _rf_att.attenuator_ports[5],
        _rf_att.attenuator_ports[6],
        _rf_att.attenuator_ports[7],
        _rf_att.attenuator_ports[8],
    ],
)

_gNB367_du_rm_AHFII_20 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu1.pdu_ports[7],
    radio_type="AHFII",
    attenuation_ports=[
        _rf_att.attenuator_ports[9],
        _rf_att.attenuator_ports[10],
        _rf_att.attenuator_ports[11],
        _rf_att.attenuator_ports[12],
    ],
)

_gNB367_du_rm_AHLOA_55 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu1.pdu_ports[3],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att.attenuator_ports[13],
        _rf_att.attenuator_ports[14],
    ],
)

_gNB367_du_rm_AHCA_25 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu2.pdu_ports[4],
    radio_type="AHCA",
    attenuation_ports=[
        _rf_att.attenuator_ports[15],
        _rf_att.attenuator_ports[16],
    ],
)

_gNB367_du_rm_AKQJ_13 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu1.pdu_ports[1],
    radio_type="AKQJ",
    attenuation_ports=[
        _rf_att.attenuator_ports[17],
        _rf_att.attenuator_ports[18],
        _rf_att.attenuator_ports[17],
        _rf_att.attenuator_ports[18],
        _rf_att.attenuator_ports[19],
        _rf_att.attenuator_ports[20],
    ],
)

_gNB367_du_rm_AKQJ_15 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu1.pdu_ports[4],
    radio_type="AKQJ",
    attenuation_ports=[
        _rf_att.attenuator_ports[21],
        _rf_att.attenuator_ports[22],
    ],
)

_gNB367_du_rm_AKQJ_16 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu1.pdu_ports[7],
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

_gNB367_du_rm_AZQW_14 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu1.pdu_ports[12],
    radio_type="AZQW",
    attenuation_ports=[
        _rf_att.attenuator_ports[29],
        _rf_att.attenuator_ports[30],
        _rf_att.attenuator_ports[29],
        _rf_att.attenuator_ports[30],
        _rf_att.attenuator_ports[31],
        _rf_att.attenuator_ports[32],
    ],
)

_gNB367_du = DU(
    airscale=_gNB367_airscale,
    rus=[
        _gNB367_du_rm_AHFII_25,
        _gNB367_du_rm_AHFII_23,
        _gNB367_du_rm_AHFII_20,
        _gNB367_du_rm_AHLOA_55,
        _gNB367_du_rm_AHCA_25,
        _gNB367_du_rm_AKQJ_13,
        _gNB367_du_rm_AKQJ_15,
        _gNB367_du_rm_AKQJ_16,
        _gNB367_du_rm_AZQW_14,
    ],
)

_gNB367 = ClassicalBts(cu=_gNB367_cu, dus=[_gNB367_du])
# ---------------- END gnb-1 ------------------------


# ---------------- START gnb-2 ------------------------ gnb_367-2

_gNB2_367_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.203.136",
        routing_v4=RoutingInformation(
            gateway="10.47.203.158", destIpAddr="10.47.203.128/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.203.136", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.203.136", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.203.137"),
    x2u=NetworkAddress(v4="10.47.203.138"),
    s1u=NetworkAddress(v4="10.47.203.138"),
)

_gNB2_367_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")

_gNB2_367_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB2_367_capu1],
    pdu_port=_comu_pdu.pdu_ports[7],
    hardware_type="ASIM",
)

_gNB2_367_airscale = Airscale(common_units=[_gNB2_367_comu])


_gNB2_367_du_rm_AHFII_18 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu1.pdu_ports[11],
    radio_type="AHFII",
    attenuation_ports=[
        _rf_att_1.attenuator_ports[1],
        _rf_att_1.attenuator_ports[2],
        _rf_att_1.attenuator_ports[3],
        _rf_att_1.attenuator_ports[4],
    ],
)

_gNB2_367_du_rm_AHLOA_71 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu1.pdu_ports[6],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att_1.attenuator_ports[5],
        _rf_att_1.attenuator_ports[6],
    ],
)

_gNB2_367_du_rm_AKQJ_12 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu1.pdu_ports[10],
    radio_type="AZQJ",
    attenuation_ports=[
        _rf_att_1.attenuator_ports[7],
        _rf_att_1.attenuator_ports[8],
        _rf_att_1.attenuator_ports[9],
        _rf_att_1.attenuator_ports[10],
    ],
)

_gNB2_367_du_rm_AKQW_14 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu1.pdu_ports[12],
    radio_type="AZQW",
    attenuation_ports=[
        _rf_att_1.attenuator_ports[11],
        _rf_att_1.attenuator_ports[12],
        _rf_att_1.attenuator_ports[13],
        _rf_att_1.attenuator_ports[14],
    ],
)

_gNB2_367_du = DU(
    airscale=_gNB367_airscale,
    rus=[
        _gNB2_367_du_rm_AHFII_18,
        _gNB2_367_du_rm_AHLOA_71,
        _gNB2_367_du_rm_AKQJ_12,
        _gNB2_367_du_rm_AKQW_14,
    ],
)

_gNB2_367 = ClassicalBts(cu=_gNB2_367_cu, dus=[_gNB2_367_du])
# ---------------- END gnb-2 ------------------------

# ---------------- START eNB-1 ------------------------ eNB_367


_eNB367_capu = CapacityUnit(addr="192.168.253.20")

_eNB367_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB367_capu],
    pdu_port=_comu_pdu.pdu_ports[4],
)


_eNB367_rm_FRHC = RU(
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
        _rf_att.attenuator_ports[23],
        _rf_att.attenuator_ports[24],
    ],
)

_eNB367_airscale = Airscale(common_units=[_eNB367_comu])

_eNB367 = RealEnb(
    system_module=_eNB367_airscale,
    rms=[_eNB367_rm_FRHC],
    oam_ip=NetworkAddress(v4="10.47.203.130"),
)
# ---------------- END eNB-1 ------------------------

# ---------------- START eNB-2 ------------------------ eNB_368


_eNB2_367_capu = CapacityUnit(addr="192.168.253.20")

_eNB2_367_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB2_367_capu],
    pdu_port=_comu_pdu.pdu_ports[6],
)

_eNB2_367_rm_FRHC = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_comu_pdu.pdu_ports[2],
    radio_type="FRHC",
    attenuation_ports=[
        _rf_att_1.attenuator_ports[15],
        _rf_att_1.attenuator_ports[16],
    ],
)

_eNB2_367_airscale = Airscale(common_units=[_eNB2_367_comu])

_eNB2_367 = RealEnb(
    system_module=_eNB2_367_airscale,
    rms=[_eNB2_367_rm_FRHC],
    oam_ip=NetworkAddress(v4="10.47.203.140"),
)
# ---------------- END eNB-2 ------------------------

# ---------------- START QC UE1 ------------------------

_ue_ctrl_pc1_ssh_details = SshServiceDetails(
    addr="10.46.135.61", username="deul5g", password="Nuc2Ue4PzLab!"
)

_ue_ctrl_pc2_ssh_details = SshServiceDetails(
    addr="10.46.135.62", username="deul5g", password="Nuc2Ue4PzLab!"
)

_ue_ctrl_pc3_ssh_details = SshServiceDetails(
    addr="10.46.135.63", username="deul5g", password="Nuc2Ue4PzLab!"
)

_ue_ctrl_pc4_ssh_details = SshServiceDetails(
    addr="10.46.135.64", username="deul5g", password="Nuc2Ue4PzLab!"
)

_appserver_ssh = SshServiceDetails(
    addr="10.44.35.216", username="ute", password="UTE.debian12"
)


# _iperf_UE = IperfDataTransferDetails(
#    ssh_connection_details=_appserver_ssh,
#    iperf_version="2",
# )

# ---------------- END QC UE1 ------------------------

# ---------------- START TAF_UE_PROXY UEs ----------------

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.44.35.216",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.44.35.216",
    binary_path="iperf",
    ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254],
)


_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, version=2
)

_mtk_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    interval=1,
    binary_path="/data/local/tmp/iperf",
    version=2,
)

_Qualcomm_SDX80_67 = TafUeAndroid(
    serial_number="b2e00539",
    ue_pc_address="10.46.135.61",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE", "UE_1"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc1_ssh_details,
    ue_pc_port="8080",
    pdu_port=_comu_pdu.pdu_ports[7],
)

_MTK_M80_49 = TafUeMtk(
    ue_pc_address="10.46.135.62",
    ue_pc_port=1234,
    serial_number="0123456789ABCDEF",
    data_transfer=[_mtk_data_transfer_iperf],
    com_port="auto",
    edb_file_path="auto",
    log_filter="2.Gen98_Default_Standard",
    imei="35190103413024",
    imsi="540017000001066",
    pdns=_pdns,
    default_pdn_name="ulmsa",
    capabilities=["REAL_UE", "REAL_MTK_UE2", "MTK_UE2", "UE_2"],
)

_Qualcomm_SDX70_52 = TafUeAndroid(
    serial_number="352bd309",
    ue_pc_address="10.46.135.63",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE", "UE_3"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc3_ssh_details,
    ue_pc_port="8080",
    pdu_port=_comu_pdu.pdu_ports[9],
)

_Qualcomm_SDX65_38 = TafUeAndroid(
    serial_number="b2e00539",
    ue_pc_address="10.46.135.61",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE", "UE_4"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc1_ssh_details,
    ue_pc_port="8080",
    pdu_port=_comu_pdu.pdu_ports[10],
)

# ---------------- STOP TAF_UE_PROXY UEs ----------------

_core_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.44.35.216", username="ute", password="UTE.debian12"
    ),
    network_interface_address="10.44.35.216",
    iperf_path="/usr/bin/iperf",
)

_core_appserver = AppServer(iperf_details=_core_iperf)


# ---------------- Start TEST PCs ------------------------
_gNB367_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.203.177",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[_gNB367],
)

_gNB2_367_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.203.179",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[_gNB2_367],
)

_eNB367_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.203.178",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[_eNB367],
)

_eNB2_367_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.203.180",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[_eNB2_367],
)
# ---------------- End TEST PCs ------------------------

tl = TestLine(
    test_pc=_gNB367_test_pc,
    test_pcs=[_gNB367_test_pc, _gNB2_367_test_pc, _eNB367_test_pc, _eNB2_367_test_pc],
    gnbs=[_gNB367, _gNB2_367],
    enbs=[_eNB367, _eNB2_367],
    pdus=[_comu_pdu, _rf_pdu1, _rf_pdu2, _rf_pdu3],
    core=_tampereCore,
    #   ues=[_SDX70_52, _mtk2],
    ues=[_Qualcomm_SDX80_67, _MTK_M80_49, _Qualcomm_SDX70_52, _Qualcomm_SDX65_38],
    appserver=_core_appserver,
    attenuators=[
        _rf_att,
        _rf_att_1,
    ],
    tl_cloud_topology="CLASSICAL_5G",
)

__all__ = ["tl"]
