__maintainer__ = "Michal Lys"
__team__ = "I_5GSC_5G_PZ1_WRO_6"
__email__ = "I_5GSC_5G_PZ1_WRO_6@internal.nsn.com"
__owner_email__ = "michal.lys@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RU, NetworkAddress
from taf.config.testline.pdu import ATEN, Gude, PduPort
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline import RealEnb
from taf.config.testline.core import RealCore5G
from taf.config.testline import RoutingInformation

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.57", username="ute", password="ute"
    )
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v6="2a00:8a00:6000:607c::1:b615",
        vlan_id=480,
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b601"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::1:b715", vlan_id=481),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::1:b815", vlan_id=482),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::1:b918", vlan_id=483),
)

_pdu_asik = ATEN(addr="10.44.206.57", port_numbers=[6])
_pdu_rmod1 = ATEN(addr="10.42.61.95", port_numbers=[5])

_gnb_ru1 = RU(
    ru_hw_group="Unknown",
    radio_type="AEQN",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.128",
        username="serviceuser",
        password="w@=EIj7P6R0bVy85OjCVa^ho&8",
    ),
    pdu_port=_pdu_rmod1.pdu_ports[5],
)

_core = RealCore5G(mcc=555, mnc=10)

_abil1_du1 = CapacityUnit(addr="192.168.253.20")

_asik_du1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_asik.pdu_ports[6],
    capacity_units=[_abil1_du1],
)

_airscale_gnb_1 = Airscale(common_units=[_asik_du1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru1])

_cbts = ClassicalBts(cu=_cu, dus=[_du_1_gnb_1], global_bts_id=50334, instance_id=50334)

_lte = RealEnb(
    system_module=Airscale(common_units=[_asik_du1]),
    x2_link_addr=NetworkAddress(v6="2a00:8a00:6000:607c::1:bd12", vlan_id=486),
    global_bts_id=40318,
)

_lte.m = NetworkAddress(v6="2a00:8a00:6000:607c::1:bc12", vlan_id=486)

_pdus = [_pdu_rmod1, _pdu_asik]

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIKL_ABILB1_ECPRI_AEQN",
    core=_core,
    pdus=_pdus,
    enbs=_lte,
)

__all__ = ["tl"]
