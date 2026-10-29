######################################
#  TestLine 106 Ulm                  #
######################################
__maintainer__ = "MN ECE RD ULM L2PS 04 SG SQD62"
__team__ = "MN ECE RD ULM L2PS 04 SG SQD62"
__email__ = "I_PZ_ULM_SQD_62@internal.nsn.com"

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


_snmp_user_data = dict(
    userName="user",
    authKey="qwer2009!",
    privKey="qwer2009!",
    authProtocol="SHA",
    privProtocol="AES",
)

_tampereCore = RealCore4G(mcc="555", mnc="10")

_core_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.44.35.210", username="ute", password="ute"
    ),
    network_interface_address="10.44.35.210",
    iperf_path="/usr/bin/iperf",
)

_core_appserver = AppServer(iperf_details=_core_iperf)

_rf_att = HBTE(
    ip_addr="10.46.133.80",
    port="5000",
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    version=None,
    model="PA-16-16-6-127-0.5-B-S",
)

# ---------------- START gnb-1 ------------------------ gnb_106-1
_comu_pdu = Gude(
    addr="10.46.133.12",
    port_numbers=[7, 8],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_gNB106_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.47.199.21",
        routing_v4=RoutingInformation(
            gateway="10.47.199.30", destIpAddr="10.47.199.0/27"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.47.199.21", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.47.199.21", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="10.47.199.22"),
    x2u=NetworkAddress(v4="10.47.199.23"),
    s1u=NetworkAddress(v4="10.47.199.23"),
)

_gNB106_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")

_gNB106_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB106_capu1],
    pdu_port=_comu_pdu.pdu_ports[7],
    hardware_type="ASIK",
)

_gNB106_airscale = Airscale(common_units=[_gNB106_comu])

_gNB106_du_rm_051 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    #    pdu_port=_comu_pdu.pdu_ports[4],
    radio_type="AHCA",
    attenuation_ports=[
        _rf_att.attenuator_ports[1],
        _rf_att.attenuator_ports[2],
        _rf_att.attenuator_ports[3],
        _rf_att.attenuator_ports[4],
    ],
)

_gNB106_du_rm_052 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    #    pdu_port=_comu_pdu.pdu_ports[5],
    radio_type="AHCA",
    attenuation_ports=[
        _rf_att.attenuator_ports[5],
        _rf_att.attenuator_ports[6],
        _rf_att.attenuator_ports[9],
        _rf_att.attenuator_ports[10],
    ],
)

_gNB106_du_rm_053 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    #    pdu_port=_comu_pdu.pdu_ports[6],
    radio_type="AHCA",
    attenuation_ports=[
        _rf_att.attenuator_ports[11],
        _rf_att.attenuator_ports[12],
        _rf_att.attenuator_ports[13],
        _rf_att.attenuator_ports[14],
    ],
)

_gNB106_du = DU(
    airscale=_gNB106_airscale,
    rus=[_gNB106_du_rm_051, _gNB106_du_rm_052, _gNB106_du_rm_053],
)

_gNB106 = ClassicalBts(cu=_gNB106_cu, dus=[_gNB106_du])
# ---------------- END gnb-1 ------------------------


# ---------------- START eNB-1 ------------------------ eNB_106
_eNB106_capu = CapacityUnit(addr="192.168.253.20")

_eNB106_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.47.199.20", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB106_capu],
    pdu_port=_comu_pdu.pdu_ports[8],
)

_eNB106_rm1 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    #    pdu_port=_comu_pdu.pdu_ports[6],
    radio_type="FRHC",
    attenuation_ports=[
        _rf_att.attenuator_ports[7],
        _rf_att.attenuator_ports[8],
        _rf_att.attenuator_ports[15],
        _rf_att.attenuator_ports[16],
    ],
)

_eNB106_airscale = Airscale(common_units=[_eNB106_comu])

_eNB106 = RealEnb(
    system_module=_eNB106_airscale,
    rms=[_eNB106_rm1],
    oam_ip=NetworkAddress(v4="10.47.199.20"),
)
# ---------------- END eNB-1 ------------------------

# ---------------- START QC UE1 ------------------------
_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.133.156", username="deul5g", password="Nuc2Ue4PzLab!"
)

_app_server_1 = TafUeAppServer(
    app_server_name="DEUL5Gappsrv10",
    address="10.47.194.210",
    user="ute",
    password="UTE.debian12",
    bind_interface_ip="10.47.194.210",
    binary_path="iperf",
    ports=[50010, 50006, 50007, 50008, 50009, 55254, 55130, 57254],
)


_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, version=2
)

_MTP_20 = TafUeAndroid(
    serial_number="34936379",
    ue_pc_address="10.46.133.156",
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE", "UE_1"],
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=_ue_ctrl_pc_ssh_details,
    ue_pc_port="8080",
)

# ---------------- END QC UE1 ------------------------
# ---------------- START TEST PCs --------------------
_gNB106_testpc1_ssh = SshServiceDetails(
    addr="10.47.199.243", username="ute", password="ute"
)
_gNB106_testpc1 = TestPc(
    default_ssh_connection_details=_gNB106_testpc1_ssh, connections=[_gNB106]
)

_eNB106_testpc2_ssh = SshServiceDetails(
    addr="10.47.199.244", username="ute", password="ute"
)
_eNB106_testpc2 = TestPc(
    default_ssh_connection_details=_eNB106_testpc2_ssh, connections=[_eNB106]
)
# ---------------- END TEST PCs ----------------------


tl = TestLine(
    test_pc=_gNB106_testpc1,
    test_pcs=[_gNB106_testpc1, _eNB106_testpc2],
    gnbs=[_gNB106],
    enbs=[_eNB106],
    pdus=[_comu_pdu],
    core=_tampereCore,
    ues=[_MTP_20],
    appserver=_core_appserver,
    attenuators=[_rf_att],
    tl_cloud_topology="CLASSICAL_5G",
)

__all__ = ["tl"]
