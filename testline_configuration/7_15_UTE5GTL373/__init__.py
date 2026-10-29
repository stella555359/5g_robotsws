######################################
#  TestLine 373 Ulm                  #
######################################
__maintainer__ = "MN ECE RD ULM L2PS 04 SG SQD62"
__team__ = "MN ECE RD ULM L2PS 04 SG SQD62"
__email__ = "I_MN_ECE_ULM_RD_L2PS_04_SG_SQD62_NIMS@internal.nsn.com"

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
from taf.config.testline.core import RealCore, IPS
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.attenuator import HBTE


from taf.config.testline import TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.ue import TafUeAt


# ---------------- START IPSL ------------------------
_ips_ssh = SshServiceDetails(
    addr="10.44.32.19", username="deul5g", password="Nuc2Ue4PzLab!"
)

_tampereCore = RealCore(ips=IPS(ssh_connection_details=_ips_ssh), mcc="555", mnc="10")
# ---------------- END IPSL ------------------------

_core_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.44.35.226", username="ute", password="ute"
    ),
    network_interface_address="10.44.35.226",
    iperf_path="/usr/bin/iperf",
)

_core_appserver = AppServer(iperf_details=_core_iperf)

_rf_att = HBTE(
    ip_addr="10.46.134.151",
    port="5000",
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
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
    addr="10.46.134.221",
    port_numbers=[1, 3, 4, 5, 10, 11],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# ---------------- START gnb-1 ------------------------ gnb_373-1

_gNB373_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.203.71",
        routing_v4=RoutingInformation(
            gateway="10.47.203.94", destIpAddr="10.47.203.64/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.203.71", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.203.71", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.203.72"),
    x2u=NetworkAddress(v4="10.47.203.73"),
    s1u=NetworkAddress(v4="10.47.203.73"),
)

_gNB373_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIO")

_gNB373_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB373_capu1],
    pdu_port=_comu_pdu.pdu_ports[3],
    hardware_type="ASIB",
)

_gNB373_airscale = Airscale(common_units=[_gNB373_comu])

_gNB373_rf_pdu1 = Gude(
    addr="10.46.134.239",
    port_numbers=[9, 10, 12],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_gNB373_rf_pdu2 = Gude(
    addr="10.46.134.216",
    port_numbers=[11],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_gNB373_du_rm_024 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB373_rf_pdu1.pdu_ports[10],
    radio_type="AHLOA",
    attenuation_ports=[_rf_att.attenuator_ports[1], _rf_att.attenuator_ports[2]],
)

_gNB373_du_rm_025 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB373_rf_pdu1.pdu_ports[9],
    radio_type="AHLOA",
    attenuation_ports=[_rf_att.attenuator_ports[3], _rf_att.attenuator_ports[4]],
)

_gNB373_du_rm_029 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB373_rf_pdu2.pdu_ports[11],
    radio_type="AHFIB",
    attenuation_ports=[_rf_att.attenuator_ports[5], _rf_att.attenuator_ports[6]],
)

_gNB373_du = DU(
    airscale=_gNB373_airscale,
    rus=[_gNB373_du_rm_024, _gNB373_du_rm_025, _gNB373_du_rm_029],
)

_gNB373 = ClassicalBts(cu=_gNB373_cu, dus=[_gNB373_du])

# ---------------- END gnb-1 ------------------------

# ---------------- START gnb-2 ------------------------ gnb_372-2

_gNB373B_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.203.74",
        routing_v4=RoutingInformation(
            gateway="10.47.203.94", destIpAddr="10.47.203.64/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.203.74", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.203.74", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.203.75"),
    x2u=NetworkAddress(v4="10.47.203.76"),
    s1u=NetworkAddress(v4="10.47.203.76"),
)

_gNB373B_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIO")
_gNB373B_capu2 = CapacityUnit(addr="192.168.253.24", hardware_type="ABIO")

_gNB373B_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB373B_capu1, _gNB373B_capu2],
    pdu_port=_comu_pdu.pdu_ports[5],
    hardware_type="ASIB",
)

_gNB373B_airscale = Airscale(common_units=[_gNB373B_comu])

_gNB373_rf_pdu3 = Gude(
    addr="10.46.134.240",
    port_numbers=[1, 3, 4],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_gNB373_du_rm_039 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB373_rf_pdu3.pdu_ports[1],
    radio_type="AHLOA",
    attenuation_ports=[_rf_att.attenuator_ports[7], _rf_att.attenuator_ports[8]],
)

