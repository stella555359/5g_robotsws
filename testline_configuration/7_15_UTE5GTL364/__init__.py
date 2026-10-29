######################################
#  TestLine 364 Ulm                  #
######################################
__maintainer__ = "MN RAN RD VRF ULM 2 (L05)"
__team__ = "MN RAN RD VRF ULM 2 (L05)"
__email__ = "i_mn_ran_rd_vrf_ulm_vt2@internal.nsn.com"

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
from taf.config.testline.pdn import PDN, PDPTypes
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeMtk


_tampereCore = RealCore4G(mcc="555", mnc="10")

_rf_att = HBTE(
    ip_addr="10.46.134.150",
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


_rf_att_2 = HBTE(
    ip_addr="10.46.134.198",
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
_pdns = [
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi1.nokia.com.mnc001.mcc540.gprs"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi2.nokia.com.mnc001.mcc540.gprs"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsa"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi3.nokia.com.mnc001.mcc540.gprs"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsaslicemqi1.mnc001.mcc540.gprs"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi1.nokia.com.mnc007.mcc244.gprs"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsaslicemqi2.mnc007.mcc244.gprs"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi3.nokia.com.mnc007.mcc244.gprs"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi2.nokia.com.mnc007.mcc244.gprs"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi4.nokia.com.mnc001.mcc540.gprs"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi5.nokia.com.mnc001.mcc540.gprs"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi4.nokia.com.mnc007.mcc244.gprs"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsagbr1.nokia.com"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi5.nokia.com.mnc007.mcc244.gprs"),
]

# ---------------- START gnb-1 ------------------------ gnb_364-1

_gNB364_comu_pdu = Gude(
    addr="10.46.134.215",
    port_numbers=[3],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_gNB364_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.202.201",
        routing_v4=RoutingInformation(
            gateway="10.47.202.222", destIpAddr="10.47.202.192/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.202.201", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.202.201", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.202.202"),
    x2u=NetworkAddress(v4="10.47.202.203"),
    s1u=NetworkAddress(v4="10.47.202.203"),
)

_gNB364_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIO")

_gNB364_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB364_capu1],
    pdu_port=_gNB364_comu_pdu.pdu_ports[3],
    hardware_type="ASIL",
)

_gNB364_airscale = Airscale(common_units=[_gNB364_comu])

_rf_pdu1 = Gude(
    addr="10.46.134.217",
    port_numbers=[3, 5, 6, 7, 8, 11],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_rf_pdu2 = Gude(
    addr="10.46.134.218",
    port_numbers=[1, 3, 4, 6],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)


_gNB364_AHLOA_27 = RU(
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


_gNB364_AHLOA_11 = RU(
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
        _rf_att.attenuator_ports[3],
        _rf_att.attenuator_ports[4],
    ],
)


_gNB364_AHLOA_03 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu1.pdu_ports[7],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att.attenuator_ports[5],
        _rf_att.attenuator_ports[6],
    ],
)


_gNB364_AHFIB_40 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu1.pdu_ports[5],
    radio_type="AHFIB",
    attenuation_ports=[
        _rf_att.attenuator_ports[9],
        _rf_att.attenuator_ports[10],
        _rf_att.attenuator_ports[11],
        _rf_att.attenuator_ports[12],
    ],
)

_gNB364_AHFIB_38 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu1.pdu_ports[7],
    radio_type="AHFIB",
    attenuation_ports=[
        _rf_att.attenuator_ports[13],
        _rf_att.attenuator_ports[14],
        _rf_att.attenuator_ports[15],
        _rf_att.attenuator_ports[16],
    ],
)

_gNB364_AHFIB_37 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu1.pdu_ports[8],
    radio_type="AHFIB",
    attenuation_ports=[
        _rf_att.attenuator_ports[17],
        _rf_att.attenuator_ports[18],
        _rf_att.attenuator_ports[19],
        _rf_att.attenuator_ports[20],
    ],
)

_gNB364_AKQJ_26 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu1.pdu_ports[5],
    radio_type="AKQJ",
    attenuation_ports=[
        _rf_att.attenuator_ports[21],
        _rf_att.attenuator_ports[22],
        _rf_att.attenuator_ports[21],
        _rf_att.attenuator_ports[22],
        _rf_att.attenuator_ports[23],
        _rf_att.attenuator_ports[24],
    ],
)

