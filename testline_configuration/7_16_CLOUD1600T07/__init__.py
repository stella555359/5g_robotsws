__maintainer__ = "Patryk Wroniszewski"
__team__ = "MN 5G RAN I&V 3 Prodzn 04 RF & SiSo"
__email__ = "patryk.wroniszewski@nokia.com"

import os

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.gnb.du import DU, RU
from taf.config.testline.enb import RealEnb
from taf.config.testline.core import EPCSim
from taf.config.testline.pdu import Gude, ATEN
from taf.config.testline.testline import TestLine
from taf.compatibility.configuration import TestlineWrapper

__all__ = ["tl"]

# GNB VM settings

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.36", username="ute", password="ute"
    )
)

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="192.168.255.1"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.44.76.119"),
    x2u=NetworkAddress(v4="10.44.76.119"),
)


# PDU settings

_pdu_gnb = Gude(addr="10.1.1.250", port_numbers=[1])

_pdu_enb = Gude(addr="10.1.1.251", port_numbers=[2])

_pdu_gnb_ru = ATEN(addr="10.1.1.252", port_numbers=[10], model="ATEN")
#

_gnb_ru = RU(
    ru_hw_group="5Ggen4_LowF_2T2R",
    radio_type="AHFIB",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[10],
)

_abil1_gnb_1_loner = CapacityUnit(addr="192.168.253.22")

_asik_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_loner],
    pdu_port=_pdu_gnb.pdu_ports[1],
)

_airscale_gnb_1 = Airscale(common_units=[_asik_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru])

# ENB VM settings

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.37", username="ute", password="ute"
    )
)

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_enb.pdu_ports[2],
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    instance_id=40198,
    x2_link_addr=NetworkAddress(v6="2A00:8A00:6000:607c::4", vlan_id=821),
)


_enb_1.m_plane = NetworkAddress(v6="2A00:8A00:6000:607c::4", vlan_id=821)


_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=None, instance_id=50198
)

_core = EPCSim(
    mme_ip="2A00:8A00:6000:607c::4",
    mcc="555",
    mnc="10",
    tac=61,
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.67", username="ute", password="ute"
    ),
    dir_path="/opt/core",
    cfg_filename="epcsim.cfg",
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    enbs=[_enb_1],
    tl_cloud_topology="5G_CLASSICAL_ASIKA101L_ABILA101B1_AEQN_BRANCH_cOAM",
    core=_core,
    pdus=[_pdu_gnb, _pdu_gnb_ru, _pdu_enb],
    test_pcs=[_lmp_vm_enb_1],
)
