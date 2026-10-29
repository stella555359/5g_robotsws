######################################
#  TestLine 383 Ulm                  #
######################################
__maintainer__ = "MN ECE ULM R&D L3NRT 07 SqdGp63"
__team__ = "MN 5G&SC PZ ULM 2 SqdGp63"
__email__ = "I_MN_5GSC_PZ_ULM_SQD_63@nokia.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import AppServer
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.core import RealCore4G
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.attenuator import HBTE

from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt

_tampereCore = RealCore4G(mcc="555", mnc="10")

_rf_att = HBTE(
    ip_addr="10.46.134.195",
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

_snmp_user_data = dict(
    userName="user",
    authKey="qwer2009!",
    privKey="qwer2009!",
    authProtocol="SHA",
    privProtocol="AES",
)

_comu_pdu = Gude(
    addr="10.46.134.75",
    port_numbers=[1, 2, 3, 4, 5, 6, 9, 10, 11, 12],
    version="8221-1",
)

_rf_pdu1 = Gude(addr="10.46.134.77", port_numbers=[3, 4, 9, 10], version="8221-1")

_rf_pdu2 = Gude(addr="10.46.134.79", port_numbers=[3, 4, 9, 10], version="8221-1")

# ---------------- START gnb-1 ------------------------ gnb_383-1

_gNB383_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.207.201",
        routing_v4=RoutingInformation(
            gateway="10.47.207.222", destIpAddr="10.47.207.192/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.207.201", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.207.201", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.207.202"),
    x2u=NetworkAddress(v4="10.47.207.203"),
    s1u=NetworkAddress(v4="10.47.207.203"),
)

_gNB383_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")],
    pdu_port=_comu_pdu.pdu_ports[5],
    hardware_type="ASIL",
)

_gNB383_airscale = Airscale(common_units=[_gNB383_comu])

_gNB383_rm_42 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu1.pdu_ports[3],
    radio_type="AHFIB",
    attenuation_ports=[
        _rf_att.attenuator_ports[1],
        _rf_att.attenuator_ports[2],
        _rf_att.attenuator_ports[3],
        _rf_att.attenuator_ports[4],
    ],
)

_gNB383_rm_43 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu1.pdu_ports[4],
    radio_type="AHFIB",
    attenuation_ports=[
        _rf_att.attenuator_ports[5],
        _rf_att.attenuator_ports[6],
        _rf_att.attenuator_ports[7],
        _rf_att.attenuator_ports[8],
    ],
)

_gNB383_rm_48 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu1.pdu_ports[9],
    radio_type="AHFIB",
    attenuation_ports=[
        _rf_att.attenuator_ports[9],
        _rf_att.attenuator_ports[10],
        _rf_att.attenuator_ports[11],
        _rf_att.attenuator_ports[12],
    ],
)

_gNB383_rm_28 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu2.pdu_ports[4],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att.attenuator_ports[13],
        _rf_att.attenuator_ports[14],
        _rf_att.attenuator_ports[15],
        _rf_att.attenuator_ports[16],
    ],
)

_gNB383_rm_26 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu2.pdu_ports[3],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att.attenuator_ports[17],
        _rf_att.attenuator_ports[18],
        _rf_att.attenuator_ports[19],
        _rf_att.attenuator_ports[20],
    ],
)

_gNB383_rm_60 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu2.pdu_ports[10],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att.attenuator_ports[21],
        _rf_att.attenuator_ports[22],
        _rf_att.attenuator_ports[23],
        _rf_att.attenuator_ports[24],
    ],
)

_gNB383_du = DU(
    airscale=_gNB383_airscale,
    rus=[
        _gNB383_rm_42,
        _gNB383_rm_43,
        _gNB383_rm_48,
        _gNB383_rm_28,
        _gNB383_rm_26,
        _gNB383_rm_60,
    ],
)
_gNB383 = ClassicalBts(cu=_gNB383_cu, dus=[_gNB383_du])

# ---------------- END gnb-1 ------------------------

# ---------------- START gnb-2 ------------------------ gnb_383-2

_gNB383_2_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.207.205",
        routing_v4=RoutingInformation(
            gateway="10.47.207.222", destIpAddr="10.47.207.192/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.207.205", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.207.205", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.207.206"),
    x2u=NetworkAddress(v4="10.47.207.207"),
    s1u=NetworkAddress(v4="10.47.207.207"),
)

_gNB383_2_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")],
    pdu_port=_comu_pdu.pdu_ports[5],
    hardware_type="ASIL",
)

_gNB383_2_airscale = Airscale(common_units=[_gNB383_2_comu])

_gNB383_2_rm_49 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu1.pdu_ports[10],
    radio_type="AHFIB",
    attenuation_ports=[
        _rf_att.attenuator_ports[25],
        _rf_att.attenuator_ports[26],
        _rf_att.attenuator_ports[27],
        _rf_att.attenuator_ports[28],
    ],
)

_gNB383_2_rm_59 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu2.pdu_ports[9],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att.attenuator_ports[29],
        _rf_att.attenuator_ports[30],
        _rf_att.attenuator_ports[31],
        _rf_att.attenuator_ports[32],
    ],
)

_gNB383_2_du = DU(
    airscale=_gNB383_airscale,
    rus=[
        _gNB383_2_rm_49,
        _gNB383_2_rm_59,
    ],
)

_gNB383_2 = ClassicalBts(cu=_gNB383_2_cu, dus=[_gNB383_2_du])

# ---------------- END gnb-2 ------------------------

# ---------------- START eNB-1 ------------------------ eNB_383