_gNB373_du_rm_040 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB373_rf_pdu3.pdu_ports[3],
    radio_type="AHLOA",
    attenuation_ports=[_rf_att.attenuator_ports[9], _rf_att.attenuator_ports[10]],
)

_gNB373_du_rm_041 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB373_rf_pdu3.pdu_ports[4],
    radio_type="AHLOA",
    attenuation_ports=[_rf_att.attenuator_ports[11], _rf_att.attenuator_ports[12]],
)

_gNB373B_du = DU(
    airscale=_gNB373B_airscale,
    rus=[_gNB373_du_rm_039, _gNB373_du_rm_040, _gNB373_du_rm_041],
)

_gNB373B = ClassicalBts(cu=_gNB373B_cu, dus=[_gNB373B_du])

# ---------------- END gnb-2 ------------------------

# ---------------- START eNB-1 ------------------------ eNB_373

_eNB373_capu = CapacityUnit(addr="192.168.253.20")

_eNB373_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB373_capu],
    pdu_port=_comu_pdu.pdu_ports[4],
)

_eNB373_rm1_ru1 = RU(
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
        _rf_att.attenuator_ports[13],
        _rf_att.attenuator_ports[14],
        _rf_att.attenuator_ports[15],
        _rf_att.attenuator_ports[16],
    ],
)

_eNB373_airscale = Airscale(common_units=[_eNB373_comu])

_eNB373 = RealEnb(
    system_module=_eNB373_airscale,
    rms=[_eNB373_rm1_ru1],
    oam_ip=NetworkAddress(v4="10.47.203.70"),
)
# ---------------- END eNB-1 ------------------------

# ---------------- START TAF_UE_PROXY UEs ----------------

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.44.35.226",
    user="ute",
    password="ute",
    bind_interface_ip="10.44.35.226",
    expected_prompt="ute@DEUL-appsrv26",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    interval=1,
    binary_path="C:/iperf/",
    version=2,
    dt_from_uepc=True,
)

_Askey19_sdx55 = TafUeAt(
    serial_number="89943f3f",
    com_port="3",
    ue_pc_address="10.46.135.33",
    ue_pc_login="deul5g",
    ue_pc_password="Nuc2Ue4PzLab!",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "UE_1"],
    data_transfer=[_data_transfer_iperf],
    ue_pc_port="8080",
    ue_pc_expected_prompt="DEUL5G@DEUL5GNUC1-373",
    imsi="555107000000167",
    pdu_port=_comu_pdu.pdu_ports[10],
)

_Askey14_sdx55 = TafUeAt(
    com_port="4",
    serial_number="89f9bb95",
    ue_pc_address="10.46.135.43",
    ue_pc_login="deul5g",
    ue_pc_password="Nuc2Ue4PzLab!",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "UE_2"],
    data_transfer=[_data_transfer_iperf],
    ue_pc_port="8080",
    ue_pc_expected_prompt="DEUL5G@DEUL5GNUC2-373",
    imsi="262731000000095",
    pdu_port=_comu_pdu.pdu_ports[11],
)
# ---------------- STOP TAF_UE_PROXY UEs ----------------

# ---------------- Start TEST PCs ------------------------
_gNB373_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="7-15-UTE5GTL373-1.ulm.nsn-rdnet.net",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[_gNB373],
)

_gNB373B_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="7-15-UTE5GTL373-2.ulm.nsn-rdnet.net",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[_gNB373B],
)

_eNB373_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="7-15-UTE5GTL373-3.ulm.nsn-rdnet.net",
        username="ute",
        password="UTE.debian12",
    ),
    connections=[_eNB373],
)
# ---------------- End TEST PCs ------------------------

tl = TestLine(
    test_pc=_gNB373_test_pc,
    test_pcs=[_gNB373_test_pc, _gNB373B_test_pc, _eNB373_test_pc],
    gnbs=[_gNB373, _gNB373B],
    enbs=[_eNB373],
    pdus=[_comu_pdu, _gNB373_rf_pdu1, _gNB373_rf_pdu2, _gNB373_rf_pdu3],
    core=_tampereCore,
    ues=[_Askey19_sdx55, _Askey14_sdx55],
    appserver=_core_appserver,
    appservers=[_core_appserver],
    attenuators=[_rf_att],
    tl_cloud_topology="CLASSICAL_5G",
)

__all__ = ["tl"]
