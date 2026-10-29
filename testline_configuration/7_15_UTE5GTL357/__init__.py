######################################
#  TestLine 357 Ulm                  #
######################################
__maintainer__ = "MN ECE RD ULM L2PS 04 SG SQD64"
__team__ = "MN ECE RD ULM L2PS 04 SG SQD64"
__email__ = "I_MN_ECE_ULM_RD_L2PS_04_SG_SQD64_NIMS@internal.nsn.com"

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
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.attenuator import HBTE
from taf.config.testline.core import RealCore, IPS
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid

_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="7-15-UTE5GTL357-1.ulm.nsn-rdnet.net",
        username="ute",
        password="UTE.debian12",
    )
)

_snmp_user_data = dict(
    userName="user",
    authKey="qwer2009!",
    privKey="qwer2009!",
    authProtocol="SHA",
    privProtocol="AES",
)

_core_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.44.35.212", username="ute", password="ute"
    ),
    network_interface_address="10.44.35.212",
    iperf_path="/usr/bin/iperf",
)

_core_appserver = AppServer(iperf_details=_core_iperf)

_rf_att = HBTE(
    ip_addr="10.46.134.145",
    port="5000",
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    version=None,
    model="PA-16-16-6-127-0.5-B-S",
)

_comu_pdu = Gude(
    addr="10.46.134.205",
    port_numbers=[1, 2, 3, 4, 5, 7, 11, 12],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)
_rf_pdu1 = Gude(
    addr="10.46.134.216",
    port_numbers=[3, 5, 6],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_rf_pdu2 = Gude(
    addr="10.46.134.217",
    port_numbers=[3],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# ---------------- START gNB-1 ------------------------ gNB_357


_gnb357_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.201.201",
        routing=RoutingInformation(gateway="10.47.201.222", ip_prefix_length=27),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.201.201", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.201.201", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.201.202"),
    x2u=NetworkAddress(v4="10.47.201.203"),
    s1u=NetworkAddress(v4="10.47.201.203"),
)

_gnb357_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")

_gnb357_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.11", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gnb357_capu1],
    pdu_port=_comu_pdu.pdu_ports[5],
    hardware_type="ASIK",
)

_gnb357_airscale = Airscale(common_units=[_gnb357_comu])

_gnb357_du_rm38 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu1.pdu_ports[3],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att.attenuator_ports[1],
        _rf_att.attenuator_ports[2],
    ],
)

_gnb357_du_rm21 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu1.pdu_ports[5],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att.attenuator_ports[3],
        _rf_att.attenuator_ports[4],
    ],
)

_gnb357_du = DU(
    airscale=_gnb357_airscale,
    rus=[
        _gnb357_du_rm38,
        _gnb357_du_rm21,
    ],
)

_gnb357 = ClassicalBts(cu=_gnb357_cu, dus=[_gnb357_du])
# ---------------- END gNB-1 ------------------------

# ---------------- START gNB-2 ------------------------ gNB_358

_gnb358_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.201.204",
        routing=RoutingInformation(gateway="10.47.201.222", ip_prefix_length=27),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.201.204", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.201.204", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.201.205"),
    x2u=NetworkAddress(v4="10.47.201.206"),
    s1u=NetworkAddress(v4="10.47.201.206"),
)

_gnb358_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")

_gnb358_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.11", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gnb358_capu1],
    pdu_port=_comu_pdu.pdu_ports[7],
    hardware_type="ASIK",
)

_gnb358_airscale = Airscale(common_units=[_gnb358_comu])

_gnb358_du_rm69 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu1.pdu_ports[6],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att.attenuator_ports[9],
        _rf_att.attenuator_ports[10],
        _rf_att.attenuator_ports[11],
        _rf_att.attenuator_ports[12],
    ],
)

_gnb358_du = DU(airscale=_gnb358_airscale, rus=[_gnb358_du_rm69])

_gnb358 = ClassicalBts(cu=_gnb358_cu, dus=[_gnb358_du])
# ---------------- END gNB-2 ------------------------

# ---------------- START eNB-1 ------------------------ eNB_357

_enb357_capu = CapacityUnit(addr="192.168.253.20")

_enb357_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.47.201.200", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_enb357_capu],
    pdu_port=_comu_pdu.pdu_ports[3],
)

_enb357_rm_01 = RU(
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
        _rf_att.attenuator_ports[7],
        _rf_att.attenuator_ports[8],
    ],
)

_enb357_rm_02 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_comu_pdu.pdu_ports[1],
    radio_type="FRHC",
    attenuation_ports=[
        _rf_att.attenuator_ports[5],
        _rf_att.attenuator_ports[6],
    ],
)

_enb357_airscale = Airscale(common_units=[_enb357_comu])

