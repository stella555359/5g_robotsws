__owner__ = "Sabau Elena"
__maintainer__ = "Sabau Elena & Medesan George"
__email__ = "elena.sabau@nokia.com"

import os
import yaml
import re
from taf.config.testline.airscale import Airscale
from taf.config.testline import DU
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline.pdu import Gude
from taf.config.testline.gnb.networkaddress import NetworkAddress, RoutingInformation
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import CU, ClassicalBts

# Power breakers
_pdu_du = Gude(addr="10.255.3.92", port_numbers=[9], model="EPC", version="8221-1")
_pdu_ru = Gude(addr="10.255.3.91", port_numbers=[6], model="EPC", version="8221-1")

_pdu_du.pdu_ports[9].contactor = "NORMALLY_OPEN"
_pdu_ru.pdu_ports[6].contactor = "NORMALLY_OPEN"


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1",
        username="toor4nsn",
        password="oZPS0POrRieRtu",
    ),
    capacity_units=[],
    pdu_port=_pdu_du.pdu_ports[9],
    hardware_type="ASOE",
    hardware_version="A.X21",
    serial_number="EA210150258",
)

_smod_1 = Airscale([_fct_1])

_rmod_1 = RU(
    ru_hw_group="5GRU4.0",
    serial_number="CV192701182",
    pdu_port=_pdu_ru.pdu_ports[6],
)


_du_1 = DU(
    airscale=_smod_1,
    rus=[_rmod_1],
    f1_m_ip_addr="10.5.34.79",
)

# 5G CU
_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.15.232.41",
        vlan_id=301,
        routing_v4=RoutingInformation(gateway="10.15.232.1", ip_prefix_length=24),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.15.232.41",
        vlan_id=301,
        routing_v4=RoutingInformation(gateway="10.15.232.1", ip_prefix_length=24),
    ),
    x2u=NetworkAddress(
        v4="10.15.232.41",
        vlan_id=301,
        routing_v4=RoutingInformation(gateway="10.15.232.1", ip_prefix_length=24),
    ),
    s1u=NetworkAddress(
        v4="10.15.232.41",
        vlan_id=301,
        routing_v4=RoutingInformation(gateway="10.15.232.1", ip_prefix_length=24),
    ),
)

_classical_bts_1 = ClassicalBts(dus=[_du_1], cu=_cu, instance_id=2, global_bts_id=2)

# _enb_sbts_1 = RealEnb(airscale=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3])
# _enb_sbts_2 = RealEnb(airscale=_smod_2, rms=[_rmod_3, _rmod_4, _rmod_5, _rmod_6], master=_enb_sbts_1)
# _enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.25.174", username="ute", password="ute"),
    connections=[_classical_bts_1],
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_classical_bts_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASOE_AEQN",
)
__all__ = ["tl"]
