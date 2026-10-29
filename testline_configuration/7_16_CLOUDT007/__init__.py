__maintainer__ = "Artur Jankowiak"
__team__ = "RRM team"
__email__ = "artur.jankowiak@nokia.com"
__owner_email__ = "artur.jankowiak@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb
from taf.config.testline.pdu import ATEN

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.18", username="ute", password="ute"
    )
)

_abil_master = CapacityUnit(addr="192.168.253.20")
_abil_slave = CapacityUnit(addr="192.168.253.21")
_abil_loner = CapacityUnit(addr="192.168.253.22")

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
    pdu_port=None,
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.80.20", vlan_id=459),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(
        v4="10.44.80.20",
        v6=None,
        vlan_id=459,
        routing_v4=RoutingInformation(gateway="10.44.80.1", ip_prefix_length=26),
    ),
    ngc=NetworkAddress(
        v4="10.44.80.20",
        v6=None,
        vlan_id=459,
        routing_v4=RoutingInformation(gateway="10.44.80.1", ip_prefix_length=26),
    ),
    s1c=NetworkAddress(
        v4="10.44.80.20",
        v6=None,
        vlan_id=459,
        routing_v4=RoutingInformation(gateway="10.44.80.1", ip_prefix_length=26),
    ),
)

_ru1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=None,
    ru_hw_group="",
    radio_type="AHLOA",
)

_ru2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=None,
    ru_hw_group="",
    radio_type="AHLOA",
)

_ru3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=None,
    ru_hw_group="",
    radio_type="AHLOA",
)

_du = DU(_airscale, rus=[_ru1, _ru2, _ru3])

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=51777, instance_id=51777)

_core = RealCore5G(mcc=540, mnc=1)

_abia = CapacityUnit(addr="192.168.253.20")

_asia = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia],
)

_lte = RealEnb(
    airscale=Airscale(common_units=[_asia]),
    x2_link_addr=NetworkAddress(
        v4="10.44.80.21",
        v6=None,
        vlan_id=821,
        routing_v4=RoutingInformation(gateway="10.44.80.1", ip_prefix_length=26),
    ),
    global_bts_id=40077,
)


def _adapt_path_from_yml(_ue):
    for k, v in _ue["UE_POOLS"]["ViaviUePool"].items():
        value = v["CONSTRUCTOR_PARAMETERS"]["script_paths"]["radio_card_config"]
        v["CONSTRUCTOR_PARAMETERS"]["script_paths"]["radio_card_config"] = os.path.join(
            os.path.dirname(os.path.abspath(__file__)), value
        )
        v["CONSTRUCTOR_PARAMETERS"]["script_paths"]["attach"] = os.path.join(
            os.path.dirname(os.path.abspath(__file__)),
            v["CONSTRUCTOR_PARAMETERS"]["script_paths"]["attach"],
        )
        v["CONSTRUCTOR_PARAMETERS"]["script_paths"]["detach"] = os.path.join(
            os.path.dirname(os.path.abspath(__file__)),
            v["CONSTRUCTOR_PARAMETERS"]["script_paths"]["detach"],
        )
    return _ue


with open(
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "viavi_config.yml")
) as ue_config:
    import yaml

    _ue = _adapt_path_from_yml(yaml.load(ue_config, yaml.SafeLoader))

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_VIAVI_ASIKL_ABILB1_3xAHLOA",
    core=_core,
    enbs=[_lte],
    ues=[_ue],
)

__all__ = ["tl"]