_enb357 = RealEnb(
    system_module=_enb357_airscale,
    rms=[
        _enb357_rm_01,
        _enb357_rm_02,
    ],
)
# ---------------- END eNB-1 ------------------------

# ---------------- START eNB-2 ------------------------ eNB_358

_enb358_capu = CapacityUnit(addr="192.168.253.20")

_enb358_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.47.201.198", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_enb358_capu],
    pdu_port=_comu_pdu.pdu_ports[4],
)

_enb358_rm1 = RU(
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
        _rf_att.attenuator_ports[15],
        _rf_att.attenuator_ports[16],
    ],
)

_enb358_airscale = Airscale(common_units=[_enb358_comu])

_enb358 = RealEnb(system_module=_enb358_airscale, rms=[_enb358_rm1])
# ---------------- END eNB-2 ------------------------

# ---------------- START QC UE1 ------------------------
_ue_ctrl_pc1_ssh_details = SshServiceDetails(
    addr="10.46.134.57", username="deul5g", password="Nuc2Ue4PzLab!"
)
_appserver_ssh = SshServiceDetails(
    addr="10.47.194.212", username="ute", password="UTE.debian12"
)

_iperf_UE = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    iperf_version="2",
)
_app_server_1 = TafUeAppServer(
    app_server_name="DEUL5Gappsrv12",
    address="10.47.194.212",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.212",
    binary_path="iperf",
    ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254],
)


_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, version=2
)


_qualcomm_357_PDU = Gude(
    addr="10.46.134.205",
    port_numbers=[11],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_qualcomm_357 = TafUeAndroid(
    serial_number="b0cb02bb",
    ue_pc_address="10.46.134.57",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc1_ssh_details,
    ue_pc_port="8080",
    pdu_port=_comu_pdu.pdu_ports[11],
)

# ---------------- END QC UE1 ------------------------

# ---------------- START QC UE2 ------------------------
_ue_ctrl_pc_2_ssh_details = SshServiceDetails(
    addr="10.46.134.58", username="deul5g", password="Nuc2Ue4PzLab!"
)


_qualcomm_358_PDU = Gude(
    addr="10.46.134.205",
    port_numbers=[12],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_qualcomm_358 = TafUeAndroid(
    serial_number="87219772",
    ue_pc_address="10.46.134.58",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc_2_ssh_details,
    ue_pc_port="8080",
    pdu_port=_comu_pdu.pdu_ports[12],
)
# ---------------- END QC UE2 ------------------------

# ---------------- START IPSL ------------------------
_ips_ssh = SshServiceDetails(
    addr="10.44.32.17", username="deul5g", password="Nuc2Ue4PzLab!"
)
_tampereCore = RealCore(ips=IPS(ssh_connection_details=_ips_ssh), mcc="555", mnc="10")

# ---------------- END IPSL ------------------------

# ---------------- START TEST PCs --------------------
_gNB357_testpc1_ssh = SshServiceDetails(
    addr="10.47.201.243", username="ute", password="UTE.debian12"
)
_gNB357_testpc1 = TestPc(
    default_ssh_connection_details=_gNB357_testpc1_ssh, connections=[_enb357]
)

_eNB357_testpc2_ssh = SshServiceDetails(
    addr="10.47.201.244", username="ute", password="UTE.debian12"
)
_eNB357_testpc2 = TestPc(
    default_ssh_connection_details=_eNB357_testpc2_ssh, connections=[_enb357]
)

_gNB358_testpc3_ssh = SshServiceDetails(
    addr="10.47.201.245", username="ute", password="UTE.debian12"
)
_gNB358_testpc3 = TestPc(
    default_ssh_connection_details=_gNB358_testpc3_ssh, connections=[_gnb358]
)

_eNB358_testpc4_ssh = SshServiceDetails(
    addr="10.47.201.246", username="ute", password="UTE.debian12"
)
_eNB358_testpc4 = TestPc(
    default_ssh_connection_details=_eNB358_testpc4_ssh, connections=[_enb358]
)
# ---------------- END TEST PCs ----------------------

tl = TestLine(
    test_pc=_gNB357_testpc1,
    test_pcs=[_gNB357_testpc1, _eNB357_testpc2, _gNB358_testpc3, _eNB358_testpc4],
    gnbs=[_gnb357, _gnb358],
    enbs=[_enb357, _enb358],
    pdus=[_comu_pdu, _rf_pdu1, _rf_pdu2],
    core=_tampereCore,
    ues=[_qualcomm_357, _qualcomm_358],
    appserver=_core_appserver,
    attenuator=[_rf_att],
    tl_cloud_topology="CLASSICAL_5G",
)

__all__ = ["tl"]
