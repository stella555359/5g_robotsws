######################################
#  TestLine 355 Ulm                  #
######################################
__maintainer__ = "MN ECE RD ULM L2PS 04 SG SQD64"
__team__ = "MN ECE RD ULM L2PS 04 SG SQD64"
__email__ = "I_MN_ECE_ULM_RD_L2PS_04_SG_SQD64_NIMS@internal.nsn.com"

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

# from taf.config.testline.core import EPCSim
from taf.config.testline.core import RealCore
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.ue import MediaTek
from taf.config.testline import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.ue import Android, Qualcomm, QualcommUeType
from taf.config.testline.appserver import AppServer
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.attenuator import HBTE

from taf.config.testline.appserver import TafUeAppServer
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

# PDU  port5= GNB TL 355-1
_pdu = Gude(
    addr="10.46.134.204",
    port_numbers=[5, 7, 3, 1],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_rf_att = HBTE(
    ip_addr="10.46.134.144",
    port="5000",
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    version=None,
    model="PA-16-16-6-127-0.5-B-S",
)

_cu1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.201.211",
        routing_v4=RoutingInformation(gateway="10.47.201.222", ip_prefix_length=27),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.201.211", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.201.211", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4="10.47.201.212"),
    x2u=NetworkAddress(v4="10.47.201.213"),
    s1u=NetworkAddress(v4="10.47.201.213"),
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

_gnb1_rf_pdu = Gude(
    addr="10.46.134.207",
    port_numbers=[2, 3],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_gnb1_rf_pdu2 = Gude(
    addr="10.46.134.220",
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
    pdu_port=_gnb1_rf_pdu.pdu_ports[2],
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
    pdu_port=_gnb1_rf_pdu.pdu_ports[3],
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
    pdu_port=_gnb1_rf_pdu2.pdu_ports[7],
    radio_type="AHCA",
    attenuation_ports=[_rf_att.attenuator_ports[5], _rf_att.attenuator_ports[6]],
)

_du1 = DU(airscale=_airscale1, rus=[_gnb1_du_rm1, _gnb1_du_rm2, _gnb1_du_rm3])

_gnb1 = ClassicalBts(cu=_cu1, dus=[_du1])

# GNB2

_cu2 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.201.214",
        routing_v4=RoutingInformation(gateway="10.47.201.222", ip_prefix_length=27),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.201.214", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.201.214", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4="10.47.201.215"),
    x2u=NetworkAddress(v4="10.47.201.216"),
    s1u=NetworkAddress(v4="10.47.201.216"),
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
    addr="10.46.134.207",
    port_numbers=[6, 7, 8],
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
    pdu_port=_gnb2_rf_pdu.pdu_ports[6],
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
    pdu_port=_gnb2_rf_pdu.pdu_ports[7],
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
    pdu_port=_gnb2_rf_pdu.pdu_ports[8],
    radio_type="AHCA",
    attenuation_ports=[_rf_att.attenuator_ports[11], _rf_att.attenuator_ports[12]],
)


_du2 = DU(airscale=_airscale2, rus=[_gnb2_du_rm1, _gnb2_du_rm2, _gnb2_du_rm3])

_gnb2 = ClassicalBts(cu=_cu2, dus=[_du2])

# -----eNB--------------------------------------------------------------------

_enb_capu = CapacityUnit(addr="192.168.253.36")

_enb_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.47.201.210", username="toor4nsn", password="oZPS0POrRieRtu"
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
    pdu_port=_pdu.pdu_ports[3],
    radio_type="FRHC",
    attenuation_ports=[_rf_att.attenuator_ports[13], _rf_att.attenuator_ports[14]],
)

_enb_ru2 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username="", password=""),
    pdu_port=_pdu.pdu_ports[3],
    radio_type="FRHC",
    attenuation_ports=[_rf_att.attenuator_ports[15], _rf_att.attenuator_ports[16]],
)

_enb = RealEnb(
    system_module=_enb_airscale,
    rms=[_enb_ru1],
    oam_ip=NetworkAddress(v4="10.47.201.210"),
)

# --- UE ---------------------------------------------------------------------------------------------------

_testpc1_ssh = SshServiceDetails(addr="10.47.201.241", username="ute", password="ute")
_testpc1 = TestPc(default_ssh_connection_details=_testpc1_ssh, connections=[_gnb1])

_testpc2_ssh = SshServiceDetails(addr="10.47.201.242", username="ute", password="ute")
_testpc2 = TestPc(default_ssh_connection_details=_testpc2_ssh, connections=[_enb])

