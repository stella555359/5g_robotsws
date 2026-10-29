__maintainer__ = "Mikolaj Guszpit"
__team__ = "MN 5G&SC 5G Pz 2 WRO 7 SG"
__email__ = "I_5GSC_5G_PZ2_WRO_7@internal.nsn.com"
__owner_email__ = "mikolaj.guszpit@nokia.com"


import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.attenuator import JFW
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb
from taf.config.testline.pdu import Gude


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# SMOD
_pdu1 = Gude(addr="10.44.205.104", port_numbers=[12], model="EPC", version="8221-1")

# AHEGB
_pdu2 = Gude(addr="10.44.205.248", port_numbers=[3], model="EPC", version="8221-1")

_pdus = [_pdu1, _pdu2]

_abil_master = CapacityUnit(addr="192.168.253.20")
_abil_slave = CapacityUnit(addr="192.168.253.21")
_abil_loner = CapacityUnit(addr="192.168.253.22")

_common_unit = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
    pdu_port=_pdu1.pdu_ports[12],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.45.178.52",
        vlan_id=851,
        routing_v4=RoutingInformation(gateway="10.45.178.1/26"),
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
        v4="10.45.178.116",
        vlan_id=852,
        routing_v4=RoutingInformation(gateway="10.45.178.65/26"),
    ),
    x2u=NetworkAddress(
        v4="10.45.178.180",
        vlan_id=853,
        routing_v4=RoutingInformation(gateway="10.45.178.129/26"),
    ),
    s1u=NetworkAddress(
        v4="10.45.178.244",
        vlan_id=854,
        routing_v4=RoutingInformation(gateway="10.45.178.193/26"),
    ),
    tracing=None,
)

_cu.sync = NetworkAddress(
    v4="10.45.179.52",
    vlan_id=855,
    routing_v4=RoutingInformation(gateway="10.45.179.1/26"),
)

_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="", password="\e\e\e"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[3],
    ru_hw_group="",
    radio_type="AHEGB",
)

_du = DU(_airscale, rus=[_ru_1])

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=40106, instance_id=40106)

_core = RealCore5G(mcc=310, mnc=260)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.69", username="ute", password="ute"
    ),
    connections=[_cbts],
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    pdus=_pdus,
)

__all__ = ["tl"]
