__maintainer__ = "Brian Bauerschmidt"
__team__ = "UTE 5G NPV"
__email__ = "I_UTE_5G_NPV@internal.nsn.com"
__owner_email__ = "brian.bauerschmidt@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RU, NetworkAddress
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.core import RealCore5G
from taf.config.testline import RoutingInformation
import yaml


def _set_abstract_lib_config_env(ue_config_file):
    tl_config_dir = os.path.dirname(os.path.abspath(__file__))
    ue_config_abs_path = os.path.join(tl_config_dir, ue_config_file)

    with open(ue_config_abs_path) as ta_ue_config:
        ue_config = yaml.safe_load(ta_ue_config)

    os.environ["ABSTRACT_LIB_CONFIG"] = ue_config_abs_path

    return ue_config


_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.52.200.151", username="ute", password="ute"
    )
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.24.78.139",
        routing=RoutingInformation(gateway="10.24.78.137", ip_prefix_length=29),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.24.78.139"),
    x2u=NetworkAddress(v4="10.24.78.139"),
    s1u=NetworkAddress(v4="10.24.78.139"),
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

_cbts = ClassicalBts(cu=_cu, dus=[_du_1_gnb_1], global_bts_id=104, instance_id=104)

_ue_config = _set_abstract_lib_config_env("ue_config.yaml")

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_ASIKL_3xABILB1__3xAEWB",
    core=_core,
)

__all__ = ["tl"]
