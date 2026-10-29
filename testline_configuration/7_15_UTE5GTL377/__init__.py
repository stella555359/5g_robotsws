######################################
#  TestLine 377 Ulm (7_15_UTE5GTL377)#
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
from taf.config.testline.ue import TafUeAndroid, TafUeMtk

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_snmp_user_data = dict(
    userName="user",
    authKey="qwer2009!",
    privKey="qwer2009!",
    authProtocol="SHA",
    privProtocol="AES",
)

_pdu1_341 = Gude(
    addr="10.46.134.251",
    port_numbers=[2],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_pdu1_362 = Gude(
    addr="10.46.134.242",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 9, 10],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_pdu1_380 = Gude(
    addr="10.46.134.80",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 10],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_pdu1_381 = Gude(
    addr="10.46.134.81",
    port_numbers=[1, 2, 3, 4, 7],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

# ---------------- START ATTENUATIORS -----------------------------
_gNB377_rf_att_1 = HBTE(
    ip_addr="10.46.134.159",
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

_gNB377_rf_att_2 = HBTE(
    ip_addr="10.46.134.160",
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

# ---------------- START gnb-1 ------------------------ gnb_377-1
_gNB377_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.206.2",
        routing_v4=RoutingInformation(
            gateway="10.47.206.14", destIpAddr="10.47.206.0/28"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.206.2", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.206.2", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.206.3"),
    x2u=NetworkAddress(v4="10.47.206.4"),
    s1u=NetworkAddress(v4="10.47.206.4"),
)

_gNB377_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIO")
_gNB377_capu2 = CapacityUnit(addr="192.168.253.24", hardware_type="ABIO")
_gNB377_capu3 = CapacityUnit(addr="192.168.253.28", hardware_type="ABIO")

_gNB377_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB377_capu1,_gNB377_capu2,_gNB377_capu3],
    pdu_port=_pdu1_362.pdu_ports[3],
    hardware_type="ASIM",
)

_gNB377_airscale = Airscale(common_units=[_gNB377_comu])

_gNB377_rm_AHFII_24 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_381.pdu_ports[2],
    radio_type="AHFII",
    attenuation_ports=[
        _gNB377_rf_att_1.attenuator_ports[1],
        _gNB377_rf_att_1.attenuator_ports[2],
        _gNB377_rf_att_1.attenuator_ports[3],
        _gNB377_rf_att_1.attenuator_ports[4],
    ],
)

_gNB377_rm_AHFII_19 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_381.pdu_ports[4],
    radio_type="AHFII",
    attenuation_ports=[
        _gNB377_rf_att_1.attenuator_ports[5],
        _gNB377_rf_att_1.attenuator_ports[6],
        _gNB377_rf_att_1.attenuator_ports[7],
        _gNB377_rf_att_1.attenuator_ports[8],
    ],
)

_gNB377_rm_AHFII_21 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_381.pdu_ports[7],
    radio_type="AHFII",
    attenuation_ports=[
        _gNB377_rf_att_1.attenuator_ports[9],
        _gNB377_rf_att_1.attenuator_ports[10],
        _gNB377_rf_att_1.attenuator_ports[11],
        _gNB377_rf_att_1.attenuator_ports[12],
    ],
)

_gNB377_rm_AHLOA_23 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_380.pdu_ports[6],
    radio_type="AHLOA",
    attenuation_ports=[
        _gNB377_rf_att_1.attenuator_ports[13],
        _gNB377_rf_att_1.attenuator_ports[14],
    ],
)

_gNB377_rm_AHCA_13 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_341.pdu_ports[2],
    radio_type="AHCA",
    attenuation_ports=[
        _gNB377_rf_att_1.attenuator_ports[15],
        _gNB377_rf_att_1.attenuator_ports[16],
    ],
)

_gNB377_rm_AZQI_06 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_380.pdu_ports[1],
    radio_type="AZQI",
    attenuation_ports=[
        _gNB377_rf_att_1.attenuator_ports[17],
        _gNB377_rf_att_1.attenuator_ports[18],
        _gNB377_rf_att_1.attenuator_ports[17],
        _gNB377_rf_att_1.attenuator_ports[18],
        _gNB377_rf_att_1.attenuator_ports[19],
        _gNB377_rf_att_1.attenuator_ports[20],
    ],
)

_gNB377_rm_AZQI_01 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_380.pdu_ports[2],
    radio_type="AZQI",
    attenuation_ports=[
        _gNB377_rf_att_1.attenuator_ports[21],
        _gNB377_rf_att_1.attenuator_ports[21],
        _gNB377_rf_att_1.attenuator_ports[21],
        _gNB377_rf_att_1.attenuator_ports[21],
        _gNB377_rf_att_1.attenuator_ports[22],
    ],
)

