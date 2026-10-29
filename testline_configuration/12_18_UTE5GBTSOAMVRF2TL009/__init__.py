__owner__ = "Preda Darius"
__maintainer__ = "Perecz Alexandru and Preda Darius"
__email__ = "alexandru.perecz@nokia.com"

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
_pdu_du = Gude(addr="10.255.3.26", port_numbers=[3], model="EPC", version="8221-1")
_pdu_du_ru = Gude(addr="10.255.3.24", port_numbers=[11], model="EPC", version="8221-1")

_pdu_du.pdu_ports[3].contactor = "NORMALLY_OPEN"
_pdu_du_ru.pdu_ports[11].contactor = "NORMALLY_OPEN"


_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    hardware_version="A.102",
    serial_number="EA191971829",
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1",
        username="toor4nsn",
        password="oZPS0POrRieRtu",
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_du.pdu_ports[3],
    hardware_type="ASIK",
    hardware_version="A.102",
    serial_number="EA193857323",
)

_smod_1 = Airscale([_fct_1])


_rmod_1 = RU(
    ru_hw_group="5GRU4.0",
    serial_number="L1200606764",
    pdu_port=_pdu_du_ru.pdu_ports[11],
)


_du_1 = DU(
    airscale=_smod_1,
    rus=[_rmod_1],
    f1_m_ip_addr="10.15.232.56",
)

# 5G CU
_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.15.232.56",
        vlan_id=361,
        routing_v4=RoutingInformation(gateway="10.15.232.1", ip_prefix_length=24),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.15.232.56",
        vlan_id=361,
        routing_v4=RoutingInformation(gateway="10.15.232.1", ip_prefix_length=24),
    ),
    x2u=NetworkAddress(
        v4="10.15.232.56",
        vlan_id=361,
        routing_v4=RoutingInformation(gateway="10.15.232.1", ip_prefix_length=24),
    ),
    s1u=NetworkAddress(
        v4="10.15.232.56",
        vlan_id=361,
        routing_v4=RoutingInformation(gateway="10.15.232.1", ip_prefix_length=24),
    ),
)

_classical_bts_1 = ClassicalBts(
    dus=[_du_1], cu=_cu, instance_id=10656, global_bts_id=10656
)

# _enb_sbts_1 = RealEnb(airscale=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3])
# _enb_sbts_2 = RealEnb(airscale=_smod_2, rms=[_rmod_3, _rmod_4, _rmod_5, _rmod_6], master=_enb_sbts_1)
# _enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.25.143", username="ute", password="ute"),
    connections=[_classical_bts_1],
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_classical_bts_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AZQG_CPRI_ENB",
)
__all__ = ["tl"]
