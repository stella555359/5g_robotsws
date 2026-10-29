__maintainer__ = "Michal Chamera"
__team__ = "I_5G_SISO_CRT_GMS"
__email__ = "michal.chamera@nokia.com"

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
from taf.config.testline import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import Gude, ATEN


__all__ = ["tl"]

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.160", username="ute", password="ute"
    )
)


_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.209.113", username="ute", password="ute"
    )
)


_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.1",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::1:a2dd", vlan_id=1001),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::1:a2dd", vlan_id=1001),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::1:a2dd", vlan_id=1001),
)


_pdu_gnb_ru = Gude(addr="10.44.205.63", port_numbers=[11], version="8221-1")


_ru = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AZQI",
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password="a2%FgSz3$fHmdusap354xujw7a"
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[11],
)


_abil1_gnb_1_loner = CapacityUnit(addr="192.168.253.38")
_asik_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1_loner],
)

_airscale_gnb_1 = Airscale(common_units=[_asik_gnb_1])


_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_ru])


_abia_enb_1 = CapacityUnit(addr="192.168.253.20")

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_enb_1],
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50196, instance_id=1
)


_enb_1 = RealEnb(
    system_module=_airscale_enb_1,
    x2_link_addr=NetworkAddress(v6="2a00:8a00:6000:607c::1:a2dd", vlan_id=1001),
    global_bts_id=40196,
    instance_id=40196,
)

_enb_1.m_plane = (NetworkAddress(v4="10.42.181.5", vlan_id=370),)
_core = RealCore5G()

tl = TestLine(
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_enb_1],
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    enbs=[_enb_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIKR_ABILB1_AZQI_ENB",
    core=_core,
    pdus=[_pdu_gnb_ru],
)
