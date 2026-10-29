######################################
#  TestLine 350 Ulm                  #
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
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.attenuator import HBTE

import os
from taf.config.testline import TafUeDataTransferProtocol, TafUeAtDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.pdu import ATEN
from taf.config.testline.ue import TafUeAt

_rf_att = HBTE(
    ip_addr="10.46.134.141",
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

# ---------------- START gnb-1 ------------------------ gnb_350-1
_gNB350_comu_pdu = Gude(
    addr="10.46.134.201",
    port_numbers=[5],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_gNB350_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.201.81",
        routing_v4=RoutingInformation(
            gateway="10.47.201.94", destIpAddr="10.47.201.64/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.201.81", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.201.81", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.201.82"),
    x2u=NetworkAddress(v4="10.47.201.83"),
    s1u=NetworkAddress(v4="10.47.201.83"),
)

_gNB350_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")

_gNB350_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB350_capu1],
    pdu_port=_gNB350_comu_pdu.pdu_ports[5],
    hardware_type="ASIB",
)

_gNB350_airscale = Airscale(common_units=[_gNB350_comu])

_gNB350_rf_pdu1 = Gude(
    addr="10.46.134.206",
    port_numbers=[1, 2],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_gNB350_rf_pdu2 = Gude(
    addr="10.46.134.207",
    port_numbers=[9],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_gNB350_du_rm_1 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB350_rf_pdu1.pdu_ports[1],
    radio_type="AHCA",
    attenuation_ports=[_rf_att.attenuator_ports[1], _rf_att.attenuator_ports[2]],
)

_gNB350_du_rm_2 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB350_rf_pdu1.pdu_ports[2],
    radio_type="AHCA",
    attenuation_ports=[_rf_att.attenuator_ports[3], _rf_att.attenuator_ports[4]],
)

_gNB350_du_rm_3 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB350_rf_pdu2.pdu_ports[9],
    radio_type="AHFIB",
    attenuation_ports=[_rf_att.attenuator_ports[5], _rf_att.attenuator_ports[6]],
)

_gNB350_du = DU(
    airscale=_gNB350_airscale, rus=[_gNB350_du_rm_1, _gNB350_du_rm_2, _gNB350_du_rm_3]
)

_gNB350 = ClassicalBts(cu=_gNB350_cu, dus=[_gNB350_du])
# ---------------- END gnb-1 ------------------------

# ---------------- START gnb-2 ------------------------ gnb_350-2
_gNB350B_comu_pdu = Gude(
    addr="10.46.134.201",
    port_numbers=[7],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_gNB350B_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.201.84",
        routing_v4=RoutingInformation(
            gateway="10.47.201.94", destIpAddr="10.47.201.64/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.201.84", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.201.84", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.201.85"),
    x2u=NetworkAddress(v4="10.47.201.86"),
    s1u=NetworkAddress(v4="10.47.201.86"),
)

_gNB350B_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIO")
_gNB350B_capu2 = CapacityUnit(addr="192.168.253.24", hardware_type="ABIO")
_gNB350B_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB350B_capu1, _gNB350B_capu2],
    pdu_port=_gNB350B_comu_pdu.pdu_ports[7],
    hardware_type="ASIB",
)

_gNB350B_airscale = Airscale(common_units=[_gNB350B_comu])

_gNB350_rf_pdu3 = Gude(
    addr="10.46.134.206",
    port_numbers=[6, 9, 12],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_gNB350_du_rm_4 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB350_rf_pdu3.pdu_ports[6],
    radio_type="AHCA",
    attenuation_ports=[_rf_att.attenuator_ports[7], _rf_att.attenuator_ports[8]],
)

_gNB350_du_rm_5 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB350_rf_pdu3.pdu_ports[9],
    radio_type="AHCA",
    attenuation_ports=[_rf_att.attenuator_ports[9], _rf_att.attenuator_ports[10]],
)

_gNB350_du_rm_6 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB350_rf_pdu3.pdu_ports[9],
    radio_type="AHCA",
    attenuation_ports=[_rf_att.attenuator_ports[11], _rf_att.attenuator_ports[12]],
)

_gNB350B_du = DU(
    airscale=_gNB350B_airscale, rus=[_gNB350_du_rm_4, _gNB350_du_rm_5, _gNB350_du_rm_6]
)

_gNB350B = ClassicalBts(cu=_gNB350B_cu, dus=[_gNB350B_du])
# ---------------- END gnb-2 ------------------------

# ---------------- START eNB-1 ------------------------ eNB_350
_eNB350_comu_pdu = Gude(
    addr="10.46.134.201",
    port_numbers=[3],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_eNB350_capu = CapacityUnit(addr="192.168.253.20")

_eNB350_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB350_capu],
    pdu_port=_eNB350_comu_pdu.pdu_ports[3],
)

_eNB350_rf_pdu = Gude(
    addr="10.46.134.201",
    port_numbers=[1],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_eNB350_rm1 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_eNB350_rf_pdu.pdu_ports[1],
    radio_type="FRHC",
    attenuation_ports=[_rf_att.attenuator_ports[13], _rf_att.attenuator_ports[14]],
)

_eNB350_rm2 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_eNB350_rf_pdu.pdu_ports[1],
    radio_type="FRHC",
    attenuation_ports=[_rf_att.attenuator_ports[15], _rf_att.attenuator_ports[16]],
)

_eNB350_airscale = Airscale(common_units=[_eNB350_comu])

