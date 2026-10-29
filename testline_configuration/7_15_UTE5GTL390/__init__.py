######################################
#  TestLine 390 Ulm                  #
######################################
__maintainer__ = "MN RAN Pz Ulm 2 SQD64"
__team__ = "MN RAN Pz Ulm 2 SQD64"
__email__ = "I_PZ_ULM_SQD_64@internal.nsn.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import AppServer
from taf.config.testline.connection_details import (
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.core import RealCore, IPS
from taf.config.testline.ue import Android, Qualcomm, QualcommUeType
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.attenuator import HBTE

from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid

_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="7-15-UTE5GTL390-1.ulm.nsn-rdnet.net", username="ute", password="ute"
    )
)

# ---------------- START ATTENUATOR -------------------------------
_rf_att = HBTE(
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
# ---------------- STOP ATTENUATOR ----------------------------------

# ---------------- START gnb-1 -------------------------------------- gnb_390-1
_gNB390_comu_pdu = Gude(
    addr="10.46.134.234",
    port_numbers=[6],
    model="EPC",
    version="8221-1",
    snmp_user=dict(
        userName="user",
        authKey="qwer2009!",
        privKey="qwer2009!",
        authProtocol="SHA",
        privProtocol="AES",
    ),
)

_gNB390_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.206.151",
        routing_v4=RoutingInformation(
            gateway="10.47.205.190", destIpAddr="10.47.205.64/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.206.151", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.206.151", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.206.212"),
    x2u=NetworkAddress(v4="10.47.206.181"),
    s1u=NetworkAddress(v4="10.47.206.181"),
)

_gNB390_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")

_gNB390_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB390_capu1],
    pdu_port=_gNB390_comu_pdu.pdu_ports[6],
    hardware_type="ASIB",
)

_gNB390_airscale = Airscale(common_units=[_gNB390_comu])

_gNB390_rf_pdu1 = Gude(
    addr="10.46.134.251",
    port_numbers=[3, 4, 6],
    model="EPC",
    version="8221-1",
    snmp_user=dict(
        userName="user",
        authKey="qwer2009!",
        privKey="qwer2009!",
        authProtocol="SHA",
        privProtocol="AES",
    ),
)


_gNB390_du_rm_001 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB390_rf_pdu1.pdu_ports[3],
    radio_type="AHEGB",
    attenuation_ports=[_rf_att.attenuator_ports[19], _rf_att.attenuator_ports[20]],
)

_gNB390_du_rm_002 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB390_rf_pdu1.pdu_ports[4],
    radio_type="AHEGB",
    attenuation_ports=[_rf_att.attenuator_ports[21], _rf_att.attenuator_ports[22]],
)

_gNB390_du_rm_003 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB390_rf_pdu1.pdu_ports[6],
    radio_type="AHEGB",
    attenuation_ports=[_rf_att.attenuator_ports[23], _rf_att.attenuator_ports[24]],
)

_gNB390_du = DU(
    airscale=_gNB390_airscale,
    rus=[_gNB390_du_rm_001, _gNB390_du_rm_002, _gNB390_du_rm_003],
)

_gNB390 = ClassicalBts(cu=_gNB390_cu, dus=[_gNB390_du])
# ---------------- END gnb-1 ------------------------

# ---------------- START eNB-1 ------------------------ eNB_390
_eNB390_comu_pdu = Gude(
    addr="10.46.134.245",
    port_numbers=[5],
    model="EPC",
    version="8221-1",
    snmp_user=dict(
        userName="user",
        authKey="qwer2009!",
        privKey="qwer2009!",
        authProtocol="SHA",
        privProtocol="AES",
    ),
)

_eNB390_capu = CapacityUnit(addr="192.168.253.20")

_eNB390_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.47.206.150", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB390_capu],
    pdu_port=_eNB390_comu_pdu.pdu_ports[5],
)

_eNB390_rf_pdu = Gude(
    addr="10.46.134.245",
    port_numbers=[1, 2, 3, 4, 5, 6, 7],
    model="EPC",
    version="8221-1",
    snmp_user=dict(
        userName="user",
        authKey="qwer2009!",
        privKey="qwer2009!",
        authProtocol="SHA",
        privProtocol="AES",
    ),
)

_eNB390_rm1_ru1 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_eNB390_rf_pdu.pdu_ports[1],
    radio_type="FXED",
    attenuation_ports=[_rf_att.attenuator_ports[1], _rf_att.attenuator_ports[2]],
)

_eNB390_rm1_ru2 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_eNB390_rf_pdu.pdu_ports[2],
    radio_type="FXED",
    attenuation_ports=[_rf_att.attenuator_ports[3], _rf_att.attenuator_ports[4]],
)

_eNB390_rm1_ru3 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_eNB390_rf_pdu.pdu_ports[3],
    radio_type="FXED",
    attenuation_ports=[_rf_att.attenuator_ports[5], _rf_att.attenuator_ports[6]],
)

_eNB390_rm1_ru4 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_eNB390_rf_pdu.pdu_ports[3],
    radio_type="FRMC",
    attenuation_ports=[_rf_att.attenuator_ports[7], _rf_att.attenuator_ports[8]],
)

_eNB390_rm1_ru5 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_eNB390_rf_pdu.pdu_ports[3],
    radio_type="FRMC",
    attenuation_ports=[_rf_att.attenuator_ports[9], _rf_att.attenuator_ports[10]],
)

_eNB390_rm1_ru6 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_eNB390_rf_pdu.pdu_ports[3],
    radio_type="FRMC",
    attenuation_ports=[_rf_att.attenuator_ports[11], _rf_att.attenuator_ports[12]],
)

