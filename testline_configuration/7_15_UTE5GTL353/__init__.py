#######################################
# TestLine TL353 Ulm (7_15_UTE5GTL353)#
#######################################
__maintainer__ = "MN ECE RD ULM L2PS 04 SG SQD62"
__team__ = "MN ECE RD ULM L2PS 04 SG SQD62"
__email__ = "I_MN_ECE_ULM_RD_L2PS_04_SG_SQD62_NIMS@internal.nsn.com"

import os

from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import AppServer
from taf.config.testline.connection_details import (
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.core import RealCore
from taf.config.testline.ue import MediaTek, Android, Qualcomm
from taf.config.testline.ue import QualcommUeType, PluginAndroidClassType
from taf.config.testline.pdu import APC, PduPort, Gude
from taf.config.testline.pdn import PDN, PDPTypes
from taf.config.testline.radio import RU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.attenuator import HBTE, JFW

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_pdns = [PDN(pdp_type=PDPTypes.IP.value, apn="ulmsa")]

_tampereCore = RealCore(mcc="555", mnc="10", pdns=_pdns)

_snmp_user_data = dict(
    userName="user",
    authKey="qwer2009!",
    privKey="qwer2009!",
    authProtocol="SHA",
    privProtocol="AES",
)


# ---------------- START gNB-1 ------------------- #
_gnb1_rf_att = HBTE(
    ip_addr="10.46.134.143",
    port="5000",
    attenuation_port_numbers=[1, 2, 3, 4],
    version=None,
    model="PA-16-16-6-127-0.5-B-S",
)

_gnb1_comu_pdu = Gude(
    addr="10.46.134.203",
    port_numbers=[5],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_gnb1_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.201.131",
        routing=RoutingInformation(gateway="10.47.201.158", ip_prefix_length=27),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.201.131", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.201.131", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.201.132"),
    x2u=NetworkAddress(v4="10.47.201.133"),
    s1u=NetworkAddress(v4="10.47.201.133"),
)

_gnb1_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")

_gnb1_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gnb1_capu1],
    pdu_port=_gnb1_comu_pdu.pdu_ports[5],
    hardware_type="ASIB",
)

_gnb1_airscale = Airscale(common_units=[_gnb1_common_unit])

_gnb1_rf_pdu1 = Gude(
    addr="10.46.134.206",
    port_numbers=[4],
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
    pdu_port=_gnb1_rf_pdu1.pdu_ports[4],
    radio_type="AHCA",
    attenuation_ports=[
    _gnb1_rf_att.attenuator_ports[1],
    _gnb1_rf_att.attenuator_ports[2],
    ],
)

_gnb1_du = DU(airscale=_gnb1_airscale, rus=[_gnb1_du_rm1])

_gnb1 = ClassicalBts(cu=_gnb1_cu, dus=[_gnb1_du])

# ----------------- END gNB-1 -------------------- #


# ---------------- START eNB-1 ------------------- #
_enb1_comu_pdu = Gude(
    addr="10.46.134.203",
    port_numbers=[3],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_enb1_capu = CapacityUnit(addr="192.168.253.20", hardware_type="ABIA")

_enb1_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_enb1_capu],
    pdu_port=_enb1_comu_pdu.pdu_ports[3],
    hardware_type="ASIA",    
)

_enb1_rf_pdu = Gude(
    addr="10.46.134.203",
    port_numbers=[1],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_enb1_du_rm1 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_enb1_rf_pdu.pdu_ports[1],
    radio_type="FRHC",
    attenuation_ports=[
    _gnb1_rf_att.attenuator_ports[3],
    _gnb1_rf_att.attenuator_ports[4],
    ],
)

_enb1_airscale = Airscale(common_units=[_enb1_comu])

_enb1 = RealEnb(
    system_module=_enb1_airscale,
    rms=[_enb1_du_rm1],
)
# ---------------- STOP eNB-1 ------------------- #


# ---------------- START MTK UE1: Mediatek #41 M80 ------------------- #
_mtk_host_ssh1 = SshServiceDetails(
    addr="10.46.134.53", username="deul5g", password="Nuc2Ue4PzLab!"
)
    
_mtk1 = MediaTek(
    ssh_connection_details=_mtk_host_ssh1,
    capabilities=["REAL_MEDIATEK_UE", "MTK_UE1"],
    server_dir="/cygdrive/c/pyro_server",
    server_port=8080,
    edb_file_path=r"auto",
    imei="123451234512346",
    imsi="5555107000000136",
    apn_url="ulmsa",
    iperf_details=IperfDataTransferDetails(
        ssh_connection_details=SshServiceDetails(
            addr="10.46.134.53", username="deul5g", password="Nuc2Ue4PzLab!"
        ),
        network_interface_address="",
        iperf_path="/data/local/tmp/iperf.exe",
        port=5432,
    ),
)
# ---------------- END MTK UE1: Mediatek #41 M80 --------------------- #


# ---------------- START Core APP Server ------------------- #
_core_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.44.35.230", username="ute", password="ute"
    ),
    network_interface_address="10.44.35.230",
    iperf_path="/usr/bin/iperf",
    port=5432,
)

_core_appserver = AppServer(iperf_details=_core_iperf)
# ---------------- END Core APP Server ------------------- #


# ---------------- START TEST PCs ------------------------ #
_testpc_ssh1 = SshServiceDetails(addr="10.47.201.177", username="ute", password="ute")
_testpc1 = TestPc(default_ssh_connection_details=_testpc_ssh1, connections=[_gnb1])

_testpc_ssh2 = SshServiceDetails(addr="10.47.201.178", username="ute", password="ute")
_testpc2 = TestPc(default_ssh_connection_details=_testpc_ssh2, connections=[_enb1])
# ---------------- END TEST PCs -------------------------- #


# ----------------------------------------- TL ----------------------------------------- #
tl = TestLine(
    test_pc=_testpc1,
    test_pcs=[_testpc1, _testpc2],
    gnbs=[_gnb1],
    enbs=[_enb1],
    pdus=[_gnb1_comu_pdu, _gnb1_rf_pdu1, _enb1_comu_pdu, _enb1_rf_pdu,],
    core=_tampereCore,
    ues=[_mtk1],
    appserver=_core_appserver,
    attenuators=[_gnb1_rf_att],
    tl_cloud_topology="CLASSICAL_5G_TYPE",
)

__all__ = ["tl"]
# ----------------------------------------- TL ----------------------------------------- #