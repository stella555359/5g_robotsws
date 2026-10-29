#######################################
#  TestLine 906 Ulm (7_15_UTE5GTL906) #
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
    addr="10.46.148.84",
    port_numbers=[3, 6, 7],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# ---------------- START gnb-1 ------------------------ gnb_906-1

_gNB906_cu = CU(
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

_gNB906_capu1 = CapacityUnit(
    addr="192.168.253.20", 
    hardware_type="<GNB-0-CAPU1-HWTYPE>")

_gNB906_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB906_capu1],
    pdu_port=_eNB_gNB_rf_pdu.pdu_ports[7],
    hardware_type="<GNB-0-COMU-HWTYPE>",
)

_gNB906_airscale = Airscale(
    common_units=[_gNB906_comu])

_gNB906_du = DU(
    airscale=_gNB906_airscale,
    rus=[
    ],
)

_gNB906 = ClassicalBts(
    cu=_gNB906_cu,
    dus=[_gNB906_du])
# ---------------- END gnb-1 ------------------------

# ---------------- START gnb-2 ------------------------ gnb_906-2

_gNB906_2_cu = CU(
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

_gNB906_2_capu1 = CapacityUnit(
    addr="192.168.253.20", 
    hardware_type="<GNB-0-CAPU1-HWTYPE>")

_gNB906_2_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB906_2_capu1],
    pdu_port=_eNB_gNB_rf_pdu.pdu_ports[3],
    hardware_type="<GNB-0-COMU-HWTYPE>",
)

_gNB906_2_airscale = Airscale(
    common_units=[_gNB906_2_comu])

_gNB906_2_du = DU(
    airscale=_gNB906_2_airscale,
    rus=[
    ],
)

_gNB906_2 = ClassicalBts(
    cu=_gNB906_2_cu,
    dus=[_gNB906_2_du])
# ---------------- END gnb-2 ------------------------

# ---------------- START eNB-1 ------------------------ eNB_906

_eNB906_capu = CapacityUnit(
    addr="192.168.253.20")

_eNB906_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB906_capu],
    pdu_port=_eNB_gNB_rf_pdu.pdu_ports[6],
)

_eNB906_airscale = Airscale(
    common_units=[_eNB906_comu])

_eNB906 = RealEnb(
    system_module=_eNB906_airscale,
    rms=[],
    oam_ip=NetworkAddress(v4="<ENB-0-MPLANE-IP>"),
)
# ---------------- END eNB-1 ------------------------

# ---------------- START TEST PCs ------------------------

_testpc1_ssh = SshServiceDetails(addr="10.46.148.96", username="ute", password="ute")
_testpc1 = TestPc(default_ssh_connection_details=_testpc1_ssh, connections=[_gNB906])

_testpc2_ssh = SshServiceDetails(addr="10.46.148.196", username="ute", password="ute")
_testpc2 = TestPc(default_ssh_connection_details=_testpc2_ssh, connections=[_eNB906])

# ---------------- END TEST PCs ------------------------

tl = TestLine(
    test_pc=_testpc1,
    test_pcs=[_testpc1, _testpc2],
    gnbs=[_gNB906, _gNB906_2],
    enbs=[_eNB906],
    pdus=[
        _eNB_gNB_rf_pdu,
    ],
    #core=_tampereCore,
    ues=[],
    #appserver=_core_appserver,
    #attenuators=[],
    tl_cloud_topology="CLASSICAL_5G",
)

__all__ = ["tl"]
