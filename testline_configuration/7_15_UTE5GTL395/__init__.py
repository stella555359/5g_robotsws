######################################
#  TestLine 395 Ulm                  #
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
    ip_addr="10.46.134.191",
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
    ip_addr="10.46.134.199",
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


# PDU1-371
_comu_pdu371 = Gude(
    addr="10.46.134.71",
    port_numbers=[3, 4, 5, 12],
    version="8221-1",
    snmp_user=_snmp_user_data,
)

# PDU1-381
_rf_pdu381 = Gude(
    addr="10.46.134.81",
    port_numbers=[9, 10, 12],
    version="8221-1",
    snmp_user=_snmp_user_data,
)

# PDU1-382
_rf_pdu382 = Gude(
    addr="10.46.134.82",
    port_numbers=[1, 3, 4, 6, 7],
    version="8221-1",
    snmp_user=_snmp_user_data,
)

# PDU1-339
_rf_pdu339 = Gude(
    addr="10.46.134.239",
    port_numbers=[9, 11, 12],
    version="8221-1",
    snmp_user=_snmp_user_data,
)

# PDU1-340
_rf_pdu340 = Gude(
    addr="10.46.134.240",
    port_numbers=[2, 6, 8],
    version="8221-1",
    snmp_user=_snmp_user_data,
)

# PDU1-378
_rf_pdu378 = Gude(
    addr="10.46.134.78",
    port_numbers=[1, 2],
    version="8221-1",
    snmp_user=_snmp_user_data,
)

# ---------------- START sbts-1 ------------------------

_SBTS395_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.207.81",
        routing_v4=RoutingInformation(
            gateway="10.47.207.94", destIpAddr="10.47.207.64/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.207.81", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.207.81", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.207.82"),
    x2u=NetworkAddress(v4="10.47.207.83"),
    s1u=NetworkAddress(v4="10.47.207.83"),
)

_SBTS395_BBMOD1 = CapacityUnit(
    addr="192.168.253.2",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1232105759",
)

_SBTS395_BBMOD2 = CapacityUnit(
    # ip to be update
    addr="192.168.253.26",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1232105745",
)

_SBTS395_BBMOD3 = CapacityUnit(
    # ip to be update
    addr="192.168.253.30",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1232105746",
)

_SBTS395_BBMOD4 = CapacityUnit(
    # ip to be update
    addr="192.168.253.30",
    hardware_type="ABIP",
    hardware_version="475266A.105",
    serial_number="L1232105754",
)


_SBTS395_SMOD1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_SBTS395_BBMOD1],
    pdu_port=_comu_pdu371.pdu_ports[3],
    hardware_type="ASIM",
    serial_number="L1243008961",
)

_SBTS395_SMOD2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_SBTS395_BBMOD2, _SBTS395_BBMOD3, _SBTS395_BBMOD4],
    pdu_port=_comu_pdu371.pdu_ports[4],
    hardware_type="ASIM",
    serial_number="L1243005540",
)

_SBTS395_airscale = Airscale(common_units=[_SBTS395_SMOD1, _SBTS395_SMOD2])

_SBTS395_AHLOB_13 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu381.pdu_ports[10],
    radio_type="AHLOB",
    serial_number="AH251003025",
    attenuation_ports=[
        _rf_att_1.attenuator_ports[1],
        _rf_att_1.attenuator_ports[2],
        _rf_att_1.attenuator_ports[3],
        _rf_att_1.attenuator_ports[4],
    ],
)

_SBTS395_AHLOB_16 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu382.pdu_ports[1],
    radio_type="AHLOB",
    serial_number="AH251003054",
    attenuation_ports=[
        _rf_att_1.attenuator_ports[5],
        _rf_att_1.attenuator_ports[6],
        _rf_att_1.attenuator_ports[7],
        _rf_att_1.attenuator_ports[8],
    ],
)

_SBTS395_AHLOB_14 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu382.pdu_ports[4],
    radio_type="AHLOB",
    serial_number="AH251003034",
    attenuation_ports=[
        _rf_att_2.attenuator_ports[13],
        _rf_att_2.attenuator_ports[14],
        _rf_att_2.attenuator_ports[15],
        _rf_att_2.attenuator_ports[16],
    ],
)

_SBTS395_AHVA_01 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu339.pdu_ports[11],
    radio_type="AHVA",
    serial_number="L1251205197",
    attenuation_ports=[
        _rf_att_1.attenuator_ports[9],
        _rf_att_1.attenuator_ports[10],
        _rf_att_1.attenuator_ports[11],
        _rf_att_1.attenuator_ports[12],
    ],
)

