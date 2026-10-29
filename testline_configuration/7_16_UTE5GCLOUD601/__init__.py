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
        addr="10.44.156.215", username="ute", password="ute"
    )
)

_pdu_rmod1 = Gude(addr="10.44.206.141", port_numbers=[3], model="EPC", version="8221-1")
_pdu_rmod2 = Gude(addr="10.44.206.143", port_numbers=[3], model="EPC", version="8221-1")
_pdu_asik = Gude(addr="10.44.205.110", port_numbers=[7], model="EPC", version="8221-1")
_pdus = [_pdu_rmod1, _pdu_rmod2, _pdu_asik]

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v6="2a00:8a00:6000:607c::1:b60a",
        vlan_id=480,
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b601"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::1:b70a", vlan_id=481),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::1:b80a", vlan_id=482),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::1:b90c", vlan_id=483),
)

_gnb_ru1 = RU(
    ru_hw_group="Unknown",
    radio_type="AZQO",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="serviceuser", password="umniedziala"
    ),
    pdu_port=_pdu_rmod1.pdu_ports[3],
)
_gnb_ru2 = RU(
    ru_hw_group="Unknown",
    radio_type="AZQO",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="serviceuser", password="umniedziala"
    ),
    pdu_port=_pdu_rmod2.pdu_ports[3],
)
_core = RealCore5G(mcc=555, mnc=10)

_abil1_du1 = CapacityUnit(addr="192.168.253.20")

_asik_du1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_du1],
    pdu_port=_pdu_asik.pdu_ports[7],
)

_airscale_gnb_1 = Airscale(common_units=[_asik_du1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru1, _gnb_ru2])

_cbts = ClassicalBts(cu=_cu, dus=[_du_1_gnb_1], global_bts_id=50327, instance_id=50327)

_lte = RealEnb(
    system_module=Airscale(common_units=[_asik_du1]),
    x2_link_addr=NetworkAddress(v6="2a00:8a00:6000:607c::1:bc09", vlan_id=486),
    global_bts_id=40316,
)

_lte.m = NetworkAddress(v6="2a00:8a00:6000:607c::1:bc09", vlan_id=486)

tl = TestLine(
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_2xAZQO_ECPRI",
    test_pc=_test_pc,
    pdus=_pdus,
    core=_core,
    gnbs=[_cbts],
    enbs=_lte,
)

__all__ = ["tl"]
