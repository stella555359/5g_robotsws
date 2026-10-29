######################################
#  TestLine 387 Ulm                  #
######################################
__maintainer__ = "MN ECE RD ULM L2PS 04 SG SQD64"
__team__ = "MN ECE RD ULM L2PS 04 SG SQD64"
__email__ = "I_MN_ECE_ULM_RD_L2PS_04_SG_SQD64_NIMS@internal.nsn.com"

from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNTafUeAndroidDetails
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdn import PDN, PDPTypes
from taf.config.testline import RealEnb
from taf.config.testline import RoutingInformation
from taf.config.testline.core import RealCore
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.appserver import AppServer
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.attenuator import HBTE
from taf.config.testline.ue import TafUeAndroid


_snmp_user_data = dict(
    userName="user",
    authKey="qwer2009!",
    privKey="qwer2009!",
    authProtocol="SHA",
    privProtocol="AES",
)

_comu_pdu = Gude(
    addr="10.46.134.244",
    port_numbers=[1, 2, 3, 4, 5, 6, 12],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_rf_pdu = Gude(
    addr="10.46.134.251",
    port_numbers=[3, 4, 5, 6, 7, 8, 9, 10, 11],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)
_rf_pdu_2 = Gude(
    addr="10.46.134.229",
    port_numbers=[5, 6, 7, 12],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_pdns = [
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsa"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi4.nokia.com.mnc001.mcc540.gprs"),
]

_tampereCore = RealCore(mcc="540", mnc="01", pdns=_pdns)

_app_server_1 = TafUeAppServer(
    app_server_name="DEUL5Gappsrv20",
    address="10.47.194.220",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.220",
)

_net_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.47.194.220", username="ute", password="UTE.debian12"
    ),
    network_interface_address="10.47.194.220",
    iperf_path="/usr/bin/iperf",
)

_net_appserver = AppServer(iperf_details=_net_iperf)

# ---------------- START ATTENUATIORS -----------------------------

_rf_att = HBTE(
    ip_addr="10.46.134.187",
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

_rf_att_2 = HBTE(
    ip_addr="10.46.134.188",
    port="5000",
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    version=None,
    model="PA-16-16-6-127-0.5-B-S",
)

# ---------------- STOP ATTENUATORS -------------------

# ---------------- START gNB-1 ------------------------ gNB_387

_gnb1_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.206.66",
        routing_v4=RoutingInformation(
            gateway="10.47.206.78", destIpAddr="10.47.206.64/28"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.206.66", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.206.66", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.206.67"),
    x2u=NetworkAddress(v4="10.47.206.68"),
    s1u=NetworkAddress(v4="10.47.206.68"),
)

_gnb1_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")

_gnb1_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gnb1_capu1],
    pdu_port=_comu_pdu.pdu_ports[3],
    hardware_type="ASIK",
)

_gnb1_airscale = Airscale(common_units=[_gnb1_comu])

_gnb1_du_rm_AHFII_04 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu.pdu_ports[4],
    radio_type="AHFII",
    attenuation_ports=[
        _rf_att.attenuator_ports[1],
        _rf_att.attenuator_ports[2],
        _rf_att.attenuator_ports[3],
        _rf_att.attenuator_ports[4],
    ],
)

_gnb1_du_rm_AHFII_02 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu.pdu_ports[7],
    radio_type="AHFII",
    attenuation_ports=[
        _rf_att.attenuator_ports[5],
        _rf_att.attenuator_ports[6],
        _rf_att.attenuator_ports[7],
        _rf_att.attenuator_ports[8],
    ],
)

_gnb1_du_rm_AHFII_08 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu.pdu_ports[10],
    radio_type="AHFII",
    attenuation_ports=[
        _rf_att.attenuator_ports[9],
        _rf_att.attenuator_ports[10],
        _rf_att.attenuator_ports[11],
        _rf_att.attenuator_ports[12],
    ],
)

_gnb1_du_rm_AKQJ_18 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu_2.pdu_ports[7],
    radio_type="AKQJ",
    attenuation_ports=[
        _rf_att.attenuator_ports[13],
        _rf_att.attenuator_ports[14],
        _rf_att.attenuator_ports[13],
        _rf_att.attenuator_ports[14],
        _rf_att.attenuator_ports[15],
        _rf_att.attenuator_ports[16],
    ],
)

_gnb1_du_rm_AKQJ_23 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu_2.pdu_ports[6],
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

_gnb1_du_rm_AHLOA_73 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu.pdu_ports[3],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att.attenuator_ports[21],
        _rf_att.attenuator_ports[22],
    ],
)

