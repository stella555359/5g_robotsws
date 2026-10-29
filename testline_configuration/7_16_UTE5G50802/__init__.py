__maintainer__ = "Marcin Prazjer"
__team__ = "MN 5G&SC 5G Pz 2 WRO 7 SG"
__email__ = "marcin.prajzner@nokia.com"
__owner_email__ = "marcin.prajzner@nokia.com"

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

# _real_android_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    # os.path.dirname(os.path.abspath(__file__)), "ues.yaml"
# )


# _qualcomm_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    # os.path.dirname(os.path.abspath(__file__)), "ues.yaml"
# )

_attenuator = JFW(
    ip_addr="10.42.61.71",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    model="TAS_16T16_0_2G6_90_1S_DEJS",
)

# PDU 5G RMODs
_pdu1 = Gude(
    addr="10.44.205.80", port_numbers=[7, 8, 9, 10, 11, 12], model="EPC", version="8221-1"
)

# PDU SMOD SFE1 gNB1_gNB2 eNB1 eNB2
_pdu2 = Gude(addr="10.44.205.104", port_numbers=[3, 4, 5], model="EPC", version="8221-1")


_pdus = [_pdu1, _pdu2]

_abil_master = CapacityUnit(addr="192.168.253.20")
_abil_slave = CapacityUnit(addr="192.168.253.21")
_abil_loner = CapacityUnit(addr="192.168.253.22")

_common_unit = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
    pdu_port=_pdu2.pdu_ports[3],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.70.13",
        vlan_id=905,
        routing_v4=RoutingInformation(gateway="10.44.70.1/26"),
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
        v4="10.44.70.13",
        vlan_id=905,
        routing_v4=RoutingInformation(gateway="10.44.70.1/26"),
    ),
    x2u=NetworkAddress(
        v4="10.44.70.13",
        vlan_id=905,
        routing_v4=RoutingInformation(gateway="10.44.70.1/26"),
    ),
    s1u=NetworkAddress(
        v4="10.44.70.13",
        vlan_id=905,
        routing_v4=RoutingInformation(gateway="10.44.70.1/26"),
    ),
    tracing=None,
)

_cu.sync = NetworkAddress(
    v4="10.44.70.13",
    vlan_id=905,
    routing_v4=RoutingInformation(gateway="10.44.70.1/26"),
)

_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.2", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[7],
    ru_hw_group="",
    radio_type="AEQN",
)

_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.6", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[9],
    ru_hw_group="",
    radio_type="AEQN",
)

_ru_3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.10", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[11],
    ru_hw_group="",
    radio_type="AEQN",
)

_ru_4 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.154", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[8],
    ru_hw_group="",
    radio_type="AEQN",
)

_ru_5 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.158", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[12],
    ru_hw_group="",
    radio_type="AEQN",
)

_ru_6 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.162", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[10],
    ru_hw_group="",
    radio_type="AEQN",
)

_du = DU(_airscale, rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6])

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=50802, instance_id=50802)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.209.185", username="ute", password="Ut3pa5s#1be1"
    ),
    connections=[_cbts],
)

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
    pdu_port=_pdu2.pdu_ports[5],
)

_lte_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.209.187", username="ute", password="Ut3pa5s#1be1"
    )
)

_lte = RealEnb(
    system_module=Airscale(common_units=[_asia]),
    x2_link_addr=NetworkAddress(
        v4="10.44.70.14",
        vlan_id=905,
        routing_v4=RoutingInformation(gateway="10.44.70.1/26"),
    ),
    global_bts_id=40801,
    instance_id=40801,
)

_lte.m = NetworkAddress(
    v4="10.44.70.14",
    vlan_id=905,
    routing_v4=RoutingInformation(gateway="10.44.70.1/26"),
)

tl = TestLine(
    test_pc=_test_pc,
    # test_pcs=_lte_test_pc, -> LTE to be added
    gnbs=[_cbts],
    enbs=[_lte],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_ATT_ASILL_ABILB1B2B3_3xAEQN_FRGU",
    # ues=[_real_android_ue],
    attenuator=_attenuator,
    pdus=_pdus,
)

__all__ = ["tl"]
