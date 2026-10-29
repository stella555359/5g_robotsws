#######################################
# TestLine TL389 Ulm (7_15_UTE5GTL389)#
#######################################
__maintainer__ = "MN RAN RD VRF ULM 2 SqdGp64"
__team__ = "MN RAN RD VRF ULM 2 SqdGp64"
__email__ = "i_pz_ulm_sqd_64@internal.nsn.com"

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

_snmp_user_data = dict(
    userName="user",
    authKey="qwer2009!",
    privKey="qwer2009!",
    authProtocol="SHA",
    privProtocol="AES",
)

# _pdns = [
#     PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi1.nokia.com.mnc001.mcc540.gprs"),
#     PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi2.nokia.com.mnc001.mcc540.gprs"),
#     PDN(pdp_type=PDPTypes.IP.value, apn="ulmsa"),
#     PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi3.nokia.com.mnc001.mcc540.gprs"),
#     PDN(pdp_type=PDPTypes.IP.value, apn="ulmsaslicemqi1.mnc001.mcc540.gprs"),
#     PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi1.nokia.com.mnc007.mcc244.gprs"),
#     PDN(pdp_type=PDPTypes.IP.value, apn="ulmsaslicemqi2.mnc007.mcc244.gprs"),
#     PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi3.nokia.com.mnc007.mcc244.gprs"),
#     PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi2.nokia.com.mnc007.mcc244.gprs"),
#     PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi4.nokia.com.mnc001.mcc540.gprs"),
#     PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi5.nokia.com.mnc001.mcc540.gprs"),
#     PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi4.nokia.com.mnc007.mcc244.gprs"),
#     PDN(pdp_type=PDPTypes.IP.value, apn="ulmsagbr1.nokia.com"),
#     PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi5.nokia.com.mnc007.mcc244.gprs"),
# ]
# _tampereCore = RealCore(mcc="540", mnc="01", pdns=_pdns)

# ---------------- START Power Switchs ------------------------ gnb_389

_pdu1_366 = Gude(
    addr="10.46.134.246",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_pdu1_367 = Gude(
    addr="10.46.134.247",
    port_numbers=[7, 8, 9, 10, 12],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_pdu1_368 = Gude(
    addr="10.46.134.248",
    port_numbers=[1, 2, 3, 4],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_pdu1_337 = Gude(
    addr="10.46.134.237",
    port_numbers=[6],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_pdu1_339 = Gude(
    addr="10.46.134.239",
    port_numbers=[3],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_gNB389_rf_att_1 = HBTE(
    ip_addr="10.46.134.189",
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

_gNB389_rf_att_2 = HBTE(
    ip_addr="10.46.134.190",
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

# ---------------- START gNB-1 -------------------TL389#

_gNB389_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.206.201",
        routing_v4=RoutingInformation(
            gateway="10.47.206.222", destIpAddr="10.47.206.192/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.206.201", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.206.201", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.206.202"),
    x2u=NetworkAddress(v4="10.47.206.203"),
    s1u=NetworkAddress(v4="10.47.206.203"),
)

_gNB389_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIO")

_gNB389_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB389_capu1],
    pdu_port=_pdu1_366.pdu_ports[3],
    hardware_type="ASIM",
)

_gNB389_airscale = Airscale(common_units=[_gNB389_comu])

_gNB389_rm_AHFII_10 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_367.pdu_ports[10],
    radio_type="AHFII",
    attenuation_ports=[
        _gNB389_rf_att_1.attenuator_ports[1],
        _gNB389_rf_att_1.attenuator_ports[2],
        _gNB389_rf_att_1.attenuator_ports[3],
        _gNB389_rf_att_1.attenuator_ports[4],
    ],
)

_gNB389_rm_AHFII_11 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_366.pdu_ports[11],
    radio_type="AHFII",
    attenuation_ports=[
        _gNB389_rf_att_1.attenuator_ports[5],
        _gNB389_rf_att_1.attenuator_ports[6],
        _gNB389_rf_att_1.attenuator_ports[7],
        _gNB389_rf_att_1.attenuator_ports[8],
    ],
)

_gNB389_rm_AHFII_12 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_366.pdu_ports[12],
    radio_type="AHFII",
    attenuation_ports=[
        _gNB389_rf_att_1.attenuator_ports[9],
        _gNB389_rf_att_1.attenuator_ports[10],
        _gNB389_rf_att_1.attenuator_ports[11],
        _gNB389_rf_att_1.attenuator_ports[12],
    ],
)

_gNB389_rm_AHLOA_19 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_367.pdu_ports[7],
    radio_type="AHLOA",
    attenuation_ports=[
        _gNB389_rf_att_1.attenuator_ports[13],
        _gNB389_rf_att_1.attenuator_ports[14],
    ],
)

