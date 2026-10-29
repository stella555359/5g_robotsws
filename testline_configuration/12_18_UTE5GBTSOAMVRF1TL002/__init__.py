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
_pdu_du = Gude(addr="10.255.3.92", port_numbers=[7, 8], model="EPC", version="8221-1")
_pdu_ru = Gude(
    addr="10.255.3.91", port_numbers=[1, 2, 3, 4], model="EPC", version="8221-1"
)

_pdu_du.pdu_ports[7].contactor = "NORMALLY_OPEN"
_pdu_du.pdu_ports[8].contactor = "NORMALLY_OPEN"
_pdu_ru.pdu_ports[1].contactor = "NORMALLY_OPEN"
_pdu_ru.pdu_ports[2].contactor = "NORMALLY_OPEN"
_pdu_ru.pdu_ports[3].contactor = "NORMALLY_OPEN"
_pdu_ru.pdu_ports[4].contactor = "NORMALLY_OPEN"

_fsp_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIL",
    hardware_version="A.102",
    serial_number="L1190102644",
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.16",
    hardware_type="ABIO",
    hardware_version="A.103",
    serial_number="L1211508008",
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIL",
    hardware_version="A.102",
    serial_number="EA193273643",
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.32",
    hardware_type="ABIO",
    hardware_version="A.104",
    serial_number="L1213012524",
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1",
        username="toor4nsn",
        password="oZPS0POrRieRtu",
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_du.pdu_ports[7],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1211204986",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1",
        username="toor4nsn",
        password="oZPS0POrRieRtu",
    ),
    capacity_units=[_fsp_3, _fsp_4],
    pdu_port=_pdu_du.pdu_ports[8],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1192109432",
)
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="5GRU4.0",
    serial_number="L1200609801",
    pdu_port=_pdu_ru.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="5GRU4.0",
    serial_number="L1200609798",
    pdu_port=_pdu_ru.pdu_ports[2],
)

_rmod_3 = RU(
    ru_hw_group="5GRU4.0",
    serial_number="L1200609805",
    pdu_port=_pdu_ru.pdu_ports[3],
)

_rmod_4 = RU(
    ru_hw_group="5GRU4.0",
    serial_number="L1193610016",
    pdu_port=_pdu_ru.pdu_ports[4],
)

_du_1 = DU(
    airscale=_smod_1,
    rus=[_rmod_1, _rmod_2],
    f1_m_ip_addr="10.5.34.83",
)
_du_2 = DU(
    airscale=_smod_2,
    rus=[_rmod_3, _rmod_4],
    f1_m_ip_addr="10.5.34.83",
)
# 5G CU
_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.15.232.41",
        vlan_id=361,
        routing_v4=RoutingInformation(gateway="10.15.232.1", ip_prefix_length=26),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.15.232.41",
        vlan_id=361,
        routing_v4=RoutingInformation(gateway="10.15.232.1", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.15.232.41",
        vlan_id=361,
        routing_v4=RoutingInformation(gateway="10.15.232.1", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.15.232.41",
        vlan_id=361,
        routing_v4=RoutingInformation(gateway="10.15.232.1", ip_prefix_length=26),
    ),
)

_classical_bts_1 = ClassicalBts(
    dus=[_du_1], cu=_cu, instance_id=38083, global_bts_id=38083
)
_classical_bts_2 = ClassicalBts(
    dus=[_du_2], cu=_cu, instance_id=38083, global_bts_id=38083
)
# _enb_sbts_1 = RealEnb(airscale=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3])
# _enb_sbts_2 = RealEnb(airscale=_smod_2, rms=[_rmod_3, _rmod_4, _rmod_5, _rmod_6], master=_enb_sbts_1)
# _enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.25.176", username="ute", password="ute"),
    connections=[_classical_bts_1],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.25.177", username="ute", password="ute"),
    connections=[_classical_bts_2],
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_classical_bts_1, _classical_bts_2],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_MULTIGNB_ASIB_ABIL_ABIO_4xAEUD",
)
__all__ = ["tl"]