_gnb1_du_rm_AHLOA_36 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu.pdu_ports[5],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att.attenuator_ports[23],
        _rf_att.attenuator_ports[24],
    ],
)


_gnb1_du_rm_AHLOA_37 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu.pdu_ports[11],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att.attenuator_ports[25],
        _rf_att.attenuator_ports[26],
    ],
)


_gnb1_du_rm_AEHC_03 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu_2.pdu_ports[12],
    radio_type="AEHC",
    attenuation_ports=[
        _rf_att.attenuator_ports[29],
        _rf_att.attenuator_ports[30],
        _rf_att.attenuator_ports[31],
        _rf_att.attenuator_ports[32],
    ],
)


_gnb1_du_rm_AHCA_38 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu.pdu_ports[5],
    radio_type="AHCA",
    attenuation_ports=[
        _rf_att_2.attenuator_ports[15],
        _rf_att_2.attenuator_ports[16],
    ],
)


_gnb1_du = DU(
    airscale=_gnb1_airscale,
    rus=[
        _gnb1_du_rm_AHLOA_73,
        _gnb1_du_rm_AHLOA_36,
        _gnb1_du_rm_AHLOA_37,
        _gnb1_du_rm_AHFII_04,
        _gnb1_du_rm_AHFII_02,
        _gnb1_du_rm_AHFII_08,
        _gnb1_du_rm_AKQJ_18,
        _gnb1_du_rm_AKQJ_23,
        _gnb1_du_rm_AEHC_03,
        _gnb1_du_rm_AHCA_38,
    ],
)

_gnb1 = ClassicalBts(cu=_gnb1_cu, dus=[_gnb1_du])

# ---------------- END gNB-1 ------------------------ gNB_387

# ---------------- START gNB-2 ------------------------ gNB_388

_gnb2_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.206.71",
        routing_v4=RoutingInformation(
            gateway="10.47.206.78", destIpAddr="10.47.206.64/28"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.206.71", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.206.71", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.206.72"),
    x2u=NetworkAddress(v4="10.47.206.73"),
    s1u=NetworkAddress(v4="10.47.206.73"),
)

_gnb2_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIO")

_gnb2_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gnb2_capu1],
    pdu_port=_comu_pdu.pdu_ports[5],
    hardware_type="ASIL",
)

_gnb2_airscale = Airscale(common_units=[_gnb2_comu])

_gnb2_du_rm_AHFII_06 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu.pdu_ports[9],
    radio_type="AHFII",
    attenuation_ports=[
        _rf_att_2.attenuator_ports[1],
        _rf_att_2.attenuator_ports[2],
        _rf_att_2.attenuator_ports[3],
        _rf_att_2.attenuator_ports[4],
    ],
)

_gnb2_du_rm_AKQJ_19 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu_2.pdu_ports[5],
    radio_type="AKQJ",
    attenuation_ports=[
        _rf_att_2.attenuator_ports[5],
        _rf_att_2.attenuator_ports[6],
        _rf_att_2.attenuator_ports[7],
        _rf_att_2.attenuator_ports[8],
    ],
)

_gnb2_du_rm_AHLOA_72 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu.pdu_ports[6],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att_2.attenuator_ports[9],
        _rf_att_2.attenuator_ports[10],
        _rf_att_2.attenuator_ports[11],
        _rf_att_2.attenuator_ports[12],
    ],
)

_gnb2_du = DU(
    airscale=_gnb2_airscale,
    rus=[
        _gnb2_du_rm_AHLOA_72,
        _gnb2_du_rm_AHFII_06,
        _gnb2_du_rm_AKQJ_19,
    ],
)

_gnb2 = ClassicalBts(cu=_gnb2_cu, dus=[_gnb2_du])

# ---------------- END gNB-2 ------------------------ gNB_388

# ---------------- START eNB-1 ------------------------ eNB_387

_enb1_capu = CapacityUnit(addr="192.168.253.20")

_enb1_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_enb1_capu],
    pdu_port=_comu_pdu.pdu_ports[4],
)

_enb1_rm1 = RU(
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
        _rf_att.attenuator_ports[27],
        _rf_att.attenuator_ports[28],
    ],
)

_enb1_system_module = Airscale(common_units=[_enb1_comu])

_enb1 = RealEnb(
    system_module=_enb1_system_module,
    rms=[
        _gnb1_du_rm_AHLOA_73,
        _gnb1_du_rm_AHLOA_36,
        _gnb1_du_rm_AHLOA_37,
        _gnb1_du_rm_AHFII_04,
        _gnb1_du_rm_AHFII_02,
        _gnb1_du_rm_AHFII_08,
        _enb1_rm1,
    ],
    oam_ip=NetworkAddress(v4="10.47.206.65"),
)

