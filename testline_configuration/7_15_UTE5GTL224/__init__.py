######################################
#  TestLine 224 Ulm                  #
######################################
__maintainer__ = "MN RAN RD VRF ULM "
__team__ = "MN RAN RD VRF ULM"
__email__ = "OU_MN_RAN_RD_VRF_ULM_2_53028393@internal.nsn.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.appserver import AppServer
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.core import RealCore4G

from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.attenuator import HBTE

### to be kept for future testing
# from taf.config.testline import PDNAndroidDetails
from taf.config.testline import TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.ue import TafUeAndroid


_tampereCore = RealCore4G(mcc="540", mnc="01")

_rf_att_1 = HBTE(
    ip_addr="10.46.152.219",
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
    ip_addr="10.46.152.220",
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

_snmp_user_data = dict(
    userName="user",
    authKey="qwer2009!",
    privKey="qwer2009!",
    authProtocol="SHA",
    privProtocol="AES",
)


# PDU1-2021
_comu_pdu1 = Gude(
    addr="10.46.152.121",
    port_numbers=[5, 6, 7],
    version="8221-1",
    snmp_user=_snmp_user_data,
)

# PDU1_2022
# _UE_pdu1_2022 = Gude(
#    addr="10.46.152.122",
#    port_numbers=[7],
#    version="8221-1",
#    snmp_user=_snmp_user_data,
# )

# PDU1-2004
_rf_pdu1_2004 = Gude(
    addr="10.46.152.141",
    port_numbers=[10],
    version="8221-1",
    snmp_user=_snmp_user_data,
)

# PDU2-2004
_rf_pdu2_2004 = Gude(
    addr="10.46.152.142",
    port_numbers=[2, 3, 5, 6],
    version="8221-1",
    snmp_user=_snmp_user_data,
)

# PDU3-2004
_rf_pdu3_2004 = Gude(
    addr="10.46.152.143",
    port_numbers=[1],
    version="8221-1",
    snmp_user=_snmp_user_data,
)

# PDU2-2005
_rf_pdu2_2005 = Gude(
    addr="10.46.152.152",
    port_numbers=[4, 5, 7, 8, 10],
    version="8221-1",
    snmp_user=_snmp_user_data,
)

# PDU3-2005
_rf_pdu3_2005 = Gude(
    addr="10.46.152.153",
    port_numbers=[1, 3, 4, 5],
    version="8221-1",
    snmp_user=_snmp_user_data,
)

# PDU4-2005
_rf_pdu4_2005 = Gude(
    addr="10.46.152.154",
    port_numbers=[4],
    version="8221-1",
    snmp_user=_snmp_user_data,
)
# ---------------- START sbts-1 ------------------------

_SBTS_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.221.210",
        routing_v4=RoutingInformation(
            gateway="10.47.221.222", destIpAddr="10.47.221.208/28"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.221.210", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.221.210", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.221.211"),
    x2u=NetworkAddress(v4="10.47.221.212"),
    s1u=NetworkAddress(v4="10.47.221.212"),
)

_SBTS_BBMOD1 = CapacityUnit(
    addr="192.168.253.2",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1232105759",
)

_SBTS_BBMOD2 = CapacityUnit(
    # ip to be update
    addr="192.168.253.26",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1232105745",
)

_SBTS_BBMOD3 = CapacityUnit(
    # ip to be update
    addr="192.168.253.30",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1232105746",
)

_SBTS_BBMOD4 = CapacityUnit(
    # ip to be update
    addr="192.168.253.30",
    hardware_type="ABIP",
    hardware_version="475266A.105",
    serial_number="L1232105754",
)


_SBTS_SMOD1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_SBTS_BBMOD1],
    pdu_port=_comu_pdu1.pdu_ports[5],
    hardware_type="ASIM",
    serial_number="L1243008961",
)

_SBTS_SMOD2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_SBTS_BBMOD2, _SBTS_BBMOD3, _SBTS_BBMOD4],
    pdu_port=_comu_pdu1.pdu_ports[6],
    hardware_type="ASIM",
    serial_number="L1243005540",
)