_eNB350 = RealEnb(
    system_module=_eNB350_airscale,
    rms=[_eNB350_rm1, _eNB350_rm2],
    oam_ip=NetworkAddress(v4="10.47.201.80"),
)
# ---------------- END eNB-1 ------------------------

# ---------------- START IPSL ------------------------
_ips_ssh = SshServiceDetails(
    addr="10.44.32.134", username="deul5g", password="Nuc2Ue4PzLab!"
)
_tampereCore = RealCore(ips=IPS(ssh_connection_details=_ips_ssh), mcc="555", mnc="10")
# ---------------- END IPSL ------------------------

# ---------------- START APPLICATION SERVER ----------
_appserver1_ssh = SshServiceDetails(addr="10.44.35.222", username="ute", password="ute")

_appserver1_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver1_ssh, iperf_version=3
)

_appserver1 = AppServer(iperf_details=_appserver1_iperf)
# ---------------- STOP APPLICATION SERVER ----------

# ---------------- START QC UE1 ------------------------
_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.134.50", username="deul5g", password="Nuc2Ue4PzLab!"
)

_appserver_ssh = SshServiceDetails(addr="10.44.35.222", username="ute", password="ute")

_iperf_UE1 = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    iperf_path="C:/iPerf/iperf",
    iperf_version="2",
)


_ASKEY_1_PDU = Gude(
    addr="10.46.134.201",
    port_numbers=[10],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_ASKEY_350_1 = Android(
    ssh_connection_details=_ue_ctrl_pc_ssh_details,
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE", "UE_1"],
    imsi="555107000000142",
    serial_number="13c49cfd",
    server_dir="C:/pyro_server",
    python_path="C:/Python39/python.exe",
    iperf_details=_iperf_UE1,
    serial_com="4",
    diag_com="3",
    pdu_port=_ASKEY_1_PDU.pdu_ports[10],
    class_name=PluginAndroidClassType.at_cmd,
)
# ---------------- END QC UE1 ------------------------

# ---------------- START QC UE2 ------------------------
_ue_ctrl_pc_2_ssh_details = SshServiceDetails(
    addr="10.46.134.30", username="deul5g", password="Nuc2Ue4PzLab!"
)

_iperf_UE2 = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    iperf_path="C:/iPerf/iperf",
    iperf_version="2",
)

_ASKEY_2_PDU = Gude(
    addr="10.46.134.201",
    port_numbers=[9],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_ASKEY_350_2 = Android(
    ssh_connection_details=_ue_ctrl_pc_2_ssh_details,
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE", "UE_2"],
    imsi="262731000000096",
    serial_number="9da8e160",
    server_dir="C:/pyro_server",
    python_path="C:/Python39/python.exe",
    iperf_details=_iperf_UE2,
    serial_com="3",
    diag_com="4",
    pdu_port=_ASKEY_2_PDU.pdu_ports[9],
    class_name=PluginAndroidClassType.at_cmd,
)
# ---------------- END QC UE2 ------------------------

# ---------------- START TAF_UE_PROXY UEs ----------------
_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.44.35.222",
    user="ute",
    password="ute",
    bind_interface_ip="10.44.35.222",
)

_data_transfer_iperf = TafUeAtDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    interval=1,
    version=2,
    dt_from_uepc=True,
)

_Askey_1 = TafUeAt(
    serial_number="13c49cfd",
    com_port="4",
    ue_pc_address="10.46.135.50",
    ue_pc_login="deul5g",
    ue_pc_password="Nuc2Ue4PzLab!",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "UE_1"],
    data_transfer=[_data_transfer_iperf],
    ue_pc_port="8080",
)

_Askey_2 = TafUeAt(
    com_port="3",
    serial_number="9da8e160",
    ue_pc_address="10.46.135.30",
    ue_pc_login="deul5g",
    ue_pc_password="Nuc2Ue4PzLab!",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "UE_2"],
    data_transfer=[_data_transfer_iperf],
    ue_pc_port="8080",
)
# ---------------- STOP TAF_UE_PROXY UEs ----------------

# ---------------- START TEST PCs --------------------

_gNB350_testpc1_ssh = SshServiceDetails(
    addr="10.47.201.113", username="ute", password="ute"
)
_gNB350_testpc1 = TestPc(
    default_ssh_connection_details=_gNB350_testpc1_ssh, connections=[_gNB350]
)

_gNB350B_testpc2_ssh = SshServiceDetails(
    addr="10.47.201.119", username="ute", password="ute"
)
_gNB350B_testpc2 = TestPc(
    default_ssh_connection_details=_gNB350B_testpc2_ssh, connections=[_gNB350B]
)

_eNB350_testpc3_ssh = SshServiceDetails(
    addr="10.47.201.114", username="ute", password="ute"
)
_eNB350_testpc3 = TestPc(
    default_ssh_connection_details=_eNB350_testpc3_ssh, connections=[_eNB350]
)


# ---------------- END TEST PCs ----------------------

tl = TestLine(
    test_pc=_gNB350_testpc1,
    test_pcs=[_gNB350_testpc1, _gNB350B_testpc2, _eNB350_testpc3],
    gnbs=[_gNB350, _gNB350B],
    enbs=[_eNB350],
    pdus=[_gNB350_comu_pdu, _eNB350_comu_pdu, _eNB350_rf_pdu, _gNB350B_comu_pdu],
    core=_tampereCore,
    ues=[_ASKEY_350_1, _ASKEY_350_2],
    # ues=[_Askey_1, _Askey_2],
    appserver=_appserver1,
    appservers=[_appserver1],
    attenuators=[_rf_att],
    tl_cloud_topology="NON_CM",
)

__all__ = ["tl"]
