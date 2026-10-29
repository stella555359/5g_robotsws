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

_qualcomm_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ues.yaml"
)

_att_1 = JFW(
    ip_addr="10.42.75.166",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    model="TAS_16T16_0_2G6_90_1S_DEJS",
)

_att_2 = JFW(
    ip_addr="10.42.75.167",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    model="TAS_16T16_0_2G6_90_1S_DEJS",
)

_CELL_MAP = {
    631: {"att_alias": "att_1", "att_ports": [21]},
    632: {"att_alias": "att_2", "att_ports": [6]},
    633: {"att_alias": "att_1", "att_ports": [5]},
    # 634: {"att_alias": "att_2", "att_ports": [7, 8, 9, 10]},
    635: {"att_alias": "att_1", "att_ports": [10]},
}

_pdu1 = Gude(addr="10.44.177.202", port_numbers=[3], model="EPC", version="8221-1")

_pdu2 = Gude(
    addr="10.44.177.203", port_numbers=[5, 7, 9], model="EPC", version="8221-1"
)

_pdu3 = Gude(addr="10.44.177.204", port_numbers=[2], model="EPC", version="8221-1")

_pdus = [_pdu1, _pdu2, _pdu3]

_abil_master = CapacityUnit(addr="192.168.253.20")
_abil_slave = CapacityUnit(addr="192.168.253.21")
_abil_loner = CapacityUnit(addr="192.168.253.22")

_common_unit = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
    pdu_port=_pdu3.pdu_ports[2],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.225.97",
        vlan_id=915,
        routing_v4=RoutingInformation(gateway="10.44.225.65/26"),
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
        v4="10.44.225.97",
        vlan_id=916,
        routing_v4=RoutingInformation(gateway="10.44.225.65/26"),
    ),
    x2u=NetworkAddress(
        v4="10.44.225.97",
        vlan_id=917,
        routing_v4=RoutingInformation(gateway="10.44.225.65/26"),
    ),
    s1u=NetworkAddress(
        v4="10.44.225.97",
        vlan_id=918,
        routing_v4=RoutingInformation(gateway="10.44.225.65/26"),
    ),
    tracing=None,
)

_cu.sync = NetworkAddress(
    v4="10.44.225.97",
    vlan_id=919,
    routing_v4=RoutingInformation(gateway="10.44.225.65/26"),
)

_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[3],
    ru_hw_group="",
    radio_type="AHGA",
)

_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.162", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[5],
    ru_hw_group="",
    radio_type="AZQS",
)

_ru_3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.2", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[9],
    ru_hw_group="",
    radio_type="AEQN",
)

_ru_4 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.158", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[7],
    ru_hw_group="",
    radio_type="AZQG",
)

_du = DU(_airscale, rus=[_ru_1, _ru_2, _ru_3, _ru_4])

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=50863, instance_id=50863)

_core = RealCore5G(mcc=450, mnc=6)

_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_lte = CommonUnit(
    _common_unit_lte_ssh, capacity_units=[_abil_loner], pdu_port=_pdu2.pdu_ports[5]
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
        v4="10.44.224.161",
        vlan_id=922,
        routing_v4=RoutingInformation(gateway="10.44.224.129/26"),
    ),
    global_bts_id=40863,
    instance_id=40863,
)

_lte.m = NetworkAddress(
    v4="10.44.224.161",
    v6="2a00:8a00:6000:607c::1:b405",
    vlan_id=921,
    routing_v4=RoutingInformation(gateway="10.44.224.129/26"),
)

_lte_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.209.191", username="ute", password="ute"
    ),
    connections=[_lte],
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.209.198", username="ute", password="ute"
    ),
    connections=[_cbts],
)

tl = TestLine(
    test_pc=_test_pc,
    # test_pcs=_lte_test_pc,
    gnbs=[_cbts],
    enbs=[_lte],
    pdus=_pdus,
    attenuator=[_att_1, _att_2],
    ues=[_qualcomm_ue],
)

tl.CELL_MAP = _CELL_MAP

__all__ = ["tl"]
