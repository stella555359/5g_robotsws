######################################
#  TestLine 381 Ulm                  #
######################################
__maintainer__ = "MN ECE ULM R&D L3NRT 07 SqdGp63"
__team__ = "MN 5G&SC PZ ULM 2 SqdGp63"
__email__ = "I_MN_5GSC_PZ_ULM_SQD_63@nokia.com"

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
from taf.config.testline.core import RealCore4G
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.attenuator import HBTE
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid


_tampereCore = RealCore4G(mcc="555", mnc="10")

_rf_att = HBTE(
    ip_addr="10.46.134.193",
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

_comu_pdu = Gude(
    addr="10.46.134.73",
    port_numbers=[1, 2, 3, 4, 5, 6, 9, 10, 11, 12],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# ---------------- START gnb-1 ------------------------ gnb_381-1

_gNB381_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.207.131",
        routing_v4=RoutingInformation(
            gateway="10.47.207.158", destIpAddr="10.47.207.128/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.207.131", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.207.131", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.207.132"),
    x2u=NetworkAddress(v4="10.47.207.133"),
    s1u=NetworkAddress(v4="10.47.207.133"),
)

_gNB381_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[CapacityUnit(addr="")],
    pdu_port=_comu_pdu.pdu_ports[6],
    hardware_type="ASOE",
)

_gNB381_airscale = Airscale(common_units=[_gNB381_comu])

_gNB381_rf_pdu1 = Gude(
    addr="10.46.134.77",
    port_numbers=[7, 8],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_gNB381_rf_pdu2 = Gude(
    addr="10.46.134.79",
    port_numbers=[11, 12],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# _gNB381_rf_pdu3 = Gude(addr="10.46.134.80", port_numbers=[5, 6], version="8221-1")

_gNB381_rf_pdu4 = Gude(
    addr="10.46.134.84",
    port_numbers=[1, 2, 4, 5],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_gNB381_rm_47 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB381_rf_pdu1.pdu_ports[8],
    radio_type="AHFIB",
    attenuation_ports=[
        _rf_att.attenuator_ports[1],
        _rf_att.attenuator_ports[2],
        _rf_att.attenuator_ports[3],
        _rf_att.attenuator_ports[4],
    ],
)

_gNB381_rm_77 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB381_rf_pdu4.pdu_ports[1],
    radio_type="AHFIB",
    attenuation_ports=[
        _rf_att.attenuator_ports[5],
        _rf_att.attenuator_ports[6],
        _rf_att.attenuator_ports[7],
        _rf_att.attenuator_ports[8],
    ],
)

_gNB381_rm_06 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB381_rf_pdu4.pdu_ports[4],
    radio_type="AHFIB",
    attenuation_ports=[
        _rf_att.attenuator_ports[9],
        _rf_att.attenuator_ports[10],
        _rf_att.attenuator_ports[11],
        _rf_att.attenuator_ports[12],
    ],
)

_gNB381_rm_61 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB381_rf_pdu2.pdu_ports[11],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att.attenuator_ports[13],
        _rf_att.attenuator_ports[14],
        _rf_att.attenuator_ports[15],
        _rf_att.attenuator_ports[16],
    ],
)

_gNB381_rm_64 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB381_rf_pdu4.pdu_ports[2],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att.attenuator_ports[17],
        _rf_att.attenuator_ports[18],
        _rf_att.attenuator_ports[19],
        _rf_att.attenuator_ports[20],
    ],
)

_gNB381_rm_65 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB381_rf_pdu4.pdu_ports[5],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att.attenuator_ports[21],
        _rf_att.attenuator_ports[22],
        _rf_att.attenuator_ports[23],
        _rf_att.attenuator_ports[24],
    ],
)

_gNB381_du = DU(
    airscale=_gNB381_airscale,
    rus=[
        _gNB381_rm_47,
        _gNB381_rm_77,
        _gNB381_rm_06,
        _gNB381_rm_61,
        _gNB381_rm_64,
        _gNB381_rm_65,
    ],
)

_gNB381 = ClassicalBts(cu=_gNB381_cu, dus=[_gNB381_du])

# ---------------- END gnb-1 ------------------------

# ---------------- START eNB-1 ------------------------ eNB_381

_eNB381_capu = CapacityUnit(addr="192.168.253.20")

_eNB381_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB381_capu],
    pdu_port=_comu_pdu.pdu_ports[3],
)

_eNB381_rm = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_comu_pdu.pdu_ports[1],
    radio_type="FRHC",
)

_eNB381_airscale = Airscale(common_units=[_eNB381_comu])

_eNB381 = RealEnb(
    system_module=_eNB381_airscale,
    rms=[_eNB381_rm],
    oam_ip=NetworkAddress(v4="10.47.207.130"),
)

# ---------------- END eNB-1 ------------------------