_gNB389_rm_AHCA_57 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_337.pdu_ports[6],
    radio_type="AHCA",
    attenuation_ports=[
        _gNB389_rf_att_1.attenuator_ports[15],
        _gNB389_rf_att_1.attenuator_ports[16],
    ],
)

_gNB389_rm_AZQI_04 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_367.pdu_ports[12],
    radio_type="AZQI",
    attenuation_ports=[
        _gNB389_rf_att_1.attenuator_ports[17],
        _gNB389_rf_att_1.attenuator_ports[18],
        _gNB389_rf_att_1.attenuator_ports[17],
        _gNB389_rf_att_1.attenuator_ports[18],
        _gNB389_rf_att_1.attenuator_ports[19],
        _gNB389_rf_att_1.attenuator_ports[20],
    ],
)

_gNB389_rm_AZQI_05 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_368.pdu_ports[1],
    radio_type="AZQI",
    attenuation_ports=[
        _gNB389_rf_att_1.attenuator_ports[21],
        _gNB389_rf_att_1.attenuator_ports[22],
    ],
)

_gNB389_rm_AZQI_03 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_368.pdu_ports[2],
    radio_type="AZQI",
    attenuation_ports=[
        _gNB389_rf_att_1.attenuator_ports[25],
        _gNB389_rf_att_1.attenuator_ports[26],
        _gNB389_rf_att_1.attenuator_ports[25],
        _gNB389_rf_att_1.attenuator_ports[26],
        _gNB389_rf_att_1.attenuator_ports[27],
        _gNB389_rf_att_1.attenuator_ports[28],
    ],
)

_gNB389_rm_AZQW_05 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_368.pdu_ports[3],
    radio_type="AZQW",
    attenuation_ports=[
        _gNB389_rf_att_1.attenuator_ports[29],
        _gNB389_rf_att_1.attenuator_ports[30],
        _gNB389_rf_att_1.attenuator_ports[29],
        _gNB389_rf_att_1.attenuator_ports[30],
        _gNB389_rf_att_1.attenuator_ports[31],
        _gNB389_rf_att_1.attenuator_ports[32],
    ],
)

_gNB389_du = DU(
    airscale=_gNB389_airscale,
    rus=[
        _gNB389_rm_AHFII_10,
        _gNB389_rm_AHFII_11,
        _gNB389_rm_AHFII_12,
        _gNB389_rm_AHLOA_19,
        _gNB389_rm_AHCA_57,
        _gNB389_rm_AZQI_04,
        _gNB389_rm_AZQI_05,
        _gNB389_rm_AZQI_03,
        _gNB389_rm_AZQW_05,
    ],
)

_gNB389 = ClassicalBts(cu=_gNB389_cu, dus=[_gNB389_du])

# ----------------- END gNB-1 --------------------TL389 #

# ---------------- START gNB-2 -------------------TL390 #

