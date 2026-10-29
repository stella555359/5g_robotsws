__maintainer__ = "Kamil Ostrzolek"
__team__ = "I_5GSC_5G_PZ1_WRO_6"
__email__ = "I_5GSC_5G_PZ1_WRO_6@internal.nsn.com"
__owner_email__ = "kamil.ostrzolek@nokia.com"

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
        addr="10.44.149.94", username="ute", password="ute"
    )
)

_pdu_rmod1 = Gude(addr="10.44.206.134", port_numbers=[3], model="EPC", version="8221-1")
_pdu_rmod2 = Gude(addr="10.44.206.134", port_numbers=[7], model="EPC", version="8221-1")
_pdu_rmod3 = Gude(addr="10.44.206.134", port_numbers=[8], model="EPC", version="8221-1")
_pdu_asik = ATEN(addr="10.44.206.57", port_numbers=[7])
_pdus = [_pdu_rmod1, _pdu_rmod2, _pdu_rmod3, _pdu_asik]

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v6="2a00:8a00:6000:607c::1:6071",
        vlan_id=820,
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::1:b601", ip_prefix_length=120
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::1:6171", vlan_id=821),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::1:6241", vlan_id=822),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::1:6345", vlan_id=823),
)

_gnb_ru1 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AHDB",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.148", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_rmod1.pdu_ports[3],
)

_gnb_ru2 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AHDB",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.148", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_rmod2.pdu_ports[7],
)

_gnb_ru3 = RU(
    ru_hw_group="NR_RADIO",
    radio_type="AHDB",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.148", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_rmod3.pdu_ports[8],
)

_core = RealCore5G(mcc=555, mnc=10)

_abil1_du1 = CapacityUnit(addr="192.168.253.36")

_asik_du1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_du1],
    pdu_port=_pdu_asik.pdu_ports[7],
)

_airscale_gnb_1 = Airscale(common_units=[_asik_du1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru1, _gnb_ru2, _gnb_ru3])

_cbts = ClassicalBts(cu=_cu, dus=[_du_1_gnb_1], global_bts_id=50340, instance_id=50340)

_lte = RealEnb(
    system_module=Airscale(common_units=[_asik_du1]),
    x2_link_addr=NetworkAddress(v6="2a00:8a00:6000:607c::1:6136", vlan_id=821),
    global_bts_id=40322,
)

_lte.m = NetworkAddress(v6="2a00:8a00:6000:607c::1:6036", vlan_id=820)

tl = TestLine(
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIKR_ABILB4_3xAHDB",
    test_pc=_test_pc,
    pdus=_pdus,
    core=_core,
    gnbs=[_cbts],
    enbs=_lte,
)

__all__ = ["tl"]
