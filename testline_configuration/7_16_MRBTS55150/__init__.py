__maintainer__ = "Witold Galka"
__team__ = "MN 5G&SC 5G Pz 2 WRO 7 SG"
__email__ = "witold.galka@nokia.com"
__owner_email__ = "witold.galka@nokia.com"

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

# AHGA
_pdu1 = Gude(addr="10.44.177.34", port_numbers=[2], model="EPC", version="8221-1")

# AZQO
_pdu2 = Gude(addr="10.44.177.99", port_numbers=[4, 5], model="EPC", version="8221-1")

_pdus = [_pdu1, _pdu2]

_abil_master = CapacityUnit(addr="192.168.253.20")
_abil_slave = CapacityUnit(addr="192.168.253.21")
_abil_loner = CapacityUnit(addr="192.168.253.22")

_common_unit = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
    pdu_port=_pdu2.pdu_ports[4],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.70.248",
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
        v4="10.44.70.248",
        vlan_id=904,
        routing_v4=RoutingInformation(gateway="10.44.68.193/26"),
    ),
    x2u=NetworkAddress(
        v4="10.44.70.248",
        vlan_id=905,
        routing_v4=RoutingInformation(gateway="10.44.70.1/26"),
    ),
    s1u=NetworkAddress(
        v4="10.44.70.248",
        vlan_id=906,
        routing_v4=RoutingInformation(gateway="10.44.70.65/26"),
    ),
    tracing=None,
)

_cu.sync = NetworkAddress(
    v4="10.44.70.248",
    vlan_id=907,
    routing_v4=RoutingInformation(gateway="10.44.70.129/26"),
)

_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr=" ", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[4],
    ru_hw_group="",
    radio_type="AHGA",
)

_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr=" ", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[4],
    ru_hw_group="",
    radio_type="AZQO",
)

_du = DU(_airscale, rus=[_ru_1, _ru_2])

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=50064, instance_id=50064)

_core = RealCore5G(mcc=310, mnc=260)

_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_lte = CommonUnit(
    _common_unit_lte_ssh, capacity_units=[_abil_loner], pdu_port=_pdu2.pdu_ports[4]
)

_abia = CapacityUnit(addr="192.168.253.20")

_asia = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia],
    pdu_port=_pdu2.pdu_ports[4],
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.122", username="ute", password="ute"
    ),
    connections=[_cbts],
)

_lte = RealEnb(
    system_module=Airscale(common_units=[_asia]),
    x2_link_addr=NetworkAddress(
        v4="10.44.68.248",
        vlan_id=910,
        routing_v4=RoutingInformation(gateway="10.44.79.1/26"),
    ),
    global_bts_id=40064,
    instance_id=40064,
)

_lte_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.121", username="ute", password="ute"
    ),
    connections=[_lte],
)

_lte.m = NetworkAddress(
    v4="10.44.68.248",
    vlan_id=909,
    routing_v4=RoutingInformation(gateway="10.44.78.193/26"),
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc, _lte_test_pc],
    gnbs=[_cbts],
    enbs=[_lte, _lte.m],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_AHGA_AZQO",
    pdus=_pdus,
)

__all__ = ["tl"]
