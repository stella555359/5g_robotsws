######################################
#  TestLine 375 Ulm (7_15_UTE5GTL375)#
######################################
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

_pdu1_336 = Gude(
    addr="10.46.134.236",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 9, 10],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_pdu1_337 = Gude(
    addr="10.46.134.237",
    port_numbers=[2, 3, 5, 7, 10],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_pdu1_338 = Gude(
    addr="10.46.134.238",
    port_numbers=[1, 2, 4, 5, 7, 8, 10, 11],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

# ---------------- START ATTENUATIORS -----------------------------
_gNB375_rf_att_1 = HBTE(
    ip_addr="10.46.134.186",
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

_gNB375_rf_att_2 = HBTE(
    ip_addr="10.46.134.180",
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
# ---------------- STOP ATTENUATORS -------------------

# ---------------- START gnb-1 ------------------------ gnb_375-1
_gNB375_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.205.201",
        routing_v4=RoutingInformation(
            gateway="10.47.205.222", destIpAddr="10.47.205.192/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.205.201", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.205.201", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.205.202"),
    x2u=NetworkAddress(v4="10.47.205.203"),
    s1u=NetworkAddress(v4="10.47.205.203"),
)

_gNB375_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIO")

_gNB375_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB375_capu1],
    pdu_port=_pdu1_336.pdu_ports[3],
    hardware_type="ASIM",
)

_gNB375_airscale = Airscale(common_units=[_gNB375_comu])

_gNB375_rm_AHFII_13 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_338.pdu_ports[11],
    radio_type="AHFII",
    attenuation_ports=[
        _gNB375_rf_att_1.attenuator_ports[1],
        _gNB375_rf_att_1.attenuator_ports[2],
        _gNB375_rf_att_1.attenuator_ports[3],
        _gNB375_rf_att_1.attenuator_ports[4],
    ],
)

_gNB375_rm_AHFII_14 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_338.pdu_ports[8],
    radio_type="AHFII",
    attenuation_ports=[
        _gNB375_rf_att_1.attenuator_ports[5],
        _gNB375_rf_att_1.attenuator_ports[6],
        _gNB375_rf_att_1.attenuator_ports[7],
        _gNB375_rf_att_1.attenuator_ports[8],
    ],
)

_gNB375_rm_AHFII_15 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_338.pdu_ports[5],
    radio_type="AHFII",
    attenuation_ports=[
        _gNB375_rf_att_1.attenuator_ports[9],
        _gNB375_rf_att_1.attenuator_ports[10],
        _gNB375_rf_att_1.attenuator_ports[11],
        _gNB375_rf_att_1.attenuator_ports[12],
    ],
)

_gNB375_rm_AHLOA_48 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_337.pdu_ports[2],
    radio_type="AHLOA",
    attenuation_ports=[
        _gNB375_rf_att_1.attenuator_ports[13],
        _gNB375_rf_att_1.attenuator_ports[14],
    ],
)

_gNB375_rm_AHCA_56 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_337.pdu_ports[3],
    radio_type="AHCA",
    attenuation_ports=[
        _gNB375_rf_att_1.attenuator_ports[15],
        _gNB375_rf_att_1.attenuator_ports[16],
    ],
)

_gNB375_rm_AZQI_08 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_338.pdu_ports[10],
    radio_type="AZQI",
    attenuation_ports=[
        _gNB375_rf_att_1.attenuator_ports[17],
        _gNB375_rf_att_1.attenuator_ports[18],
        _gNB375_rf_att_1.attenuator_ports[19],
        _gNB375_rf_att_1.attenuator_ports[20],
    ],
)

_gNB375_rm_AZQI_09 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_338.pdu_ports[7],
    radio_type="AZQI",
    attenuation_ports=[
        _gNB375_rf_att_1.attenuator_ports[21],
        _gNB375_rf_att_1.attenuator_ports[22],
    ],
)

_gNB375_rm_AZQI_10 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_338.pdu_ports[4],
    radio_type="AZQI",
    attenuation_ports=[
        _gNB375_rf_att_1.attenuator_ports[25],
        _gNB375_rf_att_1.attenuator_ports[26],
        _gNB375_rf_att_1.attenuator_ports[27],
        _gNB375_rf_att_1.attenuator_ports[28],
    ],
)

