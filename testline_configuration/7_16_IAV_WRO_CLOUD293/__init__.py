__maintainer__ = "Mikolaj Guszpit"
__team__ = "MN 5G&SC 5G Pz 2 WRO 7 SG"
__email__ = "I_5GSC_5G_PZ2_WRO_7@internal.nsn.com"
__owner_email__ = "mikolaj.guszpit@nokia.com"


import os
from taf.config.testline.testline import TestLine
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
from taf.config.testline.pdu import Gude


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_qualcomm_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "askey_ue.yaml"
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.195.177", username="ute", password="ute"
    )
)


_pdu1 = Gude(addr="10.44.205.8", port_numbers=[8, 9], model="EPC", version="8221-1")

_pdu2 = Gude(addr="10.44.206.13", port_numbers=[7], model="EPC", version="8221-1")

_abil_master = CapacityUnit(addr="192.168.253.20")
_abil_slave = CapacityUnit(addr="192.168.253.21")
_abil_loner = CapacityUnit(addr="192.168.253.22")

_common_unit = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
    pdu_port=_pdu2.pdu_ports[7],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.68.136",
        vlan_id=903,
        routing_v4=RoutingInformation(gateway="10.44.68.129/26"),
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
        v4="10.44.68.200",
        vlan_id=904,
        routing_v4=RoutingInformation(gateway="10.44.68.193/26"),
    ),
    x2u=NetworkAddress(
        v4="10.44.70.8",
        vlan_id=905,
        routing_v4=RoutingInformation(gateway="10.44.70.1/26"),
    ),
    s1u=NetworkAddress(
        v4="10.44.70.72",
        vlan_id=906,
        routing_v4=RoutingInformation(gateway="10.44.70.65/26"),
    ),
    tracing=None,
)

_cu.sync = NetworkAddress(
    v4="10.44.70.136",
    vlan_id=907,
    routing_v4=RoutingInformation(gateway="10.44.70.129/26"),
)

_ru = RU(
    ru_hw_group="hw_group",
    radio_type="AEQN",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.10.49", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(
        addr="TO_UPDATE", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu1.pdu_ports[9],
)


_du = DU(_airscale, rus=[_ru])

_classical_bts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=50058, instance_id=50058)

_core = RealCore5G(mcc=555, mnc=10)

_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_lte = CommonUnit(
    _common_unit_lte_ssh, capacity_units=[_abil_loner], pdu_port=_pdu2.pdu_ports[7]
)

_abia = CapacityUnit(addr="192.168.253.20")

_asia = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia],
)

_lte_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.195.200", username="ute", password="ute"
    )
)

_lte = RealEnb(
    system_module=Airscale(common_units=[_asia]),
    x2_link_addr=NetworkAddress(
        v4="10.44.79.9",
        vlan_id=910,
        routing_v4=RoutingInformation(gateway="10.44.79.1/26"),
    ),
    global_bts_id=40058,
    instance_id=40058,
)

_lte.m = NetworkAddress(
    v4="10.44.78.201",
    vlan_id=909,
    routing_v4=RoutingInformation(gateway="10.44.78.193/26"),
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=_lte_test_pc,
    gnbs=[_classical_bts],
    enbs=[_lte],
    ues=[_qualcomm_ue],
)

__all__ = ["tl"]
