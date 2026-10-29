######################################
#  TestLine 380 Ulm                  #
######################################
__maintainer__ = "MN ECE RD ULM L2PS 04 SG SQD62"
__team__ = "MN ECE RD ULM L2PS 04 SG SQD62"
__email__ = "I_MN_ECE_ULM_RD_L2PS_04_SG_SQD62_NIMS@internal.nsn.com"

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
from taf.config.testline import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.core import RealCore4G
from taf.config.testline.ue import Android, Qualcomm, QualcommUeType
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.attenuator import HBTE

from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid

_tampereCore = RealCore4G(mcc="555", mnc="10")

_core_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.47.194.204", username="ute", password="ute"
    ),
    network_interface_address="10.47.194.204",
    iperf_path="/usr/bin/iperf",
)

_core_appserver = AppServer(iperf_details=_core_iperf)

_snmp_user_data = dict(
    userName="user",
    authKey="qwer2009!",
    privKey="qwer2009!",
    authProtocol="SHA",
    privProtocol="AES",
)

# ---------------- START gNB-1 ------------------------
_gnb1_comu_pdu = Gude(
    addr="10.46.134.231",
    port_numbers=[7],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_gnb1_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.205.21", username="Nemuadmin", password="nemuuser", port="443"
    ),
)


_gnb1_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")

_gnb1_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gnb1_capu1],
    pdu_port=_gnb1_comu_pdu.pdu_ports[7],
    hardware_type="ASIB",
)

_gnb1_airscale = Airscale(common_units=[_gnb1_comu])

_gnb1_rf_pdu = Gude(
    addr="10.46.134.229",
    port_numbers=[1, 6],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_gnb1_rf_att = HBTE(
    ip_addr="10.46.134.181",
    port="5000",
    attenuation_port_numbers=[1, 2],
    version=None,
    model="PA-16-16-6-127-0.5-B-S",
)


_gnb1_du_rm1 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb1_rf_pdu.pdu_ports[1],
    radio_type="AEQE",
    attenuation_ports=[
        _gnb1_rf_att.attenuator_ports[1],
        _gnb1_rf_att.attenuator_ports[2],
    ],
)


_gnb1_du = DU(airscale=_gnb1_airscale, rus=[_gnb1_du_rm1])

_gnb1 = ClassicalBts(cu=_gnb1_cu, dus=[_gnb1_du])

# ---------------- END gNB-1 ------------------------

# ---------------- START eNB-1 ------------------------
_enb1_comu_pdu = Gude(
    addr="10.46.134.231",
    port_numbers=[8],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_enb1_capu = CapacityUnit(addr="192.168.253.20")
_enb1_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_enb1_capu],
    pdu_port=_enb1_comu_pdu.pdu_ports[8],
)

_enb1_airscale = Airscale(common_units=[_enb1_comu])

_enb1_rf_pdu = Gude(
    addr="10.46.134.231",
    port_numbers=[2],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_enb1_rf_att = HBTE(
    ip_addr="10.46.134.181",
    port="5000",
    attenuation_port_numbers=[3, 4],
    version=None,
    model="PA-16-16-6-127-0.5-B-S",
)

_enb1_rm1 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_enb1_rf_pdu.pdu_ports[2],
    radio_type="FRHC",
    attenuation_ports=[
        _enb1_rf_att.attenuator_ports[3],
        _enb1_rf_att.attenuator_ports[4],
    ],
)

_enb1 = RealEnb(
    system_module=_enb1_airscale,
    rms=[_enb1_rm1],
    oam_ip=NetworkAddress(v4="10.47.205.20"),
)
# ---------------- STOP eNB-1 ------------------------

# ---------------- START QC UE1 ------------------------

_testpc1_ssh = SshServiceDetails(addr="10.47.205.51", username="ute", password="ute")
_testpc1 = TestPc(default_ssh_connection_details=_testpc1_ssh, connections=[_gnb1])

_testpc2_ssh = SshServiceDetails(addr="10.47.205.52", username="ute", password="ute")
_testpc2 = TestPc(default_ssh_connection_details=_testpc2_ssh, connections=[_enb1])

_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.135.49", username="deul5g", password="Nuc2Ue4PzLab!"
)

_qualcomm1_PDU = Gude(
    addr="10.46.134.231",
    port_numbers=[12],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_qualcomm1 = Android(
    ssh_connection_details=_ue_ctrl_pc_ssh_details,
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE"],
    serial_number="30f95d66",
    server_dir="C:/pyro_server",
    python_path="C:/Python38/python.exe",
    iperf_details=IperfDataTransferDetails(
        network_interface_address="",
        ssh_connection_details=_ue_ctrl_pc_ssh_details,
        iperf_path="/data/data/com.nokia.android.application/iperf",
    ),
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    pdu_port=_qualcomm1_PDU.pdu_ports[12],
)

# ---------------- STOP QC UE1 ------------------------

# ---------------- START QC UE2 ------------------------
_ue_ctrl_pc_2_ssh_details = SshServiceDetails(
    addr="10.46.135.50", username="deul5g", password="Nuc2Ue4PzLab!"
)

_qualcomm2_PDU = Gude(
    addr="10.46.134.231",
    port_numbers=[11],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_qualcomm2 = Android(
    ssh_connection_details=_ue_ctrl_pc_2_ssh_details,
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE"],
    serial_number="1c2309a0",
    server_dir="C:/pyro_server",
    python_path="C:/Python38/python.exe",
    iperf_details=IperfDataTransferDetails(
        network_interface_address="",
        ssh_connection_details=_ue_ctrl_pc_2_ssh_details,
        iperf_path="/data/data/com.nokia.android.application/iperf",
    ),
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    pdu_port=_qualcomm2_PDU.pdu_ports[11],
)

# ---------------- STOP QC UE2 ------------------------

# ---------------- START TAF_UE_PROXY UEs ----------------

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.47.194.204",
    user="ute",
    password="ute",
    bind_interface_ip="10.47.194.204",
)


_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, version=2
)

_Qualcomm_1 = TafUeAndroid(
    serial_number="30f95d66",
    ue_pc_address="10.46.135.49",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE", "UE_1"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc_ssh_details,
    ue_pc_port="8080",
)

_Qualcomm_2 = TafUeAndroid(
    serial_number="1c2309a0",
    ue_pc_address="10.46.135.50",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE", "UE_1"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc_2_ssh_details,
    ue_pc_port="8080",
)


# ---------------- STOP TAF_UE_PROXY UEs ----------------

# ---------------- END ATTENUATOR ------------------------
tl = TestLine(
    test_pc=_testpc1,
    test_pcs=[_testpc1, _testpc2],
    gnbs=[_gnb1],
    enbs=[_enb1],
    core=_tampereCore,
    ues=[_qualcomm1, _qualcomm2],
    # ues=[_Qualcomm_1, _Qualcomm_2],
    appserver=_core_appserver,
    attenuators=[_gnb1_rf_att, _enb1_rf_att],
    tl_cloud_topology="NON_CM",
)

__all__ = ["tl"]
