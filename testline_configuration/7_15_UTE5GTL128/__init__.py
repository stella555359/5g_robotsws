######################################
#  TestLine 128 Ulm                   #
######################################
__maintainer__ = "MN ECE RD ULM L2PS 04 SG SQD64"
__team__ = "MN ECE RD ULM L2PS 04 SG SQD64"
__email__ = "I_MN_ECE_ULM_RD_L2PS_04_SG_SQD64_NIMS@internal.nsn.com"

from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeMtk
from taf.config.testline.appserver import TafUeAppServer
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

from taf.config.testline.appserver import AppServer
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

# PDU  port5= GNB TL 112-1
_pdu = Gude(
    addr="10.46.133.34",
    port_numbers=[1, 3, 4, 5, 6],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

cfg_dir = os.path.dirname(os.path.abspath(__file__))


_rf_att = HBTE(
    ip_addr="10.46.133.97",
    port="5000",
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    version=None,
    model="PA-16-16-6-127-0.5-B-S",
)


# GNB1

_cu1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.200.147",
        routing_v4=RoutingInformation(
            gateway="10.47.200.158", destIpAddr="10.47.200.128/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.200.147", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.200.147", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4="10.47.200.148"),
    x2u=NetworkAddress(v4="10.47.200.149"),
    s1u=NetworkAddress(v4="10.47.200.149"),
)

##ABIL
_capacity_unit1 = CapacityUnit(addr="192.168.253.20")

##ASIB
_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_capacity_unit1],
    pdu_port=_pdu.pdu_ports[3],
)

_airscale1 = Airscale(common_units=[_common_unit1])

_gnb1_rf_pdu = Gude(
    addr="10.46.133.43",
    port_numbers=[9, 10],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_gnb1_rf_pdu_2 = Gude(
    addr="10.46.133.28",
    port_numbers=[2],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_gnb1_du_rm32 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb1_rf_pdu.pdu_ports[9],
    radio_type="AHCA",
    attenuation_ports=[_rf_att.attenuator_ports[1], _rf_att.attenuator_ports[2]],
)

_gnb1_du_rm42 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb1_rf_pdu.pdu_ports[10],
    radio_type="AHCA",
    attenuation_ports=[_rf_att.attenuator_ports[3], _rf_att.attenuator_ports[4]],
)

_gnb1_du_rm27 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb1_rf_pdu_2.pdu_ports[2],
    radio_type="AHCA",
    attenuation_ports=[_rf_att.attenuator_ports[5], _rf_att.attenuator_ports[6]],
)

_du1 = DU(airscale=_airscale1, rus=[_gnb1_du_rm32, _gnb1_du_rm42, _gnb1_du_rm27])

_gnb1 = ClassicalBts(cu=_cu1, dus=[_du1])

# ---------------- END gnb-1 ------------------------

# ---------------- START gnb-2 ------------------------ gnb_128-2

_cu2 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.200.152",
        routing_v4=RoutingInformation(
            gateway="10.47.200.158", destIpAddr="10.47.200.128/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.200.152", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4="10.47.200.153"),
    x2u=NetworkAddress(v4="10.47.200.154"),
    s1u=NetworkAddress(v4="10.47.200.154"),
)

##ABIL
_capacity_unit2 = CapacityUnit(addr="192.168.253.20")

##ASIB
_common_unit2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_capacity_unit2],
    pdu_port=_pdu.pdu_ports[5],
)

_airscale2 = Airscale(common_units=[_common_unit2])

_gnb2_rf_pdu = Gude(
    addr="10.46.133.38",
    port_numbers=[4, 5, 7],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_gnb2_du_rm07 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb2_rf_pdu.pdu_ports[4],
    radio_type="AHCA",
    attenuation_ports=[_rf_att.attenuator_ports[7], _rf_att.attenuator_ports[8]],
)

_gnb2_du_rm35 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb2_rf_pdu.pdu_ports[5],
    radio_type="AHCA",
    attenuation_ports=[_rf_att.attenuator_ports[9], _rf_att.attenuator_ports[10]],
)

_gnb2_du_rm03 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb2_rf_pdu.pdu_ports[7],
    radio_type="AHCA",
    attenuation_ports=[_rf_att.attenuator_ports[11], _rf_att.attenuator_ports[12]],
)