_SBTS395_AHVA_02 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu340.pdu_ports[2],
    radio_type="AHVA",
    serial_number="L1251205198",
    attenuation_ports=[
        _rf_att_1.attenuator_ports[13],
        _rf_att_1.attenuator_ports[14],
        _rf_att_1.attenuator_ports[15],
        _rf_att_1.attenuator_ports[16],
    ],
)

_SBTS395_AHVA_03 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu340.pdu_ports[8],
    radio_type="AHVA",
    serial_number="L1251205199",
    attenuation_ports=[
        _rf_att_1.attenuator_ports[17],
        _rf_att_1.attenuator_ports[18],
        _rf_att_1.attenuator_ports[19],
        _rf_att_1.attenuator_ports[20],
    ],
)

_SBTS395_AHFII_47 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu381.pdu_ports[9],
    radio_type="AHFII",
    serial_number="K9245120723",
    attenuation_ports=[
        _rf_att_1.attenuator_ports[21],
        _rf_att_1.attenuator_ports[22],
        _rf_att_1.attenuator_ports[23],
        _rf_att_1.attenuator_ports[24],
    ],
)

_SBTS395_AHFII_54 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu381.pdu_ports[12],
    radio_type="AHFII",
    serial_number="K9245135266",
    attenuation_ports=[
        _rf_att_1.attenuator_ports[25],
        _rf_att_1.attenuator_ports[26],
        _rf_att_1.attenuator_ports[27],
        _rf_att_1.attenuator_ports[28],
    ],
)

_SBTS395_AHFII_55 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu382.pdu_ports[3],
    radio_type="AHFIB",
    serial_number="K9250263186",
    attenuation_ports=[
        _rf_att_1.attenuator_ports[29],
        _rf_att_1.attenuator_ports[30],
        _rf_att_1.attenuator_ports[31],
        _rf_att_1.attenuator_ports[32],
    ],
)

_SBTS395_AVQQA_01 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu339.pdu_ports[9],
    radio_type="AVQQA",
    serial_number="L1244206846",
    attenuation_ports=[
        _rf_att_2.attenuator_ports[1],
        _rf_att_2.attenuator_ports[2],
        _rf_att_2.attenuator_ports[3],
        _rf_att_2.attenuator_ports[4],
    ],
)

_SBTS395_AVQQA_02 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu339.pdu_ports[12],
    radio_type="AVQQA",
    serial_number="L1244206849",
    attenuation_ports=[
        _rf_att_2.attenuator_ports[5],
        _rf_att_2.attenuator_ports[6],
        _rf_att_2.attenuator_ports[7],
        _rf_att_2.attenuator_ports[8],
    ],
)

_SBTS395_AVQQA_03 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu340.pdu_ports[6],
    radio_type="AVQQA",
    serial_number="L1244206847",
    attenuation_ports=[
        _rf_att_2.attenuator_ports[9],
        _rf_att_2.attenuator_ports[10],
        _rf_att_2.attenuator_ports[11],
        _rf_att_2.attenuator_ports[12],
    ],
)

_SBTS395_du = DU(
    airscale=_SBTS395_airscale,
    rus=[
        _SBTS395_AHLOB_13,
        _SBTS395_AHLOB_16,
        _SBTS395_AHLOB_14,
        _SBTS395_AHVA_01,
        _SBTS395_AHVA_02,
        _SBTS395_AHVA_03,
        _SBTS395_AHFII_47,
        _SBTS395_AHFII_54,
        _SBTS395_AHFII_55,
        _SBTS395_AVQQA_01,
        _SBTS395_AVQQA_02,
        _SBTS395_AVQQA_03,
    ],
)
_SBTS395_1 = ClassicalBts(cu=_SBTS395_cu, dus=[_SBTS395_du])

# ---------------- END sbts-1 --------------------------

# ---------------- START gnb-2 ------------------------

_gNB395_2_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.207.85",
        routing_v4=RoutingInformation(
            gateway="10.47.207.94", destIpAddr="10.47.207.64/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.207.85", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.207.85", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.207.86"),
    x2u=NetworkAddress(v4="10.47.207.87"),
    s1u=NetworkAddress(v4="10.47.207.87"),
)

_gNB395_2_BBMOD1 = CapacityUnit(
    addr="192.168.253.2",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1242304265",
)

_gNB395_2_BBMOD2 = CapacityUnit(
    # ip to be update
    addr="192.168.253.26",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1242304290",
)

_gNB395_2_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB395_2_BBMOD1, _gNB395_2_BBMOD2],
    pdu_port=_comu_pdu371.pdu_ports[5],
    hardware_type="ASIM",
    serial_number="L1243102019",
)

_gNB395_2_airscale = Airscale(common_units=[_gNB395_2_comu])

