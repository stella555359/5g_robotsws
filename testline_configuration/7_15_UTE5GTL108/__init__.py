######################################
#  TestLine 108 Ulm                  #
######################################
__maintainer__ = "MN ECE RD ULM L2PS 04 SG SQD62"
__team__ = "MN ECE RD ULM L2PS 04 SG SQD62"
__email__ = "I_MN_ECE_ULM_RD_L2PS_04_SG_SQD62_NIMS@internal.nsn.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.core import RealCore5G
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.ue import MediaTek, Android, Qualcomm
from taf.config.testline.ue import QualcommUeType, PluginAndroidClassType
from taf.config.testline.radio import RU
from taf.config.testline.appserver import AppServer
from taf.config.testline.pdu import Gude
from taf.config.testline.attenuator import HBTE
from taf.config.testline import RealEnb

__all__ = ["tl"]

_snmp_user_data = dict(
    userName="user",
    authKey="qwer2009!",
    privKey="qwer2009!",
    authProtocol="SHA",
    privProtocol="AES",
)

_comu_pdu = Gude(
    addr="10.46.133.46",
    port_numbers=[2, 4, 6, 9],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_rf_pdu = Gude(
    addr="10.46.133.17",
    port_numbers=[7, 8, 9],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_rf_att = HBTE(
    ip_addr="10.46.133.86",
    port="5000",
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    version=None,
    model="PA-16-16-6-127-0.5-B-S",
)

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_tampereCore = RealCore5G(mcc="555", mnc="10")

# ----------------------------------------------------- #

# ---------------- START gnb-1 ------------------------ #

_gNB_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.198.200",
        routing_v4=RoutingInformation(
            gateway="10.47.198.222", destIpAddr="10.47.198.192/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.198.200", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.198.200", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.198.201"),
    x2u=NetworkAddress(v4="10.47.198.202"),
    s1u=NetworkAddress(v4="10.47.198.202"),
)

_gNB_capacity_unit = CapacityUnit(addr="192.168.253.20")

_gNB_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB_capacity_unit],
    pdu_port=_comu_pdu.pdu_ports[6],
    hardware_type="ASIK",
)

_gNB_du_rm_38 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu.pdu_ports[7],
    radio_type="AHCA",
    attenuation_ports=[
        _rf_att.attenuator_ports[1],
        _rf_att.attenuator_ports[2],
        _rf_att.attenuator_ports[3],
        _rf_att.attenuator_ports[4],
    ],
)

_gNB_du_rm_37 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu.pdu_ports[8],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att.attenuator_ports[5],
        _rf_att.attenuator_ports[6],
        _rf_att.attenuator_ports[7],
        _rf_att.attenuator_ports[8],
    ],
)

_gNB_du_rm_36 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu.pdu_ports[9],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att.attenuator_ports[9],
        _rf_att.attenuator_ports[10],
        _rf_att.attenuator_ports[11],
        _rf_att.attenuator_ports[12],
    ],
)

_gNB_airscale = Airscale(common_units=[_gNB_common_unit])

_gNB_du = DU(
    airscale=_gNB_airscale,
    rus=[_gNB_du_rm_38, _gNB_du_rm_37, _gNB_du_rm_36],
)

_gNB = ClassicalBts(cu=_gNB_cu, dus=[_gNB_du])

# ---------------- END gnb-1 ------------------------ #

# ---------------- START enb-1 ------------------------ #
_eNB_capu = CapacityUnit(addr="192.168.253.20")

_eNB_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB_capu],
    pdu_port=_comu_pdu.pdu_ports[4],
)

_eNB_ru1 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_comu_pdu.pdu_ports[2],
    radio_type="FRHC",
    attenuation_ports=[
        _rf_att.attenuator_ports[13],
        _rf_att.attenuator_ports[14],
        _rf_att.attenuator_ports[15],
        _rf_att.attenuator_ports[16],
    ],
)

