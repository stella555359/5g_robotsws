######################################
#  TestLine 370 Ulm                  #
######################################
__maintainer__ = "MN ECE RD ULM L2PS 04 SG SQD64"
__team__ = "MN ECE RD ULM L2PS 04 SG SQD64"
__email__ = "I_MN_ECE_ULM_RD_L2PS_04_SG_SQD64_NIMS@internal.nsn.com"

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

# ---------------- START ATTENUATIOR ----------------
_rf_att = HBTE(
    ip_addr="10.46.134.184",
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
    ],
    version=None,
    model="PA-16-16-6-127-0.5-B-S",
)
# ---------------- STOP ATTENUATOR -------------------

# ---------------- START gnb-1 ------------------------ gnb_370-1
_gNB370_comu_pdu = Gude(
    addr="10.46.134.233",
    port_numbers=[7],
    version="8221-1",
    snmp_user=dict(
        userName="user",
        authKey="qwer2009!",
        privKey="qwer2009!",
        authProtocol="SHA",
        privProtocol="AES",
    ),
)

_gNB370_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.205.181",
        routing_v4=RoutingInformation(
            gateway="10.47.205.190", destIpAddr="10.47.205.160/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.205.181", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.205.181", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.205.132"),
    x2u=NetworkAddress(v4="10.47.205.171"),
    s1u=NetworkAddress(v4="10.47.205.171"),
)

_gNB370_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIO")

_gNB370_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB370_capu1],
    pdu_port=_gNB370_comu_pdu.pdu_ports[7],
    hardware_type="ASIB",
)
_gNB370_airscale = Airscale(common_units=[_gNB370_comu])

_gNB370_rf_pdu1 = Gude(
    addr="10.46.134.233",
    port_numbers=[4],
    version="8221-1",
    snmp_user=dict(
        userName="user",
        authKey="qwer2009!",
        privKey="qwer2009!",
        authProtocol="SHA",
        privProtocol="AES",
    ),
)

_gNB370_rf_pdu2 = Gude(
    addr="10.46.134.240",
    port_numbers=[8, 11],
    version="8221-1",
    snmp_user=dict(
        userName="user",
        authKey="qwer2009!",
        privKey="qwer2009!",
        authProtocol="SHA",
        privProtocol="AES",
    ),
)

_gNB370_rf_pdu3 = Gude(
    addr="10.46.134.251",
    port_numbers=[2],
    version="8221-1",
    snmp_user=dict(
        userName="user",
        authKey="qwer2009!",
        privKey="qwer2009!",
        authProtocol="SHA",
        privProtocol="AES",
    ),
)

_gNB370_du_rm_1 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB370_rf_pdu1.pdu_ports[4],
    radio_type="ARGA",
    # Global cell ID:	14001    Physical layer cell ID:	33
    attenuation_ports=[_rf_att.attenuator_ports[19], _rf_att.attenuator_ports[20]],
)

_gNB370_du_rm_2 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB370_rf_pdu1.pdu_ports[4],
    radio_type="ARGA",
    attenuation_ports=[_rf_att.attenuator_ports[21], _rf_att.attenuator_ports[22]],
)

_gNB370_du_rm_3 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB370_rf_pdu1.pdu_ports[4],
    radio_type="ARGA",
    attenuation_ports=[_rf_att.attenuator_ports[23], _rf_att.attenuator_ports[24]],
)


_gNB370_du = DU(
    airscale=_gNB370_airscale,
    rus=[
        _gNB370_du_rm_1,
        _gNB370_du_rm_2,
        _gNB370_du_rm_3,
    ],
)

_gNB370 = ClassicalBts(cu=_gNB370_cu, dus=[_gNB370_du])
# ---------------- END gnb-1 ------------------------

# ---------------- START gnb-2 ------------------------
# --- NO second gNB in customer TL A1-Austria----------
# ---------------- END gnb-2 ------------------------

