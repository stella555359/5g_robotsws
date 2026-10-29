__maintainer__ = "Pawel Wisniewski"
__team__ = "MN 5G&SC 5G Pz 2 WRO 7 SG"
__email__ = "pawel.1.wisniewski@nokia.com"
__owner_email__ = "tomasz.brzazgacz@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.attenuator import JFW
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.testline import TestLine

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_abil_master = CapacityUnit(addr="192.168.253.20")
_abil_slave = CapacityUnit(addr="192.168.253.21")
_abil_loner = CapacityUnit(addr="192.168.253.22")

_common_unit = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.224.161",
        vlan_id=907,
        routing_v4=RoutingInformation(gateway="10.44.70.129/26"),
    ),
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
        v4="10.44.224.161",
        vlan_id=907,
        routing_v4=RoutingInformation(gateway="10.44.70.129/26"),
    ),
    x2u=NetworkAddress(
        v4="10.44.224.161",
        vlan_id=907,
        routing_v4=RoutingInformation(gateway="10.44.70.129/26"),
    ),
    s1u=NetworkAddress(
        v4="10.44.224.161",
        vlan_id=907,
        routing_v4=RoutingInformation(gateway="10.44.70.129/26"),
    ),
    tracing=None,
)

_cu.sync = NetworkAddress(
    v4="10.44.70.141",
    vlan_id=907,
    routing_v4=RoutingInformation(gateway="10.44.70.129/26"),
)

_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.2", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="",
    radio_type="FRGP",
)

_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.6", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="",
    radio_type="FRHB",
)

_ru_3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.10", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="",
    radio_type="AHCE",
)

_du = DU(
    _airscale,
    rus=[
        _ru_1,
        _ru_2,
        _ru_3,
    ],
)

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=40863, instance_id=40863)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.43.209.193", username="ute", password="ute"
    ),
    connections=[_cbts],
)

_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_lte = CommonUnit(_common_unit_lte_ssh, capacity_units=[_abil_loner])


tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
)

__all__ = ["tl"]