_SBTS_airscale = Airscale(common_units=[_SBTS_SMOD1, _SBTS_SMOD2])

# RUs

_SBTS_AHLOB_11 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu3_2005.pdu_ports[4],
    radio_type="AHLOB",
    serial_number="AH251003025",
    attenuation_ports=[
        _rf_att_1.attenuator_ports[1],
        _rf_att_1.attenuator_ports[2],
        _rf_att_1.attenuator_ports[3],
        _rf_att_1.attenuator_ports[4],
    ],
)

_SBTS_AHLOB_12 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu3_2005.pdu_ports[1],
    radio_type="AHLOB",
    serial_number="AH251003054",
    attenuation_ports=[
        _rf_att_1.attenuator_ports[5],
        _rf_att_1.attenuator_ports[6],
        _rf_att_1.attenuator_ports[7],
        _rf_att_1.attenuator_ports[8],
    ],
)

_SBTS_AHLOB_10 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu2_2005.pdu_ports[7],
    radio_type="AHLOB",
    serial_number="AH251003034",
    attenuation_ports=[
        _rf_att_2.attenuator_ports[13],
        _rf_att_2.attenuator_ports[14],
        _rf_att_2.attenuator_ports[15],
        _rf_att_2.attenuator_ports[16],
    ],
)

_SBTS_AHVA_12 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu2_2004.pdu_ports[2],
    radio_type="AHVA",
    serial_number="L1251205197",
    attenuation_ports=[
        _rf_att_1.attenuator_ports[9],
        _rf_att_1.attenuator_ports[10],
        _rf_att_1.attenuator_ports[11],
        _rf_att_1.attenuator_ports[12],
    ],
)

_SBTS_AHVA_08 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu2_2004.pdu_ports[5],
    radio_type="AHVA",
    serial_number="L1251205198",
    attenuation_ports=[
        _rf_att_1.attenuator_ports[13],
        _rf_att_1.attenuator_ports[14],
        _rf_att_1.attenuator_ports[15],
        _rf_att_1.attenuator_ports[16],
    ],
)

_SBTS_AHVA_09 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu3_2004.pdu_ports[1],
    radio_type="AHVA",
    serial_number="L1251205199",
    attenuation_ports=[
        _rf_att_1.attenuator_ports[17],
        _rf_att_1.attenuator_ports[18],
        _rf_att_1.attenuator_ports[19],
        _rf_att_1.attenuator_ports[20],
    ],
)

_SBTS_AHFII_40 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu3_2005.pdu_ports[3],
    radio_type="AHFII",
    serial_number="K9245120723",
    attenuation_ports=[
        _rf_att_1.attenuator_ports[21],
        _rf_att_1.attenuator_ports[22],
        _rf_att_1.attenuator_ports[23],
        _rf_att_1.attenuator_ports[24],
    ],
)

_SBTS_AHFII_39 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu2_2005.pdu_ports[10],
    radio_type="AHFII",
    serial_number="K9245135266",
    attenuation_ports=[
        _rf_att_1.attenuator_ports[25],
        _rf_att_1.attenuator_ports[26],
        _rf_att_1.attenuator_ports[27],
        _rf_att_1.attenuator_ports[28],
    ],
)

_SBTS_AHFII_38 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu2_2005.pdu_ports[7],
    radio_type="AHFIB",
    serial_number="K9250263186",
    attenuation_ports=[
        _rf_att_1.attenuator_ports[29],
        _rf_att_1.attenuator_ports[30],
        _rf_att_1.attenuator_ports[31],
        _rf_att_1.attenuator_ports[32],
    ],
)

_SBTS_AVQQA_08 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu1_2004.pdu_ports[10],
    radio_type="AVQQA",
    serial_number="L1244206846",
    attenuation_ports=[
        _rf_att_2.attenuator_ports[1],
        _rf_att_2.attenuator_ports[2],
        _rf_att_2.attenuator_ports[3],
        _rf_att_2.attenuator_ports[4],
    ],
)