_gNB390_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.206.211",
        routing_v4=RoutingInformation(
            gateway="10.47.206.222", destIpAddr="10.47.206.192/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.206.211", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.206.211", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.206.212"),
    x2u=NetworkAddress(v4="10.47.206.213"),
    s1u=NetworkAddress(v4="10.47.206.213"),
)

_gNB390_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIO")

_gNB390_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB390_capu1],
    pdu_port=_pdu1_366.pdu_ports[5],
    hardware_type="ASIM",
)

_gNB390_airscale = Airscale(common_units=[_gNB390_comu])

_gNB390_rm_AHFII_09 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_367.pdu_ports[8],
    radio_type="AHFII",
    attenuation_ports=[
        _gNB389_rf_att_2.attenuator_ports[1],
        _gNB389_rf_att_2.attenuator_ports[2],
        _gNB389_rf_att_2.attenuator_ports[3],
        _gNB389_rf_att_2.attenuator_ports[4],
    ],
)

_gNB390_rm_AHLOA_57 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_367.pdu_ports[9],
    radio_type="AHFII",
    attenuation_ports=[
        _gNB389_rf_att_2.attenuator_ports[5],
        _gNB389_rf_att_2.attenuator_ports[6],
    ],
)

_gNB390_rm_AZQI_07 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_368.pdu_ports[4],
    radio_type="AHFII",
    attenuation_ports=[
        _gNB389_rf_att_2.attenuator_ports[7],
        _gNB389_rf_att_2.attenuator_ports[8],
        _gNB389_rf_att_2.attenuator_ports[7],
        _gNB389_rf_att_2.attenuator_ports[8],
        _gNB389_rf_att_2.attenuator_ports[9],
        _gNB389_rf_att_2.attenuator_ports[10],
    ],
)

_gNB390_rm_AZQW_06 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_339.pdu_ports[3],
    radio_type="AHFII",
    attenuation_ports=[
        _gNB389_rf_att_2.attenuator_ports[11],
        _gNB389_rf_att_2.attenuator_ports[12],
        _gNB389_rf_att_2.attenuator_ports[11],
        _gNB389_rf_att_2.attenuator_ports[12],
        _gNB389_rf_att_2.attenuator_ports[13],
        _gNB389_rf_att_2.attenuator_ports[14],
    ],
)

_gNB390_du = DU(
    airscale=_gNB390_airscale,
    rus=[
        _gNB390_rm_AHFII_09,
        _gNB390_rm_AHLOA_57,
        _gNB390_rm_AZQI_07,
        _gNB390_rm_AZQW_06,
    ],
)

_gNB390 = ClassicalBts(cu=_gNB390_cu, dus=[_gNB390_du])

# ----------------- END gNB-2 --------------------TL390 #

# ----------------- START eNB-1 --------------------TL389 #

_eNB389_capu = CapacityUnit(addr="192.168.253.20", hardware_type="ABIA")

_eNB389_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB389_capu],
    pdu_port=_pdu1_366.pdu_ports[4],
    hardware_type="ASIA",
)

_eNB389_rm_50 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_366.pdu_ports[1],
    radio_type="FRHC",
    attenuation_ports=[
        _gNB389_rf_att_1.attenuator_ports[23],
        _gNB389_rf_att_1.attenuator_ports[24],
    ],
)

# _eNB389_rm_50
# DSS/RF-Sharing opt. Connections: DISABLED!

_eNB389_airscale = Airscale(common_units=[_eNB389_comu])

_eNB389 = RealEnb(
    system_module=_eNB389_airscale,
    rms=[
        _gNB389_rm_AHFII_10,
        _gNB389_rm_AHFII_11,
        _gNB389_rm_AHFII_12,
        _gNB389_rm_AHLOA_19,
        _gNB389_rm_AHCA_57,
        _eNB389_rm_50,
    ],
    oam_ip=NetworkAddress(v4="10.47.206.200"),
)

# ----------------- END eNB-1 --------------------TL389 #

# ----------------- START eNB-2 --------------------TL390 #