# ---------------- START eNB-1 ------------------------ eNB_370
_eNB370_comu_pdu = Gude(
    addr="10.46.134.233",
    port_numbers=[6],
    version="8221-1",
    snmp_user=dict(
        userName="user",
        authKey="qwer2009!",
        privKey="qwer2009!",
        authProtocol="SHA",
        privProtocol="AES",
    ),
)

_eNB370_capu = CapacityUnit(addr="10.47.205.180")

_eNB370_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB370_capu],
    pdu_port=_eNB370_comu_pdu.pdu_ports[6],
)

_eNB370_rf_pdu = Gude(
    addr="10.46.134.233",
    port_numbers=[1, 2, 3, 4, 5],
    version="8221-1",
    snmp_user=dict(
        userName="user",
        authKey="qwer2009!",
        privKey="qwer2009!",
        authProtocol="SHA",
        privProtocol="AES",
    ),
)

_eNB370_rm1 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_eNB370_rf_pdu.pdu_ports[1],
    radio_type="FXED",
    attenuation_ports=[_rf_att.attenuator_ports[1], _rf_att.attenuator_ports[2]],
)

_eNB370_rm2 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_eNB370_rf_pdu.pdu_ports[1],
    radio_type="FXED",
    attenuation_ports=[_rf_att.attenuator_ports[3], _rf_att.attenuator_ports[4]],
)

_eNB370_rm3 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_eNB370_rf_pdu.pdu_ports[1],
    radio_type="FXED",
    attenuation_ports=[_rf_att.attenuator_ports[5], _rf_att.attenuator_ports[6]],
)

_eNB370_rm4 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_eNB370_rf_pdu.pdu_ports[1],
    radio_type="FRMC",
    # Global cell ID:	10    Physical layer cell ID:	366
    attenuation_ports=[_rf_att.attenuator_ports[7], _rf_att.attenuator_ports[8]],
)

_eNB370_rm5 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_eNB370_rf_pdu.pdu_ports[1],
    radio_type="FRMC",
    attenuation_ports=[_rf_att.attenuator_ports[9], _rf_att.attenuator_ports[10]],
)

_eNB370_rm6 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_eNB370_rf_pdu.pdu_ports[1],
    radio_type="FRMC",
    attenuation_ports=[_rf_att.attenuator_ports[11], _rf_att.attenuator_ports[12]],
)

_eNB370_rm7 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_eNB370_rf_pdu.pdu_ports[1],
    radio_type="FRHC",
    attenuation_ports=[_rf_att.attenuator_ports[13], _rf_att.attenuator_ports[14]],
)

_eNB370_rm8 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_eNB370_rf_pdu.pdu_ports[1],
    radio_type="FRHC",
    attenuation_ports=[_rf_att.attenuator_ports[15], _rf_att.attenuator_ports[16]],
)

_eNB370_rm9 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_eNB370_rf_pdu.pdu_ports[1],
    radio_type="FRHC",
    attenuation_ports=[_rf_att.attenuator_ports[17], _rf_att.attenuator_ports[18]],
)



_eNB370_airscale = Airscale(common_units=[_eNB370_comu])

_eNB370 = RealEnb(
    system_module=_eNB370_airscale,
    rms=[
        _eNB370_rm1,
        _eNB370_rm2,
        _eNB370_rm3,
        _eNB370_rm4,
        _eNB370_rm5,
        _eNB370_rm6,
        _eNB370_rm7,
        _eNB370_rm8,
        _eNB370_rm9,
    ],
    oam_ip=NetworkAddress(v4="10.47.205.180"),
)
# ---------------- END eNB-1 ------------------------

# ---------------- START IPSL ------------------------
_ips_ssh = SshServiceDetails(
    addr="10.44.32.85", username="deul5g", password="Nuc2Ue4PzLab!"
)
_tampereCore = RealCore(ips=IPS(ssh_connection_details=_ips_ssh), mcc="555", mnc="10")
# ---------------- END IPSL ------------------------

# ---------------- START APPLICATION SERVER ----------
_appserver1_ssh = SshServiceDetails(
    addr="10.47.194.217", username="ute", password="ute"
)

