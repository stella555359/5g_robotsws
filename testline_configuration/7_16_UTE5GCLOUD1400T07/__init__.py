__maintainer__ = "Oliwier Cyran"
__team__ = "MN 5G&SC Pz 5G I&V 7 WRO 2 SG"
__email__ = "oliwier.cyran@nokia.com"
__owner_email__ = "oliwier.cyran@nokia.com"

import os
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
from taf.config.testline.core import RealCore4G
from taf.config.testline.attenuator import JFW
from taf.compatibility.configuration import TestlineWrapper
from taf.config.testline.pdu import Gude
from taf.config.testline.ue import Android
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.signal_analyzer import KeysightN9935A

__all__ = ["tl"]

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.90", username="ute", password="ute"
    )
)

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.1",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.42.181.201", vlan_id=370),
    x2u=NetworkAddress(v4="10.42.181.201", vlan_id=370),
    s1u=NetworkAddress(v4="10.42.181.202", vlan_id=370),
)


_pdu_gnb = Gude(addr="10.44.206.219", port_numbers=[5], model="EPC", version="8221-1")

_pdu_gnb_ru = Gude(
    addr="10.44.206.237", port_numbers=[1], model="EPC", version="8221-1"
)

_pdu_gnb_ru2 = Gude(
    addr="10.44.206.219", port_numbers=[6], model="EPC", version="8221-1"
)

_pdu_gnb_ru3 = Gude(
    addr="10.44.206.237", port_numbers=[2], model="EPC", version="8221-1"
)

_pdu_enb = Gude(addr="10.44.206.219", port_numbers=[6], model="EPC", version="8221-1")


_gnb_ru = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    radio_type="AHIB",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="root"
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[1],
    signal_analyzer=KeysightN9935A(ip="10.42.54.183"),
)


_gnb_ru2 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    radio_type="AHIB",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="root"
    ),
    pdu_port=_pdu_gnb_ru2.pdu_ports[6],
    signal_analyzer=KeysightN9935A(ip="10.42.54.183"),
)

_gnb_ru3 = RU(
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    radio_type="AHIB",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="root"
    ),
    pdu_port=_pdu_gnb_ru3.pdu_ports[2],
    signal_analyzer=KeysightN9935A(ip="10.42.54.183"),
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

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru, _gnb_ru2, _gnb_ru3])

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.194.122", username="ute", password="ute"
    )
)

_asik_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
)

_airscale_enb_1 = Airscale(common_units=[_asik_enb_1])

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    global_bts_id=40127,
    instance_id=1900,
    x2_link_addr=NetworkAddress(v4="10.42.181.201"),
)

_enb_1.m_plane = NetworkAddress(v4="10.42.181.101")


_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50127, instance_id=1900
)

_core = RealCore4G()

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_enb_1],
    gnbs=[_cbts],
    enbs=[_enb_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIKL_ABILB1_3xAHIB_ENB",
    core=_core,
    pdus=[_pdu_gnb, _pdu_gnb_ru, _pdu_gnb_ru2, _pdu_gnb_ru3, _pdu_enb],
)