_SBTS_AVQQA_07 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu2_2004.pdu_ports[3],
    radio_type="AVQQA",
    serial_number="L1244206849",
    attenuation_ports=[
        _rf_att_2.attenuator_ports[5],
        _rf_att_2.attenuator_ports[6],
        _rf_att_2.attenuator_ports[7],
        _rf_att_2.attenuator_ports[8],
    ],
)

_SBTS_AVQQA_10 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu2_2004.pdu_ports[6],
    radio_type="AVQQA",
    serial_number="L1244206847",
    attenuation_ports=[
        _rf_att_2.attenuator_ports[9],
        _rf_att_2.attenuator_ports[10],
        _rf_att_2.attenuator_ports[11],
        _rf_att_2.attenuator_ports[12],
    ],
)

_SBTS_du = DU(
    airscale=_SBTS_airscale,
    rus=[
        _SBTS_AHLOB_11,
        _SBTS_AHLOB_12,
        _SBTS_AHLOB_10,
        _SBTS_AHVA_12,
        _SBTS_AHVA_08,
        _SBTS_AHVA_09,
        _SBTS_AHFII_40,
        _SBTS_AHFII_39,
        _SBTS_AHFII_38,
        _SBTS_AVQQA_08,
        _SBTS_AVQQA_07,
        _SBTS_AVQQA_10,
    ],
)
_SBTS_1 = ClassicalBts(cu=_SBTS_cu, dus=[_SBTS_du])

# ---------------- END sbts-1 --------------------------

# ---------------- START gnb-2 ------------------------

_gNB_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.221.213",
        routing_v4=RoutingInformation(
            gateway="10.47.221.222", destIpAddr="10.47.221.208/28"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.221.213", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.221.213", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.221.214"),
    x2u=NetworkAddress(v4="10.47.221.215"),
    s1u=NetworkAddress(v4="10.47.221.215"),
)

_gNB_BBMOD1 = CapacityUnit(
    addr="192.168.253.2",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1242304265",
)

_gNB_BBMOD2 = CapacityUnit(
    # ip to be update
    addr="192.168.253.26",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1242304290",
)

_gNB_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB_BBMOD1, _gNB_BBMOD2],
    pdu_port=_comu_pdu1.pdu_ports[7],
    hardware_type="ASIM",
    serial_number="L1243102019",
)

_gNB_airscale = Airscale(common_units=[_gNB_comu])

_gNB_AHFII_37 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu2_2005.pdu_ports[4],
    radio_type="AHFII",
    serial_number="K9245135211",
    attenuation_ports=[
        _rf_att_2.attenuator_ports[17],
        _rf_att_2.attenuator_ports[18],
        _rf_att_2.attenuator_ports[19],
        _rf_att_2.attenuator_ports[20],
    ],
)

_gNB_AHLOB_05 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu2_2005.pdu_ports[5],
    radio_type="AHLOB",
    serial_number="K9245135211",
    attenuation_ports=[
        _rf_att_2.attenuator_ports[21],
        _rf_att_2.attenuator_ports[22],
        _rf_att_2.attenuator_ports[23],
        _rf_att_2.attenuator_ports[24],
    ],
)

_gNB_AZQW_23 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu3_2005.pdu_ports[5],
    radio_type="AZQW",
    attenuation_ports=[
        _rf_att_2.attenuator_ports[25],
        _rf_att_2.attenuator_ports[26],
        _rf_att_2.attenuator_ports[27],
        _rf_att_2.attenuator_ports[28],
    ],
)

_gNB_AKQJ_39 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu4_2005.pdu_ports[4],
    radio_type="AKQJ",
    attenuation_ports=[
        _rf_att_2.attenuator_ports[29],
        _rf_att_2.attenuator_ports[30],
        _rf_att_2.attenuator_ports[31],
        _rf_att_2.attenuator_ports[32],
    ],
)


_gNB_du = DU(
    airscale=_gNB_airscale,
    rus=[
        _gNB_AHFII_37,
        _gNB_AHLOB_05,
        _gNB_AZQW_23,
        _gNB_AKQJ_39,
    ],
)

