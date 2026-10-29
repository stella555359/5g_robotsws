######################################
#  TestLine 371 Ulm                  #
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
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.core import RealCore, IPS
from taf.config.testline.ue import Android, Qualcomm
from taf.config.testline.ue import QualcommUeType, PluginAndroidClassType
from taf.config.testline.pdu import APC, PduPort, Gude
from taf.config.testline.radio import RU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.attenuator import HBTE

import os
from taf.config.testline import TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.pdu import ATEN
from taf.config.testline.ue import TafUeAt

_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="7-15-UTE5GTL371-1.ulm.nsn-rdnet.net", username="ute", password="ute"
    )
)


# ---------------- START IPSL ------------------------
_ips_ssh = SshServiceDetails(
    addr="10.44.32.82", username="deul5g", password="Nuc2Ue4PzLab!"
)
_tampereCore = RealCore(ips=IPS(ssh_connection_details=_ips_ssh), mcc="555", mnc="10")
# ---------------- END IPSL ------------------------

_core_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.47.194.207", username="ute", password="ute"
    ),
    network_interface_address="10.47.194.207",
    iperf_path="/usr/bin/iperf",
)

_core_appserver = AppServer(iperf_details=_core_iperf)

_rf_att = HBTE(
    ip_addr="10.46.134.152",
    port="5000",
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
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

# ---------------- START gnb-1 ------------------------ gnb_371-1
_gNB371_comu_pdu = Gude(
    addr="10.46.134.222",
    port_numbers=[3],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_gNB371_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.203.11",
        routing_v4=RoutingInformation(
            gateway="10.47.203.94", destIpAddr="10.47.203.64/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.203.11", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.203.11", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.203.12"),
    x2u=NetworkAddress(v4="10.47.203.13"),
    s1u=NetworkAddress(v4="10.47.203.13"),
)

_gNB371_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIO")

_gNB371_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB371_capu1],
    pdu_port=_gNB371_comu_pdu.pdu_ports[3],
    hardware_type="ASIB",
)

_gNB371_airscale = Airscale(common_units=[_gNB371_comu])

_gNB371_rf_pdu1 = Gude(
    addr="10.46.134.227",
    port_numbers=[1, 4],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_gNB371_rf_pdu2 = Gude(
    addr="10.46.134.220",
    port_numbers=[12],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)


_gNB371_du_rm_1 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB371_rf_pdu1.pdu_ports[4],
    radio_type="AHFIB",
    attenuation_ports=[_rf_att.attenuator_ports[1], _rf_att.attenuator_ports[2]],
)

_gNB371_du_rm_2 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB371_rf_pdu1.pdu_ports[1],
    radio_type="AHFIB",
    attenuation_ports=[_rf_att.attenuator_ports[3], _rf_att.attenuator_ports[4]],
)

_gNB371_du_rm_3 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB371_rf_pdu2.pdu_ports[12],
    radio_type="AHLOA",
    attenuation_ports=[_rf_att.attenuator_ports[5], _rf_att.attenuator_ports[6]],
)

_gNB371_du = DU(
    airscale=_gNB371_airscale, rus=[_gNB371_du_rm_1, _gNB371_du_rm_2, _gNB371_du_rm_3]
)

_gNB371 = ClassicalBts(cu=_gNB371_cu, dus=[_gNB371_du])
# ---------------- END gnb-1 ------------------------

# ---------------- START gnb-2 ------------------------ gnb_371-2
_gNB371B_comu_pdu = Gude(
    addr="10.46.134.222",
    port_numbers=[5],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_gNB371B_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.203.14",
        routing_v4=RoutingInformation(
            gateway="10.47.203.94", destIpAddr="10.47.203.64/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.203.14", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.203.14", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.203.15"),
    x2u=NetworkAddress(v4="10.47.203.16"),
    s1u=NetworkAddress(v4="10.47.203.16"),
)

_gNB371B_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIO")
_gNB371B_capu2 = CapacityUnit(addr="192.168.253.24", hardware_type="ABIO")

_gNB371B_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB371B_capu1, _gNB371B_capu2],
    pdu_port=_gNB371B_comu_pdu.pdu_ports[5],
    hardware_type="ASIB",
)

_gNB371B_airscale = Airscale(common_units=[_gNB371B_comu])

_gNB371_rf_pdu3 = Gude(
    addr="10.46.134.227",
    port_numbers=[2, 3, 6],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)


_gNB371_du_rm_4 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB371_rf_pdu3.pdu_ports[2],
    radio_type="AHFIB",
    attenuation_ports=[_rf_att.attenuator_ports[7], _rf_att.attenuator_ports[8]],
)

_gNB371_du_rm_5 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB371_rf_pdu3.pdu_ports[6],
    radio_type="AHFIB",
    attenuation_ports=[_rf_att.attenuator_ports[9], _rf_att.attenuator_ports[10]],
)

_gNB371_du_rm_6 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB371_rf_pdu3.pdu_ports[3],
    radio_type="AHFIB",
    attenuation_ports=[_rf_att.attenuator_ports[11], _rf_att.attenuator_ports[12]],
)

_gNB371B_du = DU(
    airscale=_gNB371B_airscale, rus=[_gNB371_du_rm_4, _gNB371_du_rm_5, _gNB371_du_rm_6]
)

_gNB371B = ClassicalBts(cu=_gNB371B_cu, dus=[_gNB371B_du])
# ---------------- END gnb-2 ------------------------

# ---------------- START eNB-1 ------------------------ eNB_371
_eNB371_comu_pdu = Gude(
    addr="10.46.134.222",
    port_numbers=[4],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_eNB371_capu = CapacityUnit(addr="192.168.253.20")

_eNB371_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB371_capu],
    pdu_port=_eNB371_comu_pdu.pdu_ports[4],
)

