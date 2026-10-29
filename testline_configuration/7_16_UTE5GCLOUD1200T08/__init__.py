__maintainer__ = "Maciej Nowak"
__team__ = "MN 5G&SC 5G Pz 1 WRO 3 SG"
__email__ = "maciej.nowak@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.gnb.du import DU, RU
from taf.config.testline.core import RealCore4G
from taf.config.testline import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline.pdu import Gude

__all__ = ["tl"]

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="ute", password="ute"
    )
)

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.1",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4="10.1.1.3", v6=None, vlan_id=2441),
    x2u=NetworkAddress(v4="10.1.1.3", v6=None, vlan_id=2441),
    s1u=NetworkAddress(v4="10.1.1.7", v6=None, vlan_id=2441),
)

_pdu_gnb = Gude(addr="10.44.206.18", port_numbers=[6], model="EPC", version="8221-1")

_pdu_gnb_ru = Gude(addr="10.44.206.18", port_numbers=[1], model="EPC", version="8221-1")

_gnb_ru = RU(
    ru_hw_group="5Ggen3_LowF_2T2R",
    radio_type="AHPB",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.53", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="root"
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[1],
)

_abil1_gnb_1_loner = CapacityUnit(addr="192.168.253.22")

_asik_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_loner],
    pdu_port=_pdu_gnb.pdu_ports[6],
)

_airscale_gnb_1 = Airscale(common_units=[_asik_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru])

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="ute", password="ute"
    )
)

_abia_enb_1 = CapacityUnit(addr="192.168.253.20")

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_enb_1],
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50160, instance_id=1
)

_core = RealCore4G()

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    x2_link_addr=NetworkAddress(v4="10.1.1.7", vlan_id=1332),
    global_bts_id=40160,
    instance_id=1,
)

_enb_1.m_plane = NetworkAddress(v4="10.1.1.7", vlan_id=1332)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_enb_1],
    gnbs=[_cbts],
    enbs=[_enb_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AHPB",
    core=_core,
    pdus=[_pdu_gnb, _pdu_gnb_ru],
)
