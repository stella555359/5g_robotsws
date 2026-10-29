######################################
#  TestLine 391 Ulm                  #
######################################
__maintainer__ = "MN RAN Pz ULM 2 SqdGp63"
__team__ = "MN RAN Pz ULM 2 SqdGp63"
__email__ = "i_pz_ulm_sqd_63@internal.nsn.com"

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
from taf.config.testline.core import RealCore4G
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.attenuator import HBTE
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid


_tampereCore = RealCore4G(mcc="555", mnc="10")

_rf_att = HBTE(
    ip_addr="10.46.134.194",
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

# ---------------- START gnb-1 ------------------------ gnb_391-1
_comu_pdu = Gude(
    addr="10.46.134.74", port_numbers=[1, 2, 3, 4, 5, 6, 9, 10], version="8221-1"
)

_gNB391_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.207.141",
        routing_v4=RoutingInformation(
            gateway="10.47.207.158", destIpAddr="10.47.207.128/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.207.141", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.207.141", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.207.142"),
    x2u=NetworkAddress(v4="10.47.207.143"),
    s1u=NetworkAddress(v4="10.47.207.143"),
)

_gNB391_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[CapacityUnit(addr="")],
    pdu_port=_comu_pdu.pdu_ports[5],
    hardware_type="ASOE",
)

_gNB391_airscale = Airscale(common_units=[_gNB391_comu])

_gNB391_rf_pdu77 = Gude(addr="10.46.134.77", port_numbers=[1, 2], version="8221-1")
_gNB391_rf_pdu39 = Gude(
    addr="10.46.134.239", port_numbers=[5, 6, 7, 8], version="8221-1"
)
_gNB391_rf_pdu79 = Gude(addr="10.46.134.79", port_numbers=[5, 6], version="8221-1")

_gNB391_rm_39 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB391_rf_pdu77.pdu_ports[2],
    radio_type="AHFIB",
    attenuation_ports=[
        _rf_att.attenuator_ports[1],
        _rf_att.attenuator_ports[2],
        _rf_att.attenuator_ports[3],
        _rf_att.attenuator_ports[4],
    ],
)

_gNB391_rm_52 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB391_rf_pdu39.pdu_ports[8],
    radio_type="AHFIB",
    attenuation_ports=[
        _rf_att.attenuator_ports[5],
        _rf_att.attenuator_ports[6],
        _rf_att.attenuator_ports[7],
        _rf_att.attenuator_ports[8],
    ],
)

_gNB391_rm_53 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB391_rf_pdu39.pdu_ports[7],
    radio_type="AHFIB",
    attenuation_ports=[
        _rf_att.attenuator_ports[9],
        _rf_att.attenuator_ports[10],
        _rf_att.attenuator_ports[11],
        _rf_att.attenuator_ports[12],
    ],
)

_gNB391_rm_50 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB391_rf_pdu79.pdu_ports[5],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att.attenuator_ports[13],
        _rf_att.attenuator_ports[14],
        _rf_att.attenuator_ports[15],
        _rf_att.attenuator_ports[16],
    ],
)

_gNB391_rm_62 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB391_rf_pdu39.pdu_ports[5],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att.attenuator_ports[17],
        _rf_att.attenuator_ports[18],
        _rf_att.attenuator_ports[19],
        _rf_att.attenuator_ports[20],
    ],
)

_gNB391_rm_67 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB391_rf_pdu39.pdu_ports[6],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att.attenuator_ports[21],
        _rf_att.attenuator_ports[22],
        _rf_att.attenuator_ports[23],
        _rf_att.attenuator_ports[24],
    ],
)

_gNB391_du = DU(
    airscale=_gNB391_airscale,
    rus=[
        _gNB391_rm_39,
        _gNB391_rm_52,
        _gNB391_rm_53,
        _gNB391_rm_50,
        _gNB391_rm_62,
        _gNB391_rm_67,
    ],
)

_gNB391 = ClassicalBts(cu=_gNB391_cu, dus=[_gNB391_du])
# ---------------- END gnb-1 ------------------------

# ---------------- START eNB-1 ------------------------ eNB_391

_eNB391_capu = CapacityUnit(addr="192.168.253.20")

_eNB391_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB391_capu],
    pdu_port=_comu_pdu.pdu_ports[3],
)

_eNB391_rm = RU(
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

_eNB391_airscale = Airscale(common_units=[_eNB391_comu])

_eNB391 = RealEnb(
    system_module=_eNB391_airscale,
    rms=[_eNB391_rm],
    oam_ip=NetworkAddress(v4="10.47.207.140"),
)
# ---------------- END eNB-1 ------------------------

# ---------------- START gNB-2 ------------------------ gnb_391-2

_gNB391_2_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.207.145",
        routing_v4=RoutingInformation(
            gateway="10.47.207.158", destIpAddr="10.47.207.128/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.207.145", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.207.145", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="110.47.207.146"),
    x2u=NetworkAddress(v4="10.47.207.147"),
    s1u=NetworkAddress(v4="10.47.207.147"),
)

_gNB391_2_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[CapacityUnit(addr="")],
    pdu_port=_comu_pdu.pdu_ports[6],
    hardware_type="ASOE",
)