_eNB390_capu = CapacityUnit(addr="192.168.253.20", hardware_type="ABIA")

_eNB390_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB390_capu],
    pdu_port=_pdu1_366.pdu_ports[6],
    hardware_type="ASIA",
)

_eNB390_rm_50 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_366.pdu_ports[2],
    radio_type="FRHC",
    attenuation_ports=[
        _gNB389_rf_att_2.attenuator_ports[15],
        _gNB389_rf_att_2.attenuator_ports[16],
    ],
)

_eNB390_airscale = Airscale(common_units=[_eNB390_comu])

_eNB390 = RealEnb(
    system_module=_eNB390_airscale,
    rms=[_eNB390_rm_50],
    oam_ip=NetworkAddress(v4="10.47.206.210"),
)

# ----------------- END eNB-2 --------------------TL390 #

# ---------------- START Core APP Server ------------------- #

# DEUL5Gappsrv04
_app_server_1 = TafUeAppServer(
    app_server_name="DEUL5Gappsrv04",
    # address="10.47.194.204", !240729 SAME IP!
    # Not! address="DEUL5Gappsrv10.intra.noklab.net",
    # address="DEUL-appsrv10.ulm.nsn-rdnet.net",
    address="DEUL5Gappsrv04.ulm.nsn-rdnet.net",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.204",
    #    binary_path="iperf",
    #    ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254]
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    interval=1,
    #    binary_path="/data/local/tmp/iperf",
    version=2,
    dt_from_uepc=True,
)

# ---------------- END Core APP Server ------------------- #

_pdns = [
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsa"),
]

_tampereCore = RealCore(mcc="555", mnc="10", pdns=_pdns)

# ---------------- START QC UE1: Qualcomm #65 SDX75 ------------------------ #

_ue_ctrl_pc1_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC389-1.intra.noklab.net", username="deul5g", password="Nuc2Ue4PzLab!"
)

_qualcomm65_sdx75 = TafUeAndroid(
    serial_number="6e2d8f36",
    ue_pc_address="10.46.135.24",
    # ue_pc_address="DEUL5GNUC389-1.intra.noklab.net",
    # proxy_mngr_port=9955,  # ueproxy manager will not be visible unless proxy_mngr_port is configured! (default value: 9955 - used in autostart)
    capabilities=[
        "REAL_UE",
        "REAL_ANDROID_UE",
        "REAL_QUALCOMM_UE",
        "UE_1",
    ],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc1_ssh_details,
    ue_pc_port="8080",  # If proxy_mngr_port is defined in Ue object ue_pc_port will be omitted!
    pdu_port=_pdu1_366.pdu_ports[7],
)

# ---------------- END QC UE1: Qualcomm #65 SDX75 ------------------------ #

# ---------------- START QC UE2: Qualcomm #58 SDX70 ------------------------ #

_ue_ctrl_pc2_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC390-1.intra.noklab.net", username="deul5g", password="Nuc2Ue4PzLab!"
)

_qualcomm58_sdx70 = TafUeAndroid(
    serial_number="12c1902d",
    ue_pc_address="10.46.135.60",
    # ue_pc_address="DEUL5GNUC390-1.intra.noklab.net",
    # proxy_mngr_port=9955,  # ueproxy manager will not be visible unless proxy_mngr_port is configured! (default value: 9955 - used in autostart)
    capabilities=[
        "REAL_UE",
        "REAL_ANDROID_UE",
        "REAL_QUALCOMM_UE",
        "UE_2",
    ],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc2_ssh_details,
    ue_pc_port="8080",  # If proxy_mngr_port is defined in Ue object ue_pc_port will be omitted!
    pdu_port=_pdu1_366.pdu_ports[9],
)

# ---------------- END QC UE2: Qualcomm #58 SDX70 ------------------------ #

# ---------------- START QC UE3: Qualcomm #49 SDX65 ------------------------ #

