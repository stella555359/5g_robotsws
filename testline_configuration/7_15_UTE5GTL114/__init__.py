######################################
#  TestLine 114 Ulm                  #
######################################
__maintainer__ = "Christian Moegle"
__team__ = "MN ECE RD ULM L3NRT 07 SG SQD60"
__email__ = "I_MN ECE RD ULM L3NRT 07 SG SQD60_NIMS@internal.nsn.com"

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
from taf.config.testline.ue import QualcommLicenseType
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.attenuator import HBTE

_host_gnb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.198.49", username="ute", password="ute"
    ),
)

_tampereCore = RealCore4G(mcc="555", mnc="10")

_core_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.44.35.212", username="ute", password="ute"
    ),
    network_interface_address="10.44.35.212",
    iperf_path="/usr/bin/iperf",
)

_core_appserver = AppServer(iperf_details=_core_iperf)

# ---------------- START gNB-1 ------------------------ gNB_114
_gnb_comu_pdu = Gude(
    addr="10.46.133.41", 
    port_numbers=[5], 
    model="Gude", 
    version="8221-1",
    snmp_user=dict(
        userName="user",
        authKey="qwer2009!",
        privKey="qwer2009!",
        authProtocol="SHA",
        privProtocol="AES",
    ),
)

_gnb_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="192.168.255.129",
        routing_v4=RoutingInformation(gateway="192.168.255.126", ip_prefix_length=27),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="192.168.4.112"),
    x2u=NetworkAddress(v4="192.168.4.112"),
    s1u=NetworkAddress(v4="192.168.4.111"),
)

_gnb_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")

_gnb_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gnb_capu1],
    pdu_port=_gnb_comu_pdu.pdu_ports[5],
    hardware_type="ASIK",
)

_gnb_airscale = Airscale(common_units=[_gnb_comu])

_gnb_rf_pdu = Gude(
    addr="10.46.133.28", 
    port_numbers=[7], 
    model="Gude", 
    version="8221-1",
    snmp_user=dict(
        userName="user",
        authKey="qwer2009!",
        privKey="qwer2009!",
        authProtocol="SHA",
        privProtocol="AES",
    ),
)

_gnb_rf_att = HBTE(
    ip_addr="10.46.133.87",
    port="5000",
    attenuation_port_numbers=[9, 10],
    version=None,
    model="PA-16-16-0-127-0.5-B-S",
)

_gnb_du_rm1 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb_rf_pdu.pdu_ports[7],
    radio_type="AZQG",
    attenuation_ports=[
        _gnb_rf_att.attenuator_ports[9],
        _gnb_rf_att.attenuator_ports[10],
    ],
)

_gnb_du = DU(airscale=_gnb_airscale, rus=[_gnb_du_rm1])

_gnb = ClassicalBts(cu=_gnb_cu, dus=[_gnb_du])
# ---------------- END gNB-1 ------------------------


# ---------------- START eNB-1 ------------------------ eNB_114
_host_enb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.198.50", username="ute", password="ute"
    ),
)

_enb_comu_pdu = Gude(
    addr="10.46.133.41", 
    port_numbers=[3], 
    model="Gude", 
    version="8221-1",
    snmp_user=dict(
        userName="user",
        authKey="qwer2009!",
        privKey="qwer2009!",
        authProtocol="SHA",
        privProtocol="AES",
    ),
)

_enb_capu = CapacityUnit(addr="192.168.253.20")

_enb_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_enb_capu],
    pdu_port=_enb_comu_pdu.pdu_ports[3],
)

_enb_rf_pdu = Gude(
    addr="10.46.133.28", 
    port_numbers=[1], 
    model="Gude", 
    version="8221-1",
    snmp_user=dict(
        userName="user",
        authKey="qwer2009!",
        privKey="qwer2009!",
        authProtocol="SHA",
        privProtocol="AES",
    ),
)

_enb_rm1 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_enb_rf_pdu.pdu_ports[1],
    radio_type="FRHC",
)

_enb_system_module = Airscale(common_units=[_enb_comu])

_enb = RealEnb(system_module=_enb_system_module, rms=[_enb_rm1])
# ---------------- END eNB-1 ------------------------


# ---------------- START QC UE1 ------------------------
_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.133.114", username="deul5g", password="Nuc2Ue4PzLab!"
)

_qualcomm_sdx55 = Android(
    ssh_connection_details=_ue_ctrl_pc_ssh_details,
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE"],
    serial_number="e531fd2b",
    server_dir="C:/pyro_server",
    python_path="C:/Python27/python.exe",
    iperf_details=IperfDataTransferDetails(
        network_interface_address="",
        ssh_connection_details=_ue_ctrl_pc_ssh_details,
        iperf_path="/data/iperf/",
    ),
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
)

# ---------------- END QC UE1 ------------------------


tl = TestLine(
    test_pc=_host_gnb,
    test_pcs=[_host_gnb, _host_enb],
    core=_tampereCore,
    appserver=_core_appserver,
    gnbs=[_gnb],
    enbs=[_enb],
    pdus=[_gnb_comu_pdu, _gnb_rf_pdu, _enb_comu_pdu, _enb_rf_pdu],
    ues=[_qualcomm_sdx55],
    attenuator=[_gnb_rf_att],
    tl_cloud_topology="CLOUD_5G_QC_CLASSICAL_ASIK_ABIL_AZQG_ENB",
)

__all__ = ["tl"]
