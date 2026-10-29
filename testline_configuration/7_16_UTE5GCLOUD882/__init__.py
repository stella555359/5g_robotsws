__maintainer__ = "Maciej Cupial"
__team__ = "MN 5G&SC 5G Pz 2 WRO 7 SG"
__email__ = "I_5GSC_5G_PZ2_WRO_7@internal.nsn.com"
__owner_email__ = "maciej.cupial@nokia.com"
__BTS_owner__ = "kasia"


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
from taf.config.testline.pdu import Gude


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_real_android_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ues.yaml"
)

_attenuator = JFW(
    ip_addr="10.42.221.101",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    model="TAS_16T16_0_2G6_90_1S_DEJS",
)

# AZQO on the wall 582 1M203309887-B4
_pdu1 = Gude(
    addr="10.44.177.96", port_numbers=[10], model="EPC", version="8221-1"
)

# AZHL rack 1282 AH212600297-B3
_pdu2 = Gude(addr="10.44.205.60", port_numbers=[9], model="EPC", version="8221-1")

# AHLOA rack 2351 BL2106G10I3-A2
_pdu3 = Gude(addr="10.44.205.248", port_numbers=[2], model="EPC", version="8221-1")

# 5G smod DH220345033-B3
_pdu4 = Gude(addr="10.42.61.167", port_numbers=[9], model="EPC", version="8221-1")

_pdus = [_pdu1, _pdu2, _pdu3, _pdu4]

_abil_master = CapacityUnit(addr="192.168.253.20")
_abil_slave = CapacityUnit(addr="192.168.253.21")
_abil_loner = CapacityUnit(addr="192.168.253.22")

_common_unit = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
    pdu_port=_pdu4.pdu_ports[9],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.70.208",
        vlan_id=908,
        routing_v4=RoutingInformation(gateway="10.44.70.193/26"),
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
        v4="10.44.70.208",
        vlan_id=908,
        routing_v4=RoutingInformation(gateway="10.44.70.193/26"),
    ),
    x2u=NetworkAddress(
        v4="10.44.70.208",
        vlan_id=908,
        routing_v4=RoutingInformation(gateway="10.44.70.193/26"),
    ),
    s1u=NetworkAddress(
        v4="10.44.70.208",
        vlan_id=908,
        routing_v4=RoutingInformation(gateway="10.44.70.193/26"),
    ),
    tracing=None,
)

_cu.sync = NetworkAddress(
    v4="10.44.70.208",
    vlan_id=908,
    routing_v4=RoutingInformation(gateway="10.44.70.193/26"),
)

_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.48.162", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[10],
    ru_hw_group="",
    radio_type="AZQO",
)

_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.49.162", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[9],
    ru_hw_group="",
    radio_type="AZHL",
)

_ru_3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.50.2", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu3.pdu_ports[2],
    ru_hw_group="",
    radio_type="AHLOA",
)

_du = DU(_airscale, rus=[_ru_1, _ru_2, _ru_3])

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=50882, instance_id=50882)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.27", username="ute", password="ute"
    ),
    connections=[_cbts],
)

_core = RealCore5G(mcc=540, mnc=1)

# _common_unit_lte_ssh = SshServiceDetails(
    # addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
# )

# _common_unit_lte = CommonUnit(
    # _common_unit_lte_ssh, capacity_units=[_abil_loner], pdu_port=_pdu3.pdu_ports[4]
# )

# _abia = CapacityUnit(addr="192.168.253.20")

# _asia = CommonUnit(
    # lmp_connection=SshServiceDetails(
        # addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    # ),
    # capacity_units=[_abia],
# )

# _lte_test_pc = TestPc(
    # default_ssh_connection_details=SshServiceDetails(
        # addr="10.44.156.177", username="ute", password="ute"
    # )
# )

# _lte = RealEnb(
    # system_module=Airscale(common_units=[_asia]),
    # x2_link_addr=NetworkAddress(
        # v4="10.44.79.11",
        # vlan_id=910,
        # routing_v4=RoutingInformation(gateway="10.44.79.1/26"),
    # ),
    # global_bts_id=40067,
    # instance_id=40067,
# )

# _lte.m = NetworkAddress(
    # v4="10.44.78.203",
    # vlan_id=909,
    # routing_v4=RoutingInformation(gateway="10.44.78.193/26"),
# )

tl = TestLine(
    test_pc=_test_pc,
    # test_pcs=_lte_test_pc,
    gnbs=[_cbts],
    # enbs=[_lte],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_ATT_ASILL_ABIOB1B2B3_AZQO_AZHL_AHLOA",
    ues=[_real_android_ue],
    attenuator=_attenuator,
    pdus=_pdus,
)

__all__ = ["tl"]