_gNB377_rm_AZQI_02 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_380.pdu_ports[3],
    radio_type="AZQI",
    attenuation_ports=[
        _gNB377_rf_att_1.attenuator_ports[25],
        _gNB377_rf_att_1.attenuator_ports[26],
        _gNB377_rf_att_1.attenuator_ports[25],
        _gNB377_rf_att_1.attenuator_ports[26],
        _gNB377_rf_att_1.attenuator_ports[27],
        _gNB377_rf_att_1.attenuator_ports[28],
    ],
)

_gNB377_rm_AZQW_11 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_380.pdu_ports[4],
    radio_type="AZQW",
    attenuation_ports=[
        _gNB377_rf_att_1.attenuator_ports[29],
        _gNB377_rf_att_1.attenuator_ports[30],
        _gNB377_rf_att_1.attenuator_ports[29],
        _gNB377_rf_att_1.attenuator_ports[30],
        _gNB377_rf_att_1.attenuator_ports[31],
        _gNB377_rf_att_1.attenuator_ports[32],
    ],
)

_gNB377_du = DU(
    airscale=_gNB377_airscale,
    rus=[
        _gNB377_rm_AHFII_24,
        _gNB377_rm_AHFII_19,
        _gNB377_rm_AHFII_21,
        _gNB377_rm_AHLOA_23,
        _gNB377_rm_AHCA_13,
        _gNB377_rm_AZQI_06,
        _gNB377_rm_AZQI_01,
        _gNB377_rm_AZQI_02,
        _gNB377_rm_AZQW_11,
    ],
)

_gNB377 = ClassicalBts(cu=_gNB377_cu, dus=[_gNB377_du])
# ---------------- END gnb-1 ------------------------

# ---------------- START gnb-2 ------------------------ gnb_378
_gNB378_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.206.7",
        routing_v4=RoutingInformation(
            gateway="10.47.206.14", destIpAddr="10.47.206.0/28"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.206.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.206.7", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.206.8"),
    x2u=NetworkAddress(v4="10.47.206.9"),
    s1u=NetworkAddress(v4="10.47.206.9"),
)

_gNB378_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIO")

_gNB378_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB378_capu1],
    pdu_port=_pdu1_362.pdu_ports[5],
    hardware_type="ASIM",
)

_gNB378_airscale = Airscale(common_units=[_gNB378_comu])

_gNB378_rm_AHFII_16 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_381.pdu_ports[2],
    radio_type="AHFII",
    attenuation_ports=[
        _gNB377_rf_att_2.attenuator_ports[1],
        _gNB377_rf_att_2.attenuator_ports[2],
        _gNB377_rf_att_2.attenuator_ports[3],
        _gNB377_rf_att_2.attenuator_ports[4],
    ],
)

_gNB378_rm_AHLOA_49 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_380.pdu_ports[5],
    radio_type="AHLOA",
    attenuation_ports=[
        _gNB377_rf_att_1.attenuator_ports[5],
        _gNB377_rf_att_1.attenuator_ports[6],
    ],
)

_gNB378_rm_AZQW_01 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_380.pdu_ports[7],
    radio_type="AZQW",
    attenuation_ports=[
        _gNB377_rf_att_2.attenuator_ports[11],
        _gNB377_rf_att_2.attenuator_ports[12],
        _gNB377_rf_att_2.attenuator_ports[11],
        _gNB377_rf_att_2.attenuator_ports[12],
        _gNB377_rf_att_2.attenuator_ports[13],
        _gNB377_rf_att_2.attenuator_ports[14],
    ],
)

_gNB378_rm_AZQI_11 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_380.pdu_ports[10],
    radio_type="AZQI",
    attenuation_ports=[
        _gNB377_rf_att_2.attenuator_ports[7],
        _gNB377_rf_att_2.attenuator_ports[8],
        _gNB377_rf_att_2.attenuator_ports[7],
        _gNB377_rf_att_2.attenuator_ports[8],
        _gNB377_rf_att_2.attenuator_ports[9],
        _gNB377_rf_att_2.attenuator_ports[10],
    ],
)

_gNB378_du = DU(
    airscale=_gNB378_airscale,
    rus=[
        _gNB378_rm_AHFII_16,
        _gNB378_rm_AHLOA_49,
        _gNB378_rm_AZQW_01,
        _gNB378_rm_AZQI_11,
    ],
)

