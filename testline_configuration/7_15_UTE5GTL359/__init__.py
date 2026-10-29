######################################
#  TestLine 359 Ulm                  #
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
from taf.config.testline.pdn import PDN, PDPTypes

from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import RealEnb
from taf.config.testline import RoutingInformation
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.attenuator import HBTE
from taf.config.testline.core import RealCore
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeMtk
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt


__all__ = ["tl"]

_testpc_ssh = SshServiceDetails(
    addr="7-15-UTE5GTL359-1.ulm.nsn-rdnet.net", username="ute", password="UTE.debian12"
)
_testpc = TestPc(default_ssh_connection_details=_testpc_ssh)


_snmp_user_data = dict(
    userName="user",
    authKey="qwer2009!",
    privKey="qwer2009!",
    authProtocol="SHA",
    privProtocol="AES",
)

# ---------------- START gNB-1 ------------------------ gNB_359
_comu_pdu = Gude(
    addr="10.46.134.202",
    port_numbers=[1, 2, 3, 4, 5, 7, 11, 12],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)
_rf_pdu = Gude(
    addr="10.46.134.206",
    port_numbers=[5, 8],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_rf_pdu_2 = Gude(
    addr="10.46.134.216",
    port_numbers=[7],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)
_rf_att = HBTE(
    ip_addr="10.46.134.147",
    port="5000",
    attenuation_port_numbers=[1, 2, 3, 4, 7, 8, 9, 10, 15, 16],
    version=None,
    model="PA-16-16-6-127-0.5-B-S",
)

_cu1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.201.71",
        routing=RoutingInformation(gateway="10.47.201.222", ip_prefix_length=27),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.201.71", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.201.71", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.201.72"),
    x2u=NetworkAddress(v4="10.47.201.73"),
    s1u=NetworkAddress(v4="10.47.201.73"),
)

_gnb1_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")

_gnb1_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gnb1_capu1],
    pdu_port=_comu_pdu.pdu_ports[5],
    hardware_type="ASIK",
)
_gnb1_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.201.74",
        routing=RoutingInformation(gateway="10.47.201.222", ip_prefix_length=27),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.201.74", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.201.74", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.201.75"),
    x2u=NetworkAddress(v4="10.47.201.76"),
    s1u=NetworkAddress(v4="10.47.201.76"),
)

_gnb1_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")

_gnb1_airscale = Airscale(common_units=[_gnb1_comu])
# B6:ALHOA #12

_gnb1_du_rm14 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu.pdu_ports[5],
    radio_type="AHCA",
    attenuation_ports=[
        _rf_att.attenuator_ports[1],
        _rf_att.attenuator_ports[2],
    ],
)

_gnb1_du_rm37 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu_2.pdu_ports[7],
    radio_type="AHCA",
    attenuation_ports=[
        _rf_att.attenuator_ports[3],
        _rf_att.attenuator_ports[4],
    ],
)

du1 = DU(airscale=_gnb1_airscale, rus=[_gnb1_du_rm14, _gnb1_du_rm37])

_gnb1 = ClassicalBts(cu=_cu1, dus=[du1])

# ---------------- END gNB-1 ------------------------

# ---------------- START gNB-2 ------------------------ gNB_360

_gnb2_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.201.74",
        routing=RoutingInformation(gateway="10.47.201.222", ip_prefix_length=27),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.201.74", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.201.74", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.201.75"),
    x2u=NetworkAddress(v4="10.47.201.76"),
    s1u=NetworkAddress(v4="10.47.201.76"),
)

_gnb2_capu = CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")

_gnb2_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gnb2_capu],
    pdu_port=_comu_pdu.pdu_ports[7],
    hardware_type="ASIK",
)

_gnb2_airscale = Airscale(common_units=[_gnb2_comu])
# B6:ALHOA #2

_gnb2_du_rm17 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu.pdu_ports[8],
    radio_type="ALHOA",
    attenuation_ports=[
        _rf_att.attenuator_ports[9],
        _rf_att.attenuator_ports[10],
    ],
)

_gnb2_du = DU(airscale=_gnb2_airscale, rus=[_gnb2_du_rm17])

_gnb2 = ClassicalBts(cu=_gnb2_cu, dus=[_gnb2_du])

# ---------------- START eNB-1 ------------------------ eNB_359

_enb1_capu = CapacityUnit(addr="192.168.253.20")

_enb1_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.47.201.70", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_enb1_capu],
    pdu_port=_comu_pdu.pdu_ports[3],
)

_enb1_rm1 = RU(
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
        _rf_att.attenuator_ports[7],
        _rf_att.attenuator_ports[8],
    ],
)

_enb1_airscale = Airscale(common_units=[_enb1_comu])