# ---------------- END eNB-1 ------------------------ eNB_387

# ---------------- START eNB-2 ------------------------ eNB_388

_enb2_capu = CapacityUnit(addr="192.168.253.20")


_enb2_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_enb2_capu],
    pdu_port=_comu_pdu.pdu_ports[6],
)

_enb2_rm1 = RU(
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
        _rf_att_2.attenuator_ports[13],
        _rf_att_2.attenuator_ports[14],
    ],
)

_enb2_system_module = Airscale(common_units=[_enb2_comu])

_enb2 = RealEnb(
    system_module=_enb2_system_module,
    rms=[_enb2_rm1],
    oam_ip=NetworkAddress(v4="10.47.206.70"),
)

# ---------------- END eNB-2 ------------------------ eNB_388

# ---------------- Start TEST PCs ------------------------

_gNB1_testpc1_ssh = SshServiceDetails(
    addr="10.47.206.97", username="ute", password="UTE.debian12"
)

_gNB1_testpc1 = TestPc(
    default_ssh_connection_details=_gNB1_testpc1_ssh, connections=[_gnb1]
)

_gNB2_testpc2_ssh = SshServiceDetails(
    addr="10.47.206.99", username="ute", password="UTE.debian12"
)

_gNB2_testpc2 = TestPc(
    default_ssh_connection_details=_gNB2_testpc2_ssh, connections=[_gnb2]
)

_eNB1_testpc3_ssh = SshServiceDetails(
    addr="10.47.206.98", username="ute", password="UTE.debian12"
)

_eNB1_testpc3 = TestPc(
    default_ssh_connection_details=_eNB1_testpc3_ssh, connections=[_enb1]
)

_eNB2_testpc4_ssh = SshServiceDetails(
    addr="10.47.206.100", username="ute", password="UTE.debian12"
)

_eNB2_testpc4 = TestPc(
    default_ssh_connection_details=_eNB2_testpc4_ssh, connections=[_enb2]
)

# ---------------- End TEST PCs ------------------------

# ---------------- START QC UE1 ------------------------

_ue_ctrl_pc_2_ssh_details = SshServiceDetails(
    addr="10.46.135.79", username="deul5g", password="Nuc2Ue4PzLab!"
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, version=2
)

_qualcomm63_sdx75 = TafUeAndroid(
    serial_number="c42ec35a",
    ue_pc_address="10.46.135.79",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE", "Qualcomm", "UE_1"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc_2_ssh_details,
    ue_pc_port="8080",
    pdu_port=_comu_pdu.pdu_ports[12],
)

# ---------------- END QC UE1 ------------------------

# ---------------- START MEDIATEK UE2 ------------------------

_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.135.59", username="deul5g", password="Nuc2Ue4PzLab!"
)

_mtk_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    interval=1,
    binary_path="/data/local/tmp/iperf",
    version=2,
)


_pdn1 = PDNTafUeAndroidDetails(
    entryName="ulmsa",
    apnName="ulmsa",
    apnType=["DEFAULT", "MMS", "XCAP"],
)
_pdn2 = PDNTafUeAndroidDetails(
    entryName="ulmsamqi4.nokia.com.mnc001.mcc540.gprs",
    apnName="ulmsamqi4.nokia.com.mnc001.mcc540.gprs",
    apnType=["DEFAULT", "MMS", "XCAP"],
)

_mtk46 = TafUeAndroid(
    serial_number="0123456789ABCDEF",
    ue_pc_address="10.46.135.59",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "MTK", "MTK_UE2", "UE_2"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc_ssh_details,
    pdns=[_pdn1, _pdn2],
    ue_pc_port="1234",
)

# ---------------- END MEDIATEK UE2 ------------------------

tl = TestLine(
    test_pc=_gNB1_testpc1,
    test_pcs=[_gNB1_testpc1, _gNB2_testpc2, _eNB1_testpc3, _eNB2_testpc4],
    core=_tampereCore,
    appserver=_net_appserver,
    gnbs=[_gnb1, _gnb2],
    enbs=[_enb1, _enb2],
    pdus=[
        _comu_pdu,
        _rf_pdu,
    ],
    ues=[_qualcomm63_sdx75, _mtk46],
    attenuator=[_rf_att, _rf_att_2],
    tl_cloud_topology="CLASSICAL_5G",
)

__all__ = ["tl"]