_gNB395_2_AHFII_53 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu382.pdu_ports[6],
    radio_type="AHFII",
    serial_number="K9245135211",
    attenuation_ports=[
        _rf_att_2.attenuator_ports[17],
        _rf_att_2.attenuator_ports[18],
        _rf_att_2.attenuator_ports[19],
        _rf_att_2.attenuator_ports[20],
    ],
)

_gNB395_2_AHLOB_15 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu382.pdu_ports[7],
    radio_type="AHLOB",
    serial_number="K9245135211",
    attenuation_ports=[
        _rf_att_2.attenuator_ports[21],
        _rf_att_2.attenuator_ports[22],
        _rf_att_2.attenuator_ports[23],
        _rf_att_2.attenuator_ports[24],
    ],
)

_gNB395_2_AZQW_20 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu378.pdu_ports[2],
    radio_type="AZQW",
    attenuation_ports=[
        _rf_att_2.attenuator_ports[25],
        _rf_att_2.attenuator_ports[26],
        _rf_att_2.attenuator_ports[27],
        _rf_att_2.attenuator_ports[28],
    ],
)

_gNB395_2_AKQJ_30 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu378.pdu_ports[1],
    radio_type="AKQJ",
    attenuation_ports=[
        _rf_att_2.attenuator_ports[29],
        _rf_att_2.attenuator_ports[30],
        _rf_att_2.attenuator_ports[31],
        _rf_att_2.attenuator_ports[32],
    ],
)


_gNB395_2_du = DU(
    airscale=_gNB395_2_airscale,
    rus=[
        _gNB395_2_AHFII_53,
        _gNB395_2_AHLOB_15,
        _gNB395_2_AZQW_20,
        _gNB395_2_AKQJ_30,
    ],
)

_gNB395_2 = ClassicalBts(cu=_gNB395_2_cu, dus=[_gNB395_2_du])

# ---------------- END gnb-2 ------------------------

# ---------------- START Core APP Server ----------------- #

_app_server_1 = TafUeAppServer(
    app_server_name="DEUL5Gappsrv36",
    address="10.47.194.236",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.236",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, version=2
)

# ---------------- END Core APP Server ------------------- #

# ---------------- START QC UE1: Qualcomm #73 SDX85 ---------------------- #
_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.135.126", username="deul5g", password="Nuc2Ue4PzLab!"
)

###Qualcomm#73 SDX85
_Qualcomm_SDX85_73 = TafUeAndroid(
    serial_number="b332da",
    ue_pc_address="10.46.135.126",
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
        addr="10.46.135.126", username="deul5g", password="Nuc2Ue4PzLab!"
    ),
    ue_pc_port="8080",
)
# ---------------- END QC UE1: Qualcomm #73 SDX85 ------------------------ #

# ---------------- START MTK UE2: MTK #69 M90 ---------------------- #
_ue_ctrl_pc2_ssh_details = SshServiceDetails(
    addr="10.46.135.127", username="deul5g", password="Nuc2Ue4PzLab!"
)

###Mediatek#69 M90
_Mediatek_M90_69 = TafUeAndroid(
    serial_number="0123456789ABCDEF",
    ue_pc_address="10.46.135.127",
    capabilities=["REAL_UE", "REAL_MTK", "UE2", "UE_2", "MTK", "APN_irat"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.46.135.127", username="deul5g", password="Nuc2Ue4PzLab!"
    ),
    ue_pc_port="1234",
)
# ---------------- END QC UE2: MTK #69 M90 ------------------------ #


_core_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.47.194.236", username="ute", password="ute"
    ),
    network_interface_address="10.47.194.236",
    iperf_path="/usr/bin/iperf",
    ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254],
)

_appserver = AppServer(iperf_details=_core_iperf)

# ---------------- TEST PC ---------------------------Tl393

_testpc1_ssh = SshServiceDetails(addr="10.47.207.101", username="ute", password="ute")
_testpc1 = TestPc(default_ssh_connection_details=_testpc1_ssh, connections=[_SBTS395_1])

_testpc3_ssh = SshServiceDetails(addr="10.47.207.103", username="ute", password="ute")
_testpc3 = TestPc(default_ssh_connection_details=_testpc3_ssh, connections=[_gNB395_2])


# ---------------- END TEST PC -----------------------

tl = TestLine(
    test_pc=_testpc1,
    test_pcs=[_testpc1, _testpc3],
    gnbs=[_SBTS395_1, _gNB395_2],
    enbs=[],
    pdus=[_comu_pdu371, _rf_pdu381, _rf_pdu382, _rf_pdu339, _rf_pdu340, _rf_pdu378],
    core=_tampereCore,
    ues=[_Qualcomm_SDX85_73, _Mediatek_M90_69],
    appserver=_appserver,
    attenuators=[_rf_att_1, _rf_att_2],
    tl_cloud_topology="CLASSICAL_5G",
)

__all__ = ["tl"]
