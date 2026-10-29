#######################################
#  TestLine 903 Ulm (7_15_UTE5GTL903) #
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
    addr="10.46.148.83",
    port_numbers=[1, 4, 5, 12],
    version="8221-1",
    model="EPC",
    snmp_user=_snmp_user_data,
)

# ---------------- START gnb-1 ------------------------ gnb_903-1

_gNB903_cu = CU(
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

_gNB903_capu1 = CapacityUnit(
    addr="192.168.253.20", 
    hardware_type="<GNB-0-CAPU1-HWTYPE>")

_gNB903_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gNB903_capu1],
    pdu_port=_eNB_gNB_rf_pdu.pdu_ports[5],
    hardware_type="<GNB-0-COMU-HWTYPE>",
)

_gNB903_airscale = Airscale(
    common_units=[_gNB903_comu])

_gNB903_du_rm_1 = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_eNB_gNB_rf_pdu.pdu_ports[12],
    radio_type="MDEA",
    attenuation_ports=[
    ],
)

_gNB903_du = DU(
    airscale=_gNB903_airscale,
    rus=[
        _gNB903_du_rm_1,
    ],
)

_gNB903 = ClassicalBts(
    cu=_gNB903_cu,
    dus=[_gNB903_du])
# ---------------- END gnb-1 ------------------------


# ---------------- START eNB-1 ------------------------ eNB_903

_eNB903_capu = CapacityUnit(
    addr="192.168.253.20")

_eNB903_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_eNB903_capu],
    pdu_port=_eNB_gNB_rf_pdu.pdu_ports[4],
)

_eNB903_rm = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_eNB_gNB_rf_pdu.pdu_ports[1],
    radio_type="FRPD",
)

_eNB903_airscale = Airscale(
    common_units=[_eNB903_comu])

_eNB903 = RealEnb(
    system_module=_eNB903_airscale,
    rms=[_eNB903_rm],
    oam_ip=NetworkAddress(v4="<ENB-0-MPLANE-IP>"),
)
# ---------------- END eNB-1 ------------------------

# ---------------- START TEST PCs ------------------------

_testpc1_ssh = SshServiceDetails(addr="10.46.148.94", username="ute", password="ute")
_testpc1 = TestPc(default_ssh_connection_details=_testpc1_ssh, connections=[_gNB903])

_testpc2_ssh = SshServiceDetails(addr="10.46.148.194", username="ute", password="ute")
_testpc2 = TestPc(default_ssh_connection_details=_testpc2_ssh, connections=[_eNB903])

# ---------------- END TEST PCs ------------------------

tl = TestLine(
    test_pc=_testpc1,
    test_pcs=[_testpc1, _testpc2],
    gnbs=[_gNB903],
    enbs=[_eNB903],
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