_eNB_airscale = Airscale(common_units=[_eNB_comu])

_eNB = RealEnb(
    system_module=_eNB_airscale,
    rms=[_eNB_ru1],
    oam_ip=NetworkAddress(v4="10.47.198.199"),
)
# ---------------- END enb-1 ------------------------ #

# ---------------- START UE1: Mediatek #20 ------------------------ #
_mtk_host_ssh = SshServiceDetails(
    addr="10.46.135.28", username="deul5g", password="Nuc2Ue4PzLab!", port="22"
)

_mtk = MediaTek(
    ssh_connection_details=_mtk_host_ssh,
    capabilities=["REAL_MEDIATEK_UE"],
    server_dir="/cygdrive/c/pyro_server",
    server_port=8080,
    edb_file_path="C:/Mediatek/00_MTK-DB/W19.43.p3_IODTCBr.20191022/MDDB_MT6297_S00_VMOLY_W19_43_P3.EDB",
    imsi="540017000001014",
    imei="35190103100451",
    apn_url="ulmsa",
    iperf_details=IperfDataTransferDetails(
        ssh_connection_details=SshServiceDetails(
            addr="10.46.135.28", username="deul5g", password="Nuc2Ue4PzLab!", port="22"
        ),
        network_interface_address="",
        iperf_path="/data/local/tmp/iperf",
        port=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254],
    ),
)
# ---------------- END UE1: Mediatek #20 ------------------------ #

# ---------------- START UE2: Askey #06 SDX55 ------------------------ #
_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.135.30", username="deul5g", password="Nuc2Ue4PzLab!"
)

_ASKEY_06 = Android(
    ssh_connection_details=_ue_ctrl_pc_ssh_details,
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE"],
    imsi="540017000001044",
    serial_number="93d5d42",
    server_dir="C:/pyro_server",
    python_path="C:/Python38/python.exe",
    iperf_details=IperfDataTransferDetails(
        network_interface_address="",
        ssh_connection_details=_ue_ctrl_pc_ssh_details,
        iperf_path="C:/iPerf/",
    ),
    serial_com="4",
    diag_com="3",
    pdu_port=_comu_pdu.pdu_ports[9],
    class_name=PluginAndroidClassType.at_cmd,
)
# ---------------- END UE2: Askey #06 SDX55 ------------------------ #

# ---------------- START Core APP Server ------------------- #
_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.47.194.208", username="root", password="nsn"
    ),
    network_interface_address="10.47.194.208",
    iperf_path="iperf",
    port=5432,
)

_appserver = AppServer(_iperf_details_on_appserver)
# ---------------- END Core APP Server ------------------- #

# ---------------- START TEST PCs -------------------- #
_gNB_testpc1_ssh = SshServiceDetails(
    addr="10.47.198.242", username="ute", password="ute"
)
_gNB_testpc1 = TestPc(
    default_ssh_connection_details=_gNB_testpc1_ssh, connections=[_gNB]
)

_eNB_testpc2_ssh = SshServiceDetails(
    addr="10.47.198.246", username="ute", password="ute"
)
_eNB_testpc2 = TestPc(
    default_ssh_connection_details=_eNB_testpc2_ssh, connections=[_eNB]
)
# ---------------- END TEST PCs ---------------------- #

# ----------------------------------------- TL ----------------------------------------- #
tl = TestLine(
    test_pc=_gNB_testpc1,
    test_pcs=[_gNB_testpc1, _eNB_testpc2],
    gnbs=[_gNB],
    enbs=[_eNB],
    core=_tampereCore,
    ues=[_mtk, _ASKEY_06],
    pdus=[_comu_pdu, _rf_pdu],
    appserver=_appserver,
    attenuators=[_rf_att],
    tl_cloud_topology="CLASSICAL_5G_TYPE",
)

# ----------------------------------------- TL ----------------------------------------- #
