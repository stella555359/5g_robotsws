__maintainer__ = "Bartlomiej Lebda"
__team__ = "I_5GSC_5G_PZ1_WRO_6"
__email__ = "I_5GSC_5G_PZ1_WRO_6@internal.nsn.com"
__owner_email__ = "bartlomiej.lebda@nokia.com"

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
        addr="10.42.194.90", username="ute", password="ute"
    )
)

_pdu_rmod1 = ATEN(addr="10.42.61.94", port_numbers=[4])
_pdu_asib = ATEN(addr="10.44.206.57", port_numbers=[5])
_pdus = [_pdu_rmod1, _pdu_asib]

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v6="2a00:8a00:6000:607c::1:602a",
        vlan_id=820,
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:6001"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::1:612a", vlan_id=821),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::1:631e", vlan_id=822),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::1:641f", vlan_id=823),
)

_gnb_ru1 = RU(
    ru_hw_group="Unknown",
    radio_type="AEQN",
    default_ssh_connection_details=SshServiceDetails(
        addr="0.0.0.0", username="serviceuser", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    pdu_port=_pdu_rmod1.pdu_ports[4],
)

_core = RealCore5G(mcc=555, mnc=10)

_abil1_du1 = CapacityUnit(addr="192.168.253.20")

_asib_du1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_du1],
    pdu_port=_pdu_asib.pdu_ports[5],
)

_airscale_gnb_1 = Airscale(common_units=[_asib_du1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru1])

_cbts = ClassicalBts(cu=_cu, dus=[_du_1_gnb_1], global_bts_id=50326, instance_id=50326)

_lte = RealEnb(
    system_module=Airscale(common_units=[_asib_du1]),
    x2_link_addr=NetworkAddress(v6="2a00:8a00:6000:607c::1:6136", vlan_id=821),
    global_bts_id=40322,
)

_lte.m = NetworkAddress(v6="2a00:8a00:6000:607c::1:6036", vlan_id=820)

tl = TestLine(
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIBL_ABILB1_ECPRI_AEQN",
    test_pc=_test_pc,
    pdus=_pdus,
    core=_core,
    gnbs=[_cbts],
    enbs=_lte,
)

__all__ = ["tl"]
