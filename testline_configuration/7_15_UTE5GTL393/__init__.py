######################################
#  TestLine 393 Ulm                  #
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
from taf.config.testline import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.core import RealCore4G
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.attenuator import HBTE
from taf.config.testline import TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.ue import TafUeAt

_tampereCore = RealCore4G(mcc="540", mnc="01")

_rf_att = HBTE(
    ip_addr="10.46.134.192",
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
    addr="10.46.134.72",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_rf_pdu1 = Gude(
    addr="10.46.134.82",
    port_numbers=[9, 10, 12],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_rf_pdu2 = Gude(
    addr="10.46.134.83",
    port_numbers=[1, 3, 4, 6, 7],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_rf_pdu3 = Gude(
    addr="10.46.134.84",
    port_numbers=[7],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# ---------------- START gnb-1 ------------------------

_gNB393_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.207.71",
        routing_v4=RoutingInformation(
            gateway="10.47.207.94", destIpAddr="10.47.207.64/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.207.71", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.207.71", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.207.72"),
    x2u=NetworkAddress(v4="10.47.207.73"),
    s1u=NetworkAddress(v4="10.47.207.73"),
)

_gNB393_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[CapacityUnit(addr="192.168.253.20", hardware_type="ABIN/ABIO")],
    pdu_port=_comu_pdu.pdu_ports[3],
    hardware_type="ASIL",
)
_gNB393_airscale = Airscale(common_units=[_gNB393_comu])


_gNB393_rm_60 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu1.pdu_ports[9],
    radio_type="AHFIB",
    attenuation_ports=[
        _rf_att.attenuator_ports[1],
        _rf_att.attenuator_ports[2],
        _rf_att.attenuator_ports[3],
        _rf_att.attenuator_ports[4],
    ],
)

_gNB393_rm_61 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu1.pdu_ports[12],
    radio_type="AHFIB",
    attenuation_ports=[
        _rf_att.attenuator_ports[5],
        _rf_att.attenuator_ports[6],
        _rf_att.attenuator_ports[7],
        _rf_att.attenuator_ports[8],
    ],
)

_gNB393_rm_62 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu2.pdu_ports[3],
    radio_type="AHFIB",
    attenuation_ports=[
        _rf_att.attenuator_ports[9],
        _rf_att.attenuator_ports[10],
        _rf_att.attenuator_ports[11],
        _rf_att.attenuator_ports[12],
    ],
)

_gNB393_rm_07 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu1.pdu_ports[10],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att.attenuator_ports[13],
        _rf_att.attenuator_ports[14],
        _rf_att.attenuator_ports[15],
        _rf_att.attenuator_ports[16],
    ],
)

_gNB393_rm_08 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu2.pdu_ports[1],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att.attenuator_ports[17],
        _rf_att.attenuator_ports[18],
        _rf_att.attenuator_ports[19],
        _rf_att.attenuator_ports[20],
    ],
)

_gNB393_rm_09 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu2.pdu_ports[4],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att.attenuator_ports[21],
        _rf_att.attenuator_ports[22],
        _rf_att.attenuator_ports[23],
        _rf_att.attenuator_ports[24],
    ],
)

_gNB393_rm_73 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu3.pdu_ports[7],
    radio_type="AHFIB",
)

_gNB393_du = DU(
    airscale=_gNB393_airscale,
    rus=[
        _gNB393_rm_60,
        _gNB393_rm_61,
        _gNB393_rm_62,
        _gNB393_rm_07,
        _gNB393_rm_08,
        _gNB393_rm_09,
        _gNB393_rm_73,
    ],
)
_gNB393 = ClassicalBts(cu=_gNB393_cu, dus=[_gNB393_du])

# ---------------- END gnb-1 --------------------------

# ---------------- START gnb-2 ------------------------

_gNB393_2_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.207.75",
        routing_v4=RoutingInformation(
            gateway="10.47.207.94", destIpAddr="10.47.207.64/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.207.75", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.207.75", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.207.76"),
    x2u=NetworkAddress(v4="10.47.207.77"),
    s1u=NetworkAddress(v4="10.47.207.77"),
)

_gNB393_2_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")],
    pdu_port=_comu_pdu.pdu_ports[5],
    hardware_type="ASIL",
)

_gNB393_2_airscale = Airscale(common_units=[_gNB393_2_comu])

_gNB393_2_rm_63 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu2.pdu_ports[6],
    radio_type="AHFIB",
    attenuation_ports=[
        _rf_att.attenuator_ports[25],
        _rf_att.attenuator_ports[26],
        _rf_att.attenuator_ports[27],
        _rf_att.attenuator_ports[28],
    ],
)

_gNB393_2_rm_33 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu2.pdu_ports[7],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att.attenuator_ports[29],
        _rf_att.attenuator_ports[30],
        _rf_att.attenuator_ports[31],
        _rf_att.attenuator_ports[32],
    ],
)

_gNB393_2_du = DU(
    airscale=_gNB393_2_airscale,
    rus=[
        _gNB393_2_rm_63,
        _gNB393_2_rm_33,
    ],
)

_gNB393_2 = ClassicalBts(cu=_gNB393_2_cu, dus=[_gNB393_2_du])

# ---------------- END gnb-2 ------------------------