_eNB371_rf_pdu = Gude(
    addr="10.46.134.222",
    port_numbers=[1],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_eNB371_rf_att = HBTE(
    ip_addr="10.46.134.152",
    port="5000",
    attenuation_port_numbers=[13, 14, 15, 16],
    version=None,
    model="PA-16-16-6-127-0.5-B-S",
)

_eNB371_rm1 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_eNB371_rf_pdu.pdu_ports[1],
    radio_type="FRHC",
    attenuation_ports=[
        _eNB371_rf_att.attenuator_ports[15],
        _eNB371_rf_att.attenuator_ports[16],
    ],
)

_eNB371_rm2 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_eNB371_rf_pdu.pdu_ports[1],
    radio_type="FRHC",
    attenuation_ports=[
        _eNB371_rf_att.attenuator_ports[13],
        _eNB371_rf_att.attenuator_ports[14],
    ],
)

_eNB371_airscale = Airscale(common_units=[_eNB371_comu])

_eNB371 = RealEnb(
    system_module=_eNB371_airscale,
    rms=[_eNB371_rm1, _eNB371_rm2],
    oam_ip=NetworkAddress(v4="10.47.203.10"),
)
# ---------------- END eNB-1 ------------------------

# ---------------- START QC UE1 ------------------------
_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.135.31", username="deul5g", password="Nuc2Ue4PzLab!"
)

_appserver_ssh = SshServiceDetails(addr="10.47.194.207", username="ute", password="UTE.debian12")

_iperf_UE1 = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    iperf_path="C:/iPerf/iperf",
    iperf_version="2",
)

_ASKEY_1_PDU = Gude(
    addr="10.46.134.222",
    port_numbers=[10],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_ASKEY_371_1 = Android(
    ssh_connection_details=_ue_ctrl_pc_ssh_details,
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE", "UE_1"],
    imsi="555107000000156",
    serial_number="93d5d42",
    server_dir="C:/pyro_server",
    python_path="C:/Python38/python.exe",
    iperf_details=_iperf_UE1,
    serial_com="4",
    diag_com="3",
    pdu_port=_ASKEY_1_PDU.pdu_ports[10],
    class_name=PluginAndroidClassType.at_cmd,
)

# ---------------- END QC UE1 ------------------------

# ---------------- START QC UE2 ------------------------
_ue_ctrl_pc_2_ssh_details = SshServiceDetails(
    addr="10.46.135.41", username="deul5g", password="Nuc2Ue4PzLab!"
)

_iperf_UE2 = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    iperf_path="C:/iPerf/iperf",
    iperf_version="2",
)

_ASKEY_2_PDU = Gude(
    addr="10.46.134.222",
    port_numbers=[6],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_ASKEY_371_2 = Android(
    ssh_connection_details=_ue_ctrl_pc_2_ssh_details,
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE", "UE_2"],
    imsi="262731000000094",
    serial_number="8c421567",
    server_dir="C:/pyro_server",
    python_path="C:/Python38/python.exe",
    iperf_details=_iperf_UE2,
    serial_com="4",
    diag_com="5",
    pdu_port=_ASKEY_2_PDU.pdu_ports[6],
    class_name=PluginAndroidClassType.at_cmd,
)


# ---------------- END QC UE2 ------------------------
# ---------------- START TAF_UE_PROXY UEs ----------------

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.47.194.207",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.207",
)


_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    interval=1,
    version=2,
    dt_from_uepc=True,
)

_Askey_1 = TafUeAt(
    serial_number="93d5d42",
    com_port="4",
    ue_pc_address="10.46.135.31",
    ue_pc_login="deul5g",
    ue_pc_password="Nuc2Ue4PzLab!",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "UE_1"],
    data_transfer=[_data_transfer_iperf],
    ue_pc_port="8080",
)

_Askey_2 = TafUeAt(
    com_port="4",
    serial_number="8c421567",
    ue_pc_address="10.46.135.41",
    ue_pc_login="deul5g",
    ue_pc_password="Nuc2Ue4PzLab!",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "UE_2"],
    data_transfer=[_data_transfer_iperf],
    ue_pc_port="8080",
)

# ---------------- STOP TAF_UE_PROXY UEs ----------------

# ---------------- Start TEST PCs ------------------------
_gNB371_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="7-15-UTE5GTL371-1.ulm.nsn-rdnet.net", username="ute", password="ute"
    ),
    connections=[_gNB371],
)

_gNB371B_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="7-15-UTE5GTL371-3.ulm.nsn-rdnet.net", username="ute", password="ute"
    ),
    connections=[_gNB371B],
)

_eNB371_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="7-15-UTE5GTL371-2.ulm.nsn-rdnet.net", username="ute", password="ute"
    ),
    connections=[_eNB371],
)

# ---------------- End TEST PCs ------------------------

tl = TestLine(
    test_pc=_host,
    test_pcs=[_gNB371_test_pc, _gNB371B_test_pc, _eNB371_test_pc],
    gnbs=[_gNB371, _gNB371B],
    enbs=[_eNB371],
    pdus=[_gNB371_comu_pdu, _eNB371_comu_pdu, _eNB371_rf_pdu, _gNB371B_comu_pdu],
    core=_tampereCore,
    ues=[_ASKEY_371_1, _ASKEY_371_2],
    # ues=[_Askey_1, _Askey_2],
    appserver=_core_appserver,
    attenuators=[_rf_att],
    tl_cloud_topology="CLASSICAL_5G",
)

__all__ = ["tl"]