# ---------------- START gnb-2 ------------------------ gnb_381-2

_gNB381_2_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.207.135",
        routing_v4=RoutingInformation(
            gateway="10.47.207.158", destIpAddr="10.47.207.128/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.207.135", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.207.135", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="110.47.207.136"),
    x2u=NetworkAddress(v4="10.47.207.137"),
    s1u=NetworkAddress(v4="10.47.207.137"),
)

_gNB381_2_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[CapacityUnit(addr="")],
    pdu_port=_comu_pdu.pdu_ports[5],
    hardware_type="ASOE",
)

_gNB381_airscale = Airscale(common_units=[_gNB381_2_comu])

_gNB381_2_rm_46 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB381_rf_pdu1.pdu_ports[7],
    radio_type="AHFIB",
    attenuation_ports=[
        _rf_att.attenuator_ports[25],
        _rf_att.attenuator_ports[26],
        _rf_att.attenuator_ports[27],
        _rf_att.attenuator_ports[28],
    ],
)

_gNB381_2_rm_68 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB381_rf_pdu2.pdu_ports[12],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att.attenuator_ports[29],
        _rf_att.attenuator_ports[30],
        _rf_att.attenuator_ports[31],
        _rf_att.attenuator_ports[32],
    ],
)

_gNB381_2_du = DU(airscale=_gNB381_airscale, rus=[_gNB381_2_rm_46, _gNB381_2_rm_68])

_gNB381_2 = ClassicalBts(cu=_gNB381_2_cu, dus=[_gNB381_2_du])

# ---------------- END gnb-2 ------------------------

# ---------------- START eNB-2 ------------------------ eNB_381-2

_eNB381_2_capu = CapacityUnit(addr="192.168.253.20")

_eNB381_2_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB381_2_capu],
    pdu_port=_comu_pdu.pdu_ports[4],
)

_eNB381_2_rm = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_comu_pdu.pdu_ports[2],
    radio_type="FRHC",
)

_eNB381_2_airscale = Airscale(common_units=[_eNB381_2_comu])

_eNB381_2 = RealEnb(
    system_module=_eNB381_2_airscale,
    rms=[_eNB381_2_rm],
    oam_ip=NetworkAddress(v4="10.47.207.134"),
)

# ---------------- END eNB-2 ------------------------

# ---------------- START TAF_UE_PROXY UEs ----------------

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.47.194.226",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.226",
)


_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, version=2
)

_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.135.91",
    username="deul5g",
    password="Nuc2Ue4PzLab!",
)

_Qualcomm41_sdx65 = TafUeAndroid(
    serial_number="562e2b2b",
    ue_pc_address="10.46.135.91",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE", "UE_1"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc_ssh_details,
    ue_pc_port="8080",
    pdu_port=_comu_pdu.pdu_ports[9],
)

# ---------------- STOP TAF_UE_PROXY UEs ----------------


_core_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.47.194.226", username="ute", password="UTE.debian12"
    ),
    network_interface_address="10.47.194.226",
    iperf_path="/usr/bin/iperf",
)

_core_appserver = AppServer(iperf_details=_core_iperf)

# ---------------- END QC UE2 ------------------------

# ---------------- TEST PC ---------------------------

_testpc1_ssh = SshServiceDetails(
    addr="10.47.207.179", username="ute", password="UTE.debian12"
)
_testpc1 = TestPc(default_ssh_connection_details=_testpc1_ssh, connections=[_gNB381])

_testpc2_ssh = SshServiceDetails(
    addr="10.47.207.180", username="ute", password="UTE.debian12"
)
_testpc2 = TestPc(default_ssh_connection_details=_testpc2_ssh, connections=[_eNB381])

_testpc3_ssh = SshServiceDetails(
    addr="10.47.207.177", username="ute", password="UTE.debian12"
)
_testpc3 = TestPc(default_ssh_connection_details=_testpc3_ssh, connections=[_gNB381_2])

_testpc4_ssh = SshServiceDetails(
    addr="10.47.207.178", username="ute", password="UTE.debian12"
)
_testpc4 = TestPc(default_ssh_connection_details=_testpc4_ssh, connections=[_eNB381_2])

# ---------------- END TEST PC -----------------------

tl = TestLine(
    test_pc=_testpc1,
    test_pcs=[_testpc1, _testpc2, _testpc3, _testpc4],
    gnbs=[_gNB381, _gNB381_2],
    enbs=[_eNB381, _eNB381_2],
    pdus=[
        _comu_pdu,
        _gNB381_rf_pdu1,
        _gNB381_rf_pdu2,
        _gNB381_rf_pdu4,
    ],
    core=_tampereCore,
    ues=[_Qualcomm41_sdx65],
    appserver=_core_appserver,
    attenuators=[_rf_att],
    tl_cloud_topology="CLASSICAL_5G",
)

__all__ = ["tl"]
