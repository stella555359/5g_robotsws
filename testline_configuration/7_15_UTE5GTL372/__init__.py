######################################
#  TestLine 372 Ulm                  #
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
from taf.config.testline.core import RealCore, IPS
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.attenuator import HBTE
from taf.config.testline import TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.ue import TafUeAt

_rf_att = HBTE(
    ip_addr="10.46.134.140",
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
    addr="10.46.134.222",
    port_numbers=[2, 7, 8, 9, 11, 12],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_rf_pdu = Gude(
    addr="10.46.134.216",
    port_numbers=[2, 4, 7, 8, 10],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# ---------------- START gnb-1 ------------------------ gnb_372-1

_gNB372_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.203.21",
        routing_v4=RoutingInformation(
            gateway="10.47.203.30", destIpAddr="10.47.203.0/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.203.21", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.203.21", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.203.22"),
    x2u=NetworkAddress(v4="10.47.203.23"),
    s1u=NetworkAddress(v4="10.47.203.23"),
)

_gNB372_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")

_gNB372_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB372_capu1],
    pdu_port=_comu_pdu.pdu_ports[7],
    hardware_type="ASIK",
)

_gNB372_airscale = Airscale(common_units=[_gNB372_comu])


_gNB372_du_rm_058 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu.pdu_ports[2],
    radio_type="AHCA",
    attenuation_ports=[_rf_att.attenuator_ports[1], _rf_att.attenuator_ports[2]],
)

_gNB372_du_rm_055 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu.pdu_ports[4],
    radio_type="AHCA",
    attenuation_ports=[_rf_att.attenuator_ports[3], _rf_att.attenuator_ports[4]],
)

_gNB372_du_rm_051 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu.pdu_ports[8],
    radio_type="AHLOA",
    attenuation_ports=[_rf_att.attenuator_ports[5], _rf_att.attenuator_ports[6]],
)

_gNB372_du = DU(
    airscale=_gNB372_airscale,
    rus=[_gNB372_du_rm_058, _gNB372_du_rm_055, _gNB372_du_rm_051],
)

_gNB372 = ClassicalBts(cu=_gNB372_cu, dus=[_gNB372_du])

# ---------------- END gnb-1 ------------------------

# ---------------- START gnb-2 ------------------------ gnb_372-2

_gNB372B_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.203.24",
        routing_v4=RoutingInformation(
            gateway="10.47.203.30", destIpAddr="10.47.203.0/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.203.24", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.203.24", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.203.25"),
    x2u=NetworkAddress(v4="10.47.203.26"),
    s1u=NetworkAddress(v4="10.47.203.26"),
)

_gNB372B_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")

_gNB372B_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB372B_capu1],
    pdu_port=_comu_pdu.pdu_ports[9],
    hardware_type="ASIK",
)

_gNB372B_airscale = Airscale(common_units=[_gNB372B_comu])

_gNB372_rf_pdu3 = Gude(
    addr="10.46.134.217",
    port_numbers=[1, 4],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_gNB372_du_rm_069 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_rf_pdu.pdu_ports[10],
    radio_type="AHCA",
    attenuation_ports=[_rf_att.attenuator_ports[7], _rf_att.attenuator_ports[8]],
)

_gNB372_du_rm_070 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB372_rf_pdu3.pdu_ports[1],
    radio_type="AHCA",
    attenuation_ports=[_rf_att.attenuator_ports[9], _rf_att.attenuator_ports[10]],
)

_gNB372_du_rm_071 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gNB372_rf_pdu3.pdu_ports[4],
    radio_type="AHCA",
    attenuation_ports=[_rf_att.attenuator_ports[11], _rf_att.attenuator_ports[12]],
)

_gNB372B_du = DU(
    airscale=_gNB372B_airscale,
    rus=[_gNB372_du_rm_069, _gNB372_du_rm_070, _gNB372_du_rm_071],
)

_gNB372B = ClassicalBts(cu=_gNB372B_cu, dus=[_gNB372B_du])

# ---------------- END gnb-2 ------------------------

# ---------------- START eNB-1 ------------------------ eNB_372

_eNB372_capu = CapacityUnit(addr="192.168.253.20")

_eNB372_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB372_capu],
    pdu_port=_comu_pdu.pdu_ports[8],
)

_eNB372_ru1 = RU(
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
        _rf_att.attenuator_ports[13],
        _rf_att.attenuator_ports[14],
        _rf_att.attenuator_ports[15],
        _rf_att.attenuator_ports[16],
    ],
)

