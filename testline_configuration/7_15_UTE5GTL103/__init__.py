######################################
#  TestLine 103 Ulm                  #
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
from taf.config.testline.core import RealCore4G
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.attenuator import HBTE

from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid


_tampereCore = RealCore4G(mcc="555", mnc="10")

_core_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.44.35.214", username="ute", password="ute"
    ),
    network_interface_address="10.44.35.214",
    iperf_path="/usr/bin/iperf3",
    iperf_version=3,
)

_core_appserver = AppServer(iperf_details=_core_iperf)

_gnb_rf_att = HBTE(
    ip_addr="10.46.133.94",
    port="5000",
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    version=None,
    model="PA-16-16-6-127-0.5-B-S",
)

# ---------------- START gNB-1 ------------------------
_comu_pdu = Gude(
    addr="10.46.133.14",
    port_numbers=[1, 4, 5, 8, 10],
    model="EPC",
    version="8221-1",
    snmp_user=dict(
        userName="user",
        authKey="qwer2009!",
        privKey="qwer2009!",
        authProtocol="SHA",
        privProtocol="AES",
    ),
)

_gnb1_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.199.71",
        routing_v4=RoutingInformation(
            gateway="10.47.199.94", destIpAddr="10.47.199.64/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.199.71", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.199.71", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.199.72"),
    x2u=NetworkAddress(v4="10.47.199.73"),
    s1u=NetworkAddress(v4="10.47.199.73"),
)

_gnb1_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")

_gnb1_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gnb1_capu1],
    pdu_port=_comu_pdu.pdu_ports[4],
    hardware_type="ASIB",
)

_gnb1_airscale = Airscale(common_units=[_gnb1_comu])

_gnb1_rf_pdu = Gude(
    addr="10.46.133.37",
    port_numbers=[1, 2],
    model="EPC",
    version="8221-1",
    snmp_user=dict(
        userName="user",
        authKey="qwer2009!",
        privKey="qwer2009!",
        authProtocol="SHA",
        privProtocol="AES",
    ),
)

_gnb1_du_rm11 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb1_rf_pdu.pdu_ports[1],
    radio_type="AZQG",
    attenuation_ports=[
        _gnb_rf_att.attenuator_ports[1],
        _gnb_rf_att.attenuator_ports[2],
        _gnb_rf_att.attenuator_ports[3],
        _gnb_rf_att.attenuator_ports[4],
        _gnb_rf_att.attenuator_ports[9],
        _gnb_rf_att.attenuator_ports[10],
        _gnb_rf_att.attenuator_ports[11],
        _gnb_rf_att.attenuator_ports[12],
    ],
)

_gnb1_du_rm17 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb1_rf_pdu.pdu_ports[1],
    radio_type="AZOG",
    attenuation_ports=[
        _gnb_rf_att.attenuator_ports[5],
        _gnb_rf_att.attenuator_ports[6],
        _gnb_rf_att.attenuator_ports[7],
        _gnb_rf_att.attenuator_ports[8],
        _gnb_rf_att.attenuator_ports[13],
        _gnb_rf_att.attenuator_ports[14],
        _gnb_rf_att.attenuator_ports[15],
        _gnb_rf_att.attenuator_ports[16],
    ],
)


_gnb1_du = DU(airscale=_gnb1_airscale, rus=[_gnb1_du_rm11, _gnb1_du_rm17])

_gnb1 = ClassicalBts(cu=_gnb1_cu, dus=[_gnb1_du])

# ---------------- END gNB-1 ------------------------

# ---------------- START eNB-1 ------------------------


_enb1_capu = CapacityUnit(addr="192.168.253.20")
_enb1_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_enb1_capu],
    pdu_port=_comu_pdu.pdu_ports[5],
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
    pdu_port=_comu_pdu.pdu_ports[1],
    radio_type="FRHC",
)

_enb1 = RealEnb(
    system_module=_enb1_airscale,
    rms=[_enb1_rm1],
    oam_ip=NetworkAddress(v4="10.47.199.70"),
)
# ---------------- STOP eNB-1 ------------------------


# ---------------- START QC UE1 ------------------------

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.44.35.214",
    user="ute",
    password="ute",
    bind_interface_ip="10.44.35.214",
)


_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, version=3
)

_android1 = TafUeAndroid(
    serial_number="55c4ef7f",
    ue_pc_address="10.46.135.25",
    capabilities=["UE_2"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.46.135.25", username="deul5g", password="Nuc2Ue4PzLab!"
    ),
    ue_pc_port="8080",
)

_android2 = TafUeAndroid(
    serial_number="385b7831",
    ue_pc_address="10.46.135.25",
    capabilities=["UE_1"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.46.135.25", username="deul5g", password="Nuc2Ue4PzLab!"
    ),
    ue_pc_port="8080",
)

_testpc1_ssh = SshServiceDetails(addr="10.47.199.113", username="ute", password="ute")
_testpc1 = TestPc(default_ssh_connection_details=_testpc1_ssh, connections=[_gnb1])

_testpc2_ssh = SshServiceDetails(addr="10.47.199.114", username="ute", password="ute")
_testpc2 = TestPc(default_ssh_connection_details=_testpc2_ssh, connections=[_enb1])

_appserver_ssh = SshServiceDetails(addr="10.44.35.214", username="ute", password="ute")

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh, iperf_version=3
)

# ---------------- TL DEFINITION ------------------------
tl = TestLine(
    test_pc=_testpc1,
    test_pcs=[_testpc1, _testpc2],
    gnbs=[_gnb1],
    enbs=[_enb1],
    pdus=[_comu_pdu, _gnb1_rf_pdu],
    core=_tampereCore,
    #    ues=[_qualcomm1, _qualcomm2],
    ues=[_android1, _android2],
    appserver=_core_appserver,
    #    appserver=_app_server_1,
    attenuators=[_gnb_rf_att],
    tl_cloud_topology="CLASSICAL_5G",
)

__all__ = ["tl"]
