######################################
#  TestLine 366 Ulm                  #
######################################
__maintainer__ = "MN ECE RD ULM L2PS 04 SG SQD62"
__team__ = "MN ECE RD ULM L2PS 04 SG SQD62"
__email__ = "I_MN_ECE_ULM_RD_L2PS_04_SG_SQD62_NIMS@internal.nsn.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import AppServer

# from taf.config.testline.connection_details import (SshServiceDetails,
#                                                    OpenStackConnectionDetails,
#                                                    BmcConnectionDetails,
#                                                    HttpConnectionDetails,
#                                                   IperfDataTransferDetails)
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import RealEnb
from taf.config.testline.core import RealCore
from taf.config.testline.ue import Android, Qualcomm
from taf.config.testline.ue import QualcommUeType, PluginAndroidClassType
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.attenuator import HBTE

from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import (
    TafUeDataTransferProtocol,
    TafUeAtDataTransferProtocol,
)
from taf.config.testline.ue import TafUeAt

_espooCore = RealCore(mcc="540", mnc="1")

_rf_att = HBTE(
    ip_addr="10.46.134.148",
    port="5000",
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    version=None,
    model="PA-16-16-6-127-0.5-B-S",
)

# ---------------- START gNB-1 ------------------------
_pdu1 = Gude(
    addr="10.46.134.212",
    port_numbers=[10],
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
_pdu2 = Gude(
    addr="10.46.134.213",
    port_numbers=[1, 2, 3, 4, 5, 7, 11, 12],
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
_pdu3 = Gude(
    addr="10.46.134.216",
    port_numbers=[12],
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
_pdu4 = Gude(
    addr="10.46.134.217",
    port_numbers=[2, 3],
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

_gnb1_cu = CU(
    backhaul_site_oam_ip="10.47.202.22",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.202.22", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.202.22", username="Nemuadmin", password="nemuuser", port=443
    ),
)

_gnb1_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")

_gnb1_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gnb1_capu1],
    pdu_port=_pdu2.pdu_ports[5],
    hardware_type="ASIK",
)

_gnb1_airscale = Airscale(common_units=[_gnb1_comu])

_gnb1_du_rm05 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    radio_type="AHLOA",
    attenuation_ports=[_rf_att.attenuator_ports[1], _rf_att.attenuator_ports[2]],
)

_gnb1_du_rm06 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu4.pdu_ports[3],
    radio_type="AHLOA",
    attenuation_ports=[_rf_att.attenuator_ports[3], _rf_att.attenuator_ports[4]],
)

_gnb1_du_rm19 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    radio_type="AHLOA",
    attenuation_ports=[_rf_att.attenuator_ports[5], _rf_att.attenuator_ports[6]],
)

_gnb1_du1 = DU(airscale=_gnb1_airscale, rus=[_gnb1_du_rm05, _gnb1_du_rm06])

_gnb1 = ClassicalBts(cu=_gnb1_cu, dus=[_gnb1_du1])
# ---------------- End gNB-1 --------------------------

# ---------------- START gNB-2 ------------------------

_gnb2_cu = CU(
    backhaul_site_oam_ip="10.47.202.25",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.202.25", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.202.25", username="Nemuadmin", password="nemuuser", port=443
    ),
)

_gnb2_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")

_gnb2_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gnb2_capu1],
    pdu_port=_pdu2.pdu_ports[7],
    hardware_type="ASIK",
)

_gnb2_airscale = Airscale(common_units=[_gnb2_comu])

_gnb2_du_rm27 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    radio_type="AHLOA",
    attenuation_ports=[_rf_att.attenuator_ports[9], _rf_att.attenuator_ports[10]],
)

_gnb2_du_rm29 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    radio_type="AHLOA",
    attenuation_ports=[_rf_att.attenuator_ports[11], _rf_att.attenuator_ports[12]],
)

_gnb2_du_rm31 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu4.pdu_ports[2],
    radio_type="AHLOA",
    attenuation_ports=[_rf_att.attenuator_ports[13], _rf_att.attenuator_ports[14]],
)

