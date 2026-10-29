######################################
#  TestLine 116 Ulm                   #
######################################
__maintainer__ = "MN RAN RD VRF ULM 2 (L05)"
__team__ = "MN RAN RD VRF ULM 2 (L05)"
__email__ = "i_mn_ran_rd_vrf_ulm_vt2@internal.nsn.com"

import os
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.ue import TafUeMtk
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
    addr="10.46.133.36",
    port_numbers=[1, 3, 4, 5],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

cfg_dir = os.path.dirname(os.path.abspath(__file__))


_rf_att = HBTE(
    ip_addr="10.46.133.76",
    port="5000",
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    version=None,
    model="PA-16-16-6-127-0.5-B-S",
)


# GNB1

_cu1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.200.201",
        routing_v4=RoutingInformation(
            gateway="10.47.200.222", destIpAddr="10.47.200.192/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.200.201", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.200.201", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4="10.47.200.202"),
    x2u=NetworkAddress(v4="10.47.200.203"),
    s1u=NetworkAddress(v4="10.47.200.203"),
)

##ABIL
_capacity_unit1 = CapacityUnit(addr="192.168.253.20")

##ASIL
_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_capacity_unit1],
    pdu_port=_pdu.pdu_ports[3],
)

_airscale1 = Airscale(common_units=[_common_unit1])

_gnb1_rf_pdu = Gude(
    addr="10.46.133.48",
    port_numbers=[10, 11, 12],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_gnb1_du_rm63 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb1_rf_pdu.pdu_ports[10],
    radio_type="AHCA",
    attenuation_ports=[_rf_att.attenuator_ports[1], _rf_att.attenuator_ports[2]],
)

_gnb1_du_rm59 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb1_rf_pdu.pdu_ports[11],
    radio_type="AHCA",
    attenuation_ports=[_rf_att.attenuator_ports[3], _rf_att.attenuator_ports[4]],
)

_gnb1_du_rm58 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb1_rf_pdu.pdu_ports[12],
    radio_type="AHCA",
    attenuation_ports=[_rf_att.attenuator_ports[5], _rf_att.attenuator_ports[6]],
)

_du1 = DU(airscale=_airscale1, rus=[_gnb1_du_rm63, _gnb1_du_rm59, _gnb1_du_rm58])

_gnb1 = ClassicalBts(cu=_cu1, dus=[_du1])

# ---------------- END gnb-1 ------------------------

# ---------------- START gnb-2 ------------------------

_cu2 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.200.205",
        routing_v4=RoutingInformation(
            gateway="10.47.200.222", destIpAddr="10.47.200.192/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.200.205", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.200.205", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4="10.47.200.206"),
    x2u=NetworkAddress(v4="10.47.200.207"),
    s1u=NetworkAddress(v4="10.47.200.207"),
)

##ABIL
_capacity_unit2 = CapacityUnit(addr="192.168.253.20")

##ASIL
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
    port_numbers=[11, 12],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_gnb2_rf_pdu_2 = Gude(
    addr="10.46.133.48",
    port_numbers=[9],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_gnb2_du_rm02 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb2_rf_pdu.pdu_ports[11],
    radio_type="AHCA",
    attenuation_ports=[_rf_att.attenuator_ports[7], _rf_att.attenuator_ports[8]],
)

_gnb2_du_rm36 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb2_rf_pdu.pdu_ports[12],
    radio_type="AHCA",
    attenuation_ports=[_rf_att.attenuator_ports[9], _rf_att.attenuator_ports[10]],
)

_gnb2_du_rm31 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb2_rf_pdu_2.pdu_ports[9],
    radio_type="AHCA",
    attenuation_ports=[_rf_att.attenuator_ports[11], _rf_att.attenuator_ports[12]],
)

_du2 = DU(airscale=_airscale2, rus=[_gnb2_du_rm02, _gnb2_du_rm36, _gnb2_du_rm31])

_gnb2 = ClassicalBts(cu=_cu2, dus=[_du2])

# ---------------- END gnb-2 ------------------------

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
    oam_ip=NetworkAddress(v4="10.47.200.200"),
)

# -----eNB eNB--------------------------------------------------------------------

# --- UE -------------------------------------------------------------------------
_pdns = [
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi1.nokia.com.mnc001.mcc540.gprs"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi2.nokia.com.mnc001.mcc540.gprs"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsa"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi3.nokia.com.mnc001.mcc540.gprs"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsaslicemqi1.mnc001.mcc540.gprs"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi1.nokia.com.mnc007.mcc244.gprs"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsaslicemqi2.mnc007.mcc244.gprs"),
    PDN(pdp_type=PDPTypes.IP.value, apn="ulmsamqi3.nokia.com.mnc007.mcc244.gprs"),
]


