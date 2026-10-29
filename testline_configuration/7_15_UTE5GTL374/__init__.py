######################################
#  TestLine 374 Ulm                  #
######################################
__maintainer__ = "MN ECE RD ULM L2PS 04 SG SQD62"
__team__ = "MN ECE RD ULM L2PS 04 SG SQD62"
__email__ = "I_MN_ECE_ULM_RD_L2PS_04_SG_SQD62_NIMS@internal.nsn.com"

import os
from taf.config.testline.ue import MediaTek
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
from taf.config.testline import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.core import RealCore
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.ue import TafUeMtk
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import AppServer
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.attenuator import HBTE


__all__ = ["tl"]

_snmp_user_data = dict(
    userName="user",
    authKey="qwer2009!",
    privKey="qwer2009!",
    authProtocol="SHA",
    privProtocol="AES",
)

# PDU  port5= GNB TL 374-1
_pdu = Gude(
    addr="10.46.134.221",
    port_numbers=[2, 7, 8, 9],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_cu1 = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.203.81", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.203.81", username="Nemuadmin", password="nemuuser", port=443
    ),
)

_rf_att = HBTE(
    ip_addr="10.46.134.139",
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
    pdu_port=_pdu.pdu_ports[7],
)

_airscale1 = Airscale(common_units=[_common_unit1])

_gnb1_rf_pdu = Gude(
    addr="10.46.134.217",
    port_numbers=[2],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_gnb1_rf_pdu2 = Gude(
    addr="10.46.134.240",
    port_numbers=[6, 7],
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
    pdu_port=_gnb1_rf_pdu2.pdu_ports[6],
    radio_type="AHLOA",
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
    pdu_port=_gnb1_rf_pdu2.pdu_ports[7],
    radio_type="AHLOA",
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
    pdu_port=_gnb1_rf_pdu.pdu_ports[2],
    radio_type="AHFIB",
    attenuation_ports=[_rf_att.attenuator_ports[5], _rf_att.attenuator_ports[6]],
)

_du1 = DU(airscale=_airscale1, rus=[_gnb1_du_rm1, _gnb1_du_rm2, _gnb1_du_rm3])

_gnb1 = ClassicalBts(cu=_cu1, dus=[_du1])

# GNB2

_cu2 = CU(
    backhaul_site_oam_ip="10.47.203.84",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.203.84", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.203.84", username="Nemuadmin", password="nemuuser", port=443
    ),
)

##ABIL
_capacity_unit2 = CapacityUnit(addr="192.168.253.20")

##ASIK
_common_unit2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_capacity_unit2],
    pdu_port=_pdu.pdu_ports[7],
)

_airscale2 = Airscale(common_units=[_common_unit2])

_gnb2_rf_pdu = Gude(
    addr="10.46.134.240",
    port_numbers=[10, 12],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_gnb2_rf_pdu2 = Gude(
    addr="10.46.134.251",
    port_numbers=[1],
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
    pdu_port=_gnb2_rf_pdu.pdu_ports[10],
    radio_type="AHLOA",
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
    pdu_port=_gnb2_rf_pdu.pdu_ports[12],
    radio_type="AHLOA",
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
    pdu_port=_gnb2_rf_pdu2.pdu_ports[1],
    radio_type="AHLOA",
    attenuation_ports=[_rf_att.attenuator_ports[11], _rf_att.attenuator_ports[12]],
)


_du2 = DU(airscale=_airscale2, rus=[_gnb2_du_rm1, _gnb2_du_rm2, _gnb2_du_rm3])

_gnb2 = ClassicalBts(cu=_cu2, dus=[_du2])

# -----eNB--------------------------------------------------------------------

_enb_capu = CapacityUnit(addr="192.168.253.36")

_enb_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_enb_capu],
    pdu_port=_pdu.pdu_ports[8],
)

_enb_airscale = Airscale(common_units=[_enb_comu])

