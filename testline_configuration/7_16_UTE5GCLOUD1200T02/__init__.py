__maintainer__ = "Oliwier Cyran"
__team__ = "MN 5G RAN I&V 3PZ SISO"
__email__ = "oliwier.cyran@nokia.com"
__owner_email__ = "oliwier.cyran@nokia.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline import RealEnb
from taf.config.testline.core import RealCore5G
from taf.config.testline.attenuator import TopYoung
from taf.compatibility.configuration import TestlineWrapper
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.signal_analyzer import KeysightN9935A
import os


__all__ = ["tl"]

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.93", username="ute", password="ute"
    )
)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.1",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::1:a23d", vlan_id=370),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::1:a23d", vlan_id=370),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::1:a23d", vlan_id=370),
)


_pdu_gnb = Gude(addr="10.44.206.18", port_numbers=[5], model="EPC", version="8221-1")

_pdu_gnb_ru = ATEN(addr="10.42.61.112", port_numbers=[8])

_pdu_enb = Gude(addr="10.44.206.192", port_numbers=[9], model="EPC", version="8221-1")

_attenuator = TopYoung(ip_addr="10.42.54.112", port=23, attenuation_port_numbers=[1, 2])


_gnb_ru = RU(
    ru_hw_group="TDD",
    radio_type="AZQO",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.101.1", username="root", password="root"
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[8],
    signal_analyzer=KeysightN9935A(ip="10.42.54.183"),
    attenuation_ports=[_attenuator.attenuator_ports[1]],
)

_abil1_gnb_1_loner = CapacityUnit(addr="192.168.253.22")

_asik_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_loner],
    pdu_port=_pdu_gnb.pdu_ports[5],
)

_airscale_gnb_1 = Airscale([_asik_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru])

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.194.57", username="ute", password="ute"
    )
)

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    global_bts_id=40142,
    instance_id=1,
    x2_link_addr=NetworkAddress(v6="2a00:8a00:6000:607c::1:a23d"),
)

_enb_1.m_plane = NetworkAddress(v4="10.42.55.6")

_enb_1.u_plane = NetworkAddress(v6="2a00:8a00:6000:607c::1:a23d")

_enb_1.c_plane = NetworkAddress(v6="2a00:8a00:6000:607c::1:a23d")

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50142, instance_id=1
)

_attenuator = TopYoung(
    ip_addr="10.42.61.234", port=3001, attenuation_port_numbers=range(1, 16)
)

_core = RealCore5G()

_qualcomm_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "qualcomm_ue.yaml"
)

_tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_enb_1],
    gnbs=[_cbts],
    enbs=[_enb_1],
    ues=[_qualcomm_ue],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_QUALCOMM_ASIKL_ABILB1_AZQO_ENB",
    core=_core,
    pdus=[_pdu_gnb, _pdu_gnb_ru, _pdu_enb],
    attenuator=_attenuator,
)

tl = TestlineWrapper(_tl)
