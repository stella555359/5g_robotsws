######################################
#  TestLine 112 Ulm                   #
######################################
__maintainer__ = "MN ECE RD ULM L2PS 04 SG SQD64"
__team__ = "MN ECE RD ULM L2PS 04 SG SQD64"
__email__ = "I_MN_ECE_ULM_RD_L2PS_04_SG_SQD64_NIMS@internal.nsn.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdn import PDN, PDPTypes
from taf.config.testline import RealEnb
from taf.config.testline import RoutingInformation
from taf.config.testline.core import RealCore
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.ue import TafUeMtk
from taf.config.testline.appserver import AppServer
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.attenuator import HBTE
from taf.config.testline import PDNTafUeAndroidDetails
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid


__all__ = ["tl"]

_snmp_user_data = dict(
    userName="user",
    authKey="qwer2009!",
    privKey="qwer2009!",
    authProtocol="SHA",
    privProtocol="AES",
)

# PDU  port5= GNB TL 112-1
_pdu = Gude(
    addr="10.46.133.42",
    port_numbers=[5, 6, 3, 1],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

cfg_dir = os.path.dirname(os.path.abspath(__file__))

# GNB1

_cu1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.198.135",
        routing_v4=RoutingInformation(
            gateway="10.47.198.158", destIpAddr="10.47.198.128/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.198.135", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.198.135", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4="10.47.198.136"),
    x2u=NetworkAddress(v4="10.47.198.137"),
    s1u=NetworkAddress(v4="10.47.198.137"),
)

_rf_att = HBTE(
    ip_addr="10.46.133.88",
    port="5000",
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    version=None,
    model="PA-16-16-6-127-0.5-B-S",
)


##ABIL
_capacity_unit1 = CapacityUnit(addr="192.168.253.20")

##ASIK
_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_capacity_unit1],
    pdu_port=_pdu.pdu_ports[5],
)

_airscale1 = Airscale(common_units=[_common_unit1])

_gnb1_rf1_pdu = Gude(
    addr="10.46.133.117",
    port_numbers=[5],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_gnb1_rf2_pdu = Gude(
    addr="10.46.133.117",
    port_numbers=[6],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_gnb1_rf3_pdu = Gude(
    addr="10.46.133.43",
    port_numbers=[7],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_gnb1_du_rm1 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb1_rf1_pdu.pdu_ports[5],
    radio_type="AHCA",
    attenuation_ports=[_rf_att.attenuator_ports[1], _rf_att.attenuator_ports[2]],
)

_gnb1_du_rm2 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb1_rf2_pdu.pdu_ports[6],
    radio_type="AHCA",
    attenuation_ports=[_rf_att.attenuator_ports[3], _rf_att.attenuator_ports[4]],
)

_gnb1_du_rm3 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb1_rf3_pdu.pdu_ports[7],
    radio_type="AHLOA",
    attenuation_ports=[_rf_att.attenuator_ports[5], _rf_att.attenuator_ports[6]],
)

_du1 = DU(airscale=_airscale1, rus=[_gnb1_du_rm1, _gnb1_du_rm2, _gnb1_du_rm3])

_gnb1 = ClassicalBts(cu=_cu1, dus=[_du1])

# GNB2

_cu2 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.198.145",
        routing_v4=RoutingInformation(
            gateway="10.47.198.158", destIpAddr="10.47.198.128/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.198.145", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.198.145", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4="10.47.198.146"),
    x2u=NetworkAddress(v4="10.47.198.147"),
    s1u=NetworkAddress(v4="10.47.198.147"),
)

##ABIL
_capacity_unit2 = CapacityUnit(addr="192.168.253.20")

##ASIK
_common_unit2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_capacity_unit2],
    pdu_port=_pdu.pdu_ports[6],
)

_airscale2 = Airscale(common_units=[_common_unit2])

_gnb2_rf_pdu = Gude(
    addr="10.46.133.43",
    port_numbers=[5, 8, 6],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_gnb2_du_rm1 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb2_rf_pdu.pdu_ports[5],
    radio_type="AHCA",
    attenuation_ports=[_rf_att.attenuator_ports[7], _rf_att.attenuator_ports[8]],
)

_gnb2_du_rm2 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb2_rf_pdu.pdu_ports[8],
    radio_type="AHCA",
    attenuation_ports=[_rf_att.attenuator_ports[9], _rf_att.attenuator_ports[10]],
)

_gnb2_du_rm3 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb2_rf_pdu.pdu_ports[6],
    radio_type="AHCA",
    attenuation_ports=[_rf_att.attenuator_ports[11], _rf_att.attenuator_ports[12]],
)


_du2 = DU(airscale=_airscale2, rus=[_gnb2_du_rm1, _gnb2_du_rm2, _gnb2_du_rm3])

_gnb2 = ClassicalBts(cu=_cu2, dus=[_du2])

# -----eNB--------------------------------------------------------------------

_enb_capu = CapacityUnit(addr="192.168.253.36")

_enb_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.47.198.134", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_enb_capu],
    pdu_port=_pdu.pdu_ports[3],
)

_enb_airscale = Airscale(common_units=[_enb_comu])