_tampereCore = RealCore(mcc="540", mnc="01", pdns=_pdns)

##############################UE1###########################################
##############################UE1###########################################
_mtk1_host_ssh = SshServiceDetails(
    addr="10.46.135.211", username="deul5g", password="Nuc2Ue4PzLab!"
)

##############################UE1_New_UE_Usage###########################################
_mtk_appserver_taf = TafUeAppServer(
    app_server_name="DEUL5Gappsrv01",
    address="10.47.194.201",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.201",
    # expected_prompt='[cmw_sg4@smw_sg4 ~]$ ',
    #    binary_path="iperf",
    #    ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254],
)

_mtk_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_mtk_appserver_taf,
    interval=1,
    binary_path="/data/local/tmp/iperf",
    version=2,
)


_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_mtk_appserver_taf, interval=1, version=2
)


_mtk1_taf = TafUeMtk(
    ue_pc_address="10.46.135.211",
    ue_pc_port=1234,
    serial_number="0123456789ABCDEF",
    data_transfer=[
        _mtk_data_transfer_iperf,
    ],
    com_port="auto",
    edb_file_path="auto",
    log_filter="2.Gen97_Default_Standard",
    imei="35190103110862",
    imsi="540017000001047",
    pdns=_pdns,
    default_pdn_name="ulmsa",
    capabilities=["REAL_UE", "REAL_MTK_UE"],
)

_mtk1_android = TafUeAndroid(
    serial_number="0123456789ABCDEF",
    ue_pc_address="10.46.135.211",
    capabilities=["REAL_UE", "REAL_MTK_UE", "UE1", "UE_1"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.46.135.211", username="deul5g", password="Nuc2Ue4PzLab!"
    ),
    ue_pc_port="1234",
)


##############################UE2###########################################
_mtk2_host_ssh = SshServiceDetails(
    addr="10.46.135.121", username="deul5g", password="Nuc2Ue4PzLab!"
)

_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.47.194.201", username="ute", password="UTE.debian12"
    ),
    network_interface_address="10.47.194.201",
    iperf_path="iperf",
    ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254],
)

_appserver = AppServer(_iperf_details_on_appserver)
##############################UE2_New_UE_Usage###########################################
_mtk2_taf = TafUeMtk(
    ue_pc_address="10.46.135.121",
    ue_pc_port=1234,
    serial_number="0123456789ABCDEF",
    data_transfer=[
        _mtk_data_transfer_iperf,
    ],
    com_port="auto",
    edb_file_path="auto",
    log_filter="2.Gen98_Default_Standard",
    imei="35190103112120",
    imsi="540017000001048",
    pdns=_pdns,
    default_pdn_name="ulmsa",
    capabilities=["REAL_UE_2", "REAL_MTK_UE_2"],
)

_mtk2 = TafUeAndroid(
    serial_number="0123456789ABCDEF",
    ue_pc_address="10.46.135.121",
    capabilities=["REAL_UE", "REAL_MTK_UE"],
    data_transfer=[_mtk_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.46.135.121", username="deul5g", password="Nuc2Ue4PzLab!"
    ),
    ue_pc_port="1234",
)

############################## TEST PC ###########################################

_gNB1_testpc1_ssh = SshServiceDetails(
    addr="10.47.200.241", username="ute", password="UTE.debian12"
)
_gNB1_testpc1 = TestPc(
    default_ssh_connection_details=_gNB1_testpc1_ssh, connections=[_gnb1]
)

_gNB2_testpc2_ssh = SshServiceDetails(
    addr="10.47.200.243", username="ute", password="UTE.debian12"
)
_gNB2_testpc2 = TestPc(
    default_ssh_connection_details=_gNB2_testpc2_ssh, connections=[_gnb2]
)

_eNB_testpc3_ssh = SshServiceDetails(
    addr="10.47.200.242", username="ute", password="UTE.debian12"
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
    core=_tampereCore,
    pdus=[_pdu, _gnb1_rf_pdu, _gnb2_rf_pdu, _gnb2_rf_pdu_2],
    ues=[_mtk1_android],
#    ues=[_mtk1_taf, _mtk2_taf],
    appserver=_appserver,
    attenuators=[_rf_att],
    tl_cloud_topology="CLASSICAL_5G_TYPE",
)