_gNB_2 = ClassicalBts(cu=_gNB_cu, dus=[_gNB_du])

# ---------------- END gnb-2 ------------------------

# ---------------- START eNB-1 ----------------------

_airscale_Common = Airscale(common_units=[_SBTS_SMOD1])

_SBTS_eNB = RealEnb(
    system_module=_airscale_Common,
    rms=[
        _SBTS_AHLOB_11,
        _SBTS_AHLOB_12,
        _SBTS_AHLOB_10,
        _SBTS_AHFII_40,
        _SBTS_AHFII_39,
        _SBTS_AHFII_38,
    ],
    oam_ip=NetworkAddress(v4="10.47.221.209"),
)

# ---------------- END SBTS395_eNB ------------------------

# ---------------- START Core APP Server ----------------- #

_app_server_1 = TafUeAppServer(
    app_server_name="DEUL5Gappsrv36",
    address="10.47.194.206",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.206",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, version=2
)

# ---------------- END Core APP Server ------------------- #

# ---------------- START QC UE1: Qualcomm #75 SDX85 ---------------------- #
_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.135.150", username="deul5g", password="Nuc2Ue4PzLab!"
)

###Qualcomm#75 SDX85
_Qualcomm_SDX85 = TafUeAndroid(
    serial_number="186e60da",
    ue_pc_address="10.46.135.150",
    capabilities=[
        "REAL_UE",
        "REAL_ANDROID_UE",
        "REAL_QUALCOMM_UE",
        "UE1",
        "UE_1",
        "X80",
    ],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.46.135.150", username="deul5g", password="Nuc2Ue4PzLab!"
    ),
    ue_pc_port="8080",
)
# ---------------- END QC UE1: Qualcomm #75 SDX85 ------------------------ #

# ---------------- START MTK UE2: MTK #72 M90 --------------------------- #
_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.135.157", username="deul5g", password="Nuc2Ue4PzLab!"
)

###Mediatek#72 M90
_Mediatek_M90 = TafUeAndroid(
    serial_number="0123456789ABCDEF",
    ue_pc_address="10.46.135.157",
    capabilities=["REAL_UE", "REAL_MTK", "UE2", "UE_2", "MTK"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.46.135.157", username="deul5g", password="Nuc2Ue4PzLab!"
    ),
    ue_pc_port="1234",
)
# ---------------- END QC UE2: MTK #56 M80 Dujac ------------------------ #


_core_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.47.194.206", username="ute", password="UTE.debian12"
    ),
    network_interface_address="10.47.194.206",
    iperf_path="/usr/bin/iperf",
    ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254],
)

_appserver = AppServer(iperf_details=_core_iperf)

# ---------------- TEST PC ---------------------------Tl393

_testpc1_ssh = SshServiceDetails(
    addr="10.47.12.224", username="ute", password="UTE.debian12"
)
_testpc1 = TestPc(default_ssh_connection_details=_testpc1_ssh, connections=[_SBTS_1])

_testpc3_ssh = SshServiceDetails(
    addr="10.47.12.24", username="ute", password="UTE.debian12"
)
_testpc3 = TestPc(default_ssh_connection_details=_testpc3_ssh, connections=[_gNB_2])

# ---------------- END TEST PC -----------------------

tl = TestLine(
    test_pc=_testpc1,
    test_pcs=[_testpc1, _testpc3],
    gnbs=[_SBTS_1, _gNB_2],
    enbs=[],
    #    enbs=[_SBTS_eNB],
    pdus=[
        _comu_pdu1,
        _rf_pdu1_2004,
        _rf_pdu2_2004,
        _rf_pdu3_2004,
        _rf_pdu2_2005,
        _rf_pdu3_2005,
        _rf_pdu4_2005,
    ],
    core=_tampereCore,
    ues=[_Qualcomm_SDX85, _Mediatek_M90],
    appserver=_appserver,
    attenuators=[_rf_att_1, _rf_att_2],
    tl_cloud_topology="CLASSICAL_5G",
)

__all__ = ["tl"]