_gNB378 = ClassicalBts(cu=_gNB378_cu, dus=[_gNB378_du])
# ---------------- END gnb-2 ------------------------

# ---------------- START eNB-1 ------------------------ eNB_377
_eNB377_capu = CapacityUnit(addr="192.168.253.20")

_eNB377_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB377_capu],
    pdu_port=_pdu1_362.pdu_ports[4],
)

_eNB377_rm_50 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_362.pdu_ports[1],
    radio_type="FRHC",
    attenuation_ports=[
        _gNB377_rf_att_1.attenuator_ports[23],
        _gNB377_rf_att_1.attenuator_ports[24],
    ],
)

_eNB377_airscale = Airscale(common_units=[_eNB377_comu])

_eNB377 = RealEnb(
    system_module=_eNB377_airscale,
    rms=[
        _gNB377_rm_AHFII_24,
        _gNB377_rm_AHFII_19,
        _gNB377_rm_AHFII_21,
        _gNB377_rm_AHLOA_23,
        _gNB377_rm_AHCA_13,
        _eNB377_rm_50,
    ],
    oam_ip=NetworkAddress(v4="10.47.206.1"),
)
# ---------------- END eNB-1 ------------------------

# ---------------- START eNB-2 ------------------------ eNB_377-2
_eNB378_capu = CapacityUnit(addr="192.168.253.20")

_eNB378_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB378_capu],
    pdu_port=_pdu1_362.pdu_ports[6],
)

_eNB378_rm_50 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1_362.pdu_ports[2],
    radio_type="FRHC",
    attenuation_ports=[
        _gNB377_rf_att_2.attenuator_ports[15],
        _gNB377_rf_att_2.attenuator_ports[16],
    ],
)

_eNB378_airscale = Airscale(common_units=[_eNB378_comu])

_eNB378 = RealEnb(
    system_module=_eNB378_airscale,
    rms=[
        _gNB378_rm_AHFII_16,
        _gNB378_rm_AHLOA_49,
        _eNB378_rm_50,
    ],
    oam_ip=NetworkAddress(v4="10.47.206.6"),
)
# ---------------- END eNB-2 ------------------------

# ---------------- START Core APP Server ------------------- #
_app_server_33 = TafUeAppServer(
    app_server_name="DEUL5Gappsrv33",
    # address="10.47.194.233",
    # Not! address="DEUL5Gappsrv10.intra.noklab.net",
    address="DEUL5Gappsrv33.ulm.nsn-rdnet.net",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.233",
    #    binary_path="iperf",
    #    ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254]
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_33,
    interval=1,
    #    binary_path="/data/local/tmp/iperf",
    version=2,
    dt_from_uepc=True,
)
# ---------------- END Core APP Server ------------------- #

_pdns = [
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsa"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmcmgnsa"),
]

_tampereCore = RealCore(mcc="555", mnc="10", pdns=_pdns)

# ---------------- START QC UE1 ------------------------
_ue_ctrl_pc1_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC1-377.intra.noklab.net", username="deul5g", password="Nuc2Ue4PzLab!"
)

_qualcomm62_sdx75 = TafUeAndroid(
    serial_number="42513a3",
    # ue_pc_address="10.46.135.75",
    ue_pc_address="DEUL5GNUC1-377.intra.noklab.net",
    # proxy_mngr_port=9955,  # ueproxy manager will not be visible unless proxy_mngr_port is configured! (default value: 9955 - used in autostart)
    capabilities=[
        "REAL_UE",
        "REAL_ANDROID_UE",
        "REAL_QUALCOMM_UE",
        "UE_1",
        "UE1",
    ],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc1_ssh_details,
    ue_pc_port="8080",  # If proxy_mngr_port is defined in Ue object ue_pc_port will be omitted!
    pdu_port=_pdu1_362.pdu_ports[7],
)
# ---------------- END QC UE1 ------------------------

# ---------------- START MTK UE2: MTK #56 M80 Dujac using taf.ue.mtk ------------------------
_ue_ctrl_pc4_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC2-377.intra.noklab.net", username="deul5g", password="Nuc2Ue4PzLab!"
)

_mtk_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_33,
    interval=1,
    #    binary_path="/data/local/tmp/iperf",
    version=2,
)

_mtk57 = TafUeMtk(
    ue_pc_address="10.46.135.134",
    ue_pc_port=1234,
    serial_number="0123456789ABCDEF",
    data_transfer=[
        _mtk_data_transfer_iperf,
    ],
    com_port="auto",
    edb_file_path="auto",
    log_filter="2.Gen98_Default_Standard",
    imei="35190103413036",
    imsi="540017000001149",
    pdns=_pdns,
    default_pdn_name="ulmcmgnsa",
    capabilities=["REAL_UE", "REAL_MTK_UE", "MTK", "UE_57"],
)