_gnb2_du = DU(airscale=_gnb2_airscale, rus=[_gnb2_du_rm29])

_gnb2 = ClassicalBts(cu=_gnb2_cu, dus=[_gnb2_du])
# ---------------- End gNB-1 --------------------------

# ---------------- START eNB-1 ------------------------

_enb1_capu = CapacityUnit(addr="192.168.253.20")

_enb1_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_enb1_capu],
    pdu_port=_pdu2.pdu_ports[3],
)

_enb1_airscale = Airscale(common_units=[_enb1_comu])

_enb1_rm1 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu2.pdu_ports[1],
    radio_type="FRHC",
    attenuation_ports=[_rf_att.attenuator_ports[7], _rf_att.attenuator_ports[8]],
)

_enb1 = RealEnb(
    system_module=_enb1_airscale,
    rms=[_enb1_rm1],
    oam_ip=NetworkAddress(v4="10.47.202.20"),
)

# ---------------- STOP eNB-1 ------------------------

# ---------------- START eNB-2 ------------------------

_enb2_capu = CapacityUnit(addr="192.168.253.20")

_enb2_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_enb2_capu],
    pdu_port=_pdu2.pdu_ports[4],
)

_enb2_airscale = Airscale(common_units=[_enb2_comu])


_enb2_rm2 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu2.pdu_ports[2],
    radio_type="FRHC",
    attenuation_ports=[_rf_att.attenuator_ports[15], _rf_att.attenuator_ports[16]],
)

_enb2 = RealEnb(
    system_module=_enb2_airscale,
    rms=[_enb2_rm2],
    oam_ip=NetworkAddress(v4="10.47.202.21"),
)

# ---------------- STOP eNB-2 ------------------------

_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.47.194.203", username="ute", password="ute"
    ),
    network_interface_address="10.47.194.203",
    iperf_path="/usr/bin/iperf",
)

_appserver = AppServer(_iperf_details_on_appserver)


# ---------------- START QC ASKEY UE1 ------------------------
_ue1_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.134.66", username="deul5g", password="Nuc2Ue4PzLab!"
)

_qc1 = Android(
    ssh_connection_details=_ue1_ctrl_pc_ssh_details,
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE", "UE_0"],
    serial_number="4331352e",
    server_dir="C:/pyro_server",
    python_path="C:/Python39/python.exe",
    iperf_details=IperfDataTransferDetails(
        network_interface_address="",
        ssh_connection_details=_ue1_ctrl_pc_ssh_details,
        iperf_path="C:/iPerf/",
    ),
    serial_com="6",
    diag_com="5",
    pdu_port=_pdu2.pdu_ports[11],
    class_name=PluginAndroidClassType.at_cmd,
)
# ---------------- STOP QC ASKEY UE1 ------------------------
# ---------------- START QC ASKEY UE2 ------------------------
_ue2_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.134.19", username="deul5g", password="Nuc2Ue4PzLab!"
)

_qc2 = Android(
    ssh_connection_details=_ue2_ctrl_pc_ssh_details,
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "UE_1"],
    serial_number="3a6d612e",
    server_dir="C:/pyro_server",
    python_path="C:/Python39/python.exe",
    iperf_details=IperfDataTransferDetails(
        network_interface_address="",
        ssh_connection_details=_ue2_ctrl_pc_ssh_details,
        iperf_path="C:/iperf/",
    ),
    serial_com="6",  # serial modem port => check with device manager on NUC PC
    diag_com="5",  # connection port of QXDM
    pdu_port=_pdu1.pdu_ports[10],
    class_name=PluginAndroidClassType.at_cmd,
)
# ---------------- STOP QC ASKEY UE2 ------------------------
# ---------------- START QC ASKEY UE3 ------------------------
_ue3_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.134.46", username="deul5g", password="Nuc2Ue4PzLab!"
)

