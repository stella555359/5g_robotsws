__maintainer__ = "Tomasz Brzazgacz"
__team__ = "MN 5G&SC 5G Pz 2 WRO 7 SG"
__email__ = "I_MN_RAN_PZ2_WRO7_SG_GMS@internal.nsn.com"
__owner_email__ = "tomasz.brzazgacz@nokia.com"
__scout__ = "https://scout.nsn-rdnet.net/testlines/10_16_MRBTS-50892/preview"
__omnia__ = "https://omnia.krk-lab.nsn-rdnet.net/testline_id/TL9461"

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

# TODO: https://confluence.ext.net.nokia.com/display/mnsranprodiwkpz/Short+guide+about+__init__.py

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# TODO: TO BE ADDED
# _real_android_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
#     os.path.dirname(os.path.abspath(__file__)), "ues.yaml"
# )

# TODO: TO BE ADDED
# _attenuator = JFW(
#     ip_addr="0.0.0.0",
#     port=3001,
#     attenuation_port_numbers=range(1, 17),
#     model="TAS_16T16_0_2G6_90_1S_DEJS",
# )

# RMODs: 2xAQQA
_pdu1 = Gude(addr="10.44.177.202", port_numbers=[1, 2], model="EPC", version="8221-1")

# FRHB - port1, FRCG - port2, AHCA - port6, FHS/MDEA - port8
_pdu2 = Gude(addr="10.44.177.203", port_numbers=[1, 2, 6, 8], model="EPC", version="8221-1")

# FRGP - port1, FSMF smod - port5
_pdu3 = Gude(addr="10.44.177.204", port_numbers=[1, 5], model="EPC", version="8221-1")

_pdus = [_pdu1, _pdu2, _pdu3]

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
        v4="10.44.224.225", #BTS M-plane IPv4
        vlan_id=915,
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
        v4="10.44.224.225", #X2 C-plane IPv4 / IPv6
        vlan_id=916,
        routing_v4=RoutingInformation(gateway="10.44.68.193/26"),
    ),
    x2u=NetworkAddress(
        v4="10.44.224.225", #X2 U-plane IPv4 / IPv6
        vlan_id=917,
        routing_v4=RoutingInformation(gateway="10.44.70.1/26"),
    ),
    s1u=NetworkAddress(
        v4="10.44.224.225", #S1 U-plane primary IPv4 / IPv6
        vlan_id=918,
        routing_v4=RoutingInformation(gateway="10.44.70.65/26"),
    ),
    tracing=None,
)

_cu.sync = NetworkAddress(
    v4="10.44.224.225", #gNB 5giav_classical_sync
    vlan_id=919,
    routing_v4=RoutingInformation(gateway="10.44.70.129/26"),
)

# 5G RUs:
# 1M224505019:
_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[2],
    ru_hw_group="",
    radio_type="AQQA",
)

# 1M224505020:
_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[1],
    ru_hw_group="",
    radio_type="AQQA",
)


# LTE RUs:
# K9154009331:
_ru_3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[2],
    ru_hw_group="",
    radio_type="FRCG",
)

# L1120104303
_ru_4 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu3.pdu_ports[1],
    ru_hw_group="",
    radio_type="FRGP",
)

# EA145061870
_ru_5 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[1],
    ru_hw_group="",
    radio_type="FRHB",
)

# AS200205543
_ru_6 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[6],
    ru_hw_group="",
    radio_type="AHCA",
)

_du = DU(_airscale, rus=[_ru_1, _ru_2])

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=50892, instance_id=50892)

# VM 5G:
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.209.42", username="ute", password="Ut3pa5s#1be1"
    ),
    connections=[_cbts],
)

_core = RealCore5G(mcc=450, mnc=6)

#### LTE ####
_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

# TODO: pdu_port to be added
_common_unit_lte = CommonUnit(
    _common_unit_lte_ssh, capacity_units=[_abil_loner]
)

_abia = CapacityUnit(addr="192.168.253.20")

_asia = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia],
)

# VM LTE:
_lte_test_pc_40862 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.209.190", username="ute", password="Ut3pa5s#1be1"
    )
)

_lte_test_pc_40863 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.209.191", username="ute", password="Ut3pa5s#1be1"
    )
)

_lte_40862 = RealEnb(
    system_module=Airscale(common_units=[_asia]),
    x2_link_addr=NetworkAddress(
        v4="10.44.224.33", #eNB 5giav_classical_x2c
        vlan_id=915,
        routing_v4=RoutingInformation(gateway="10.44.224.1/26"),
    ),
    global_bts_id=40862,
    instance_id=40862,
)

_lte_40863 = RealEnb(
    system_module=Airscale(common_units=[_asia]),
    x2_link_addr=NetworkAddress(
        v4="10.44.224.161", #eNB 5giav_classical_x2c
        vlan_id=917,
        routing_v4=RoutingInformation(gateway="10.44.224.129/26"),
    ),
    global_bts_id=40863,
    instance_id=40863,
)

_lte_40862.m = NetworkAddress(
    v4="10.44.224.33",
    vlan_id=915,
    routing_v4=RoutingInformation(gateway="10.44.224.1/26"),
)

_lte_40863.m = NetworkAddress(
    v4="10.44.224.161",
    vlan_id=917,
    routing_v4=RoutingInformation(gateway="10.44.224.129/26"),
)

_lte_test_pc_40862.connections.append(_lte_40862.system_module.common_units[0])
_lte_test_pc_40863.connections.append(_lte_40863.system_module.common_units[0])


tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc, _lte_test_pc_40862, _lte_test_pc_40863],
    gnbs=[_cbts],
    enbs=[_lte_40862, _lte_40863],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AHLOA_ENB",
    pdus=_pdus,
)

__all__ = ["tl"]