# ---------------- START eNB-1 ----------------------

_eNB393_capu = CapacityUnit(addr="192.168.253.20")

_eNB393_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB393_capu],
    pdu_port=_comu_pdu.pdu_ports[4],
)

_eNB393_rm = RU(
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

_eNB393_airscale = Airscale(common_units=[_eNB393_comu])

_eNB393 = RealEnb(
    system_module=_eNB393_airscale,
    rms=[_eNB393_rm],
    oam_ip=NetworkAddress(v4="10.47.207.70"),
)

# ---------------- END eNB-1 ------------------------

# ---------------- START eNB-2 ----------------------

_eNB393_2_capu = CapacityUnit(addr="192.168.253.20")

_eNB393_2_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB393_capu],
    pdu_port=_comu_pdu.pdu_ports[6],
)

_eNB393_2_rm = RU(
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

_eNB393_2_airscale = Airscale(common_units=[_eNB393_2_comu])

_eNB393_2 = RealEnb(
    system_module=_eNB393_2_airscale,
    rms=[_eNB393_2_rm],
    oam_ip=NetworkAddress(v4="10.47.207.74"),
)

# ---------------- END eNB-2 --------------------------

# ---------------- START QC UE1 ------------------------TL393

_appserver_ssh = SshServiceDetails(
    addr="10.47.194.211", username="ute", password="UTE.debian12"
)

_iperf_UE = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    iperf_path="C:/iPerf/iperf",
    iperf_version="2",
)
_ue_ctrl_pc1_ssh_details = SshServiceDetails(
    addr="10.46.135.122", username="deul5g", password="Nuc2Ue4PzLab!"
)


# ---------------- END QC UE1 ------------------------

# ---------------- START QC UE2 ------------------------TL393

_ue_ctrl_pc2_ssh_details = SshServiceDetails(
    addr="10.46.135.123", username="deul5g", password="Nuc2Ue4PzLab!"
)


# ---------------- END QC UE2 ------------------------

# ---------------- START TAF_UE_PROXY UEs ----------------

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.47.194.211",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.211",
    expected_prompt="ute@DEUL5Gappsrv11",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    interval=1,
    binary_path="C:/iperf/",
    version=2,
    dt_from_uepc=True,
)

_Askey47_sdx65 = TafUeAt(
    serial_number="22011159",
    com_port="5",
    ue_pc_address="10.46.135.122",
    ue_pc_login="deul5g",
    ue_pc_password="Nuc2Ue4PzLab!",
    ue_pc_expected_prompt="DEUL5G@DEUL5Gnuc1-393",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "UE_1"],
    data_transfer=[_data_transfer_iperf],
    ue_pc_port="8080",
    pdu_port=_comu_pdu.pdu_ports[9],
    imsi="555107000000065",
)

_Askey48_sdx65 = TafUeAt(
    com_port="3",
    serial_number="7668ef02",
    ue_pc_address="10.46.135.123",
    ue_pc_login="deul5g",
    ue_pc_password="Nuc2Ue4PzLab!",
    ue_pc_expected_prompt="DEUL5G@DEUL5Gnuc2-393",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "UE_2"],
    data_transfer=[_data_transfer_iperf],
    ue_pc_port="8080",
    pdu_port=_comu_pdu.pdu_ports[10],
    imsi="555107000000066",
)

# ---------------- STOP TAF_UE_PROXY UEs ----------------

_core_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.47.194.211", username="ute", password="UTE.debian12"
    ),
    network_interface_address="10.47.194.211",
    iperf_path="/usr/bin/iperf",
)

_core_appserver = AppServer(iperf_details=_core_iperf)

# ---------------- TEST PC ---------------------------Tl393

_testpc1_ssh = SshServiceDetails(
    addr="10.47.207.97", username="ute", password="UTE.debian12"
)
_testpc1 = TestPc(default_ssh_connection_details=_testpc1_ssh, connections=[_gNB393])

_testpc2_ssh = SshServiceDetails(
    addr="10.47.207.98", username="ute", password="UTE.debian12"
)
_testpc2 = TestPc(default_ssh_connection_details=_testpc2_ssh, connections=[_eNB393])

_testpc3_ssh = SshServiceDetails(
    addr="10.47.207.99", username="ute", password="UTE.debian12"
)
_testpc3 = TestPc(default_ssh_connection_details=_testpc3_ssh, connections=[_gNB393_2])

_testpc4_ssh = SshServiceDetails(
    addr="10.47.207.100", username="ute", password="UTE.debian12"
)
_testpc4 = TestPc(default_ssh_connection_details=_testpc4_ssh, connections=[_eNB393_2])

# ---------------- END TEST PC -----------------------

tl = TestLine(
    test_pc=_testpc1,
    test_pcs=[_testpc1, _testpc2, _testpc3, _testpc4],
    gnbs=[_gNB393, _gNB393_2],
    enbs=[_eNB393, _eNB393_2],
    pdus=[_rf_pdu1, _rf_pdu2, _comu_pdu],
    core=_tampereCore,
    ues=[_Askey47_sdx65, _Askey48_sdx65],
    appserver=_core_appserver,
    attenuators=[_rf_att],
    tl_cloud_topology="CLASSICAL_5G",
)

__all__ = ["tl"]