_eNB383_capu = CapacityUnit(addr="192.168.253.20")

_eNB383_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.47.207.200", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB383_capu],
    pdu_port=_comu_pdu.pdu_ports[4],
)

_eNB383_rm = RU(
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

_eNB383_airscale = Airscale(common_units=[_eNB383_comu])

_eNB383 = RealEnb(
    system_module=_eNB383_airscale,
    rms=[_eNB383_rm],
    oam_ip=NetworkAddress(v4="10.47.207.200"),
)

# ---------------- END eNB-1 ------------------------

# ---------------- START eNB-2 ------------------------eNB_383_2

_eNB383_2_capu = CapacityUnit(addr="192.168.253.20")

_eNB383_2_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.47.207.204", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB383_capu],
    pdu_port=_comu_pdu.pdu_ports[6],
)

_eNB383_2_rm = RU(
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

_eNB383_2_airscale = Airscale(common_units=[_eNB383_2_comu])

_eNB383_2 = RealEnb(
    system_module=_eNB383_2_airscale,
    rms=[_eNB383_2_rm],
    oam_ip=NetworkAddress(v4="10.47.207.204"),
)
# ---------------- END eNB-2 --------------------------

# ---------------- START TAF_UE_PROXY UEs ----------------

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.47.194.227",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.227",
)


_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, version=2
)

_ue_ctrl_pc1_ssh_details = SshServiceDetails(
    addr="10.46.135.99", username="deul5g", password="Nuc2Ue4PzLab!"
)

_Qualcomm43_sdx65 = TafUeAndroid(
    serial_number="d18b9dd2",
    ue_pc_address="10.46.135.99",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE", "UE_1"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc1_ssh_details,
    ue_pc_port="8080",
    pdu_port=_comu_pdu.pdu_ports[10],
)

_ue_ctrl_pc2_ssh_details = SshServiceDetails(
    addr="10.46.135.100", username="deul5g", password="Nuc2Ue4PzLab!"
)

_Qualcomm44_sdx65 = TafUeAndroid(
    serial_number="a0c4c0d5",
    ue_pc_address="10.46.135.100",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE", "UE_2"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc2_ssh_details,
    ue_pc_port="8080",
    pdu_port=_comu_pdu.pdu_ports[9],
)

_ue_ctrl_pc3_ssh_details = SshServiceDetails(
    addr="10.46.135.101", username="deul5g", password="Nuc2Ue4PzLab!"
)

_Qualcomm19_sdx55 = TafUeAndroid(
    serial_number="4ab8873e",
    ue_pc_address="10.46.135.101",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE", "UE_3"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc3_ssh_details,
    ue_pc_port="8080",
    pdu_port=_comu_pdu.pdu_ports[11],
)

_ue_ctrl_pc4_ssh_details = SshServiceDetails(
    addr="10.46.135.102", username="deul5g", password="Nuc2Ue4PzLab!"
)

_Askey37_sdx55 = TafUeAt(
    serial_number="",  # needs to be updated
    com_port="6",
    ue_pc_address="10.46.135.32",
    ue_pc_login="deul5g",
    ue_pc_password="Nuc2Ue4PzLab!",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "UE_4"],
    data_transfer=[_data_transfer_iperf],
    ue_pc_port="8080",
    pdu_port=_comu_pdu.pdu_ports[12],
    ue_pc_expected_prompt="DEUL5G@DEUL5GNUC1-372$",
    imsi="555107000000137",  # needs to be updated
)

# ---------------- STOP TAF_UE_PROXY UEs ----------------

_core_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.47.194.227", username="ute", password="UTE.debian12"
    ),
    iperf_path="/usr/bin/iperf",
    network_interface_address="10.47.194.227",
    iperf_version="2",
)

_core_appserver = AppServer(iperf_details=_core_iperf)

# ---------------- TEST PC ---------------------------

_testpc1_ssh = SshServiceDetails(
    addr="10.47.207.241", username="ute", password="UTE.debian12"
)
_testpc1 = TestPc(default_ssh_connection_details=_testpc1_ssh, connections=[_gNB383])

_testpc2_ssh = SshServiceDetails(
    addr="10.47.207.242", username="ute", password="UTE.debian12"
)
_testpc2 = TestPc(default_ssh_connection_details=_testpc2_ssh, connections=[_eNB383])

_testpc3_ssh = SshServiceDetails(
    addr="10.47.207.243", username="ute", password="UTE.debian12"
)
_testpc3 = TestPc(default_ssh_connection_details=_testpc3_ssh, connections=[_gNB383_2])

_testpc4_ssh = SshServiceDetails(
    addr="10.47.207.244", username="ute", password="UTE.debian12"
)
_testpc4 = TestPc(default_ssh_connection_details=_testpc4_ssh, connections=[_eNB383_2])

# ---------------- END TEST PC -----------------------

tl = TestLine(
    test_pc=_testpc1,
    test_pcs=[_testpc1, _testpc2, _testpc3, _testpc4],
    gnbs=[_gNB383, _gNB383_2],
    enbs=[_eNB383, _eNB383_2],
    pdus=[
        _comu_pdu,
        _rf_pdu1,
        _rf_pdu2,
    ],
    core=_tampereCore,
    ues=[_Qualcomm43_sdx65, _Qualcomm44_sdx65, _Qualcomm19_sdx55, _Askey37_sdx55],
    appserver=_core_appserver,
    attenuators=[
        _rf_att,
    ],
    tl_cloud_topology="CLASSICAL_5G",
)

__all__ = ["tl"]