_gNB375_rm_AZQW_08 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_338.pdu_ports[1],
    radio_type="AZQW",
    attenuation_ports=[
        _gNB375_rf_att_1.attenuator_ports[29],
        _gNB375_rf_att_1.attenuator_ports[30],
        _gNB375_rf_att_1.attenuator_ports[31],
        _gNB375_rf_att_1.attenuator_ports[32],
    ],
)

_gNB375_du = DU(
    airscale=_gNB375_airscale,
    rus=[
        _gNB375_rm_AHFII_13,
        _gNB375_rm_AHFII_14,
        _gNB375_rm_AHFII_15,
        _gNB375_rm_AHLOA_48,
        _gNB375_rm_AHCA_56,
        _gNB375_rm_AZQI_08,
        _gNB375_rm_AZQI_09,
        _gNB375_rm_AZQI_10,
        _gNB375_rm_AZQW_08,
    ],
)

_gNB375 = ClassicalBts(cu=_gNB375_cu, dus=[_gNB375_du])
# ---------------- END gnb-1 ------------------------

# ---------------- START gnb-2 ------------------------ gnb_376
_gNB376_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.205.211",
        routing_v4=RoutingInformation(
            gateway="10.47.205.222", destIpAddr="10.47.205.192/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.205.211", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.205.211", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.205.212"),
    x2u=NetworkAddress(v4="10.47.205.213"),
    s1u=NetworkAddress(v4="10.47.205.213"),
)

_gNB376_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIO")

_gNB376_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB376_capu1],
    pdu_port=_pdu1_336.pdu_ports[5],
    hardware_type="ASIM",
)

_gNB376_airscale = Airscale(common_units=[_gNB376_comu])

_gNB376_rm_AHFII_16 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_338.pdu_ports[2],
    radio_type="AHFII",
    attenuation_ports=[
        _gNB375_rf_att_2.attenuator_ports[1],
        _gNB375_rf_att_2.attenuator_ports[2],
        _gNB375_rf_att_2.attenuator_ports[3],
        _gNB375_rf_att_2.attenuator_ports[4],
    ],
)

_gNB376_rm_AHLOA_49 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_337.pdu_ports[5],
    radio_type="AHLOA",
    attenuation_ports=[
        _gNB375_rf_att_1.attenuator_ports[5],
        _gNB375_rf_att_1.attenuator_ports[6],
    ],
)

_gNB376_rm_AZQI_11 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_337.pdu_ports[10],
    radio_type="AZQI",
    attenuation_ports=[
        _gNB375_rf_att_2.attenuator_ports[7],
        _gNB375_rf_att_2.attenuator_ports[8],
        _gNB375_rf_att_2.attenuator_ports[9],
        _gNB375_rf_att_2.attenuator_ports[10],
    ],
)

_gNB376_rm_AZQW_01 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_337.pdu_ports[7],
    radio_type="AZQW",
    attenuation_ports=[
        _gNB375_rf_att_2.attenuator_ports[11],
        _gNB375_rf_att_2.attenuator_ports[12],
        _gNB375_rf_att_2.attenuator_ports[13],
        _gNB375_rf_att_2.attenuator_ports[14],
    ],
)

_gNB376_du = DU(
    airscale=_gNB376_airscale,
    rus=[
        _gNB376_rm_AHFII_16,
        _gNB376_rm_AHLOA_49,
        _gNB376_rm_AZQI_11,
        _gNB376_rm_AZQW_01,
    ],
)

_gNB376 = ClassicalBts(cu=_gNB376_cu, dus=[_gNB376_du])
# ---------------- END gnb-2 ------------------------

# ---------------- START eNB-1 ------------------------ eNB_375
_eNB375_capu = CapacityUnit(addr="192.168.253.20")

_eNB375_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB375_capu],
    pdu_port=_pdu1_336.pdu_ports[4],
)