_enb_ru1 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username="", password=""),
    pdu_port=_pdu.pdu_ports[1],
    radio_type="FXED",
    attenuation_ports=[_rf_att.attenuator_ports[13], _rf_att.attenuator_ports[14]],
)

_enb_ru2 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username="", password=""),
    pdu_port=_pdu.pdu_ports[1],
    radio_type="FXED",
    attenuation_ports=[_rf_att.attenuator_ports[15], _rf_att.attenuator_ports[16]],
)


_enb = RealEnb(
    system_module=_enb_airscale,
    rms=[_enb_ru1, _enb_ru2],
    oam_ip=NetworkAddress(v4="10.47.198.134"),
)

# --- UE ---------------------------------------------------------------------------------------------------

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
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsagbr2.nokia.com"),
]

_tampereCore = RealCore(mcc="540", mnc="01", pdns=_pdns)

##############################UE1###########################################
_mtk_appserver = TafUeAppServer(
    app_server_name="DEUL-appsrv23",
    address="10.44.35.223",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.44.35.223",
    binary_path="iperf",
    ports=[
        50010,
        50006,
        50007,
        50008,
        50009,
        55254,
        55130,
        57254,
        51003,
        51009,
        51109,
        52009,
        51171,
    ],
)

_mtk_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_mtk_appserver,
    interval=1,
    binary_path="/data/local/tmp/iperf",
    version=2,
)



#_mtk1 = TafUeMtk(
#    ue_pc_address="10.46.133.135",
#    ue_pc_port=1234,
#    serial_number="0123456789ABCDEF",
#    data_transfer=[_mtk_data_transfer_iperf],
#    com_port="auto",
#    edb_file_path="auto",
#    imei="0123456789ABCDEF",
#    imsi="540017000001007",
#    pdns=_pdns,
#    default_pdn_name="ulmsa",
#    capabilities=["REAL_UE", "MTK_UE1", "MTK", "UE_1"],
#)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_mtk_appserver, interval=1, version=2
)

_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.133.135", username="deul5g", password="Nuc2Ue4PzLab!"
)

_pdn1 = PDNTafUeAndroidDetails(
    entryName="ulmsa",
    apnName="ulmsa",
    apnType=["DEFAULT", "MMS", "XCAP"],
)
_pdn2 = PDNTafUeAndroidDetails(
    entryName="ulmsamqi4.nokia.com.mnc001.mcc540.gprs",
    apnName="ulmsamqi4.nokia.com.mnc001.mcc540.gprs",
    apnType=["DEFAULT", "MMS", "XCAP"],
)

_mtk1 = TafUeAndroid(
    serial_number="0123456789ABCDEF",
    ue_pc_address="10.46.133.135",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_MTK_UE", "MTK", "UE_1"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc_ssh_details,
    pdns=[_pdn1, _pdn2],
    ue_pc_port="1234",
)

##############################UE2###########################################
_mtk2 = TafUeMtk(
    ue_pc_address="10.46.133.136",
    ue_pc_port=1234,
    serial_number="0123456789ABCDEF",
    data_transfer=[_mtk_data_transfer_iperf],
    com_port="auto",
    edb_file_path="auto",
    log_filter="2.Gen98_Default_Standard",
    imei="0123456789ABCDEF",
    imsi="244070000000518",
    pdns=_pdns,
    default_pdn_name="ulmsa",
    capabilities=["REAL_UE", "MTK_UE2", "UE_2"],
)

_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.44.35.223", username="ute", password="UTE.debian12"
    ),
    network_interface_address="10.44.35.223",
    iperf_path="iperf",
    ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254],
)

_appserver = AppServer(_iperf_details_on_appserver)

# ---------------- START TEST PCs --------------------

_gNB1_testpc1_ssh = SshServiceDetails(
    addr="10.47.198.180", username="ute", password="UTE.debian12"
)
_gNB1_testpc1 = TestPc(
    default_ssh_connection_details=_gNB1_testpc1_ssh, connections=[_gnb1]
)

_gNB2_testpc2_ssh = SshServiceDetails(
    addr="10.47.198.182", username="ute", password="UTE.debian12"
)
_gNB2_testpc2 = TestPc(
    default_ssh_connection_details=_gNB2_testpc2_ssh, connections=[_gnb2]
)

_eNB_testpc3_ssh = SshServiceDetails(
    addr="10.47.198.181", username="ute", password="UTE.debian12"
)
_eNB_testpc3 = TestPc(
    default_ssh_connection_details=_eNB_testpc3_ssh, connections=[_enb]
)

# ---------------- END TEST PCs ----------------------

# --- TL ---------------------------------------------------------------------------------------------------

tl = TestLine(
    test_pc=_gNB1_testpc1,
    test_pcs=[_gNB1_testpc1, _gNB2_testpc2, _eNB_testpc3],
    gnbs=[_gnb1, _gnb2],
    enbs=[_enb],
    pdus=[_pdu, _gnb1_rf1_pdu, _gnb1_rf2_pdu, _gnb1_rf3_pdu, _gnb2_rf_pdu],
    core=_tampereCore,
    ues=[_mtk1, _mtk2],
    appserver=_appserver,
    attenuators=[_rf_att],
    tl_cloud_topology="CLASSICAL_5G_TYPE",
)
