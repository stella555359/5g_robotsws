__maintainer__ = "Rafal Nowacki"
__team__ = "5G_PZ_2_WRO_6_SG"
__email__ = "rafal.nowacki@nokia.com"
__owner_email__ = "rafal.nowacki@nokia.com"

from taf.config.testline import DU, RU, RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.core import RealCore5G

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.124", username="ute", password="ute"
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
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.76.39", vlan_id=820),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.76.39", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.76.39", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(
        v4="10.44.76.98",
        vlan_id=821,
        routing=RoutingInformation(gateway="10.44.76.65", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.44.76.154",
        vlan_id=822,
        routing=RoutingInformation(gateway="10.44.76.129", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.44.76.218",
        vlan_id=823,
        routing=RoutingInformation(gateway="10.44.76.193", ip_prefix_length=26),
    ),
)

_cu.m = NetworkAddress(
    v4="10.44.76.40",
    vlan_id=820,
    routing=RoutingInformation(gateway="10.44.76.1", ip_prefix_length=26),
)

_cu.sync = NetworkAddress(
    v4="10.44.77.26",
    vlan_id=458,
    routing=RoutingInformation(gateway="10.44.77.1", ip_prefix_length=26),
)

_ru = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="",
    radio_type="AEUB",
)

_du = DU(airscale=_airscale, rus=[_ru])

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=50035, global_bts_id=50035)

_core = RealCore5G(mcc=555, mnc=10)


_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_lte = CommonUnit(
    lmp_connection=_common_unit_lte_ssh, capacity_units=[_abil_loner]
)

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
        v4="10.44.80.219",
        v6="2a00:8a00:6000:607c::5640",
        vlan_id=455,
        routing=RoutingInformation(gateway="10.44.80.193", ip_prefix_length=26),
    ),
    global_bts_id=40055,
)

_lte.m = NetworkAddress(
    v4="10.44.80.157",
    v6="2a00:8a00:6000:607c::5540",
    vlan_id=454,
    routing=RoutingInformation(gateway="10.44.80.1", ip_prefix_length=26),
)

_lte_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.158.123", username="ute", password="ute"
    ),
    connections=[_lte],
)

tl = TestLine(
    test_pc=_test_pc,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AEUB",
    test_pcs=[_test_pc, _lte_test_pc],
    gnbs=[_cbts],
    enbs=[_lte],
    core=_core,
)

__all__ = ["tl"]