_appserver1_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver1_ssh, iperf_version=3
)

_appserver1 = AppServer(iperf_details=_appserver1_iperf)
# ---------------- STOP APPLICATION SERVER ----------


# ---------------- START QC UE1 ------------------------
_ue1_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.135.40", username="deul5g", password="Nuc2Ue4PzLab!"
)

_nokia83_TL370_1 = Android(
    ssh_connection_details=_ue1_ctrl_pc_ssh_details,
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE"],
    imsi="555107000000181",
    serial_number="HZQN1876AAKA2001397",
    server_dir="C:/pyro_server",
    python_path="C:/Python36/python.exe",
    iperf_details=_appserver1_iperf,
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
)
# ---------------- END QC UE1 ------------------------

# ---------------- START QC UE2 ------------------------
_ue2_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.135.42", username="deul5g", password="Nuc2Ue4PzLab!"
)

_nokia83_TL370_2 = Android(
    ssh_connection_details=_ue2_ctrl_pc_ssh_details,
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE"],
    imsi="555107000000182",
    serial_number="HZQN1876AAKA2001322",
    server_dir="C:/pyro_server",
    python_path="C:/Python36/python.exe",
    iperf_details=_appserver1_iperf,
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
)
# ---------------- END QC UE2 ------------------------

# ---------------- START TEST PCs --------------------
_gNB370_testpc_ssh = SshServiceDetails(
    # addr="7-15-UTE5GTL370-1.ulm.nsn-rdnet.net", username="ute", password="ute"
    addr="10.47.205.53",
    username="ute",
    password="ute",
)
_gNB370_testpc = TestPc(
    default_ssh_connection_details=_gNB370_testpc_ssh, connections=[_gNB370]
)

_eNB370_testpc_ssh = SshServiceDetails(
    # addr="7-15-UTE5GTL370-2.ulm.nsn-rdnet.net", username="ute", password="ute"
    addr="10.47.205.54",
    username="ute",
    password="ute",
)
_eNB370_testpc = TestPc(
    default_ssh_connection_details=_eNB370_testpc_ssh, connections=[_eNB370]
)
# ---------------- END TEST PCs ----------------------
# ---------------- START TAF_UE_PROXY UEs ----------------
_app_server_1 = TafUeAppServer(
    app_server_name="DEUL5Gappsrv17",
    address="10.47.194.217",
    user="ute",
    password="ute",
    bind_interface_ip="10.47.194.217",
)


_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, version=3
)

_android1 = TafUeAndroid(
    serial_number="HZQN1876AAKA2001397",
    imsi="555107000000181",
    ue_pc_address=_ue1_ctrl_pc_ssh_details.addr,
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_NOKIA8.3", "UE_1"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue1_ctrl_pc_ssh_details,
    ue_pc_port="8080",
)

_android2 = TafUeAndroid(
    serial_number="HZQN1876AAKA2001322",
    imsi="555107000000182",
    ue_pc_address="10.46.135.42",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_NOKIA8.3", "UE_2"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue2_ctrl_pc_ssh_details,
    ue_pc_port="8080",
)
# ---------------- STOP TAF_UE_PROXY UEs ----------------

tl = TestLine(
    test_pc=_gNB370_testpc,
    test_pcs=[_gNB370_testpc, _eNB370_testpc],
    gnbs=[_gNB370],
    enbs=[_eNB370],
    pdus=[
        _gNB370_comu_pdu,
        _gNB370_rf_pdu1,
        _gNB370_rf_pdu2,
        _gNB370_rf_pdu3,
        _eNB370_comu_pdu,
        _eNB370_rf_pdu,
        _eNB370_rf_pdu,
    ],
    core=_tampereCore,
    ues=[_nokia83_TL370_2],
    # ues=[_android1],
    appserver=_appserver1,
    appservers=[_appserver1],
    attenuators=[_rf_att],
    tl_cloud_topology="NON_CM",
)

__all__ = ["tl"]
