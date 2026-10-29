__owner__ = "Alin Necula"
__maintainer__ = "Alin Necula"
__email__ = "alin.necula@nokia.com"

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
_pdu_du = Gude(addr="10.255.3.26", port_numbers=[11, 12], model="EPC", version="8221-1")
_pdu_ru = Gude(addr="10.255.3.24", port_numbers=[12], model="EPC", version="8221-1")

_pdu_du.pdu_ports[11].contactor = "NORMALLY_OPEN"
_pdu_du.pdu_ports[12].contactor = "NORMALLY_OPEN"
_pdu_ru.pdu_ports[12].contactor = "NORMALLY_OPEN"

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="A.102",
    serial_number="L1210302300",
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="A.102",
    serial_number="L1210302261",
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIO",
    hardware_version="A.103",
    serial_number="L1211508207",
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="A.102",
    serial_number="L1210302220",
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIO",
    hardware_version="A.102",
    serial_number="L1210302219",
)

_fsp_6 = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIO",
    hardware_version="A.103",
    serial_number="L1212117748",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1",
        username="toor4nsn",
        password="oZPS0POrRieRtu",
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_du.pdu_ports[11],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1210402785",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1",
        username="toor4nsn",
        password="oZPS0POrRieRtu",
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_du.pdu_ports[12],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1210402774",
)
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="5GRU4.0",
    serial_number="CV192701452",
    pdu_port=_pdu_ru.pdu_ports[12],
)

_du_1 = DU(
    airscale=_smod_1,
    rus=[_rmod_1],
    f1_m_ip_addr="10.15.232.200",
)
_du_2 = DU(
    airscale=_smod_2,
    rus=[_rmod_1],
    f1_m_ip_addr="10.15.232.200",
)
# 5G CU
_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.15.232.200",
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
        v4="10.15.232.200",
        vlan_id=361,
        routing_v4=RoutingInformation(gateway="10.15.232.1", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.15.232.200",
        vlan_id=361,
        routing_v4=RoutingInformation(gateway="10.15.232.1", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.15.232.200",
        vlan_id=361,
        routing_v4=RoutingInformation(gateway="10.15.232.1", ip_prefix_length=26),
    ),
)

_classical_bts_1 = ClassicalBts(
    dus=[_du_1], cu=_cu, instance_id=10009, global_bts_id=10009
)
_classical_bts_2 = ClassicalBts(
    dus=[_du_2], cu=_cu, instance_id=10009, global_bts_id=10009
)
# _enb_sbts_1 = RealEnb(airscale=_smod_1, rms=[_rmod_1, _rmod_2, _rmod_3])
# _enb_sbts_2 = RealEnb(airscale=_smod_2, rms=[_rmod_3, _rmod_4, _rmod_5, _rmod_6], master=_enb_sbts_1)
# _enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.25.146", username="ute", password="ute"),
    connections=[_classical_bts_1],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.25.147", username="ute", password="ute"),
    connections=[_classical_bts_2],
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_classical_bts_1, _classical_bts_2],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_FULLRACK_ASILL_ABIOB1B3_AEQN_ECPRI_ASILR_ABIOB4B6_ENB",
)
__all__ = ["tl"]
