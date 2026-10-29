######################################
#  TestLine 379 Ulm                  #
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
from taf.config.testline.core import RealCore4G
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.attenuator import HBTE
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAt


_tampereCore = RealCore4G(mcc="555", mnc="10")

_core_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.47.194.209", username="ute", password="UTE.debian12"
    ),
    network_interface_address="10.47.194.209",
    iperf_version=2,
)

_core_appserver = AppServer(iperf_details=_core_iperf)

_rf_att = HBTE(
    ip_addr="10.46.134.181",
    port="5000",
    attenuation_port_numbers=[9, 10, 11, 12, 13, 14],
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

_pdu1 = Gude(
    addr="10.46.134.231",
    port_numbers=[1, 5, 6, 9, 10],
    model="EPC",
    version="8221-1",
    #    snmp_user=_snmp_user_data,
)

_pdu2 = Gude(
    addr="10.46.134.229",
    port_numbers=[7, 8],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

# ---------------- START gNB-1 ------------------------

_gnb1_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.205.11", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.205.11", username="Nemuadmin", password="nemuuser", port="443"
    ),
)


_gnb1_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")

_gnb1_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gnb1_capu1],
    pdu_port=_pdu1.pdu_ports[5],
    hardware_type="ASIB",
)

_gnb1_airscale = Airscale(common_units=[_gnb1_comu])


_gnb1_du_rm1 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu2.pdu_ports[7],
    radio_type="AZOG",
    attenuation_ports=[
        _rf_att.attenuator_ports[9],
        _rf_att.attenuator_ports[10],
    ],
)

_gnb1_du_rm2 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu2.pdu_ports[8],
    radio_type="AZOG",
    attenuation_ports=[
        _rf_att.attenuator_ports[11],
        _rf_att.attenuator_ports[12],
    ],
)


_gnb1_du = DU(airscale=_gnb1_airscale, rus=[_gnb1_du_rm1, _gnb1_du_rm2])

_gnb1 = ClassicalBts(cu=_gnb1_cu, dus=[_gnb1_du])

# ---------------- END gNB-1 ------------------------


_enb1_capu = CapacityUnit(addr="192.168.253.20")
_enb1_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_enb1_capu],
    pdu_port=_pdu1.pdu_ports[6],
)

_enb1_airscale = Airscale(common_units=[_enb1_comu])


_enb1_rm1 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu1.pdu_ports[1],
    radio_type="FRHC",
    attenuation_ports=[
        _rf_att.attenuator_ports[13],
        _rf_att.attenuator_ports[14],
    ],
)

_enb1 = RealEnb(
    system_module=_enb1_airscale,
    rms=[_enb1_rm1],
    oam_ip=NetworkAddress(v4="10.47.205.10"),
)
# ---------------- STOP eNB-1 ------------------------

_testpc1_ssh = SshServiceDetails(
    addr="10.47.205.49", username="ute", password="UTE.debian12"
)
_testpc1 = TestPc(default_ssh_connection_details=_testpc1_ssh, connections=[_gnb1])

_testpc2_ssh = SshServiceDetails(
    addr="10.47.205.50", username="ute", password="UTE.debian12"
)
_testpc2 = TestPc(default_ssh_connection_details=_testpc2_ssh, connections=[_enb1])

# ---------------- START TAF_UE_PROXY UEs ----------------

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.47.194.209",
    user="ute",
    password="UTE.debian12",
    expected_prompt="ute@DEUL5Gappsrv09",
    bind_interface_ip="10.47.194.209",
)


_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    interval=1,
    dt_from_uepc=True,
    version=2,
)

_asci_2 = TafUeAt(
    com_port="8",
    serial_number="9b665771",
    ue_pc_address="10.46.135.47",
    ue_pc_login="deul5g",
    ue_pc_password="Nuc2Ue4PzLab!",
    ue_pc_expected_prompt="DEUL5G@DEUL5GNUC1-379",
    capabilities=["ue_proxy", "REAL_UE", "REAL_ANDROID_UE", "UE_1"],
    data_transfer=[_data_transfer_iperf],
    #                     proxy_mngr_port=9955,
    ue_pc_port="8080",
)


_asci_1 = TafUeAt(
    com_port="3",
    serial_number="42ee1e4c",
    ue_pc_address="10.46.135.48",
    ue_pc_login="deul5g",
    ue_pc_password="Nuc2Ue4PzLab!",
    ue_pc_expected_prompt="DEUL5G@DEUL5GNUC2-379",
    capabilities=["ue_proxy", "REAL_UE", "REAL_ANDROID_UE", "APN_irat", "UE_2"],
    data_transfer=[_data_transfer_iperf],
    #    proxy_mngr_port=9955,
    ue_pc_port="8080",
)

# ---------------- STOP TAF_UE_PROXY UEs ----------------


tl = TestLine(
    test_pc=_testpc1,
    test_pcs=[_testpc1, _testpc2],
    gnbs=[_gnb1],
    enbs=[_enb1],
    core=_tampereCore,
    ues=[_asci_2, _asci_1],
    appserver=_core_appserver,
    attenuators=[_rf_att],
    tl_cloud_topology="NON_CM",
    pdus=[_pdu1, _pdu2],
)

__all__ = ["tl"]