_eNB375_rm_50 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_336.pdu_ports[1],
    radio_type="FRHC",
    attenuation_ports=[
        _gNB375_rf_att_1.attenuator_ports[23],
        _gNB375_rf_att_1.attenuator_ports[24],
    ],
)

_eNB375_airscale = Airscale(common_units=[_eNB375_comu])

_eNB375 = RealEnb(
    system_module=_eNB375_airscale,
    rms=[
        _gNB375_rm_AHFII_13,
        _gNB375_rm_AHFII_14,
        _gNB375_rm_AHFII_15,
        _gNB375_rm_AHLOA_48,
        _gNB375_rm_AHCA_56,
        _eNB375_rm_50,
    ],
    oam_ip=NetworkAddress(v4="10.47.205.200"),
)
# ---------------- END eNB-1 ------------------------

# ---------------- START eNB-2 ------------------------ eNB_375-2
_eNB376_capu = CapacityUnit(addr="192.168.253.20")

_eNB376_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB376_capu],
    pdu_port=_pdu1_336.pdu_ports[6],
)

_eNB376_rm_50 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_336.pdu_ports[2],
    radio_type="FRHC",
    attenuation_ports=[
        _gNB375_rf_att_2.attenuator_ports[15],
        _gNB375_rf_att_2.attenuator_ports[16],
    ],
)

_eNB376_airscale = Airscale(common_units=[_eNB376_comu])

_eNB376 = RealEnb(
    system_module=_eNB376_airscale,
    rms=[_eNB376_rm_50],
    oam_ip=NetworkAddress(v4="10.47.205.210"),
)
# ---------------- END eNB-2 ------------------------

# ---------------- START Core APP Server ------------------- #
_app_server_39 = TafUeAppServer(
    app_server_name="DEUL5Gappsrv39",
    # address="10.47.194.239",
    # Not! address="DEUL5Gappsrv10.intra.noklab.net",
    address="DEUL5Gappsrv39.ulm.nsn-rdnet.net",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.239",
    #    binary_path="iperf",
    #    ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254]
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_39,
    interval=1,
    #    binary_path="/data/local/tmp/iperf",
    version=3,
    dt_from_uepc=True,
)
# ---------------- END Core APP Server ------------------- #

_pdns = [
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsa"),
]

_tampereCore = RealCore(mcc="555", mnc="10", pdns=_pdns)

# ---------------- START QC UE1 ------------------------
_ue_ctrl_pc1_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC1-375.intra.noklab.net", username="deul5g", password="Nuc2Ue4PzLab!"
)

_qualcomm63_sdx75 = TafUeAndroid(
    serial_number="c42ec35a",
    # ue_pc_address="10.46.135.75",
    ue_pc_address="DEUL5GNUC1-375.intra.noklab.net",
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
    pdu_port=_pdu1_336.pdu_ports[7],
)
# ---------------- END QC UE1 ------------------------

# ---------------- START QC UE2 ------------------------
_ue_ctrl_pc2_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC1-376.intra.noklab.net", username="deul5g", password="Nuc2Ue4PzLab!"
)

_qualcomm53_sdx70 = TafUeAndroid(
    serial_number="a937b547",
    ue_pc_address="DEUL5GNUC1-376.intra.noklab.net",
    capabilities=[
        "REAL_UE",
        "REAL_ANDROID_UE",
        "REAL_QUALCOMM_UE",
        "UE_2",
    ],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc2_ssh_details,
    ue_pc_port="8080",
    pdu_port=_pdu1_336.pdu_ports[9],
)
# ---------------- END QC UE2 ------------------------

# ---------------- START QC UE3 ------------------------
_ue_ctrl_pc3_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC2-375.intra.noklab.net", username="deul5g", password="Nuc2Ue4PzLab!"
)

_qualcomm47_sdx65 = TafUeAndroid(
    serial_number="790b793f",
    ue_pc_address="DEUL5GNUC2-375.intra.noklab.net",
    capabilities=[
        "REAL_UE",
        "REAL_ANDROID_UE",
        "REAL_QUALCOMM_UE",
        "UE_3",
    ],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc3_ssh_details,
    ue_pc_port="8080",
    pdu_port=_pdu1_336.pdu_ports[10],
)
# ---------------- END QC UE3 ------------------------