_gNB391_airscale = Airscale(common_units=[_gNB391_2_comu])

_gNB391_2_rm_08 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB391_rf_pdu77.pdu_ports[1],
    radio_type="AHFIB",
    attenuation_ports=[
        _rf_att.attenuator_ports[25],
        _rf_att.attenuator_ports[26],
        _rf_att.attenuator_ports[27],
        _rf_att.attenuator_ports[28],
    ],
)

_gNB391_2_rm_56 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB391_rf_pdu79.pdu_ports[6],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att.attenuator_ports[29],
        _rf_att.attenuator_ports[30],
        _rf_att.attenuator_ports[31],
        _rf_att.attenuator_ports[32],
    ],
)

_gNB391_2_du = DU(airscale=_gNB391_airscale, rus=[_gNB391_2_rm_08, _gNB391_2_rm_56])

_gNB391_2 = ClassicalBts(cu=_gNB391_2_cu, dus=[_gNB391_2_du])
# ---------------- END gnb-2 ------------------------

# ---------------- START eNB-2 ------------------------ eNB_391-2
_eNB391_2_capu = CapacityUnit(addr="192.168.253.20")

_eNB391_2_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB391_2_capu],
    pdu_port=_comu_pdu.pdu_ports[4],
)

_eNB391_2_rm = RU(
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

_eNB391_2_airscale = Airscale(common_units=[_eNB391_2_comu])

_eNB391_2 = RealEnb(
    system_module=_eNB391_2_airscale,
    rms=[_eNB391_2_rm],
    oam_ip=NetworkAddress(v4="10.47.207.144"),
)
# ---------------- END eNB-2 ------------------------

# ---------------- START QC UE1 ------------------------

_ue_ctrl_pc1_ssh_details = SshServiceDetails(
    addr="10.46.135.95", username="deul5g", password="Nuc2Ue4PzLab!"
)
_appserver_ssh = SshServiceDetails(addr="tbd", username="ute", password="ute")

_iperf_UE = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    iperf_version="2",
)
# ---------------- END QC UE1 ------------------------

# ---------------- START QC UE2 ------------------------

_ue_ctrl_pc2_ssh_details = SshServiceDetails(
    addr="10.46.135.96", username="deul5g", password="Nuc2Ue4PzLab!"
)

# ---------------- END QC UE2 ------------------------
# ---------------- START TAF_UE_PROXY UEs ----------------

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="tbd",
    user="ute",
    password="ute",
    bind_interface_ip="tbd",
)


_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, version=2
)

_Qualcomm1 = TafUeAndroid(
    serial_number="fb547ae6",
    ue_pc_address="10.46.135.95",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE", "UE_1"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc1_ssh_details,
    ue_pc_port="8080",
    pdu_port=_comu_pdu.pdu_ports[9],
)

_Qualcomm2 = TafUeAndroid(
    serial_number="25f1b8d3",
    ue_pc_address="10.46.135.96",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE", "UE_2"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc2_ssh_details,
    ue_pc_port="8080",
    pdu_port=_comu_pdu.pdu_ports[10],
)


# ---------------- STOP TAF_UE_PROXY UEs ----------------

_core_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="tbd", username="ute", password="ute"
    ),
    network_interface_address="tbd",
    iperf_path="/usr/bin/iperf",
)

_core_appserver = AppServer(iperf_details=_core_iperf)

# ---------------- TEST PC ---------------------------

_testpc1_ssh = SshServiceDetails(addr="10.47.207.181", username="ute", password="ute")
_testpc1 = TestPc(default_ssh_connection_details=_testpc1_ssh, connections=[_gNB391])

_testpc2_ssh = SshServiceDetails(addr="10.47.207.182", username="ute", password="ute")
_testpc2 = TestPc(default_ssh_connection_details=_testpc2_ssh, connections=[_eNB391])

_testpc3_ssh = SshServiceDetails(addr="10.47.207.183", username="ute", password="ute")
_testpc3 = TestPc(default_ssh_connection_details=_testpc3_ssh, connections=[_gNB391_2])

_testpc4_ssh = SshServiceDetails(addr="10.47.207.184", username="ute", password="ute")
_testpc4 = TestPc(default_ssh_connection_details=_testpc4_ssh, connections=[_eNB391_2])

# ---------------- END TEST PC -----------------------

tl = TestLine(
    test_pc=_testpc1,
    test_pcs=[_testpc1, _testpc2, _testpc3, _testpc4],
    gnbs=[_gNB391, _gNB391_2],
    enbs=[_eNB391, _eNB391_2],
    pdus=[
        _comu_pdu,
        _gNB391_rf_pdu39,
        _gNB391_rf_pdu77,
        _gNB391_rf_pdu79,
    ],
    core=_tampereCore,
    ues=[_Qualcomm2],
    appserver=_core_appserver,
    attenuators=[_rf_att],
    tl_cloud_topology="CLASSICAL_5G",
)

__all__ = ["tl"]
