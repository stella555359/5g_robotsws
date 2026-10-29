__maintainer__ = "Soufiane Benighil"
__team__ = "UTE 5G NPV"
__email__ = "I_UTE_5G_NPV@internal.nsn.com"
__owner_email__ = "soufiane.benighil@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RU, NetworkAddress
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline import RealEnb
from taf.config.testline.core import RealCore5G
from taf.config.testline import RoutingInformation

tl_name = "7_10_CLOUD5GNPVT103"


os.environ["INIT_CONFIG_FILE_PATH"] = os.path.dirname(os.path.abspath(__file__))
os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_config.yaml"
)

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.52.200.150", username="ute", password="ute"
    )
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.24.78.138",
        routing=RoutingInformation(gateway="10.24.78.137", ip_prefix_length=29),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.24.78.138"),
    x2u=NetworkAddress(v4="10.24.78.138"),
    s1u=NetworkAddress(v4="10.24.78.138"),
)

_gnb_ru2 = RU(
    ru_hw_group="Unknown",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
)

_core = RealCore5G(mcc=310, mnc=889)

_abil1_du1 = CapacityUnit(addr="192.168.253.20")

_asik_du1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_du1],
)

_airscale_gnb_1 = Airscale(common_units=[_asik_du1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru2])

_cbts = ClassicalBts(cu=_cu, dus=[_du_1_gnb_1], global_bts_id=103, instance_id=103)

# _lte = RealEnb(airscale=Airscale(common_units=[_asik_du1]),
#               x2_link_addr=NetworkAddress(v4='10.44.64.106',
#                                           vlan_id=454),
#               global_bts_id=40303)

# _lte.m = NetworkAddress(v4='10.44.64.42',
#                       vlan_id=455)

# _pdus = [_pdu_rmod1]

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_ASIKL_ABILB1_AEWD",
    core=_core,
)

__all__ = ["tl"]