_qc3 = Android(
    ssh_connection_details=_ue3_ctrl_pc_ssh_details,
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    serial_number="92a62916",
    server_dir="C:/pyro_server",
    python_path="C:/Python39/python.exe",
    iperf_details=IperfDataTransferDetails(
        network_interface_address="",
        ssh_connection_details=_ue3_ctrl_pc_ssh_details,
        iperf_path="C:/iperf/",
    ),
    serial_com="4",  # serial modem port => check with device manager on NUC PC
    diag_com="3",  # connection port of QXDM
    pdu_port=_pdu2.pdu_ports[12],
    class_name=PluginAndroidClassType.at_cmd,
)
# ---------------- STOP QC ASKEY UE3 ------------------------

###################### taf_ue_proxy ########
#################

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.47.194.203",
    user="ute",
    password="ute",
    expected_prompt="ute@DEUL5Gappsrv03",
    bind_interface_ip="10.47.194.203",
)

_data_transfer_iperf = TafUeAtDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    interval=1,
    dt_from_uepc=True,
    version=2,
)

_qc1_proxy = TafUeAt(
    com_port="6",
    serial_number="4331352e",
    ue_pc_address="10.46.134.66",
    ue_pc_login="deul5g",
    ue_pc_password="Nuc2Ue4PzLab!",
    ue_pc_expected_prompt="",
    capabilities=["ue_proxy", "REAL_UE", "REAL_ANDROID_UE", "UE_0"],
    data_transfer=[_data_transfer_iperf],
    ue_pc_port="8080",
)

_qc2_proxy = TafUeAt(
    com_port="4",
    serial_number="b0234816",
    ue_pc_address="10.46.134.19",
    ue_pc_login="deul5g",
    ue_pc_password="Nuc2Ue4PzLab!",
    ue_pc_expected_prompt="",
    capabilities=["ue_proxy", "REAL_UE", "REAL_ANDROID_UE", "UE_1"],
    data_transfer=[_data_transfer_iperf],
    ue_pc_port="8080",
)


_qc3_proxy = TafUeAt(
    com_port="6",
    serial_number="92a62916",
    ue_pc_address="10.46.134.46",
    ue_pc_login="deul5g",
    ue_pc_password="Nuc2Ue4PzLab!",
    ue_pc_expected_prompt="",
    capabilities=["ue_proxy", "REAL_UE", "REAL_ANDROID_UE", "UE_2"],
    data_transfer=[_data_transfer_iperf],
    ue_pc_port="8080",
)


# ---------------- START TEST PCs --------------------

_gNB1_testpc1_ssh = SshServiceDetails(
    addr="10.47.202.52", username="ute", password="ute"
)
_gNB1_testpc1 = TestPc(
    default_ssh_connection_details=_gNB1_testpc1_ssh, connections=[_gnb1]
)

_gNB2_testpc2_ssh = SshServiceDetails(
    addr="10.47.202.55", username="ute", password="ute"
)
_gNB2_testpc2 = TestPc(
    default_ssh_connection_details=_gNB2_testpc2_ssh, connections=[_gnb2]
)

_eNB1_testpc3_ssh = SshServiceDetails(
    addr="10.47.202.53", username="ute", password="ute"
)
_eNB1_testpc3 = TestPc(
    default_ssh_connection_details=_eNB1_testpc3_ssh, connections=[_enb1]
)

_eNB2_testpc4_ssh = SshServiceDetails(
    addr="10.47.202.54", username="ute", password="ute"
)
_eNB2_testpc4 = TestPc(
    default_ssh_connection_details=_eNB2_testpc4_ssh, connections=[_enb2]
)

# ---------------- END TEST PCs ----------------------

# ------------ TL --------------------------------------------
tl = TestLine(
    test_pc=_gNB1_testpc1,
    test_pcs=[_gNB1_testpc1, _gNB2_testpc2, _eNB1_testpc3, _eNB2_testpc4],
    gnbs=[_gnb1, _gnb2],
    enbs=[_enb1, _enb2],
    core=_espooCore,
    pdus=[_pdu1, _pdu2, _pdu3, _pdu4],
    #    ues=[_qc1, _qc2, _qc3],
    ues=[_qc1_proxy, _qc2_proxy, _qc3_proxy],
    appserver=_appserver,
    attenuators=[_rf_att],
    tl_cloud_topology="NON_CM",
)
__all__ = ["tl"]