_ue_ctrl_pc3_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC390-2.intra.noklab.net", username="deul5g", password="Nuc2Ue4PzLab!"
)

_qualcomm49_sdx65 = TafUeAndroid(
    serial_number="45a8d735",
    ue_pc_address="10.46.135.70",
    #ue_pc_address="DEUL5GNUC390-2.intra.noklab.net",
    # proxy_mngr_port=9955,  # ueproxy manager will not be visible unless proxy_mngr_port is configured! (default value: 9955 - used in autostart)
    capabilities=[
        "REAL_UE",
        "REAL_ANDROID_UE",
        "REAL_QUALCOMM_UE",
        "UE_3",
    ],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc3_ssh_details,
    ue_pc_port="8080",  # If proxy_mngr_port is defined in Ue object ue_pc_port will be omitted!
    pdu_port=_pdu1_366.pdu_ports[10],
)

# ----------------END QC UE3: Qualcomm #49 SDX65 ------------------------ #

# ---------------- START TEST PCs ------------------------ #

_gNB389_testpc1_ssh = SshServiceDetails(
    # 7-15-UTE5GTL389-1.ulm.nsn-rdnet.net
    # addr="10.47.206.245", username="ute", password="ute"
    addr="7-15-UTE5GTL389-1.ulm.nsn-rdnet.net",
    username="ute",
    password="UTE.debian12",
)

_gNB389_testpc1 = TestPc(
    default_ssh_connection_details=_gNB389_testpc1_ssh, connections=[_gNB389]
)

_eNB389_testpc2_ssh = SshServiceDetails(
    # addr="10.47.206.246", username="ute", password="ute"
    addr="7-15-UTE5GTL389-2.ulm.nsn-rdnet.net",
    username="ute",
    password="UTE.debian12",
)

_eNB389_testpc2 = TestPc(
    default_ssh_connection_details=_eNB389_testpc2_ssh, connections=[_eNB389]
)

_gNB390_testpc1_ssh = SshServiceDetails(
    addr="7-15-UTE5GTL390-1.ulm.nsn-rdnet.net",  # addr="10.47.206.241"
    username="ute",
    password="UTE.debian12",
)

_gNB390_testpc1 = TestPc(
    default_ssh_connection_details=_gNB390_testpc1_ssh, connections=[_gNB390]
)

_eNB390_testpc2_ssh = SshServiceDetails(
    addr="7-15-UTE5GTL390-2.ulm.nsn-rdnet.net",  # addr="110.47.206.242"
    username="ute",
    password="UTE.debian12",
)

_eNB390_testpc2 = TestPc(
    default_ssh_connection_details=_eNB390_testpc2_ssh, connections=[_eNB390]
)

# ---------------- END TEST PCs -------------------------- #

_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.47.194.204", username="ute", password="UTE.debian12"
    ),
    network_interface_address="10.47.194.204",
    iperf_path="iperf",
    # ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254],
)

_appserver = AppServer(_iperf_details_on_appserver)

# ----------------------------------------- TL ----------------------------------------- #

tl = TestLine(
    test_pc=_gNB389_testpc1,
    test_pcs=[_gNB389_testpc1, _eNB389_testpc2, _gNB390_testpc1, _eNB390_testpc2],
    gnbs=[_gNB389, _gNB390],
    enbs=[_eNB389, _eNB390],
    pdus=[_pdu1_366, _pdu1_367, _pdu1_368, _pdu1_337, _pdu1_339],
    core=_tampereCore,
    ues=[_qualcomm65_sdx75, _qualcomm58_sdx70, _qualcomm49_sdx65],
    attenuators=[_gNB389_rf_att_1, _gNB389_rf_att_2],
    appserver=_appserver,
    tl_cloud_topology="CLASSICAL_5G",
)

__all__ = ["tl"]
# ----------------------------------------- TL ----------------------------------------- #