_eNB390_rm1_ru7 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_eNB390_rf_pdu.pdu_ports[3],
    radio_type="FRHC",
    attenuation_ports=[_rf_att.attenuator_ports[13], _rf_att.attenuator_ports[14]],
)

_eNB390_rm1_ru8 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_eNB390_rf_pdu.pdu_ports[3],
    radio_type="FRHC",
    attenuation_ports=[_rf_att.attenuator_ports[15], _rf_att.attenuator_ports[16]],
)

_eNB390_rm1_ru9 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_eNB390_rf_pdu.pdu_ports[3],
    radio_type="FRHC",
    attenuation_ports=[_rf_att.attenuator_ports[17], _rf_att.attenuator_ports[18]],
)


_eNB390_airscale = Airscale(common_units=[_eNB390_comu])

_eNB390 = RealEnb(
    system_module=_eNB390_airscale,
    rms=[
        _eNB390_rm1_ru1,
        _eNB390_rm1_ru2,
        _eNB390_rm1_ru3,
        _eNB390_rm1_ru4,
        _eNB390_rm1_ru5,
        _eNB390_rm1_ru6,
        _eNB390_rm1_ru7,
        _eNB390_rm1_ru8,
        _eNB390_rm1_ru9,
    ],
    oam_ip=NetworkAddress(v4="10.47.206.150"),
)
# ---------------- END eNB-1 ------------------------

# ---------------- START IPSL ------------------------
_ips_ssh = SshServiceDetails(
    addr="10.44.32.86", username="deul5g", password="Nuc2Ue4PzLab!"
)
_tampereCore = RealCore(ips=IPS(ssh_connection_details=_ips_ssh), mcc="555", mnc="10")
# ---------------- END IPSL ------------------------

# ---------------- START application server ------------------------
_appserver1_ssh = SshServiceDetails(
    addr="10.47.194.216", username="ute", password="ute"
)

_appserver1_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver1_ssh, iperf_version=3
)

_appserver1 = AppServer(iperf_details=_appserver1_iperf)
# ---------------- END  application server ------------------------

# ---------------- START QC UE1 ------------------------
_ue1_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.135.60", username="deul5g", password="Nuc2Ue4PzLab!"
)

_nokia83_TL390_1 = Android(
    ssh_connection_details=_ue1_ctrl_pc_ssh_details,
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE"],
    imsi="555107000000188",
    serial_number="HZQN1876AAKA2001275",
    server_dir="C:/pyro_server",
    python_path="C:/Python36/python.exe",
    iperf_details=_appserver1_iperf,
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
)
# ---------------- END QC UE1 ------------------------

# ---------------- START QC UE2 ------------------------
_ue2_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.135.70", username="deul5g", password="Nuc2Ue4PzLab!"
)

_nokia83_TL390_2 = Android(
    ssh_connection_details=_ue2_ctrl_pc_ssh_details,
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE"],
    imsi="555107000000189",
    serial_number="HZQN1876AAKA2001274",
    server_dir="C:/pyro_server",
    python_path="C:/Python36/python.exe",
    iperf_details=_appserver1_iperf,
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
)
# ---------------- END QC UE2 ------------------------

# ---------------- Start TEST PCs ------------------------
_gNB390_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        # addr="7-15-UTE5GTL390-1.ulm.nsn-rdnet.net", username="ute", password="ute"
        addr="10.47.206.241",
        username="ute",
        password="ute",
    ),
    connections=[_gNB390],
)


_eNB390_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        # addr="7-15-UTE5GTL390-2.ulm.nsn-rdnet.net", username="ute", password="ute"
        addr="10.47.206.242",
        username="ute",
        password="ute",
    ),
    connections=[_eNB390],
)

# ---------------- End TEST PCs ------------------------
# ---------------- START TAF_UE_PROXY UEs ----------------
_app_server_1 = TafUeAppServer(
    app_server_name="DEUL5Gappsrv16",
    address="10.47.194.216",
    user="ute",
    password="ute",
    bind_interface_ip="10.47.194.216",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, version=3
)

_android1 = TafUeAndroid(
    serial_number="HZQN1876AAKA2001275",
    imsi="555107000000188",
    ue_pc_address=_ue1_ctrl_pc_ssh_details.addr,
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_NOKIA8.3", "UE_1"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue1_ctrl_pc_ssh_details,
    ue_pc_port="8080",
)

_android2 = TafUeAndroid(
    serial_number="HZQN1876AAKA2001274",
    imsi="555107000000189",
    ue_pc_address="10.46.135.42",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_NOKIA8.3", "UE_2"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue2_ctrl_pc_ssh_details,
    ue_pc_port="8080",
)
# ---------------- STOP TAF_UE_PROXY UEs ----------------

tl = TestLine(
    test_pc=_host,
    test_pcs=[_gNB390_test_pc, _eNB390_test_pc],
    gnbs=[_gNB390],
    enbs=[_eNB390],
    pdus=[
        _gNB390_comu_pdu,
        _gNB390_du_rm_001,
        _gNB390_du_rm_002,
        _gNB390_du_rm_003,
        _eNB390_comu_pdu,
        _eNB390_rf_pdu,
    ],
    core=_tampereCore,
    ues=[_nokia83_TL390_1, _nokia83_TL390_2],
    # ues=[_nokia83_TL390_1, _nokia83_TL390_2, _android1, _android2],
    appserver=_appserver1,
    appservers=[_appserver1],
    attenuators=[_rf_att],
    tl_cloud_topology="NON_CM",
)

__all__ = ["tl"]