_enb_ru1 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username="", password=""),
    pdu_port=_pdu.pdu_ports[2],
    radio_type="FRHC",
    attenuation_ports=[_rf_att.attenuator_ports[13], _rf_att.attenuator_ports[14]],
)

_enb_ru2 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username="", password=""),
    pdu_port=_pdu.pdu_ports[2],
    radio_type="FRHC",
    attenuation_ports=[_rf_att.attenuator_ports[15], _rf_att.attenuator_ports[16]],
)
_enb = RealEnb(
    system_module=_enb_airscale,
    rms=[_enb_ru1, _enb_ru2],
    oam_ip=NetworkAddress(v4="10.47.203.80"),
)

# --- UE ---------------------------------------------------------------------------------------------------

_testpc1_ssh = SshServiceDetails(
    addr="10.47.203.109", username="ute", password="UTE.debian12"
)
_testpc1 = TestPc(default_ssh_connection_details=_testpc1_ssh, connections=[_gnb1])

_testpc2_ssh = SshServiceDetails(
    addr="10.47.203.110", username="ute", password="UTE.debian12"
)
_testpc2 = TestPc(default_ssh_connection_details=_testpc2_ssh, connections=[_enb])

_testpc3_ssh = SshServiceDetails(
    addr="10.47.203.111", username="ute", password="UTE.debian12"
)
_testpc3 = TestPc(default_ssh_connection_details=_testpc3_ssh, connections=[_gnb2])

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

_app_server_1 = TafUeAppServer(
    app_server_name="DEUL5Gappsrv19",
    address="10.47.194.219",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.219",
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

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    interval=1,
    binary_path="/data/local/tmp/iperf",
    version=2,
)
##############################UE1###########################################

_mtk1 = TafUeMtk(
    ue_pc_address="10.46.135.34",
    ue_pc_port=1234,
    serial_number="0123456789ABCDEF",
    data_transfer=[_data_transfer_iperf],
    com_port="auto",
    edb_file_path="auto",
    imei="0123456789ABCDEF",
    imsi="540017000001045",
    pdns=_pdns,
    default_pdn_name="ulmsa",
    capabilities=["REAL_MEDIATEK_UE", "MTK_UE1"],
)

##############################UE2###########################################
_mtk2 = TafUeMtk(
    ue_pc_address="10.46.135.44",
    ue_pc_port=1234,
    serial_number="0123456789ABCDEF",
    data_transfer=[_data_transfer_iperf],
    com_port="auto",
    edb_file_path="auto",
    log_filter="2.Gen98_Default_Standard",
    imei="0123456789ABCDEF",
    imsi="244070000000517",
    pdns=_pdns,
    default_pdn_name="ulmsa",
    capabilities=["REAL_MEDIATEK_UE", "MTK_UE2"],
)

##############################UE1 as _mtk1_android ###########################################
_mtk1_android = TafUeAndroid(
    serial_number="0123456789ABCDEF",
    ue_pc_address="10.46.135.34",
    capabilities=["QualcommNoLicenseUe", "REAL_ANDROID_UE"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.46.135.34", username="deul5g", password="Nuc2Ue4PzLab!"
    ),
    ue_pc_port="8090",
)


_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.47.194.219", username="ute", password="UTE.debian12"
    ),
    network_interface_address="10.47.194.219",
    iperf_path="iperf",
    ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254],
)

_appserver = AppServer(_iperf_details_on_appserver)

# --- TL ---------------------------------------------------------------------------------------------------

tl = TestLine(
    test_pc=_testpc1,
    test_pcs=[_testpc1, _testpc2, _testpc3],
    gnbs=[_gnb1, _gnb2],
    enbs=[_enb],
    core=_tampereCore,
    ues=[_mtk1, _mtk2, _mtk1_android],
    appserver=_appserver,
    attenuators=[_rf_att],
    tl_cloud_topology="CLASSICAL_5G_TYPE",
)