_gNB364_AKQJ_03 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu1.pdu_ports[8],
    radio_type="AKQJ",
    attenuation_ports=[
        _rf_att.attenuator_ports[25],
        _rf_att.attenuator_ports[26],
        _rf_att.attenuator_ports[25],
        _rf_att.attenuator_ports[26],
        _rf_att.attenuator_ports[27],
        _rf_att.attenuator_ports[28],
    ],
)


_gNB364_du = DU(
    airscale=_gNB364_airscale,
    rus=[
        _gNB364_AHLOA_27,
        _gNB364_AHLOA_11,
        _gNB364_AHLOA_03,
        _gNB364_AHFIB_40,
        _gNB364_AHFIB_38,
        _gNB364_AHFIB_37,
        _gNB364_AKQJ_26,
        _gNB364_AKQJ_03,
    ],
)

_gNB364 = ClassicalBts(cu=_gNB364_cu, dus=[_gNB364_du])
# ---------------- END gnb-1 ------------------------

# ---------------- START gnb-2 ------------------------ gnb_364-2
_gNB364_2_comu_pdu = Gude(
    addr="10.46.134.215",
    port_numbers=[5],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_gNB364_2_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.202.211",
        routing_v4=RoutingInformation(
            gateway="10.47.202.222", destIpAddr="10.47.202.192/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.202.211", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.202.211", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.202.212"),
    x2u=NetworkAddress(v4="10.47.202.213"),
    s1u=NetworkAddress(v4="10.47.202.213"),
)

_gNB364_2_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")

_gNB364_2_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB364_2_capu1],
    pdu_port=_gNB364_2_comu_pdu.pdu_ports[5],
    hardware_type="ASIL",
)

_gNB364_2_airscale = Airscale(common_units=[_gNB364_2_comu])


_gNB364_AHLOA_10 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu1.pdu_ports[11],
    radio_type="AHLOA",
    attenuation_ports=[
        _rf_att_2.attenuator_ports[3],
        _rf_att_2.attenuator_ports[4],
        _rf_att_2.attenuator_ports[5],
        _rf_att_2.attenuator_ports[6],
    ],
)
_gNB364_AHFIB_36 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu1.pdu_ports[8],
    radio_type="AHFIB",
    attenuation_ports=[
        _rf_att_2.attenuator_ports[1],
        _rf_att_2.attenuator_ports[2],
    ],
)
_gNB364_AKQJ_24 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu1.pdu_ports[11],
    radio_type="AKQJ",
    attenuation_ports=[
        _rf_att_2.attenuator_ports[7],
        _rf_att_2.attenuator_ports[8],
        _rf_att_2.attenuator_ports[7],
        _rf_att_2.attenuator_ports[8],
        _rf_att_2.attenuator_ports[9],
        _rf_att_2.attenuator_ports[10],
    ],
)


_gNB364_2_du = DU(
    airscale=_gNB364_2_airscale,
    rus=[_gNB364_AHLOA_10, _gNB364_AHFIB_36, _gNB364_AKQJ_24],
)

_gNB364_2 = ClassicalBts(cu=_gNB364_2_cu, dus=[_gNB364_2_du])
# ---------------- END gnb-2 ------------------------

# ---------------- START eNB-1 ------------------------ eNB_364
_eNB364_comu_pdu = Gude(
    addr="10.46.134.215",
    port_numbers=[4],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_eNB364_capu = CapacityUnit(addr="192.168.253.20")

_eNB364_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB364_capu],
    pdu_port=_eNB364_comu_pdu.pdu_ports[4],
)

_eNB_rf_pdu = Gude(
    addr="10.46.134.215",
    port_numbers=[1, 2],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)


_eNB364_rm1 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_eNB_rf_pdu.pdu_ports[1],
    radio_type="FRHC",
    attenuation_ports=[
        _rf_att.attenuator_ports[29],
        _rf_att.attenuator_ports[30],
        _rf_att.attenuator_ports[31],
        _rf_att.attenuator_ports[32],
    ],
)