_testpc3_ssh = SshServiceDetails(addr="10.47.201.247", username="ute", password="ute")
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

# ---------------- START MTK UE1 and UE2 ------------------------

_mtk1_host_ssh = SshServiceDetails(
    addr="10.46.134.55", username="deul5g", password="Nuc2Ue4PzLab!"
)

_mtk1 = MediaTek(
    ssh_connection_details=_mtk1_host_ssh,
    capabilities=["REAL_MEDIATEK_UE", "MTK_UE1", "UE_1"],
    server_dir="C:/pyro_server",
    server_port=8080,
    # edb_file_path='D:/MTK/sw/MT6297_EVB(NLWCTG_SAP)_bin.tar/MDDB_MT6297_S00_VMOLY_APOLLO_SQC_W19_33_P8.EDB',
    # edb_file_path='D:/MTK/sw/W19.41.P3/MT6297_PDB(NLWCTG_SAP)_bin/MDDB_MT6297_S00_VMOLY_W19_41_P3.EDB',
    # #edb_file_path='D:/MTK/sw/F60_W19_42_P1/w19.41.p9_v2_3GPP_15.6_June/MDDB_MT6297_S00_VMOLY_W19_42_P1.EDB',
    # edb_file_path='C:/00_Mediatek/00_MTK-DB/Apollo5G-SW_25.10.2019/Apollo5G-SW_25.10.2019/M70_MT6297_PDB__NLWCTG_SAP/MDDB_MT6297_S00_VMOLY_M70_DEV_W19_43_P2.EDB',
    edb_file_path=r"auto",
    imei="35190103100449",
    imsi="540017000001035",
    apn_url="ulmsa",
    iperf_details=IperfDataTransferDetails(
        ssh_connection_details=SshServiceDetails(
            addr="10.46.134.55", username="deul5g", password="Nuc2Ue4PzLab!"
        ),
        network_interface_address="",
        iperf_path="/data/local/tmp/iperf",
        ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254],
    ),
)

_mtk2_host_ssh = SshServiceDetails(
    addr="10.46.135.35", username="deul5g", password="Nuc2Ue4PzLab!"
)

_mtk2 = MediaTek(
    ssh_connection_details=_mtk2_host_ssh,
    capabilities=["REAL_MEDIATEK_UE", "MTK_UE2", "UE_2"],
    server_dir="C:/pyro_server",
    server_port=8080,
    # edb_file_path='D:/MTK/sw/MT6297_EVB(NLWCTG_SAP)_bin.tar/MDDB_MT6297_S00_VMOLY_APOLLO_SQC_W19_33_P8.EDB',
    # edb_file_path='D:/MTK/sw/W19.41.P3/MT6297_PDB(NLWCTG_SAP)_bin/MDDB_MT6297_S00_VMOLY_W19_41_P3.EDB',
    # #edb_file_path='D:/MTK/sw/F60_W19_42_P1/w19.41.p9_v2_3GPP_15.6_June/MDDB_MT6297_S00_VMOLY_W19_42_P1.EDB',
    # edb_file_path='C:/00_Mediatek/00_MTK-DB/Apollo5G-SW_25.10.2019/Apollo5G-SW_25.10.2019/M70_MT6297_PDB__NLWCTG_SAP/MDDB_MT6297_S00_VMOLY_M70_DEV_W19_43_P2.EDB',
    log_filter="2.Gen98_Default_Standard",
    edb_file_path=r"auto",
    imei="35190103100449",
    imsi="244070000000516",
    apn_url="ulmsa",
    iperf_details=IperfDataTransferDetails(
        ssh_connection_details=SshServiceDetails(
            addr="10.46.135.35", username="deul5g", password="Nuc2Ue4PzLab!"
        ),
        network_interface_address="",
        iperf_path="/data/local/tmp/iperf",
        ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254],
    ),
)

####   NEW UE_PROXY #####

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.47.194.223",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.223",
)


_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, version=3
)


_mtk1_android = TafUeAndroid(
    serial_number="0123456789ABCDEF",
    ue_pc_address="10.46.134.55",
    capabilities=["QualcommNoLicenseUe", "REAL_ANDROID_UE"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.46.134.55", username="deul5g", password="Nuc2Ue4PzLab!"
    ),
    ue_pc_port="8090",
)


####  END NEW UE_PROXY  ######

_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.47.194.223", username="ute", password="UTE.debian12"
    ),
    network_interface_address="10.47.194.223",
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
