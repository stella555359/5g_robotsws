__maintainer__ = "Krystian Rzeczkowski"
__team__ = "I_5GSC_5G_PZ1_WRO_5"
__email__ = "I_5GSC_5G_PZ1_WRO_5@internal.nsn.com"
__owner_email__ = "krystian.rzeczkowski@nokia.com"

import os


from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.enb import RealEnb

from taf.config.testline import NetworkAddress, RoutingInformation


from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import ATEN, PduPort, Gude
from taf.config.testline.radio import RU
from taf.config.testline.core import RealCore4G


_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.41", username="ute", password="ute"
    )
)

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.64.18",
        v6="2A00:8A00:6000:607C::5512",
        vlan_id=454,
        routing_v4=RoutingInformation(gateway="10.44.64.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5501/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.64.82",
        v6="2a00:8a00:6000:607c::5612",
        vlan_id="455",
        routing_v4=RoutingInformation(gateway="10.44.64.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5601/120"),
    ),
    x2u=NetworkAddress(
        v4="10.44.64.146",
        v6="2a00:8a00:6000:607c::5712",
        vlan_id="456",
        routing_v4=RoutingInformation(gateway="10.44.64.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5701/120"),
    ),
    s1u=NetworkAddress(
        v4="10.44.64.228",
        v6="2a00:8a00:6000:607c::5814",
        vlan_id="457",
        routing_v4=RoutingInformation(gateway="10.44.64.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5801/120"),
    ),
)

_pdu_gnb = ATEN(addr="10.44.206.132", port_numbers=[1])
_pdu_gnb_ru1 = ATEN(addr="10.44.206.102", port_numbers=[7])
_pdu_gnb_ru2 = ATEN(addr="0.0.0.0", port_numbers=[0])
_pdu_fanbreaker = ATEN(addr="10.44.206.101", port_numbers=[5])
_pdu_gpsbreaker = ATEN(addr="0.0.0.0", port_numbers=[0])

_pdus = [_pdu_gnb, _pdu_gnb_ru1, _pdu_gnb_ru2, _pdu_fanbreaker, _pdu_gpsbreaker]

_gnb_ru = RU(
    ru_hw_group="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[7],
)

_abil1_gnb_1_master = CapacityUnit(addr="192.168.253.20")

_abil1_gnb_1_slave = CapacityUnit(addr="192.168.253.21")

_abil1_gnb_1_loner = CapacityUnit(addr="192.168.253.22")

_asik_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_master, _abil1_gnb_1_loner, _abil1_gnb_1_slave],
    pdu_port=_pdu_gnb.pdu_ports[1],
)

_airscale_gnb_1 = Airscale(common_units=[_asik_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru])

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.209.36", username="ute", password="ute"
    )
)

_pdu_enb = ATEN(addr="0.0.0.0", port_numbers=[0])

_asik_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_enb.pdu_ports[0],
)

_airscale_enb_1 = Airscale(common_units=[_asik_enb_1])

_enb_1 = RealEnb(
    system_module=_airscale_enb_1,
    global_bts_id=40399,
    instance_id=1900,
    x2_link_addr=NetworkAddress(v4="10.44.64.82", vlan_id=454),
)


_enb_1.m_plane = NetworkAddress(v4="10.44.64.87", vlan_id=326)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50398, instance_id=50398
)

_tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AHLOA_BRANCH"

_core = RealCore4G()

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    core=_core,
    tl_cloud_topology=_tl_cloud_topology,
    enbs=[_enb_1],
    test_pcs=[_lmp_vm_enb_1],
    pdus=_pdus,
)

__all__ = ["tl"]