_eNB364_airscale = Airscale(common_units=[_eNB364_comu])

_eNB364 = RealEnb(
    system_module=_eNB364_airscale,
    rms=[
        _gNB364,
        _gNB364_AHLOA_27,
        _gNB364_AHLOA_11,
        _gNB364_AHLOA_03,
        _gNB364_AHFIB_40,
        _gNB364_AHFIB_38,
        _gNB364_AHFIB_37,
        _eNB364_rm1,
    ],
    oam_ip=NetworkAddress(v4="10.47.202.200"),
)
# ---------------- END eNB-1 ------------------------


# ---------------- START TAF_UE_PROXY UEs ----------------


_app_server_1 = TafUeAppServer(
    app_server_name="DEUL5GAPPSRV21",
    address="10.47.194.224",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.224",
    binary_path="iperf",
    ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254],
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, version=2
)

_mtk_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    interval=1,
    binary_path="/data/local/tmp/iperf",
    version=2,
)


_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.135.65", username="deul5g", password="Nuc2Ue4PzLab!"
)


_ue2_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.135.66", username="deul5g", password="Nuc2Ue4PzLab!"
)


_Qualcomm_SDX80_68 = TafUeAndroid(
    serial_number="cbe698fc",
    ue_pc_address="10.46.135.65",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE", "UE_1"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc_ssh_details,
    ue_pc_port="8080",
)

###Mediatek#60 M90
_Mediatek_M90_60 = TafUeAndroid(
    serial_number="0123456789ABCDEF",
    ue_pc_address="10.46.135.66",
    capabilities=["REAL_UE", "REAL_MTK", "UE2", "UE_2", "MTK"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.46.135.66", username="deul5g", password="Nuc2Ue4PzLab!"
    ),
    ue_pc_port="1234",
)

# _mtk2 = TafUeMtk(
#    ue_pc_address="10.46.135.66",
#    ue_pc_port=1234,
#    serial_number="0123456789ABCDEF",
#    data_transfer=[_mtk_data_transfer_iperf],
#    com_port="auto",
#    edb_file_path="auto",
#    log_filter="2.Gen98_Default_Standard",
#    imei="35190103413008",
#    imsi="540017000001021",
#    pdns=_pdns,
#    default_pdn_name="ulmsa",
#    capabilities=["REAL_UE", "REAL_MTK_UE2", "MTK_UE2", "UE_2"],
# )
# ---------------- STOP TAF_UE_PROXY UEs ----------------

_core_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.47.194.224", username="ute", password="UTE.debian12"
    ),
    network_interface_address="10.47.194.224",
    iperf_path="/usr/bin/iperf",
)

_core_appserver = AppServer(iperf_details=_core_iperf)

# ---------------- START TEST PCs ------------------------

_testpc1_ssh = SshServiceDetails(addr="10.47.202.165", username="ute", password="ute")
_testpc1 = TestPc(default_ssh_connection_details=_testpc1_ssh, connections=[_gNB364])

_testpc2_ssh = SshServiceDetails(addr="10.47.202.166", username="ute", password="ute")
_testpc2 = TestPc(default_ssh_connection_details=_testpc2_ssh, connections=[_eNB364])

_testpc3_ssh = SshServiceDetails(addr="10.47.202.167", username="ute", password="ute")
_testpc3 = TestPc(default_ssh_connection_details=_testpc3_ssh, connections=[_gNB364_2])


# ---------------- END TEST PCs ------------------------

tl = TestLine(
    test_pc=_testpc1,
    test_pcs=[_testpc1, _testpc2, _testpc3],
    gnbs=[_gNB364, _gNB364_2],
    enbs=[_eNB364],
    pdus=[
        _gNB364_comu_pdu,
        _gNB364_2_comu_pdu,
        _eNB364_comu_pdu,
        _eNB_rf_pdu,
    ],
    core=_tampereCore,
    ues=[_Qualcomm_SDX80_68, _Mediatek_M90_60],
    appserver=_core_appserver,
    attenuators=[_rf_att, _rf_att_2],
    tl_cloud_topology="CLASSICAL_5G",
)

__all__ = ["tl"]