# ---------------- START MTK UE4 ------------------------
_ue_ctrl_pc4_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC2-376.intra.noklab.net", username="deul5g", password="Nuc2Ue4PzLab!"
)

_mtk_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_39,
    interval=1,
    #    binary_path="/data/local/tmp/iperf",
    version=3,
    dt_from_uepc=True,
)

# _mtk55 = TafUeMtk(
#    ue_pc_address="10.46.135.54",
#    ue_pc_port=1234,
#    serial_number="0123456789ABCDEF",
#    data_transfer=[
#        _mtk_data_transfer_iperf,
#    ],
#    com_port="auto",
#    edb_file_path="auto",
#    log_filter="2.Gen98_Default_Standard",
#    imei="35190103413004",  # needs to be updated
#    imsi="540017000001125",  # needs to be updated
#    pdns=_pdns,
#    default_pdn_name="ulmsa",
#    capabilities=["REAL_UE", "REAL_MTK_UE", "UE_1"],
# )

_mtk55 = TafUeAndroid(
    serial_number="0123456789ABCDEF",
    ue_pc_address="10.46.135.54",
    capabilities=[
        "REAL_UE",
        "REAL_MTK_UE",
        "UE_4",
    ],
    data_transfer=[_mtk_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc4_ssh_details,
    ue_pc_port="1234",
)
# ---------------- END MTK UE4 ------------------------

# ---------------- Start TEST PCs --------------------
_gNB375_testpc_ssh = SshServiceDetails(
    addr="7-15-UTE5GTL375-1.ulm.nsn-rdnet.net", username="ute", password="UTE.debian12"
)
_gNB375_testpc = TestPc(
    default_ssh_connection_details=_gNB375_testpc_ssh, connections=[_gNB375]
)

_eNB375_testpc_ssh = SshServiceDetails(
    addr="7-15-UTE5GTL375-2.ulm.nsn-rdnet.net", username="ute", password="UTE.debian12"
)
_eNB375_testpc = TestPc(
    default_ssh_connection_details=_eNB375_testpc_ssh, connections=[_eNB375]
)

_gNB376_testpc_ssh = SshServiceDetails(
    addr="7-15-UTE5GTL376-1.ulm.nsn-rdnet.net", username="ute", password="UTE.debian12"
)
_gNB376_testpc = TestPc(
    default_ssh_connection_details=_gNB376_testpc_ssh, connections=[_gNB376]
)

_eNB376_testpc_ssh = SshServiceDetails(
    addr="7-15-UTE5GTL376-2.ulm.nsn-rdnet.net", username="ute", password="UTE.debian12"
)
_eNB376_testpc = TestPc(
    default_ssh_connection_details=_eNB376_testpc_ssh, connections=[_eNB376]
)
# --------------- END TEST PCs -----------------------

# ----- DEUL5Gappsrv39.ulm.nsn-rdnet.net ---
_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.47.194.239", username="ute", password="ute"
    ),
    network_interface_address="10.47.194.239",
    iperf_path="iperf",
    # ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254],
)

_appserver = AppServer(_iperf_details_on_appserver)
# --------------- END

# ----------------------------------------- TL ----------------------------------------- #
tl = TestLine(
    test_pc=_gNB375_testpc,
    test_pcs=[_gNB375_testpc, _eNB375_testpc, _gNB376_testpc, _eNB376_testpc],
    gnbs=[_gNB375, _gNB376],
    enbs=[_eNB375, _eNB376],
    pdus=[
        _pdu1_336,
        _pdu1_337,
        _pdu1_338,
    ],
    core=_tampereCore,
    ues=[_qualcomm63_sdx75, _qualcomm53_sdx70, _qualcomm47_sdx65],
    # ues=[_qualcomm63_sdx75, _qualcomm53_sdx70, _qualcomm47_sdx65, _mtk55],
    attenuators=[_gNB375_rf_att_1, _gNB375_rf_att_2],
    appserver=_appserver,
    tl_cloud_topology="CLASSICAL_5G",
)

__all__ = ["tl"]
# ----------------------------------------- TL ----------------------------------------- #