_du2 = DU(airscale=_airscale2, rus=[_gnb2_du_rm07, _gnb2_du_rm35, _gnb2_du_rm03])

_gnb2 = ClassicalBts(cu=_cu2, dus=[_du2])

# -----eNB--------------------------------------------------------------------

_enb_capu = CapacityUnit(addr="192.168.253.36")

_enb_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_enb_capu],
    pdu_port=_pdu.pdu_ports[4],
)

_enb_airscale = Airscale(common_units=[_enb_comu])


_enb_ru1 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu.pdu_ports[1],
    radio_type="FXED",
    attenuation_ports=[_rf_att.attenuator_ports[13], _rf_att.attenuator_ports[14]],
)


_enb_ru2 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu.pdu_ports[1],
    radio_type="FXED",
    attenuation_ports=[_rf_att.attenuator_ports[15], _rf_att.attenuator_ports[16]],
)

_enb = RealEnb(
    system_module=_enb_airscale,
    rms=[_enb_ru1, _enb_ru2],
    oam_ip=NetworkAddress(v4="10.47.200.146"),
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


##############################UE1 new Taf.ue form###########################################
_mtk_appserver = TafUeAppServer(
    app_server_name="DEUL5Gappsrv18",
    address="10.47.194.218",
    user="ute",
    password="ute",
    bind_interface_ip="10.47.194.218",
    # expected_prompt="[cmw_sg4@smw_sg4 ~]$ ",
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

_mtk1 = TafUeMtk(
    ue_pc_address="DEUL5GNUC1-128.intra.noklab.net",
    ue_pc_port=1234,
    serial_number="0123456789ABCDEF",
    data_transfer=[
        _mtk_data_transfer_iperf,
    ],
    com_port="auto",
    edb_file_path="auto",
    imei="35190103110846",
    imsi="540017000001063",
    pdns=_pdns,
    default_pdn_name="ulmsa",
    capabilities=["REAL_UE", "MTK_UE1", "MTK", "UE_1"],
)


##############################UE2 new Taf.ue form###########################################
_mtk2 = TafUeMtk(
    ue_pc_address="10.46.135.45",
    ue_pc_port=1234,
    serial_number="0123456789ABCDEF",
    data_transfer=[
        _mtk_data_transfer_iperf,
    ],
    com_port="auto",
    edb_file_path="auto",
    log_filter="2.Gen98_Default_Standard",
    imei="35190103110849",
    imsi="244070000000511",
    pdns=_pdns,
    default_pdn_name="ulmsa",
    capabilities=["REAL_UE", "MTK_UE2", "UE_2"],
)

_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.47.194.218", username="ute", password="UTE.debian12"
    ),
    network_interface_address="10.47.194.218",
    iperf_path="iperf",
    ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254],
)

_appserver = AppServer(_iperf_details_on_appserver)

############################## TEST PC ###########################################

_gNB1_testpc1_ssh = SshServiceDetails(
    addr="10.47.200.181", username="ute", password="UTE.debian12"
)
_gNB1_testpc1 = TestPc(
    default_ssh_connection_details=_gNB1_testpc1_ssh, connections=[_gnb1]
)

_gNB2_testpc2_ssh = SshServiceDetails(
    addr="10.47.200.183", username="ute", password="UTE.debian12"
)
_gNB2_testpc2 = TestPc(
    default_ssh_connection_details=_gNB2_testpc2_ssh, connections=[_gnb2]
)

_eNB_testpc3_ssh = SshServiceDetails(
    addr="10.47.200.182", username="ute", password="UTE.debian12"
)
_eNB_testpc3 = TestPc(
    default_ssh_connection_details=_eNB_testpc3_ssh, connections=[_enb]
)

# --- TL ---------------------------------------------------------------------------------------------------

tl = TestLine(
    test_pc=_gNB1_testpc1,
    test_pcs=[_gNB1_testpc1, _gNB2_testpc2, _eNB_testpc3],
    gnbs=[_gnb1, _gnb2],
    enbs=[_enb],
    pdus=[_pdu, _gnb1_rf_pdu, _gnb1_rf_pdu_2, _gnb2_rf_pdu],
    core=_tampereCore,
    ues=[_mtk1, _mtk2],
    appserver=_appserver,
    attenuators=[_rf_att],
    tl_cloud_topology="CLASSICAL_5G_TYPE",
)
