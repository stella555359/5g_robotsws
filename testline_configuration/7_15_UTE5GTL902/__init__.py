#######################################
#  TestLine 902 Ulm (7_15_UTE5GTL902) #
#######################################
__maintainer__ = "MN RAN Pz ULM"
__team__ = "MN RAN Pz ULM"
__email__ = "ran-pz-ulm-ta@list.nokia.com"

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
from taf.config.testline.core import RealCore4G
from taf.config.testline.ue import MediaTek, Android, Qualcomm
from taf.config.testline.ue import QualcommUeType, PluginAndroidClassType
from taf.config.testline.pdu import APC, PduPort, Gude
from taf.config.testline.radio import RU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.attenuator import HBTE


_tampereCore = RealCore4G(mcc="555", mnc="10")

_snmp_user_data = dict(
    userName="user",
    authKey="qwer2009!",
    privKey="qwer2009!",
    authProtocol="SHA",
    privProtocol="AES",
)

_eNB_gNB_rf_pdu = Gude(
    addr="10.46.148.81",
    port_numbers=[2, 3, 4, 7, 8, 10, 11],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# ---------------- START gnb-1 ------------------------ gnb_902-1

_gNB902_comu_pdu = Gude(
    addr="10.46.148.81",
    port_numbers=[7],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_gNB902_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="<GNB-0-MPLANE-IP>",
        routing_v4=RoutingInformation(
            gateway="<TL-GATEWAY-IP>", destIpAddr="<TL-S1NET-ADDRESS-RANGE>"
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="<GNB-0-MPLANE-IP>", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="<GNB-0-MPLANE-IP>", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="<GNB-0-CPLANE-IP>"),
    x2u=NetworkAddress(v4="<GNB-0-UPLANE-IP>"),
    s1u=NetworkAddress(v4="<GNB-0-UPLANE-IP>"),
)

_gNB902_capu1 = CapacityUnit(
    addr="192.168.253.20", 
    hardware_type="<GNB-0-CAPU1-HWTYPE>")

_gNB902_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB902_capu1],
    pdu_port=_eNB_gNB_rf_pdu.pdu_ports[7],
    hardware_type="<GNB-0-COMU-HWTYPE>",
)

_gNB902_airscale = Airscale(
    common_units=[_gNB902_comu])

_gNB902_du_rm_1 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_eNB_gNB_rf_pdu.pdu_ports[3],
    radio_type="FRPD",
    attenuation_ports=[
    ],
)

_gNB902_du_rm_2 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_eNB_gNB_rf_pdu.pdu_ports[4],
    radio_type="FRPD",
    attenuation_ports=[
    ],
)

_gNB902_du_rm_3 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_eNB_gNB_rf_pdu.pdu_ports[10],
    radio_type="MDEA",
    attenuation_ports=[
    ],
)

_gNB902_du = DU(
    airscale=_gNB902_airscale,
    rus=[
        _gNB902_du_rm_1,
        _gNB902_du_rm_2,
        _gNB902_du_rm_3,
    ],
)

_gNB902 = ClassicalBts(
    cu=_gNB902_cu,
    dus=[_gNB902_du])
# ---------------- END gnb-1 ------------------------


# ---------------- START eNB-1 ------------------------ eNB_902
_eNB902_comu_pdu = Gude(
    addr="10.46.148.81",
    port_numbers=[8],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

_eNB902_capu = CapacityUnit(
    addr="192.168.253.20")

_eNB902_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB902_capu],
    pdu_port=_eNB_gNB_rf_pdu.pdu_ports[8],
)

_eNB902_rm = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_eNB_gNB_rf_pdu.pdu_ports[2],
    radio_type="FRHC",
)

_eNB902_airscale = Airscale(
    common_units=[_eNB902_comu])

_eNB902 = RealEnb(
    system_module=_eNB902_airscale,
    rms=[_eNB902_rm],
    oam_ip=NetworkAddress(v4="<ENB-0-MPLANE-IP>"),
)
# ---------------- END eNB-1 ------------------------

# ---------------- START QC UE1: Qualcomm #29 SDX60 -------------------

_ASKEY_1_PDU = Gude(
    addr="10.46.148.81",
    port_numbers=[11],
    model="EPC",
    version="8221-1",
    snmp_user=_snmp_user_data,
)

_ue_ctrl_pc_ssh_details = SshServiceDetails(
    addr="10.46.148.12", username="deul5g", password="Nuc2Ue4PzLab!"
)

_ASKEY_902_1 = Android(
    ssh_connection_details=_ue_ctrl_pc_ssh_details,
    capabilities=["REAL_UE", "REAL_ANDROID_UE", "REAL_QUALCOMM_UE"],
    serial_number="<UE-0-SERIALNUM>",
    server_dir="C:/pyro_server",
    python_path="C:/Python38/python.exe",
    iperf_details=IperfDataTransferDetails(
        network_interface_address="",
        ssh_connection_details=_ue_ctrl_pc_ssh_details,
        iperf_path="/data/data/com.nokia.android.application/iperf",
    ),
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    pdu_port=_ASKEY_1_PDU.pdu_ports[11],
    class_name=PluginAndroidClassType.at_cmd,
)

# ---------------- END QC UE1 ------------------------

# ---------------- START TEST PCs ------------------------

_testpc1_ssh = SshServiceDetails(addr="10.46.148.91", username="ute", password="ute")
_testpc1 = TestPc(default_ssh_connection_details=_testpc1_ssh, connections=[_gNB902])

_testpc2_ssh = SshServiceDetails(addr="10.46.148.191", username="ute", password="ute")
_testpc2 = TestPc(default_ssh_connection_details=_testpc2_ssh, connections=[_eNB902])

# ---------------- END TEST PCs ------------------------

tl = TestLine(
    test_pc=_testpc1,
    test_pcs=[_testpc1, _testpc2],
    gnbs=[_gNB902],
    enbs=[_eNB902],
    pdus=[
        _gNB902_comu_pdu,
        _eNB902_comu_pdu,
        _eNB_gNB_rf_pdu,
    ],
    #core=_tampereCore,
    ues=[_ASKEY_902_1],
    #appserver=_core_appserver,
    #attenuators=[],
    tl_cloud_topology="CLASSICAL_5G",
)

__all__ = ["tl"]