_eNB372_airscale = Airscale(common_units=[_eNB372_comu])

_eNB372 = RealEnb(
    system_module=_eNB372_airscale,
    rms=[_eNB372_ru1],
    oam_ip=NetworkAddress(v4="10.47.203.20"),
)

# ---------------- END eNB-1 ------------------------

# ---------------- START IPSL ------------------------

_ips_ssh = SshServiceDetails(
    addr="deul5gipsl18.intra.noklab.net", username="deul5g", password="Nuc2Ue4PzLab!"
)
_tampereCore = RealCore(ips=IPS(ssh_connection_details=_ips_ssh), mcc="555", mnc="10")

# ---------------- END IPSL ------------------------

# ---------------- START APPLICATION SERVER ----------

_appserver1_ssh = SshServiceDetails(
    addr="10.47.194.206", username="ute", password="UTE.debian12"
)

_appserver1_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver1_ssh, iperf_version=3
)

_appserver1 = AppServer(iperf_details=_appserver1_iperf)

_appserver2_ssh = SshServiceDetails(
    addr="10.44.35.213", username="ute", password="UTE.debian12"
)

_appserver2_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver2_ssh, iperf_version=3
)

_appserver2 = AppServer(iperf_details=_appserver2_iperf)

# ---------------- STOP APPLICATION SERVER ----------

# ---------------- START TAF_UE_PROXY UEs ----------------

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.47.194.206",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.206",
    expected_prompt="ute@DEUL5Gappsrv06",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    interval=1,
    binary_path="C:/iperf/",
    version=2,
    dt_from_uepc=True,
)

_Askey02_sdx55 = TafUeAt(
    serial_number="53b3bb9",
    com_port="6",
    ue_pc_address="10.46.135.32",
    ue_pc_login="deul5g",
    ue_pc_password="Nuc2Ue4PzLab!",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "UE_1"],
    data_transfer=[_data_transfer_iperf],
    ue_pc_port="8080",
    ue_pc_expected_prompt="DEUL5G@DEUL5GNUC1-372",
    imsi="555107000000137",
    pdu_port=_comu_pdu.pdu_ports[12],
)

_Askey18_sdx55 = TafUeAt(
    com_port="5",
    serial_number="5afd7624",
    ue_pc_address="10.46.135.36",
    ue_pc_login="deul5g",
    ue_pc_password="Nuc2Ue4PzLab!",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "UE_2"],
    data_transfer=[_data_transfer_iperf],
    ue_pc_port="8080",
    ue_pc_expected_prompt="DEUL5G@DEUL5GNUC2-372",
    imsi="262731000000097",
    pdu_port=_comu_pdu.pdu_ports[11],
)
# ---------------- STOP TAF_UE_PROXY UEs ----------------

# ---------------- START TEST PCs --------------------

_gNB372_testpc1_ssh = SshServiceDetails(
    addr="10.47.203.101", username="ute", password="UTE.debian12"
)
_gNB372_testpc1 = TestPc(
    default_ssh_connection_details=_gNB372_testpc1_ssh, connections=[_gNB372]
)

_gNB372B_testpc2_ssh = SshServiceDetails(
    addr="10.47.203.103", username="ute", password="UTE.debian12"
)
_gNB372B_testpc2 = TestPc(
    default_ssh_connection_details=_gNB372B_testpc2_ssh, connections=[_gNB372B]
)

_eNB372_testpc3_ssh = SshServiceDetails(
    addr="10.47.203.102", username="ute", password="UTE.debian12"
)
_eNB372_testpc3 = TestPc(
    default_ssh_connection_details=_eNB372_testpc3_ssh, connections=[_eNB372]
)
# ---------------- END TEST PCs ----------------------

tl = TestLine(
    test_pc=_gNB372_testpc1,
    test_pcs=[_gNB372_testpc1, _gNB372B_testpc2, _eNB372_testpc3],
    gnbs=[_gNB372, _gNB372B],
    enbs=[_eNB372],
    pdus=[
        _comu_pdu,
        _rf_pdu,
        _gNB372_rf_pdu3,
    ],
    core=_tampereCore,
    ues=[_Askey02_sdx55, _Askey18_sdx55],
    appserver=_appserver1,
    appservers=[_appserver1],
    attenuators=[_rf_att],
    tl_cloud_topology="NON_CM",
)

__all__ = ["tl"]