_enb1 = RealEnb(
    system_module=_enb1_airscale,
    rms=[_enb1_rm1],
    oam_ip=NetworkAddress(v4="10.47.201.70"),
)
# ---------------- STOP eNB-1 ------------------------

# ---------------- START eNB-2 ------------------------ eNB_360

_enb2_capu = CapacityUnit(addr="192.168.253.20")

_enb2_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.47.201.65", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_enb2_capu],
    pdu_port=_comu_pdu.pdu_ports[4],
)

_enb2_rm1 = RU(
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

_enb2_airscale = Airscale(common_units=[_enb2_comu])

_enb2 = RealEnb(system_module=_enb2_airscale, rms=[_enb2_rm1])
# ---------------- STOP eNB-2 ------------------------


_pdns = [
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi1.nokia.com"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi2.nokia.com"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsa"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi3.nokia.com.mnc001.mcc540.gprs"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsaslicemqi1"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi1.nokia.com.mnc007.mcc244.gprs"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsaslicemqi2.mnc007.mcc244.gprs"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi3.nokia.com.mnc007.mcc244.gprs"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi2.nokia.com.mnc007.mcc244.gprs"),
]

_tampereCore = RealCore(mcc="540", mnc="01", pdns=_pdns)

# ---------------- START QC UE1 and MTK UE3  ------------------------

_ue1_ctrl_pc_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC1-359.intra.noklab.net", username="deul5g", password="Nuc2Ue4PzLab!"
)


_appserver_ssh = SshServiceDetails(
    addr="10.44.35.224", username="ute", password="UTE.debian12"
)

_iperf_UE = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    iperf_version="2",
)
_app_server_1 = TafUeAppServer(
    app_server_name="DEUL5Gappsrv24",
    address="10.44.35.224",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.44.35.224",
    binary_path="iperf",
    ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254],
)


_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, version=2
)


_qualcomm_51_PDU = Gude(
    addr="10.46.134.202",
    port_numbers=[12],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_qualcomm_51 = TafUeAndroid(
    serial_number="b0cb02bb",
    ue_pc_address="10.46.135.76",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue1_ctrl_pc_ssh_details,
    ue_pc_port="8080",
    pdu_port=_comu_pdu.pdu_ports[12],
)


_ue3_ctrl_pc_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC3-359.intra.noklab.net", username="deul5g", password="Nuc2Ue4PzLab!"
)

_mtk_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    interval=1,
    binary_path="/data/local/tmp/iperf",
    version=2,
)


_mtk2 = TafUeMtk(
    ue_pc_address="10.46.135.77",
    ue_pc_port=1234,
    serial_number="0123456789ABCDEF",
    data_transfer=[_mtk_data_transfer_iperf],
    com_port="auto",
    edb_file_path="auto",
    log_filter="2.Gen98_Default_Standard",
    imei="0123456789ABCDEF",
    imsi="540017000001039",
    pdns=_pdns,
    default_pdn_name="ulmsa",
    capabilities=["REAL_MEDIATEK_UE2", "MTK_UE2"],
)


# ---------------- STOP QC UE1 and MTK UE3 ------------------------

# ---------------- Start ASKEY UE2 ------------------------

_ue2_ctrl_pc_ssh_details = SshServiceDetails(
    addr="DEUL5GNUC2-359.intra.noklab.net", username="deul5g", password="Nuc2Ue4PzLab!"
)

_ASKEY_PDU = Gude(
    addr="10.46.134.202",
    port_numbers=[11],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)


_ASKEY_359 = TafUeAt(
    com_port="5",
    serial_number="4255dddc",
    ue_pc_address="10.46.135.39",
    ue_pc_login="deul5g",
    ue_pc_password="Nuc2Ue4PzLab!",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE"],
    data_transfer=[_data_transfer_iperf],
    ue_pc_port="8080",
    ue_pc_expected_prompt="DEUL5G@DEUL5GNUC2-359",
    imsi="540017000001045",
    pdu_port=_comu_pdu.pdu_ports[11],
)


# ---------------- STOP ASKEY UE2 ------------------------

_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.44.35.224", username="ute", password="ute"
    ),
    network_interface_address="10.44.35.224",
    iperf_path="iperf",
    ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254],
)

_appserver = AppServer(_iperf_details_on_appserver)

tl = TestLine(
    test_pc=_testpc,
    gnbs=[_gnb1, _gnb2],
    enbs=[_enb1, _enb2],
    pdus=[_comu_pdu, _rf_pdu, _rf_pdu_2],
    core=_tampereCore,
    ues=[_qualcomm_51, _ASKEY_359, _mtk2],
    appserver=_appserver,
    attenuator=[_rf_att],
    tl_cloud_topology="CLASSICAL_5G_TYPE",
)
