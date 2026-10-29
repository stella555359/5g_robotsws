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
        addr="10.44.178.52", username="ute", password="ute"
    )
)

_pdu_rmod1 = Gude(addr="10.42.221.99", port_numbers=[2], model="EPC", version="8221-1")
_pdu_asoe = Gude(addr="10.42.221.99", port_numbers=[6], model="EPC", version="8221-1")
_pdus = [_pdu_rmod1, _pdu_asoe]

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v6="2a00:8a00:6000:607c::1:a809",
        vlan_id=897,
        routing_v6=RoutingInformation(
            gateway="a00:8a00:6000:607c::1:a80b", ip_prefix_length=120
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::1:b90b", vlan_id=898),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::1:aa07", vlan_id=899),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::1:ab07", vlan_id=900),
)

_gnb_ru1 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AZQO",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.148", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_rmod1.pdu_ports[2],
)
_asoe_du1_master = (CapacityUnit(addr="192.168.253.20"),)
_asoe_du1_slave = CapacityUnit(addr="192.168.253.21")
_asoe_du1_loner = CapacityUnit(addr="192.168.253.22")

_core = RealCore5G(mcc=555, mnc=10)

_asoe_du1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_asoe_du1_master, _asoe_du1_slave, _asoe_du1_loner],
    pdu_port=_pdu_asoe.pdu_ports[6],
)

_airscale_gnb_1 = Airscale(common_units=[_asoe_du1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru1])

_cbts = ClassicalBts(cu=_cu, dus=[_du_1_gnb_1], global_bts_id=50911, instance_id=50911)

_lte = RealEnb(
    system_module=Airscale(common_units=[_asoe_du1]),
    x2_link_addr=NetworkAddress(v6="2a00:8a00:6000:607c::1:a904", vlan_id=898),
    global_bts_id=410002,
)

_lte.m = NetworkAddress(v6="2a00:8a00:6000:607c::1:a804", vlan_id=897)

tl = TestLine(
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASOE_AZQO_ECPRI_ENB",
    test_pc=_test_pc,
    pdus=_pdus,
    core=_core,
    gnbs=[_cbts],
    enbs=_lte,
)

__all__ = ["tl"]