# ---------------- START MTK UE2: MTK #57 M80 Dujac using taf.ue.android ---------------------- #
_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.135.134", username="deul5g", password="Nuc2Ue4PzLab!"
)

_mtk1 = TafUeAndroid(
    serial_number="0123456789ABCDEF",
    ue_pc_address="10.46.135.134",
    capabilities=["REAL_UE", "REAL_MTK", "UE_2", "UE2", "MTK"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.46.135.134", username="deul5g", password="Nuc2Ue4PzLab!"
    ),
    ue_pc_port="1234",
)
# ---------------- END MTK UE2: MTK #56 M80 Dujac ------------------------ #


# ---------------- START QC UE3 ------------------------
_ue_ctrl_pc2_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC1-378.intra.noklab.net", username="deul5g", password="Nuc2Ue4PzLab!"
)

_qualcomm57_sdx70 = TafUeAndroid(
    serial_number="a937b547",
    ue_pc_address="DEUL5GNUC1-378.intra.noklab.net",
    capabilities=[
        "REAL_UE",
        "REAL_ANDROID_UE",
        "REAL_QUALCOMM_UE",
        "UE_2",
    ],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc2_ssh_details,
    ue_pc_port="8080",
    pdu_port=_pdu1_362.pdu_ports[9],
)
# ---------------- END QC UE3 ------------------------

# ---------------- START QC UE4 ------------------------
_ue_ctrl_pc3_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC2-378.intra.noklab.net", username="deul5g", password="Nuc2Ue4PzLab!"
)

_qualcomm42_sdx65 = TafUeAndroid(
    serial_number="790b793f",
    ue_pc_address="DEUL5GNUC2-378.intra.noklab.net",
    capabilities=[
        "REAL_UE",
        "REAL_ANDROID_UE",
        "REAL_QUALCOMM_UE",
        "UE_3",
    ],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc3_ssh_details,
    ue_pc_port="8080",
    pdu_port=_pdu1_362.pdu_ports[10],
)
# ---------------- END QC UE4 ------------------------

# ---------------- Start TEST PCs --------------------
_gNB377_testpc_ssh = SshServiceDetails(
    addr="10.47.206.49", username="ute", password="UTE.debian12"
)
_gNB377_testpc = TestPc(
    default_ssh_connection_details=_gNB377_testpc_ssh, connections=[_gNB377]
)

_eNB377_testpc_ssh = SshServiceDetails(
    addr="10.47.206.50", username="ute", password="UTE.debian12"
)
_eNB377_testpc = TestPc(
    default_ssh_connection_details=_eNB377_testpc_ssh, connections=[_eNB377]
)

_gNB378_testpc_ssh = SshServiceDetails(
    addr="10.47.206.51", username="ute", password="UTE.debian12"
)
_gNB378_testpc = TestPc(
    default_ssh_connection_details=_gNB378_testpc_ssh, connections=[_gNB378]
)

_eNB378_testpc_ssh = SshServiceDetails(
    addr="10.47.206.52", username="ute", password="UTE.debian12"
)
_eNB378_testpc = TestPc(
    default_ssh_connection_details=_eNB378_testpc_ssh, connections=[_eNB378]
)
# --------------- END TEST PCs -----------------------

# ----- DEUL5Gappsrv33.ulm.nsn-rdnet.net ---
_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.47.194.233", username="ute", password="UTE.debian12"
    ),
    network_interface_address="10.47.194.233",
    iperf_path="iperf",
    # ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254],
)

_appserver = AppServer(_iperf_details_on_appserver)
# --------------- END

# ----------------------------------------- TL ----------------------------------------- #
tl = TestLine(
    test_pc=_gNB377_testpc,
    test_pcs=[_gNB377_testpc, _eNB377_testpc, _gNB378_testpc, _eNB378_testpc],
    gnbs=[_gNB377, _gNB378],
    enbs=[_eNB377, _eNB378],
    pdus=[
        _pdu1_341,
        _pdu1_362,
        _pdu1_380,
        _pdu1_381,
    ],
    core=_tampereCore,
    ues=[
        _qualcomm62_sdx75,
        _mtk1,
    ],
    attenuators=[_gNB377_rf_att_1, _gNB377_rf_att_2],
    appserver=_appserver,
    tl_cloud_topology="CLASSICAL_5G",
)

__all__ = ["tl"]
# ----------------------------------------- TL ----------------------------------------- #
